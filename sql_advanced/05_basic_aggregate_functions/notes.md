# Section 5: Basic Aggregate Functions, Conditional Aggregation & Temporal Grouping - Master Guide & Architectural Patterns

---

## 🚀 Masterclass Deep Dive: Conditional Aggregation & Temporal Grouping

Basic aggregation (`COUNT`, `SUM`, `AVG` with `GROUP BY`) groups rows into uniform buckets. However, production backend analytics and financial reporting engines rarely stop at simple counts. You frequently need to:

1. Extract **multiple conflicting or conditional metrics** across the exact same grouping bucket simultaneously (e.g., total transactions *and* approved transactions in a single table scan).
2. Filter or analyze data based on **sub-grouped chronological milestones** (e.g., isolating a user's absolute first action or calculating rolling retention).
3. Handle **temporal range joins** where records must align not just by identity keys, but across complex validity date windows (`BETWEEN start_date AND end_date`).

Mastering **Conditional Aggregation** (`CASE WHEN` inside aggregate functions), **First-Occurrence Subqueries**, and **Temporal Date Arithmetic** (`DATE_ADD`, `INTERVAL`) represents the critical bridge between intermediate query writing and senior backend database engineering.

---

## Problem-by-Problem Breakdown & Architectural Analysis

---

### 1. LeetCode 1193: Monthly Transactions I

* **Problem Pattern:** Conditional Aggregation and Date Truncation Grouping.
* **Source Context:** Transactions table containing transaction IDs, countries, states ("approved" or "declined"), monetary amounts, and timestamps. The objective is to compute monthly and country-wise metrics: total transaction count, approved transaction count, total transaction amount, and approved transaction amount.

#### 🧠 Core Concept & Intuition

When a reporting query requires slicing data into specific subsets of the same group (e.g., total vs. approved), developers often fall into the trap of writing separate queries or complex multi-table joins. The architectural secret is **Conditional Aggregation**: embedding control-flow statements (`CASE WHEN`) directly *inside* aggregate functions like `SUM` or `COUNT`. This instructs the database engine to evaluate specific row conditions on the fly during a single pass of the table.

#### 🔍 Personal Assessment & Weak Point Analysis

* **The Root Cause:** Transitioning from standard grouping to multi-metric conditional extraction often causes a mental roadblock. When faced with calculating total volume versus status-specific volume in a single pass, the lack of familiarity with putting control flow inside aggregate expressions leads to hesitation.
* **The Engineering Reflex:** Whenever a requirement asks for multiple sub-metrics from the same grouping bucket, your immediate reflex should be: *“I need a single table scan using conditional aggregation via `SUM(CASE WHEN condition THEN 1 ELSE 0 END)`.”*

#### 🚀 Best Engineering Approach

1. **Truncate Timestamps:** Standardize raw datetime values into structured monthly reporting buckets using `DATE_FORMAT(trans_date, '%Y-%m')`.
2. **Multi-Metric Extraction:** Use standard `COUNT`/`SUM` for global metrics, and conditionally wrapped expressions with `CASE WHEN` to isolate approved subsets.
3. **Cluster and Aggregate:** Group the final result set by the derived month and country fields.

#### ✅ Correct Code

```sql
SELECT 
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    COUNT(id) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY month, country;

```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`DATE_FORMAT(trans_date, '%Y-%m') AS month`**: Strips the day, hour, and minute components from the full timestamp, collapsing granular daily entries into clean monthly reporting buckets.
* **`SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END)`**: Evaluates every individual row. If the transaction state is approved, it contributes a `1` to the sum (acting as a conditional counter); otherwise, it evaluates to `0`. This calculates approved volume without globally filtering out declined records.
* **`SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END)`**: Accumulates monetary value exclusively for approved transactions, bypassing declined amounts entirely.

---

### 2. LeetCode 1174: Immediate Food Delivery II

* **Problem Pattern:** First-Occurrence Filtering and Percentage Calculation with Floating-Point Scaling.
* **Source Context:** Delivery table tracking order records, customer IDs, order dates, and customer preferred delivery dates. The goal is to find the percentage of immediate orders (where order date equals preferred delivery date) restricted strictly to each customer's *first* recorded order.

#### 🧠 Core Concept & Intuition

Computing metrics on "first events" requires isolating the baseline entry per entity using a correlated subquery or composite tuple filter. Once the dataset is restricted to initial orders, calculating a percentage requires dividing the count of conditional successes by the total population count, ensuring floating-point precision by scaling up with decimals (`100.0`).

#### 🚀 Best Engineering Approach

1. **Isolate First Orders:** Use a composite tuple subquery `(customer_id, order_date) IN (SELECT customer_id, MIN(order_date) ...)` to lock onto the baseline order for every single customer.
2. **Evaluate Condition:** Use inline conditional logic (`IF` or `CASE WHEN`) to check if `order_date = customer_pref_delivery_date`.
3. **Compute Ratio:** Divide successful immediate orders by total rows, scale by `100.0`, and round to two decimal places.

#### ✅ Correct Code

```sql
SELECT 
    ROUND(
        SUM(IF(order_date = customer_pref_delivery_date, 1, 0)) * 100.0 / COUNT(*), 
        2
    ) AS immediate_percentage
FROM Delivery
WHERE (customer_id, order_date) IN (
    SELECT customer_id, MIN(order_date)
    FROM Delivery
    GROUP BY customer_id
);

```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`WHERE (customer_id, order_date) IN (...)`**: Uses composite tuple matching to ensure that only rows matching a customer's absolute earliest order date pass through to the outer aggregation layer.
* **`IF(order_date = customer_pref_delivery_date, 1, 0)`**: Inline conditional check that yields `1` if the order is immediate, and `0` otherwise.
* **`* 100.0 / COUNT(*)`**: Prevents integer division rounding errors by forcing floating-point evaluation, yielding an accurate percentage value.

---

### 3. LeetCode 550: Game Play Analysis IV

* **Problem Pattern:** Consecutive-Day Retention Tracking via Self-Joins and Date Arithmetic.
* **Source Context:** Activity table tracking player login dates. The objective is to calculate the fraction of players who logged back in on the exact calendar day immediately following their initial login date.

#### 🧠 Core Concept & Intuition

Calculating user retention (returning on day $N+1$) requires comparing a user's *baseline* date against their *subsequent* event records. This is a classic architectural pattern: joining a pre-calculated baseline summary back onto the raw event stream using precise date interval math.

#### 🚀 Best Engineering Approach

1. **Derive Baselines:** Create a subquery or CTE capturing each user's initial login date (`MIN(event_date)`).
2. **Date Interval Match:** Join the raw activity table back to the baseline summary, verifying if an activity record exists exactly 24 hours (one day) after the first login.
3. **Calculate Fraction:** Divide the count of unique retained players by the total unique player population.

#### ✅ Correct Code

```sql
SELECT 
    ROUND(COUNT(DISTINCT a.player_id) / (SELECT COUNT(DISTINCT player_id) FROM Activity), 2) AS fraction
FROM Activity a
JOIN (
    SELECT player_id, MIN(event_date) AS first_login
    FROM Activity
    GROUP BY player_id
) b 
ON a.player_id = b.player_id
AND a.event_date = DATE_ADD(b.first_login, INTERVAL 1 DAY);

```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **Subquery `b**`: Extracts the exact starting login timestamp for every unique player in the system.
* **`DATE_ADD(b.first_login, INTERVAL 1 DAY)`**: Adds precisely one calendar day to the baseline login date, safely managing leap years and month transitions under the hood.
* **`JOIN ... ON ... AND a.event_date = ...`**: Restricts the join mechanism to rows where a player logged in on the exact day immediately following their debut.
* **`COUNT(DISTINCT a.player_id) / (...)`**: Computes the final retention ratio against the total player base, rounded to two decimal places.

---

### 4. LeetCode 1251: Average Selling Price

* **Problem Pattern:** Conditional Date Interval Joins and Null-Safe Aggregation.
* **Source Context:** A `Prices` table containing product IDs, pricing periods (`start_date` to `end_date`), and unit prices; paired with a `UnitsSold` table tracking individual purchase dates and quantities sold. The objective is to compute the average selling price for each product, ensuring that items with zero recorded sales default safely to an average price of zero.

#### 🧠 Core Concept & Intuition

When calculating metrics governed by temporal ranges, a basic identifier join is insufficient because rows must match both on identity *and* fall inclusively within a valid date window (`BETWEEN start_date AND end_date`). Furthermore, using a `LEFT JOIN` ensures that products with zero sales are preserved in the result stream rather than dropped entirely. Handling potential `NULL` divisions requires combining `COALESCE` with weighted averaging.

#### 🚀 Best Engineering Approach

1. **Range-Based Left Join:** Join `Prices` to `UnitsSold` on matching product IDs where the purchase date falls inclusively within the price validity window (`BETWEEN start_date AND end_date`).
2. **Calculate Weighted Revenue:** Multiply unit prices by units sold, sum them up, and divide by total units sold.
3. **Handle Unsold Products:** Wrap the calculation in `COALESCE(..., 0)` to gracefully output `0` for items with no sales history.

#### ✅ Correct Code

```sql
SELECT 
    Prices.product_id, 
    COALESCE(
        ROUND(SUM(Prices.price * UnitsSold.units) / SUM(UnitsSold.units), 2), 
        0
    ) AS average_price
FROM Prices
LEFT JOIN UnitsSold
  ON Prices.product_id = UnitsSold.product_id
  AND UnitsSold.purchase_date BETWEEN Prices.start_date AND Prices.end_date
GROUP BY Prices.product_id;

```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`LEFT JOIN ... ON ... AND UnitsSold.purchase_date BETWEEN Prices.start_date AND Prices.end_date`**: Maps sales transactions strictly to their corresponding historical price window for each product, while preserving unsold items via the `LEFT JOIN`.
* **`SUM(Prices.price * UnitsSold.units) / SUM(UnitsSold.units)`**: Computes the weighted average price by dividing total cumulative revenue by total units sold.
* **`COALESCE(..., 0)`**: Converts any `NULL` results (generated when an unsold product causes division by zero) into `0`, satisfying strict output requirements.
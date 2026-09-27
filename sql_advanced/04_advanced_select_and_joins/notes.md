# Section 4: Advanced Select, Window Functions, and Joins - Master Guide & Architectural Patterns

---

## 🚀 Masterclass Deep Dive: Window Functions & Temporal Data States

As a backend engineer, basic `SELECT` and `WHERE` clauses will only get you through entry-level tasks. When building production analytics, financial ledgers, or inventory tracking systems, you need **Window Functions** (`OVER`, `PARTITION BY`, `RANK`) and advanced set operations (`UNION ALL`). Window functions allow you to perform calculations across rows related to the current row without collapsing the entire result set like a traditional `GROUP BY` does.

---

## Problem-by-Problem Breakdown

---

### 1. LeetCode 1204: Last Person to Fit in the Bus

* **Problem Pattern:** Cumulative Running Sum with Window Functions.
* **Source Context:** Queue table tracking people waiting to board a bus with their weights and boarding turn order, where the goal is to find the name of the last person who can board without exceeding a total weight limit of 1000 kilograms.

#### 🧠 Core Concept & Intuition

When you need to track running totals (like a bank account balance sheet or cumulative cargo weight), you cannot use a simple aggregate sum because you need the running accumulation at *every single step*. This is where the running window sum (`SUM() OVER (...)`) becomes your most powerful tool. It calculates the cumulative weight ordered strictly by the boarding turn.

#### ❌ Student Pitfalls & Wrong Code

Students frequently get stuck because they try to use a standard `SUM(weight)` with a `GROUP BY`, which collapses the rows into a single total and completely destroys the sequence order. Without knowing window functions, writing procedural loops in SQL feels impossible.

#### 🚀 Best Engineering Approach

1. **Compute a Running Total:** Use `SUM(weight) OVER (ORDER BY turn ASC)` inside a CTE to generate an ongoing cumulative weight for each person as they line up.
2. **Filter and Slice:** Filter the cumulative table where the running weight is less than or equal to 1000, sort descending by total weight to get the person closest to the limit, and pick the top result using `LIMIT 1`.

#### ✅ Correct Code

```sql
WITH cumulative_wt AS (
    SELECT 
        person_name,
        SUM(weight) OVER (ORDER BY turn ASC) AS total_wt
    FROM Queue
)
SELECT person_name
FROM cumulative_wt
WHERE total_wt <= 1000
ORDER BY total_wt DESC
LIMIT 1;

```

#### 📝 Detailed Explanation of Code & Logic

* **`SUM(weight) OVER (ORDER BY turn ASC)`**: This is the window function engine. Instead of grouping all rows together, it processes rows sequentially based on the `turn` column, adding up the weights progressively (Person 1 weight, then Person 1 + Person 2, then Person 1 + Person 2 + Person 3, etc.).
* **`WHERE total_wt <= 1000`**: Filters out everyone whose cumulative weight breached the bus limit.
* **`ORDER BY total_wt DESC LIMIT 1`**: Sorts the surviving valid cumulative weights from highest to lowest and extracts the very last person who fit right before the threshold was crossed.

---

### 2. LeetCode 1907: Count Salary Categories

* **Problem Pattern:** Categorical Distribution and Zero-Row Preservation via `UNION ALL`.
* **Source Context:** Accounts table containing monthly bank account incomes, where the goal is to calculate the account counts for three strict salary categories ("Low Salary", "Average Salary", "High Salary"), ensuring that categories with zero matching accounts still appear with a count of 0.

#### 🧠 Core Concept & Intuition

A standard `GROUP BY` query in SQL completely omits categories that have zero matching rows in the database. However, reporting dashboards require fixed categories to always be present. To guarantee that all categories are rendered even if their count is zero, you execute independent scalar queries for each category and stitch them together using `UNION ALL`.

#### ❌ Student Pitfalls & Wrong Code

Using a standard `GROUP BY category` approach. If the "Average Salary" bucket has 0 accounts in the dataset, a standard group-by query will drop that category entirely from the output table, failing the test case requirement.

#### 🚀 Best Engineering Approach

Use individual `SELECT` statements for each explicit category combined with `UNION ALL`. Because an aggregate function like `COUNT(*)` evaluated on an empty filtered subset in SQL always returns a single row with a value of `0` (rather than zero rows), `UNION ALL` guarantees all three category rows are always returned.

#### ✅ Correct Code

```sql
SELECT 'Low Salary' AS category, COUNT(*) AS accounts_count
FROM Accounts
WHERE income < 20000

UNION ALL

SELECT 'Average Salary' AS category, COUNT(*) AS accounts_count
FROM Accounts
WHERE income >= 20000 AND income <= 50000

UNION ALL

SELECT 'High Salary' AS category, COUNT(*) AS accounts_count
FROM Accounts
WHERE income > 50000;

```

#### 📝 Detailed Explanation of Code & Logic

* **`SELECT 'Low Salary' AS category, COUNT(*) AS accounts_count`**: Hardcodes the category label string as a column while counting how many records match the income condition (`< 20000`). If no accounts match, `COUNT(*)` safely outputs `0`.
* **`UNION ALL`**: Appends the result sets of the three independent queries vertically into a single consolidated table without overhead duplicate filtering. This ensures all three salary categories are rigidly displayed every single time.

---

### 3. LeetCode 1164: Product Price at a Given Date

* **Problem Pattern:** Temporal State Resolution via Window Ranking (`PARTITION BY` + `RANK`) combined with Default Fallback via `UNION`.
* **Source Context:** Products table tracking historical price modifications over time, where the goal is to determine the active price of every unique product on a specific target date (`2019-08-16`).

#### 🧠 Core Concept & Intuition

Handling temporal (time-series) data is a core backend engineering challenge. If a product's price changed multiple times, you need to find the **most recent price change that occurred on or before the target date**.

However, a complete temporal solution must account for two distinct states:

1. **Products with history:** Products that experienced at least one price update on or before the target date.
2. **Products without history:** Products whose very first price change happened *after* the target date (or never changed at all). Per business rules, these default to an initial baseline price of `10`.

Handling both states requires a multi-part query architecture.

#### ❌ Student Pitfalls & Wrong Code

* **The Pitfall:** Trying to use `MAX(change_date)` directly in a standard `GROUP BY` query.
* **Why it fails:** While `MAX(change_date)` successfully finds the latest date, grouping by product ID alone prevents you from directly selecting the `new_price` associated with that specific date without writing messy, inefficient correlated subqueries or unnecessary self-joins.

#### 🚀 Best Engineering Approach

1. **Filter Temporal Bounds (Part 1):** Restrict historical records using a CTE to only include changes on or before the target date (`change_date <= '2019-08-16'`).
2. **Partition and Rank:** Use the window ranking function `RANK() OVER (PARTITION BY product_id ORDER BY change_date DESC)` to assign rank `1` to the most recent historical price for every product.
3. **Handle Default Fallbacks (Part 2):** Identify products that lack any history prior to the target date using a `NOT IN` subquery and explicitly assign them the default price of `10`.
4. **Merge Datasets:** Combine Part 1 and Part 2 using a `UNION` clause to yield the final clean output table.

#### ✅ Correct Code

```sql
WITH before_change_date AS (
    SELECT 
        product_id, 
        new_price AS price, 
        RANK() OVER (PARTITION BY product_id ORDER BY change_date DESC) AS rnk 
    FROM Products 
    WHERE change_date <= '2019-08-16'
)
SELECT product_id, price 
FROM before_change_date 
WHERE rnk = 1

UNION 

SELECT DISTINCT product_id, 10 AS price 
FROM Products 
WHERE product_id NOT IN (
    SELECT product_id 
    FROM Products 
    WHERE change_date <= '2019-08-16'
);

```

#### 📝 Detailed Explanation of Code & Logic & Clauses Breakdown

##### Part 1: Resolving Historical Prices

```sql
WITH before_change_date AS (
    SELECT 
        product_id, 
        new_price AS price, 
        RANK() OVER (PARTITION BY product_id ORDER BY change_date DESC) AS rnk 
    FROM Products 
    WHERE change_date <= '2019-08-16'
)
SELECT product_id, price 
FROM before_change_date 
WHERE rnk = 1

```

* **`WHERE change_date <= '2019-08-16'`**: Discards all future price updates, restricting data scope strictly to changes occurring on or before the target date.
* **`PARTITION BY product_id`**: Creates isolated evaluation buckets for each unique product so calculations do not mix across different items.
* **`ORDER BY change_date DESC`**: Sorts each product's price history chronologically backwards, ensuring the most recent date gets ranked first.
* **`RANK() OVER (...) AS rnk`**: Assigns ranking integers. The maximum date prior to the target date receives `rnk = 1`.
* **`WHERE rnk = 1`**: Filters the CTE to extract only the latest valid historical price for qualifying products.

##### Part 2: Handling the Default Price Fallback

```sql
SELECT DISTINCT product_id, 10 AS price 
FROM Products 
WHERE product_id NOT IN (
    SELECT product_id 
    FROM Products 
    WHERE change_date <= '2019-08-16'
);

```

* **Why it's necessary:** Products whose first price modification happened *after* `2019-08-16` will not appear in Part 1 at all.
* **`WHERE product_id NOT IN (SELECT product_id FROM Products WHERE change_date <= '2019-08-16')`**: Evaluates all products that *did* have prior history, and uses `NOT IN` to capture the leftover products that had zero updates on or before the target date.
* **`SELECT DISTINCT product_id, 10 AS price`**: Forces these untouched products to output the system default baseline price of `10`.

##### Part 3: The Glue (`UNION`)

* **`UNION`**: Merges the custom historical prices from Part 1 and the default baseline prices from Part 2 into a single unified result set, automatically stripping away any duplicate rows.
# Section 6: Advanced Subqueries, CTEs & Complex Query Patterns - Master Guide

---

## 🚀 Masterclass Deep Dive: Moving Beyond Basic Joins

When building production backend architectures, queries rarely stop at simple lookups or two-table joins. You frequently encounter complex relational challenges that require multi-layered logic:

1. **Multi-Condition Filtering via Subqueries (`IN`, Composite Tuples):** Isolating records that match aggregate criteria across different dimensions simultaneously (e.g., matching investment value distributions while filtering for geographic uniqueness).
2. **Sequential and Relational State Shifting (`CASE WHEN`, Modulo Arithmetic):** Dynamically transforming row IDs or alternating values based on sequence parity.
3. **Partitioned Ranking & Window Frames (`DENSE_RANK`, `ROWS BETWEEN`):** Computing relative hierarchies, top-N elements per category, or rolling window aggregations (e.g., 7-day moving averages).
4. **Graph Degree Counting & Set Unioning (`UNION ALL`):** Aggregating bidirectional relationships where an entity can appear across multiple columns (e.g., tracking total friends from both requester and accepter vectors).

Mastering these patterns ensures you can write high-performance analytical queries that handle complex business logic directly at the database layer.


## Problem-by-Problem Architectural Breakdown


### 1. LeetCode 585: Investments in 2016

* **Problem Number:** LC 585
* **Problem Pattern:** Multi-Condition Subquery Filtering with Composite Tuples and Aggregate Validation (`GROUP BY` + `HAVING`).
* **Source Context:** Insurance table tracking policyholder IDs (`pid`), 2015 investment values (`tiv_2015`), 2016 investment values (`tiv_2016`), and geographic coordinates (`lat`, `lon`). The objective is to compute the sum of `tiv_2016` for policyholders who meet two strict business rules:
1. Their `tiv_2015` value matches that of one or more other policyholders.
2. Their geographic location (`lat`, `lon`) is completely unique across the entire dataset.



#### 🧠 Core Concept & Intuition

When a query requires validating independent conditions across different columns, trying to cram everything into a single join can cause row multiplication or logic collision. The clean engineering approach is to treat each business rule as an isolated filter condition using subqueries paired with `GROUP BY` and `HAVING`. Furthermore, matching multi-column coordinates simultaneously requires **composite tuple matching** (`(lat, lon) IN (...)`).

#### 🚀 Best Engineering Approach

1. **Filter Shared Investments:** Use a subquery with `GROUP BY tiv_2015 HAVING COUNT(*) > 1` to isolate investment values held by multiple people.
2. **Filter Unique Locations:** Use a subquery with composite attributes `(lat, lon) IN (SELECT lat, lon FROM Insurance GROUP BY lat, lon HAVING COUNT(*) = 1)` to guarantee geographic uniqueness.
3. **Aggregate and Round:** Sum the `tiv_2016` values of the records surviving both filters and round the final output to two decimal places.

#### ✅ Correct Code

```sql
SELECT ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM Insurance
WHERE tiv_2015 IN (
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
)
AND (lat, lon) IN (
    SELECT lat, lon
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1
);

```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`WHERE tiv_2015 IN (...)`**: Ensures that only policyholders sharing a 2015 investment footprint with others qualify.
* **`AND (lat, lon) IN (...)`**: Implements composite tuple filtering, evaluating latitude and longitude together as a single coordinate pair to ensure exact geographic isolation.
* **`ROUND(..., 2)`**: Formats the final financial aggregation to standard two-decimal precision.

---

### 2. LeetCode 626: Exchange Seats

* **Problem Number:** LC 626
* **Problem Pattern:** Sequence Parity Manipulation via Conditional Branching (`CASE WHEN`) and Scalar Subquery Lookups.
* **Source Context:** Seat table containing continuous incremental student IDs and names. The objective is to swap the seat ID of every two consecutive students (ID 1 swaps with 2, 3 with 4, etc.). If the total number of students is odd, the final student's ID remains unchanged.

#### 🧠 Core Concept & Intuition

When reshaping sequential data dynamically, standard joins can become cumbersome. Instead, we can evaluate each row's ID based on its mathematical parity (even or odd). For odd IDs, we want to shift them up by 1 (unless they are the absolute maximum ID in the table). For even IDs, we want to shift them down by 1.

#### 🚀 Best Engineering Approach

1. **Evaluate Parity:** Use a `CASE` statement to inspect whether `id % 2 = 1` or `id % 2 = 0`.
2. **Handle Edge Cases (Max ID):** For odd IDs, check if `id < (SELECT MAX(id) FROM Seat)` to ensure we do not increment an odd ID past the boundary into a non-existent seat.
3. **Order and Return:** Sort the transformed result set by the newly computed ID sequence.

#### ✅ Correct Code

```sql
SELECT 
    CASE 
        WHEN id % 2 = 1 AND id < (SELECT MAX(id) FROM Seat) THEN id + 1
        WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM Seat) THEN id
        ELSE id - 1
    END AS id, 
    student
FROM Seat
ORDER BY id ASC;

```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`WHEN id % 2 = 1 AND id < (SELECT MAX(id) FROM Seat) THEN id + 1`**: Shifts odd IDs up by one position, provided they are not the final row in the sequence.
* **`WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM Seat) THEN id`**: Preserves the final odd ID when the total row count is odd, adhering to business rules.
* **`ELSE id - 1`**: Shifts even IDs down by one position (e.g., seat 2 becomes seat 1).

---

### 3. Department Top Three Salaries (LeetCode 185)

* **Problem Number:** LC 185

* **Problem Pattern:** Partitioned Window Ranking (`DENSE_RANK`) combined with Common Table Expressions (CTEs).
* **Source Context:** Employee and Department tables. The goal is to find employees who earn salaries in the top three unique salaries for each department.

#### 🧠 Core Concept & Intuition

When business rules require finding "top N items *per category*" while handling ties gracefully without skipping rank numbers, standard SQL clauses fall short. Understanding why traditional approaches fail highlights why window functions are necessary:

1. **The Global Limit Failure (`LIMIT 3`):** If you attempt to use a global `LIMIT 3` clause at the end of a standard query, SQL restricts the *entire output* to only three rows total across the entire company. It might pull three employees from the IT department and completely omit Sales, failing the core requirement of a department-by-department breakdown.
2. **The Group-By Trap (`GROUP BY departmentId`):** Standard aggregation collapses multiple rows into a single summary row (such as finding the `MAX(salary)` per department). However, this destroys individual employee identities and names, making it impossible to list the actual people who earned those top salaries.
3. **The Solution - Relative Positioning:** We need a way to evaluate rows *relative to their peers inside the same category* without collapsing the table. This is solved by **Window Functions**.

#### 🔍 Deep-Dive Breakdown of the Window Function Mechanics

Look closely at the ranking engine line:

```sql
DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS drk

```

Every component of this expression performs a specific architectural task:

* **`PARTITION BY e.departmentId` (The Clipboard Splitter):**
This acts like taking the master employee table and dividing it into separate, independent clipboards based on the department ID. Clipboard 1 holds *only* IT personnel; Clipboard 2 holds *only* Sales personnel. All subsequent sorting and ranking operations happen **strictly inside each isolated clipboard**, completely ignoring rows in other departments.


* **`ORDER BY e.salary DESC` (The Intra-Clipboard Sorting):**
On each individual department's clipboard, the database engine sorts the employees from the **highest salary to the lowest salary**. The top earner sits at position 1, and lower earners follow sequentially down the list.


* **`DENSE_RANK() AS drk` (The Rank Assignment Strategy):**
Assigns a numeric position to each employee based on their sorted order on that specific clipboard.



##### Why `DENSE_RANK()` Instead of `RANK()` or `ROW_NUMBER()`?

In enterprise reporting and technical interviews, choosing the correct ranking function is critical:

* **`ROW_NUMBER()`:** Assigns a completely unique sequential number to every row (1, 2, 3, 4...). If two employees share the exact same salary, one arbitrarily gets rank 2 and the other gets rank 3. This violates business equity.
* **`RANK()`:** Gives tied employees the same rank, but **skips subsequent numbers**. If two people tie for rank 1, the next person is automatically jumped to rank 3 (skipping rank 2).
* **`DENSE_RANK()`:** Gives tied employees the same rank, but **does not skip numbers** (1, 1, 2, 3...). If two people tie for rank 1, the next person is rank 2, and the person after them is rank 3. Because the problem requires finding the top three *unique* salary tiers per department (meaning tied earners share a rank without pushing out the next tier), `DENSE_RANK()` is the exact tool required.


#### 🚀 Best Engineering Approach

1. **Modularize via CTEs:** Isolate the ranking logic inside a Common Table Expression (`RankedEmployees`) so the main query remains clean and readable.
2. **Apply Partitioned Windowing:** Compute department-specific salary hierarchies using `DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...)`.
3. **Filter and Join Metadata:** Query the virtual CTE table, filtering for rows where `drk <= 3`, and join back to the Department table to resolve human-readable department names.

#### ✅ Correct Code

```sql
WITH RankedEmployees AS (
    SELECT
        d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS drk
    FROM Employee e
    JOIN Department d ON e.departmentId = d.id
)
SELECT Department, Employee, Salary
FROM RankedEmployees
WHERE drk <= 3;
```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`WITH RankedEmployees AS (...)`**: Creates a temporary, query-scoped virtual table that attaches a calculated rank column (`drk`) to every employee record based on their departmental standing.
* **`PARTITION BY e.departmentId`**: Scopes the ranking window strictly within each individual department ID bucket.
* **`ORDER BY e.salary DESC`**: Orders the partitioned rows from maximum salary to minimum salary.
* **`WHERE drk <= 3`**: Acts as the final filter on the pre-ranked virtual table, extracting only those employees who fall into the top three salary tiers of their respective departments.

---

### 4. LeetCode 1321: Restaurant Growth

* **Problem Number:** LC 1321

* **Problem Pattern:** Sliding Window Frame Aggregation (`ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`) inside Common Table Expressions (CTEs).
* **Source Context:** Customer table tracking customer transactions, individual payment amounts, and visit dates. The objective is to compute a 7-day rolling moving sum and moving average of customer spending (current day plus the preceding 6 days), rounded to two decimal places, ordered chronologically.


#### 🧠 Core Concept & Intuition

When building analytics pipelines that require time-series moving averages or rolling windows, standard grouping or basic joins fall short. Understanding the limitations of traditional approaches highlights why advanced window frames are necessary:

1. **The Self-Join Performance Trap:** An intuitive approach to calculating a 7-day moving window is to perform a self-join where rows match if a date falls within a 6-day trailing window (`b.visited_on BETWEEN a.visited_on - INTERVAL 6 DAY AND a.visited_on`). However, for large datasets, this creates a massive Cartesian product, blowing up query complexity to $O(n^2)$ and causing severe latency bottlenecks.
2. **The Aggregation and Granularity Challenge:** A single day can contain multiple customer transactions. Before any rolling calculation can happen, raw individual rows must be collapsed into single daily financial totals.
3. **The Solution - Physical Window Frames:** SQL window functions allow aggregate functions to operate over a sliding subset of rows *relative to the current row* in $O(n)$ time, completely bypassing the need for heavy self-joins.


#### 🔍 Deep-Dive Breakdown of the Window Frame Mechanics

Look closely at the sliding window expression used in the query:

```sql
SUM(daily_amount) OVER(
    ORDER BY visited_on
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
)

```

Every component of this window specification performs a critical computational role:

* **`ORDER BY visited_on` (The Chronological Timeline):**
Establishes the absolute sequence of rows. The window engine must know what "before" and "after" mean, sorting the aggregated daily totals strictly by calendar date.


* **`ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` (The Sliding Physical Frame):**
This defines the exact physical boundaries of the window. Instead of looking at the entire table, the aggregate function (`SUM` or `AVG`) looks *only* at a moving block consisting of the current row plus the exact 6 rows immediately preceding it. As the engine steps to the next day, the window slides forward by dropping the oldest day and picking up the new day.


#### 🚀 Best Engineering Approach

1. **Aggregate Daily Totals (CTE 1):** Use an initial CTE (`DailyTotals`) to group raw transactions by date, collapsing multiple customer payments into a single consolidated sum per calendar day.


2. **Apply Sliding Windows (CTE 2):** Use a second CTE (`RollingMetrics`) to calculate both the 7-day rolling sum and the 7-day rolling average simultaneously using physical row frames.


3. **Filter Out Warm-Up Days:** Because a 7-day moving average requires a full 6 days of preceding history, the first 6 days of data do not represent complete 7-day windows and must be filtered out using date arithmetic (`INTERVAL 6 DAY`).



#### ✅ Correct Code

```sql
WITH DailyTotals AS (
    SELECT
        visited_on,
        SUM(amount) AS daily_amount
    FROM Customer
    GROUP BY visited_on
),
RollingMetrics AS (
    SELECT
        visited_on,
        SUM(daily_amount) OVER(
            ORDER BY visited_on
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS amount,
        ROUND(
            AVG(daily_amount) OVER(
                ORDER BY visited_on
                ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
            ), 
            2
        ) AS average_amount
    FROM DailyTotals
)
SELECT visited_on, amount, average_amount
FROM RollingMetrics
WHERE visited_on >= (SELECT MIN(visited_on) FROM Customer) + INTERVAL 6 DAY;
```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`WITH DailyTotals AS (...)`**: Collapses granular customer transaction entries into unique daily financial summaries grouped by visit date.
* **`SUM(daily_amount) OVER(...)`**: Computes the rolling cumulative spending amount across the active 7-day physical window frame.
* **`ROUND(..., 2)`**: Formats the final calculated moving average to standard financial two-decimal precision.
* **`WHERE visited_on >= (SELECT MIN(visited_on) FROM Customer) + INTERVAL 6 DAY`**: Acts as the warm-up filter, omitting any rolling calculations prior to the date where a complete 7-day history is available.

---

### 5. Friend Requests II: Who Has the Most Friends (LeetCode 602)

* **Problem Number:** LC 602
* **Problem Pattern:** Bidirectional Graph Degree Aggregation via `UNION ALL` and Global Grouping.
* **Source Context:** RequestAccepted table tracking friendship connections (`requester_id`, `accepter_id`). The objective is to find the user ID with the highest total number of friends across both columns.

#### 🧠 Core Concept & Intuition

In social network schemas, an entity can appear in multiple columns depending on who initiated the request. To find total connections (graph degree), you must combine IDs from both columns into a single unified column stream using `UNION ALL` before grouping and counting.

#### 🚀 Best Engineering Approach

1. **Unify Relationship Streams:** Stack `requester_id` and `accepter_id` into a single column using `UNION ALL`.
2. **Group and Count:** Group by user ID and count total occurrences.
3. **Sort and Limit:** Order by total count descending and extract the top record (`LIMIT 1`).

#### ✅ Correct Code

```sql
WITH AllFriends AS (
    SELECT requester_id AS id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id AS id FROM RequestAccepted
)
SELECT id, COUNT(*) AS num
FROM AllFriends
GROUP BY id
ORDER BY num DESC
LIMIT 1;

```

#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`UNION ALL`**: Preserves all duplicate entries (which are vital here, as every appearance represents a distinct friendship link) without overhead duplicate filtering.
* **`GROUP BY id`**: Consolidates all friendship instances per individual user.

---

### 6. Movie Rating (LeetCode 1341)

* **Problem Number:** LC 1341


* **Problem Pattern:** Multi-Query Analytics with Deterministic Lexical Tie-Breaking and Union Streaming.
* **Source Context:** Movies, Users, and MovieRating tables. The objective requires solving two distinct, independent analytical queries-finding the user who rated the greatest number of movies and finding the movie with the highest average rating in February 2020-and combining their text results into a single unified column named `results`.


#### 🧠 Core Concept & Intuition

When business reporting requirements demand two completely different analytical calculations combined into a single output column, standard joins or single-pass queries fall short. Understanding why naive approaches fail highlights the need for partitioned sub-queries combined with `UNION`:

1. **The Multi-Metric Scope Challenge:** The first part of the problem evaluates user activity (counting ratings per user), while the second part evaluates temporal performance (calculating average movie ratings restricted to a specific month: February 2020). Attempting to compute both dimensions in a single unified `SELECT` statement causes messy cross-joins, bloated table states, and corrupted aggregate counts.


2. **The Non-Deterministic Tie-Breaking Trap:** The problem states that if multiple entities share the top metric (e.g., two users tying for the same number of ratings, or two movies sharing an identical average rating), the system must return the **lexicographically smaller name**. Failing to include a secondary sorting key results in non-deterministic query behavior, where databases might return random winners on ties.


3. **The Solution - Modular Parenthesized Sub-Queries:** By wrapping each independent query in parentheses and merging them with `UNION ALL`, you establish clean architectural separation. Each query executes its own filtering, aggregation, tie-breaking, and limiting independently before stacking results into the final output column.


#### 🔍 Deep-Dive Breakdown of the Query Mechanics

Look closely at the dual-query architecture:

```sql
(
    SELECT a.name AS results
    FROM Users a
    JOIN MovieRating b ON a.user_id = b.user_id
    GROUP BY a.user_id, a.name
    ORDER BY COUNT(b.movie_id) DESC, a.name ASC
    LIMIT 1
)
UNION ALL
(
    SELECT a.title AS results
    FROM Movies a
    JOIN MovieRating b ON a.movie_id = b.movie_id
    WHERE b.created_at BETWEEN '2020-02-01' AND '2020-02-29'
    GROUP BY a.movie_id, a.title
    ORDER BY AVG(b.rating) DESC, a.title ASC
    LIMIT 1
);

```

Every clause in this block plays a precise role:

* **Parentheses `(...)` around each query:** In standard SQL, applying a global `LIMIT` or `ORDER BY` across a combined `UNION` set can cause syntax errors or unintended sorting behavior. Wrapping each individual query in parentheses isolates its `ORDER BY` and `LIMIT` clauses locally, ensuring each sub-block successfully extracts its own top-1 record.
* **`GROUP BY a.user_id, a.name` (The Granularity Rule):** Grouping by both the unique ID and the name satisfies strict SQL aggregate rules, ensuring that users with identical names do not accidentally collapse into a single row.
* **`ORDER BY COUNT(b.movie_id) DESC, a.name ASC` (Deterministic Tie-Breaking):**
* The primary sort (`DESC`) ranks the highest engagement at the top.


* The secondary sort (`ASC`) looks at the text name (`a.name ASC`). If two users tie with 3 ratings each, the database sorts them alphabetically and picks the lexicographically smaller name, satisfying the business constraint deterministically.


* **`WHERE b.created_at BETWEEN '2020-02-01' AND '2020-02-29'` (Temporal Bounding):** Isolates ratings specifically to February 2020, ignoring historical noise and future records.


#### 🚀 Best Engineering Approach

1. **Modularize the User Query:** Build the first query to join Users and MovieRating, group by user, sort by total rating count descending and name ascending, and limit to 1.


2. **Modularize the Movie Query:** Build the second query to join Movies and MovieRating, filter by the February 2020 date range, group by movie, sort by average rating descending and title ascending, and limit to 1.


3. **Stack via Union:** Combine both parenthesized queries using `UNION ALL` to output a clean, two-row report under the uniform column header `results`.


#### 📝 Detailed Explanation of Code & Logic, Clauses & Clauses Breakdown

* **`UNION ALL`**: Appends the single-row user result directly above the single-row movie result, creating a unified, vertical 2-row result set.
* **`ORDER BY ... DESC, name ASC`**: Implements multi-level sorting, ensuring primary metrics take priority while secondary alphabetical fields resolve ties consistently.
* **`LIMIT 1`**: Restricts each isolated sub-query to output strictly one top-performing entity.
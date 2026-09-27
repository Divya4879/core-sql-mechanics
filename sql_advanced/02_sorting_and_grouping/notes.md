# Section 2: Sorting and Grouping - Master Guide & Architectural Patterns

---

## 🧠 Masterclass Deep Dive: The SQL Order of Execution

Before diving into grouping and sorting problems, you must master *how* a database engine processes your queries. Students often fail because they treat SQL like procedural code (top-to-bottom).

The actual logical order of execution inside a database engine is:

1. **`FROM` / `JOIN**`: Tables are gathered and joined.
2. **`WHERE`**: Individual raw rows are filtered.
3. **`GROUP BY`**: Rows are clustered into summary buckets.
4. **`HAVING`**: Aggregated buckets/groups are filtered.
5. **`SELECT`**: Expressions, columns, and aliases are computed.
6. **`DISTINCT`**: Duplicate rows are stripped.
7. **`ORDER BY`**: Results are sorted.
8. **`LIMIT` / `OFFSET**`: Windowing/pagination is applied.

**Why this matters for Backend Engineers:** You cannot reference an alias created in the `SELECT` clause inside a `WHERE` clause, because `WHERE` executes *before* `SELECT`. Similarly, aggregate functions (`COUNT`, `SUM`) cannot live in `WHERE` because aggregation happens *after* row-level filtering.

---

## Problem-by-Problem Breakdown

---

### 1. LeetCode 619: Biggest Single Number

* **Problem Pattern:** Frequency Filtering with Aggregate Null-Handling.
* **Source Context:** MyNumbers table containing integer values that may include duplicates, where the goal is to find the largest number appearing exactly once, returning `NULL` if none exist.

#### 🧠 Core Concept & Intuition

To find a "single" number, you must count how many times each number appears in the dataset. Once you isolate numbers with a frequency of 1, you find the maximum value among them. The key architectural magic here is understanding how SQL handles **empty aggregate result sets**.

#### ❌ Student Pitfalls & Wrong Code

Students often struggle with the edge case where *no* single numbers exist. A common wrong approach is trying to use a `WHERE` clause directly with an aggregate function:

```sql
-- WRONG: Trying to filter with WHERE directly on an aggregate count
SELECT MAX(num) 
FROM MyNumbers 
WHERE COUNT(num) = 1; -- Error: Invalid use of group function in WHERE!

```

#### 🚀 Best Engineering Approach

1. **Isolate Frequencies via CTE:** Use a Common Table Expression (CTE) to group numbers and filter using `HAVING COUNT(num) = 1`.
2. **Leverage Native Aggregate Nullity:** If every number appears twice or more, the CTE returns zero rows (an empty table). When you run an aggregate function like `MAX()` on an empty set, SQL naturally evaluates it to `NULL` without crashing or requiring manual `IF/ELSE` checks.

#### ✅ Correct Code

```sql
WITH temp_nums AS (
    SELECT num
    FROM MyNumbers
    GROUP BY num
    HAVING COUNT(num) = 1
)
SELECT MAX(num) AS num
FROM temp_nums;

```

#### 📝 Detailed Explanation

The CTE groups identical numbers together and counts their occurrences. The `HAVING` clause strips away any number that appears more than once. Finally, the outer query applies `MAX(num)` to the remaining single numbers. If the table contains zero single numbers, `MAX()` executes on an empty table and natively outputs `NULL`, satisfying the problem requirement cleanly.

---

### 2. LeetCode 1070: Product Sales Analysis III

* **Problem Pattern:** Multi-Column Tuple Comparison / First-Occurrence Grouping.
* **Source Context:** Sales table tracking product sales across years, where the goal is to find the first year, quantity, and price for every product's initial sale.

#### 🧠 Core Concept & Intuition

When a product has multiple sales across different years, you need to isolate its chronological starting point. Because a product can even have multiple transactions *within* that exact same starting year, you must match both the product ID and the earliest year simultaneously.

#### ❌ Student Pitfalls & Wrong Code

Students often try a simple single-column join or `IN` clause (e.g., `WHERE product_id IN (...)`), which accidentally fetches *all* years for that product instead of locking onto just the first year, or they miss secondary sales rows that happened in that same starting year.

#### 🚀 Best Engineering Approach

Use **Tuple Comparison (Multi-Column In-Clause)**. By grouping by `product_id` and selecting `MIN(year)` inside a subquery, you can compare paired columns `(product_id, year)` directly against the main table. This guarantees you fetch all attributes (quantity and price) tied specifically to the product's debut year.

#### ✅ Correct Code

```sql
SELECT product_id, year AS first_year, quantity, price
FROM Sales
WHERE (product_id, year) IN (
    SELECT product_id, MIN(year)
    FROM Sales
    GROUP BY product_id
);

```

#### 📝 Detailed Explanation

The inner subquery evaluates every product and calculates its minimum (earliest) sales year. The outer query uses tuple matching `WHERE (product_id, year) IN (...)` to scan the main table and pull every row matching those exact composite keys. This correctly captures all sales entries if a product had multiple transactions during its launch year.

---

### 3. LeetCode 596: Classes With at Least 5 Students

* **Problem Pattern:** Group Aggregation Threshold Filtering (`GROUP BY` + `HAVING`).
* **Source Context:** Courses table containing student and class enrollments, where the goal is to find all classes with at least five students enrolled.

#### 🧠 Core Concept & Intuition

Applying the SQL Order of Execution: **`WHERE` filters raw rows *before* grouping, while `HAVING` filters aggregated groups *after* grouping.** To find classes with minimum size thresholds, you must cluster student rows by class name and evaluate their counts collectively.

#### ❌ Student Pitfalls & Wrong Code

Students frequently try to use `WHERE` with aggregate functions, which results in a syntax compilation error because aggregate evaluations do not exist yet when the `WHERE` clause runs:

```sql
-- WRONG: Trying to filter aggregated counts using WHERE
SELECT class
FROM Courses
WHERE COUNT(student) >= 5
GROUP BY class; -- Error: Invalid use of aggregate function in WHERE!

```

#### 🚀 Best Engineering Approach

1. Cluster data into buckets using `GROUP BY class`.
2. Calculate the size of each bucket using `COUNT(student)`.
3. Filter out classes below the threshold using the `HAVING` clause. Wrapping this in a CTE keeps the query modular and readable for backend codebases.

#### ✅ Correct Code

```sql
WITH tmp_table AS (
    SELECT COUNT(student) AS cnt, class
    FROM Courses
    GROUP BY class
    HAVING cnt >= 5
)
SELECT class
FROM tmp_table;

```

#### 📝 Detailed Explanation

The database engine reads the `Courses` table, clusters individual student rows by their respective `class` names (`GROUP BY class`), and counts how many student entries exist in each cluster (`COUNT(student) AS cnt`). The `HAVING` clause then inspects those calculated totals and discards any class with fewer than 5 students, leaving only the qualifying classes to be selected.
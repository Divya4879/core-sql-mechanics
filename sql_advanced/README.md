# SQL Advanced

A problem-driven SQL practice and revision module built around query patterns that require more than basic filtering, joins, and aggregation.

This section was developed primarily from solving SQL50 problems and revisiting problems where the query logic was difficult to understand, easy to get wrong, or required combining several SQL mechanics at once.

It is **not intended to be a complete reference to advanced SQL**. Instead, it focuses on a selected set of recurring patterns that became useful to understand through practice.

---

## 📖 Purpose

The `sql_advanced` section sits after the foundational and intermediate SQL material in this repository.

The emphasis here is less on introducing SQL syntax from scratch and more on understanding **how individual SQL mechanics combine to solve non-trivial problems**.

The problems in this section cover patterns such as:

* choosing the correct join structure
* preserving rows that have no matching records
* generating complete combinations before joining actual data
* grouping and filtering aggregated results
* understanding SQL's logical order of execution
* comparing multiple columns as a pair
* manipulating and validating strings
* using regular expressions for structured filtering
* deleting duplicate rows safely
* handling first and second occurrences
* using conditional aggregation
* working with dates and date intervals
* resolving historical states at a particular date
* using window functions for ranking and running calculations
* building rolling time windows
* combining independent query results with set operations
* handling ties and deterministic ordering
* composing several query stages with subqueries and CTEs

The examples are deliberately centered around concrete problems rather than isolated syntax demonstrations.

---

# 📂 Module Structure

```text
sql_advanced/

├── 01_basic_joins/
│   └── notes.md
│
├── 02_sorting_and_grouping/
│   └── notes.md
│
├── 03_advanced_strings_and_regex/
│   └── notes.md
│
├── 04_advanced_select_and_joins/
│   └── notes.md
│
├── 05_basic_aggregate_functions/
│   └── notes.md
│
└── 06_subqueries/
    └── notes.md
```

Each module currently contains a `notes.md` file with explanations, common mistakes, query patterns, and worked solutions.

---

# 1. Basic Joins (`01_basic_joins`)

This module focuses on join problems where choosing the correct relational structure is more important than simply knowing join syntax.

### Concepts and patterns covered

* `CROSS JOIN`
* Cartesian products
* `INNER JOIN`
* `LEFT JOIN`
* Self-joins
* Joining different rows from the same table
* Preserving rows with no matching records
* Conditional aggregation after joins
* Joining on multiple columns
* Date-based joins
* Hierarchical self-referencing relationships
* `GROUP BY` and `HAVING` after joins
* Using subqueries with joined data

### Problems included

* **LeetCode 1661 - Average Time of Process per Machine**

  * Self-joining start and end records
  * Matching rows using multiple keys
  * Calculating elapsed time

* **LeetCode 1934 - Confirmation Rate**

  * `LEFT JOIN`
  * Preserving users with no confirmation records
  * Conditional aggregation
  * Percentage calculation

* **LeetCode 197 - Rising Temperature**

  * Self-joining rows from different dates
  * Comparing consecutive calendar dates
  * Date arithmetic

* **LeetCode 1280 - Students and Examinations**

  * `CROSS JOIN` for complete student-subject combinations
  * `LEFT JOIN` for sparse examination records
  * Preserving zero-count combinations

* **LeetCode 570 - Managers with at Least 5 Direct Reports**

  * Self-referencing relationships
  * Grouping by manager
  * `HAVING`
  * Subquery-based lookup

### Main idea

A recurring theme in this module is that the desired output may contain rows that **do not exist directly in the source data**.

For example, a report may need to show every student-subject combination even when no examination record exists. In such cases, the query has to construct the required result shape first and then attach the available data.

---

# 2. Sorting and Grouping (`02_sorting_and_grouping`)

This module focuses on grouping logic, aggregate filtering, and the logical order in which SQL evaluates a query.

A central reference in this section is the logical SQL execution order:

```text
FROM / JOIN
    ↓
WHERE
    ↓
GROUP BY
    ↓
HAVING
    ↓
SELECT
    ↓
DISTINCT
    ↓
ORDER BY
    ↓
LIMIT / OFFSET
```

Understanding this order helps explain why certain expressions belong in `WHERE`, while others require `HAVING`, and why some aliases cannot be referenced at earlier stages of a query.

### Concepts and patterns covered

* Logical query execution order
* `GROUP BY`
* `HAVING`
* Aggregate filtering
* Empty aggregate results
* `MAX()` and `NULL`
* Multi-column tuple comparison
* First-occurrence grouping
* `MIN()`
* Sorting and tie handling
* CTE-based query decomposition

### Problems included

* **LeetCode 619 - Biggest Single Number**

  * Frequency counting
  * `GROUP BY`
  * `HAVING`
  * Applying `MAX()` to an empty result
  * Understanding why the result becomes `NULL`

* **LeetCode 1070 - Product Sales Analysis III**

  * Finding the first year for each product
  * `MIN()`
  * Grouping
  * Multi-column tuple comparison

* **LeetCode 596 - Classes With at Least 5 Students**

  * Group-level filtering
  * `GROUP BY`
  * `HAVING`
  * Understanding the difference between row-level and group-level filtering

### Main idea

The focus here is not simply memorizing `GROUP BY` syntax. The problems are used to understand **when aggregation happens, what the grouped result represents, and where filtering must occur**.

---

# 3. Advanced Strings and Regex (`03_advanced_strings_and_regex`)

This module covers SQL problems where the main difficulty comes from transforming, validating, aggregating, or deduplicating string data.

### Concepts and patterns covered

* `LEFT()`
* `SUBSTRING()`
* `UPPER()`
* `LOWER()`
* `CONCAT()`
* Regular expressions
* `REGEXP_LIKE`
* String aggregation
* `GROUP_CONCAT`
* `DISTINCT` inside aggregation
* Ordered string aggregation
* Self-join based deletion
* Duplicate detection
* Scalar subqueries
* Handling missing second-highest values

### Problems included

* **LeetCode 1667 - Fix Names in a Table**

  * Splitting a string into first character and remainder
  * Case normalization
  * String concatenation

* **LeetCode 1517 - Find Users With Valid E-Mails**

  * Regular expression validation
  * Pattern-based filtering
  * Combining multiple string constraints

* **LeetCode 1484 - Group Sold Products By The Date**

  * `GROUP_CONCAT`
  * `DISTINCT`
  * Alphabetical ordering inside string aggregation
  * Grouping records by date

* **LeetCode 196 - Delete Duplicate Emails**

  * Detecting duplicate values
  * Self-joins
  * Deleting duplicates while retaining the row with the smallest ID

* **LeetCode 176 - Second Highest Salary**

  * Finding the second distinct maximum
  * Scalar subqueries
  * `DISTINCT`
  * `LIMIT` / offset-based selection
  * Returning `NULL` when a second salary does not exist

### Main idea

These problems show that SQL is not limited to selecting and aggregating numeric data. String transformation, validation, normalization, and duplicate handling can also be expressed directly at the database-query layer.

---

# 4. Advanced Select and Joins (`04_advanced_select_and_joins`)

This module introduces more analytical query patterns, particularly window functions and queries where the output depends on the state of multiple rows.

### Concepts and patterns covered

* Window functions
* Running totals
* `SUM() OVER`
* `PARTITION BY`
* `RANK()`
* Conditional categorization with `CASE`
* `UNION ALL`
* Preserving zero-count categories
* Historical state resolution
* Date-based filtering
* Combining ranked results with fallback values

### Problems included

* **LeetCode 1204 - Last Person to Fit in the Bus**

  * Running cumulative totals
  * Windowed `SUM()`
  * Ordering rows by turn
  * Finding the last row satisfying a cumulative constraint

* **LeetCode 1907 - Count Salary Categories**

  * `CASE`
  * Categorizing rows into fixed ranges
  * Conditional counting
  * `UNION ALL`
  * Preserving categories whose count is zero

* **LeetCode 1164 - Product Price at a Given Date**

  * Historical price records
  * Finding the latest applicable change
  * `PARTITION BY`
  * `RANK()`
  * Combining calculated results with default values using `UNION`

### Main idea

The problems here move beyond treating each row independently.

For example, a running total requires information from **previous rows**, while historical price resolution requires determining which record represents the applicable state at a particular point in time.

---

# 5. Basic Aggregate Functions (`05_basic_aggregate_functions`)

Despite the directory name, this module focuses on aggregation patterns that become more involved when combined with dates, conditions, joins, and first-occurrence logic.

### Concepts and patterns covered

* `COUNT()`
* `SUM()`
* `AVG()`
* Conditional aggregation
* `CASE`
* Grouping by month
* Date truncation / date extraction
* Date comparisons
* First-record filtering
* Percentage calculations
* Floating-point division
* Self-joins
* Date arithmetic
* Interval-based joins
* `COALESCE`
* Null-safe aggregation

### Problems included

* **LeetCode 1193 - Monthly Transactions I**

  * Conditional aggregation
  * Monthly grouping
  * Country-wise metrics
  * Counting approved transactions separately
  * Summing total and approved transaction amounts

* **LeetCode 1174 - Immediate Food Delivery II**

  * Identifying each customer's first order
  * Filtering to first occurrences
  * Conditional percentage calculation
  * Floating-point scaling

* **LeetCode 550 - Game Play Analysis IV**

  * Identifying each player's first login
  * Comparing it with the following calendar day
  * Self-joins
  * Date arithmetic
  * Retention-style percentage calculation

* **LeetCode 1251 - Average Selling Price**

  * Joining sales to the price period that was active on the purchase date
  * Date interval conditions
  * Weighted average calculation
  * Handling products with no recorded sales

### Main idea

The aggregation functions themselves are straightforward. The harder part is usually **deciding which rows should participate in the aggregation**.

These problems therefore combine aggregation with filtering, temporal conditions, first-occurrence logic, and missing-data handling.

---

# 6. Subqueries (`06_subqueries`)

This is the largest problem set in the `sql_advanced` module.

It focuses on combining subqueries, CTEs, window functions, set operations, conditional expressions, and multi-stage analytical logic.

### Concepts and patterns covered

* Scalar subqueries
* Multi-row subqueries
* Composite tuple filtering
* `GROUP BY` + `HAVING` inside subqueries
* `CASE`
* `UNION`
* `UNION ALL`
* CTEs
* Window functions
* `DENSE_RANK()`
* `PARTITION BY`
* Sliding window frames
* Running and rolling calculations
* Graph-style aggregation
* Deterministic tie-breaking
* Multiple independent analytical queries

### Problems included

* **LeetCode 585 - Investments in 2016**

  * Composite conditions
  * Repeated investment values
  * Unique geographic locations
  * Tuple comparison
  * `GROUP BY`
  * `HAVING`
  * Subquery-based filtering

* **LeetCode 626 - Exchange Seats**

  * `CASE`
  * Even/odd ID logic
  * Scalar subqueries
  * Handling the final row when the number of records is odd

* **LeetCode 185 - Department Top Three Salaries**

  * `DENSE_RANK()`
  * `PARTITION BY`
  * Ranking within groups
  * CTEs
  * Handling tied salary values

* **LeetCode 1321 - Restaurant Growth**

  * Pre-aggregation with a CTE
  * Rolling seven-day calculations
  * Window frames
  * `ROWS BETWEEN`
  * Moving `SUM()`
  * Moving `AVG()`
  * Filtering out incomplete initial windows

* **LeetCode 602 - Friend Requests II: Who Has the Most Friends**

  * `UNION ALL`
  * Combining IDs appearing in different columns
  * Counting graph connections
  * Grouping and ordering

* **LeetCode 1341 - Movie Rating**

  * Independent analytical queries
  * User-level aggregation
  * Movie-level aggregation
  * Date filtering
  * Average ratings
  * Deterministic lexical tie-breaking
  * Combining results with `UNION ALL`

### Main idea

The purpose of this module is to make multi-stage SQL queries easier to reason about.

A complex query does not necessarily require a single complicated `SELECT`. Often, the clearer approach is to break the problem into stages:

```text
raw data
   ↓
filter / transform
   ↓
aggregate
   ↓
rank / compare
   ↓
filter the calculated result
   ↓
produce final output
```

CTEs and subqueries make these stages explicit.

---

# 🧠 Recurring Problem-Solving Patterns

Across the six modules, several patterns appear repeatedly.

### 1. Preserve the required rows first

When the final result must include entities with no matching records, an `INNER JOIN` may remove information that the problem expects to retain.

Typical tools:

* `LEFT JOIN`
* `CROSS JOIN`
* conditional counting

---

### 2. Filter rows and filter groups differently

`WHERE` works on individual rows before grouping.

`HAVING` works on groups after aggregation.

This distinction appears repeatedly in problems involving minimum counts, frequencies, and grouped thresholds.

---

### 3. Treat multiple columns as one logical condition when necessary

Some problems require matching a combination such as:

```sql
(product_id, year)
```

rather than matching only one column.

Tuple comparisons can express this directly.

---

### 4. Separate first-occurrence logic from later aggregation

Several problems require identifying the first event for each entity before calculating a metric.

Examples include:

* first sale
* first order
* first login
* first applicable state

The general pattern is:

```text
identify first record
        ↓
filter to those records
        ↓
perform the required calculation
```

---

### 5. Use conditional aggregation when several metrics share the same grouping

Instead of running separate queries for related counts or sums, conditions can be incorporated into aggregate expressions.

For example:

```sql
SUM(
    CASE
        WHEN condition THEN 1
        ELSE 0
    END
)
```

This is used in several reporting and percentage problems.

---

### 6. Use window functions when rows must remain visible

`GROUP BY` collapses rows into groups.

Window functions allow calculations such as:

* rankings
* running totals
* rolling averages

while keeping the individual rows available in the result.

---

### 7. Choose the ranking function according to the meaning of a tie

The module specifically uses ranking concepts where tied values matter.

For example:

* `ROW_NUMBER()` gives every row a unique position.
* `RANK()` gives tied rows the same rank but leaves gaps.
* `DENSE_RANK()` gives tied rows the same rank without gaps.

The appropriate function depends on what the problem considers a distinct position.

---

### 8. Make tie-breaking deterministic

If a problem requires a single result when multiple records share the primary metric, a secondary ordering criterion may be necessary.

For example:

```sql
ORDER BY rating DESC, title ASC
```

The first ordering criterion determines the primary metric; the second resolves ties consistently.

---

### 9. Build complete result states before filling in sparse data

Some reporting problems are not simply:

```text
existing records → output
```

They are:

```text
required combinations/categories
            ↓
attach existing records
            ↓
represent missing combinations as zero
```

`CROSS JOIN`, `LEFT JOIN`, and `UNION ALL` are useful for these cases.

---

### 10. Break multi-stage queries into explicit steps

CTEs can make a query easier to reason about when the calculation naturally has several stages.

For example:

```sql
WITH DailyTotals AS (
    ...
),
RollingMetrics AS (
    ...
)
SELECT ...
FROM RollingMetrics;
```

The point is not to use a CTE simply because the query is long. It is useful when separating intermediate results makes the logic clearer.

---

# 📌 What This Module Is

`sql_advanced` is:

* a problem-driven SQL revision section
* based substantially on SQL50 practice
* focused on problems that required additional reasoning during practice
* a collection of reusable query patterns
* a reference for revisiting mistakes and difficult query structures
* an extension of the mechanics covered in the Foundations and Intermediate sections

It is particularly useful for revisiting a problem after solving it and asking:

> **What SQL pattern was actually required here, and why did simpler approaches fail?**

---

# 🔗 Relationship With the Rest of the Repository

The three sections serve different purposes:

```text
SQL Foundations
      ↓
Learn the core mechanics
      ↓
SQL Intermediate
      ↓
Build broader relational and analytical understanding
      ↓
SQL Advanced
      ↓
Apply those mechanics to harder, pattern-driven problems
```

The Advanced section therefore assumes familiarity with concepts introduced earlier in the repository, particularly:

* filtering
* joins
* `NULL` handling
* aggregation
* `GROUP BY`
* `HAVING`
* subqueries
* date operations
* CTEs
* basic window functions

It is intended to reinforce those concepts by putting them together rather than re-teaching them from the beginning.

---

# 📚 Problems Covered

| Module                          | Problems                                         |
| ------------------------------- | ------------------------------------------------ |
| `01_basic_joins`                | LC 1661, LC 1934, LC 197, LC 1280, LC 570        |
| `02_sorting_and_grouping`       | LC 619, LC 1070, LC 596                          |
| `03_advanced_strings_and_regex` | LC 1667, LC 1517, LC 1484, LC 196, LC 176        |
| `04_advanced_select_and_joins`  | LC 1204, LC 1907, LC 1164                        |
| `05_basic_aggregate_functions`  | LC 1193, LC 1174, LC 550, LC 1251                |
| `06_subqueries`                 | LC 585, LC 626, LC 185, LC 1321, LC 602, LC 1341 |

---

# 🧭 How to Use This Section

A useful way to work through these notes is:

1. Read the problem requirement.
2. Try to identify the required result shape before writing SQL.
3. Solve the problem independently.
4. Compare the solution with the pattern described in the notes.
5. Pay particular attention to the **pitfall** and **reasoning** sections.
6. Revisit the problem later without looking at the solution.
7. Try to recognize the same pattern in a different problem.

The goal is not to memorize individual solutions.

The useful outcome is being able to recognize patterns such as:

```text
"Every combination must appear"
        → CROSS JOIN + LEFT JOIN

"Filter after counting"
        → GROUP BY + HAVING

"Find the first record"
        → MIN() / ranking / first-occurrence logic

"Rank within each department"
        → PARTITION BY + ranking function

"Need previous rows"
        → window function / window frame

"Same relationship appears in two columns"
        → UNION ALL before aggregation

"Two independent answers in one result"
        → separate queries + UNION
```

That pattern recognition is the main purpose of this module.

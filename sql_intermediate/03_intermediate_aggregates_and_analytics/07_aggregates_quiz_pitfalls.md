# 📊 SQL Aggregates & Analytics: Common Quiz Pitfalls & Conceptual Rules

Welcome to the conceptual review notes for aggregate functions and logical query execution order. These sections target the most frequent traps encountered in intermediate SQL assessments.

---

## 🔢 Section 1: Aggregate Functions vs. Scalar Functions

### 1. Core Aggregate Functions

* **Concept:** Aggregate functions evaluate multiple rows of data and condense them into a **single scalar summary value**.

* **The Core Set:** `AVG()`, `COUNT()`, `MAX()`, `MIN()`, and `SUM()`.

* **Problem Patterns / Distinctions:**

* Students often confuse aggregates with **scalar functions** (like `CONCAT()` for strings or `ROUND()` for math formatting). Scalar functions operate row-by-row and do not summarize sets of data.

* Functions like `FIRST()` and `LAST()` are not universal ANSI standard core aggregates across all relational engines (often requiring window functions or explicit sorting instead).


* **Memory Anchor ("The Big Five"):** Think of core aggregates as your basic dashboard summary metrics (**Count, Sum, Average, Min, Max**). If it doesn't reduce a whole column into one summary number, it is not a core aggregate.

---

## ⚙️ Section 2: Logical Execution Order & Filtering Traps (`WHERE` vs `HAVING`)

### 1. The Execution Sequence Rule

A database engine does not execute a SQL query in the order you type it. It follows a strict **Logical Execution Order**:

1. `FROM` (Locates and joins tables)
2. `WHERE` (Filters raw individual rows)
3. `GROUP BY` (Collapses rows into summary groups)
4. `HAVING` (Filters the grouped summary results)
5. `SELECT` (Pulls final columns)
6. `ORDER BY` / `LIMIT` (Sorts and caps output)



### 2. The `WHERE` Aggregate Trap (Anti-Pattern)

* **The Error:** Trying to use an aggregate function inside a `WHERE` clause (e.g., `WHERE SUM(area) > 15000000`).

* **Why It Fails:** When the database evaluates the `WHERE` clause, **the groups have not been 
formed yet**, and `SUM()` has not been calculated. This results in an invalid use/syntax error.

* **The Correct Alternative:** Use **`HAVING`** *after* the `GROUP BY` clause because summary evaluations can only happen after groups are built.

* **Correct Code Example:**

```sql
-- CORRECT: Filtering groups using HAVING after grouping
SELECT region, SUM(area)   
FROM bbc   
GROUP BY region 
HAVING SUM(area) > 15000000;

```


**Memory Anchor:**

* **`WHERE`** filters **raw rows** *before* grouping.
* **`HAVING`** filters **summary groups** *after* grouping.
* *Rule of thumb:* Never let an aggregate function (`SUM`, `COUNT`, etc.) live inside a `WHERE` clause!
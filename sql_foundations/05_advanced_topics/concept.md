# Advanced Queries: Subqueries and Set Operations

When a single query isn't enough to answer complex questions about your data, SQL provides advanced mechanisms to nest queries within each other or combine multiple independent result sets together.

## 1. Subqueries (Nested Queries)

A subquery is a query nested inside another outer query. It allows you to perform pre-processing or post-processing on the fly, feeding the results of the inner query directly into the outer query without needing to execute them separately.

**Placement:** Subqueries can be used almost anywhere a normal table or value is referenced.
    *   In a `WHERE` or `HAVING` clause to test expressions against dynamic aggregate values.
    *   In a `FROM` clause (acting as a temporary table that you can `JOIN`).
    *   In a `SELECT` clause to return data directly.

**Execution Order:** They are generally executed in the same logical order as the part of the outer query they appear in.

**Syntax Rules:** Because they are nested, **every subquery must be fully enclosed in parentheses `()`** to establish the proper execution hierarchy.

**Limitations:** While subqueries can reference any tables in the database, some SQL implementations do not allow the use of `LIMIT` or `OFFSET` inside the inner subquery.

---

## 2. Correlated Subqueries

A standard subquery executes independently, calculates a result, and passes it to the outer query once. A **correlated subquery**, however, is dependent on the outer query. 

* The inner query explicitly references a column or alias from the outer query. 
* Because the inner query depends on the current row being evaluated by the outer query, the inner query must be re-run for *every single row* of the outer query.

**Caveats:** 
    *   **Readability:** These queries can become highly complex. Always use meaningful aliases for tables and temporary values to maintain readability.
    *   **Performance:** Because they execute on a per-row basis rather than resolving once, they can be difficult for the database engine to optimize. Performance characteristics can vary wildly depending on the specific database system you are using.

---

## 3. Existence Tests (`IN` / `NOT IN`)

While standard `WHERE` constraints can use the `IN` operator to check if a value exists within a fixed, hardcoded list (e.g., `IN (1, 2, 3)`), subqueries allow you to test against a **dynamic list** derived from current data.

```sql
SELECT *, …
FROM mytable
WHERE column IN/NOT IN 
    (SELECT another_column
     FROM another_table);

```

**Requirement:** The inner subquery must strictly select a single column or expression. This ensures it produces a one-dimensional list that the outer query's column can accurately test against.

**Use Case:** Exceptionally powerful for cross-referencing tables where the criteria are constantly changing based on live data.

---

## 4. Set Operations (`UNION`, `INTERSECT`, `EXCEPT`)

While `JOIN`s combine tables horizontally (adding columns side-by-side), set operators combine the results of two completely separate queries vertically (stacking rows on top of each other).

```sql
SELECT column, another_column
FROM mytable

UNION / UNION ALL / INTERSECT / EXCEPT

SELECT other_column, yet_another_column
FROM another_table
ORDER BY column DESC
LIMIT n;

```

### Strict Requirements for Set Operations

To successfully combine two queries, both result sets must have:

1. The exact same **number** of columns.
2. The exact same **order** of columns.
3. Matching (or highly compatible) **data types** for those respective columns.

### The Operators

* **`UNION`:** Appends the results of the second query to the first. It automatically evaluates the entire combined set and **removes all duplicate rows**.
* **`UNION ALL`:** Appends the results, but **retains duplicates**. It is much faster than standard `UNION` because the database skips the deduplication step.
* **`INTERSECT`:** Compares the two result sets and returns *only* the identical rows that exist in **both** sets (discarding duplicates).
* **`EXCEPT`:** Compares the sets and returns only the rows found in the **first** result set that are **not** present in the second result set.

*Note on Order:* Because `EXCEPT` subtracts the bottom query from the top query, it is **query order-sensitive** (just like `LEFT JOIN` vs `RIGHT JOIN`).



### Execution Order & Duplicates

In the standard SQL order of operations, set operations (like `UNION`) happen *before* the outer `ORDER BY` and `LIMIT` clauses are applied.

While `INTERSECT` and `EXCEPT` discard duplicate rows by default, some database engines support `INTERSECT ALL` and `EXCEPT ALL`, which allow duplicates to be retained in the final output.

```
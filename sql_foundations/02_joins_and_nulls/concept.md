# Relational Data Mapping: Joins and NULL Handling

## 1. Database Normalization and Multi-Table Queries

In real-world relational systems, entity data is broken down and distributed across multiple orthogonal tables to minimize data redundancy and allow independent schema growth (e.g., car engine types can scale independently of car models).

* **Trade-offs:** While normalization prevents duplicate data state across tables, it introduces query complexity and increases I/O overhead because relational engines must reassemble the data at runtime.

* **Primary Keys:** Tables are linked using a unique identifier known as a primary key. This is commonly an auto-incrementing integer (chosen for space-efficiency), but it can also be a string or hashed value, provided it uniquely identifies the entity row.

---

## 2. Inner Joins (`INNER JOIN` / `JOIN`)

An `INNER JOIN` (which can also be written simply as `JOIN`) evaluates two tables side-by-side and matches rows that share the same key as defined by the `ON` constraint. Unmatched rows are dropped entirely from the result set.

* **Execution Order:** Once the tables are joined and the virtual combined result table is created, any subsequent clauses (`WHERE`, `ORDER BY`, `LIMIT`) are then applied.

* **Syntax:**

```sql
SELECT column_name, another_table_column, ...
FROM mytable
INNER JOIN another_table 
    ON mytable.id = another_table.id
WHERE condition(s)
ORDER BY column, ... ASC/DESC
LIMIT num_limit OFFSET num_offset;

```


* **Performance Note:** Always ensure columns in the `ON` clause are indexed to prevent expensive full-table scans.

---

## 3. Outer Joins (`LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`)

When tables contain asymmetric data due to records being entered at different stages, an `INNER JOIN` will drop unmatched rows. Outer joins resolve this by preserving data from one or both sides.

* **`LEFT JOIN`:** Preserves all rows from the left table, regardless of whether a matching row is found in the right table. Missing matches are filled with `NULL`.

* **`RIGHT JOIN`:** Preserves all rows from the right table, regardless of a match in the left table.

* **`FULL JOIN`:** Preserves all rows from both tables, filling missing gaps with `NULL` on either side.

* **Compatibility Note:** You may see these written as `LEFT OUTER JOIN`, `RIGHT OUTER JOIN`, or `FULL OUTER JOIN`. The `OUTER` keyword is optional and kept strictly for SQL-92 standard compatibility; they are entirely equivalent.

* **Syntax:**

```sql
SELECT column_name, another_column, ...
FROM mytable
LEFT JOIN another_table 
    ON mytable.id = another_table.matching_id

-- Or with explicit/optional OUTER keyword (SQL-92 compatibility)
SELECT column_name, another_column, ...
FROM mytable
LEFT OUTER JOIN another_table 
    ON mytable.id = another_table.matching_id

SELECT column_name, another_column, ...
FROM mytable
RIGHT JOIN another_table 
    ON mytable.id = another_table.matching_id

SELECT column_name, another_column, ...
FROM mytable
FULL JOIN another_table 
    ON mytable.id = another_table.matching_id

```



---

## 4. Managing `NULL` Values

A `NULL` represents the absence of data. While outer joins naturally introduce `NULL`s via asymmetric matching, database designers generally try to minimize unnecessary `NULL`s because they require special query handling.

* **Alternatives vs. Skewed Data:** While you can use data-type appropriate defaults (like `0` for numbers or empty strings for text), storing a true `NULL` is appropriate when a default value would corrupt downstream analytics (for example, factoring a default `0` into an average salary calculation would skew the mean).

* **Querying for `NULL`:** Because `NULL` is a state of non-value, standard operators like `= NULL` fail. You must explicitly test using `IS NULL` or `IS NOT NULL`.

* **Syntax:**

```sql
SELECT column, another_column, ...
FROM mytable
WHERE column IS NULL 
   OR column IS NOT NULL
   AND/OR another_condition;

```
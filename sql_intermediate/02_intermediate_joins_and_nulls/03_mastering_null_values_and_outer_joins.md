# Architectural Guide: Mastering NULL Values, Outer Joins, and Conditional Logic

In relational databases, missing or unassigned data is represented by **`NULL`**. Handling `NULL` values requires specialized operators, outer join configurations, scalar substitution functions, and conditional evaluation patterns to prevent silent data loss and maintain query accuracy.

---

## Part 1: The Semantics of `NULL` and Why `=` Fails

### Core Concept

`NULL` is not a data value like zero or an empty string (`''`); it represents a complete **absence of data** or an unknown state. Because its value is unknown, standard comparison operators (`=`, `!=`, `<`, `>`) cannot evaluate it. Comparing anything to `NULL` using an equals sign results in an unknown logical state rather than true or false.

### Syntax Rule: `IS NULL` vs. `=`

* **The Trap:** Writing `dept = NULL` or `dept != NULL` will always return an empty result set because an unknown value cannot be equated.


* **The Solution:** Use the explicit unary operators **`IS NULL`** and **`IS NOT NULL`** to evaluate missing records.



```sql
-- Correct: Finds teachers who have no assigned department reference
SELECT teacher.name
FROM teacher
WHERE teacher.dept IS NULL;

---

## Part 2: Join Variations (`INNER`, `LEFT`, and `RIGHT`)

Standard `INNER JOIN` operations evaluate intersections, dropping any rows that lack a mutual match in both tables—such as teachers assigned to no department, or departments with zero teachers. To retain unmatched records, use **Outer Joins**.

### 1. `INNER JOIN`
Excludes unmatched rows entirely. In school database schemas, an `INNER JOIN` between `teacher` and `dept` misses teachers with no department and departments with no teacher.

```sql
SELECT teacher.name, dept.name
FROM teacher INNER JOIN dept
  ON teacher.dept = dept.id;

### 2. `LEFT JOIN`
A `LEFT JOIN` preserves every row from the primary (left) table (`teacher`), regardless of whether a matching foreign key exists in the secondary (right) table (`dept`). Unmatched right-side columns are populated with `NULL`.

```sql
-- Lists all teachers, appending NULL for departments that don't exist for unassigned staff
SELECT teacher.name, dept.name
FROM teacher
LEFT JOIN dept 
  ON teacher.dept = dept.id;

### 3. `RIGHT JOIN`
A `RIGHT JOIN` preserves every row from the secondary (right) table (`dept`), pulling in matching data from the left table and inserting `NULL` where left-side records are missing. This is critical for administrative reporting where empty categories must be visible (e.g., listing an Engineering department with zero staff).

```sql
-- Ensures every department is listed, even if zero teachers are assigned to it
SELECT teacher.name, dept.name
FROM teacher
RIGHT JOIN dept 
  ON teacher.dept = dept.id;

---

## Part 3: Fallback Substitution with `COALESCE`

When query results contain `NULL` values that disrupt presentation layers or calculations, the **`COALESCE()`** function provides a clean mitigation strategy.

### Concept
`COALESCE(val1, val2, val3, ...)` evaluates its arguments sequentially from left to right and returns the **first non-NULL value** it encounters.

### Practical Applications
1.  **Phone Number Fallbacks:** Supplying a default contact number if a mobile record is missing.
2.  **String Substitution:** Replacing raw `NULL` department names with a readable label like `'None'`.

```sql
-- Substitutes a default fallback number if the mobile column contains NULL
SELECT name, COALESCE(mobile, '07986 444 2266') AS contact_number
FROM teacher;

```sql
-- Combines LEFT JOIN with COALESCE to display 'None' instead of blank table cells for unassigned departments
SELECT teacher.name, COALESCE(dept.name, 'None') AS department_label
FROM teacher
LEFT JOIN dept 
  ON teacher.dept = dept.id;

---

## Part 4: Aggregate Functions and NULL Behavior

Aggregate functions handle `NULL` values differently depending on how they are structured:

*   **`COUNT(column)`:** Automatically **ignores** any row where the specified column is `NULL`, counting only populated records.
*   **`COUNT(*)`:** Counts all rows in the virtual table, including those containing `NULL` values.
*   **`COUNT(DISTINCT column)`:** Evaluates unique values while skipping `NULL` entries.

```sql
-- Counts total teacher IDs (including non-null rows) and unique mobile numbers, ignoring NULL entries
SELECT COUNT(teacher.id), COUNT(DISTINCT teacher.mobile)
FROM teacher;

### Aggregating with Outer Joins for Zero Counts
To generate reports that list categories with zero activity (e.g., counting staff per department where an engineering department has 0 members), pair a `RIGHT JOIN` with group aggregations:

```sql
-- Counts staff per department, ensuring empty departments report '0' via RIGHT JOIN mechanics
SELECT dept.name, COUNT(teacher.name) AS staff_count
FROM teacher
RIGHT JOIN dept 
  ON teacher.dept = dept.id
GROUP BY dept.name;

---

## Part 5: Conditional Logic Using `CASE` Statements

When you need to categorize data dynamically based on complex logical rules, SQL provides the structural **`CASE`** expression.

### Syntax Pattern
A `CASE` block evaluates conditions sequentially. Once a condition is met, it returns the specified result and exits; if no conditions match, it falls back to the `ELSE` clause before terminating with `END`.

```sql
-- Evaluates department IDs to categorize teachers into 'Sci', 'Art', or 'None' using multi-branch logic
SELECT teacher.name, 
       CASE 
         WHEN dept IN ('1', '2') THEN 'Sci'
         WHEN dept = 3 THEN 'Art'
         ELSE 'None'
       END AS category_label
FROM teacher;
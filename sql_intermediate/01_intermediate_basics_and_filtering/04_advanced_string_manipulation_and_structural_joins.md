# Advanced String Manipulation, Self-Joins, and Structural SQL Mechanics

This technical reference guide covers a wide array of intermediate SQL operations. It bridges data transformation functions (`REPLACE`), structural querying rules, set combinations (`UNION` vs `UNION ALL`), advanced self-joins with department lookups, escaping special characters, quoted identifiers for spaced column names, and handling missing data (`NULL`).

---

## Part 1: String Transformation with `REPLACE()`

### Concept
The `REPLACE()` function scans a string, finds all occurrences of a specific target substring, and swaps them out for a new replacement string.

### Syntax
```sql
REPLACE(source_string, search_string, replacement_string)

```

### Explanation & Examples

* **Substitution:** `REPLACE('vessel', 'e', 'a')` evaluates to `'vassal'`.
* **Character Removal:** To strip a character entirely, pass an empty string `''` as the replacement parameter.

```sql
-- Removes all lowercase 'a' characters from country names
SELECT name, REPLACE(name, 'a', '') AS name_without_a
FROM world;

```

### Real-Life Application

* Data cleaning pipelines where phone numbers, postal codes, or raw text feeds contain unwanted formatting symbols (like dashes, spaces, or rogue characters) before loading into a data warehouse.

### Best Practices

* `REPLACE()` is case-sensitive in most SQL dialects. If you need case-insensitive replacements, normalize the text using `LOWER()` or `UPPER()` first.

---

## Part 2: The Anatomy of a Basic `SELECT` Statement

### Concept

The `SELECT` command is the primary gateway for querying a database. Regardless of how complex a query becomes, its output is **always a two-dimensional grid** consisting of rows and columns.

### Syntax & Core Components

```sql
SELECT column1, column2 
FROM table_name 
WHERE condition = 'value';

```

* **`SELECT` clause:** Dictates *which columns* appear in the output grid.
* **`FROM` clause:** Identifies the target table(s).
* **`WHERE` clause:** Filters *which rows* pass the test.

---

## Part 3: String Concatenation (`||` vs Vendor Syntax)

### Concept

Concatenation joins two or more strings together end-to-end.

### Syntax & Vendor Differences

* **Standard ANSI SQL:** Uses the double-pipe operator (`||`).
* **Vendor Variations:**
* PostgreSQL, SQLite, Oracle: `col1 || ' ' || col2`
* MySQL: `CONCAT(col1, ' ', col2)`
* SQL Server (T-SQL): `col1 + ' ' + col2`



### Example

```sql
-- PostgreSQL / Standard SQL syntax combining first and last names
SELECT first_name || ' ' || last_name AS full_name
FROM employees;

```

---

## Part 4: Flexible Pattern Matching with `LIKE`

### Concept

The `LIKE` operator performs partial string matching using wildcard characters.

* `%`: Matches zero, one, or multiple arbitrary characters.
* `_`: Matches exactly one single character.

### Example

```sql
-- Finds all countries starting with the letter 'Z'
SELECT name 
FROM world 
WHERE name LIKE 'Z%';

```

---

## Part 5: Combining Result Sets (`UNION` vs `UNION ALL`)

### Concept

A `UNION` operation stacks the output grids of two or more separate `SELECT` statements on top of each other into a single unified result set.

### Rules for `UNION`:

1. Every `SELECT` statement must have the **exact same number of columns**.
2. The columns must have **compatible data types** in the exact same matching order.

### `UNION` vs `UNION ALL`

* **`UNION`:** Automatically removes duplicate rows from the final result set. Requires sorting/scanning overhead.
* **`UNION ALL`:** Preserves **all** rows, including duplicates. Significantly faster because it simply appends results together.

```sql
-- UNION: Returns combined list with duplicates removed
SELECT name FROM north_america_countries
UNION
SELECT name FROM south_america_countries;

-- UNION ALL: Returns all rows, keeping duplicates if any exist
SELECT city FROM local_branch_a
UNION ALL
SELECT city FROM local_branch_b;

```

---

## Part 6: Escaping Apostrophes in String Literals

### Concept

Because SQL uses single quotes (`'...'`) to wrap string boundaries, database engines throw syntax errors if data contains an unescaped internal apostrophe (e.g., searching for a book title like *Tom's Book*).

### Syntax & Example

To escape an apostrophe in standard SQL, **double it up** (`''`).

```sql
SELECT *
FROM books
WHERE title = 'Tom''s Book';

```

---

## Part 7: Full-Text Search via `LIKE` (The Brute-Force Approach)

### Concept

If you need to find a specific keyword hidden anywhere inside a massive text column across a table, the simplest approach is a brute-force pattern search using leading and trailing wildcards.

### Example

```sql
-- Searches for the word 'database' anywhere inside a review comment
SELECT review_text
FROM user_reviews
WHERE review_text LIKE '%database%';

```

* **Performance Warning:** Using leading wildcards (`'%term%'`) forces a **full table scan** because indexes cannot optimize wildcard-prefixed text searches efficiently.

---

## Part 8: Column Aliasing (`AS`)

### Concept

When returning calculated values, math expressions, or aggregate functions, you can assign a custom header using the `AS` keyword.

### Example

```sql
SELECT COUNT(employee_id) AS total_active_staff
FROM employees
WHERE status = 'Active';

```

---

## Part 9: Self-Joins & Department Lookups (The Employee-Manager Problem)

### Concept

A **Self-Join** happens when a table needs to be joined **to itself**. This is common in hierarchical data structures, such as an `employee` table where every employee record contains a `manager_id` pointing directly back to another `employee_id` in the *same* table.

### Simplified Explanation

We create two imaginary copies of the table using **Aliases**: `w` (for worker) and `b` (for boss). If we also need to pull department details for both the worker and the manager, we can chain standard inner joins to the `department` table.

### Code Example (Worker, Boss, and Department Lookups)

```sql
CREATE TABLE department (
  dept_code VARCHAR(10) PRIMARY KEY,
  dept_name VARCHAR(50)
);

CREATE TABLE employee(
  employee_id INTEGER PRIMARY KEY,
  first_name VARCHAR(10),
  dept_code VARCHAR(10),
  manager_id INTEGER REFERENCES employee
);

INSERT INTO employee VALUES (1,'Robin','Eng',NULL);
INSERT INTO employee VALUES (2,'Jon','SoC',1);
INSERT INTO employee VALUES (3,'Andrew','SoC',2);
INSERT INTO employee VALUES (4,'Alison','SoC',2);

-- Self-join linking worker to boss, including department context
SELECT 
  w.employee_id AS worker_id,
  w.first_name AS worker,
  w.dept_code AS worker_dept,
  b.employee_id AS manager_id,
  b.first_name AS boss,
  m_dept.dept_code AS manager_dept
FROM employee w
LEFT JOIN employee b ON w.manager_id = b.employee_id
LEFT JOIN department m_dept ON b.dept_code = m_dept.dept_code;

```

* **Why did Robin show up here?** By switching from an inner join to a `LEFT JOIN` on the manager relationship, `Robin` (who has a `NULL` manager_id) is preserved in the output grid instead of being filtered out.

---

## Part 10: Column Names with Spaces (Quoted Identifiers)

### Concept

Normally, SQL column identifiers cannot contain spaces. If you inherit a legacy database or CSV import containing column names with spaces (e.g., `"Account Balance"`), you must wrap the identifier in **Quoted Identifiers**.

### Syntax Variants across Vendors

* **ANSI SQL Standard / PostgreSQL / SQLite:** Double quotes (`"Account Balance"`)
* **Microsoft SQL Server (T-SQL):** Square brackets (`[Account Balance]`)
* **MySQL:** Backticks (``Account Balance``)

### Example

```sql
CREATE TABLE SpaceMonster ("Account Balance" INT);
INSERT INTO SpaceMonster VALUES (42);

SELECT "Account Balance" 
FROM SpaceMonster;

```

* **Best Practice:** Avoid spaces in database identifiers entirely; use `snake_case` instead.

---

## Part 11: Handling Missing Data (`IS NULL`)

### Concept

In SQL, `NULL` represents missing or unknown data. You **cannot use standard comparison operators like `= NULL` or `!= NULL**` because comparing anything to unknown evaluates to null/false. You must explicitly use `IS NULL` or `IS NOT NULL`.

### Example

```sql
SELECT name, gdp
FROM world
WHERE gdp IS NULL;

```
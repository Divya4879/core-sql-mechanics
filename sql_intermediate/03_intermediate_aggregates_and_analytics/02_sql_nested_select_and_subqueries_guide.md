# SQL Nested Select & Subqueries Guide

A subquery (nested `SELECT`) allows the output of one query to serve as an input value, set, or table for another query. The inner subquery executes *first*, passing its resolved results up to the outer query.

---

## 1. Single-Value Subqueries (`=`)

When a subquery is guaranteed to return strictly **one row and one column** (a scalar value), standard comparison operators like `=` can be used directly.

### Usage & Pattern

*Use Case:* Dynamic filtering against a single lookup value that changes or is unknown beforehand.

```sql
/* Find countries in the same continent as Brazil */
SELECT name 
FROM world 
WHERE continent = (
    SELECT continent 
    FROM world 
    WHERE name = 'Brazil'
);

```

---

## 2. Handling Multiple Results (`IN` Operator)

If a subquery returns **multiple rows** (e.g., matching multiple continents), using `=` will fail. You must use the `IN` operator to handle multi-row evaluation sets.

### Usage & Pattern

* *Use Case:* Filtering against a dynamic list of group items.

```sql
/* Find countries in the same continent as Brazil or Mexico */
SELECT name, continent 
FROM world
WHERE continent IN (
    SELECT continent 
    FROM world 
    WHERE name = 'Brazil' 
       OR name = 'Mexico'
);

```

---

## 3. Derived Tables (`FROM` Clause Subqueries) & Aliasing

A subquery can be placed inside the `FROM` clause to act as a **derived table** (a virtual temporary table that the outer query queries against).

### Aliasing Rules

* **Mandatory Aliases:** Modern SQL engines *always* require you to give a derived table an alias using the `AS` keyword (e.g., `AS sub`). Without it, the query will throw a syntax error.

```sql
/* Querying against a temporary aggregated subquery result */
SELECT sub.continent, sub.total_pop
FROM (
    SELECT continent, SUM(population) AS total_pop
    FROM world
    GROUP BY continent
) AS sub
WHERE sub.total_pop > 100000000;

```

---

## 4. Subqueries on the `SELECT` Line (Scalar Calculations)

If a subquery is guaranteed to return a single scalar value, it can be placed directly inside the `SELECT` column list to compute dynamic ratios or relative benchmarks per row.

### Usage & Pattern

* *Use Case:* Comparing individual row metrics against a global benchmark without a full join.

```sql
/* Show China's population as a multiple of the UK's */
SELECT 
    name, 
    population / (SELECT population FROM world WHERE name = 'United Kingdom') AS population_multiple
FROM world
WHERE name = 'China';

```

---

## 5. Set Operators over a Set (`ALL` and `ANY` / `SOME`)

Standard binary comparison operators (`=`, `>`, `<`, `>=`, `<=`) evaluate a single value against a single target. Modifying them with **`ALL`** or **`ANY`** allows them to evaluate against an entire multi-row set.

### A. `> ALL` (Greater than every value in the set)

The outer value must be strictly greater than the *maximum* value returned by the subquery list.

* *Use Case:* Finding absolute outliers that beat the maximum value of a peer group.

```sql
/* Countries with a population greater than every single country in Europe */
SELECT name
FROM world
WHERE population > ALL (
    SELECT population 
    FROM world 
    WHERE continent = 'Europe' 
      AND population > 0
);

```

### B. `> ANY` (Greater than at least one value in the set)

The outer value must be greater than the *minimum* value returned by the subquery list (equivalent to `> MIN(...)`).

* *Use Case:* Finding items that exceed at least the floor threshold of a reference group.

```sql
/* Countries with a population greater than any (at least one) country in Europe */
SELECT name
FROM world
WHERE population > ANY (
    SELECT population 
    FROM world 
    WHERE continent = 'Europe' 
      AND population > 0
);

```
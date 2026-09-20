# Advanced Subqueries, Type Casting, and the ALL Operator Mechanics

When moving beyond basic filtering and joins, SQL subqueries and advanced formatting functions allow you to perform complex cross-table evaluations, string manipulations, and conditional comparisons against entire lists of data.

---

## 1. Mathematical Formatting & Type Casting (`CONCAT`, `CAST`, `ROUND`)
When calculating ratios or percentages, SQL typically returns raw floating-point decimals. Production reporting often requires cleaning these numbers for presentation.

*   **`ROUND(expression, decimals)`**: Rounds a numeric output to specified decimal places.
*   **`CAST(expression AS data_type)`**: Converts a value into a specific data type (e.g., converting a rounded float to an `INT` to eliminate trailing `.0` decimals).
*   **`CONCAT(str1, str2, ...)`**: Joins multiple strings or data values together.

```sql
/* Calculates European country populations as a percentage of Germany's */
SELECT 
    name, 
    CONCAT(
        CAST(
            ROUND(100 * population / (SELECT population FROM world WHERE name = 'Germany'), 0) 
            AS INT
        ), 
        '%'
    ) AS percentage
FROM world
WHERE continent = 'Europe';

```

---

## 2. The `ALL` Operator & The `NULL` Gotcha

The `ALL` operator allows standard comparison operators (`>`, `<`, `>=`, `<=`, `=`) to evaluate a single value against **every** value returned in a subquery list. For the condition to pass, the comparison must hold true for all items in that list.

> ⚠️ **The `NULL` Trap:** If a subquery returns a `NULL` value, comparison logic using `ALL` can break entirely. You must always filter out missing data in your subquery (e.g., `WHERE population > 0`).

```sql
/* Find countries with a GDP greater than every country in Europe */
SELECT name
FROM world
WHERE gdp > ALL (
    SELECT gdp 
    FROM world
    WHERE continent = 'Europe' 
      AND gdp > 0
);

```

---

## 3. Correlated (Synchronized) Subqueries

A **Correlated Subquery** depends directly on the outer query, evaluating row-by-row like a nested loop.

* **Table Aliasing:** Relies on aliases (e.g., `world x` and `world y`) to distinguish between the outer row being processed and the inner rows being scanned.
* **Contextual Matching:** The inner query filters rows based on criteria linked to the current outer row (such as matching continents).

### Pattern A: Alphabetical Extrema (`<= ALL`)

Relational operators evaluate text strings based on standard lexicographical (alphabetical) ordering.

```sql
/* Find the first country alphabetically for each continent */
SELECT continent, name
FROM world x
WHERE name <= ALL (
    SELECT y.name 
    FROM world y
    WHERE x.continent = y.continent
)
ORDER BY name ASC;

```

### Pattern B: Scaled Peer Comparisons & Self-Exclusion

You can modify subquery values mathematically to evaluate records against scaled metrics of their peers.

> 💡 **The Self-Exclusion Rule:** When comparing a row against peers in the same table, you must include `AND x.name != y.name` to prevent a record from evaluating against itself.

```sql
/* Find countries with populations more than 3x that of all their neighbors */
SELECT name, continent
FROM world x
WHERE population > ALL (
    SELECT 3 * population  
    FROM world y
    WHERE x.continent = y.continent
      AND x.name != y.name
);

```
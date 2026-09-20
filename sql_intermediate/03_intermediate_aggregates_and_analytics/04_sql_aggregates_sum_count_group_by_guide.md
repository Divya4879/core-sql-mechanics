# Intermediate SQL Guide: Aggregates, Grouping & Order of Execution (`SUM`, `COUNT`, `GROUP BY`, `HAVING`)

Moving from basic row-by-row selection (`SELECT ... WHERE`) to aggregate reporting requires shifting your mental model from processing individual records to evaluating entire groups of data.

---

## 1. The SQL Order of Execution (The Most Important Concept)

When writing queries with `GROUP BY` and aggregates, SQL does **not** execute lines in the order you write them. Understanding the engine's execution lifecycle prevents runtime errors and logical bugs.

### The Execution Pipeline:

1. **`FROM` / `JOIN**`: Gathers and joins the raw tables.
2. **`WHERE`**: Filters raw, individual rows **before** any grouping or math happens. *(You cannot use aggregate functions here).*
3. **`GROUP BY`**: Collapses the filtered rows into summary groups based on specified columns.
4. **`HAVING`**: Filters the **already-aggregated groups** based on aggregate results (e.g., groups where `SUM() > 100`).
5. **`SELECT`**: Evaluates expressions, aliases, and aggregate functions on the grouped rows.
6. **`DISTINCT`**: Drops duplicate rows.
7. **`ORDER BY`**: Sorts the final output. *(Can reference column aliases created in the `SELECT` step).*
8. **`LIMIT`**: Truncates the result set.

---

## 2. Core Aggregate Functions & The `NULL` Gotcha

Aggregates process a set of rows and return a single scalar value.

* **`COUNT(*)`**: Counts **all rows**, including those with `NULL` values.
* **`COUNT(column_name)`**: Counts only rows where the specified column is **not `NULL**`.
* **`SUM(column_name)`**: Computes the total sum of numerical values, ignoring `NULL` values.

---

## 3. Grouping (`GROUP BY`) & Filtering (`HAVING` vs. `WHERE`)

### The `WHERE` vs. `HAVING` Rule

* Use **`WHERE`** to filter raw source rows *before* grouping.
* Use **`HAVING`** to filter grouped summary results *after* aggregation.

---

## 4. Intermediate & Advanced Patterns

### Pattern A: Filtering Rows Before Aggregating (SQLZoo Q7 Style)

*Use Case:* "For each continent, show the continent and number of countries with populations of at least 10 million."

* **Logic:** You only want to count countries that meet a raw row condition *before* grouping them by continent. Therefore, the condition belongs in the `WHERE` clause.

```sql
SELECT continent, COUNT(name) AS large_country_count
FROM world
WHERE population >= 10000000 -- Filters raw rows first
GROUP BY continent;

```

---

### Pattern B: Filtering Groups After Aggregating (SQLZoo Q8 / HAVING Style)

*Use Case:* "List the continents that have a total population of at least 100 million."

* **Logic:** You must calculate the sum of the population *per continent* first, and then filter out continents whose total sum falls below 100 million. This requires **`HAVING`** (or a subquery/`ALL` setup).

#### Approach 1: The Idiomatic Way (`GROUP BY` + `HAVING`)

```sql
SELECT continent
FROM world
GROUP BY continent
HAVING SUM(population) >= 100000000; -- Filters aggregated group sums

```

#### Approach 2: The Subquery / `ALL` Way

```sql
SELECT continent
FROM world x
WHERE 100000000 <= (
    SELECT SUM(population) 
    FROM world y
    WHERE x.continent = y.continent
)
GROUP BY continent;

```

---

### Pattern C: Conditional Aggregation (Pivot Pattern)

An advanced intermediate pattern involves counting or summing *only specific subsets* of data within a single query using conditional statements inside the aggregate.

*Use Case:* Count the number of "mega countries" (pop > 100M) vs. standard countries per continent in a single row.

```sql
SELECT 
    continent,
    COUNT(name) AS total_countries,
    SUM(CASE WHEN population > 100000000 THEN 1 ELSE 0 END) AS mega_countries,
    SUM(CASE WHEN population <= 100000000 THEN 1 ELSE 0 END) AS standard_countries
FROM world
GROUP BY continent;

```

* **Why it works:** The `CASE` statement evaluates each row dynamically *inside* the `SUM` or `COUNT` function, enabling multi-metric reporting without complex self-joins.

---

## Pattern D: Practical Patterns: Combined `WHERE` & `HAVING`

When building aggregate reports, you will frequently need to filter raw data *before* grouping while simultaneously filtering summary groups *after* aggregation.

### Example: Filtering Rows First, Then Filtering Groups

* **Query:** For each relevant continent, show the number of countries that have a population of at least 200 million (using `WHERE`), or filter continents whose total aggregate population exceeds half a billion (using `HAVING`).

```sql
-- Filtering aggregated groups with HAVING (e.g., continents with total pop >= 500M)
SELECT continent, SUM(population) AS total_pop
FROM world
GROUP BY continent
HAVING SUM(population) >= 500000000;

-- Combining WHERE (pre-filter rows) and HAVING (post-filter groups)
SELECT continent, COUNT(name) AS large_countries
FROM world
WHERE population >= 200000000  -- Step 1: Filter raw rows first
GROUP BY continent             -- Step 2: Group remaining rows
HAVING COUNT(name) > 0;        -- Step 3: Filter final group summaries

```

---

## Pattern E: Ordering by Column Position

When writing `ORDER BY` clauses on aggregate queries, you can reference columns by their **numerical index position** in the `SELECT` list (1-indexed) rather than re-typing long aggregate functions or column aliases.

```sql
-- Sorts the output by the second column (SUM(population)) in ascending/descending order
SELECT continent, SUM(population) AS total_population
FROM world
GROUP BY continent
ORDER BY 2 DESC;

```
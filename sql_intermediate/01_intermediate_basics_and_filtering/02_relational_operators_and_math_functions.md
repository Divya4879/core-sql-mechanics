# Relational Operators, Mathematical Scaling, and Advanced String Analysis

This document serves as an exhaustive technical reference guide for intermediate SQL operations. It covers exclusive conditions (`XOR`), numerical scaling, advanced rounding mechanics, character metrics, vendor-specific syntax, and multi-condition text validation.

---

## Part 1: Exclusive Conditionals (`XOR`)

When filtering data, standard `OR` returns true if *either* or *both* conditions are met. However, you often need **Exclusive OR (XOR)**: evaluating whether a row satisfies one condition **or** the other, but explicitly excluding rows where **both** conditions are true simultaneously.

### The Logic Matrix
* Condition A = True, Condition B = True $\rightarrow$ **False** (Excluded)
* Condition A = True, Condition B = False $\rightarrow$ **True** (Included)
* Condition A = False, Condition B = True $\rightarrow$ **True** (Included)
* Condition A = False, Condition B = False $\rightarrow$ **False** (Excluded)

### Example Problem: Mutually Exclusive "Big" Countries
* *Problem Statement:* Find countries that are either big by area (greater than 3 million sq km) or big by population (greater than 250 million), but **not both**. (e.g., Australia and Indonesia qualify; China fails because it is large in both categories; the UK fails because it is small in both).

```sql
SELECT name, population, area
FROM world
WHERE population > 250000000
XOR area > 3000000;

```

---

## Part 2: Mathematical Scaling & The Integer Division Trap

When dividing numeric values in SQL to convert raw integers into readable units (like scaling raw inhabitants into millions or raw currency into billions), you must account for database arithmetic rules.

### The Integer Division Gotcha

In many SQL dialects, dividing an integer by an integer results in **integer truncation** (e.g., `5 / 2` yields `2`, completely discarding the decimal `.5`).

* **The Fix:** Force floating-point math by dividing by a decimal/float literal (e.g., dividing by `1000000.0` instead of `1000000`).

```sql
-- Converts raw population to millions and raw GDP to billions safely
SELECT 
  name, 
  population / 1000000.0 AS pop_in_millions, 
  gdp / 1000000000.0 AS gdp_in_billions
FROM world
WHERE continent = 'South America';

```

---

## Part 3: Precision Control with `ROUND()` & Negative Rounding

The `ROUND()` function is used to format numerical outputs to a specified decimal place.

### Syntax

```sql
ROUND(column_name, decimal_places)

```

### 1. Standard Decimal Rounding

```sql
-- Rounds the calculated population and GDP values to 2 decimal places
SELECT 
  name, 
  ROUND(population / 1000000.0, 2) AS pop_millions, 
  ROUND(gdp / 1000000000.0, 2) AS gdp_billions
FROM world
WHERE continent = 'South America';

```

### 2. Deep Dive: Negative Decimal Arguments (`-3`)

What happens when you pass a *negative* integer into the second parameter of `ROUND()`?
Instead of rounding *right* of the decimal point, negative numbers round *left* of the decimal point, targeting tens, hundreds, thousands, and millions.

* `0` $\rightarrow$ Rounds to the nearest integer (ones place).
* `-1` $\rightarrow$ Rounds to the nearest 10.
* `-2` $\rightarrow$ Rounds to the nearest 100.
* `-3` $\rightarrow$ Rounds to the nearest **1,000**.

```sql
-- Problem: Show name and GDP per capita, rounded to the nearest thousand
SELECT name, ROUND(gdp / population, -3) AS per_capita_gdp
FROM world
WHERE gdp >= 1000000000000;

```

* *Why use `-3`?* For financial data like per capita GDP, displaying exact figures like `$43,281.49` is cluttered. Rounding with `-3` cleans the output to the nearest thousand (e.g., `$43,000`).

---

## Part 4: String Length Functions (`LENGTH()` vs. `LEN()`)

To evaluate the physical sizing of text strings, SQL provides length-checking functions. However, syntax varies by database vendor:

* **`LENGTH(string)`:** Standard ANSI syntax used in PostgreSQL, MySQL, SQLite, and Oracle.
* **`LEN(string)`:** Proprietary syntax used in **Microsoft SQL Server (T-SQL)**.

### Example Problem: Matching Character Counts

* *Problem Statement:* Find countries where the name and the capital have the exact same number of characters (e.g., *Greece* [6] and *Athens* [6]).

```sql
SELECT name, capital
FROM world
WHERE LENGTH(name) = LENGTH(capital);

```

---

## Part 5: Substring Isolation (`LEFT()`) & Inequality Operators

### 1. The `LEFT()` Function

The `LEFT()` function extracts a specified number of characters from the beginning (left side) of a string.

* **Syntax:** `LEFT(column_name, number_of_characters)`

### 2. Inequality Operators (`!=` vs. `<>`)

Both operators mean "not equal to".

* `!=` is widely supported.
* `<>` is the strict ANSI SQL standard. Both are functionally identical in most modern databases.

### Example Problem: First Letter Matching (Excluding Exact Self-Matches)

* *Problem Statement:* Find countries and capitals where the first letter matches (e.g., Sweden & Stockholm both start with 'S'), but exclude countries where the entire name and capital are identical strings.

```sql
SELECT name, capital
FROM world
WHERE LEFT(name, 1) = LEFT(capital, 1)
  AND name != capital;

```

---

## Part 6: Multi-Condition Text Pattern Matching (The Vowel & No-Space Filter)

When a query requires complex logical validation—such as ensuring a string contains multiple independent sub-elements while simultaneously excluding others—you can chain multiple `LIKE` and `NOT LIKE` conditions together using `AND`.

### Example Problem: All Vowels and Single-Word Constraints

* *Problem Statement:* Find the country name that contains all five vowels (`a`, `e`, `i`, `o`, `u`) anywhere in its spelling, but contains **no spaces** in its name.
* *The Multi-Word Exception Note:* Countries like *Equatorial Guinea* and *Dominican Republic* contain all five vowels, but they **fail** this filter because they consist of multiple words separated by spaces.



```sql
SELECT name
FROM world
WHERE name LIKE '%a%'
  AND name LIKE '%e%'
  AND name LIKE '%i%'
  AND name LIKE '%o%'
  AND name LIKE '%u%'
  AND name NOT LIKE '% %';

```

### Why this pattern works:

1. **The Vowel Chain (`AND LIKE`):** Because all conditions are joined by `AND`, the database evaluates every single row against all five vowel constraints. A country must pass every check to be returned.
2. **The Space Exclusion (`NOT LIKE '% %'`):** The `% %` wildcard searches for an embedded space. Prefixing it with `NOT` explicitly filters out multi-word strings like *Equatorial Guinea*.
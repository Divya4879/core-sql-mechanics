# Core Syntax, Advanced Filtering, and String Manipulation

This document bridges basic retrieval concepts with intermediate filtering patterns, strict grammar rules, wildcard mechanics, and dynamic string functions.

---

## Part 1: Syntax Rules, String Literals, and Set Membership

### 1. The Anatomy of a Basic `SELECT` Query
At its core, a query instructs the database engine which columns to extract (`SELECT`), from which table (`FROM`), and what strict conditional filters must be applied (`WHERE`).

```sql
SELECT name, population 
FROM world 
WHERE name = 'France';

```

### 2. String Quotation Mechanics: Single vs. Double Quotes

* **Single Quotes (`'text'`):** Strictly reserved in standard ANSI/ISO SQL for **string literal values** (the actual data residing inside rows, like `'Sweden'` or `'France'`).
* **Double Quotes (`"identifier"`):** Reserved for **database object identifiers** (such as column names, table names, or aliases, particularly those containing spaces or reserved keywords).

> **Rule of Thumb:** Always use single quotes for text data values. Using double quotes for strings may pass in lenient engines like MySQL, but will throw an immediate syntax error in enterprise databases like PostgreSQL or Oracle.

### 3. Multi-Value Filtering with `IN (...)`

When you need to match a column against multiple discrete options, chaining `OR` statements (`WHERE name = 'A' OR name = 'B'`) becomes hard to scale. The `IN` operator provides a clean shorthand.

* **Why are parentheses `()` mandatory with `IN`?** In SQL grammar, `IN` is an operator designed to evaluate a *set*. The parentheses act as the collection constructor delimiter, telling the SQL parser precisely where the literal list begins and ends.

```sql
-- Clean syntax checking membership against a set of literal values
SELECT name, population 
FROM world 
WHERE name IN ('Sweden', 'Norway', 'Denmark');

```

---

## Part 2: Advanced Pattern Matching & Wildcards (`LIKE`, `%`, `_`)

When exact matching (`=`) isn't enough, the `LIKE` operator enables flexible text searching using wildcard symbols.

### Wildcard Glossary

* **`%` (Percent Sign):** Matches **zero, one, or multiple arbitrary characters**.
* **`_` (Underscore):** Matches **exactly one single character**.

### Common Problem Patterns & Implementations

#### Pattern A: Suffix & Prefix Lookups (`%`)

```sql
-- Problem: Find all countries ending with the letter 'y'
SELECT name 
FROM world 
WHERE name LIKE '%y';

-- Problem: Find all countries ending with the word 'land'
SELECT name 
FROM world 
WHERE name LIKE '%land';

```

#### Pattern B: Multi-Occurrence Searching (`%...%...%`)

To find strings containing a character a minimum number of times, sandwich the target character between wildcard blocks.

```sql
-- Problem: Find countries containing three or more 'a' characters anywhere in their name
SELECT name 
FROM world 
WHERE name LIKE '%a%a%a%';

```

#### Pattern C: Precise Character Positioning (`_`)

When a character must sit at a specific index rather than an arbitrary location, use the single-character underscore `_`.

```sql
-- Problem: Find countries where 't' is the 2nd character 
SELECT name 
FROM world 
WHERE name LIKE '_t%' 
ORDER BY name;

```

#### Pattern D: Complex Spacing & Fixed Lengths

* **Exact Character Length:** Chaining underscores enforces a strict string length (e.g., four underscores `____` matches any word that is precisely 4 characters long).
* **Separated Characters:** Multiple wildcards can be combined to track characters separated by exact gaps (e.g., two 'o's separated by two arbitrary characters).

```sql
-- Problem: Find countries with a name length of exactly 4 characters
SELECT name 
FROM world 
WHERE name LIKE '____';

-- Problem: Find countries with two 'o' characters separated by exactly two other characters
SELECT name 
FROM world 
WHERE name LIKE '%o__o%';

```

---

## Part 3: Dynamic String Manipulation & Relational Text Comparison (`CONCAT()`)

Sometimes, filtering requires comparing two columns or appending text dynamically rather than checking against a static string literal. This is where string functions like `CONCAT()` become essential.

### 1. Dynamic Suffix Construction

The `CONCAT()` function merges multiple string arguments into a single continuous string. This allows you to construct dynamic comparison patterns inside a `WHERE` clause.

```sql
-- Problem: Find countries where the capital matches the country name followed by " City"
SELECT name 
FROM world 
WHERE capital LIKE concat(name, ' City');

```

### 2. Advanced Filtering: Inclusion vs. Strict Extensions

* **Inclusion Matching (`concat(name, '%')`):** Checks if the capital begins with the exact spelling of the country name.

```sql
SELECT capital, name 
FROM world 
WHERE capital LIKE concat(name, '%');

```

* **Strict Extensions Excl. Exact Matches (`concat(name, '%_')`):**
* *The Challenge:* Find capitals that are longer expansions of their country names (e.g., include *Mexico* -> *Mexico City*), but **exclude** edge cases where the capital name is identical to the country name (e.g., exclude *Luxembourg*).
* *The Solution:* Append a trailing underscore `_` to your concatenation.



```sql
SELECT capital, name 
FROM world 
WHERE capital LIKE concat(name, '%_');

```

* *Why does `%_` work?* `%` matches zero or more characters. By itself, `concat(name, '%')` would match *Luxembourg* because zero characters after *Luxembourg* still fulfills the match. Appending `_` enforces that **at least one mandatory trailing character** must follow the country name, instantly filtering out exact self-matches while successfully capturing longer extensions like *Mexico City*.



---

### Code Examples

Topics Covered: Basic Selection, Set Membership (IN), Wildcards (LIKE, %, _), 
    and String Concatenation (CONCAT).


----------------------------------------------------------------------------
SECTION 1: Syntax, Literals, and Set Membership
----------------------------------------------------------------------------

1. Show the name and population for Sweden, Norway, and Denmark using IN()

```sql
SELECT name, population 
FROM world 
WHERE name IN ('Sweden', 'Norway', 'Denmark');
```


----------------------------------------------------------------------------
SECTION 2: Pattern Matching and Wildcards
----------------------------------------------------------------------------

2. Find countries that end with the letter 'y'

```sql
SELECT name 
FROM world 
WHERE name LIKE '%y';
```

3. Find countries that end with the word 'land'

```sql
SELECT name 
FROM world 
WHERE name LIKE '%land';
```

4. Find countries that have three or more 'a' characters in their name

```sql
SELECT name 
FROM world 
WHERE name LIKE '%a%a%a%';
```

5. Find countries that have "t" as the second character (ordered alphabetically)

```sql
SELECT name 
FROM world 
WHERE name LIKE '_t%' 
ORDER BY name;
```

6. Find countries with two "o" characters separated by two other characters
```sql
SELECT name 
FROM world 
WHERE name LIKE '%o__o%';
```

7. Find countries that have a name length of exactly 4 characters

```sql
SELECT name 
FROM world 
WHERE name LIKE '____';
```

----------------------------------------------------------------------------
SECTION 3: Advanced String Functions and Dynamic Comparison
----------------------------------------------------------------------------

8. Find countries where the capital is the country name plus ' City'

```sql
SELECT name 
FROM world 
WHERE capital LIKE concat(name, ' City');
```

9. Find capital and name where the capital includes the country name

```sql
SELECT capital, name 
FROM world 
WHERE capital LIKE concat(name, '%');
```

10. Find capital and name where the capital is a strict extension of the country name 
 (Excludes exact matches like Luxembourg, includes extensions like Mexico City)

```sql
SELECT capital, name 
FROM world 
WHERE capital LIKE concat(name, '%_');
```
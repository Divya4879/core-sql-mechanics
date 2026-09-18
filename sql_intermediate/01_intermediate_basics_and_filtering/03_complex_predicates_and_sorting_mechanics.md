# Complex Predicates, Boolean Precedence, Character Encoding, and Advanced Sorting

This technical guide covers intermediate-to-advanced SQL filtering patterns. It addresses logical operator precedence (the SQL equivalent of BODMAS), dataset exclusion via `NOT IN`, handling non-ASCII text and Umlauts, escaping string literals, multi-level sorting, and leveraging boolean expressions as numeric sort keys.

---

## Part 1: Prefix Pattern Matching & Dynamic Construction

When filtering strings starting with a specific token, you can use traditional static wildcards (`LIKE 'John%'`) or dynamically construct the pattern using functions like `CONCAT()`.

```sql
-- Static prefix pattern
SELECT winner 
FROM nobel 
WHERE winner LIKE 'John%';

-- Dynamic prefix pattern using CONCAT()
SELECT winner 
FROM nobel 
WHERE winner LIKE concat('John', '%');

```

* **Best Practice:** While `CONCAT()` is powerful when strings are derived from other columns or runtime variables, static strings (`'John%'`) are generally cleaner and slightly more performant for hardcoded queries.

---

## Part 2: Boolean Operator Precedence (The SQL "BODMAS")

When mixing `AND` and `OR` operators in a `WHERE` clause, the database evaluates `AND` with higher priority than `OR` (similar to how multiplication takes precedence over addition in arithmetic).

If you omit parentheses, your query will execute logic you did not intend. **Always use explicit parentheses to enforce evaluation order.**

### Example Problem: Multi-Year Specific Filtering

* *Problem Statement:* Find winners from 1980 in Physics **OR** winners from 1984 in Chemistry.

```sql
-- CORRECT: Parentheses explicitly segment each conditional block
SELECT yr, subject, winner
FROM nobel
WHERE (yr = 1980 AND subject = 'Physics')
   OR (yr = 1984 AND subject = 'Chemistry');

-- DANGEROUS / INCORRECT (Missing Parentheses):
-- Without parentheses, SQL groups `subject = 'Physics' OR yr = 1984` together 
-- due to operator precedence mixing, returning unintended rows.

```

---

## Part 3: Dataset Exclusion with `NOT IN`

When filtering out multiple specific discrete categories from a dataset, chaining multiple `AND subject != '...'` conditions creates brittle and unreadable code. The `NOT IN` operator provides a clean, scalable alternative.

### Example Problem: Excluding Chemists and Medics

* *Problem Statement:* Show all 1980 winners, strictly excluding Chemistry and Medicine.

```sql
SELECT yr, subject, winner
FROM nobel
WHERE yr = 1980
  AND subject NOT IN ('Chemistry', 'Medicine');

```

* **Why it shines:** If you later need to exclude Economics and Literature as well, you simply add them to the array inside the parentheses (`NOT IN ('Chemistry', 'Medicine', 'Economics', 'Literature')`) rather than writing multiple new `AND` clauses.
* **⚠️ Gotcha with `NULL`s:** If a column contains `NULL` values, using `NOT IN` will evaluate to unknown and return **zero rows**. Always ensure filtered columns have `NOT NULL` constraints or handle nulls explicitly when using exclusion sets.

---

## Part 4: Character Encoding, Umlauts, & Non-ASCII Handling

Real-world databases regularly encounter international names containing non-ASCII characters (diacritics, umlauts, accents), such as `PETER GRÜNBERG`.

```sql
SELECT *
FROM nobel
WHERE winner = 'PETER GRÜNBERG';

```

### Modern Database Best Practices for Non-ASCII Data:

1. **Database Collation:** Ensure your database and tables use a modern UTF-8 encoding charset (e.g., `utf8mb4` in MySQL or `UTF8` in PostgreSQL) to store accented characters natively without data corruption.
2. **Case and Diacritic Sensitivity:** Depending on your database collation settings, matching `Grünberg` vs `Grunberg` might be treated as distinct or identical. Use case-insensitive collations or explicit accent-insensitive configurations when building search bars.

---

## Part 5: Escaping String Literals (The Single Quote Trap)

Because SQL syntax uses single quotes (`'...'`) to wrap string literals, what happens when the data *itself* contains a single quote (an apostrophe), such as `EUGENE O'NEILL`?

If you write `WHERE winner = 'EUGENE O'NEILL'`, the database sees the apostrophe in `O'NEILL` as the premature closing delimiter of the string, throwing an immediate syntax error.

### How to Escape Single Quotes:

* **Standard SQL (ANSI Method):** Escape an internal single quote by **doubling it up** (`''`). The database reads the double quote as a literal apostrophe rather than a closing tag.
* **Engine-Specific Escaping:** Some programming layers or database dialects use a backslash (`\'`).

```sql
-- ANSI Standard SQL (Doubling the quote)
SELECT *
FROM nobel
WHERE winner = 'EUGENE O''NEILL';
OR winner = 'EUGENE O\'NEILL'

```

---

## Part 6: Multi-Column Sorting & Tie-Breaking Hierarchies

When sorting query results, you are rarely restricted to a single column. Multi-column sorting establishes a strict hierarchy of organization.

```sql
SELECT winner, yr, subject
FROM nobel
WHERE winner LIKE 'Sir%'
ORDER BY yr DESC, winner ASC;

```

* **How it evaluates:**
1. First, the database sorts all rows by year in descending order (`yr DESC`, newest first).
2. If multiple winners share the exact same year, it acts as a tie-breaker, sorting those specific rows alphabetically by winner name (`winner ASC`).



---

## Part 7: Advanced Trick: Boolean Expressions as Sort Keys (`0` or `1`)

One of the most powerful and elegant features in SQL is that **conditional expressions can be evaluated as numerical values (`0` for False, `1` for True)**. You can pass these expressions directly into the `ORDER BY` clause to control custom sorting behaviors without writing messy `CASE` statements.

### Example Problem: Pushing Chemistry and Physics Last

* *Problem Statement:* Show 1984 winners ordered alphabetically by subject and winner, but ensure that *Chemistry* and *Physics* rows are always forced to the absolute bottom of the results list.

```sql
SELECT winner, subject
FROM nobel
WHERE yr = 1984
ORDER BY 
  -- Expression evaluates to 1 if Chemistry/Physics, 0 for all other subjects.
  -- Sorting ASC places 0 (others) first, and 1 (chem/phys) last!
  subject IN ('Chemistry', 'Physics') ASC, 
  subject ASC, 
  winner ASC;

```

### Why this elite trick works:

1. The expression `subject IN ('Chemistry', 'Physics')` returns a boolean value for every row: `1` if true, `0` if false.
2. By placing it first in the `ORDER BY` clause and setting it to `ASC`:
* Rows where the expression is `0` (Peace, Literature, Medicine, etc.) are sorted to the top.
* Rows where the expression is `1` (Chemistry, Physics) are assigned a higher sort weight and pushed to the bottom.


3. Subsequent columns (`subject ASC, winner ASC`) cleanly sub-sort the items within those major groups.
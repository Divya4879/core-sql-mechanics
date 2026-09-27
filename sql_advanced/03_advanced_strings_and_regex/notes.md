# Section 3: Advanced String Functions, Regular Expressions, and Clauses - Master Guide & Architectural Patterns

---

## 🔀 Masterclass Deep Dive: String Manipulation & Pattern Matching in Backend Systems

As a Python backend engineer, you will constantly ingest raw, messy string data from external APIs, user inputs, and legacy databases. Relying solely on Python scripts to clean every single string is a performance bottleneck; doing data cleansing and pattern filtering directly at the database layer using advanced SQL string functions and regular expressions keeps your application pipelines lightning-fast.

---

## Problem-by-Problem Breakdown

---

### 1. LeetCode 1667: Fix Names in a Table

* **Problem Pattern:** String Slicing and Case Transformation (`LEFT`, `UPPER`, `LOWER`, `CONCAT`).
* **Source Context:** Users table containing names with erratic uppercase and lowercase formatting, where the goal is to standardize names so only the first letter is uppercase and the rest are lowercase.

#### 🧠 Core Concept & Intuition

String formatting requires breaking a word into two parts: the very first character and everything after it. You transform the first character to uppercase, transform the remainder to lowercase, and glue them back together.

#### ❌ Student Pitfalls & Wrong Code

Students often try to pass the entire string into `UPPER()` or get confused about how to isolate just the first character without mutating the rest of the name:

```sql
-- WRONG: Capitalizes the entire name instead of just the first letter
SELECT user_id, UPPER(name) 
FROM Users;

```

#### 🚀 Best Engineering Approach

1. **Isolate & Capitalize:** Use `LEFT(name, 1)` to grab the first character, then wrap it in `UPPER()`.
2. **Isolate & Lowercase:** Use `SUBSTRING(name, 2)` to grab everything from the second character onward, then wrap it in `LOWER()`.
3. **Concatenate:** Merge them using `CONCAT()` or the string concatenation operator.

#### ✅ Correct Code

```sql
SELECT user_id, CONCAT(UPPER(LEFT(name, 1)), LOWER(SUBSTRING(name, 2))) AS name
FROM Users
ORDER BY user_id ASC;

```

#### 📝 Detailed Explanation of Code & Logic

* **`LEFT(name, 1)`**: Extracts exactly 1 character from the left side of the `name` string.
* **`UPPER(...)`**: Forces that single character to uppercase.
* **`SUBSTRING(name, 2)`**: Starts at index 2 and extracts the remainder of the string.
* **`LOWER(...)`**: Forces all remaining characters to lowercase, correcting any accidental uppercase letters in the middle of the name.
* **`CONCAT(...)`**: Joins the capitalized first letter and the lowercase rest back into a single clean string.
* **`ORDER BY user_id ASC`**: Satisfies the requirement to sort the final presentation by user ID.

---

### 2. LeetCode 1517: Find Users With Valid E-Mails

* **Problem Pattern:** Regular Expression Validation (`REGEXP_LIKE`).
* **Source Context:** Users table containing various email strings, where the goal is to filter and return only emails that match strict structural criteria.

#### 🧠 Core Concept & Intuition: A Regex101 Guide for SQL

If you have never used Regular Expressions (Regex), think of them as a hyper-powerful pattern-matching language. Instead of searching for an exact word, you search for a *rule* (e.g., "must start with a letter, can contain dots, and must end with a specific domain").

Let's dissect the production regex pattern used for this problem: `'^[a-zA-Z][a-zA-Z0-9._-]*@leetcode\.com$'`

* **`^`**: Asserts the **start** of the string. The email must begin right here.
* **`[a-zA-Z]`**: A character class. It matches **exactly one** letter, whether lowercase (`a-z`) or uppercase (`A-Z`). *Rule:* The email *must* start with a letter, never a number or symbol.
* **`[a-zA-Z0-9._-]*`**: Matches letters, numbers, periods, underscores, or hyphens.
* `*`: A quantifier meaning **"zero or more times"** of the preceding character set. This covers the middle body of the email prefix.


* **`@`**: Matches the literal `@` symbol. It must appear immediately after the prefix.
* **`leetcode\.com`**: Matches the literal text `leetcode.com`. Notice the backslash (`\.`): in regex, a dot normally means "any character", so the backslash escapes it to mean a literal dot punctuation mark.
* **`$`**: Asserts the **end** of the string. Nothing else can follow `.com`.

#### ❌ Student Pitfalls & Wrong Code

Trying to write multiple nested `LIKE` statements with wildcards (`LIKE '%@%' AND LIKE '%.com'`), which fails to enforce structural rules like starting with a letter or forbidding invalid leading characters.

#### 🚀 Best Engineering Approach

Use the native database regex engine (`REGEXP_LIKE` in MySQL or `~` in PostgreSQL) to validate complex text rules in a single, highly optimized pass.

#### ✅ Correct Code

```sql
SELECT user_id, name, mail
FROM Users
WHERE REGEXP_LIKE(mail, '^[a-zA-Z][a-zA-Z0-9._-]*@leetcode\.com$');

```

#### 📝 Detailed Explanation of Code & Logic

* **`REGEXP_LIKE(column, pattern)`**: Evaluates every row's `mail` string against the regex pattern. If the string satisfies every rule defined in the regex string, it returns true and includes the row in the result set; otherwise, it filters it out.

---

### 3. LeetCode 1484: Group Sold Products By The Date

* **Problem Pattern:** String Aggregation (`GROUP_CONCAT` with `DISTINCT` and sorting).
* **Source Context:** Activities table tracking products sold on specific dates, where the goal is to aggregate and list all unique products sold on each date in alphabetical order.

#### 🧠 Core Concept & Intuition

Normally, aggregate functions like `SUM` or `COUNT` collapse rows into a single number. But what do you do when you need to collapse multiple text rows into a **single comma-separated string list**? You use string aggregation functions.

#### ❌ Student Pitfalls & Wrong Code

Trying to select product names alongside a standard `COUNT` without an aggregation function, which causes SQL engines to throw grouping errors or return arbitrary, truncated rows.

#### 🚀 Best Engineering Approach

Use `GROUP_CONCAT()` (MySQL) or `STRING_AGG()` (PostgreSQL) paired with `DISTINCT` to eliminate duplicate product entries on the same day, and include an internal `ORDER BY` clause to keep the final output sorted alphabetically.

#### ✅ Correct Code

```sql
SELECT 
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    GROUP_CONCAT(DISTINCT product ORDER BY product ASC) AS products
FROM Activities
GROUP BY sell_date
ORDER BY sell_date ASC;

```

#### 📝 Detailed Explanation of Code & Logic

* **`GROUP BY sell_date`**: Clusters all sales transactions into buckets based on the calendar date.
* **`COUNT(DISTINCT product)`**: Counts how many unique product names were sold on that specific day.
* **`GROUP_CONCAT(DISTINCT product ORDER BY product ASC)`**: This is the magic function. It gathers all unique product names in the bucket, sorts them alphabetically from A to Z, and concatenates them into a single string separated by commas.

---

### 4. LeetCode 196: Delete Duplicate Emails

* **Problem Pattern:** Relational Deletion via Self-Join.
* **Source Context:** Person table containing duplicate email entries, where the goal is to delete duplicate rows while preserving the unique row with the smallest ID.

#### 🧠 Core Concept & Intuition

When performing a `DELETE` operation in SQL, you cannot simply reference the table you are selecting from in a straightforward subquery without creating an intermediary wrapper. To delete duplicates, you must join the table to itself to compare records side-by-side: keeping the row with the lower ID and flagging the row with the higher ID for deletion.

#### ❌ Student Pitfalls & Wrong Code

Trying to run a subquery update directly on the target table without a derived wrapper table, which causes MySQL error codes prohibiting updates/deletes on tables being actively selected from in subqueries.

#### 🚀 Best Engineering Approach

Use a self-join where two aliases of the same table (`p1` and `p2`) match on the same email, and filter specifically where `p1.id > p2.id` (meaning `p1` is the duplicate copy with the higher ID).

#### ✅ Correct Code

```sql
DELETE p1 
FROM Person p1
JOIN Person p2 
  ON p1.email = p2.email
WHERE p1.id > p2.id;

```

#### 📝 Detailed Explanation of Code & Logic

* **`DELETE p1`**: Tells the database engine that any matching rows found in alias `p1` should be permanently deleted from the database.
* **`FROM Person p1 JOIN Person p2 ON p1.email = p2.email`**: Creates a side-by-side view where every row is paired with every other row that shares the exact same email address.
* **`WHERE p1.id > p2.id`**: Identifies the duplicate rows. If two rows share `test@example.com`, but row 1 has `id = 1` and row 2 has `id = 2`, `p1.id > p2.id` evaluates to `2 > 1` (true). Row 2 (`p1`) is targeted and deleted, while row 1 (`p2`) is preserved because its ID is smaller.

---

### 5. LeetCode 176: Second Highest Salary

* **Problem Pattern:** Offset Windowing and Scalar Subquery Null-Safety.
* **Source Context:** Employee table containing salary data, where the goal is to find the second highest distinct salary, returning `NULL` if a second highest salary does not exist.

#### 🧠 Core Concept & Intuition

Sorting and pagination clauses (`LIMIT` and `OFFSET`) are normally used to slice data chunks. Here, we use them to skip the highest salary and grab the exact row immediately below it. Wrapping the entire query in an outer scalar subquery ensures that if the table has fewer than two rows, the query safely outputs `NULL` instead of an empty result set.

#### ❌ Student Pitfalls & Wrong Code

Writing a plain query with `LIMIT 1 OFFSET 1` without the outer wrapper. If an employee table only contains 1 row, a plain `LIMIT`/`OFFSET` query returns an empty table (zero rows) instead of a clean SQL `NULL`, failing automated test assertions.

#### 🚀 Best Engineering Approach

Wrap your pagination query inside an outer scalar select statement. If the inner query evaluates to an empty set due to insufficient rows, the outer query evaluates it to `NULL` automatically.

#### ✅ Correct Code

```sql
SELECT (
    SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;

```

#### 📝 Detailed Explanation of Code & Logic

* **`DISTINCT salary`**: Removes duplicate salary figures so ties don't mess up the sequence.
* **`ORDER BY salary DESC`**: Sorts salaries from highest to lowest.
* **`LIMIT 1 OFFSET 1`**: Skips the first highest salary (`OFFSET 1`) and grabs only the very next single row (`LIMIT 1`), which is the second highest salary.
* **Outer `SELECT (...) AS SecondHighestSalary`**: Acts as a safety wrapper. If the table has 0 or 1 rows, the inner query returns empty, causing the outer wrapper to output `NULL`, satisfying the exact edge-case requirement of the problem.
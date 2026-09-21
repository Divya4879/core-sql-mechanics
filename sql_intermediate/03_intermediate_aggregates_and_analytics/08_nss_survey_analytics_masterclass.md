# Masterclass: Advanced Survey Data Analytics, Weighted Metrics & Conditional Aggregation in SQL

This guide serves as an exhaustive, pattern-driven architectural reference for handling proportional datasets, weighted aggregations, and conditional pivoting in relational databases. It focuses exclusively on advanced data manipulation patterns rather than basic equality filters.

---

## 🏗️ Understanding the Database Schema (`nss` table)
Before writing analytical queries, you must understand how survey data is structured:
* **`institution`**: The university or college name.
* **`subject`**: The academic field code (e.g., `(8) Computer Science`).
* **`question`**: The survey question identifier (e.g., `Q01`, `Q15`, `Q22`).
* **`response`**: The exact number of students who actually answered that specific question at that institution for that subject.
* **`sample`**: The total population sample size.
* **`A_STRONGLY_AGREE` / `score`**: Stored as percentages (ranging from 0 to 100), *not* absolute headcounts.

---

## 📐 Section 1: Proportional Data Scaling (Percentages to Absolute Counts)

### Topics Covered
* Proportional data manipulation
* Mathematical operations within projection lists (`SELECT`)

### Real-World Pattern / DB Problem
Converting percentage-based metrics (which save storage space and standardize ratings) back into estimated absolute headcounts for business analytics and reporting.

### Core Concept & Explanation
Because columns like `A_STRONGLY_AGREE` or `score` are stored as ratios out of 100, you cannot treat them as raw counts. To find out how many actual students contributed to that percentage, you must multiply the percentage by the absolute `response` volume and divide by 100.

### Syntax & Code Block

```sql
-- Estimating absolute student headcounts from percentage indicators grouped by subject
SELECT subject, 
       SUM(response * A_STRONGLY_AGREE / 100) AS estimated_headcount
FROM nss
WHERE question = 'Q22'
  AND subject IN ('(8) Computer Science', '(H) Creative Arts and Design')
GROUP BY subject;

```

---

## ⚖️ Section 2: Weighted Average Calculation (Avoiding the Mean-of-Means Trap)

### Topics Covered

* Aggregate functions (`SUM()`)
* Weighted mathematical modeling
* Grouped summary calculations

### Real-World Pattern / DB Problem

Calculating an accurate regional or subject-wide average score across multiple institutions of vastly different sizes without letting small colleges skew the data.

### Core Concept & Explanation

**The Trap:** Using a standard `AVG()` on a percentage column (e.g., `AVG(score)`) gives equal weight to a tiny college of 10 students and a massive university of 10,000 students.

**The Engineering Solution:** You must compute a true weighted average by multiplying each institution's score by its response weight, summing them across the group, and dividing by the total absolute response volume.

$$\text{Weighted Average} = \frac{\sum(\text{score} \times \text{response})}{\sum(\text{response})}$$

### Syntax & Code Block

```sql
-- Calculating a precise weighted satisfaction score across institutions
SELECT institution, 
       ROUND(SUM(score * response) / SUM(response), 0) AS weighted_satisfaction_score
FROM nss
WHERE question = 'Q22'
  AND institution LIKE '%Manchester%'
GROUP BY institution
ORDER BY institution;

```

---

## 🔀 Section 3: Conditional Aggregation & Inline Pivoting (`CASE WHEN` in `SUM`)

### Topics Covered

* Conditional logic (`CASE WHEN`)
* Inline row pivoting
* Multi-metric single-pass extraction

### Real-World Pattern / DB Problem

Generating a summary report where one column displays total population metrics across all categories, while a parallel column isolates a specific sub-category subset, all within a single database query pass.

### Core Concept & Explanation

If you use a traditional `WHERE` clause to filter for a sub-category, you lose the rest of your dataset's context. Conditional aggregation solves this by embedding a `CASE WHEN` statement directly *inside* an aggregate function (`SUM`). It acts as a row-level router: matching rows pass their values through, non-matching rows pass zero, and the outer `SUM` aggregates the result cleanly.

### Syntax & Code Block

```sql
-- Displaying total sample size alongside a targeted subset metric in a single pass
SELECT institution, 
       SUM(sample) AS total_sample_size, 
       SUM(CASE WHEN subject = '(8) Computer Science' THEN sample ELSE 0 END) AS computing_sample_size
FROM nss
WHERE institution LIKE '%Manchester%' 
  AND question = 'Q01'
GROUP BY institution;

```

---

## 🔍 Section 4: Advanced Filtering & Fuzzy Substring Pattern Matching

### Topics Covered

* Wildcard matching (`LIKE`)
* Substring containment (`'%Pattern%'`)
* Operator precedence control via parentheses

### Real-World Pattern / DB Problem

Querying regional data where exact string matching fails because institution names contain variable prefixes or suffixes (e.g., matching any university containing "Manchester").

### Core Concept & Explanation

Exact equality (`= 'Manchester'`) fails when a database stores compound names like `"University of Manchester"` or `"Manchester Metropolitan University"`. Using the `LIKE` operator with wildcard characters (`%`) ensures you capture any record containing the target substring. Furthermore, when mixing `AND` and `OR` logic, proper parenthesization is critical to prevent scope leakage.

### Syntax & Code Block

```sql
-- Querying regional data with safe operator precedence and fuzzy text matching
SELECT institution, score
FROM nss
WHERE question = 'Q22'
  AND institution LIKE '%Manchester%'
  AND (subject = '(8) Computer Science' OR subject = '(H) Creative Arts and Design')
GROUP BY institution;

```

---

## 🚨 Section 5: Engineering Best Practices & Anti-Patterns Checklist

* ❌ **Anti-Pattern: Aggregating Inside `WHERE**`
Never place an aggregate function (`SUM`, `COUNT`) inside a `WHERE` clause. Remember the logical execution order: `WHERE` filters raw rows *before* groups are formed. Use `HAVING` for post-group filtering.

* ⚠️ **Watch Out for Integer Division Truncation**
Be mindful of how your database engine handles integer division (dividing integers can drop remainders). Always ensure calculations preserve decimal precision by casting or structuring multiplication before division.

* ✅ **Always Use Explicit Table Aliasing and Column Naming**
Always assign meaningful aliases (`AS weighted_satisfaction_score`) to calculated expressions to maintain clean, readable API payloads and schema outputs.

* ✅ **Use Parentheses for Complex Logical Grouping**
When mixing `AND` and `OR` conditions in a `WHERE` clause, always use parentheses to explicitly control evaluation precedence and avoid unintended scope leakage.
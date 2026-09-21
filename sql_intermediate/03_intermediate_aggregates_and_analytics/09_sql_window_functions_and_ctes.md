# Masterclass: SQL Window Functions, Mental Models for Partitioning, Framing & Advanced Analytics

This guide is an exhaustive architectural reference designed to demystify window functions. It directly addresses how to systematically determine **what goes into `PARTITION BY`, `ORDER BY`, and `GROUP BY**` for any complex analytical problem, while introducing advanced window patterns (like offsets and running totals) not covered previously.

---

## 🧠 Mental Model: How to Design Any Window Clause (`OVER (...)`)

When facing a complex database problem, developers often guess which columns to put inside `PARTITION BY` and `ORDER BY`. Use this deterministic two-step framework to figure it out instantly:

### 1. The `PARTITION BY` Rule: *“Reset my calculation per...”*

* **Question to ask yourself:** *"Do I want this rank, sum, or running total to be calculated independently for every unique category/group, or across the whole table?"*
* **The Logic:** Whatever entity you want to isolate or scope your calculation to goes into `PARTITION BY`.
* *Example:* If a table has votes across multiple years and districts, and you want rank `1` **for each district in each year**, you partition by both: `PARTITION BY constituency, yr`. If you omit `yr`, the ranking will incorrectly compete 2015 data against 2017 data.



### 2. The `ORDER BY` Rule (inside `OVER`): *“Sort my window rows by...”*

* **Question to ask yourself:** *"Within that partition, what metric defines the sequence, hierarchy, or progression?"*
* **The Logic:** This determines *how* the rows are ordered to assign numbers (like ranks or row numbers).
* *Example:* To find winners, you sort by votes descending: `ORDER BY votes DESC`. To track chronological changes, you sort by date: `ORDER BY election_date ASC`.



### 3. Window Functions vs. `GROUP BY`: *When to use which?*

* **`GROUP BY` (Collapsing):** Destroys individual row identity. It summarizes 100 rows into 1 summary row. Use it when you only care about group-level totals or averages.
* **Window Functions (`OVER`):** Preserves individual row identity. It computes a calculation (like a rank or average) and attaches it as a **new column** to every existing row without collapsing them. Use it when you need row-level context *alongside* group-level analytics.

---

## 🏗️ Understanding the Database Schema (`ge` table)

Before analyzing patterns, review the underlying table structure:

* **`yr`**: The election year (`2015`, `2017`).
* **`firstName` / `lastName**`: Candidate identification details.
* **`constituency`**: The unique geographic district code where citizens vote (e.g., `S14000024`).
* **`party`**: The political affiliation of the candidate.
* **`votes`**: The absolute total count of votes received by a candidate.

---

## 📊 Section 1: Ranking Mechanics & Tie-Handling (`ROW_NUMBER` vs `RANK` vs `DENSE_RANK`)

### Topics Covered

* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`

### Real-World Pattern / DB Problem

Handling ties when multiple entities score the exact same value (e.g., two candidates tying for second place in an election).

### Core Concept & Explanation

SQL provides three core ranking functions, and choosing the wrong one breaks business logic during ties:

* **`ROW_NUMBER()`:** Assigns a unique sequential integer to every row, even if values are identical (1, 2, 3, 4). Useful for pagination or arbitrary tie-breaking.
* **`RANK()`:** Assigns the same rank to ties, but leaves **gaps** in the sequence afterward (1, 1, 3, 4).
* **`DENSE_RANK()`:** Assigns the same rank to ties with **no gaps** in the sequence (1, 1, 2, 3).

### Syntax & Code Block

```sql
-- Comparing tie-handling behaviors across ranking functions
SELECT constituency, party, votes,
       ROW_NUMBER() OVER (PARTITION BY constituency ORDER BY votes DESC) AS row_num,
       RANK() OVER (PARTITION BY constituency ORDER BY votes DESC) AS standard_rank,
       DENSE_RANK() OVER (PARTITION BY constituency ORDER BY votes DESC) AS dense_rank_pos
FROM ge
WHERE yr = 2017;

```

---

## 📐 Section 2: Basic Window Ranking & Ordering (`RANK() OVER`)

### Topics Covered

* Analytical ranking functions (`RANK()`)
* Window execution clause (`OVER`)

### Real-World Pattern / DB Problem

Ranking records within a flat dataset globally (e.g., finding the top-voted candidates across a single target district without losing individual row context).

### Core Concept & Explanation

Unlike aggregate functions which collapse rows, window functions calculate metrics across related rows while keeping every row visible. The `RANK()` function evaluates rows sorted via `ORDER BY votes DESC`, giving the highest value rank `1`.

### Syntax & Code Block

```sql
-- Ranking candidates by vote count for a specific constituency in 2017
SELECT party, votes,
       RANK() OVER (ORDER BY votes DESC) AS posn
FROM ge
WHERE constituency = 'S14000024' 
  AND yr = 2017
ORDER BY party;

```

---

## 🎯 Section 3: Scoped Partitioning (`PARTITION BY`)

### Topics Covered

* Window isolation via `PARTITION BY`
* Multi-group segmentation

### Real-World Pattern / DB Problem

Evaluating multi-year data where rankings must be calculated **independently per year and per district** rather than pooled together globally.

### Core Concept & Explanation

If you omit `PARTITION BY`, the database computes ranks across the entire table. By specifying `PARTITION BY yr, constituency`, you instruct the SQL engine to create isolated sandbox partitions for every unique year-constituency combination, resetting the rank counter to `1` for each partition.

### Syntax & Code Block

```sql
-- Ranking parties independently for each year within a specific constituency
SELECT yr, party, votes,
       RANK() OVER (PARTITION BY yr, constituency ORDER BY votes DESC) AS posn
FROM ge
WHERE constituency = 'S14000021'
ORDER BY party, yr;

```

---

## 🧱 Section 4: Filtering Window Results via Common Table Expressions (CTEs)

### Topics Covered

* Inline virtual tables (`WITH ... AS`)
* Resolving SQL Logical Execution Order constraints

### Real-World Pattern / DB Problem

Filtering rows based on calculated window ranks (e.g., *"Show me only the rank 1 district winners"*).

### Core Concept & Explanation

**The Execution Order Trap:** You **cannot** put a window function or its alias directly in a `WHERE` clause (e.g., `WHERE posn = 1` fails) because `WHERE` executes *before* window functions are evaluated in the query lifecycle.
**The Solution:** Wrap your window query in a CTE so the database computes the ranks first, allowing the outer query to filter `WHERE posn = 1` cleanly.

### Syntax & Code Block

```sql
-- Extracting strictly the winning party for each constituency using a CTE
WITH ranked_candidates AS (
    SELECT constituency, party, yr,
           RANK() OVER(PARTITION BY constituency, yr ORDER BY votes DESC) AS posn
    FROM ge
    WHERE constituency BETWEEN 'S14000021' AND 'S14000026'
      AND yr = 2017
)
SELECT constituency, party 
FROM ranked_candidates
WHERE posn = 1;

```

---

## 🔄 Section 5: Temporal & Sequential Analysis (`LAG()` and `LEAD()`)

### Topics Covered

* Offset analytical functions (`LAG()`, `LEAD()`)
* Period-over-period comparison

### Real-World Pattern / DB Problem

Comparing a row's value against the *previous* or *next* row in a sequence (e.g., calculating how many more or fewer votes a political party received in 2017 compared to 2015).

### Core Concept & Explanation

`LAG()` pulls data from a previous row within the same partition, while `LEAD()` pulls data from a subsequent row. This eliminates the need for complex self-joins when computing differences over time.

### Syntax & Code Block

```sql
-- Comparing current election votes against the previous election cycle per party/constituency
SELECT constituency, party, yr, votes,
       LAG(votes, 1) OVER (PARTITION BY constituency, party ORDER BY yr ASC) AS previous_votes,
       votes - LAG(votes, 1) OVER (PARTITION BY constituency, party ORDER BY yr ASC) AS vote_difference
FROM ge
WHERE constituency = 'S14000024';

```

---

## 📊 Section 6: Multi-Stage Pipelines (Combining Window Functions + `GROUP BY`)

### Topics Covered

* Multi-stage CTE data pipelines
* Aggregating windowed outputs

### Real-World Pattern / DB Problem

Transitioning from micro-level analysis to macro-level summaries (e.g., first ranking candidates locally inside districts, filtering for rank `1` winners, and then counting total seats won nationwide per party).

### Core Concept & Explanation

This is the ultimate pattern for advanced analytics:

1. **Stage 1 (CTE + Window):** Isolate local context and rank candidates per district.
2. **Stage 2 (CTE Filter):** Keep only the winners (`posn = 1`).
3. **Stage 3 (Outer Aggregate):** Group the winners by party and count total seats using `GROUP BY` and `COUNT()`.

### Syntax & Code Block

```sql
-- Counting total national/regional seats won per party based on local window rankings
WITH constituency_winners AS (
    SELECT constituency, party,
           RANK() OVER(PARTITION BY constituency ORDER BY votes DESC) AS posn
    FROM ge
    WHERE constituency LIKE 'S%'
      AND yr = 2017
)
SELECT party, COUNT(constituency) AS total_seats_won
FROM constituency_winners
WHERE posn = 1
GROUP BY party
ORDER BY total_seats_won DESC;

```

## SECTION 8: Regional Aggregations & Multi-Tier Seat Tallying (`GROUP BY` + Window CTEs)

### Topics Covered

* Geographic pattern matching (`LIKE 'S%'`)

* Multi-stage query decomposition (Window CTEs + Aggregations)

* Macro-level counting (`COUNT()`, `GROUP BY`)

### Real-World Pattern / DB Problem

Calculating macro-level performance metrics across a vast geographic subset (e.g., tallying total regional or national legislative seats won per political party based on individual district-level election results).

### Core Concept & Explanation

To find out how many total seats each party won in a specific region (such as Scotland, where district codes begin with `'S'`), a standard `GROUP BY` query is insufficient because raw rows contain multiple competing candidates per district.

You must execute a **multi-stage analytical pipeline**:

1. **Stage 1 (Granular Window Ranking):** Filter rows for the target year and geographic prefix (`LIKE 'S%'`), then use `RANK() OVER (PARTITION BY constituency ...)` to determine the winner of every single district independently.


2. **Stage 2 (Filtering Winners):** Wrap the window ranking in a CTE and filter strictly for local victors (`posn = 1`).


3. **Stage 3 (Macro-Aggregation):** Group the filtered winner dataset by `party` and run `COUNT(constituency)` to tally total seats won.

### Syntax & Code Block

```sql
-- Counting total regional seats won per party across all Scottish constituencies in 2017
WITH constituency_winners AS (
    SELECT constituency, party,
           RANK() OVER(PARTITION BY constituency ORDER BY votes DESC) AS posn
    FROM ge
    WHERE constituency LIKE 'S%'
      AND yr = 2017
)
SELECT party, COUNT(constituency) AS seats
FROM constituency_winners
WHERE posn = 1
GROUP BY party
ORDER BY seats DESC;
```

---

## 🚨 Section 8: Engineering Best Practices & Anti-Patterns Checklist

* ❌ **Anti-Pattern: Filtering Window Functions in `WHERE**`
Never attempt to write `WHERE RANK() OVER (...) = 1`. Window functions evaluate after the `WHERE` clause. Always wrap them in a CTE or subquery.

* ⚠️ **Watch Out for Partition Granularity Errors**
If your window results look unexpectedly large or identical across different groups, check your `PARTITION BY` columns. Missing a scoped column (like omitting `yr` in multi-year data) causes partitions to bleed together.

* ✅ **Explicitly Choose Your Tie-Breaker Function**
Always decide deliberately between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`. Using `RANK()` when you need unique sequential identifiers will cause bugs if data contains tied values.

* ✅ **Keep CTE Names Semantic**
Use clear, descriptive names for your intermediate steps (e.g., `ranked_candidates`, `constituency_winners`) instead of generic placeholders like `t1` or `sub`.
# Random SQL Drills

A curated collection of selected LeetCode Database problems solved outside the SQL50 problem set. These problems were retained because they presented an interesting challenge, required additional reasoning, or were difficult to solve independently.

The collection serves as a personal reference for revisiting challenging queries, understanding alternative approaches, and strengthening practical SQL problem-solving skills.

Each problem is stored as an individual SQL file, making the collection easy to navigate and useful for targeted revision.

## Overview

- **Source:** LeetCode Database problem set
- **Collection size:** 38 SQL solutions
- **Organisation:** Six practice batches, from `day_01` to `day_06`
- **Primary SQL dialect:** MySQL
- **Purpose:** Targeted practice, solution review, and reinforcement of SQL concepts
- **Scope:** Selected problems outside the SQL 50 set, not an exhaustive collection of LeetCode Database problems

## Repository Structure

| Directory | Problems | General Focus |
|---|---:|---|
| [`day_01`](day_01/) | 9 | Aggregation, grouping, ranking, and conditional logic |
| [`day_02`](day_02/) | 8 | Joins, filtering, date-based analysis, and ranking |
| [`day_03`](day_03/) | 8 | String manipulation, validation, and data transformation |
| [`day_04`](day_04/) | 6 | Multi-stage queries, analytical functions, and sequence analysis |
| [`day_05`](day_05/) | 4 | Event analysis, aggregation, and relational reasoning |
| [`day_06`](day_06/) | 3 | String processing, recursive relationships, and pattern analysis |
| **Total** | **38** | |

The day-based structure reflects the organisation of the original practice sessions. It is not intended to indicate problem difficulty or define a required order of study.

## Problem Index

### Day 01 — Foundational SQL Patterns

1. [LeetCode 1050 — Actors and Directors Who Cooperated At Least Three Times](day_01/problem_1050.sql)
2. [LeetCode 1179 — Reformat Department Table](day_01/problem_1179.sql)
3. [LeetCode 1407 — Top Travellers](day_01/problem_1407.sql)
4. [LeetCode 1741 — Find Total Time Spent by Each Employee](day_01/problem_1741.sql)
5. [LeetCode 177 — Nth Highest Salary](day_01/problem_177.sql)
6. [LeetCode 178 — Rank Scores](day_01/problem_178.sql)
7. [LeetCode 184 — Department Highest Salary](day_01/problem_184.sql)
8. [LeetCode 608 — Tree Node](day_01/problem_608.sql)
9. [LeetCode 627 — Swap Salary](day_01/problem_627.sql)

### Day 02 — Joins, Aggregation, and Analytical Queries

1. [LeetCode 1084 — Sales Analysis III](day_02/problem_1084.sql)
2. [LeetCode 1158 — Market Analysis I](day_02/problem_1158.sql)
3. [LeetCode 3564 — Seasonal Sales Analysis](day_02/problem_3564.sql)
4. [LeetCode 3642 — Find Books with Polarized Opinions](day_02/problem_3642.sql)
5. [LeetCode 3657 — Find Loyal Customers](day_02/problem_3657.sql)
6. [LeetCode 3705 — Find Golden Hour Customers](day_02/problem_3705.sql)
7. [LeetCode 3793 — Find Users with High Token Usage](day_02/problem_3793.sql)
8. [LeetCode 607 — Sales Person](day_02/problem_607.sql)

### Day 03 — Strings, Validation, and Data Transformation

1. [LeetCode 1795 — Rearrange Products Table](day_03/problem_1795.sql)
2. [LeetCode 3436 — Find Valid Emails](day_03/problem_3436.sql)
3. [LeetCode 3451 — Find Invalid IP Addresses](day_03/problem_3451.sql)
4. [LeetCode 3465 — Find Products with Valid Serial Numbers](day_03/problem_3465.sql)
5. [LeetCode 3580 — Find Consistently Improving Employees](day_03/problem_3580.sql)
6. [LeetCode 3601 — Find Drivers with Improved Fuel Efficiency](day_03/problem_3601.sql)
7. [LeetCode 3716 — Find Churn Risk Customers](day_03/problem_3716.sql)
8. [LeetCode 3808 — Find Emotionally Consistent Users](day_03/problem_3808.sql)

### Day 04 — Multi-Stage Queries and Relationship Analysis

1. [LeetCode 262 — Trips and Users](day_04/problem_262.sql)
2. [LeetCode 3554 — Find Category Recommendation Pairs](day_04/problem_3554.sql)
3. [LeetCode 3611 — Find Overbooked Employees](day_04/problem_3611.sql)
4. [LeetCode 3626 — Find Stores with Inventory Imbalance](day_04/problem_3626.sql)
5. [LeetCode 3764 — Most Common Course Pairs](day_04/problem_3764.sql)
6. [LeetCode 3832 — Find Users with Consistent Behavior Patterns](day_04/problem_3832.sql)

### Day 05 — Event Analysis and Aggregation

1. [LeetCode 3521 — Find Product Recommendation Pairs](day_05/problem_3521.sql)
2. [LeetCode 3586 — Find COVID Recovery Patients](day_05/problem_3586.sql)
3. [LeetCode 3673 — Find Zombie Sessions](day_05/problem_3673.sql)
4. [LeetCode 601 — Human Traffic of Stadium](day_05/problem_601.sql)

### Day 06 — Advanced SQL and Pattern Analysis

1. [LeetCode 3374 — First Letter Capitalization II](day_06/problem_3374.sql)
2. [LeetCode 3482 — Analyze Organization Hierarchy](day_06/problem_3482.sql)
3. [LeetCode 3617 — Find Students with Study Spiral Pattern](day_06/problem_3617.sql)

For each problem's query, implementation choices, and any accompanying notes, refer to its corresponding SQL file.

## SQL Concepts Practised

The collection covers a range of SQL patterns through individual problem-solving exercises.

### 1. Aggregation and Grouping

- `GROUP BY` with one or multiple columns
- Aggregate functions such as `COUNT()`, `SUM()`, and `AVG()`
- Filtering grouped results with `HAVING`
- Conditional aggregation and multi-stage summaries

### 2. Joins and Relational Reasoning

- Inner joins and outer joins
- Self-joins and relationship matching
- Identifying missing or unmatched records
- Controlling row multiplication in multi-table joins
- Choosing between joins, subqueries, and common table expressions (CTEs)

### 3. Window Functions and Ranking

- `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`
- Partitioning calculations with `PARTITION BY`
- Ranking rows within groups
- Handling ties and selecting top-ranked results
- Using `LAG()` and `LEAD()` for sequence-dependent analysis

### 4. Date and Event Analysis

- Date filtering and calendar-based categorisation
- Comparing records across time
- Analysing event sequences and intervals
- Preserving chronological relationships between records
- Applying conditions to time-dependent data

### 5. String Manipulation and Data Transformation

- String functions and conditional expressions
- Regular-expression-based validation
- Reshaping data between rows and columns
- Tokenisation and string reconstruction
- Extracting and validating structured text

These are broad areas represented in the collection, not an exhaustive list of the techniques used in every solution.

## Problem-Solving Considerations

When revisiting a solution, focus on the reasoning behind the query rather than memorising its syntax.

- **Output grain:** What does one row in the expected result represent?
- **Filtering order:** Should a condition be applied before grouping, after aggregation, or within a join?
- **Join cardinality:** Could multiple matches duplicate rows or inflate an aggregate?
- **Ranking semantics:** Should ties share a rank, or should every row receive a unique position?
- **Sequence and ordering:** Does the solution depend on chronology or a deterministic order?
- **Edge cases:** How should duplicates, missing matches, `NULL` values, and boundary dates be handled?
- **Query decomposition:** Would CTEs or subqueries make intermediate calculations easier to inspect and verify?

The relevant SQL files are the primary reference for each problem's implementation and any problem-specific observations.

## How to Use This Collection

Use these problems as active revision material.

1. **Attempt the problem independently.** Identify the required output, relevant tables, and relationships.
2. **Inspect the solution.** Trace the query from its input tables to the final result.
3. **Identify the difficult part.** Determine which SQL concept or reasoning step required the most attention.
4. **Check edge cases.** Test relevant conditions such as duplicate records, ties, missing values, and date boundaries.
5. **Re-solve later without copying.** Reconstruct the query from the problem statement and verify that the logic still makes sense.

The objective is to develop more reliable independent problem-solving skills and a clearer understanding of SQL query behaviour.

## SQL Dialect and Compatibility

The solutions primarily use **MySQL** syntax.

Features such as regular expressions, date functions, string operations, and window functions can behave differently across database engines. Some queries may need modification to run on PostgreSQL, SQL Server, SQLite, or other systems.

## Position Within Core SQL Mechanics

The sections of this repository serve complementary purposes:

- **SQL Foundations:** Core query construction and fundamental relational mechanics.
- **SQL Intermediate:** Broader SQL practice and the application of foundational concepts.
- **SQL Advanced:** Selected challenging problems focused on deeper SQL reasoning and recurring patterns.
- **Random SQL Drills:** Additional LeetCode Database problems retained for targeted practice and review.

This collection complements the structured sections; it does not replace them or claim comprehensive coverage of SQL.

## Source

Problems are drawn from the [LeetCode Database problem set](https://leetcode.com/problemset/database/).

The SQL files document the solutions developed while working through these selected problems.
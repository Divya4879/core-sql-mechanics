# Core SQL Mechanics

A structured SQL reference repository covering foundational, intermediate, and problem-driven advanced SQL concepts through notes, examples, and problem-solving patterns.

---

## 📖 Part 1: Learning Progression

This repository is organized as a progressive SQL learning path. The three sections move from core query mechanics into more involved relational querying, analytics, database behavior, and problem-driven SQL practice.

1. **🧱 SQL Foundations:** Covers the core SQL mechanics needed to construct, filter, join, aggregate, modify, and reason about relational data.

2. **🔬 SQL Intermediate:** Builds on those foundations with more involved filtering, joins, subqueries, aggregation, analytical queries, schema operations, security, transactions, and concurrency.

3. **🧠 SQL Advanced:** Applies the mechanics from the earlier sections to a selected set of harder, pattern-driven problems, primarily based on SQL50 practice and problems that required additional reasoning during problem solving.

The **Foundations** section is based primarily on the [SQLBolt](https://sqlbolt.com) curriculum, while the **Intermediate** section is based primarily on [SQLZoo](https://sqlzoo.net) practice and concepts. The **Advanced** section is primarily problem-driven and focuses on selected SQL50 problems and the query patterns involved in solving them.

---

# 🧱 Part 2: SQL Foundations

The `sql_foundations` section provides the core SQL concepts used throughout the repository. Each module contains a `concept.md` reference and a corresponding `queries.sql` file with examples.

## Module 1: Basics & Filtering (`01_basics_and_filtering/`)

Covers the basic structure of SQL queries and row-level filtering:

* `SELECT` and column projection
* `WHERE`
* Comparison and logical operators
* Sorting with `ORDER BY`
* `LIMIT` and `OFFSET`
* Basic expressions and query composition

## Module 2: Joins & NULLs (`02_joins_and_nulls/`)

Covers relationships between tables and handling missing values:

* Relational table relationships
* `INNER JOIN`
* `LEFT JOIN`
* `RIGHT JOIN`
* `FULL JOIN`
* Join conditions
* Multi-table queries
* `NULL` values
* Missing-record handling

An accompanying `sql-joins.png` diagram is included in this module.

## Module 3: Aggregates & Execution (`03_aggregates_and_execution/`)

Covers summarizing data and understanding SQL query evaluation:

* Column aliases with `AS`
* `COUNT()`
* `SUM()`
* `AVG()`
* `MAX()`
* `MIN()`
* `GROUP BY`
* `HAVING`
* Grouped and non-grouped columns
* Logical SQL query execution order

## Module 4: CRUD & Schema (`04_crud_and_schema/`)

Covers basic schema definition and data modification:

* `CREATE`
* `ALTER`
* `DROP`
* `INSERT`
* `UPDATE`
* `DELETE`
* Table definitions
* Schema changes
* `PRIMARY KEY`
* `FOREIGN KEY`
* `CHECK`
* `UNIQUE`
* Basic relational constraints

## Module 5: Advanced Topics (`05_advanced_topics/`)

Introduces query composition beyond basic filtering and aggregation:

* Subqueries
* Correlated subqueries
* `IN`
* `NOT IN`
* `UNION`
* `INTERSECT`
* `EXCEPT`

---

# 🔬 Part 3: SQL Intermediate

The `sql_intermediate` section builds on the foundation material through SQLZoo-based practice and more detailed reference guides.

It focuses on recurring SQL patterns involving filtering, joins, subqueries, aggregation, analytics, schema management, security, transactions, and concurrency.

## Module 1: Intermediate Basics & Filtering (`01_intermediate_basics_and_filtering/`)

Covers more involved filtering, expressions, functions, strings, and data transformations:

* Advanced `SELECT` and filtering patterns
* Relational and mathematical operators
* Complex predicates using `AND`, `OR`, `IN`, and `BETWEEN`
* Sorting with `ORDER BY`
* String manipulation
* `LIKE` pattern matching
* Type casting
* Null fallback patterns
* Common SQL functions
* Data transformation patterns
* Structural/self-join query patterns

### Topics Covered

* `01_core_syntax_and_advanced_filtering.md` - `SELECT` structure, projections, filtering predicates, and query mechanics.
* `02_relational_operators_and_math_functions.md` - numeric comparisons, ranges, conditional expressions, mathematical operators, and arithmetic transformations.
* `03_complex_predicates_and_sorting_mechanics.md` - compound predicates and ordering with `ORDER BY`.
* `04_advanced_string_manipulation_and_structural_joins.md` - string manipulation, `LIKE` pattern matching, and structural/self-join patterns.
* `05_essential_sql_functions_and_data_transformations.md` - common SQL functions, type casting, null fallbacks, normalization, and data transformations.

## Module 2: Intermediate Joins & NULLs (`02_intermediate_joins_and_nulls/`)

Extends relational querying into multi-table traversal, junction tables, outer joins, self-joins, and common relational pitfalls.

### Topics Covered

* `01_mastering_sql_joins_and_multi_table_queries.md` - explicit `JOIN ... ON` syntax, multi-table traversal, and relational query pitfalls.
* `02_mastering_movie_database_joins_and_aggregation.md` - junction-table patterns, relational cardinality, multi-table aggregation, and role filtering.
* `03_mastering_null_values_and_outer_joins.md` - missing data, outer join semantics, `NULL` behavior, and `COALESCE`.
* `04_mastering_self_joins_and_transit_networks.md` - self-joins, graph-style traversal, transit/network queries, and join mechanics.
* `05__joins_quiz_pitfalls.md` - common join pitfalls, assessment problems, and multi-table edge cases.

## Module 3: Intermediate Aggregates & Analytics (`03_intermediate_aggregates_and_analytics/`)

Covers subqueries, derived tables, aggregation, date/time analysis, metadata, pagination, weighted calculations, window functions, and CTE-based analytical queries.

### Topics Covered

* `01_subqueries_and_all_operator.md` - subquery patterns and the `ALL` operator.
* `02_sql_nested_select_and_subqueries_guide.md` - nested `SELECT` statements, query scoping, and subquery patterns.
* `03_derived_tables_from_subqueries_and_in_operator.md` - derived tables from `FROM`-clause subqueries and set membership with `IN`.
* `04_sql_aggregates_sum_count_group_by_guide.md` - aggregate functions, `GROUP BY`, grouping rules, and `HAVING`.
* `05_sql_date_time_and_extrema.md` - date/time values, intervals, date arithmetic, timestamp formatting, date-part extraction, and temporal extrema.
* `06_sql_metadata_and_pagination_guide.md` - schema metadata, system catalogs, metadata queries, and result-set pagination.
* `07_aggregates_quiz_pitfalls.md` - grouping errors, invalid column selections, aggregate behavior, and `NULL` handling.
* `08_nss_survey_analytics_masterclass.md` - survey-data analysis, weighted averages, proportional calculations, conditional aggregation, and multi-variable evaluation.
* `09_sql_window_functions_and_ctes.md` - `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `OVER`, `PARTITION BY`, window ordering, and CTEs.
* `10_sql_window_lag_and_covid_analytics.md` - `LAG()`, `LEAD()`, temporal comparisons, population-normalized ratios, and multi-stage CTE pipelines.

## Module 4: Intermediate CRUD & Schema (`04_intermediate_crud_and_schema/`)

Covers schema definition, constraints, data manipulation, validation, referential integrity, and a complete schema case study.

### Topics Covered

* `01_sql_ddl_schema_management_guide.md` - DDL with `CREATE`, `ALTER`, and `DROP`, schema evolution, constraints, keys, data types, and views.
* `02_sql_dml_data_manipulation_guide.md` - `INSERT`, `INSERT ... SELECT`, `UPDATE`, `DELETE`, bulk data transformation, validation, `NULL` handling, and referential integrity.
* `03_ddl_student_records_db.md` - a student-records database case study covering schema implementation and relational constraints.

## Module 5: Advanced Topics & Hacks (`05_advanced_topics_and_hacks/`)

Covers database-level topics beyond query construction, including access control, transactions, and concurrent operations.

### Topics Covered

* `01__sql_user_management_and_security_guide.md` - users, roles, privileges, `GRANT`, `REVOKE`, authentication boundaries, session management, query governance, and database security practices.
* `02__sql_transactions_and_concurrency_guide.md` - transactions, ACID properties, isolation levels, race conditions, atomic operations, row-level locking, deadlocks, serialization failures, retry strategies, and savepoints.

---

# 🧠 Part 4: SQL Advanced

The `sql_advanced` section is a problem-driven revision and practice module.

Rather than attempting to cover every advanced SQL feature, it focuses on selected problems from SQL50 and other difficult assessment-style problems where solving the query required combining several SQL mechanics or understanding a pattern that was easy to get wrong.

The notes emphasize the reasoning behind the queries, common mistakes, and the mechanics used to arrive at the solution.

## Module 1: Basic Joins (`01_basic_joins/`)

Focuses on join problems involving row preservation, self-joins, complete combinations, and relationships between multiple records.

### Topics Covered

* `CROSS JOIN`
* `INNER JOIN`
* `LEFT JOIN`
* Self-joins
* Multi-column join conditions
* Date-based joins
* Conditional aggregation after joins
* Preserving rows with no matching records
* Hierarchical relationships
* `GROUP BY` and `HAVING` after joins

### Problems Covered

* LeetCode 1661 - Average Time of Process per Machine
* LeetCode 1934 - Confirmation Rate
* LeetCode 197 - Rising Temperature
* LeetCode 1280 - Students and Examinations
* LeetCode 570 - Managers with at Least 5 Direct Reports

## Module 2: Sorting & Grouping (`02_sorting_and_grouping/`)

Focuses on grouping, aggregate filtering, and understanding the logical order of SQL query evaluation.

### Topics Covered

* Logical SQL query execution order
* `GROUP BY`
* `HAVING`
* Aggregate filtering
* Frequency counting
* `MAX()` and `NULL` behavior
* Multi-column tuple comparison
* First-occurrence grouping
* `MIN()`
* Sorting and tie handling

### Problems Covered

* LeetCode 619 - Biggest Single Number
* LeetCode 1070 - Product Sales Analysis III
* LeetCode 596 - Classes With at Least 5 Students

## Module 3: Advanced Strings & Regex (`03_advanced_strings_and_regex/`)

Focuses on string transformation, validation, aggregation, and duplicate handling.

### Topics Covered

* String slicing and transformation
* `LEFT()`
* `UPPER()`
* `LOWER()`
* `CONCAT()`
* Regular expressions
* `REGEXP_LIKE`
* `GROUP_CONCAT`
* `DISTINCT` within aggregation
* Ordered string aggregation
* Duplicate detection
* Self-join based deletion
* Scalar subqueries

### Problems Covered

* LeetCode 1667 - Fix Names in a Table
* LeetCode 1517 - Find Users With Valid E-Mails
* LeetCode 1484 - Group Sold Products By The Date
* LeetCode 196 - Delete Duplicate Emails
* LeetCode 176 - Second Highest Salary

## Module 4: Advanced Select & Joins (`04_advanced_select_and_joins/`)

Focuses on analytical queries involving window functions, running calculations, categorical reporting, and historical states.

### Topics Covered

* Window functions
* Running totals
* `SUM() OVER`
* `PARTITION BY`
* `RANK()`
* `CASE`
* `UNION`
* `UNION ALL`
* Zero-row/category preservation
* Historical state resolution
* Date-based filtering

### Problems Covered

* LeetCode 1204 - Last Person to Fit in the Bus
* LeetCode 1907 - Count Salary Categories
* LeetCode 1164 - Product Price at a Given Date

## Module 5: Aggregate Functions (`05_basic_aggregate_functions/`)

Focuses on aggregation patterns that become more involved when combined with conditions, dates, first-occurrence logic, joins, and missing data.

### Topics Covered

* `COUNT()`
* `SUM()`
* `AVG()`
* Conditional aggregation
* `CASE`
* Monthly grouping
* Date comparisons
* First-occurrence filtering
* Percentage calculations
* Floating-point division
* Date arithmetic
* Interval-based joins
* `COALESCE`
* Null-safe aggregation

### Problems Covered

* LeetCode 1193 - Monthly Transactions I
* LeetCode 1174 - Immediate Food Delivery II
* LeetCode 550 - Game Play Analysis IV
* LeetCode 1251 - Average Selling Price

## Module 6: Subqueries (`06_subqueries/`)

Focuses on multi-stage SQL problems involving subqueries, CTEs, window functions, set operations, ranking, and analytical calculations.

### Topics Covered

* Scalar subqueries
* Multi-row subqueries
* Composite tuple filtering
* `GROUP BY` and `HAVING` inside subqueries
* `CASE`
* `UNION`
* `UNION ALL`
* CTEs
* `DENSE_RANK()`
* `PARTITION BY`
* Window frames
* Rolling calculations
* Graph-style aggregation
* Deterministic tie-breaking
* Multi-stage analytical queries

### Problems Covered

* LeetCode 585 - Investments in 2016
* LeetCode 626 - Exchange Seats
* LeetCode 185 - Department Top Three Salaries
* LeetCode 1321 - Restaurant Growth
* LeetCode 602 - Friend Requests II: Who Has the Most Friends
* LeetCode 1341 - Movie Rating

### Purpose of the Advanced Section

The Advanced section is intended to develop **pattern recognition rather than solution memorization**.

Recurring patterns include:

* constructing complete combinations with `CROSS JOIN` before attaching sparse data
* using `LEFT JOIN` when unmatched rows must remain visible
* distinguishing row-level filtering from group-level filtering
* identifying first occurrences before calculating metrics
* using conditional aggregation for related metrics
* using window functions when rows must remain visible during calculations
* selecting the appropriate ranking function when ties matter
* resolving historical records at a particular point in time
* combining values from multiple columns with `UNION ALL`
* using CTEs and subqueries to separate multi-stage calculations
* handling missing values and empty result sets explicitly

The section is therefore a collection of **problem-solving patterns and worked reasoning**, rather than an exhaustive advanced SQL curriculum.

---

# ⚙️ Part 5: Recurring SQL Mechanics

Across all three sections, the repository repeatedly works with the following SQL mechanics:

* **Query Construction:** `SELECT`, projections, expressions, aliases, and filtering.
* **Predicate Logic:** comparison operators, `AND`, `OR`, `IN`, `NOT IN`, `BETWEEN`, and compound conditions.
* **Sorting & Pagination:** `ORDER BY`, `LIMIT`, `OFFSET`, and result-set pagination.
* **Relational Traversal:** joins, junction tables, multi-table relationships, outer joins, self-joins, `CROSS JOIN`, and `NULL` behavior.
* **Aggregation:** aggregate functions, `GROUP BY`, `HAVING`, conditional aggregation, and weighted calculations.
* **Subqueries:** nested queries, correlated queries, scalar subqueries, `ALL`, `IN`, and derived tables.
* **Analytical SQL:** window functions, ranking, row numbering, running totals, rolling calculations, `LAG()`, `LEAD()`, partitioning, and CTEs.
* **Date & Time:** intervals, date arithmetic, timestamp formatting, date-part extraction, temporal comparisons, and extrema.
* **String Operations:** string manipulation, pattern matching, regular expressions, normalization, and string aggregation.
* **Schema & Data Operations:** DDL, DML, constraints, keys, views, schema evolution, and referential integrity.
* **Database Behavior:** logical query execution order, metadata, transactions, isolation, locking, concurrency, and race conditions.
* **Security:** users, roles, privileges, authentication boundaries, and database access control.
* **Problem-Solving Patterns:** first-occurrence filtering, historical state resolution, ranking within groups, zero-row preservation, duplicate handling, and multi-stage query composition.

These topics represent the material currently documented in the repository; the repository does not attempt to cover every SQL feature or every database-specific implementation.

---

# 📚 Part 7: Sources

* **Foundations:** [SQLBolt](https://sqlbolt.com) - used as the primary learning source for the foundational section.
* **Intermediate:** [SQLZoo](https://sqlzoo.net) - used as the primary learning source for the intermediate section.
* **Advanced:** Primarily based on [Leetcode SQL50](https://leetcode.com/studyplan/top-sql-50) problem-solving practice and selected assessment problems. The Advanced section reorganizes difficult problems around the SQL mechanics and reasoning patterns involved in solving them.

The repository reorganizes these learning materials and problem-solving work into topic-focused notes, examples, and reference guides.

# Core SQL Mechanics

> *A structured SQL reference repository covering foundational and intermediate SQL concepts through notes, examples, and problem-solving patterns.*

---

## 📖 Part 1: Learning Progression

This repository is organized as a progressive SQL learning path. The two sections build from core query mechanics into more involved relational querying, aggregation, analytics, schema operations, and database behavior.

1. **🧱 SQL Foundations:** Covers the core SQL mechanics needed to construct, filter, join, aggregate, modify, and reason about relational data.

2. **🔬 SQL Intermediate:** Builds on those foundations with more involved filtering, joins, subqueries, aggregation, analytical queries, schema operations, security, transactions, and concurrency.

The **Foundations** section is based primarily on the [SQLBolt](https://sqlbolt.com) curriculum, while the **Intermediate** section is based primarily on [SQLZoo](https://sqlzoo.net) practice and concepts.

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
* `02_mastering_movie_database_joins_and_aggregation.md` - junction tables, relational cardinality, multi-table aggregation, and role filtering.
* `03_mastering_null_values_and_outer_joins.md` - missing data, outer joins, `NULL` behavior, and `COALESCE`.
* `04_mastering_self_joins_and_transit_networks.md` - self-joins, graph-style traversal, transit/network queries, and join mechanics.
* `05__joins_quiz_pitfalls.md` - common join pitfalls, assessment problems, and multi-table edge cases.

## Module 3: Intermediate Aggregates & Analytics (`03_intermediate_aggregates_and_analytics/`)

Covers subqueries, derived tables, aggregation, date/time analysis, metadata, pagination, weighted calculations, window functions, and CTE-based analytical queries.

### Topics Covered

* `01_subqueries_and_all_operator.md` - subquery patterns and the `ALL` operator.
* `02_sql_nested_select_and_subqueries_guide.md` - nested `SELECT` statements, query scoping, and subquery patterns.
* `03_derived_tables_from_subqueries_and_in_operator.md` - derived tables from `FROM`-clause subqueries and set membership with `IN`.
* `04_sql_aggregates_sum_count_group_by_guide.md` - aggregate functions, `GROUP BY`, grouping rules, and `HAVING`.
* `05_sql_date_time_and_extrema_guide.md` - date/time values, intervals, date arithmetic, timestamp formatting, date-part extraction, and temporal extrema.
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

# ⚙️ Part 4: Recurring SQL Mechanics

Across both sections, the repository repeatedly works with the following SQL mechanics:

* **Query Construction:** `SELECT`, projections, expressions, aliases, and filtering.
* **Predicate Logic:** comparison operators, `AND`, `OR`, `IN`, `NOT IN`, `BETWEEN`, and compound conditions.
* **Sorting & Pagination:** `ORDER BY`, `LIMIT`, `OFFSET`, and result-set pagination.
* **Relational Traversal:** joins, junction tables, multi-table relationships, outer joins, self-joins, and `NULL` behavior.
* **Aggregation:** aggregate functions, `GROUP BY`, `HAVING`, conditional aggregation, and weighted calculations.
* **Subqueries:** nested queries, correlated queries, `ALL`, `IN`, and derived tables.
* **Analytical SQL:** window functions, ranking, row numbering, `LAG()`, `LEAD()`, partitioning, and CTEs.
* **Date & Time:** intervals, date arithmetic, timestamp formatting, date-part extraction, temporal comparisons, and extrema.
* **Schema & Data Operations:** DDL, DML, constraints, keys, views, schema evolution, and referential integrity.
* **Database Behavior:** logical query execution order, metadata, transactions, isolation, locking, concurrency, and race conditions.
* **Security:** users, roles, privileges, authentication boundaries, and database access control.

These topics represent the material currently documented in the repository; the repository does not attempt to cover every SQL feature or every database-specific implementation.

---

# 🗺️ Repository Structure

```text
core-sql-mechanics/

├── sql_foundations/
│   ├── 01_basics_and_filtering/
│   ├── 02_joins_and_nulls/
│   ├── 03_aggregates_and_execution/
│   ├── 04_crud_and_schema/
│   └── 05_advanced_topics/
│
└── sql_intermediate/
    ├── 01_intermediate_basics_and_filtering/
    ├── 02_intermediate_joins_and_nulls/
    ├── 03_intermediate_aggregates_and_analytics/
    ├── 04_intermediate_crud_and_schema/
    └── 05_advanced_topics_and_hacks/
```

---

# 📚 Sources

* **Foundations:** [SQLBolt](https://sqlbolt.com) - used as the primary learning source for the foundational section.
* **Intermediate:** [SQLZoo](https://sqlzoo.net) - used as the primary learning source for the intermediate section.

The repository reorganizes these learning materials into topic-focused notes, examples, and reference guides.
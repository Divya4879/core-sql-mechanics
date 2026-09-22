# SQL Intermediate: Technical Reference Manual & Study Curriculum

> *A structured technical reference library and curriculum bridging foundational SQL concepts with intermediate analytics, relational querying, schema management, and production database engineering patterns.*

---

## 📖 Part 1: Curriculum Progression

This repository is structured as a progressive learning path. Rather than treating SQL as isolated syntax tricks, the curriculum follows a logical engineering arc:

1. **Foundational Filtering & Transformations (Module 1):** Establishes clean query habits, predicate logic, sorting, string manipulation, pattern matching, built-in functions, type conversion, and practical data transformations.

2. **Relational Modeling & Joins (Module 2):** Covers multi-table queries, explicit ANSI join chains, junction-table relationships, outer join semantics, `NULL` handling, self-joins, transit/network traversal, and common relational mapping pitfalls.

3. **Subqueries, Aggregates & Analytics (Module 3):** Covers scalar and nested subqueries, the `ALL` and `IN` operators, derived tables, aggregate functions (`SUM()`, `COUNT()`, `AVG()`, `MIN()`, `MAX()`), `GROUP BY`, `HAVING`, date/time operations, metadata and pagination, weighted analytics, window functions (`ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()`, `OVER`, `PARTITION BY`), CTEs (`WITH`), and practical analytical query pipelines.

4. **Schema Management & CRUD Operations (Module 4):** Covers DDL (`CREATE`, `ALTER`, `DROP`), schema evolution, constraints, primary keys, foreign keys, composite keys, `NOT NULL`, `DEFAULT`, data types, views, DML (`INSERT`, `INSERT ... SELECT`, `UPDATE`, `DELETE`), bulk data transformation, `NULL` handling, validation, referential integrity, and practical schema implementation.

5. **Security, Concurrency & Transactions (Module 5):** Covers database users and roles, privileges, password management, least-privilege security, cross-schema/database navigation, session context, process management, query termination and timeouts, connection-pool state, transactions (`BEGIN`, `COMMIT`, `ROLLBACK`), ACID, isolation levels, concurrency, race conditions, lost updates, atomic operations, row-level locking (`SELECT ... FOR UPDATE`), deadlocks, serialization failures, retry strategies, savepoints, and production database security/resilience patterns.

---

## ⚙️ Part 2: Engineering Standards & Query Habits

The reference guides in this repository emphasize professional query practices designed to prevent common errors and performance anti-patterns:

* **Explicit ANSI Join Syntax:** Strict use of explicit `JOIN ... ON` clauses rather than legacy implicit comma joins.

* **Index-Aware Querying:** Awareness of how query structure impacts database execution plans, including the effect of function wrappers and leading wildcards on index utilization.

* **Modular CTE Pipelines:** Leveraging Common Table Expressions (`WITH ... AS`) to break complex, multi-stage analytical queries into readable, testable, modular steps.

* **Defensive Data Handling:** Proactive management of `NULL` propagation traps (`IS NULL` vs `=`), floating-point and rounding considerations, type compatibility, and referential integrity rules across relational boundaries.

---

## 🗺️ Part 3: Repository Structure & Module Mapping

```text
sql_intermediate/

├── 01_intermediate_basics_and_filtering/

├── 02_intermediate_joins_and_nulls/

├── 03_intermediate_aggregates_and_analytics/

├── 04_intermediate_crud_and_schema/

└── 05_advanced_topics_and_hacks/
```

### Module 1: Basics and Filtering (`01_intermediate_basics_and_filtering/`)

1. `01_core_syntax_and_advanced_filtering.md` : Basic `SELECT` structures, projections, filtering predicates, and foundational query mechanics.

2. `02_relational_operators_and_math_functions.md` : Numeric comparisons, ranges, conditional expressions, mathematical operators, and arithmetic transformations.

3. `03_complex_predicates_and_sorting_mechanics.md` : Multi-condition filtering (`AND`, `OR`, `IN`, `BETWEEN`) and sorting pipelines (`ORDER BY`).

4. `04_advanced_string_manipulation_and_structural_joins.md` : Pattern matching with wildcards (`LIKE`), string manipulation, and structural/self-join query patterns.

5. `05_essential_sql_functions_and_data_transformations.md` : High-frequency built-in SQL functions, type casting, null fallbacks, string normalization, and practical data transformations.

### Module 2: Joins and Nulls (`02_intermediate_joins_and_nulls/`)

1. `01_mastering_sql_joins_and_multi_table_queries.md` : Explicit join syntax (`INNER JOIN`), multi-table bridge traversal chains, and common relational query pitfalls.

2. `02_mastering_movie_database_joins_and_aggregation.md` : Junction-table patterns, relational cardinality, multi-table aggregation, and role filtering.

3. `03_mastering_null_values_and_outer_joins.md` : Managing missing data, outer joins (`LEFT`/`RIGHT JOIN`), and fallback patterns with `COALESCE`.

4. `04_mastering_self_joins_and_transit_networks.md` : Self-joins, graph traversal, network routing, and join execution mechanics.

5. `05__joins_quiz_pitfalls.md` : Common relational pitfalls, quiz breakdowns, and edge cases in multi-table queries.

### Module 3: Aggregates and Analytics (`03_intermediate_aggregates_and_analytics/`)

1. `01_subqueries_and_all_operator.md` : Scalable subquery patterns and the behavior of the `ALL` operator.

2. `02_sql_nested_select_and_subqueries_guide.md` : Multi-layered query nesting, correlated/uncorrelated query concepts, and data scoping.

3. `03_derived_tables_from_subqueries_and_in_operator.md` : Virtual inline tables, `FROM`-clause subqueries, and set membership with `IN`.

4. `04_sql_aggregates_sum_count_group_by_guide.md` : Aggregate functions, grouping rules, `SUM()`, `COUNT()`, `AVG()`, `MIN()`, `MAX()`, and post-aggregation filtering with `HAVING`.

5. `05_sql_date_time_and_extrema_guide.md` : Date/time data, calendar intervals, date arithmetic, timestamp formatting, date-part extraction, and temporal extrema.

6. `06_sql_metadata_and_pagination_guide.md` : Schema discovery, system catalogs, metadata extraction, and result-set pagination.

7. `07_aggregates_quiz_pitfalls.md` : Troubleshooting grouping errors, invalid column selections, aggregate behavior, and `NULL` handling.

8. `08_nss_survey_analytics_masterclass.md` : Complex survey dataset analysis, weighted averages, proportional calculations, conditional aggregation, and multi-variable evaluation.

9. `09_sql_window_functions_and_ctes.md` : Modern analytic syntax, `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, window partitioning, `OVER`, `PARTITION BY`, and Common Table Expressions.

10. `10_sql_window_lag_and_covid_analytics.md` : Advanced `LAG()` and `LEAD()` analysis, temporal comparisons, population-normalized ratios, and multi-stage CTE pipelines.

### Module 4: CRUD and Schema (`04_intermediate_crud_and_schema/`)

1. `01_sql_ddl_schema_management_guide.md` : Data Definition Language (`CREATE`, `ALTER`, `DROP`), schema evolution, constraints, keys, data types, and views.

2. `02_sql_dml_data_manipulation_guide.md` : Data Manipulation Language (`INSERT`, `INSERT ... SELECT`, `UPDATE`, `DELETE`), bulk data transformation, validation, `NULL` handling, and referential integrity.

3. `03_ddl_student_records_db.md` : Complete schema implementation case study building a student records database from scratch.

### Module 5: Advanced Topics and Hacks (`05_advanced_topics_and_hacks/`)

1. `01__sql_user_management_and_security_guide.md` : User provisioning, authentication boundaries, roles, privilege control (`GRANT`, `REVOKE`), session management, query governance, and production security practices.

2. `02__sql_transactions_and_concurrency_guide.md` : Transactions and ACID, isolation levels, race conditions, atomic operations, row-level locking, deadlocks, serialization failures, retry strategies, and savepoints.
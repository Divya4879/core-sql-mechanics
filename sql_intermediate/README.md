# SQL Intermediate: Technical Reference Manual & Study Curriculum

> *A structured technical reference library and curriculum bridging foundational SQL concepts with advanced analytics, window functions, and relational database design patterns.*

---

## 📖 Part 1: Curriculum Progression

This repository is structured as a progressive learning path. Rather than treating SQL as isolated syntax tricks, the curriculum follows a logical engineering arc:

1. **Foundational Filtering & Transformations (Module 1):** Establishes clean query habits, predicate logic, safe string manipulations, and pattern matching.

2. **Relational Modeling & Joins (Module 2):** Covers multi-table graph traversals, explicit ANSI join chains, outer join semantics, self-joins for transit networks, and resolving relational mapping pitfalls.

3. **Advanced Analytics & Time-Series Engineering (Module 3):** Explores subquery pipelines, grouped aggregations, window functions (`RANK()`, `WITH temp_table AS(), ()`, `LAG()`, `LEAD()`), temporal date arithmetic, sparse telemetry handling with temporal joins, and multi-tier CTE architectures.

4. **Schema Management & CRUD Operations (Module 4):** Examines Data Definition Language (DDL) and Data Manipulation Language (DML) primitives to build complete transactional databases from scratch.

5. **Security, Concurrency & Transactions (Module 5):** Covers administrative control, user provisioning, ACID compliance, session isolation levels, and race-condition prevention in concurrent environments.

---

## ⚙️ Part 2: Engineering Standards & Query Habits

The reference guides in this repository emphasize professional query practices designed to prevent common errors and performance anti-patterns:

* **Explicit ANSI Join Syntax:** Strict use of explicit `JOIN ... ON` clauses rather than legacy implicit comma joins.

* **Index-Aware Querying:** Awareness of how query structure impacts database execution plans (e.g., avoiding function wrappers on indexed columns that trigger full table scans).

* **Modular CTE Pipelines:** Leveraging Common Table Expressions (`WITH ... AS`) to break complex, monolithic multi-stage queries into readable, testable, modular steps.

* **Defensive Data Handling:** Proactive management of null propagation traps (`IS NULL` vs `=`), floating-point rounding precision, and strict referential integrity rules across relational boundaries.

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

* `01_core_syntax_and_advanced_filtering.md` : Basic `SELECT` structures, projections, and filtering predicates.

* `02_relational_operators_and_math_functions.md` : Working with numeric ranges, conditional logic, and mathematical operators.

* `03_complex_predicates_and_sorting_mechanics.md` : Multi-condition filtering (`AND`, `OR`, `IN`, `BETWEEN`) and sorting pipelines (`ORDER BY`).

* `04_advanced_string_manipulation_and_structural_joins.md` : Pattern matching with wildcards (`LIKE`) and string manipulation patterns.

* `05_essential_sql_functions_and_data_transformations.md` : High-frequency built-in SQL functions, type casting, null fallbacks, and index-safe case normalization.

### Module 2: Joins and Nulls (`02_intermediate_joins_and_nulls/`)

* `01_mastering_sql_joins_and_multi_table_queries.md` : Explicit join syntax (`INNER JOIN`), multi-table "bridge" traversal chains, and the "Own-Goal Trap".

* `02_mastering_movie_database_joins_and_aggregation.md` : Junction table patterns, relational cardinality, and role filtering (`ord`).

* `03_mastering_null_values_and_outer_joins.md` : Managing missing data, outer joins (`LEFT`/`RIGHT JOIN`), and fallback patterns with `COALESCE`.

* `04_mastering_self_joins_and_transit_networks.md` : Graph traversal, network routing, and self-join execution mechanics.

* `05__joins_quiz_pitfalls.md` : Common relational pitfalls, quiz breakdowns, and edge cases in multi-table queries.

### Module 3: Aggregates and Analytics (`03_intermediate_aggregates_and_analytics/`)

* `01_subqueries_and_all_operator.md` : Scalable subquery patterns and the strict behavior of the `ALL` operator.

* `02_sql_nested_select_and_subqueries_guide.md` : Multi-layered query nesting and data scoping.

* `03_derived_tables_from_subqueries_and_in_operator.md` : Virtual inline tables, `FROM`-clause subqueries, and set membership with `IN`.

* `04_sql_aggregates_sum_count_group_by_guide.md` : Summarization engines, grouping rules, and post-aggregation filtering (`HAVING`).

* `05_sql_date_time_and_extrema_guide.md` : Calendar intervals, date arithmetic, timestamp formatting, and boundary extraction.

* `06_sql_metadata_and_pagination_guide.md` : Schema discovery, system catalogs, metadata extraction, and result set pagination.

* `07_aggregates_quiz_pitfalls.md` : Troubleshooting grouping errors, invalid column selections, and null aggregate behaviors.

* `08_nss_survey_analytics_masterclass.md` : Complex survey dataset analysis, weighted averages, and multi-variable evaluation.

* `09_sql_window_functions_and_ctes.md` : Modern analytic syntax, partition bounding, row numbering, and Common Table Expressions.

* `10_sql_window_lag_and_covid_analytics.md` : Advanced window `LAG()`, temporal joins for sparse time-series, population-normalized ratios, and multi-tier CTE pipelines (`Turning the Corner`).

### Module 4: CRUD and Schema (`04_intermediate_crud_and_schema/`)

* `01_sql_ddl_schema_management_guide.md` : Data Definition Language (`CREATE`, `ALTER`, `DROP`, indexes, and views).

* `02_sql_dml_data_manipulation_guide.md` : Data Manipulation Language (`INSERT`, `UPDATE`, `DELETE`, and transaction boundaries).

* `03_ddl_student_records_db.md` : Complete schema implementation case study building a student records database from scratch.

### Module 5: Advanced Topics and Hacks (`05_advanced_topics_and_hacks/`)

* `01__sql_user_management_and_security_guide.md` : User provisioning, authentication boundaries, and privilege control (`GRANT`, `REVOKE`).

* `02__sql_transactions_and_concurrency_guide.md` : ACID compliance, session isolation levels, lock management, and race condition prevention.
# SQL Foundations

A quick reference guide and revision tool for core SQL concepts and relational database basics. 

This repository is adapted from the interactive curriculum at [SQLBolt](https://sqlbolt.com). It reorganizes the foundational lessons into a structured, easily searchable format designed for fast revision and getting the basics right. 

---

## 📂 Repository Structure

To make revision straightforward, each module is split into two files:

* **`concept.md`:** The conceptual notes. Covers the syntax, rules, and execution order for a quick read.
* **`queries.sql`:** The practical examples. Executable `.sql` scripts that demonstrate the concepts in action using a simple, unified E-Commerce schema.

---

## 📚 Modules

### Module 1: SQL Basics & Filtering
* Retrieving data (`SELECT`)
* Row-level filtering (`WHERE`)
* Sorting and pagination (`ORDER BY`, `LIMIT`, `OFFSET`)

### Module 2: Relational Data Mapping (Joins)
* Multi-table queries and normalization
* Inner and Outer Joins (`LEFT`, `RIGHT`, `FULL`)
* Handling and testing for `NULL` values

### Module 3: Aggregations & Execution Order
* Inline expressions and aliasing (`AS`)
* Aggregate functions (`COUNT`, `SUM`, `AVG`, `MAX`, `MIN`)
* Grouping data and post-aggregation filtering (`GROUP BY`, `HAVING`)
* The 8-step SQL query execution pipeline

### Module 4: Schema Operations (CRUD)
* Data Definition (DDL): `CREATE`, `ALTER`, and `DROP` tables
* Data Manipulation (DML): `INSERT`, `UPDATE`, and `DELETE` records safely
* Basic table constraints (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`)

### Module 5: Advanced Queries
* Subqueries and Correlated Subqueries
* Dynamic existence testing (`IN`, `NOT IN`)
* Set operations (`UNION`, `INTERSECT`, `EXCEPT`)

---

## 🚀 Usage

The `.sql` files are written as standalone scripts that can be executed to see the queries in action. They are compatible with most standard SQL engines (SQLite, PostgreSQL, MySQL).

If you want to run them locally using SQLite:

```bash
# Initialize the schema and populate the tables
sqlite3 database.db < 04_crud_and_schema/queries.sql

# Run advanced queries against the seeded data
sqlite3 database.db < 05_advanced_queries/queries.sql

```

> **Credit:** All core concepts and learning progressions in this repository are based on the curriculum provided by [SQLBolt](https://sqlbolt.com).

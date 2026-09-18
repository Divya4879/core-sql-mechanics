# Core SQL Mechanics

A pragmatic, no-nonsense reference guide for SQL. 

I built this repository to serve as my personal go-to resource for interview revision and everyday backend development. It traces the full learning arc—starting from foundational basics (housed in the `sql_foundations` directory) and expanding through targeted practice on SQLZoo and LeetCode to master intermediate mechanics and complex logic.

There are no bloated tutorials or generic `foo/bar` examples here. Just clean concepts, exact syntax, and runnable scripts documenting real-world problem-solving.

---

## 🎯 Why This Exists

When writing complex queries, I found myself constantly looking up the exact syntax for self-joins, window functions, or how to handle date-time formatting. I also needed a dedicated place to store the specific logic patterns and tricky edge cases I got stuck on. This repo is designed for quick scanning, accurate syntax, and preserving the solutions to difficult queries.

---

## 📂 Repository Structure

Every module in this repository is split into two core files:
* **`concept.md`:** The theory, syntax rules, and "gotchas" for quick mental refreshers.
* **`queries.sql`:** Executable, real-world examples. Tricky patterns and complex problem breakdowns (like SQLZoo Assessments) are integrated directly into these files under their relevant topics rather than isolated in separate folders.

---

## ✅ Phase 1: The Foundations (Completed)

These modules cover the structural backbone of SQL and are located in the `sql_foundations` directory:

* **`01_basics_and_filtering`:** Projections (`SELECT`), row-level filtering (`WHERE`), and sorting/pagination (`ORDER BY`, `LIMIT`).
* **`02_joins_and_nulls`:** Database normalization, `INNER JOIN`, `LEFT/RIGHT JOIN`, and handling `NULL` records.
* **`03_aggregates_and_execution`:** Grouping data (`GROUP BY`), aggregate functions (`SUM`, `COUNT`, `AVG`), filtering groups (`HAVING`), and the 8-step execution pipeline.
* **`04_crud_and_schema`:** DDL (`CREATE`, `ALTER`, `DROP`), DML (`INSERT`, `UPDATE`, `DELETE`), and constraints.
* **`05_advanced_topics`:** Subqueries, Set Operations (`UNION`, `INTERSECT`).

---

## 🚧 Phase 2: Problem Solving & Pattern Recognition (Work in Progress)

This is the living part of the repository. It's a learning log of my ongoing practice and logic building, currently based on SQLZoo.

This section is dedicated to deepening my understanding of SQL mechanics by documenting the specific problems, edge cases, and logic traps that challenge me, whether they arise in advanced topics or unexpectedly tricky `SELECT` queries.

As I work through assessments and custom problems, I am building out this section to include:

* **Query Deconstruction:** Breaking down difficult, multi-step constraints into readable, maintainable logic.
* **Edge Cases & Gotchas:** Documenting syntax quirks, data type mismatches, and unexpected engine behaviors I encounter in the wild.
* **Pattern Mastery:** Building a personal catalog of solutions for recurring tricky scenarios, to be added dynamically as I solve them.

---

## 🛠 Usage

The `.sql` files are written to be dialect-agnostic (standard PostgreSQL/MySQL syntax). You can read them directly on GitHub or pipe them into a local database instance to test the logic yourself.

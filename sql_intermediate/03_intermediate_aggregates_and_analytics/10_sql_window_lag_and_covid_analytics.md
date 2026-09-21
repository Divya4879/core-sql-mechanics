# Masterclass: Time-Series Window Analytics, `LAG()` Offsets, and Multi-Tier CTE Pipelines in SQL

This guide serves as an exhaustive, pattern-driven architectural reference for handling time-series telemetry, sequence offsets, temporal deltas, and multi-stage analytical pipelines in relational databases. It is built around real-world epidemiological dataset patterns to provide production-grade mastery of window functions.

---

## 🏗️ Understanding the Database Schema (`covid` & `world` tables)

Before writing analytical time-series queries, you must understand how the underlying datasets are structured:

* **`covid` table**:
* **`name`**: Country or region name.
* **`whn`**: The specific timestamp or date of the telemetry record.
* **`confirmed`**: Cumulative total of confirmed positive cases.
* **`deaths`**: Cumulative total of recorded deaths.
* **`recovered`**: Cumulative total of recoveries.


* **`world` table**:
* **`name`**: Country name (used for relational joins).
* **`population`**: Total national population size (used for per-capita normalization).



---

## 📋 Section 1: Time-Series Scoping & Temporal Filtering

### Topics Covered

* Date extraction functions (`MONTH()`, `YEAR()`, `DAY()`)
* String formatting for dates (`DATE_FORMAT()`)
* Weekday filtering (`WEEKDAY()`)

### Real-World Pattern / DB Problem

Extracting specific temporal windows (e.g., analyzing only a single month of telemetry like March 2020) or filtering rows by specific periodic cadences (e.g., pulling only records from Mondays to smooth out weekend reporting anomalies).

### Core Concept & Explanation

Time-series data is notoriously noisy due to administrative reporting schedules (such as lower data throughput on weekends). Database engines provide native date functions to isolate precise temporal ranges or cadence markers without needing complex programmatic preprocessing.

### Syntax & Code Block

```sql
-- Filtering cumulative data for a specific country within a specific month and year
SELECT name, DAY(whn), confirmed, deaths, recovered
FROM covid
WHERE name = 'Spain'
  AND MONTH(whn) = 3 
  AND YEAR(whn) = 2020
ORDER BY whn;

-- Filtering time-series data to view weekly snapshots (Mondays only: WEEKDAY = 0)
SELECT name, DATE_FORMAT(whn, '%Y-%m-%d') AS formatted_date, confirmed
FROM covid
WHERE name = 'Italy'
  AND WEEKDAY(whn) = 0
  AND YEAR(whn) = 2020
ORDER BY whn;

```

---

## 🔄 Section 2: The Mechanics of the `LAG()` Offset Function

### Topics Covered

* Analytical offset function (`LAG()`)
* Window partitioning and sequencing (`PARTITION BY`, `ORDER BY`)
* Handling boundary `NULL` values

### Real-World Pattern / DB Problem

Accessing values from a preceding row in a time-series sequence (e.g., looking at yesterday's cumulative count alongside today's count) to perform delta or trend analysis.

### Core Concept & Explanation

The `LAG(column, offset)` function allows a row to "look back" at a previous row within the same partition.

* **`PARTITION BY name`**: Ensures calculations for Italy do not cross over into Spain's data.
* **`ORDER BY whn`**: Chronologically sequences the records so "previous" reliably means "yesterday".
* **First Row Behavior**: The very first row in a partition has no predecessor, so `LAG()` defaults to returning `NULL`.

### Syntax & Code Block

```sql
-- Pulling confirmed cases from the preceding day using LAG()
SELECT name, DAY(whn), confirmed,
       LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS previous_day_confirmed
FROM covid
WHERE name = 'Italy'
  AND MONTH(whn) = 3 
  AND YEAR(whn) = 2020
ORDER BY whn;

```

---

## 📉 Section 3: Deriving Cumulative Deltas (Calculating New Daily Events)

### Topics Covered

* Subtracting window offset values from current row attributes
* Transforming cumulative telemetry into discrete daily metrics

### Real-World Pattern / DB Problem

Many datasets store metrics as cumulative totals (running sums) rather than discrete daily occurrences. To analyze daily spikes or trends, you must calculate the delta between consecutive rows.

### Core Concept & Explanation

By subtracting the value returned by `LAG(confirmed)` from the current row's `confirmed` value, you instantly strip away the cumulative buildup to isolate the **new cases reported on that specific day**.

### Syntax & Code Block

```sql
-- Calculating discrete daily new cases by subtracting yesterday's cumulative total from today's
SELECT name, DAY(whn), 
       confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new_cases
FROM covid
WHERE name = 'Italy'
  AND MONTH(whn) = 3 
  AND YEAR(whn) = 2020
ORDER BY whn;

```

---

## 🔗 Section 4: Alternative Approaches — Temporal Joins vs. Window `LAG()`

### Topics Covered

* Self-joins with date arithmetic (`DATE_ADD`, `INTERVAL`)
* Handling missing telemetry dates in time series

### Real-World Pattern / DB Problem

Comparing weekly or interval metrics when rows might be missing from the database (e.g., if a country skipped reporting on a Monday, a window `LAG()` would grab Sunday instead, whereas a temporal join can look specifically for an exact week-prior date match).

### Core Concept & Explanation

While window functions like `LAG()` are cleaner and faster for contiguous sequences, joining a table to itself using explicit date arithmetic (`DATE_ADD`) allows you to bridge structural gaps in sparse telemetry data.

### Syntax & Code Block

```sql
-- Calculating weekly new cases using a temporal left join with date arithmetic
SELECT tw.name, DATE_FORMAT(tw.whn, '%Y-%m-%d') AS week_date,
       tw.confirmed - lw.confirmed AS weekly_new_cases
FROM covid tw 
LEFT JOIN covid lw ON DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn
                  AND tw.name = lw.name
WHERE tw.name = 'Italy'
  AND WEEKDAY(tw.whn) = 0
ORDER BY tw.whn;

```

---

## 🏆 Section 5: Multi-Metric Competitive Ranking (`RANK() OVER`)

### Topics Covered

* Simultaneous multi-column ranking
* Global sorting and ordering partitions

### Real-World Pattern / DB Problem

Evaluating entities across multiple competing dimensions on a specific date (e.g., ranking countries globally by confirmed cases while simultaneously ranking them by total deaths).

### Core Concept & Explanation

You can invoke multiple window ranking functions within a single `SELECT` projection list, each operating under its own independent `ORDER BY` clause, allowing you to establish multi-variable leaderboards instantly.

### Syntax & Code Block

```sql
-- Ranking countries globally by confirmed cases and deaths concurrently on a target date
SELECT name,
       confirmed,
       RANK() OVER (ORDER BY confirmed DESC) AS confirmed_rank,
       deaths,
       RANK() OVER (ORDER BY deaths DESC) AS death_rank
FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC;

```

---

## 📐 Section 6: Population-Normalized Rate Calculations & Ratios

### Topics Covered

* Relational table joining (`JOIN ON`)
* Per-capita standardization formulas (`(metric / population) * multiplier`)
* Filtering large-scale subsets (`POPULATION > threshold`)

### Real-World Pattern / DB Problem

Comparing metrics across entities of wildly different sizes (e.g., comparing raw case numbers between China and a small European nation is misleading; you must normalize the data per 100,000 citizens).

### Core Concept & Explanation

By joining your telemetry table (`covid`) with a metadata entity table (`world`), you can dynamically compute per-capita rates, round decimal outputs for readability, and rank entities based on density-adjusted impact rather than raw volume.

### Syntax & Code Block

```sql
-- Calculating infection rates per 100,000 residents for countries with over 10M population
SELECT covid.name,
       ROUND(100000 * covid.confirmed / world.population, 2) AS infection_rate_per_100k,
       RANK() OVER (ORDER BY 100000 * covid.confirmed / world.population DESC) AS rate_rank
FROM covid
JOIN world ON covid.name = world.name
WHERE covid.whn = '2020-04-20'
  AND world.population > 10000000
ORDER BY world.population DESC;

```

---

## 🚀 Section 7: Advanced Multi-Tier CTE Pipelines (`Turning the Corner`)

### Topics Covered

* Multi-CTE data pipelines (`WITH cte1 AS (...), cte2 AS (...)`)
* Aggregating windowed intermediate results (`MAX()`, `GROUP BY`)
* Post-aggregation conditional filtering (`HAVING`)

### Real-World Pattern / DB Problem

Finding complex milestones across massive datasets, such as identifying the exact peak date and maximum daily new case count for every country that ever crossed a specific threshold (e.g., finding countries with at least 20,000 new cases in a single day).

### Core Concept & Explanation

This represents the pinnacle of modern SQL data engineering. It requires a multi-stage architecture:

1. **Stage 1 (`daily_cases` CTE):** Use window `LAG()` partitioned by country to calculate discrete daily new cases.
2. **Stage 2 (`peak_values` CTE):** Take the output of Stage 1, group by country, find the absolute maximum new case count using `MAX()`, and filter out countries that never reached the threshold using `HAVING MAX(new_cases) >= 20000`.
3. **Stage 3 (Final Projection):** Join or match back to extract the corresponding calendar date (`whn`) when that peak occurred.

### Syntax & Code Block

```sql
-- Finding the peak date and peak volume for countries exceeding 20,000 daily new cases
WITH daily_cases AS (
    SELECT name, whn,
           confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) AS new_cases
    FROM covid
),
peak_values AS (
    SELECT name, MAX(new_cases) AS peak_cases
    FROM daily_cases
    GROUP BY name
    HAVING MAX(new_cases) >= 20000
)
SELECT p.name, 
       DATE_FORMAT(d.whn, '%Y-%m-%d') AS peak_date, 
       p.peak_cases
FROM peak_values p
JOIN daily_cases d ON p.name = d.name AND p.peak_cases = d.new_cases
ORDER BY p.peak_cases DESC;

```

---

## 🚨 Section 8: Engineering Best Practices & Anti-Patterns Checklist

* ❌ **Anti-Pattern: Ignoring Engine-Specific Date Bugs (MariaDB / SQL Server)**
* *Note:* When working with certain database engines (like MariaDB) on temporal window queries, strict SQL modes can throw syntax errors or trigger known parsing bugs (e.g., MariaDB bug MDEV-23866). Always ensure compatibility settings or ANSI mode are declared if required, or test against robust ANSI-compliant engines.


* ⚠️ **Watch Out for `NULL` Propagation in Deltas**
* The first row of any window partition returns `NULL` for `LAG()`. Subtracting `NULL` from a cumulative count (`confirmed - NULL`) will yield `NULL` for the first day. Always account for initial-day telemetry handling in your application logic.


* ✅ **Prefer Window `LAG()` Over Self-Joins for Contiguous Sequences**
* When your time series has no missing dates, window functions (`LAG()`, `LEAD()`) execute significantly faster and with cleaner syntax than self-joining a table onto itself. Use self-joins *only* when dealing with sparse or gapped datasets.


* ✅ **Decompose Complex Analytics into Semantic CTE Stages**
* Never write monolithic, nested subqueries. If you are calculating window offsets, aggregating maximums, and filtering thresholds simultaneously, break your code down into clean, self-documenting CTE stages (`daily_cases`, `peak_values`).
# SQL Date, Time & Extrema Guide: Fundamentals to Modern Practices

Dates and times in SQL can feel confusing because different databases handle them differently. However, once you grasp a few core rules—**data types, literals, component extraction, and aggregate matching**—date manipulation becomes straightforward and predictable.

---

## 1. Date & Time Types and Literals

### The Concept

To work with dates safely, databases need to know that a value is actually a date/time and not just a regular text string.

* **`DATE`**: Stores year, month, and day (`YYYY-MM-DD`).
* **`TIME`**: Stores hours, minutes, and seconds (`HH:MM:SS`).
* **`TIMESTAMP`**: Combines both date and time (`YYYY-MM-DD HH:MM:SS`).

### Syntax & Code Example

To write a date or time safely in SQL without relying on risky string conversions, use **ANSI SQL standard type literals** (prefixing the string with the data type keyword).

```sql
-- Table creation using standard types
CREATE TABLE t_dttest (
    a DATE,
    b TIME,
    c TIMESTAMP
);

-- Inserting data using Modern/Best Practice ANSI Type Literals
INSERT INTO t_dttest VALUES (
    DATE '1962-05-20',
    TIME '10:32:16',
    TIMESTAMP '1962-05-20 10:32:16'
);

```

> ⚠️ **Engineering Practice Note:**
> * **[Modern / Best Practice]:** Always use explicit type literals like `DATE '1982-05-20'` or `TIMESTAMP '...'`. This prevents database engines from misinterpreting month/day order based on local server settings.
> * **[Legacy / Obsolete]:** Passing bare strings like `'1982-05-20'` and hoping the database implicitly casts them correctly. This frequently breaks when moving code between servers with different regional settings (e.g., US `MM/DD/YYYY` vs. UK `DD/MM/YYYY`).
> 
> 

---

## 2. Filtering Dates & Ranges (`BETWEEN`)

### The Concept

Because dates are sequential values, you can compare them just like numbers. The `BETWEEN` operator is a clean, readable way to filter rows that fall inside a specific date window (inclusive of start and end bounds).

### Syntax & Code Example

```sql
-- Find events happening strictly on a specific date
SELECT * 
FROM totp
WHERE wk = DATE '1982-05-20';

-- Find events falling within a date range
SELECT * 
FROM totp
WHERE wk BETWEEN DATE '1980-05-20' AND DATE '1980-05-26';

```

---

## 3. Date Arithmetic & Time Intervals

### The Concept

SQL allows you to add or subtract time units (days, months, years) from dates.

### Syntax & Code Example

```sql
-- Subtracting dates (ANSI Standard syntax)
-- Returns the number of days between current date and the event week
SELECT singer, song, wk, (CURRENT_DATE - wk) DAY(5) AS days_ago
FROM totp
WHERE singer = 'Tom Jones';

-- Adding/Subtracting Intervals (Finding events 7 days prior to a target date)
SELECT * 
FROM totp
WHERE DATE '1976-05-20' BETWEEN wk - INTERVAL '7' DAY AND wk;

```

**Engineering Practice Note:**
> * **[Modern / Best Practice]:** Use ANSI standard `INTERVAL '7' DAY` syntax for portable database design.
> * **[Legacy / Obsolete]:** Vendor-specific syntax like `wk - 7` (which treats integers as days blindly) or proprietary shortcut functions that vary wildly between MySQL, Postgres, and SQL Server.
> 
> 

---

## 4. Extracting Date Components (`EXTRACT`)

### The Concept

Often, you don't want the full date; you just want the **year**, **month**, or **day** to group data or perform calculations.

### Syntax & Code Example

```sql
-- Extracting individual parts of a date
SELECT 
    EXTRACT(YEAR FROM wk) AS event_year,
    EXTRACT(MONTH FROM wk) AS event_month,
    EXTRACT(DAY FROM wk) AS event_day
FROM totp 
WHERE song = 'Rio';

```

> ⚠️ **Engineering Practice Note:**
> * **[Modern / Best Practice]:** Use the ANSI standard **`EXTRACT(PART FROM column)`** function. It works across almost all modern enterprise databases (Postgres, Oracle, Snowflake, BigQuery).
> * **[Legacy / Obsolete]:** Relying on database-specific shortcut functions like `YEAR(wk)` or `MONTH(wk)`. While supported in MySQL/SQL Server, they fail or require syntax changes if you migrate to Postgres or standard-compliant engines.
> 
> 

---

## 5. Finding Global Extremes (The Oldest / Latest Record Pattern)

### The Concept

A very common interview and real-world task is: *"Find the single oldest person"* or *"Find the event with the latest date."*

* **The Trap:** You might be tempted to use `ORDER BY date DESC LIMIT 1`. While that works for a single top record, what happens if **two records share the exact same latest date**? `LIMIT 1` will arbitrarily pick just one and drop the other!
* **The Solution:** Use a **Subquery with Aggregate Functions (`MAX` / `MIN`)** to find the threshold, matching all rows that equal that threshold.

### Syntax & Code Example

```sql
-- Step 1: Find the maximum date using (SELECT MAX(wk) FROM totp)
-- Step 2: Match all records where wk equals that maximum date (safely handling ties)
SELECT * 
FROM totp 
WHERE wk = (SELECT MAX(wk) FROM totp);

-- Example: Finding the oldest person by birthday (Minimum date is the oldest birth date)
SELECT * 
FROM people
WHERE birthday = (SELECT MIN(birthday) FROM people);

```

---

## 6. Finding the Latest Record Per Group (Advanced Extrema)

### The Concept

Instead of finding the *single* latest record in the whole table, what if you need the latest record **for every individual category or balance**? (e.g., *"What is the most recent placement location for every single account balance?"*).

### Approach A: The Traditional Subquery Join (Classic Pattern)

You join the main table against a grouped subquery that isolates the maximum date for each group.

```sql
SELECT p.balance, p.keepplace, p.startdate
FROM placement AS p
JOIN (
    -- Subquery finds the max startdate per balance
    SELECT balance AS B, MAX(startdate) AS S
    FROM placement
    GROUP BY balance
) AS X
  ON p.balance = X.B 
 AND p.startdate = X.S;

```

### Approach B: Window Functions (`ROW_NUMBER()`) — [Modern Gold Standard]

Writing multi-table joins just to find a maximum value per group can feel clunky. Modern SQL uses **Window Functions** to assign row numbers ranked by date within each partition.

```sql
-- Modern Best Practice using Window Functions
SELECT balance, keepplace, startdate
FROM (
    SELECT balance, keepplace, startdate,
           ROW_NUMBER() OVER (PARTITION BY balance ORDER BY startdate DESC) AS rn
    FROM placement
) AS ranked_placements
WHERE rn = 1;

```

> 🚀 **Engineering Practice Note:**
> * **[Modern / Best Practice]:** Use Window Functions (`ROW_NUMBER()` or `RANK()`). They are cleaner, vastly easier to read for complex group-extrema problems, and standard across all modern SQL engines.
> * **[Legacy / Obsolete]:** Correlated subqueries or manual table joins against aggregated group views. They are harder to debug and often run slower on large datasets.

---

## 7. Custom Formatting & String Padding (`DATE_FORMAT`, `LPAD`)

### The Concept

When you need to output dates in human-readable custom formats (like `DD/MM/YYYY`) or strict fixed-width strings (like `YYYYMMDD`), you combine extraction, casting, and padding functions.

* **`DATE_FORMAT`**: A standard or engine-specific function used to mask dates into custom string representations.
* **`LPAD(text, length, pad_string)`**: Pads a string with leading characters (like `'0'`) until it reaches the specified length. Essential for ensuring months like May (`5`) format correctly as `05`.

### Syntax & Code Example

```sql
-- 1. Using DATE_FORMAT for clean display strings
SELECT DATE_FORMAT(wk, '%d/%m/%Y') AS formatted_date, song
FROM totp
WHERE singer = 'Tom Jones';

-- 2. Building a strict 'YYYYMMDD' string manually using EXTRACT, CAST, and LPAD
SELECT wk,
       CAST(EXTRACT(YEAR FROM wk) AS VARCHAR(4))
       || LPAD(EXTRACT(MONTH FROM wk), 2, '0')
       || LPAD(EXTRACT(DAY FROM wk), 2, '0') AS yyyymmdd_string,
       song
FROM totp
WHERE singer = 'Madness';

```

> ⚠️ **Engineering Practice Note:**
> * **[Modern / Best Practice]:** Use database-native casting or international standard ISO formats (`YYYY-MM-DD`) for data transport, and handle custom formatting presentation layers on the frontend/application side when possible.
> * **[Legacy / Obsolete]:** Relying heavily on engine-specific string concatenation (`||` or `CONCAT`) and `LPAD` to build custom dates in SQL queries, as date formatting behavior varies wildly across database vendors (e.g., MySQL uses `DATE_FORMAT`, Oracle/Postgres use `TO_CHAR`).
> 
> 

---

## 8. Day-of-the-Week Analysis (Functions vs. Modular Arithmetic)

### The Concept

To analyze weekly broadcast patterns (e.g., discovering that a show always airs on Thursdays or Fridays), you can evaluate the day of the week.

#### Approach A: Built-in Date Functions (`DAYOFWEEK`)

Most databases offer a direct function that returns an integer representing the day of the week.

#### Approach B: Modular Arithmetic (The Mathematical Fallback)

If an engine lacks a native function, you can anchor to a known calendar date, subtract it from your target date to get total days elapsed, and use **modulo 7 (`MOD 7`)** arithmetic to cycle through the 7 days of the week.

### Syntax & Code Example

```sql
-- 1. Modern / Native Approach using built-in functions
SELECT DAYOFWEEK(wk) AS day_index, COUNT(song) AS song_count
FROM totp
GROUP BY DAYOFWEEK(wk);

-- 2. Mathematical / Arithmetic Approach (Anchor date: May 20, 1962 was a Sunday = 0)
-- Calculates day index by finding the remainder of total day difference divided by 7
SELECT wk, 
       MOD(CAST(wk - DATE '1962-05-20' AS INTEGER), 7) AS calculated_day_of_week
FROM totp;

```
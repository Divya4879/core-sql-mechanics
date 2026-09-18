# Architectural Guide: Mastering Self Joins and Complex Transit Networks

Transit network databases—such as the Edinburgh Buses schema—introduce a unique relational challenge: entities within the same table need to be compared against each other. When you need to find relationships *within* a single table (like tracking two different stops on the exact same bus route), a standard join fails because a single row only holds one stop at a time. This requires a **Self Join**.

This guide breaks down the database schema, the underlying logic of self joins, and repeatable patterns so you can master these problems independently.

---

## Part 1: Decoding the Database Schema

Before writing a single line of SQL, you must understand how the transit data is modeled. The Edinburgh Buses database consists of two core tables:

1. **`stops` Table:** Stores every physical bus stop.
* `id`: Unique identifier for the stop (integer).
* `name`: The human-readable name of the stop (e.g., `'Craiglockhart'`, `'London Road'`).


2. **`route` Table:** Stores the sequence of stops that buses visit. Because a bus visits many stops, a single bus route (`num`) has multiple rows in this table.
* `num`: The bus route number (e.g., `'4'`, `'45'`, `'10'`).


* `company`: The operating bus company (e.g., `'LRT'`, `'SMT'`).


* `pos`: The sequence position or order of the stop along that route.
* `stop`: The foreign key linking to `stops.id`.


---

## Part 2: The Core Logic of Self Joins

### Why Standard Joins Aren't Enough

Suppose you want to find all bus routes that connect **Stop A** to **Stop B**.
If you look at the `route` table, a single row contains a bus number and *one* stop ID. Stop A and Stop B exist on *different* rows for that same bus. To evaluate them together, you must clone the `route` table virtually in your query using **aliases** (`route a` and `route b`), treating them as two separate tables.

### The Fundamental Self-Join Rule

To connect two points on the same journey, you must join the route table to itself by matching the **company** and the **bus number**, while looking for **different stops**:

```sql
SELECT a.company, a.num, a.stop, b.stop
FROM route a 
JOIN route b 
  ON (a.company = b.company AND a.num = b.num)
WHERE a.stop = [Origin_ID] 
  AND b.stop = [Destination_ID];

```

* `a` represents the origin leg of the journey.


* `b` represents the destination leg of the journey.


* Matching on `a.company = b.company AND a.num = b.num` ensures we are looking at the *same physical bus*.



---

## Part 3: Step-by-Step Problem-Solving Patterns

### Pattern 1: Finding Shared Routes (`GROUP BY` + `HAVING`)

**Goal:** Find routes that visit two distinct stops (e.g., London Road [149] and Craiglockhart [53]).

* **Logic:** Filter the route table for rows matching either stop ID, group by the bus company and number, and use `HAVING COUNT(*) = 2` to ensure *both* stops are visited by that specific route.



```sql
SELECT company, num, COUNT(*)
FROM route 
WHERE stop = 149 OR stop = 53
GROUP BY company, num
HAVING COUNT(*) = 2;
```

### Pattern 2: Basic Self Join with Stop Names (`stops` Lookup Aliasing)
**Goal:** Display human-readable stop names instead of raw IDs for a connection between two places.
*   **Logic:** Join `route a` and `route b` on matching company and bus number, then join the `stops` table *twice* (aliased as `stopa` and `stopb`) to translate both stop IDs into names.
```sql
SELECT a.company, a.num, stopa.name, stopb.name
FROM route a 
JOIN route b 
  ON (a.company = b.company AND a.num = b.num)
JOIN stops stopa 
  ON (a.stop = stopa.id)
JOIN stops stopb 
  ON (b.stop = stopb.id)
WHERE stopa.name = 'Craiglockhart'
  AND stopb.name = 'London Road';
```

### Pattern 3: Using Subqueries for Name Resolution (Exercises 7 & 8)

**Goal:** Connect stops when you only have their text names (e.g., 'Haymarket' and 'Leith', or 'Craiglockhart' and 'Tollcross').

*   **Logic:** If you prefer not to join the `stops` table multiple times, you can resolve stop names to IDs inside the `WHERE` clause using subqueries.

```sql
SELECT r1.company, r1.num
FROM route r1
JOIN route r2 
  ON (r1.company = r2.company AND r1.num = r2.num)
WHERE r1.stop = (SELECT id FROM stops WHERE name = 'Craiglockhart')
  AND r2.stop = (SELECT id FROM stops WHERE name = 'Tollcross');
```

### Pattern 4: Single-Hop Reachability (Reachable Stops from an Origin)

**Goal:** List all stops that can be reached from 'Craiglockhart' by taking one single bus operated by 'LRT'.

*   **Logic:** Set `stopa.name = 'Craiglockhart'` and filter `a.company = 'LRT'`, then project `stopb.name` as your reachable destination. Use `DISTINCT` to avoid duplicate listings if multiple routes stop there.

```sql
SELECT DISTINCT stopb.name, b.company, b.num
FROM route a
JOIN route b 
  ON (a.company = b.company AND a.num = b.num)
JOIN stops stopa 
  ON (a.stop = stopa.id)
JOIN stops stopb 
  ON (b.stop = stopb.id)
WHERE stopa.name = 'Craiglockhart' 
  AND a.company = 'LRT';
```

### Pattern 5: Multi-Hop / Two-Bus Transfers (The Ultimate Self-Join Test)

**Goal:** Find routes involving *two buses* to go from a starting point (Craiglockhart) to a destination (Lochend), showing the first bus, the transfer stop name, and the second bus.

*   **Logic:** This requires joining the route table to itself **twice** (or treating it as a chain of three route instances: `bus1` from origin to transfer, and `bus2` from transfer to destination). 

    1. Find all buses leaving the origin (Craiglockhart).
    2. Find all buses arriving at the destination (Lochend).
    3. Connect them where a shared stop (`transfer`) exists on both paths.

---

## Part 4: General Framework for Tackling Any Join/Self-Join Query

When faced with a difficult query, never code blindly. Follow these steps:

1.  **Identify the Entities:** What tables do I have? (`stops`, `route`).

2.  **Determine the Scope:** Am I looking at a single point, a direct connection (1 hop), or a transfer (2 hops)?

    *   *Direct:* 1 instance of `route` (plus `stops` lookup).

    *   *Self Join (Direct connection between two points):* 2 instances of `route` (`a` and `b`) joined on shared `num` and `company`.

    *   *Multi-hop (Transfer):* 3 instances of `route` linked through a common transfer stop.

3.  **Establish the Linkages:** Write out your `ON` conditions explicitly. If matching a bus, always tie `company = company` and `num = num`. If matching a stop name, bridge through `stops.id`.

4.  **Filter with `WHERE`:** Apply specific text filters (e.g., `'Craiglockhart'`) using either direct ID matches or subqueries.

---

Here is the **Universal Self-Join Blueprint** section. You can copy and paste this directly at the bottom of your notes file as the general, schema-agnostic pattern reference for interviews:

---

## PART 5: The Universal Blueprint of Self Joins (For Any Interview)

A **Self Join** is simply a regular join (`INNER`, `LEFT`, etc.) where a database table is joined to **an exact copy of itself** using table aliases.

### When do you need a Self Join?

You need a self join whenever data that answers your question lives **inside the same table**, rather than across two separate tables.

The three most common universal patterns you will face in interviews are:

1. **Hierarchies & Trees** (e.g., Employees and Managers, Category sub-categories).
2. **Networks & Graphs** (e.g., Bus routes, Flights connecting airports, Social media mutuals).
3. **Sequential / Comparative Rows** (e.g., Finding transactions or logs that occurred right after another for the same user).

---

### Universal Pattern 1: Hierarchical Data (Adjacency Lists)

*Classic Interview Question:* "Write a query to show each employee's name alongside their manager's name."

* **The Schema:** An `employees` table containing `id`, `name`, and `manager_id` (which references `id` in the same table).
**The Logic:**
* Table `e` represents the employee.
* Table `m` represents their manager.
* The link is `e.manager_id = m.id`.
* *Crucial Trap:* The CEO doesn't have a manager (`manager_id` is `NULL`). If you use an `INNER JOIN`, the CEO disappears. You **must use a `LEFT JOIN**` to ensure top-level entities are preserved.



```sql
SELECT 
    e.name AS employee_name, 
    COALESCE(m.name, 'Top Boss') AS manager_name
FROM employees e
LEFT JOIN employees m 
  ON e.manager_id = m.id;

```

---

### Universal Pattern 2: Network & Path Matching (Graph Traversal)

*Classic Interview Question:* "Find all pairs of airports that have direct flights connecting them in both directions."

* **The Schema:** A `flights` table containing `origin_airport` and `destination_airport`.
* **The Logic:** You want to find rows where Flight A goes from X to Y, and Flight B goes from Y to X.

```sql
SELECT 
    f1.origin_airport, 
    f1.destination_airport
FROM flights f1
JOIN flights f2 
  ON f1.origin_airport = f2.destination_airport 
 AND f1.destination_airport = f2.origin_airport
WHERE f1.origin_airport < f1.destination_airport; 

```

* *The Inequality Trick (`<`):* When pairing items symmetrically, comparing primary keys or string names alphabetically with `<` or `>` prevents your query from spitting out duplicate mirror-image rows (e.g., showing both A->B and B->A).

---

### Universal Pattern 3: Sequential Row Comparison (Time-Series / Logs)

*Classic Interview Question:* "Find user login sessions that happened within 30 minutes of their previous session."

* **The Schema:** A `sessions` table containing `user_id` and `login_time`.
* **The Logic:** Join the table to itself where the user is the same, but the time of session 2 is strictly greater than session 1.

```sql
SELECT 
    s1.user_id, 
    s1.login_time AS previous_login, 
    s2.login_time AS next_login
FROM sessions s1
JOIN sessions s2 
  ON s1.user_id = s2.user_id
  AND s2.login_time > s1.login_time
  -- Optional subquery condition to find the *immediate* next session only
  AND s2.login_time = (
      SELECT MIN(s3.login_time) 
      FROM sessions s3 
      WHERE s3.user_id = s1.user_id 
        AND s3.login_time > s1.login_time
  );

```

---

## PART 6: The Universal 4-Step Self-Join Framework

Whenever an interview question or a complex database query introduces a relationship within a single table, stop and run through this exact mental checklist:

1. **Spot the Single-Source Clue:** Look at the prompt. If it asks you to find relationships between items that belong to the same list (Employees & Managers, Stops & Stops, Airports & Airports), **immediately write down two table aliases** (e.g., `FROM table x JOIN table y`).
2. **Define the Aliases' Roles:**
* What does alias `x` represent? (e.g., The starting point, the employee, flight leg 1).
* What does alias `y` represent? (e.g., The destination, the manager, flight leg 2).


3. **Establish the Glue (`ON` clause):** What binds them?
* Is it a foreign key pointing to the same table? (`x.manager_id = y.id`)
* Is it a shared characteristic forming a bridge? (`x.num = y.num AND x.company = y.company`)


4. **Guard Against Missing Data (`JOIN` type):** Ask yourself: *Can the primary entity exist without a match?* If yes (like a CEO with no manager, or a bus stop with no outbound connection), use a `LEFT JOIN`. If it requires an absolute match on both sides, use an `INNER JOIN`.
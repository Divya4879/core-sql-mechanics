# Architectural Guide: Mastering Self Joins and Complex Transit Networks

Transit network databases such as the Edinburgh Buses schema, introduce a unique relational challenge: entities within the same table need to be compared against each other. When you need to find relationships *within* a single table (like tracking two different stops on the exact same bus route), a standard join fails because a single row only holds one stop at a time. This requires a **Self Join**.

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

### Pattern 3: Using Subqueries for Name Resolution

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

### Pattern 5: Multi-Hop / Two-Bus Transfers (The Ultimate Self-Join Test)

**Goal:** Find routes involving two buses to go from a starting point (Craiglockhart) to a destination (Lochend).

* **Logic:** This requires chaining multiple route instances together. You find routes leaving the origin stop, routes arriving at the destination stop, and bridge them together through an intermediate shared transfer stop.

#### Problem Statement

Find all bus journeys involving **two buses** (one transfer) that can take a passenger from **Craiglockhart** to **Lochend**. The output must display:

1. The bus number for the first bus (`a.num`).

2. The operating company for the first bus (`a.company`).

3. The human-readable name of the transfer stop (`stopb.name`).

4. The bus number for the second bus (`d.num`).

5. The operating company for the second bus (`d.company`).

---

#### The Core Logic & Hint Breakdown

* **The Hint:** Self-join twice to find buses that visit Craiglockhart and Lochend, then join those on matching stops.

**How it works conceptually:**

* Instead of just two table instances (`a` and `b`), a two-bus transfer requires a chain of four route aliases (`a`, `b`, `c`, and `d`).
* **Leg 1 (`a` & `b`):** Represents the first bus trip starting at 'Craiglockhart' and traveling to a transfer stop.
* **The Transfer Bridge (`b.stop = c.stop`):** Links the first bus route to the second bus route at a shared physical station ID.
* **Leg 2 (`c` & `d`):** Represents the second bus trip traveling from that transfer stop onward to 'Lochend'.

---

#### Full Code Implementation

```sql
SELECT DISTINCT 
    a.num AS first_bus_num,
    a.company AS first_bus_company,
    stopb.name AS transfer_stop,
    d.num AS second_bus_num,
    d.company AS second_bus_company
FROM route a
-- Leg 1: Match the first bus route from origin
JOIN route b ON (a.company = b.company AND a.num = b.num)
-- The Transfer Bridge: Connect bus 1's path to bus 2's path at a common stop
JOIN route c ON (b.stop = c.stop)
-- Leg 2: Match the second bus route to the destination
JOIN route d ON (c.company = d.company AND c.num = d.num)
-- Translate IDs into human-readable stop names
JOIN stops stopa ON (a.stop = stopa.id)
JOIN stops stopb ON (b.stop = stopb.id)
JOIN stops stopd ON (d.stop = stopd.id)
WHERE stopa.name = 'Craiglockhart' 
  AND stopd.name = 'Lochend';

```

---

#### Step-by-Step Explanation 

1. **`route a` and `route b`:** These are self-joined on `a.company = b.company AND a.num = b.num` to isolate a continuous single bus line running from the origin.

2. **`JOIN stops stopa`:** Translates the starting point's stop ID (`a.stop`) into text, allowing us to filter for `'Craiglockhart'` in the `WHERE` clause.

3. **`JOIN route c` on `b.stop = c.stop`:** This is the critical transition point. It looks for *any other* bus route (`c`) that happens to visit the exact same physical stop (`b.stop`) where our first bus can drop passengers off.

4. **`route c` and `route d`:** These are self-joined to establish the full trajectory of the second connecting bus line from the transfer stop to the final destination.

5. **`JOIN stops stopd`:** Translates the final drop-off stop ID into text so we can filter for `'Lochend'`.

6. **`DISTINCT`:** Essential because multiple route positioning rows or duplicate path combinations can otherwise generate redundant rows in the output grid.

---

## Part 4: General Framework for Tackling Any Join / Self-Join Query

When faced with a complex database query, never code blindly. Walk through this mental checklist:

1. **Identify the Entities:** Determine what physical tables hold your data (e.g., `stops`, `route`).

2. **Determine the Scope:**
* *Direct lookup:* 1 instance of the table plus lookups.

* *Self-join (Direct connection between two points in the same list):* 2 virtual instances of the same table using distinct aliases (`a` and `b`).

* *Multi-hop / Transfers:* 3 or more virtual instances chained through common intermediate attributes.

3. **Establish the Linkages:** Write out your `ON` conditions explicitly. Match shared keys or characteristics (such as matching bus lines via `company` and `num`).

4. **Filter with `WHERE`:** Isolate specific starting points, destination constraints, or attributes using direct comparisons, IDs, or subqueries.

---

## Part 5: General Principles for Solving Self-Joins

* **Always Alias Explicitly:** Never query a self-join without using distinct table aliases (e.g., `a` and `b`, or `route a` and `route b`). Treating them as separate conceptual tables prevents ambiguous column reference errors.

* **Define the Relationship Direction:** Know whether your self-join represents a directional graph (like sequential transit stops or hierarchical management) or a symmetric pairing, and use appropriate equality or inequality operators to manage duplicate mirror rows.

* **Choose the Right Join Type:** Defaulting to an `INNER JOIN` will strip out rows where the secondary reference is missing (like top-level managers or unlinked entities). Use a `LEFT JOIN` if you need to preserve records that lack a matching pair.

* **Isolate One Leg at a Time:** When constructing multi-step paths or transfers, build and test the first leg of the join independently before appending the next table alias instance to the query tree.
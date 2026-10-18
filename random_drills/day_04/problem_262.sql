/* =====================================================================================
   LEETCODE 262: Trips and Users (Hard)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Multi-Role Transaction Filtering (Dual-Aliasing Joins) & Conditional Proportions
      
   2. CORE INSIGHT & CODE MECHANICS:
      The core difficulty of this problem is that a single `Trips` transaction has TWO distinct 
      roles (`client_id` and `driver_id`), but they both reference the exact same `Users` table.

      - The Subquery Method (User Solution): You intuitively built "validity flags" by checking if 
        each ID existed in a subquery of banned users. This is logically sound but can be 
        computationally heavy on massive datasets because the engine evaluates the subquery 
        per row during the SELECT phase.
      - The Dual-Aliasing Method (Optimal Architecture): You can `JOIN` the `Users` table to the 
        `Trips` table twice in the same query. To do this without confusing the database, you must 
        give the tables unique aliases (e.g., `JOIN Users clients` and `JOIN Users drivers`). 
        This flattens the data perfectly so you can filter `clients.banned = 'No'` and 
        `drivers.banned = 'No'` in a single `WHERE` clause.
      - Float Casting: Multiplying or writing `1.00` in the cancellation check is a perfect 
        defense against integer division truncation.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Do I have multiple columns in my transaction table (like sender/receiver, 
        buyer/seller, client/driver) that point to the same dimension table?" 
        IMMEDIATELY deploy Dual-Aliasing. Join the dimension table twice with clear aliases.
      - Question B: "How do I calculate a percentage of an event occurring?" 
        Use `SUM(CASE WHEN condition THEN 1.00 ELSE 0 END) / COUNT(id)`.
      - Question C: "Should I filter in the SELECT clause or the WHERE clause?" 
        Always filter out invalid entities (like banned users or out-of-bounds dates) in the 
        `WHERE` clause *before* you execute group aggregations.

   4. COMMON PITFALLS TO AVOID:
      - Trying to join the `Users` table only once. If you join on `client_id`, you have no way 
        to verify if the driver is banned. You must join twice.
      - Filtering dates *after* grouping. Using `WHERE request_at BETWEEN ...` early prevents 
        the engine from calculating cancellation rates for years of data you don't even need.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE (The Validity Flag Pipeline)
-- =====================================================================================
WITH banned_and_unbanned AS(
    SELECT
        request_at,
        id,
        client_id,
        CASE WHEN client_id IN(SELECT users_id FROM Users WHERE banned = 'Yes') THEN 0 ELSE 1 END AS valid_client,
        driver_id,
        CASE WHEN driver_id IN(SELECT users_id FROM Users WHERE banned = 'Yes') THEN 0 ELSE 1 END AS valid_driver,
        status
    FROM Trips
)

SELECT
    request_at AS `Day`,
    ROUND(SUM(CASE WHEN status LIKE '%cancelled%' THEN 1.00 ELSE 0 END) / COUNT(id), 2) AS `Cancellation Rate`
FROM banned_and_unbanned
WHERE valid_client = 1 
  AND valid_driver = 1 
  AND request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY `Day`;


/* =====================================================================================
   OPTIMAL & REFINED APPROACH (Dual-Aliasing Joins)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Multi-Join Architecture: By joining the `Users` table twice (once as `c` for clients, 
      once as `d` for drivers), we bypass the need for CTEs and multiple subqueries entirely.
   2. Clean Negation: Checking `status != 'completed'` cleanly captures both 'cancelled_by_driver' 
      and 'cancelled_by_client' without needing wildcard string matching (`LIKE`), which is 
      faster for the CPU to process.
   ===================================================================================== */

/*
SELECT 
    t.request_at AS `Day`,
    ROUND(SUM(CASE WHEN t.status != 'completed' THEN 1.00 ELSE 0 END) / COUNT(t.id), 2) AS `Cancellation Rate`
FROM Trips t
-- Join the Users table to verify the Client
JOIN Users c ON t.client_id = c.users_id
-- Join the Users table AGAIN to verify the Driver
JOIN Users d ON t.driver_id = d.users_id
WHERE c.banned = 'No' 
  AND d.banned = 'No'
  AND t.request_at BETWEEN '2013-10-01' AND '2013-10-03'
GROUP BY t.request_at;
*/
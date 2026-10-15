/* =====================================================================================
   LEETCODE 1407: Top Travellers
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Outer Join Aggregation, Missing Data Handling (`COALESCE`), & Multi-Column Tie-Breaking
      
   2. CORE INSIGHT & CODE MECHANICS:
      When generating leaderboards or metric summaries, you often face two major challenges:
      - Preserving Inactive Entities: If you use an `INNER JOIN`, entities with zero activity 
        (like Donald who has no rides) are completely dropped. A `LEFT JOIN` starting from the 
        `Users` table ensures every user is retained in the output.
      - Handling Null Sums: When a `LEFT JOIN` finds no matching rows in the right table, all 
        columns from that table evaluate to `NULL`. Crucially, `SUM(NULL)` returns `NULL`, not `0`. 
        Wrapping the aggregate in `COALESCE(..., 0)` safely maps those missing values to zero.
      - Composite Sorting (Tie-Breaking): Passing multiple columns into the `ORDER BY` clause 
        (`travelled_distance DESC, name ASC`) tells the engine: "Sort primarily by distance descending. 
        If there is a tie, break the tie alphabetically by name ascending."

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Should entities with zero transactions/events still show up in my report?" 
        If yes, never use `INNER JOIN`. Always `LEFT JOIN` from the master entity table and aggregate 
        using `COALESCE`.
      - Question B: "What happens when two rows share the exact same primary metric score?" 
        Always include a secondary sorting criteria in your `ORDER BY` clause (like ID or Name) 
        to ensure deterministic, stable pagination and display results.

   4. COMMON PITFALLS TO AVOID:
      - Using `INNER JOIN` instead of `LEFT JOIN`, which accidentally filters out users with 0 distance.
      - Forgetting `COALESCE`, leaving ugly `NULL` values in your distance column for inactive users.
      - Grouping by the wrong key: Always group by the unique user identifier (`Users.id`), not just 
        the user's name, to prevent bugs if two users share the same name.
   ===================================================================================== */

SELECT 
    name, 
    -- COALESCE replaces NULL sums (from unmatched left joins) with 0
    COALESCE(SUM(distance), 0) AS travelled_distance
FROM Users
LEFT JOIN Rides 
    ON Users.id = Rides.user_id
GROUP BY Users.id, name
-- Multi-column sorting: First by distance descending, then alphabetically by name for ties
ORDER BY travelled_distance DESC, name ASC;
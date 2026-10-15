/* =====================================================================================
   LEETCODE 1050: Actors and Directors Who Cooperated At Least Three Times
   =====================================================================================
   
   ARCHETYPE / PATTERN: 
   Multi-Column Grouping & Aggregated Threshold Filtering (Pair Frequency Pattern)
   
   CORE INSIGHT:
   When you need to find relationships, frequencies, or occurrences between *pairs* or 
   *combinations* of entities (e.g., actor + director, user + product, IP + endpoint), 
   do NOT write messy self-joins. Instead, leverage a multi-column GROUP BY combined 
   with a HAVING clause inside a CTE pipeline.

   WHY THIS PATTERN MATTERS:
   1. Multi-Column GROUP BY: Passing multiple columns (actor_id, director_id) tells the 
      SQL engine to treat each unique *combination* of those two values as a single group.
   2. HAVING vs WHERE: WHERE filters raw table rows *before* grouping. HAVING filters 
      the summarized/aggregated results *after* grouping (e.g., filtering by COUNT >= 3).
   3. CTE Pipeline: Wrapping it in a Common Table Expression (WITH clause) turns a 
      complex calculation into a readable, top-to-bottom data flow.
   ===================================================================================== */

WITH frequent_collaborations AS (
    SELECT 
        actor_id, 
        director_id,
        COUNT(*) AS collaboration_count
    FROM ActorDirector
    -- Grouping by two columns treats the pair as a distinct composite key
    GROUP BY actor_id, director_id
    -- HAVING filters aggregated metrics (unlike WHERE which cannot check COUNT)
    HAVING COUNT(*) >= 3
)
SELECT 
    actor_id, 
    director_id
FROM frequent_collaborations;
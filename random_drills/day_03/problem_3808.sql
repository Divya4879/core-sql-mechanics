/* =====================================================================================
   LEETCODE 3808: Find Emotionally Consistent Users (Day 3 Kickoff)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Two-Phase Aggregation Pipeline, Windowed Dominance Ranking (`ROW_NUMBER`), 
      & Windowed Partition Totals (`SUM() OVER`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      When business logic requires identifying a "dominant" behavior or preference per entity 
      (e.g., most frequent reaction) alongside a proportional ratio check against total volume 
      (e.g., consistency ratio >= 60% and total volume >= 5), you face a multi-layered calculation:

      - Phase 1 (Base Grouping): Group by the entity and the sub-category (`user_id, reaction`) 
        to calculate raw frequency counts (`cnt`) per reaction type.
      - Phase 2 (Windowed Analytics): Instead of nesting another heavy group-by, use window functions 
        directly on the aggregated table:
        1. `ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY cnt DESC)`: Sorts and assigns a rank 
           to each reaction per user, pinning the highest frequency reaction to `rnk = 1` (Dominant Reaction).
        2. `SUM(cnt) OVER (PARTITION BY user_id)`: Calculates the global sum of all reactions for that 
           user across all categories without collapsing the individual rows.
      - Phase 3 (Filtering & Ratio Projections): The outer query filters for the top-ranked dominant 
        reaction (`rnk = 1`), total volume thresholds (`total >= 5`), and ratio proportions (`(cnt / total) >= 0.60`).

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How do I find the 'Top-1' category per entity while still needing access to 
        the entity's total sum across all categories?" 
        Use `ROW_NUMBER()` to isolate the dominant item, combined with `SUM() OVER (PARTITION BY entity_id)` 
        to fetch the grand total in parallel without losing row granularity.
      - Question B: "Why use a multi-CTE pipeline here?" 
        Breaking down base counting (CTE 1) from analytical ranking and windowed totals (CTE 2) 
        keeps complex calculations clean, testable, and bug-free.

   4. COMMON PITFALLS TO AVOID:
      - Integer Division Traps: Depending on the SQL dialect, dividing two integers (`cnt / total`) can 
        truncate decimals prematurely to `0`. Always ensure floating-point casting (`1.0 * cnt / total`) 
        if your engine performs strict integer division.
      - Referencing window aliases incorrectly: Window function results cannot be filtered directly in 
        the `WHERE` clause of the same select statement where they are computed; they must be wrapped 
        in a CTE or subquery.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
WITH tmp_table AS (
    SELECT
        user_id,
        COUNT(content_id) AS cnt,
        reaction
    FROM reactions
    GROUP BY user_id, reaction
),

tmp_table_1 AS (
    SELECT
        user_id,
        cnt,
        reaction AS dominant_reaction,
        /* Find the most frequent reaction for the user */
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY cnt DESC) AS rnk,
        /* Calculate total reactions for the user across all reaction types */
        SUM(cnt) OVER(PARTITION BY user_id) AS total
    FROM tmp_table
)

SELECT
    user_id,
    dominant_reaction,
    ROUND(cnt / total, 2) AS reaction_ratio
FROM tmp_table_1
WHERE rnk = 1 
  AND total >= 5 
  AND (cnt / total) >= 0.60
ORDER BY 
    reaction_ratio DESC, 
    user_id ASC;


/* =====================================================================================
   OPTIMAL & REFINED APPROACH (Floating-Point Safe Division)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Explicit Float Casting: Multiplied the numerator by `1.0` (`1.0 * cnt / total`) to guarantee 
      that division yields accurate decimal floating-point values across all database engines 
      (preventing potential truncation bugs in strict SQL dialects).
   ===================================================================================== */

/*
WITH reaction_counts AS (
    SELECT
        user_id,
        reaction,
        COUNT(content_id) AS cnt
    FROM reactions
    GROUP BY user_id, reaction
),
ranked_reactions AS (
    SELECT
        user_id,
        reaction AS dominant_reaction,
        cnt,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY cnt DESC) AS rnk,
        SUM(cnt) OVER (PARTITION BY user_id) AS total_reactions
    FROM reaction_counts
)
SELECT
    user_id,
    dominant_reaction,
    -- Explicitly cast numerator to float (1.0 *) to prevent integer division truncation
    ROUND(1.0 * cnt / total_reactions, 2) AS reaction_ratio
FROM ranked_reactions
WHERE rnk = 1 
  AND total_reactions >= 5 
  AND (1.0 * cnt / total_reactions) >= 0.60
ORDER BY 
    reaction_ratio DESC, 
    user_id ASC;
*/
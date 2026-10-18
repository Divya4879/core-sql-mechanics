/* =====================================================================================
   LEETCODE 3832: Find Users with Persistent Behavior Patterns
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      The "Gaps and Islands" Problem, Date-Math Grouping, & Top-N Partition Filtering
      
   2. CORE INSIGHT & CODE MECHANICS:
      How do you group rows that are strictly consecutive, but separate them if there is 
      a gap in days or a change in the action? 
      
      You use the Magic Island Formula: 
      `DATE_SUB(date, INTERVAL ROW_NUMBER() OVER(...) DAY)`

      How the math works:
      Imagine a user logs in on Nov 1, Nov 2, and Nov 3. 
      - The `ROW_NUMBER()` for these rows will be 1, 2, and 3.
      - If you subtract 1 day from Nov 1 -> Oct 31.
      - If you subtract 2 days from Nov 2 -> Oct 31.
      - If you subtract 3 days from Nov 3 -> Oct 31.
      Because they are perfectly consecutive, the math results in the exact same "Anchor Date" 
      (Oct 31). This Anchor Date becomes your `island_grp`. 
      
      If there is a gap (e.g., Nov 5 is the next login, which gets ROW_NUMBER 4):
      - Subtract 4 days from Nov 5 -> Nov 1. 
      The Anchor Date changed! The streak is broken, and a new group is born.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later, ask yourself these diagnostic questions:
      - Question A: "Am I looking for consecutive days/months of the exact same activity?" 
        IMMEDIATELY deploy the Gaps and Islands formula. Do not use `LAG()`.
      - Question B: "How do I isolate the longest streak if they have multiple?" 
        Once the islands are grouped and counted, wrap them in a final CTE using 
        `ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY streak_length DESC)`. Filter for `rnk = 1`.

   4. COMMON PITFALLS TO AVOID:
      - Using `LAG()`: It fails to recognize when consecutive days are broken by missing dates.
      - Grouping only by `user_id` and `action`: This collapses multiple separate streaks 
        (e.g., a streak in Jan and a streak in Mar) into one falsely massive total.
   ===================================================================================== */

-- =====================================================================================
-- THE OPTIMAL APPROACH (The Gaps & Islands Architecture)
-- =====================================================================================
WITH base_islands AS (
    SELECT
        user_id,
        action,
        action_date,
        -- The Magic Formula: Subtracting the row number from the date creates a unified 
        -- Anchor Date for perfectly consecutive sequences.
        DATE_SUB(action_date, INTERVAL ROW_NUMBER() OVER(PARTITION BY user_id, action ORDER BY action_date) DAY) AS island_grp
    FROM activity
),

streak_aggregations AS (
    SELECT
        user_id,
        action,
        COUNT(*) AS streak_length,
        MIN(action_date) AS start_date,
        MAX(action_date) AS end_date
    FROM base_islands
    -- Grouping by the Anchor Date (island_grp) strictly isolates uninterrupted streaks
    GROUP BY user_id, action, island_grp
),

ranked_streaks AS (
    SELECT
        user_id,
        action,
        streak_length,
        start_date,
        end_date,
        -- Rank the streaks per user to find their maximum qualifying sequence
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY streak_length DESC) AS rnk
    FROM streak_aggregations
    -- Ensure the streak meets the minimum consecutive days requirement
    WHERE streak_length >= 5
)

SELECT
    user_id,
    action,
    streak_length,
    start_date,
    end_date
FROM ranked_streaks
-- Only return the longest streak per user
WHERE rnk = 1
ORDER BY 
    streak_length DESC, 
    user_id ASC;


/* =====================================================================================
   YOUR ORIGINAL APPROACH (The LAG Offset Method)
   =====================================================================================
   Note for future review: This approach is structurally logical for checking adjacent rows, 
   but is vulnerable to "Gaps and Islands" edge cases where a user has missing dates or 
   multiple distinct streaks that shouldn't be mathematically combined.
   ===================================================================================== */
/*
WITH tmp_table AS(
    SELECT
        user_id,
        action_date,
        LAG(action, 1) OVER(PARTITION BY user_id ORDER BY action_date) AS prev,
        action
    FROM activity
),
tmp_table_2 AS(
    SELECT
        user_id,
        action_date,
        action,
        CASE WHEN prev = action THEN 1 END AS valid
    FROM tmp_table
    HAVING valid = 1
)
SELECT
    user_id,
    action,
    COUNT(user_id) + 1 AS streak_length,
    DATE_SUB(MIN(action_date), INTERVAL 1 DAY) AS start_date,
    MAX(action_date) AS end_date
FROM tmp_table_2
GROUP BY user_id, action
HAVING streak_length >= 5
ORDER BY streak_length DESC, user_id ASC;
*/
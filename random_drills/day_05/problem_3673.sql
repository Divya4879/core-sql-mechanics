/* =====================================================================================
   LEETCODE 3673: Find Zombie Sessions
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Sessionization (Funnel Analysis), Precision Time Deltas (`TIMESTAMPDIFF`), 
      & Conditional Event Aggregation (Pivoting)
      
   2. 🚨 PITFALLS, WEAKNESSES, & TRAPS:
      Your original attempt hit two incredibly common architectural traps:

      - TRAP 1: The Timestamp Math Trap (Missing `TIMESTAMPDIFF`)
        In MySQL, you cannot simply subtract two timestamps (e.g., `MAX(time) - MIN(time)`). 
        The engine will attempt to treat the timestamps as integers formatted as `YYYYMMDDHHMMSS`, 
        resulting in complete mathematical garbage. `DATEDIFF` only calculates the difference 
        in whole days. When you need precision (minutes, seconds, hours), you must explicitly 
        call `TIMESTAMPDIFF(unit, start_time, end_time)`.
        
      - TRAP 2: The Select-List Granularity Trap
        If you want a column like `user_id` to appear in your final output, it MUST be included 
        in your `GROUP BY` clause, even if `session_id` is already functionally unique. Standard 
        SQL engines rigidly enforce that any non-aggregated column in the `SELECT` list must 
        be mathematically tied to the grouping granularity. 

   3. CORE INSIGHT & CODE MECHANICS:
      This code is an industry-standard template for Event Analytics (like analyzing Google 
      Analytics or Amplitude data).
      
      - Event Pivoting: Using `SUM(CASE WHEN event_type = 'X' THEN 1 ELSE 0 END)` flattens 
        the vertical event stream into horizontal metrics (scrolls, clicks, purchases) per session.
      - Safe Division: The ratio `(clicks / scrolls) < 0.20` is mathematically safe from 
        Division by Zero errors ONLY because it is evaluated alongside `scrolls >= 5`. 
      - The Pipeline: You calculate the core metrics in Phase 1 (CTE), but you push the 
        duration filter (`session_duration_minutes > 30`) to Phase 2. This prevents you from 
        having to write the heavy `TIMESTAMPDIFF` formula twice.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "Do I need the difference between two times in Minutes, Hours, or Seconds?"
        NEVER use subtraction. NEVER use `DATEDIFF`. ALWAYS use `TIMESTAMPDIFF(MINUTE, start, end)`.
      - Diagnostic Question: "Why is MySQL throwing a grouping error when session_id is unique?"
        Check your `SELECT` list. Every raw column (like `user_id`, `platform`, `country`) 
        must explicitly appear in your `GROUP BY`.
   ===================================================================================== */

-- =====================================================================================
-- THE OPTIMAL APPROACH (Event Aggregation & Timestamp Math)
-- =====================================================================================
WITH session_metrics AS (
    SELECT
        session_id,
        user_id,
        -- Calculate total elapsed minutes directly
        TIMESTAMPDIFF(MINUTE, MIN(event_timestamp), MAX(event_timestamp)) AS session_duration_minutes,
        -- Pivot vertical events into horizontal metric columns
        SUM(CASE WHEN event_type = 'scroll' THEN 1 ELSE 0 END) AS scrolls,
        SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) AS clicks,
        SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchases
    FROM app_events
    -- Both non-aggregated SELECT columns must be grouped
    GROUP BY session_id, user_id 
    -- Apply the engagement thresholds
    HAVING scrolls >= 5 
       AND (clicks / scrolls) < 0.20 
       AND purchases = 0
)

SELECT
    session_id,
    user_id,
    session_duration_minutes,
    scrolls AS scroll_count
FROM session_metrics
-- Filter by duration using the pre-calculated alias
WHERE session_duration_minutes > 30 
ORDER BY 
    scroll_count DESC, 
    session_id ASC;
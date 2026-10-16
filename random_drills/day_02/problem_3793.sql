/* =====================================================================================
   LEETCODE 3793: Find Users with High Token Usage
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Multi-Metric CTE Pipeline, Aggregated Threshold Filtering (`HAVING`), 
      & Cross-Aggregate Comparison (`MAX` vs `AVG`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      When building complex usage analytics or telemetry monitoring (such as tracking AI token consumption), 
      you frequently need to calculate multiple summary statistics per entity and filter records based on 
      relationships *between* those aggregates.

      - Multi-Metric Aggregation: Inside a single `GROUP BY` block, you compute total activity (`COUNT`), 
        average consumption rounded to specific decimal places (`ROUND(AVG(...), 2)`), and peak consumption (`MAX(...)`).
      - HAVING vs WHERE for Grouped Filters: Because the minimum prompt requirement (`prompt_count >= 3`) 
        relies on a calculated aggregate count rather than a raw table column, it must be filtered using a 
        `HAVING` clause rather than a `WHERE` clause.
      - Cross-Aggregate Comparison in the Outer Query (`max_tokens > avg_tokens`): The requirement states that 
        the user must have at least one prompt whose tokens exceed their own personal average. By computing 
        the user's `MAX(tokens)` in the CTE, you can compare it directly against their `AVG(tokens)` in the outer 
        `WHERE` clause. If a user's absolute peak prompt is higher than their average, it mathematically guarantees 
        they have at least one prompt above average!
      - Pipeline Architecture (CTE): Wrapping this multi-step metrics engine in a CTE (`WITH tmp_table AS (...)`) 
        transforms what would otherwise be a messy nested subquery into a clean, top-to-bottom analytics script.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Do I need to filter my dataset using aggregate calculations (like COUNT or SUM)?" 
        If yes, aggregate first and apply your filter in the `HAVING` clause (or wrap it in a CTE).
      - Question B: "How do I check a condition like 'at least one item exceeds the average' without looping?" 
        Look at extremes: If the maximum value in a group is strictly greater than the average of that group, 
        there *must* be at least one data point pulling the max above the mean. Comparing `MAX` to `AVG` 
        is a powerful shortcut for distribution checks.
      - Question C: "Did I format my output metrics correctly?" 
        Always round decimal aggregates (`ROUND(..., 2)`) to match expected production reporting standards.

   4. COMMON PITFALLS TO AVOID:
      - Trying to filter aggregate counts using a `WHERE` clause instead of `HAVING` (causes SQL syntax errors).
      - Forgetting to group by the primary entity identifier (`user_id`).
      - Messing up the rounding order of operations: rounding *inside* the aggregate function before final math 
        can skew results; always wrap the final `AVG()` result in `ROUND()`.
   ===================================================================================== */

WITH tmp_table AS (
    SELECT 
        user_id,
        COUNT(user_id) AS prompt_count,
        ROUND(AVG(tokens), 2) AS avg_tokens,
        MAX(tokens) AS max_tokens
    FROM prompts
    GROUP BY user_id
    -- HAVING filters aggregated totals: only keep users who have submitted at least 3 prompts
    HAVING prompt_count >= 3
)
SELECT 
    user_id,
    prompt_count,
    avg_tokens
FROM tmp_table
-- Filter using cross-aggregate comparison: User must have a peak prompt higher than their personal average
WHERE max_tokens > avg_tokens
-- Multi-column sorting: Primary sort by average tokens descending, secondary sort by user_id ascending
ORDER BY avg_tokens DESC, user_id ASC;
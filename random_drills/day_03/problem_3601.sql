/* =====================================================================================
   LEETCODE 3601: Find Drivers with Improved Fuel Efficiency
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Period-over-Period (PoP) Comparison, Conditional Averaging, & Null State Filtering
      
   2. CORE INSIGHT & CODE MECHANICS:
      When tasked with comparing two distinct time periods (e.g., H1 vs H2) for the same entity, 
      you must pivot the vertical time-series data into horizontal parallel columns.

      - Conditional Averages: By using `CASE WHEN MONTH(...)` inside aggregate functions, you isolate 
        metrics for specific time brackets. Calculating efficiency as `distance_km / fuel_consumed` 
        inside that condition gives you the exact metric per trip before averaging.
      - Null Filtering for Completeness: The problem strictly requires drivers to have trips in *both* 
        halves of the year. If a driver has no trips in H1, the conditional aggregate returns `NULL`. 
        Filtering with `HAVING first_half_avg IS NOT NULL AND second_half_avg IS NOT NULL` safely 
        drops incomplete records.
      - Performance Delta: Subtracting the two parallel columns (`second_half_avg - first_half_avg`) 
        in the outer query yields the exact business metric for improvement.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How do I compare 'Last Month' vs 'This Month' for the same user?" 
        Create parallel columns using conditional aggregations (`CASE WHEN period = X THEN val END`).
      - Question B: "How do I calculate a custom metric (like efficiency) before averaging?" 
        Do the math *inside* the `CASE WHEN` statement so the aggregate function processes the computed ratio.
      - Question C: "How do I ensure the entity was active in all compared periods?" 
        Ensure your conditional aggregates are evaluated with `IS NOT NULL` in the `HAVING` clause.

   4. COMMON PITFALLS TO AVOID:
      - Calculating averages incorrectly by averaging pre-aggregated sums, rather than averaging the 
        trip-level ratios directly.
      - Forgetting to filter out drivers who only drove in one half of the year (leaving `NULL`s in the math).
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
WITH tmp_table AS(
    SELECT
        drivers.driver_id AS driver_id,
        driver_name,
        -- Manually calculating average: SUM of metrics / COUNT of valid trips
        SUM(CASE WHEN MONTH(trip_date) IN (1, 2, 3, 4, 5, 6) THEN distance_km/fuel_consumed END) / 
        COUNT(CASE WHEN MONTH(trip_date) IN (1, 2, 3, 4, 5, 6) THEN 1 END) AS first_half_avg,
        
        SUM(CASE WHEN MONTH(trip_date) IN (7, 8, 9, 10, 11, 12) THEN distance_km/fuel_consumed END) / 
        COUNT(CASE WHEN MONTH(trip_date) IN (7, 8, 9, 10, 11, 12) THEN 1 END) AS second_half_avg
    FROM drivers
    JOIN trips
        ON drivers.driver_id = trips.driver_id
    GROUP BY drivers.driver_id
    -- Ensure driver participated in both periods and improved
    HAVING first_half_avg IS NOT NULL 
       AND second_half_avg IS NOT NULL 
       AND second_half_avg > first_half_avg
)

SELECT
    driver_id,
    driver_name,
    ROUND(first_half_avg, 2) AS first_half_avg,
    ROUND(second_half_avg, 2) AS second_half_avg,
    ROUND(second_half_avg - first_half_avg, 2) AS efficiency_improvement
FROM tmp_table
ORDER BY efficiency_improvement DESC, driver_name ASC;
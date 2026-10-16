/* =====================================================================================
   ANALYTICS DRILL: Multi-Window Peak Hour & Rating Completion Analysis
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Time Interval Extraction (`TIME`), Multi-Range Conditional Proportions, 
      & Data Quality Threshold Filtering (`HAVING`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      When business logic requires evaluating multiple disjoint time windows (e.g., lunch and dinner 
      peaks) alongside data completeness metrics (like percentage of orders that actually received a rating), 
      you must combine precise time casting with parallel conditional ratios.

      - Time Component Extraction (`TIME(order_timestamp)`): Strips away the date portion to isolate 
        the exact time string, allowing direct string/time comparisons against boundaries like `'11:00:00'`.
      - Multi-Interval Conditional Sums: Using multiple `WHEN` branches inside a single `CASE` statement 
        captures hits across different peak blocks (lunch vs. dinner) into a unified numerator.
      - Data Quality Metrics (`ordered_rating`): Calculating the proportion of non-null ratings 
        (`SUM(CASE WHEN order_rating IS NOT NULL THEN 1 END) / COUNT(order_id)`) ensures you filter out 
        customers with insufficient feedback data.
      - Multi-Constraint `HAVING` Clause: Enforces all business volume, percentage, and rating thresholds 
        simultaneously on the aggregated rows.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How do I check timestamps against multiple separate time blocks in a day?" 
        Extract the time component using `TIME()` and use explicit boundary checks or `BETWEEN` logic.
      - Question B: "How do I enforce completeness rules on optional fields?" 
        Compute a completion ratio metric (`NOT NULL` count divided by total count) and treat it 
        just like any other threshold filter in your `HAVING` clause.
      - Question C: "Where should final sorting (`ORDER BY`) live?" 
        Sorting belongs in the final projection query where results are materialized for display, 
        not buried inside an intermediate CTE.

   4. COMMON PITFALLS TO AVOID:
      - Forgetting to scale your percentage numerators by `100` when comparing against percentage thresholds (e.g., `>= 60`).
      - Placing `ORDER BY` inside a CTE where it has no effect unless accompanied by a `LIMIT` clause.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
WITH tmp_table AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        (SUM(CASE WHEN '11:00:00' <= TIME(order_timestamp) AND '14:00:00' >= TIME(order_timestamp) THEN 1
             WHEN '18:00:00' <= TIME(order_timestamp) AND '21:00:00' >= TIME(order_timestamp) THEN 1
             END) / COUNT(order_id)) * 100 AS peak_hour_percentage,
        ROUND(AVG(order_rating), 2) AS average_rating,
        (SUM(CASE WHEN order_rating IS NOT NULL THEN 1 END) / COUNT(order_id)) * 100 AS ordered_rating
    FROM restaurant_orders
    GROUP BY customer_id
    HAVING total_orders >= 3 
       AND peak_hour_percentage >= 60 
       AND ordered_rating >= 50 
       AND average_rating >= 4
    ORDER BY average_rating DESC, customer_id DESC
)
SELECT
    customer_id,
    total_orders,
    ROUND(peak_hour_percentage, 0) AS peak_hour_percentage,
    average_rating
FROM tmp_table;


/* =====================================================================================
   OPTIMAL & REFINED APPROACH (Cleaner Syntax & Logical Flow)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Streamlined Time Ranges: Replaced verbose manual inequality chains with clean `BETWEEN` syntax.
   2. Floating-Point Safety: Used `1.00` in the conditional sum to guarantee floating-point division.
   3. Proper Sorting Placement: Moved the `ORDER BY` clause to the final outer query where sorting 
      is structurally intended to execute.
   ===================================================================================== */

/*
WITH optimized_metrics AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        -- Use BETWEEN for cleaner, more readable time-window boundary checks
        (SUM(CASE 
            WHEN TIME(order_timestamp) BETWEEN '11:00:00' AND '14:00:00' THEN 1.00
            WHEN TIME(order_timestamp) BETWEEN '18:00:00' AND '21:00:00' THEN 1.00
        END) / COUNT(order_id)) * 100 AS peak_hour_percentage,
        AVG(order_rating) AS average_rating,
        (SUM(CASE WHEN order_rating IS NOT NULL THEN 1.00 END) / COUNT(order_id)) * 100 AS ordered_rating
    FROM restaurant_orders
    GROUP BY customer_id
    HAVING total_orders >= 3 
       AND peak_hour_percentage >= 60 
       AND ordered_rating >= 50 
       AND average_rating >= 4.00
)
SELECT
    customer_id,
    total_orders,
    ROUND(peak_hour_percentage, 0) AS peak_hour_percentage,
    ROUND(average_rating, 2) AS average_rating
FROM optimized_metrics
-- Sorting executed in the outer layer for proper global result ordering
ORDER BY average_rating DESC, customer_id DESC;
*/
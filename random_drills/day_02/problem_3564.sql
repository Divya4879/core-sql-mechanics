/* =====================================================================================
   LEETCODE 3564: Seasonal Sales Analysis
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Date Categorization (`CASE` + `MONTH`), Multi-Metric Aggregation, 
      Partitioned Ranking (`PARTITION BY` + `RANK`), & Deterministic Tie-Breaking
      
   2. CORE INSIGHT & CODE MECHANICS:
      When business requirements ask for "Top-1 per group" analysis based on complex business metrics 
      (e.g., finding the most popular product category per season based on quantity, then revenue, 
      then alphabetical name), you need a structured multi-phase pipeline.

      - Date Feature Engineering (`CASE` on `MONTH()`): Maps continuous calendar months into discrete 
        business seasons (Winter: Dec-Feb, Spring: Mar-May, Summer: Jun-Aug, Fall: Sep-Nov).
      - Multi-Metric Aggregations: Computes total volume (`SUM(quantity)`) and total revenue 
        (`SUM(price * quantity)`) grouped by the derived season and product category.
      - Partitioned Ranking with Tie-Breaking: Uses `RANK() OVER (PARTITION BY season ORDER BY ...)` 
        to assign ranks within each season independently. Passing multiple sort variables (`total_qty DESC, 
        total_revenue DESC, category ASC`) ensures deterministic tie-breaking.
      - Multi-Stage CTE Pipeline: Isolates aggregation in Phase 1 and ranking evaluation in Phase 2, 
        allowing the outer query to easily filter `WHERE rank = 1`.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How do I group continuous dates into custom calendar periods like seasons?" 
        Use a `CASE` statement checking `MONTH(date)` ranges to bucket rows dynamically.
      - Question B: "How do I handle complex tie-breaker rules for 'Top-1' rankings?" 
        Always pack your `ORDER BY` clause inside your window function with hierarchical secondary and 
        tertiary sort keys (e.g., volume $\rightarrow$ revenue $\rightarrow$ alphabetical name).
      - Question C: "Why use multiple CTEs?" 
        Breaking heavy math (aggregations) and analytical scoring (ranking) into sequential steps makes 
        complex queries easy to debug step-by-step.

   4. COMMON PITFALLS TO AVOID:
      - Crossing calendar year boundaries improperly when evaluating winter months (December belongs to the 
        upcoming winter season, handled cleanly by checking `IN (12, 1, 2)`).
      - Redundant grouping: Grouping in both the CTE and the ranking step when the CTE has already aggregated 
        the base metrics.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
WITH tmp_table AS (
    SELECT
        CASE WHEN MONTH(sale_date) IN (12, 1, 2) THEN 'Winter'
             WHEN MONTH(sale_date) IN (3, 4, 5) THEN 'Spring'
             WHEN MONTH(sale_date) IN (6, 7, 8) THEN 'Summer'
             ELSE 'Fall'
        END AS season,
        SUM(quantity) AS total_qty,
        SUM(price * quantity) AS total_revenue,
        category
    FROM sales
    JOIN products
        ON sales.product_id = products.product_id
    GROUP BY season, category
),

tmp_table_1 AS (
    SELECT
        season,
        category,
        total_qty AS total_quantity,
        total_revenue,
        RANK() OVER (PARTITION BY season ORDER BY total_qty DESC, total_revenue DESC, category ASC) AS `rank`
    FROM tmp_table
    GROUP BY season, category
)

SELECT
    season,
    category,
    total_quantity,
    total_revenue
FROM tmp_table_1
WHERE `rank` = 1
ORDER BY season ASC;


/* =====================================================================================
   OPTIMAL & REFINED APPROACH (Single-CTE Streamlined Architecture)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Eliminated Redundant Grouping: Your original solution included a `GROUP BY season, category` 
      inside `tmp_table_1`. Since `tmp_table` was already fully aggregated by season and category, 
      ranking can be applied directly without a second grouping pass.
   2. Streamlined Pipeline: Collapses the logic into a single clean CTE before filtering for rank 1.
   ===================================================================================== */

/*
WITH ranked_seasonal_sales AS (
    SELECT
        CASE WHEN MONTH(sale_date) IN (12, 1, 2) THEN 'Winter'
             WHEN MONTH(sale_date) IN (3, 4, 5) THEN 'Spring'
             WHEN MONTH(sale_date) IN (6, 7, 8) THEN 'Summer'
             ELSE 'Fall'
        END AS season,
        category,
        SUM(quantity) AS total_quantity,
        SUM(price * quantity) AS total_revenue,
        -- Apply ranking directly over the aggregated window partition without a second group-by pass
        RANK() OVER (
            PARTITION BY CASE WHEN MONTH(sale_date) IN (12, 1, 2) THEN 'Winter'
                               WHEN MONTH(sale_date) IN (3, 4, 5) THEN 'Spring'
                               WHEN MONTH(sale_date) IN (6, 7, 8) THEN 'Summer'
                               ELSE 'Fall'
                          END 
            ORDER BY SUM(quantity) DESC, SUM(price * quantity) DESC, category ASC
        ) as rnk
    FROM sales
    JOIN products ON sales.product_id = products.product_id
    GROUP BY season, category
)
SELECT
    season,
    category,
    total_quantity,
    total_revenue
FROM ranked_seasonal_sales
WHERE rnk = 1
ORDER BY season ASC;
*/
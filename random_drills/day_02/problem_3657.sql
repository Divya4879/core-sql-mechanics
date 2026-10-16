/* =====================================================================================
   LEETCODE 3657: Find Loyal Customers
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Multi-Metric Conditional Aggregations, Ratio Computations, & Tenure/Date Span Filtering
      
   2. CORE INSIGHT & CODE MECHANICS:
      Complex business logic often requires validating multiple independent constraints per entity 
      simultaneously (e.g., activity volume thresholds, percentage limits, and temporal lifespan). 
      Instead of writing complex self-joins or multiple subqueries, you can compute all metrics in a 
      single pass using **Conditional Aggregation inside a CTE pipeline**.

      - Multi-Target Conditional Sums: Using `SUM(CASE WHEN transaction_type = 'purchase' THEN 1 END)` 
        allows you to isolate and count specific transactional behaviors independently within the same group.
      - Ratio & Percentage Calculations: By dividing conditional counts by total counts (`COUNT(transaction_id)`) 
        and scaling by 100, you compute clean percentage rates directly in the query stream.
      - Tenure / Date Span Validation: Evaluating the time delta between an entity's first and last event 
        (`DATEDIFF(MAX(transaction_date), MIN(transaction_date))` or date subtraction) lets you verify 
        customer longevity or activity duration without complex window frames.
      - Two-Phase Filtering: Aggregating all metrics inside a CTE allows the outer query to cleanly filter 
        by business rules (e.g., refund rate thresholds).

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How do I calculate multiple different types of counts (e.g., purchases vs. refunds) 
        from a single flat transaction table?" 
        Never split them into separate queries; use parallel `CASE WHEN` statements inside aggregate functions.
      - Question B: "How do I measure an entity's lifespan or active duration?" 
        Compare the temporal extremes of their activity using `MAX(date) - MIN(date)` or engine-specific 
        date difference functions (`DATEDIFF`).
      - Question C: "Why structure this as a CTE?" 
        Isolating complex ratio calculations and thresholds in a CTE makes debugging metrics trivial 
        before applying final sorting or filtering.

   4. COMMON PITFALLS TO AVOID:
      - Integer Division Traps: When calculating percentages (`part * 100 / total`), ensure integer math 
        doesn't truncate your decimals prematurely depending on the SQL dialect.
      - Forgetting to handle `NULL` outputs from conditional sums when entities have zero occurrences of a sub-type.
   ===================================================================================== */

WITH customer_metrics AS (
    SELECT 
        customer_id,
        -- Metric 1: Count total purchase transactions
        SUM(CASE WHEN transaction_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
        -- Metric 2: Calculate refund rate percentage (Refunds / Total Transactions * 100)
        (SUM(CASE WHEN transaction_type = 'refund' THEN 1 ELSE 0 END) * 100.0) / COUNT(transaction_id) AS refund_rate,
        -- Metric 3: Calculate active customer lifespan in days (Delta between first and last transaction)
        DATEDIFF(MAX(transaction_date), MIN(transaction_date)) AS active_span_days
    FROM customer_transactions
    GROUP BY customer_id
)
SELECT 
    customer_id
FROM customer_metrics
-- Apply business logic thresholds for loyalty qualification
WHERE purchase_count >= 3
  AND active_span_days >= 30
  AND refund_rate < 20
ORDER BY customer_id ASC;
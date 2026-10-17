/* =====================================================================================
   LEETCODE 3716: Find Churn Risk Customers (Day 3 Drill)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Latest State Identification (Windowing / Correlated Subquery), Historical Max Aggregation, 
      & Multi-Condition Business Rule Filtering
      
   2. CORE INSIGHT & CODE MECHANICS:
      Complex time-series analytics (like subscription tracking) often require combining two opposing views:
      - Historical View (The Lifetime Summary): Looking across all past events for a user to calculate 
        total lifespan (`DATEDIFF(MAX, MIN)`), historical peak spend (`MAX`), and behavior counts (downgrades).
      - Current Snapshot View (The Latest State): Isolating only the user's *most recent* active event 
        to see their current plan, current price, and ensure they haven't canceled.

      - Correlated Latest-State Isolation: Using a subquery ordered by `event_date DESC, event_id DESC LIMIT 1` 
        ensures you pin down the exact latest event per user, even if multiple events share the same timestamp.
      - Ratio Threshold Analysis: Comparing current monthly amount against historical peak (`monthly_amount / max_historical_amount < 0.5`) 
        flags customers who have drastically reduced their financial commitment.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF (BUILDING INTUITION):
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Does this business rule apply to the user's entire history, or only their *current* state?" 
        Separate your logic: use an aggregate CTE for lifetime metrics (tenure, max spend), but anchor your 
        final table join strictly to the user's latest event record.
      - Question B: "How do I safely extract the latest record per entity when timestamps can tie?" 
        Always include a secondary tie-breaker column (like `event_id DESC`) alongside your date ordering 
        to ensure deterministic, stable results.

   4. COMMON PITFALLS TO AVOID:
      - Forgetting to filter out canceled subscriptions (`event_type != 'cancel'`), which can incorrectly 
        mark churned/inactive users as active churn risks.
      - Using aggregate `MAX(monthly_amount)` in the final select when you actually need the *current* 
        plan's amount rather than the historical peak.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
WITH tmp_table AS (
    SELECT
        user_id,
        DATEDIFF(MAX(event_date), MIN(event_date)) AS days_as_subscriber,
        MAX(monthly_amount) AS max_historical_amount,
        SUM(CASE WHEN event_type = 'downgrade' THEN 1 ELSE 0 END) AS downgrades
    FROM subscription_events
    GROUP BY user_id
    HAVING downgrades >= 1
)

SELECT
    a.user_id,
    a.plan_name AS current_plan,
    a.monthly_amount AS current_monthly_amount,
    b.max_historical_amount,
    b.days_as_subscriber
FROM subscription_events a
JOIN tmp_table b ON a.user_id = b.user_id
WHERE 
    a.event_id = (
        SELECT sub.event_id 
        FROM subscription_events sub 
        WHERE sub.user_id = a.user_id 
        ORDER BY sub.event_date DESC, sub.event_id DESC 
        LIMIT 1
    )
    -- Rule 1: The current subscription must be active (not canceled)
    AND a.event_type != 'cancel'
    -- Rule 2: Subscribed for at least 60 days
    AND b.days_as_subscriber >= 60 
    -- Rule 3: Current monthly amount is less than 50% of the historical maximum
    AND a.monthly_amount / b.max_historical_amount < 0.5
ORDER BY 
    b.days_as_subscriber DESC, 
    a.user_id ASC;


/* =====================================================================================
   OPTIMAL & REFINED APPROACH (Window Function for Latest State)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Replaced Correlated Subquery with `ROW_NUMBER()`: Instead of running a nested subquery for every 
      single row, a window function partitions and ranks events per user in a single pass (`rnk = 1`), 
      which is generally much more performant on large datasets.
   ===================================================================================== */

/*
WITH historical_summary AS (
    SELECT
        user_id,
        DATEDIFF(MAX(event_date), MIN(event_date)) AS days_as_subscriber,
        MAX(monthly_amount) AS max_historical_amount,
        SUM(CASE WHEN event_type = 'downgrade' THEN 1 ELSE 0 END) AS downgrades
    FROM subscription_events
    GROUP BY user_id
    HAVING downgrades >= 1
),
latest_events AS (
    SELECT
        user_id,
        event_id,
        plan_name,
        monthly_amount,
        event_type,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date DESC, event_id DESC) AS rnk
    FROM subscription_events
)
SELECT
    le.user_id,
    le.plan_name AS current_plan,
    le.monthly_amount AS current_monthly_amount,
    hs.max_historical_amount,
    hs.days_as_subscriber
FROM latest_events le
JOIN historical_summary hs ON le.user_id = hs.user_id
WHERE le.rnk = 1
  AND le.event_type != 'cancel'
  AND hs.days_as_subscriber >= 60
  AND le.monthly_amount / hs.max_historical_amount < 0.5
ORDER BY 
    hs.days_as_subscriber DESC, 
    le.user_id ASC;
*/
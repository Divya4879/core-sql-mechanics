/* =====================================================================================
   LEETCODE 3586: Find COVID Recovery Patients
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Temporal Event Tracking, Anchor Pre-Aggregation, & Minimum Positive Delta
      
   2. 🚨 PITFALLS, WEAKNESSES, & TRAPS (Analysis of Original Failing Code):
      Your original code fell into two massive SQL traps that are common when dealing with 
      dates and time-series events:

      - TRAP 1: The Cartesian Date Explosion (Many-to-Many Join)
        You joined `covid_tests a` (Positive) directly to `covid_tests b` (Negative). 
        If a patient tested Positive on Jan 1 and Jan 10, and Negative on Jan 5 and Jan 12, 
        your join creates 4 rows (every positive matched with every negative). 
        The gap between Jan 10 (Positive) and Jan 12 (Negative) is 2 days. 
        The gap between Jan 1 (First Positive) and Jan 5 (First Negative) is 4 days.
        Because your `RANK()` function blindly looked for the smallest `recovery_time`, it 
        would incorrectly select the 2-day gap, completely ignoring the business rule to 
        calculate from the *first* positive test.

      - TRAP 2: ORDER BY Inside a CTE
        In `tmp_table_2`, you wrote `ORDER BY recovery_time ASC` inside the CTE. 
        In relational databases, tables and CTEs are mathematically unordered sets. The SQL 
        engine will almost always ignore an `ORDER BY` inside a CTE unless it is paired with 
        a `LIMIT`. Final sorting must ALWAYS be pushed to the absolute outermost `SELECT` block.

   3. CORE INSIGHT & CODE MECHANICS (The Optimized Strategy):
      To calculate the time between a specific Milestone A and Milestone B, you must 
      lock in Milestone A *before* you do the math.
      
      - Phase 1 (The Anchor Lock): The subquery `SELECT patient_id, MIN(test_date)` isolates 
        a single row per patient—their absolute first positive test. This becomes our Anchor.
      - Phase 2 (The Forward Search): We join the Anchor to all of the patient's negative tests, 
        and apply `HAVING recovery_time > 0`. This instantly filters out any negative tests that 
        happened *before* the first positive test.
      - Phase 3 (The Shortest Distance): Now that the start date is locked, we just need the 
        *first* negative test that happened after it. Using `RANK() OVER(ORDER BY recovery_time ASC)` 
        finds the smallest gap, which by definition gives us the chronological first negative test.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "How do I measure the time between a user's First Action and their Next Action?"
        NEVER join the raw action table to itself directly. ALWAYS write a subquery/CTE to isolate 
        the `MIN(date)` of the First Action, and use that locked date as the foundation for your joins.
   ===================================================================================== */

-- =====================================================================================
-- THE CORRECTED & OPTIMIZED APPROACH (Anchor Lock Method)
-- =====================================================================================
WITH tmp_table AS (
    SELECT
        patients.patient_id AS patient_id,
        patient_name,
        age,
        DATEDIFF(b.test_date, a.test_date) AS recovery_time
    FROM patients
    -- STEP 1: Anchor Lock. Force table 'a' to strictly be the FIRST positive test.
    JOIN (
        SELECT 
            patient_id, 
            MIN(test_date) AS test_date 
        FROM covid_tests 
        WHERE result = 'Positive' 
        GROUP BY patient_id
    ) a ON a.patient_id = patients.patient_id
    
    -- STEP 2: Forward Search. Join to negative tests.
    JOIN covid_tests b
        ON b.patient_id = a.patient_id 
        AND b.result = 'Negative'
    -- Ensure the negative test happened strictly AFTER the first positive test
    HAVING recovery_time > 0
),

tmp_table_2 AS (
    SELECT
        patient_id,
        patient_name,
        age,
        recovery_time,
        -- STEP 3: Shortest Distance. The smallest recovery time is the first chronological negative test.
        RANK() OVER(PARTITION BY patient_id ORDER BY recovery_time ASC) AS rnk
    FROM tmp_table
)

SELECT
    patient_id,
    patient_name,
    age,
    recovery_time
FROM tmp_table_2
WHERE rnk = 1
-- Move the final cosmetic sorting to the absolute outermost query
ORDER BY 
    recovery_time ASC, 
    patient_name ASC;
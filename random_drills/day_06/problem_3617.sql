/* =====================================================================================
   LEETCODE 3617: Find Students with Study Spiral Pattern (PostgreSQL)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Time-Series Pattern Matching, Sequence Recognition, & The Modulo Cycle Theorem
      
   2. THE POSTGRESQL UPGRADE (Why it's better than MySQL here):
      - Native Date Math: In MySQL, you must use `DATEDIFF(date1, date2)`. In PostgreSQL, 
        dates are strongly typed math objects. You simply write `session_date - prev_date` 
        and Postgres natively returns an `INTEGER` of the days between them.
      - Strong Grouping: Postgres handles multi-column grouping perfectly, allowing us 
        to pass pre-calculated aggregates down the pipeline without messy subqueries.

   3. CORE INSIGHT: THE PERFECT CYCLE THEOREM (No Self-Joins Required!)
      How do we prove a student studies an exact repeating sequence (e.g., Math, Physics, Chem) 
      without joining the table to itself? We use Modulo Math (`%`).
      
      Imagine a cycle length of 3 (N = 3).
      If we assign a chronological Row Number (`rn`) to every session and apply `rn % 3`, 
      we get a repeating index:
      rn = 1 -> 1 % 3 = 1  (Math)
      rn = 2 -> 2 % 3 = 2  (Physics)
      rn = 3 -> 3 % 3 = 0  (Chem)
      rn = 4 -> 4 % 3 = 1  (Math)
      rn = 5 -> 5 % 3 = 2  (Physics)
      rn = 6 -> 6 % 3 = 0  (Chem)

      Notice the magic: Every modulo result (1, 2, 0) maps to EXACTLY ONE unique subject.
      If the sequence broke (e.g., they studied Math at rn=5), then `rn % 3 = 2` would be 
      mapped to both Physics AND Math. 
      
      Therefore, to prove a perfect repeating spiral, we just count the distinct combinations 
      of `(rn % cycle_length)` and `subject`. If that count exactly equals the `cycle_length`, 
      the sequence is mathematically proven to be a perfect loop!

   4. 🧠 THE MENTAL MODEL FOR YOUR PYTHON BACKEND CAREER:
      - Diagnostic Question: "I need to find a repeating chronological sequence in my data."
        NEVER use a self-join. 
        ALWAYS use: `COUNT(DISTINCT CONCAT(row_number % sequence_length, subject)) = sequence_length`.
        This reduces an $O(N^2)$ heavy database scan into a lightning-fast $O(N)$ linear scan.
   ===================================================================================== */

WITH StudentStats AS (
    -- Phase 1: Aggregate core metrics at the student level.
    -- We find the cycle length (distinct subjects) and total hours instantly.
    SELECT 
        student_id,
        COUNT(DISTINCT subject) AS cycle_length,
        COUNT(*) AS total_sessions,
        SUM(hours_studied) AS total_hours
    FROM study_sessions
    GROUP BY student_id
),

SessionData AS (
    -- Phase 2: Add chronological row numbers and calculate date gaps.
    SELECT 
        ss.student_id,
        ss.subject,
        ss.session_date,
        st.cycle_length,
        st.total_hours,
        -- Generate chronological sequence ID
        ROW_NUMBER() OVER(PARTITION BY ss.student_id ORDER BY ss.session_date ASC) AS rn,
        -- Grab the previous date to calculate gaps
        LAG(ss.session_date) OVER(PARTITION BY ss.student_id ORDER BY ss.session_date ASC) AS prev_date
    FROM study_sessions ss
    JOIN StudentStats st ON ss.student_id = st.student_id
    -- Optimization: Instantly filter out students who don't meet the absolute minimums
    WHERE st.cycle_length >= 3 
      AND st.total_sessions >= (2 * st.cycle_length)
),

ValidStudents AS (
    -- Phase 3: The Modulo Math Validation
    SELECT 
        student_id,
        cycle_length,
        total_hours
    FROM SessionData
    GROUP BY student_id, cycle_length, total_hours
    HAVING 
        -- Rule 1: No gaps longer than 2 days. 
        -- Postgres Native Math: (Date - Date) directly yields an integer.
        COALESCE(MAX(session_date - prev_date), 0) <= 2
        
        -- Rule 2: The Perfect Cycle Theorem.
        -- We concatenate the modulo index with the subject. If it's a perfect spiral, 
        -- there will be exactly 'cycle_length' unique combinations.
        AND COUNT(DISTINCT CONCAT(rn % cycle_length, '-', subject)) = cycle_length
)

-- Phase 4: Final Assembly with Student Names
SELECT 
    v.student_id,
    s.student_name,
    s.major,
    v.cycle_length,
    v.total_hours
FROM ValidStudents v
JOIN students s ON v.student_id = s.student_id
ORDER BY 
    v.cycle_length DESC, 
    v.total_hours DESC;
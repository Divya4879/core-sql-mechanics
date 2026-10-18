/* =====================================================================================
   LEETCODE 601: Human Traffic of Stadium (Hard)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      The "Gaps and Islands" Problem, Consecutive Sequences, & Windowed Counts
      
   2. 🚨 PITFALLS, WEAKNESSES, & TRAPS (Analysis of Original Code):
      Your positional logic (Case 1, 2, and 3) is mathematically perfect for finding 
      blocks of 3. However, the execution falls into a massive performance trap:
      
      - The Subquery Swamp: You used `IN (SELECT id FROM tmp_table)` nine separate times 
        in your `WHERE` clause. For every single row in the stadium table, the database engine 
        has to pause and run up to 9 subqueries to check if the surrounding IDs exist. 
        On a table with 100,000 rows, this triggers almost a million subquery executions. 
        It works on LeetCode's small test cases, but it will bring a production database to its knees.
      - The Hardcoded Limit: Your logic strictly checks for exactly 3 days. What if the business 
        asks for 7 consecutive days tomorrow? You would have to write 7 massive `OR` blocks 
        with 49 subqueries.

   3. CORE INSIGHT & CODE MECHANICS (The "Gaps and Islands" Strategy):
      Instead of making every row look sideways to check its neighbors, we use the 
      Magic Island Formula (`id - ROW_NUMBER()`) to group consecutive days together instantly.

      How the math works here:
      Original IDs > 100:  [2, 3, 5, 6, 7, 8]  (Notice ID 4 is missing, breaking the streak)
      ROW_NUMBER():        [1, 2, 3, 4, 5, 6]
      
      Subtracting ROW_NUMBER from ID:
      ID 2 - RN 1 = Island 1
      ID 3 - RN 2 = Island 1   --> (Streak of 2)
      -- gap --
      ID 5 - RN 3 = Island 2
      ID 6 - RN 4 = Island 2
      ID 7 - RN 5 = Island 2
      ID 8 - RN 6 = Island 2   --> (Streak of 4)

      Once they are grouped into Islands, we just use a Windowed `COUNT()` to see which 
      Islands have 3 or more members, and filter the result.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "Am I trying to find consecutive rows (dates or IDs) that meet a condition?"
        IMMEDIATELY deploy the Gaps and Islands formula. 
        `island_id = id - ROW_NUMBER() OVER(ORDER BY id)`
        Do not hardcode offsets (`id - 1`, `id + 1`). Let the math group the streaks for you.
   ===================================================================================== */

-- =====================================================================================
-- THE OPTIMAL APPROACH (Gaps and Islands Architecture)
-- =====================================================================================
WITH valid_days AS (
    -- STEP 1: Filter out the noise and create the Islands
    SELECT 
        id, 
        visit_date, 
        people,
        -- The Magic Formula: groups strictly consecutive IDs together
        id - ROW_NUMBER() OVER (ORDER BY id ASC) AS island_grp
    FROM Stadium
    WHERE people >= 100
),

island_counts AS (
    -- STEP 2: Count how many days are in each Island without collapsing the rows
    SELECT 
        id, 
        visit_date, 
        people,
        -- Windowed COUNT allows us to append the island's total size to every row
        COUNT(id) OVER (PARTITION BY island_grp) AS streak_length
    FROM valid_days
)

-- STEP 3: Filter for the business rule
SELECT 
    id, 
    visit_date, 
    people
FROM island_counts
WHERE streak_length >= 3
ORDER BY visit_date ASC;


/* =====================================================================================
   YOUR ORIGINAL APPROACH (The Positional Sliding Window)
   =====================================================================================
   Note for future review: This is combinatorial brute-force. It proves you understand 
   the mathematical relationships of a 3-day sliding window, but it relies on heavy 
   subqueries. Keep it here to remind yourself of how far you've come from brute-force 
   to optimal architectures.
   ===================================================================================== */
/*
WITH tmp_table AS (
    SELECT id, visit_date, people
    FROM Stadium
    WHERE people >= 100
)
SELECT id, visit_date, people
FROM tmp_table
WHERE 
    -- Case 1: End of a 3-day block
    (id IN (SELECT id FROM tmp_table) AND id - 1 IN (SELECT id FROM tmp_table) AND id - 2 IN (SELECT id FROM tmp_table))
    OR 
    -- Case 2: Start of a 3-day block
    (id IN (SELECT id FROM tmp_table) AND id + 1 IN (SELECT id FROM tmp_table) AND id + 2 IN (SELECT id FROM tmp_table))
    OR 
    -- Case 3: Middle of a 3-day block
    (id - 1 IN (SELECT id FROM tmp_table) AND id IN (SELECT id FROM tmp_table) AND id + 1 IN (SELECT id FROM tmp_table))
ORDER BY visit_date ASC;
*/
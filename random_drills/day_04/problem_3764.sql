/* =====================================================================================
   LEETCODE 3764: Most Common Course Pairs (Sequence Analysis)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Sequential Transition Analysis (Markov-style pairing), Pre-Filtering (Subqueries), 
      & Next-Event Tracking (`LEAD` vs Self-Joins)
      
   2. CORE INSIGHT & CODE MECHANICS:
      To find the most common "pathways" or transitions (Course A -> Course B), you must first 
      sequence a user's history chronologically, and then map each event to the event that 
      immediately followed it.

      - The User's Self-Join Method: You generated an explicit mathematical sequence (`rnk = 1, 2, 3`) 
        and joined the table to itself offset by 1 (`a.rnk = b.rnk - 1`). This is a perfectly valid 
        relational algebra approach to generate A->B pairs.
      - Pre-Filtering: Calculating the "Top Students" in a separate CTE and using `WHERE user_id IN (...)` 
        is an excellent optimization to ensure you don't waste compute power sequencing the histories 
        of users who don't qualify.

   3. ⚡ THE RANKING CRASH COURSE (HOW TO CHOOSE):
      Imagine 3 students taking a test. Their scores are 100, 100, and 90.

      A. ROW_NUMBER() -> Result: 1, 2, 3
         - What it does: Forces a strict, unique, unbroken integer sequence. Ties are broken arbitrarily.
         - WHEN TO USE IT: Use for Mathematical Sequencing (like your `a.rnk = b.rnk - 1` join) 
           or Deduplication. If you need a continuous gapless line to do math on, use `ROW_NUMBER`. 
           (Note: If you used DENSE_RANK on a tie, you'd get 1, 1. A self join on `rnk - 1` would cause 
           a many-to-many Cartesian explosion. ROW_NUMBER prevents this).

      B. RANK() -> Result: 1, 1, 3
         - What it does: The Olympic Medal system. Two Golds mean no Silver. The next person gets Bronze.
         - WHEN TO USE IT: Use for Leaderboards ("Give me the top 3 highest paid employees"). 
           If two tie for 1st, the next guy is truly in 3rd place. 

      C. DENSE_RANK() -> Result: 1, 1, 2
         - What it does: The Tier/Bracket system. Two people are in Tier 1. The next person is in Tier 2.
         - WHEN TO USE IT: Use for Brackets ("Give me the 2nd highest salary in the company"). 
           If the top two CEOs make $500k (Rank 1, 1), the VP making $400k is the 2nd highest salary (Rank 2).

   4. COMMON PITFALLS TO AVOID:
      - Using `RANK()` when doing offset math (`rnk - 1`). If `RANK` skips a number (1, 1, 3), your 
        `b.rnk - 1` logic will look for `2` and fail to join entirely, breaking the sequence.
      - Calculating heavy window functions before filtering out irrelevant users.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE (The Self-Join Offset Method)
-- =====================================================================================
WITH students AS(
    SELECT
        user_id,
        COUNT(course_id) AS cnt,
        AVG(course_rating) AS avg_grade
    FROM course_completions
    GROUP BY user_id
    HAVING cnt >= 5 AND avg_grade >= 4
),

tmp_table AS(
    SELECT
        user_id,
        course_name,
        -- DENSE_RANK works here assuming unique completion dates. 
        -- For robust production systems, ROW_NUMBER() is safer for offset math.
        DENSE_RANK() OVER (PARTITION BY user_id ORDER BY completion_date ASC) AS rnk
    FROM course_completions 
    WHERE user_id IN (SELECT user_id FROM students)
)

SELECT
    a.course_name AS first_course,
    b.course_name AS second_course,
    COUNT(*) AS transition_count
FROM tmp_table a
JOIN tmp_table b
    ON a.user_id = b.user_id AND a.rnk = b.rnk - 1
GROUP BY first_course, second_course
ORDER BY transition_count DESC, first_course ASC, second_course ASC;


/* =====================================================================================
   OPTIMAL & REFINED APPROACH (The LEAD() Window Function)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Eliminated the Self-Join: Self-joining a table to itself on an offset rank is slow 
      and prone to duplicate-tie bugs. 
   2. LEAD(): The `LEAD(course_name) OVER (...)` function automatically looks at the very next 
      row in the chronological partition and pulls its value into the current row. This 
      creates your (First Course, Second Course) pair instantly without any joins or manual ranking.
   ===================================================================================== */

/*
WITH TopStudents AS (
    SELECT user_id
    FROM course_completions
    GROUP BY user_id
    HAVING COUNT(course_id) >= 5 AND AVG(course_rating) >= 4
),
SequencedCourses AS (
    SELECT
        user_id,
        course_name AS first_course,
        -- LEAD() grabs the next chronological course_name and puts it on the same row
        LEAD(course_name) OVER(PARTITION BY user_id ORDER BY completion_date ASC) AS second_course
    FROM course_completions
    WHERE user_id IN (SELECT user_id FROM TopStudents)
)
SELECT
    first_course,
    second_course,
    COUNT(*) AS transition_count
FROM SequencedCourses
-- Filter out the final course in a user's journey (which has no 'second_course' after it)
WHERE second_course IS NOT NULL
GROUP BY first_course, second_course
ORDER BY 
    transition_count DESC, 
    first_course ASC, 
    second_course ASC;
*/
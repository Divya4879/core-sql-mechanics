/* =====================================================================================
   LEETCODE 3580: Find Consistently Improving Employees
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Sequential Row Comparison, Time-Series Self-Joins, & Offset Window Functions (`LEAD`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      When business logic requires checking a strict consecutive sequence (e.g., "did performance 
      improve over the last 3 consecutive reviews?"), you must compare a row against its immediate 
      historical predecessors.

      - The Self-Join Strategy (User Solution): By ranking reviews chronologically (`ORDER BY review_date DESC`), 
        you can join the table to itself multiple times, hardcoding the relationship between the latest 
        (`rnk = 1`), the previous (`rnk = 2`), and the oldest (`rnk = 3`). This explicitly pivots the last 
        three reviews into a single row for direct mathematical comparison.
      - Alias Filtering (`HAVING`): In MySQL, you can use `HAVING` without a `GROUP BY` to filter directly 
        on calculated alias columns (like `improvement_score_1`) in the same `SELECT` block, saving you 
        from writing an additional outer wrapper query.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How do I compare an event to the event that happened right before it?" 
        You have two choices: Self-join on `rank = rank - 1`, OR use the `LEAD()` / `LAG()` window functions.
      - Question B: "What if an employee has fewer than 3 reviews?" 
        Because the self-join approach uses `INNER JOIN` on `rnk = 2` and `rnk = 3`, employees with only 
        1 or 2 reviews are naturally dropped from the dataset. It acts as an implicit filter!

   4. COMMON PITFALLS TO AVOID:
      - Trying to use `MAX()` and `MIN()` dates: This fails because you specifically need the 1st, 2nd, 
        and 3rd latest reviews, not just the absolute bounds of their history.
      - Filtering aliases in a `WHERE` clause: Standard SQL evaluates `WHERE` before `SELECT`, so aliases 
        don't exist yet. MySQL allows `HAVING` as a workaround, but `LEAD/LAG` is cleaner for production.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE (Multi-Self-Join Pivot)
-- =====================================================================================
WITH tmp_table AS(
    SELECT
        employees.employee_id,
        name,
        review_date,
        RANK() OVER(PARTITION BY employee_id ORDER BY review_date DESC) AS rnk,
        rating
    FROM performance_reviews
    JOIN employees
    ON employees.employee_id = performance_reviews.employee_id
),

tmp_table_2 AS(
    SELECT
        a.employee_id AS employee_id,
        a.name AS name,
        a.rating - b.rating AS improvement_score_1,
        b.rating - c.rating AS improvement_score_2,
        a.rating - c.rating AS improvement_score
    FROM tmp_table a
    JOIN tmp_table b
        ON a.employee_id = b.employee_id AND a.rnk = 1 AND b.rnk = 2
    JOIN tmp_table c
        ON c.employee_id = b.employee_id AND c.rnk = 3
    -- Clever MySQL quirk: Using HAVING to filter on SELECT aliases without a GROUP BY
    HAVING improvement_score_1 > 0 AND improvement_score_2 > 0
    ORDER BY improvement_score DESC, a.name ASC
)

SELECT
    employee_id,
    name,
    improvement_score
FROM tmp_table_2;


/* =====================================================================================
   OPTIMAL & REFINED APPROACH (Using LEAD() Window Function)
   =====================================================================================
   
   Improvements made in this optimal version:
   1. Dropped the Self-Joins: Self-joining a CTE 3 times is computationally expensive. The `LEAD()` 
      function allows you to "look forward" (or historically backward, depending on your sort) 
      into the next rows within the same partition without executing a single join.
   2. Single Pass Execution: It pulls the current rating (`rnk=1`), the previous rating (`offset 1`), 
      and the oldest rating (`offset 2`) simultaneously into a single row.
   ===================================================================================== */

/*
WITH ranked_reviews AS (
    SELECT 
        e.employee_id,
        e.name,
        pr.rating AS current_rating,
        -- Fetch the rating 1 step back in history
        LEAD(pr.rating, 1) OVER(PARTITION BY e.employee_id ORDER BY pr.review_date DESC) AS prev_rating_1,
        -- Fetch the rating 2 steps back in history
        LEAD(pr.rating, 2) OVER(PARTITION BY e.employee_id ORDER BY pr.review_date DESC) AS prev_rating_2,
        RANK() OVER(PARTITION BY e.employee_id ORDER BY pr.review_date DESC) AS rnk
    FROM performance_reviews pr
    JOIN employees e ON pr.employee_id = e.employee_id
)
SELECT 
    employee_id,
    name,
    (current_rating - prev_rating_2) AS improvement_score
FROM ranked_reviews
-- Only evaluate the most recent record per employee
WHERE rnk = 1
  -- Ensure they actually had at least 3 reviews (prev_rating_2 is not null)
  AND prev_rating_2 IS NOT NULL
  -- Ensure strict consecutive improvement
  AND current_rating > prev_rating_1 
  AND prev_rating_1 > prev_rating_2
ORDER BY 
    improvement_score DESC, 
    name ASC;
*/
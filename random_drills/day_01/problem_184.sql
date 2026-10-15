/* =====================================================================================
   LEETCODE 184: Department Highest Salary
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Partitioned Window Functions (`PARTITION BY` + `RANK()`) & Two-Phase CTE Filtering
      
   2. CORE INSIGHT & CODE MECHANICS:
      When you need to find the "Top-N" items *per group* (e.g., highest salary per department, 
      newest post per user, most expensive product per category), standard aggregate functions 
      alone (`MAX()`, `GROUP BY`) fall short because you need to return entire row attributes 
      associated with that maximum value, not just the number itself.

      - PARTITION BY (The Grouping Engine): Unlike a traditional `GROUP BY` which collapses rows, 
        `PARTITION BY` splits your dataset into isolated buckets (departments) *behind the scenes*, 
        allowing window functions to calculate ranks independently within each department.
      - Why RANK() over ROW_NUMBER(): If two employees share the exact same top salary in a 
        department, `RANK()` assigns both of them rank 1. `ROW_NUMBER()` would arbitrarily force 
        one to rank 1 and the other to rank 2, dropping a valid top earner.
      - Two-Phase CTE Pipeline: SQL does not allow window functions (`RANK`, `ROW_NUMBER`) directly 
        inside a `WHERE` clause because window functions evaluate *after* the `WHERE` filter phase. 
        Wrapping the window ranking inside a CTE (`WITH ... AS`) allows you to treat the ranked 
        output like a normal table and filter `WHERE rnk = 1` in the outer query.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Do I need an aggregate metric *per group*, or do I need the full row details 
        of the top performer in each group?" 
        If you need full row details for the leader per category, reach for `PARTITION BY` + `RANK()`.
      - Question B: "Why can't I write `WHERE RANK() OVER (...) = 1` directly?" 
        Remember the SQL evaluation order: `WHERE` happens before window functions are calculated. 
        You *must* use a CTE or subquery wrapper to materialize the ranks first, then filter them.
      - Question C: "Should ties be included?" 
        If multiple entities share the top score and all must be returned, use `RANK()` or `DENSE_RANK()`. 
        If you only want a single arbitrary winner, use `ROW_NUMBER()`.

   4. COMMON PITFALLS TO AVOID:
      - Trying to put a window function directly in a `WHERE` clause (causes a SQL syntax error).
      - Using `ROW_NUMBER()` when business logic requires keeping tied top-earners.
      - Forgetting to `JOIN` the lookup table (`Department`) to fetch human-readable names instead 
        of raw foreign key IDs.
   ===================================================================================== */

WITH tmp_table AS (
    SELECT 
        Department.name AS Department,
        Employee.name AS Employee,
        salary AS Salary,
        -- PARTITION BY splits the ranking scope per department ID independently
        -- RANK() ensures ties (co-leaders) both receive rank 1
        RANK() OVER (PARTITION BY Employee.departmentId ORDER BY salary DESC) AS rnk
    FROM Employee
    JOIN Department 
        ON Employee.departmentId = Department.id
)
SELECT 
    Department,
    Employee,
    Salary
FROM tmp_table
-- Filter for rank 1 to extract all top earners per department partition
WHERE rnk = 1;
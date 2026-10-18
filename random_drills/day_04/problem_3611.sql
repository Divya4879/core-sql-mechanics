/* =====================================================================================
   LEETCODE 3611: Find Overbooked Employees
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Multi-Level Aggregation (CTE pipeline), Time-Series Windowing (`YEARWEEK`), 
      & Threshold Filtering (`HAVING`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      This problem requires a two-phase aggregation pipeline: first aggregating at the 
      weekly level per employee, and then aggregating at the lifetime level per employee.

      - Phase 1 (Weekly Rollup): You must group records by `employee_id` AND the specific calendar week. 
        Applying `HAVING total_hours > 20` here acts as a filter to only pass "heavy weeks" to the next stage.
      - Phase 2 (Lifetime Rollup): The outer query takes only the surviving heavy weeks, groups them 
        by employee, and counts them. `HAVING meeting_heavy_weeks >= 2` enforces the final business rule.

   3. ⚡ THE DATE FUNCTION CRASH COURSE (`WEEK` vs `YEARWEEK`):
      When a problem asks you to group by week, `YEARWEEK(date, mode)` is the safest tool in MySQL.
      
      - The Year-Boundary Trap: If you use `WEEK(meeting_date)`, MySQL returns a number (0-53). 
        If an employee has meetings in January 2023 and January 2024, `WEEK()` will combine them into 
        a single bucket! `YEARWEEK()` returns an integer like `202401`, guaranteeing chronological isolation.
      - The Mode Parameter (`1`): The problem explicitly states "Monday to Sunday". By default, MySQL 
        often considers Sunday the first day of the week. Passing `1` as the second argument 
        (`YEARWEEK(meeting_date, 1)`) forces the engine to treat Monday as the start of the week.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later, ask yourself these diagnostic questions:
      - Question A: "Does my data span multiple years?" 
        If yes, NEVER use `MONTH()` or `WEEK()` alone for grouping. Always use `YEARWEEK()` or `DATE_FORMAT(date, '%Y-%m')`.
      - Question B: "What day does the business consider the start of the week?" 
        Always pass the mode parameter (`1` for Monday) to avoid silent calculation bugs.
      - Question C: "Why use a CTE?" 
        Because you cannot count a count. You must first resolve the weekly totals (Phase 1) before 
        you can count how many of those totals exceed the threshold (Phase 2).

   5. COMMON PITFALLS TO AVOID:
      - Using `WEEK()` and failing test cases where data crosses the December/January boundary.
      - Forgetting to group by `employee_id` alongside the week in the first CTE, which would sum 
        company-wide hours instead of individual hours.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
WITH meeting_heavy_weeks AS (
    SELECT
        employees.employee_id AS employee_id,
        employee_name,
        department,
        -- YEARWEEK(..., 1) ensures safe cross-year grouping and forces Monday as the week start
        YEARWEEK(meeting_date, 1) AS wk,
        SUM(duration_hours) AS total_hours
    FROM employees
    JOIN meetings
        ON employees.employee_id = meetings.employee_id
    GROUP BY employee_id, wk
    -- Keep only the weeks where the employee was overbooked
    HAVING total_hours > 20
)

SELECT
    employee_id,
    employee_name,
    department,
    COUNT(wk) AS meeting_heavy_weeks
FROM meeting_heavy_weeks
GROUP BY employee_id
-- Keep only employees who have at least 2 overbooked weeks
HAVING meeting_heavy_weeks >= 2
ORDER BY 
    meeting_heavy_weeks DESC, 
    employee_name ASC;
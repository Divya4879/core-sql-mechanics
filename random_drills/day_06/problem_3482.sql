/* =====================================================================================
   LEETCODE 3482: Analyze Organization Hierarchy
   =====================================================================================
   
   1. THE "WHICH LANGUAGE IS BETTER?" VERDICT:
      For Python backend engineering (Django, FastAPI), PostgreSQL is the undisputed 
      industry standard. However, for Recursive Graph Traversal, Postgres and MySQL 8.0+ 
      use the exact same ANSI-standard SQL. The code below runs perfectly in both engines. 
      Your existing MySQL knowledge maps directly to Postgres here.

   2. ARCHETYPE / PATTERN:
      Hierarchical Tree Traversal, Bidirectional Recursion (`WITH RECURSIVE`), 
      & On-The-Fly Closure Tables.
      
   3. THE RECURSIVE ENGINE (How it works under the hood):
      A `WITH RECURSIVE` CTE operates in a strict, 3-step loop:
      - Step 1 (The Anchor): Runs the query BEFORE the `UNION ALL` to establish the Base Case.
      - Step 2 (The Recursion): Takes the results of Step 1, feeds them into the query 
        AFTER the `UNION ALL`, and finds the next layer of data.
      - Step 3 (The Termination): Repeats Step 2 until the loop returns exactly zero new rows.

   4. THE ARCHITECTURAL APPROACH (Bidirectional Traversal):
      Analyzing an org chart requires moving in two opposite directions:
      
      - Downward Traversal (The `OrgChart` CTE): We start at the CEO and walk DOWN the tree 
        to assign a `level` to everyone.
      - Upward Traversal (The `ReportingChain` CTE): To find budgets, we start at EVERY 
        employee and walk UP the tree to map them to ALL of their managers (direct and indirect). 
        Why walk UP? Walking down from a CEO creates a massive computational fan-out 
        (1 CEO -> 10 VPs -> 100 Directors -> 10,000 Employees). Walking UP traces a single, 
        straight, highly efficient line from each employee directly to the top.

   5. CLAUSE & FUNCTION BREAKDOWN:
      - `WITH RECURSIVE`: You only need to write this ONCE at the very top of your file, 
        even if you have multiple recursive CTEs below it.
      - `UNION ALL`: The mandatory glue that connects the Anchor query to the Recursive query.
      - `COALESCE(column, 0)`: The Postgres standard function to handle `NULL` values (equivalent 
        to MySQL's `IFNULL`). If a leaf-node employee has zero subordinates, the `LEFT JOIN` 
        returns `NULL`. `COALESCE` safely converts that `NULL` into a `0` so math doesn't break.

   6. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "I need to calculate a rolling sum of an entire branch in a hierarchy."
        Do NOT traverse from the top down. Traverse from the bottom up. Map every leaf to 
        every parent in a CTE, and then do a simple `GROUP BY parent_id`.
   ===================================================================================== */

WITH RECURSIVE 

-- =====================================================================================
-- PHASE 1: DOWNWARD TRAVERSAL (Calculate the exact level of every employee)
-- =====================================================================================
OrgChart AS (
    -- Anchor: Find the CEO (level 1)
    SELECT 
        employee_id, 
        employee_name, 
        salary, 
        1 AS level
    FROM Employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive Step: Find all direct reports of the previous level and add +1
    SELECT 
        e.employee_id, 
        e.employee_name, 
        e.salary, 
        oc.level + 1
    FROM Employees e
    JOIN OrgChart oc ON e.manager_id = oc.employee_id
),

-- =====================================================================================
-- PHASE 2: UPWARD TRAVERSAL (Map every employee to every manager in their chain)
-- =====================================================================================
ReportingChain AS (
    -- Anchor: Map every employee to their direct manager
    SELECT 
        employee_id AS subordinate_id, 
        manager_id AS ancestor_id, 
        salary AS subordinate_salary
    FROM Employees
    WHERE manager_id IS NOT NULL
    
    UNION ALL
    
    -- Recursive Step: Take the current manager, and jump up to THEIR manager
    SELECT 
        rc.subordinate_id, 
        e.manager_id AS ancestor_id, 
        rc.subordinate_salary
    FROM ReportingChain rc
    JOIN Employees e ON rc.ancestor_id = e.employee_id
    WHERE e.manager_id IS NOT NULL
),

-- =====================================================================================
-- PHASE 3: AGGREGATION (Calculate totals per manager)
-- =====================================================================================
ManagerAggregates AS (
    -- Because Phase 2 mapped indirect reports, a simple GROUP BY solves everything
    SELECT 
        ancestor_id AS manager_id,
        COUNT(subordinate_id) AS team_size,
        SUM(subordinate_salary) AS subordinates_salary
    FROM ReportingChain
    GROUP BY ancestor_id
)

-- =====================================================================================
-- PHASE 4: FINAL ASSEMBLY (Join the levels and the budgets)
-- =====================================================================================
SELECT 
    oc.employee_id,
    oc.employee_name,
    oc.level,
    -- Handle leaf nodes (employees with no reports) safely
    COALESCE(ma.team_size, 0) AS team_size,
    -- Budget is their own salary plus the sum of all subordinates' salaries
    oc.salary + COALESCE(ma.subordinates_salary, 0) AS budget
FROM OrgChart oc
-- Use LEFT JOIN because standard employees won't exist in the ManagerAggregates table
LEFT JOIN ManagerAggregates ma ON oc.employee_id = ma.manager_id
ORDER BY 
    oc.level ASC, 
    budget DESC, 
    oc.employee_name ASC;
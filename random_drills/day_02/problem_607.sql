/* =====================================================================================
   LEETCODE 607: Sales Person (Intuition Evolution Drill)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Exclusion Pattern (Negative Filtering), Multi-Table Joins, & CTE Subquery Isolation
      
   2. CORE INSIGHT & CODE MECHANICS:
      When a problem asks you to find entities that **never** participated in a specific relationship 
      (e.g., salespersons who have never taken an order from 'RED'), the most intuitive mental model 
      is a two-step exclusion pipeline:
      
      - Step 1 (Isolate the Violators): Join the tables (`SalesPerson` $\rightarrow$ `Orders` $\rightarrow$ `Company`) 
        to find all salespeople tied to the target condition (`Company.name = 'RED'`) and group them.
      - Step 2 (Negative Filtering via NOT IN): Select everyone from the master table whose identifier 
        is absent from that violator list (`WHERE name NOT IN (SELECT name FROM tmp_table)`).

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF (BUILDING INTUITION):
      When reviewing this later in your career, remember how your approach evolved:
      - The Struggle: Early on, exclusion problems feel confusing because we try to filter *for* what we want 
        inside a single messy join, leading to bugs where valid records get dropped or kept incorrectly.
      - The Breakthrough: Realizing that finding the "blacklist" first via a CTE makes the final query 
        read like plain English: "Give me all salespersons who are NOT in the restricted blacklist."
      - Diagnostic Question: "Am I looking for entities that never did X?" 
        Always build a blacklist CTE of those who did X, then exclude them.

   4. COMMON PITFALLS TO AVOID:
      - Trying to filter using `WHERE company.name != 'RED'` directly on the main query, which fails because 
        a salesperson who sold to Amazon *and* RED would still match the "not RED" row-level condition.
      - Name Collision Warning: While blacklisting by name works for simple problems, in production systems 
        always blacklist by unique primary keys (`sales_id`) rather than human-readable attributes like `name`.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================
WITH tmp_table AS (
    SELECT
        SalesPerson.name AS name
    FROM SalesPerson
    JOIN Orders
        ON SalesPerson.sales_id = Orders.sales_id
    JOIN Company
        ON Orders.com_id = Company.com_id
    WHERE Company.name = 'RED'
    GROUP BY SalesPerson.sales_id
)

SELECT
    salesperson.name AS name
FROM SalesPerson
WHERE SalesPerson.name NOT IN (SELECT name FROM tmp_table);


/* =====================================================================================
   OPTIMAL REFINEMENT (ID-Based Subquery Exclusion)
   ====================================================================================
   
   Production Tip: Switch from blacklisting by `name` to blacklisting by primary key `sales_id` 
   to prevent bugs if two employees ever share the same name.
   ==================================================================================== */

/*
SELECT 
    name
FROM SalesPerson
WHERE sales_id NOT IN (
    SELECT o.sales_id
    FROM Orders o
    JOIN Company c ON o.com_id = c.com_id
    WHERE c.name = 'RED'
);
*/
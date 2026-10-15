/* =====================================================================================
   LEETCODE 177: Nth Highest Salary
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Procedural Stored Functions & Dynamic Offset Pagination (`LIMIT offset, count`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      Unlike standard queries where you fetch data directly, LeetCode requires a reusable 
      database function (`CREATE FUNCTION`) because $N$ is passed dynamically as an input parameter.
      
      - BEGIN ... END Blocks: In procedural SQL, when a routine requires multiple statements 
        (variable declarations, logic execution, and a return query), you must wrap them 
        inside a compound `BEGIN ... END` block (similar to curly braces `{}` in Python/JS).
      - Variable Modification (N = N - 1): MySQL's `LIMIT` clause takes `(offset, row_count)`. 
        To find the $N^{\text{th}}$ highest salary, you must skip the top $N - 1$ rows. Because 
        `LIMIT` historically doesn't evaluate inline arithmetic expressions directly in older engines, 
        decrementing $N$ stores the correct zero-indexed offset.
      - Returning Scalar Values: The function is explicitly declared to `RETURNS INT`, allowing 
        the subquery result to evaluate and return a single scalar value (or `NULL` if out of bounds).

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Is this a stateless query or does it require procedural logic/parameters?" 
        (If it takes inputs and executes steps, you need a Stored Procedure or Function).
      - Question B: "Why do I need `BEGIN ... END`?" 
        (Whenever a SQL routine contains more than a single statement, the engine needs 
        explicit boundaries to know where the procedural block starts and terminates).
      - Question C: "How does `LIMIT` handle offsets?" 
        Remember that `LIMIT` is zero-indexed. To get the 2nd highest, you skip 1 row (`2 - 1 = 1`). 
        To get the $N^{\text{th}}$ highest, your offset must be $N - 1$.

   4. COMMON PITFALLS TO AVOID:
      - Forgetting that out-of-bounds `LIMIT` offsets return empty sets rather than `NULL` 
        in some SQL dialects. Wrapping the query inside `RETURN (SELECT ...)` handles the 
        expected `NULL` fallback cleanly.
      - Syntax differences across engines: This specific stored function syntax uses MySQL 
        procedural constructs. PostgreSQL handles functions differently using `LANGUAGE plpgsql`.
   ===================================================================================== */

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    -- Step 1: Adjust N to act as a zero-indexed offset for the LIMIT clause.
    -- To find the 2nd highest, we need to skip 1 row (2 - 1 = 1).
    SET N = N - 1;
    
    -- Step 2: Return the scalar result wrapped in parentheses
    RETURN (
        SELECT DISTINCT salary
        FROM Employee
        ORDER BY salary DESC
        -- LIMIT syntax: LIMIT offset, count
        LIMIT N, 1
    );
END;
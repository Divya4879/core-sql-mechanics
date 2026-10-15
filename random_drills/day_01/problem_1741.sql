/* =====================================================================================
   LEETCODE 1741: Find Total Time Spent by Each Employee
   =====================================================================================
   
   ARCHETYPE / PATTERN: 
   Linear Aggregation & Distributive Property over Row-Level Arithmetic
   
   CORE INSIGHT:
   When an employee can have multiple entry/exit logs on the same calendar day, and you 
   need the *cumulative* time spent, you have two ways to structure your calculation:
   1. Row-level evaluation: SUM(out_time - in_time)
   2. Distributive aggregation: SUM(out_time) - SUM(in_time)
   
   Both leverage the mathematical linearity of summation. Writing it as the difference 
   of sums (`SUM(A) - SUM(B)`) demonstrates advanced comfort with how SQL aggregates 
   operate over grouped partitions.

   WHY THIS INTUITION MATTERS FOR FUTURE INTERVIEWS:
   1. Granular Grouping: Grouping by composite keys (`event_day, emp_id`) correctly 
      partitions the data so an employee's hours are isolated per day, even with 
      multiple punch-ins.
   2. Aggregation Order of Operations: SQL computes the `GROUP BY` first, evaluates 
      the aggregate functions (`SUM`), and then performs final arithmetic in the 
      `SELECT` clause. Understanding this pipeline prevents common grouping errors.
   ===================================================================================== */

SELECT 
    event_day AS day,
    emp_id,
    -- Distributive property of summation: The sum of differences equals 
    -- the difference of the sums. Highly efficient and clean.
    SUM(out_time) - SUM(in_time) AS total_time
FROM Employees
-- Grouping by both dimensions because an employee can have multiple logs on the same day
GROUP BY event_day, emp_id;

/* =====================================================================================
   
   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: [e.g., "Do I care about raw rows or grouped/aggregated entities?"]
      - Question B: [e.g., "Can I distribute my aggregate functions or do I need nested passes?"]

   4. COMMON PITFALLS TO AVOID:
      - [What beginner mistakes this pattern protects against]
   ===================================================================================== */
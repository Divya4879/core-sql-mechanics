/* =====================================================================================
   LEETCODE 627: Swap Salary / Swap Sex of Employees
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      In-Place Conditional Row Mutation / Single-Pass State Flipping
      
   2. CORE INSIGHT & CODE MECHANICS:
      When performing an update that involves swapping or toggling values (e.g., 'm' <-> 'f', 
      0 <-> 1, 'Active' <-> 'Inactive'), you cannot use sequential UPDATE statements because 
      the first statement will overwrite the state of the table globally.
      
      Instead, you must use a single-pass conditional expression (`IF` or `CASE WHEN`) 
      directly inside the `SET` clause. This allows every individual row to evaluate its own 
      current state and determine its target value simultaneously in one atomic operation.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Am I selecting data or mutating live table data?" 
        (If mutating, think `UPDATE` + `SET`, not `SELECT`).
      - Question B: "Will sequential statements destroy my intermediate state?" 
        (If yes, never use multiple WHERE updates. Use a single conditional expression 
        so rows evaluate their original values before any overwrites occur).
      - Question C: "Is this MySQL syntax or standard ANSI SQL?" 
        (MySQL supports `IF(condition, true_val, false_val)`, but PostgreSQL and standard 
        SQL require the robust `CASE WHEN` syntax).

   4. COMMON PITFALLS TO AVOID:
      - Forgetting the `WHERE` clause: A bare `UPDATE table SET ...` without a `WHERE` 
        will update *every single row* in the table. (Though for this specific LeetCode 
        problem, we want to update all rows, in production tables you almost always filter).
      - Trying to use `WHERE` for a swap: Doing `UPDATE t SET sex='f' WHERE sex='m'` 
        followed by `UPDATE t SET sex='m' WHERE sex='f'` will turn *every* row into 'm'!
   ===================================================================================== */

-- =====================================================================================
-- SOLUTION 1: MySQL Shorthand (Using the IF() function)
-- =====================================================================================

UPDATE Salary
SET sex = IF(sex = 'm', 'f', 'm');


/* =====================================================================================
   SOLUTION 2: Standard ANSI SQL / PostgreSQL Equivalent (Using CASE WHEN)
   *Note: Since you are also mastering PostgreSQL, always lean on CASE WHEN because 
   Postgres does not have a native ternary IF() function inside SQL statements.*
   ====================================================================================
   
   UPDATE Salary
   SET sex = CASE 
       WHEN sex = 'm' THEN 'f'
       ELSE 'm'
   END;
*/
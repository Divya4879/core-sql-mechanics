/* =====================================================================================
   LEETCODE 178: Rank Scores
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Window Functions & Comparative Ranking without Gaps (`DENSE_RANK()`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      When ranking rows based on a value order, you have three primary window functions. 
      The problem explicitly requires:
      - Ties share the exact same rank number.
      - No gaps in the sequence after a tie (e.g., if two scores tie at rank 1, the next 
        score must be rank 2, not rank 3). 
      This exact business requirement points directly to `DENSE_RANK()`.

      - The OVER(ORDER BY ...) Clause: Defines the window partition and sorting order over 
        which the ranking calculation is evaluated.
      - Reserved Keywords as Aliases: Words like `RANK` are protected SQL keywords. When 
        using them as custom column aliases, you must escape them using backticks (`` `rank` ``) 
        or double quotes (`"rank"`).

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Do I need unique numbers, or do ties share a position?" 
        (If unique numbers are required regardless of identical values, use `ROW_NUMBER()`).
      - Question B: "If there is a tie, do I want gaps in my numbering sequence?" 
        (If gaps are allowed like 1, 1, 3, use `RANK()`. If no gaps are allowed like 1, 1, 2, 
        use `DENSE_RANK()`).

   4. COMMON PITFALLS TO AVOID:
      - Unescaped Keywords: Writing `AS rank` without backticks/quotes will crash if `RANK` 
        is reserved by the SQL parser.
      - Confusing `ORDER BY` inside vs. outside: The `OVER (ORDER BY score DESC)` dictates 
        how the ranking is computed, while the outer `ORDER BY score DESC` dictates how 
        the final result rows are sorted for display.
   ===================================================================================== */

SELECT 
    score,
    -- DENSE_RANK assigns identical ranks to ties and leaves NO GAPS in the sequence
    DENSE_RANK() OVER (ORDER BY score DESC) AS `rank`
FROM Scores
ORDER BY score DESC;

/* =====================================================================================
   REFERENCE CHEAT-SHEET: SQL RANKING WINDOW FUNCTIONS
   =====================================================================================
   
   A quick reference guide for behavior on ties and sequence patterns across datasets.
   Example Dataset Scores: [100, 100, 85, 70]
   
   +-----------------+---------------------------------------------+-------------------+---------------------------------------------------------------------------------+
   | Function        | Behavior on Ties                            | Sequence Pattern  | Ideal Use Case                                                                  |
   +-----------------+---------------------------------------------+-------------------+---------------------------------------------------------------------------------+
   | ROW_NUMBER()    | Ignores ties; assigns unique integers       | 1, 2, 3, 4        | Pagination, finding top-1 per group, unique row identification                  |
   | RANK()          | Assigns identical ranks; leaves gaps        | 1, 1, 3, 4        | Athletic leaderboards where a tie for 1st leaves no 2nd place                   |
   | DENSE_RANK()    | Assigns identical ranks; NO gaps            | 1, 1, 2, 3        | Tiered pricing, salary bands, and game score rankings (next is immediately 2)   |
   +-----------------+---------------------------------------------+-------------------+---------------------------------------------------------------------------------+
   ===================================================================================== */
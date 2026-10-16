/* =====================================================================================
   ADVANCED ANALYTICS: Book Reading Sessions & Polarization Scoring
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Multi-Metric Statistical Aggregation, Ratio Proportion Indexing, & Multi-Constraint `HAVING` Filtering
      
   2. CORE INSIGHT & CODE MECHANICS:
      When evaluating complex behavioral distributions or sentiment metrics across groups (such as determining 
      if an item has sufficient engagement volume *and* polarized ratings), you must combine structural 
      extremum calculations with proportional ratio math.

      - Extremum Tracking (`MAX`, `MIN` & Spread): Tracking ceiling and floor values (`MAX(session_rating)` 
        and `MIN(session_rating)`) allows you to instantly compute the rating spread (`MAX - MIN`) to measure range divergence.
      - Floating-Point Conditional Proportions: Computing ratios like `polarization_score` requires counting specific 
        subsets (ratings >= 4 or <= 2) relative to total volume. Using `1.00` inside the `THEN` clause forces the query 
        engine to execute floating-point division instead of truncating integers.
      - Multi-Constraint `HAVING` Clause: Because all filtering requirements (`cnt >= 5`, bounds on max/min ratings, 
        and ratio thresholds) rely entirely on aggregated metrics, they *must* be evaluated in the `HAVING` phase 
        (or wrapped inside a CTE) rather than a row-level `WHERE` clause.
      - Two-Phase Pipeline & Formatting: The CTE isolates heavy statistical calculations and filtering, allowing the outer 
        query to focus purely on rounding (`ROUND(..., 2)`) and multi-column tie-breaker sorting (`ORDER BY DESC, DESC`).

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "How do I filter rows based on summary statistics (like counts, averages, or max/min thresholds)?" 
        Always aggregate first via `GROUP BY` and apply your business rules inside the `HAVING` clause (or inside a CTE).
      - Question B: "How do I calculate percentages or proportions safely without integer division bugs?" 
        Always multiply or cast your numerator explicitly as a float (`1.00`) before dividing by the total count.
      - Question C: "Why combine bounds checking (`max >= 4 AND min <= 2`) with proportional scoring (`score >= 0.6`)?" 
        It creates a robust multi-layered filter: first proving the extremes exist, then verifying that the 
        majority proportion meets the polarization threshold.

   4. COMMON PITFALLS TO AVOID:
      - Integer division truncation: Writing `THEN 1` instead of `THEN 1.00` can cause integer division to drop decimals.
      - Trying to reference aggregate aliases or function outputs directly in a `WHERE` clause (always use `HAVING` or a CTE).
   ===================================================================================== */

WITH tmp_table AS (
    SELECT
        books.book_id AS book_id,
        title,
        author,
        genre,
        pages,
        -- Track upper and lower rating bounds to measure sentiment spread
        MAX(session_rating) AS max_rating,
        MIN(session_rating) AS min_rating,
        COUNT(books.book_id) AS cnt,
        -- Calculate total rating spread range
        MAX(session_rating) - MIN(session_rating) AS rating_spread,
        -- Calculate polarization ratio: proportion of extreme reviews (>= 4 or <= 2) relative to total count
        SUM(CASE WHEN (session_rating >= 4) OR (session_rating <= 2) THEN 1.00 END) / COUNT(books.book_id) AS polarization_score
    FROM books
    JOIN reading_sessions
        ON books.book_id = reading_sessions.book_id
    GROUP BY books.book_id
    -- HAVING filters multi-metric aggregates: minimum volume, required extremes, and ratio thresholds
    HAVING cnt >= 5 
       AND max_rating >= 4 
       AND min_rating <= 2 
       AND polarization_score >= 0.6
)
SELECT
    book_id,
    title,
    author,
    genre,
    pages,
    rating_spread,
    ROUND(polarization_score, 2) AS polarization_score
FROM tmp_table
-- Multi-column sorting: Primary sort by polarization score descending, secondary sort by title descending
ORDER BY polarization_score DESC, title DESC;
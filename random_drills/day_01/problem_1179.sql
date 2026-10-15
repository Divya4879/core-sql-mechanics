/* =====================================================================================
   LEETCODE 1179: Reformat Department Table
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Conditional Aggregation & Manual SQL Pivoting (Long-to-Wide Data Transformation)
      
   2. CORE INSIGHT & CODE MECHANICS:
      Tables often store data in a "long" format (multiple rows per entity, with a category column 
      like `month` and a value column like `revenue`). To reshape this into a "wide" format 
      (one row per entity, with each category turned into its own distinct column), you must 
      use **Conditional Aggregation**.

      - The CASE WHEN Filter: Evaluates each row individually. If the row matches the target condition 
        (e.g., `month = 'Jan'`), it outputs the `revenue`. If it doesn't match, it implicitly evaluates to `NULL`.
      - The Aggregate Wrapper (SUM / MAX): At first glance, wrapping a single month's revenue in `SUM()` 
        feels absurd—you aren't "adding" numbers together. However, this serves two critical architectural purposes:
        1. Row Collapse: Because you are grouping by `id`, SQL requires an aggregate function to condense 
           multiple rows for that department down into a single summary row.
        2. Null Elimination: Aggregate functions (`SUM`, `MAX`, `AVG`) automatically ignore `NULL` values. 
           Since all non-matching months evaluated to `NULL` in the `CASE` statement, the aggregate function 
           safely extracts the single valid number while collapsing the rest.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Am I transforming vertical rows into horizontal columns (Pivot)?" 
        If yes, you need a combination of `GROUP BY`, `CASE WHEN`, and an aggregate function.
      - Question B: "Why do I need `SUM()` or `MAX()` around my `CASE WHEN` statement?" 
        Remember: Without an aggregate function, SQL will throw a grouping error or return multiple rows 
        per entity. The aggregate function acts as a vacuum cleaner—it sucks up all the `NULL`s generated 
        by non-matching rows and leaves behind the single target value.
      - Question C: "Did I remember to group by the primary entity ID?" 
        Always `GROUP BY` the main identifier (`id`) so the pivot aligns correctly per entity.

   4. COMMON PITFALLS TO AVOID:
      - Omitting the aggregate function: Writing `SELECT CASE WHEN month='Jan' THEN revenue END` 
        without `SUM()` will fail or return uncollapsed, fragmented rows.
      - Forgetting the `GROUP BY` clause at the bottom: Conditional aggregation always requires 
        a corresponding group-by key to partition the rows.
   ===================================================================================== */

SELECT 
id,
    -- January Column
    SUM(CASE WHEN month = 'Jan' THEN revenue END) AS Jan_Revenue,
    -- February Column
    SUM(CASE WHEN month = 'Feb' THEN revenue END) AS Feb_Revenue,
    -- March Column
    SUM(CASE WHEN month = 'Mar' THEN revenue END) AS Mar_Revenue,
    -- April Column
    SUM(CASE WHEN month = 'Apr' THEN revenue END) AS Apr_Revenue,
    -- May Column
    SUM(CASE WHEN month = 'May' THEN revenue END) AS May_Revenue,
    -- June Column
    SUM(CASE WHEN month = 'Jun' THEN revenue END) AS Jun_Revenue,
    -- July Column
    SUM(CASE WHEN month = 'Jul' THEN revenue END) AS Jul_Revenue,
    -- August Column
    SUM(CASE WHEN month = 'Aug' THEN revenue END) AS Aug_Revenue,
    -- September Column
    SUM(CASE WHEN month = 'Sep' THEN revenue END) AS Sep_Revenue,
    -- October Column
    SUM(CASE WHEN month = 'October' OR month = 'Oct' THEN revenue END) AS Oct_Revenue,
    -- November Column
    SUM(CASE WHEN month = 'Nov' THEN revenue END) AS Nov_Revenue,
    -- December Column
    SUM(CASE WHEN month = 'Dec' THEN revenue END) AS Dec_Revenue
FROM Department
GROUP BY id;
/* =====================================================================================
   LEETCODE 1158: Market Analysis I
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Conditional Counting via Aggregates (`SUM(CASE WHEN ... THEN 1 ELSE 0 END)`) 
      & Outer Join Metric Preservation
      
   2. CORE INSIGHT & CODE MECHANICS:
      When generating reports, you often need to count events that match a specific sub-condition 
      (e.g., count orders made *only* in the year 2019) per entity, while still keeping entities 
      that had zero matching events.

      - Why standard COUNT() fails here: If you filter inside a `WHERE` clause (`WHERE YEAR(order_date) = 2019`), 
        any user who had zero orders in 2019 is completely filtered out of the dataset. Furthermore, if you 
        use a `LEFT JOIN` and write `COUNT(order_id)`, it will count *all* orders regardless of year if not filtered.
      - Conditional Counting Pattern (`SUM(CASE WHEN ... THEN 1 ELSE 0 END)`): 
        By placing a `CASE WHEN` statement *inside* a `SUM()` aggregate function, you can evaluate rows on the fly:
        1. If the row matches the criteria (e.g., year is 2019), it outputs `1`.
        2. If it fails or is a `NULL` from a `LEFT JOIN`, it outputs `0`.
        3. Summing those ones and zeros gives you an exact conditional count without dropping users who had 0 orders!

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Do I need to count *subset occurrences* per entity while keeping entities with zero matches?" 
        If yes, avoid filtering in the `WHERE` clause. Use conditional aggregation (`SUM(CASE WHEN ... THEN 1 ELSE 0 END)`).
      - Question B: "Why use `SUM` instead of `COUNT` with a `CASE` statement?" 
        `COUNT()` counts *non-null* rows. If your `CASE` statement returns `NULL` for non-matching rows, `COUNT` 
        will miscount or behave unexpectedly depending on the dialect. `SUM` treats `NULL` as zero and cleanly 
        adds up your 1s.
      - Question C: "Did I preserve all master records?" 
        Always start your join chain from the master entity table (`Users`) using a `LEFT JOIN` to ensure users 
        with zero activity still show up with a count of `0`.

   4. COMMON PITFALLS TO AVOID:
      - Filtering by year in the `WHERE` clause, which silently drops users who made zero purchases in 2019.
      - Forgetting to group by the unique user ID (`Users.user_id`), causing aggregation errors.
      - Using `COUNT(order_id)` inside a filtered join incorrectly instead of conditional summation.
   ===================================================================================== */

SELECT 
    user_id AS buyer_id,
    join_date,
    -- Conditional counting: Awards 1 if the order occurred in 2019, otherwise 0. 
    -- SUM aggregates these flags per user while preserving users with 0 matching orders.
    SUM(CASE WHEN YEAR(order_date) = 2019 THEN 1 ELSE 0 END) AS orders_in_2019
FROM Users
LEFT JOIN Orders 
    ON Users.user_id = Orders.buyer_id
GROUP BY Users.user_id, join_date;
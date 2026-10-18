/* =====================================================================================
   LEETCODE 3554: Find Category Recommendation Pairs (Hard)
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Market Basket Analysis (Affinity Analysis), Pre-Deduplication, & Lexicographical 
      Self-Joins (`<`)
      
   2. 🚨 PITFALLS, WEAKNESSES, & TRAPS (Analysis of Original Failing Code):
      Your original code fell into three distinct architectural traps:

      - TRAP 1: The Granularity Mismatch (Product-Level vs Category-Level)
        You self-joined the `ProductPurchases` table on `user_id` to find *product* pairs 
        first, planning to convert them to categories later. This fails because two different 
        products can belong to the same category. If User A buys Book 1 and Shirt 1, and User B 
        buys Book 2 and Shirt 2, your code sees zero shared product pairs, even though the 
        category pair (Books & Clothing) actually shares two users! You must step up to the 
        category level *before* generating pairs.
        
      - TRAP 2: Cartesian Inflation (Missing DISTINCT)
        If a user buys 3 Books and 2 Electronics, joining at the product level creates a 
        3x2 = 6 row explosion for a single user. Counting those rows wildly inflates the 
        customer count. You need to know *if* they bought a category, not *how many* times.
        
      - TRAP 3: Invalid Pivot Syntax (`CASE WHEN product_1 THEN category`)
        `product_1` is an integer ID, not a boolean condition. Furthermore, joining `ProductInfo` 
        with an `OR` (`product_1 = product_id OR product_2 = product_id`) duplicates rows 
        vertically instead of pivoting the two categories horizontally into `category1` and `category2`.

   3. CORE INSIGHT & CODE MECHANICS (The Optimal Strategy):
      To solve Market Basket problems flawlessly, use a strict Two-Phase Pipeline:
      
      - Phase 1 (Flatten & Deduplicate): Map every user to the distinct categories they purchased. 
        If User 1 bought 100 different electronics, they just get one row: `(User 1, Electronics)`. 
        This completely eliminates Cartesian inflation.
      - Phase 2 (The Lexicographical Self-Join): Join the Phase 1 table to itself on `user_id` 
        using the holy grail of combinatorics: `a.category < b.category`. 
        This single line of code does three magical things at once:
          1. It prevents a category from pairing with itself (Books & Books).
          2. It prevents reverse duplicates (If it pairs Books & Sports, it blocks Sports & Books).
          3. It guarantees `category1` is always alphabetically first, satisfying the output rules.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "Does the problem ask to find pairs of items bought by the same user?"
        This is a Market Basket problem. IMMEDIATELY create a CTE that uses `SELECT DISTINCT user_id, item_group`.
      - Diagnostic Question: "How do I generate unique A-B pairs without A-A or B-A duplicates?"
        Self-join using `a.id < b.id` (or `a.name < b.name`). It is the ultimate deduplication filter.
   ===================================================================================== */

-- =====================================================================================
-- THE OPTIMAL APPROACH (Pre-Deduplication & Lexicographical Pairing)
-- =====================================================================================
WITH UserCategories AS (
    -- Phase 1: Flatten the data hierarchy. 
    -- We don't care about specific products or quantities, only that a user touched a category.
    SELECT DISTINCT 
        p.user_id, 
        i.category
    FROM ProductPurchases p
    JOIN ProductInfo i 
        ON p.product_id = i.product_id
)

-- Phase 2: Generate the Market Basket pairs
SELECT 
    a.category AS category1,
    b.category AS category2,
    COUNT(a.user_id) AS customer_count
FROM UserCategories a
JOIN UserCategories b 
    ON a.user_id = b.user_id 
    -- The holy grail of pairing: strictly alphabetically less-than
    AND a.category < b.category 
GROUP BY 
    a.category, 
    b.category
HAVING 
    COUNT(a.user_id) >= 3
ORDER BY 
    customer_count DESC, 
    category1 ASC, 
    category2 ASC;
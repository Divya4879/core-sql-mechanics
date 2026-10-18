/* =====================================================================================
   LEETCODE 3521: Find Product Recommendation Pairs
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Market Basket Analysis, Pre-Deduplication, Lexicographical Self-Joins (`<`), 
      & Late Dimension Joins (Dual-Aliasing)
      
   2. 🚨 PITFALLS, WEAKNESSES, & TRAPS:
      The most common way engineers fail this problem is the "Cartesian Inflation" trap.
      
      - The Missing DISTINCT: If you self-join a raw transaction table (`ProductPurchases`) 
        on `user_id`, you are mathematically crossing every purchase a user made with every 
        other purchase. If a user bought a Laptop 3 times and a Mouse 2 times, the database 
        generates 6 rows for that (Laptop, Mouse) pair for a single user. 
        Because the business rule asks for "distinct users who bought both," counting those 
        inflated rows will completely destroy your accuracy. 
        You MUST flatten the transaction table so each (user, product) combo exists exactly once 
        before you do the self-join.

   3. CORE INSIGHT & CODE MECHANICS:
      This is a textbook 3-Phase Analytics Pipeline:
      
      - Phase 1 (Flatten): `SELECT DISTINCT user_id, product_id`. This guarantees that even 
        if a user buys a product 100 times, it only counts as one node in our basket.
      - Phase 2 (Combinatorics): Self-join the flattened table using `a.product_id < b.product_id`. 
        This prevents A-A pairs (Laptop & Laptop) and deduplicates reverse pairs (Laptop & Mouse 
        vs Mouse & Laptop).
      - Phase 3 (The Late Join): Notice we didn't touch the `ProductInfo` table yet. We wait 
        until Phase 3, after all the heavy filtering is done, to join `ProductInfo` twice 
        (Dual-Aliasing) just to fetch the category strings for our final output.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "I am doing a Market Basket self-join, but my counts are too high?"
        You forgot to `SELECT DISTINCT user_id, item_id` before the join.
      - Diagnostic Question: "I need category names for Product 1 and Product 2?"
        Use the Dual-Aliasing pattern: `JOIN ProductInfo p1` and `JOIN ProductInfo p2`.
   ===================================================================================== */

-- =====================================================================================
-- THE OPTIMAL INDUSTRY-STANDARD APPROACH (Pre-Deduplication)
-- =====================================================================================
WITH UniquePurchases AS (
    -- Phase 1: Flatten the data. A user buying the same product 5 times is still just 1 distinct edge.
    SELECT DISTINCT 
        user_id, 
        product_id
    FROM ProductPurchases
),

ProductPairs AS (
    -- Phase 2: The Lexicographical Self-Join to find co-occurrences
    SELECT 
        a.product_id AS product1_id,
        b.product_id AS product2_id,
        COUNT(a.user_id) AS customer_count
    FROM UniquePurchases a
    JOIN UniquePurchases b
        ON a.user_id = b.user_id
        -- Guarantee unique combinations and enforce the p1 < p2 output rule
        AND a.product_id < b.product_id
    GROUP BY 
        a.product_id, 
        b.product_id
    -- Business rule: Only pairs bought by at least 3 distinct users
    HAVING COUNT(a.user_id) >= 3
)

-- Phase 3: The Late Join (Dual-Aliasing) to fetch categorical dimensions
SELECT 
    pp.product1_id,
    pp.product2_id,
    p1.category AS product1_category,
    p2.category AS product2_category,
    pp.customer_count
FROM ProductPairs pp
-- Alias 1: Fetch details for the first product
JOIN ProductInfo p1 
    ON pp.product1_id = p1.product_id
-- Alias 2: Fetch details for the second product
JOIN ProductInfo p2 
    ON pp.product2_id = p2.product_id
ORDER BY 
    pp.customer_count DESC, 
    pp.product1_id ASC, 
    pp.product2_id ASC;


/* =====================================================================================
   STANDARD REFERENCE APPROACH (Without Pre-Deduplication)
   =====================================================================================
   Note for future review: This approach works on datasets where (user_id, product_id) 
   is already guaranteed to be unique. However, it is vulnerable to Cartesian inflation 
   on raw transaction logs.
   ===================================================================================== */
/*
WITH co_purchases AS (
    SELECT 
        a.product_id AS product1_id, 
        b.product_id AS product2_id,
        COUNT(a.user_id) AS customer_count
    FROM ProductPurchases a
    JOIN ProductPurchases b 
      ON a.user_id = b.user_id 
     AND a.product_id < b.product_id  
    GROUP BY a.product_id, b.product_id
    HAVING COUNT(a.user_id) >= 3      
)
SELECT 
    c.product1_id,
    c.product2_id,
    p1.category AS product1_category,
    p2.category AS product2_category,
    c.customer_count
FROM co_purchases c
JOIN ProductInfo p1 ON c.product1_id = p1.product_id  
JOIN ProductInfo p2 ON c.product2_id = p2.product_id  
ORDER BY 
    customer_count DESC, 
    product1_id ASC, 
    product2_id ASC;
*/
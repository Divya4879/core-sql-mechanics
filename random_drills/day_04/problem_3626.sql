/* =====================================================================================
   LEETCODE 3626: Find Stores with Inventory Imbalance
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Min/Max Entity Extraction, Tie-Breaking Window Functions (`ROW_NUMBER`), 
      & Dual-Aliasing Dimension Joins
      
   2. 🚨 PITFALLS, WEAKNESSES, & TRAPS (Analysis of Original Failing Code):
      Your original intuition to find the `MAX(price)` and `MIN(price)` in a CTE was good, 
      but the execution fell into three classic SQL traps:

      - TRAP 1: The "Non-Aggregated String" Trap: 
        In your `tmp_table_2`, you grouped by `store_id` but tried to select a string conditionally:
        `CASE WHEN price = max_price THEN product_name END`. 
        MySQL will reject this (or return garbage data) because `product_name` is not wrapped 
        in an aggregate function like `MAX()`. When you collapse rows with `GROUP BY`, you 
        cannot conditionally pull out a string from the collapsed rows without isolating it first.
        
      - TRAP 2: The Cartesian Fan-Out:
        In your final `SELECT`, you joined the heavily aggregated `tmp_table_2` back to the raw 
        `inventory` table AGAIN, and grouped AGAIN. Because you didn't strictly limit the join 
        to the exact min/max product IDs, this creates a massive row-duplication explosion 
        under the hood.
        
      - TRAP 3: Tie-Breaker Blindness (The `SUM` Trap):
        You used `SUM(CASE WHEN price = max_price THEN quantity END)`. If a store has TWO items 
        tied for the maximum price of $999, your code would add their quantities together. The 
        business logic requires isolating the single item with the highest quantity. 

   3. CORE INSIGHT & CODE MECHANICS (The Optimized Strategy):
      The complex Google solution used messy correlated subqueries to break ties. Instead, 
      we can completely bypass `GROUP BY` string-extraction errors and subqueries by using 
      `ROW_NUMBER()`.
      
      - Phase 1 (Store Validation): Simple CTE to find stores with `>= 3` distinct products.
      - Phase 2 (The Dual-Ranking Engine): Instead of grouping, we rank the raw inventory rows 
        TWICE per store. 
        `exp_rank`: Orders by Price DESC, then Quantity DESC (safely breaking ties).
        `cheap_rank`: Orders by Price ASC, then Quantity DESC (safely breaking ties).
      - Phase 3 (The Clean Join): We take our valid stores and join the Ranked inventory table 
        to it twice—once explicitly grabbing `exp_rank = 1` and once grabbing `cheap_rank = 1`. 
        This flattens the data instantly without ever needing a heavy `GROUP BY` to extract strings.

   4. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      - Diagnostic Question: "How do I extract the name of the product that has the highest price?"
        NEVER try to do this inside a standard `GROUP BY` using a `CASE WHEN`. 
        ALWAYS use `ROW_NUMBER() OVER(ORDER BY price DESC)` and filter for `rnk = 1`. It solves 
        tie-breaking and string extraction simultaneously.
   ===================================================================================== */

-- =====================================================================================
-- THE OPTIMAL APPROACH (Window Functions > Correlated Subqueries)
-- =====================================================================================
WITH ValidStores AS (
    -- STEP 1: Filter stores that have at least 3 DISTINCT products
    SELECT 
        s.store_id, 
        s.store_name, 
        s.location,
        COUNT(DISTINCT i.product_name) AS distinct_products
    FROM stores s
    JOIN inventory i ON s.store_id = i.store_id
    GROUP BY s.store_id, s.store_name, s.location
    HAVING distinct_products >= 3
),

RankedProducts AS (
    -- STEP 2: Rank the inventory to isolate the absolute most expensive and cheapest items
    -- Sorting by quantity DESC secondarily automatically handles the tie-breaking rules
    SELECT 
        store_id,
        product_name,
        price,
        quantity,
        ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY price DESC, quantity DESC) AS exp_rank,
        ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY price ASC, quantity DESC) AS cheap_rank
    FROM inventory
    -- Optimization: Only rank inventory for stores we know are valid
    WHERE store_id IN (SELECT store_id FROM ValidStores)
)

-- STEP 3: Bring it all together using the Dual-Aliasing Join pattern
SELECT 
    vs.store_id,
    vs.store_name,
    vs.location,
    max_prod.product_name AS most_exp_product,
    min_prod.product_name AS cheapest_product,
    ROUND(min_prod.quantity / max_prod.quantity, 2) AS imbalance_ratio
FROM ValidStores vs
-- Join once for the most expensive item
JOIN RankedProducts max_prod 
    ON vs.store_id = max_prod.store_id AND max_prod.exp_rank = 1
-- Join again for the cheapest item
JOIN RankedProducts min_prod 
    ON vs.store_id = min_prod.store_id AND min_prod.cheap_rank = 1
-- Apply the final business imbalance rule
WHERE max_prod.quantity < min_prod.quantity
ORDER BY 
    imbalance_ratio DESC, 
    vs.store_name ASC;
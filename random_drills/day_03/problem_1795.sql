/* =====================================================================================
   LEETCODE 1795: Rearrange Products Table
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Manual Unpivoting (Wide-to-Long Data Transformation) & Vertical Stacking (`UNION`)
      
   2. CORE INSIGHT & CODE MECHANICS:
      Data is often stored in a "Wide" format (e.g., `store1`, `store2`, `store3` as separate columns) 
      for easy human reading, but analytical engines frequently require it in a "Long" format 
      (e.g., `store_name`, `price`) to perform group-by aggregations. 

      To manually unpivot data in SQL, you break the wide row into multiple independent `SELECT` 
      queries and stack them vertically:
      
      - Hardcoded Categorization: You explicitly generate the categorical column by hardcoding 
        string literals (e.g., `'store1' AS store`).
      - Value Mapping: You map the actual table column to the new universal value column 
        (e.g., `store1 AS price`).
      - Vertical Stacking (`UNION`): The `UNION` operator glues the independent result sets 
        together top-to-bottom.
      - Null Pruning: The problem specifies excluding rows where the product isn't available in 
        that store. Appending `WHERE store_x IS NOT NULL` to each sub-query prunes empty records 
        before they are stacked.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Am I trying to turn multiple columns into a single column with multiple rows?" 
        This is Unpivoting. In MySQL/Postgres, default to writing separate `SELECT` queries for 
        each target column and stacking them with `UNION`.
      - Question B: "Should I use `UNION` or `UNION ALL`?" 
        `UNION` automatically deduplicates rows (which requires a sorting pass under the hood). 
        `UNION ALL` just blindly stacks them and is much faster. In this specific problem, since 
        a product cannot be in `store1` twice, `UNION ALL` is technically more optimal, though 
        `UNION` achieves the exact same result.

   4. COMMON PITFALLS TO AVOID:
      - Forgetting to alias the columns consistently in the very first `SELECT` statement. 
        (The first `SELECT` sets the column names for the entire `UNION` block).
      - Forgetting the `WHERE store_x IS NOT NULL` filter, which results in useless rows 
        with `NULL` prices polluting the dataset.
   ===================================================================================== */

-- =====================================================================================
-- YOUR EXACT SOLUTION CODE
-- =====================================================================================

-- Extract Store 1 data

SELECT 
    product_id, 
    'store1' AS store, 
    store1 AS price
FROM Products
WHERE store1 IS NOT NULL

UNION

-- Extract Store 2 data
SELECT 
    product_id, 
    'store2' AS store, 
    store2 AS price
FROM Products
WHERE store2 IS NOT NULL

UNION

-- Extract Store 3 data
SELECT 
    product_id, 
    'store3' AS store, 
    store3 AS price
FROM Products
WHERE store3 IS NOT NULL;
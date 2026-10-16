/* =====================================================================================
   LEETCODE 1084: Sales Analysis III
   =====================================================================================
   
   1. ARCHETYPE / PATTERN:
      Exclusion Pattern (Negative Filtering) via CTE & Subquery Subtraction
      
   2. CORE INSIGHT & CODE MECHANICS:
      When a business requirement asks for items that occurred **exclusively** within a specific 
      time window (e.g., "products sold *only* in the first quarter of 2019"), writing a simple 
      row-level filter like `WHERE sale_date BETWEEN '2019-01-01' AND '2019-03-31'` will **fail**. 

      Why? Because a single product can have multiple transaction rows across its lifetime. If Product A 
      was sold twice in Q1 2019 and once in Q2 2019, a row-level filter would keep the two Q1 rows, hide 
      the Q2 row, and incorrectly report that Product A was *only* sold in Q1!

      To solve exclusivity, you must use an **Exclusion Strategy**:
      1. Identify the "Violators": Create a CTE (`tmp_table`) that isolates any product that has *ever* 
         been sold outside the target window (before Jan 1, 2019 or after Mar 31, 2019).
      2. Exclude the Violators: Select products sold within the target window whose IDs are **NOT IN** 
         that violation list.
      3. Deduplicate: Use `DISTINCT` on the final projection since products will naturally have multiple 
         qualifying sales records within Q1.

   3. 🧠 THE MENTAL MODEL FOR YOUR FUTURE SELF:
      When reviewing this later in your career, ask yourself these diagnostic questions:
      - Question A: "Does the requirement ask for items that occurred *exclusively* within a range, 
        or just items that had *at least one* occurrence in that range?" 
        If it demands exclusivity ("only in"), a simple row filter will lie to you if multi-row transactions exist. 
        You must filter out entities that violate the boundary anywhere in their history.
      - Question B: "Is it easier to find what I want or find what I *don't* want?" 
        When exclusivity is required, finding the violators and excluding them (`NOT IN`) is often cleaner 
        and less prone to edge-case bugs than complex date-range grouping logic.

   4. COMMON PITFALLS TO AVOID:
      - Using a simple row-level `WHERE sale_date BETWEEN ...` without considering that products have multiple sales rows.
      - Forgetting `DISTINCT` in the final select, which causes products with multiple valid Q1 sales to appear multiple times.
   ===================================================================================== */

-- Step 1: Isolate all products that violate the exclusivity rule (sold outside Q1 2019)
WITH tmp_table AS (
    SELECT Product.product_id
    FROM Product
    JOIN Sales 
        ON Product.product_id = Sales.product_id
    WHERE sale_date < '2019-01-01' OR sale_date > '2019-03-31'
)
-- Step 2: Select products sold in Q1, excluding anyone found in the violator list
SELECT DISTINCT 
    Product.product_id,
    product_name
FROM Product
JOIN Sales 
    ON Product.product_id = Sales.product_id
WHERE Product.product_id NOT IN (SELECT product_id FROM tmp_table);
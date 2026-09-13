-- ============================================================================
-- CORE SQL FOUNDATIONS: DATA RETRIEVAL, FILTERING, AND SORTING
-- ============================================================================
-- Executable reference queries demonstrating data projections, conditional 
-- filtering, pattern matching, sorting, pagination, and geographic logic.
-- ============================================================================


-------------------------------------------------------------------------------
-- 1. DATA RETRIEVAL AND PROJECTIONS (`SELECT`, `AS`)
-------------------------------------------------------------------------------

-- Fetch every column and row in a table
SELECT * 
FROM users;

-- Project specific columns to minimize data overhead
SELECT email, created_at 
FROM users;

-- Use column aliases (`AS`) to rename fields in the result set for application mapping
SELECT first_name AS given_name, annual_salary AS compensation 
FROM employees;


-------------------------------------------------------------------------------
-- 2. CONDITIONAL FILTERING (`WHERE`, `BETWEEN`, `IN`)
-------------------------------------------------------------------------------

-- Exact match filtering using the equality operator (`=`)
SELECT product_name, price 
FROM products 
WHERE product_id = 402;

-- Numerical comparison filtering
SELECT product_name, stock_qty 
FROM products 
WHERE stock_qty > 50;

-- Inequality filtering to exclude specific records
SELECT item_name 
FROM inventory 
WHERE status != 'DISCONTINUED';

-- Match values against a discrete list of options using `IN`
SELECT employee_id, department 
FROM staff 
WHERE department IN ('Engineering', 'Infrastructure', 'Security');

-- Filter values within an inclusive continuous range using `BETWEEN`
SELECT order_id, total_amount 
FROM orders 
WHERE total_amount BETWEEN 100.00 AND 500.00;


-------------------------------------------------------------------------------
-- 3. TEXT PATTERN MATCHING (`LIKE`)
-------------------------------------------------------------------------------

-- Find records starting with a specific text prefix using the `%` wildcard
SELECT username, email 
FROM accounts 
WHERE email LIKE 'admin%';

-- Match strict structural patterns using the `_` single-character wildcard
SELECT product_code 
FROM warehouse 
WHERE product_code LIKE '_-9';


-------------------------------------------------------------------------------
-- 4. SHAPING RESULTS: UNIQUENESS, SORTING, AND PAGINATION
-------------------------------------------------------------------------------

-- Strip duplicate rows from the final output set using `DISTINCT`
SELECT DISTINCT department 
FROM employees;

-- Sort records alphabetically or chronologically using `ORDER BY` (Defaults to `ASC`)
SELECT customer_name 
FROM clients 
ORDER BY customer_name ASC;

-- Sort records in descending order (`DESC`) from highest-to-lowest or newest-to-oldest
SELECT transaction_id, amount 
FROM transactions 
ORDER BY amount DESC;

-- Restrict the volume of data returned using `LIMIT`
SELECT product_name, price 
FROM products 
ORDER BY price DESC 
LIMIT 5;

-- Implement pagination by combining `LIMIT` and `OFFSET` (skip rows, then fetch)
SELECT product_name 
FROM products 
ORDER BY product_id 
LIMIT 5 OFFSET 10;


-------------------------------------------------------------------------------
-- 5. SPATIAL & DIRECTIONAL LOGIC (LATITUDE AND LONGITUDE NAVIGATION)
-------------------------------------------------------------------------------
-- Schema Context: A `store_locations` table containing `store_name`, `city`, 
-- `country`, `latitude`, and `longitude`.

-- A. LATITUDE (NORTH TO SOUTHERN ORDERING)
-- Logic: Higher positive latitude values mean closer to the North Pole (further North).
-- To traverse strictly from North to South, order in DESCENDING order 
-- (starting from the highest positive coordinate down toward zero).
SELECT store_name, city, latitude 
FROM store_locations 
WHERE country = 'USA' 
ORDER BY latitude DESC;

-- B. LONGITUDE (WEST TO EAST ORDERING)
-- Logic: In the Western Hemisphere, longitude values are negative (-). Moving further 
-- West means moving into larger negative numbers. 
-- To find locations west of a boundary (e.g., longitude < -90.0) and sort them 
-- from west to east, filter using the threshold and sort in ASCENDING order 
-- (from the most negative/furthest west up toward zero/east).
SELECT store_name, city, longitude 
FROM store_locations 
WHERE longitude < -90.0000 
ORDER BY longitude ASC;
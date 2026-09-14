-- MODULE 5: ADVANCED QUERIES (SUBQUERIES AND SET OPERATIONS)
-- Schema Context: E-Commerce & Order Management System 
-- (Tables: users, products, orders, order_items)
-- ============================================================================


-------------------------------------------------------------------------------
-- 1. GENERAL SUBQUERIES (NESTED QUERIES)
-------------------------------------------------------------------------------

-- Subquery in WHERE: Find products that cost more than the overall catalog average.
-- The inner query evaluates once and passes the scalar average to the outer query.
SELECT product_id, name, price
FROM products
WHERE price > (
    SELECT AVG(price) 
    FROM products
);

-- Subquery in SELECT: Append a dynamic aggregate value to each row for direct comparison.
SELECT 
    name, 
    price, 
    (SELECT AVG(price) FROM products) AS catalog_average_price,
    price - (SELECT AVG(price) FROM products) AS price_difference
FROM products;


-------------------------------------------------------------------------------
-- 2. CORRELATED SUBQUERIES
-------------------------------------------------------------------------------
-- The inner query depends on the outer query (p1). It must re-execute for 
-- every row in the outer query to calculate category-specific averages.

-- Find products that cost more than the average price of THEIR SPECIFIC category.
SELECT p1.product_id, p1.name, p1.category, p1.price
FROM products AS p1
WHERE p1.price > (
    SELECT AVG(p2.price)
    FROM products AS p2
    WHERE p2.category = p1.category
);


-------------------------------------------------------------------------------
-- 3. EXISTENCE TESTS (DYNAMIC LISTS WITH `IN` / `NOT IN`)
-------------------------------------------------------------------------------

-- IN: Find all users who have placed a "High Value" order (over $1,000).
SELECT user_id, email
FROM users
WHERE user_id IN (
    SELECT user_id 
    FROM orders
    WHERE total_amount > 1000.00
);

-- NOT IN: Find all registered users who have never placed an order.
SELECT user_id, email, created_at
FROM users
WHERE user_id NOT IN (
    SELECT user_id 
    FROM orders
);


-------------------------------------------------------------------------------
-- 4. SET OPERATIONS (UNION, INTERSECT, EXCEPT)
-------------------------------------------------------------------------------
-- Stacking queries vertically. Both queries must have the exact same column 
-- count, order, and compatible data types.

-- A. UNION (Removes duplicates)
-- Create a consolidated marketing list of "VIP" customers (spent > $500) 
-- OR "Early Adopter" customers (the first 100 users to register).
SELECT user_id, email, 'VIP Customer' AS tag
FROM users
WHERE user_id IN (SELECT user_id FROM orders WHERE total_amount > 500.00)
UNION
SELECT user_id, email, 'Early Adopter' AS tag
FROM users
WHERE user_id <= 100;

-- B. UNION ALL (Retains duplicates - faster execution)
-- Useful for financial ledgers or audit logs where you want every record kept.
SELECT 'Q1_Sale' AS transaction_type, order_id, total_amount 
FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31'
UNION ALL
SELECT 'Q2_Sale' AS transaction_type, order_id, total_amount 
FROM orders WHERE order_date BETWEEN '2024-04-01' AND '2024-06-30';

-- C. INTERSECT (Must exist in BOTH sets)
-- Find highly loyal customers who placed an order in 2023 AND also in 2024.
SELECT user_id 
FROM orders WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01'
INTERSECT
SELECT user_id 
FROM orders WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';

-- D. EXCEPT (Exists in the first set, but NOT the second - Query order matters)
-- Find churned customers: Users who ordered in 2023 but did NOT order in 2024.
SELECT user_id 
FROM orders WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01'
EXCEPT
SELECT user_id 
FROM orders WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';
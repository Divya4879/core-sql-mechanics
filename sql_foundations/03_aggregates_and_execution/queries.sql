-- ============================================================================
-- MODULE 3: ADVANCED TRANSFORMATIONS, AGGREGATIONS, AND EXECUTION ORDER
-- Schema Context: E-Commerce & Order Management System 
-- (Tables: users, products, orders, order_items)
-- ============================================================================

-- 1. Expressions and Column Aliasing
SELECT 
    product_name,
    price,
    price * 0.90 AS discounted_price,
    stock_qty * price AS total_inventory_value
FROM products;

SELECT 
    o.order_id,
    u.email AS customer_email,
    o.total_amount
FROM orders AS o
INNER JOIN users AS u 
    ON o.user_id = u.user_id;


-- 2. Global Aggregations
SELECT COUNT(*) AS total_registered_users FROM users;

SELECT 
    MAX(price) AS highest_price,
    MIN(price) AS lowest_price,
    AVG(price) AS average_price
FROM products;

SELECT SUM(total_amount) AS total_revenue 
FROM orders 
WHERE status = 'COMPLETED';


-- 3. Grouped Aggregations (`GROUP BY`)
SELECT 
    category,
    COUNT(*) AS product_count,
    AVG(price) AS avg_category_price
FROM products
GROUP BY category;

SELECT 
    u.user_id,
    u.name,
    COUNT(o.order_id) AS total_orders_placed,
    SUM(o.total_amount) AS lifetime_spend
FROM users AS u
INNER JOIN orders AS o 
    ON u.user_id = o.user_id
GROUP BY u.user_id, u.name
ORDER BY lifetime_spend DESC;


-- 4. Filtering Grouped Data (`HAVING`)
SELECT 
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category
HAVING COUNT(*) > 5;

SELECT 
    u.user_id,
    u.email,
    SUM(o.total_amount) AS total_spent
FROM users AS u
INNER JOIN orders AS o 
    ON u.user_id = o.user_id
GROUP BY u.user_id, u.email
HAVING SUM(o.total_amount) > 1000.00
ORDER BY total_spent DESC;


-- 5. Complete Execution Pipeline Example
-- Execution Order: FROM/JOIN -> WHERE -> GROUP BY -> HAVING -> ORDER BY -> LIMIT
SELECT 
    p.category,
    COUNT(oi.product_id) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM products AS p
INNER JOIN order_items AS oi 
    ON p.product_id = oi.product_id
INNER JOIN orders AS o 
    ON oi.order_id = o.order_id
WHERE o.status = 'COMPLETED'
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 5000.00
ORDER BY category_revenue DESC
LIMIT 5;
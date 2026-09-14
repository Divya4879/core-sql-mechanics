-- ============================================================================
-- MODULE 4: SCHEMA OPERATIONS AND CRUD (DDL & DML)
-- Context: Creating and seeding a fresh E-Commerce schema (Migrations approach)
-- ============================================================================


-------------------------------------------------------------------------------
-- 1. TEARDOWN (DROP)
-------------------------------------------------------------------------------
-- Safely wipe existing structures before initializing the new schema. 
-- Note: Always drop dependent tables (like orders) BEFORE their parent tables.

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;


-------------------------------------------------------------------------------
-- 2. SCHEMA INITIALIZATION (CREATE TABLE & CONSTRAINTS)
-------------------------------------------------------------------------------

-- Parent Table 1: Users
CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Automatically ticks up (1, 2, 3...)
    email VARCHAR(255) UNIQUE NOT NULL,         
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Parent Table 2: Products
CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(150) NOT NULL,
    price FLOAT NOT NULL CHECK (price >= 0),    -- Prevents negative pricing bugs
    stock_qty INTEGER DEFAULT 0
);

-- Dependent Table: Orders (Demonstrating FOREIGN KEY)
CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    total_amount FLOAT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) -- Enforces relational integrity
);


-------------------------------------------------------------------------------
-- 3. RECORD CREATION (INSERT)
-------------------------------------------------------------------------------

-- A. Explicit column insertion (Best Practice - Forward compatible and safe)
INSERT INTO users (email) 
VALUES 
    ('admin@store.com'),
    ('customer1@gmail.com'),
    ('guest_user@yahoo.com');

-- B. Implicit insertion (Requires providing a value for EVERY column in exact order)
-- (Assuming product_id is auto-handled, we provide name, price, and stock_qty)
INSERT INTO products 
VALUES 
    (1, 'Mechanical Keyboard', 120.00, 50),
    (2, 'Wireless Mouse', 45.00, 150);

-- C. Insertion with inline arithmetic expressions
INSERT INTO products 
(name, price, stock_qty) 
VALUES ('USB-C Hub', 25.00 * 0.90, 200); -- Applying a 10% discount at insertion


-------------------------------------------------------------------------------
-- 4. RECORD MODIFICATION (UPDATE)
-------------------------------------------------------------------------------

-- Update a specific row (ALWAYS use a strict WHERE clause, typically by Primary Key)
UPDATE products 
SET stock_qty = stock_qty - 1 
WHERE product_id = 1;

-- Batch update rows matching a condition
UPDATE products 
SET price = price * 0.85 
WHERE stock_qty > 100;


-------------------------------------------------------------------------------
-- 5. RECORD REMOVAL (DELETE)
-------------------------------------------------------------------------------

-- Safely delete a specific record (Always test with a SELECT first!)
DELETE FROM users 
WHERE email = 'guest_user@yahoo.com';

-- "The Nuke": Leaving off the WHERE clause deletes EVERY row in the table, 
-- but leaves the schema completely intact.
DELETE FROM orders; 


-------------------------------------------------------------------------------
-- 6. SCHEMA ALTERATION (ALTER TABLE)
-------------------------------------------------------------------------------

-- Add a new column to the existing products table without dropping data
ALTER TABLE products 
ADD category VARCHAR(50) DEFAULT 'Uncategorized';

-- Drop an existing column (Note: Not supported in basic SQLite without a rebuild)
ALTER TABLE products 
DROP COLUMN category;

-- Rename a table
ALTER TABLE users 
RENAME TO registered_accounts;
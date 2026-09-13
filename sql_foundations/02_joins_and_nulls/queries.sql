-- MODULE 2: RELATIONAL DATA MAPPING (JOINS AND NULL HANDLING)
-- ============================================================================
-- Executable reference script for multi-table relationships, inner/outer joins,
-- evaluation order, and explicit NULL constraints.
-- ============================================================================


-------------------------------------------------------------------------------
-- 1. INNER JOIN (MATCHING DATA ACROSS NORMALIZED TABLES)
-------------------------------------------------------------------------------
-- Combines rows from two tables based on a shared primary/foreign key relationship.
-- Unmatched rows from either table are dropped completely.

-- Basic Inner Join query combining movies and box office statistics
SELECT movies.title, boxoffice.domestic_sales, boxoffice.international_sales
FROM movies
INNER JOIN boxoffice 
    ON movies.id = boxoffice.movie_id;

-- Inner Join combined with post-join filtering, sorting, and pagination
SELECT 
    m.title AS movie_title,
    m.director,
    b.domestic_sales + b.international_sales AS total_revenue
FROM movies AS m
INNER JOIN boxoffice AS b 
    ON m.id = b.movie_id
WHERE m.year > 2000
ORDER BY total_revenue DESC
LIMIT 5;


-------------------------------------------------------------------------------
-- 2. OUTER JOIN VARIATIONS (PRESERVING ASYMMETRIC DATA)
-------------------------------------------------------------------------------
-- Used when tables do not share 1:1 parity and you need to retain records 
-- from one or both sides even if a matching foreign key is missing.

-- A. LEFT JOIN (Preserves all rows from the left table)
-- Retrieves every building, and any employees assigned to them (filling missing matches with NULL)
SELECT building_name, capacity, role, name AS employee_name
FROM buildings
LEFT JOIN employees 
    ON buildings.building_name = employees.building;

-- B. RIGHT JOIN (Preserves all rows from the right table)
-- Equivalent concept to left join, ensuring all records on the right side persist.
SELECT employee_id, name, building_name
FROM buildings
RIGHT JOIN employees 
    ON buildings.building_name = employees.building;

-- C. FULL JOIN (Preserves all records from both sides regardless of matches)
SELECT c.category_name, p.product_name
FROM categories AS c
FULL JOIN products AS p 
    ON c.category_id = p.category_id;


-------------------------------------------------------------------------------
-- 3. MANAGING AND QUERYING NULL VALUES
-------------------------------------------------------------------------------
-- Demonstrates how to target missing states safely using IS NULL / IS NOT NULL,
-- avoiding broken logical assertions associated with direct operator matching.

-- Find records where an optional attribute is completely empty/unassigned
SELECT employee_id, name, building
FROM employees
WHERE building IS NULL;

-- Find records where data is fully populated, filtering out null gaps
SELECT employee_id, name, building
FROM employees
WHERE building IS NOT NULL;

-- Combining outer join results with a NULL check to find unassigned entities
SELECT b.building_name 
FROM buildings AS b
LEFT JOIN employees AS e 
    ON b.building_name = e.building
WHERE e.employee_id IS NULL;
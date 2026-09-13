# Core SQL Foundations: Data Retrieval, Filtering, and Sorting

## 1. Data Retrieval and Projections (`SELECT`, `AS`)

Projections define *what* data columns you want to extract from a relation.

* **Fetch all columns:**
```sql
SELECT * 
FROM users;

```


*(Note: Avoid using `*` in production applications where table schemas are wide, as it increases I/O overhead and memory consumption).*
* **Project specific columns:**
```sql
SELECT email, created_at 
FROM users;

```


* **Column Aliasing (`AS`):**
Rename fields in the result set to improve readability or map fields directly to application models.
```sql
SELECT first_name AS given_name, annual_salary AS compensation 
FROM employees;

```



## 2. Conditional Filtering (`WHERE`, `BETWEEN`, `IN`)

The `WHERE` clause acts as a row-level filter. The database engine evaluates the condition for every record; matching rows are included in the result set.

* **Equality and Numerical Comparisons:**
```sql
-- Exact match
SELECT product_name, price 
FROM products 
WHERE product_id = 402;

-- Threshold comparison
SELECT product_name, stock_qty 
FROM products 
WHERE stock_qty > 50;

-- Inequality
SELECT item_name 
FROM inventory 
WHERE status != 'DISCONTINUED';

```


* **Set Membership (`IN`):**
Checks if a column value matches any item in a discrete list. It is cleaner and more performant than chaining multiple `OR` conditions.
```sql
SELECT employee_id, department 
FROM staff 
WHERE department IN ('Engineering', 'Infrastructure', 'Security');

```


* **Inclusive Ranges (`BETWEEN`):**
Filters values within a continuous range (equivalent to `>= lower_bound AND <= upper_bound`).
```sql
SELECT order_id, total_amount 
FROM orders 
WHERE total_amount BETWEEN 100.00 AND 500.00;

```



## 3. Text Pattern Matching (`LIKE`)

Exact matching (`=`) does not work for partial strings. The `LIKE` operator enables pattern matching using wildcard characters.

* **Wildcards:**
* `%`: Matches zero or more characters.
* `_`: Matches a single explicit character.



```sql
-- Find records starting with a specific prefix
SELECT username, email 
FROM accounts 
WHERE email LIKE 'admin%';

-- Find records matching a strict character pattern (e.g., product code format like 'X-9')
SELECT product_code 
FROM warehouse 
WHERE product_code LIKE '_-9';

```

## 4. Shaping Results: Uniqueness, Sorting, and Pagination (`DISTINCT`, `ORDER BY`, `LIMIT`, `OFFSET`)

* **Removing Duplicates (`DISTINCT`):**
Strips duplicate rows from the final output set based on the selected projection.
```sql
SELECT DISTINCT department 
FROM employees;

```


* **Sorting Results (`ORDER BY`):**
Organizes the output sequence. Defaults to Ascending (`ASC`). Use `DESC` for descending order.
```sql
-- Alphabetical sorting
SELECT customer_name 
FROM clients 
ORDER BY customer_name ASC;

-- Chronological or high-to-low numeric sorting
SELECT transaction_id, amount 
FROM transactions 
ORDER BY amount DESC;

```


* **Limiting and Pagination (`LIMIT`, `OFFSET`):**
* `LIMIT` restricts the maximum number of rows returned.
* `OFFSET` skips a specified number of rows before beginning capture.


```sql
-- Top 5 most expensive products
SELECT product_name, price 
FROM products 
ORDER BY price DESC 
LIMIT 5;

-- Pagination: Skip the first 10 rows, then fetch the next 5 records
SELECT product_name 
FROM products 
ORDER BY product_id 
LIMIT 5 OFFSET 10;

```



## 5. Spatial & Directional Logic (Latitude and Longitude Navigation)

When querying geographical data (such as a `store_locations` table containing `latitude` and `longitude`), directional sorting requires careful handling of coordinate systems.

* **Latitude (North to South Ordering):**
* **Concept:** Latitude measures angular distance north or south of the Equator (0°). The Northern Hemisphere uses positive (+) values.
* **Rule:** Higher latitude numbers mean closer to the North Pole (further North). Lower numbers mean closer to the Equator (further South).
* **Syntax:** To sort strictly from North to South, order in **descending** order (from highest positive coordinate down toward zero).


```sql
SELECT store_name, city, latitude 
FROM store_locations 
WHERE country = 'USA' 
ORDER BY latitude DESC;

```


* **Longitude (West to East Ordering):**
* **Concept:** Longitude measures distance east or west of the Prime Meridian (0°). In the Western Hemisphere, longitude values are negative (-).
* **Rule:** Moving further West means moving further away from 0° into *larger negative numbers* (e.g., -118° is physically further west than -87°).
* **Filtering "West of X":** To find locations west of a specific coordinate (e.g., longitude -90.0), look for values *less than* -90.0 (more negative).
* **Sorting "West to East":** To order those filtered records from west to east, move from the most negative value (furthest west) up toward zero/east using **ascending** order.


```sql
SELECT store_name, city, longitude 
FROM store_locations 
WHERE longitude < -90.0000 
ORDER BY longitude ASC;

```
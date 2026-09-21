<!-- SQL DDL, Constraints, and Schema Architecture -->

<!-- Topics covered:- Table Creation (`CREATE TABLE`), Data Insertion (`INSERT INTO`), Composite Primary Keys, Foreign Key Dependencies, and Data Typing. -->

# DDL Student Records: Case Study & Architectural Ledger

This document serves as a comprehensive reference guide analyzing a multi-table relational schema (`student`, `module`, `registration`), common syntax traps encountered during schema design, and the definitive engineering rules to prevent them.


### Part 1: The Complete Code

```sql
-- ============================================================================
-- DDL STUDENT RECORDS - COMPLETE SCRIPT
-- ============================================================================

-- 1. STUDENT TABLE & INSERTS
CREATE TABLE student (
    matric_no CHAR(8) NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE
);

INSERT INTO student (matric_no, first_name, last_name, date_of_birth) VALUES
    ('40001010', 'Daniel', 'Radcliffe', '1989-07-23'),
    ('40001011', 'Emma', 'Watson', '1990-04-15'),
    ('40001012', 'Rupert', 'Grint', '1988-10-24');


-- 2. MODULE TABLE & INSERTS
CREATE TABLE module (
    module_code CHAR(8) NOT NULL PRIMARY KEY,
    module_title VARCHAR(50) NOT NULL,
    level INT NOT NULL,
    credits INT NOT NULL DEFAULT 20
);

INSERT INTO module (module_code, module_title, level) VALUES 
    ('HUF07101', 'Herbology', 7),
    ('SLY07102', 'Defense Against the Dark Arts', 7),
    ('HUF08102', 'History of Magic', 8);


-- 3. REGISTRATION TABLE & INSERTS
CREATE TABLE registration (
    matric_no CHAR(8) NOT NULL,
    module_code CHAR(8) NOT NULL,
    result DECIMAL(4,1),
    PRIMARY KEY (matric_no, module_code),
    FOREIGN KEY (matric_no) REFERENCES student(matric_no),
    FOREIGN KEY (module_code) REFERENCES module(module_code)
);

INSERT INTO registration (matric_no, module_code, result) VALUES 
    ('40001010', 'HUF07101', 40),
    ('40001010', 'SLY07102', 90),
    ('40001010', 'HUF08102', NULL),
    ('40001011', 'HUF07101', 99),
    ('40001011', 'HUF08102', NULL),
    ('40001012', 'HUF07101', 20),
    ('40001012', 'SLY07102', 20);


-- 4. FINAL QUERY
SELECT last_name, first_name, result, 
       CASE 
           WHEN result <= 39 THEN 'Troll'
           WHEN result BETWEEN 40 AND 69 THEN 'Acceptable'
           WHEN result BETWEEN 70 AND 89 THEN 'Exceeds Expectations'
           ELSE 'Outstanding'
       END AS grade
FROM student
JOIN registration ON student.matric_no = registration.matric_no
JOIN module ON module.module_code = registration.module_code
WHERE module.module_code = 'SLY07102'
ORDER BY result DESC;

```

---

### Part 2: Your Wrong Code Breakdown (Table by Table)

#### 1. The `student` Table & Inserts

```sql
CREATE TABLE student(
    matric_no INT(8) NOT NULL PRIMARY KEY -- MISTAKE: Matric numbers are IDs/strings, not math integers. Use CHAR(8).
    first_name VAR_CHAR(50)               -- MISTAKE: Missing comma at end of line! Typo: VARCHAR, not VAR_CHAR.
    last_name VAR_CHAR(50)                -- MISTAKE: Missing comma here too. Typo: VAR_CHAR.
    date_of_birth DATE                    -- (No comma needed on last line)
);

INSERT INTO student(matric_no, first_name, last_name, date_of_birth)
VALUES(
    40001010, 'Daniel', 'Radcliffe', DATE '1989-07-23' -- MISTAKE: matric_no needs quotes. DATE '...' is strict syntax; standard string literals '1989-07-23' are safer.
)
VALUES( -- MISTAKE: Cannot stack independent VALUES blocks back-to-back like this without commas or repeating INSERT.
    40001011, 'Emma', 'Watson', DATE '1990-04-15'
)
VALUES( -- MISTAKE: Same stacking error.
    40001012, 'Rupert', 'Grint', DATE '1988-10-24'
);

```

#### 2. The `module` Table & Inserts

```sql
CREATE TABLE module(
    module_code VARCHAR(8) NOT NULL PRIMARY KEY -- (This line is fine!)
    module_title VARCHAR(50)                    -- MISTAKE: Missing comma at the end of the previous line.
    level INT                                   -- MISTAKE: Missing comma here too.
    credits INT, DEFAULT 20                     -- MISTAKE: Putting a comma before DEFAULT breaks syntax. Should be: credits INT NOT NULL DEFAULT 20.
);

INSERT INTO module(module_code, module_title)
VALUES('HUF07101', 'Herbology')                 -- MISTAKE: You missed the required 'level' column and data!
VALUES('SLY07102', 'Defense Against the Dark Arts') -- MISTAKE: Stacked VALUES blocks without commas.
VALUES('HUF08102', 'History of Magic')          -- MISTAKE: Stacked VALUES blocks without commas.
);

```

#### 3. The `registration` Table & Inserts

```sql
CREATE TABLE registration(
    result FLOAT(1)                             -- MISTAKE 1: Forgot to define 'matric_no' and 'module_code' columns first!
                                                -- MISTAKE 2: Tutorial asked for DECIMAL(4,1), not FLOAT(1).
                                                -- MISTAKE 3: Missing composite PRIMARY KEY (matric_no, module_code).
    FOREIGN KEY matric_no REFERENCES student(matric_no)         -- MISTAKE: Missing parentheses: FOREIGN KEY (matric_no).
    FOREIGN KEY module_code REFERENCES module(module_code)      -- MISTAKE: Missing comma above, and missing parentheses.
);

INSERT INTO registration(result, matric_no, module_code)
VALUES(99, 40001010, 'HUF07101')
VALUES(40, 40001010, 'SLY07102')
VALUES(NULL, 40001010, 'HUF08102')

VALUES(90, 40001011, 'HUF07101') -- MISTAKE: All these stacked VALUES blocks fail. 
VALUES(NULL, 40001011, 'HUF08102') -- SQL expects a single VALUES clause with comma-separated 
                                 -- rows: VALUES (...), (...), (...);
VALUES(40, 40001012, 'HUF07101')
VALUES(20, 40001012, 'SLY07102');

```

---

## Part 3: The Master DDL & Insertion Ledger

### 1. Structural Syntax: The Comma Isolation Rule

* **The Trap:** Forgetting trailing commas at the end of column definitions inside `CREATE TABLE` blocks, or accidentally placing a comma *before* a column modifier keyword like `DEFAULT` (e.g., `credits INT, DEFAULT 20`).

**Why it happens:** Treating commas like punctuation at the end of a sentence rather than **delimiters that separate distinct elements**.

**The Golden Rule:** Commas separate column definitions from one another. Think of the final line before your closing parenthesis (`)`) as a VIP line, **it never gets a comma.**

### 2. Semantic Data Modeling: Identifier Data Type Discipline

Assigning numeric types like `INT(8)` to code identifiers like `matric_no`.

* **Why it happens:** Being tricked by identifiers that happen to look like numbers (student IDs, zip codes, phone numbers).

* **The Golden Rule:** Always ask yourself: *Am I going to perform mathematical calculations (addition, averages, multiplication) on this field?* If the answer is no, it is a **code or a string** (`CHAR` or `VARCHAR`), even if every character in it is a digit. Fixed-width strings also preserve critical leading zeros.

### 3. Relational Architecture: The Dependency Order of Operations

* **The Trap:** Attempting to define constraints, foreign keys, or primary keys on columns that haven't been physically declared yet (e.g., declaring a foreign key for `matric_no` before `matric_no` exists as a table column).

* **Why it happens:** Thinking of table constraints as a global list rather than a top-down execution flow.

* **The Golden Rule:** Building a database is like building physical infrastructure. **You must lay down the rooms (columns) before you can build the hallways connecting them (foreign keys and primary keys).**

### 4. Bulk Data Grammar: The Stacked `VALUES` Anti-Pattern

* **The Trap:** Writing multiple standalone `VALUES(...)` blocks back-to-back during data insertion without proper punctuation or repeating the `INSERT` command.

* **Why it happens:** Conflating human reading lines with SQL parser syntax.

* **The Golden Rule:** Standard SQL expects either completely independent `INSERT INTO` statements per row, or a **single unified command** using a comma-delimited batch:

```sql
INSERT INTO table (col1, col2) VALUES 
    (val1, val2),
    (val3, val4),
    (val5, val6);

```

### 5. Keyword Hygiene: Strict Type Verification

* **The Trap:** Using colloquial typos like `VAR_CHAR` instead of the strict SQL standard `VARCHAR`.

* **Why it happens:** Muscle memory from colloquial developer slang blending into code.

* **The Golden Rule:** Database parsers are entirely unforgiving. Treat data types (`VARCHAR`, `DECIMAL`, `INT`, `DATE`) like reserved system functions, spelling them with absolute precision is mandatory.
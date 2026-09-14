# Schema Operations and Data Manipulation (CRUD)

In SQL, the database schema describes the structure of each table and the datatypes that each column can contain. This fixed structure allows a database to be efficient and consistent despite storing millions or billions of rows.

## 1. Inserting Rows (`INSERT INTO`)

When inserting data into a database, the `INSERT` statement declares which table to write into, the columns being filled, and one or more rows of data. 

**Inserting all columns:**
In general, each row of data you insert should contain values for every corresponding column in the table. You can insert multiple rows at a time by listing them sequentially.
```sql
INSERT INTO mytable
VALUES (value_or_expr, another_value_or_expr, …),
       (value_or_expr_2, another_value_or_expr_2, …),
       …;

```

**Inserting specific columns:**
If you have incomplete data and the table contains columns that support default values, you can insert rows by explicitly specifying only the columns of data you have.

```sql
INSERT INTO mytable
(column, another_column, …)
VALUES (value_or_expr, another_value_or_expr, …),
      (value_or_expr_2, another_value_or_expr_2, …),
      …;

```

**Note on constraints:** The number of values must match the number of columns specified.
**Advantage:** Despite being more verbose, inserting values this way is **forward compatible**. If you add a new column to the table with a default value later, no hardcoded `INSERT` statements will have to change to accommodate it.
**Expressions:** You can use mathematical and string expressions with the values you are inserting to ensure all data is formatted a certain way.

---

## 2. Updating Rows (`UPDATE`)

To modify existing data, use the `UPDATE` statement. The data you are updating must match the data type of the columns in the table schema.

```sql
UPDATE mytable
SET column = value_or_expr, 
    other_column = another_value_or_expr, 
    …
WHERE condition;

```

**How it works:** The statement takes multiple column/value pairs and applies those changes to *each and every row* that satisfies the constraint in the `WHERE` clause.

**Taking care:** It is easy to make mistakes (e.g., updating the wrong rows or accidentally leaving out the `WHERE` clause, which applies the update to all rows). 

Always write the constraint first and test it in a `SELECT` query to ensure you are updating the right rows before writing the column/value pairs.

---

## 3. Deleting Rows (`DELETE`)

To delete data from a table, use the `DELETE` statement, which describes the table and the rows to delete via the `WHERE` clause.

```sql
DELETE FROM mytable
WHERE condition;

```

**Clearing a table:** If you leave out the `WHERE` constraint, all rows are removed. This is a quick and easy way to clear out a table completely if intentional.

**Taking extra care:** Like the `UPDATE` statement, run the constraint in a `SELECT` query first. Without a proper backup, it is downright easy to irrevocably remove data. Always read `DELETE` statements twice and execute once.

---

## 4. Creating Tables (`CREATE TABLE`)

When you have new entities and relationships, create a new table using `CREATE TABLE`. The structure is defined by its schema, which defines column names, allowed datatypes, optional constraints, and default values.

```sql
CREATE TABLE IF NOT EXISTS mytable (
    column DataType TableConstraint DEFAULT default_value,
    another_column DataType TableConstraint DEFAULT default_value,
    …
);

```

**`IF NOT EXISTS`:** If a table with the same name already exists, the database throws an error. This clause suppresses that error and skips creation.

### Common Table Data Types

| Data Type | Description |
| --- | --- |
| `INTEGER`, `BOOLEAN` | Stores whole integer values. In some implementations, a boolean is just an integer value of 0 or 1. |
| `FLOAT`, `DOUBLE`, `REAL` | Stores precise numerical data like measurements or fractional values (varies by precision required). |
| `CHARACTER(num_chars)`, `VARCHAR(num_chars)`, `TEXT` | Stores text. `CHARACTER` and `VARCHAR` specify the max characters allowed (longer values truncate) which can improve efficiency in big tables. |
| `DATE`, `DATETIME` | Stores date/time stamps for time series and events. Tricky to work with across timezones. |
| `BLOB` | Stores opaque binary data. Usually requires storing right metadata to requery them. |

### Common Table Constraints

| Constraint | Description |
| --- | --- |
| `PRIMARY KEY` | Values are unique and used to identify a single row in the table. |
| `AUTOINCREMENT` | For integer values, automatically fills and increments with each insertion (not supported in all DBs). |
| `UNIQUE` | Values must be unique. Differs from `PRIMARY KEY` because it doesn't have to be the row's identifying key. |
| `NOT NULL` | The inserted value cannot be `NULL`. |
| `CHECK (expr)` | Runs a complex expression to test if values are valid (e.g., positive numbers, specific size, certain prefixes). |
| `FOREIGN KEY` | Consistency check ensuring each value in this column corresponds to a valid value in another table's column. |

---

## 5. Altering Tables (`ALTER TABLE`)

As data changes over time, update your schemas using `ALTER TABLE` to add, remove, or modify columns and constraints.

**Adding columns:**
Requires specifying the datatype, potential constraints, and default values to be applied to existing and new rows.

```sql
ALTER TABLE mytable
ADD column DataType OptionalTableConstraint 
    DEFAULT default_value;

```

**Removing columns:**

Note: Some databases (like SQLite) do not support dropping columns. You must create a new table and migrate the data over instead.*

```sql
ALTER TABLE mytable
DROP column_to_be_deleted;

```

**Renaming the table:**

```sql
ALTER TABLE mytable
RENAME TO new_table_name;

```

---

## 6. Dropping Tables (`DROP TABLE`)

To remove an entire table (including all data *and* metadata schema), use `DROP TABLE`.

```sql
DROP TABLE IF EXISTS mytable;

```

**`IF EXISTS`:** Suppresses the error thrown if the specified table does not exist.
**Dependencies:** If another table is dependent on columns in the table you are removing (e.g., via a `FOREIGN KEY` dependency), you must either update the dependent tables to remove the dependent rows, or drop the dependent tables entirely first.

```
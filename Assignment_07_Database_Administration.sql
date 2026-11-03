
-- ============================================================
-- ASSIGNMENT 7: DATABASE ADMINISTRATION
-- Database: database_admin_project
-- ============================================================

-- STEP 1: Create and select a separate database
CREATE DATABASE IF NOT EXISTS database_admin_project;
USE database_admin_project;

-- STEP 2: Reset the demo table for safe reruns
DROP TABLE IF EXISTS employees;

-- STEP 3: Create a demo table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2)
);

-- STEP 4: Insert sample records
INSERT INTO employees
    (employee_id, employee_name, department, salary)
VALUES
    (1, 'Amit', 'IT', 60000),
    (2, 'Priya', 'HR', 55000),
    (3, 'Rahul', 'IT', 75000),
    (4, 'Neha', 'Finance', 65000),
    (5, 'Rohan', 'HR', 50000);

-- STEP 5: Display available databases
SHOW DATABASES;

-- STEP 6: Display tables in the current database
SHOW TABLES;

-- STEP 7: Inspect the table structure
DESCRIBE employees;

-- STEP 8: Display the SQL used to create the table
SHOW CREATE TABLE employees;

-- STEP 9: Display all employee records
SELECT *
FROM employees;

-- STEP 10: Check the current database
SELECT DATABASE() AS current_database;

-- STEP 11: Check the MySQL server version
SELECT VERSION() AS mysql_version;

-- STEP 12: Display database character set and collation
SELECT
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = DATABASE();

-- STEP 13: Count records in the employees table
SELECT COUNT(*) AS total_employees
FROM employees;

-- STEP 14: View employee data by department
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department;

-- STEP 15: Examine the query execution plan
EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT';

-- STEP 16: Check table storage information
SHOW TABLE STATUS LIKE 'employees';

-- STEP 17: Display session variables related to SQL mode
SELECT
    @@SESSION.sql_mode AS session_sql_mode;

-- STEP 18: Display session status information
SHOW SESSION STATUS LIKE 'Threads_connected';

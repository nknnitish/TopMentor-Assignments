
-- ============================================================
-- ASSIGNMENT 1: DATA WRANGLING AND DATA CLEANING
-- Independent practical: runs using its own database and tables
-- ============================================================

-- STEP 1: Create and select a separate database
CREATE DATABASE IF NOT EXISTS data_wrangling_project;
USE data_wrangling_project;

-- STEP 2: Remove old project tables so the script can be rerun
DROP VIEW IF EXISTS vw_clean_employees;
DROP TABLE IF EXISTS employees_clean;
DROP TABLE IF EXISTS employees_raw;

-- STEP 3: Create the raw table containing intentionally messy data
CREATE TABLE employees_raw (
    emp_id INT,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date VARCHAR(30)
);

-- STEP 4: Insert sample data with missing values, duplicates,
-- inconsistent department names and different date formats
INSERT INTO employees_raw
(emp_id, emp_name, department, salary, joining_date)
VALUES
(1, 'Rahul', 'IT', 60000, '2023-01-15'),
(2, 'Priya', 'HR', 45000, '15/02/2023'),
(3, 'Amit', 'it', 65000, '2023-03-10'),
(4, 'Sneha', NULL, 50000, '20-04-2023'),
(5, 'Vikas', 'Finance', NULL, '2023-05-05'),
(6, 'Neha', 'HR', 48000, '2023-06-12'),
(7, 'Rahul', 'IT', 60000, '2023-01-15'),
(8, 'Arjun', 'finance', 55000, '15/08/2023'),
(9, 'Kiran', '', 52000, '2023-09-01'),
(10, 'Meera', 'Marketing', 58000, '10/10/2023'),
(11, 'Rohan', 'IT', 72000, '2023-11-20'),
(12, 'Pooja', 'HR', 47000, '2023-12-01');

-- STEP 5: Inspect the original messy data
SELECT * FROM employees_raw;

-- STEP 6: Identify missing values and duplicate records
SELECT *
FROM employees_raw
WHERE emp_name IS NULL
   OR department IS NULL
   OR TRIM(department) = ''
   OR salary IS NULL
   OR joining_date IS NULL
   OR TRIM(joining_date) = '';

-- Find completely duplicated rows
SELECT emp_id, emp_name, department, salary, joining_date,
       COUNT(*) AS duplicate_count
FROM employees_raw
GROUP BY emp_id, emp_name, department, salary, joining_date
HAVING COUNT(*) > 1;

-- STEP 7: Create the cleaned table with proper data types
CREATE TABLE employees_clean (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2),
    joining_date DATE
);

-- STEP 8: Clean the data while inserting it into the new table
-- Standardize department names, replace missing department values,
-- remove exact duplicate rows and convert dates into DATE format.
INSERT INTO employees_clean
(emp_id, emp_name, department, salary, joining_date)
SELECT
    emp_id,
    TRIM(emp_name),
    CASE
        WHEN UPPER(TRIM(COALESCE(department, ''))) = 'IT'
            THEN 'IT'
        WHEN UPPER(TRIM(COALESCE(department, ''))) = 'HR'
            THEN 'HR'
        WHEN UPPER(TRIM(COALESCE(department, ''))) = 'FINANCE'
            THEN 'Finance'
        WHEN UPPER(TRIM(COALESCE(department, ''))) = 'MARKETING'
            THEN 'Marketing'
        ELSE 'Unknown'
    END,
    salary,
    CASE
        WHEN joining_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(joining_date, '%Y-%m-%d')
        WHEN joining_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(joining_date, '%d/%m/%Y')
        WHEN joining_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(joining_date, '%d-%m-%Y')
        ELSE NULL
    END
FROM employees_raw
WHERE emp_name IS NOT NULL
  AND TRIM(emp_name) <> ''
GROUP BY emp_id, emp_name, department, salary, joining_date;

-- STEP 9: Verify the cleaned data
SELECT * FROM employees_clean ORDER BY emp_id;

-- STEP 10: Check for remaining missing values
SELECT *
FROM employees_clean
WHERE department = 'Unknown'
   OR salary IS NULL
   OR joining_date IS NULL;

-- STEP 11: Analyze salary by department
SELECT
    department,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary,
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary,
    SUM(salary) AS total_salary
FROM employees_clean
GROUP BY department
ORDER BY total_salary DESC;

-- STEP 12: Rank employees by salary within each department
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees_clean
WHERE salary IS NOT NULL
ORDER BY department, salary_rank;

-- STEP 13: Find employees who joined during 2023
SELECT *
FROM employees_clean
WHERE joining_date >= '2023-01-01'
  AND joining_date < '2024-01-01'
ORDER BY joining_date;

-- STEP 14: Create a view for future analysis
CREATE VIEW vw_clean_employees AS
SELECT emp_id, emp_name, department, salary, joining_date
FROM employees_clean;

-- STEP 15: Test the view
SELECT * FROM vw_clean_employees;

-- STEP 16: Find the three highest-paid employees
SELECT *
FROM employees_clean
WHERE salary IS NOT NULL
ORDER BY salary DESC
LIMIT 3;

-- STEP 17: Final project summary
SELECT
    COUNT(*) AS total_clean_records,
    COUNT(salary) AS records_with_salary,
    COUNT(joining_date) AS records_with_valid_joining_date,
    COUNT(DISTINCT department) AS number_of_departments
FROM employees_clean;

-- END OF ASSIGNMENT 1

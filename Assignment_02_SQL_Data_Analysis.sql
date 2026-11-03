
-- ============================================================
-- ASSIGNMENT 2: DATA ANALYSIS USING SQL
-- Independent project with employee salary analysis
-- ============================================================

-- STEP 1: Create and select a separate database
CREATE DATABASE IF NOT EXISTS sql_data_analysis_project;
USE sql_data_analysis_project;

-- STEP 2: Reset this project's tables
DROP VIEW IF EXISTS vw_department_salary_analysis;
DROP TABLE IF EXISTS employees_clean;
DROP TABLE IF EXISTS employees_raw;

-- STEP 3: Create the raw employee table
CREATE TABLE employees_raw (
    emp_id INT,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date VARCHAR(30)
);

-- STEP 4: Insert sample data with some data-quality issues
INSERT INTO employees_raw
(emp_id, emp_name, department, salary, joining_date)
VALUES
(1, 'Rahul', 'IT', 60000, '2023-01-15'),
(2, 'Priya', 'HR', 45000, '15/02/2023'),
(3, 'Amit', 'IT', 65000, '2023-03-10'),
(4, 'Sneha', 'HR', 50000, '20-04-2023'),
(5, 'Vikas', 'Finance', NULL, '2023-05-05'),
(6, 'Neha', 'HR', 48000, '2023-06-12'),
(7, 'Arjun', 'Finance', 55000, '15/08/2023'),
(8, 'Meera', 'Marketing', 58000, '10/10/2023'),
(9, 'Rohan', 'IT', 72000, '2023-11-20'),
(10, 'Pooja', 'HR', 47000, '2023-12-01'),
(11, 'Karan', 'Finance', 62000, '2024-02-14'),
(12, 'Anjali', 'Marketing', 68000, '2024-04-22'),
(13, 'Manish', 'IT', 75000, '2024-06-18'),
(14, 'Divya', 'Finance', 59000, '2024-08-09'),
(15, 'Suman', 'Marketing', 61000, '2024-10-05');

-- STEP 5: Inspect the original data
SELECT * FROM employees_raw;

-- STEP 6: Create a clean table with proper data types
CREATE TABLE employees_clean (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2),
    joining_date DATE
);

-- STEP 7: Clean department names and convert joining dates
INSERT INTO employees_clean
(emp_id, emp_name, department, salary, joining_date)
SELECT
    emp_id,
    TRIM(emp_name),
    COALESCE(NULLIF(TRIM(department), ''), 'Unknown'),
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
  AND TRIM(emp_name) <> '';

-- STEP 8: Analyze overall salary statistics
SELECT
    COUNT(*) AS total_employees,
    COUNT(salary) AS employees_with_salary,
    ROUND(AVG(salary), 2) AS average_salary,
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary,
    SUM(salary) AS total_salary
FROM employees_clean;

-- STEP 9: Analyze salary department-wise
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

-- STEP 10: Find departments with average salary above 55000
SELECT
    department,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees_clean
GROUP BY department
HAVING AVG(salary) > 55000
ORDER BY average_salary DESC;

-- STEP 11: Rank employees within each department by salary
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS department_salary_rank
FROM employees_clean
WHERE salary IS NOT NULL
ORDER BY department, department_salary_rank;

-- STEP 12: Find the top three highest-paid employees
SELECT emp_id, emp_name, department, salary
FROM employees_clean
WHERE salary IS NOT NULL
ORDER BY salary DESC
LIMIT 3;

-- STEP 13: Find employees earning above the company average
SELECT emp_id, emp_name, department, salary
FROM employees_clean
WHERE salary > (
    SELECT AVG(salary)
    FROM employees_clean
)
ORDER BY salary DESC;

-- STEP 14: Find employees hired during 2024
SELECT *
FROM employees_clean
WHERE joining_date >= '2024-01-01'
  AND joining_date < '2025-01-01'
ORDER BY joining_date;

-- STEP 15: Calculate salary contribution by department
SELECT
    department,
    SUM(salary) AS department_salary,
    ROUND(
        SUM(salary) * 100.0 /
        (SELECT SUM(salary)
         FROM employees_clean
         WHERE salary IS NOT NULL),
        2
    ) AS salary_percentage
FROM employees_clean
WHERE salary IS NOT NULL
GROUP BY department
ORDER BY salary_percentage DESC;

-- STEP 16: Create a view for department salary analysis
CREATE VIEW vw_department_salary_analysis AS
SELECT
    department,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary,
    SUM(salary) AS total_salary
FROM employees_clean
GROUP BY department;

-- STEP 17: Display the view
SELECT *
FROM vw_department_salary_analysis
ORDER BY total_salary DESC;

-- STEP 18: Final data-quality check
SELECT *
FROM employees_clean
WHERE salary IS NULL
   OR joining_date IS NULL
   OR department = 'Unknown';

-- END OF ASSIGNMENT 2

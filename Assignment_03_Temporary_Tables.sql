
-- ============================================================
-- ASSIGNMENT 3: TEMPORARY TABLES
-- ============================================================

-- STEP 1: Create a separate database
CREATE DATABASE IF NOT EXISTS temporary_tables_project;
USE temporary_tables_project;

-- STEP 2: Create the main employee table
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2)
);

-- STEP 3: Insert sample employee records
INSERT INTO employees (emp_id, emp_name, department, salary)
VALUES
(1, 'Rahul', 'IT', 60000),
(2, 'Priya', 'HR', 45000),
(3, 'Amit', 'IT', 75000),
(4, 'Sneha', 'Finance', 55000),
(5, 'Vikas', 'HR', 48000),
(6, 'Neha', 'Finance', 65000),
(7, 'Rohan', 'IT', 85000),
(8, 'Pooja', 'Marketing', 52000),
(9, 'Arjun', 'Marketing', 62000),
(10, 'Meera', 'HR', 70000);

-- STEP 4: Display the original employee data
SELECT * FROM employees;

-- STEP 5: Create a temporary table for employees earning
-- more than 60000. It exists only for this database session.
DROP TEMPORARY TABLE IF EXISTS temp_high_salary;

CREATE TEMPORARY TABLE temp_high_salary AS
SELECT *
FROM employees
WHERE salary > 60000;

-- STEP 6: Display high-salary employees
SELECT * FROM temp_high_salary;

-- STEP 7: Add a bonus column to the temporary table
ALTER TABLE temp_high_salary
ADD COLUMN bonus DECIMAL(10,2) DEFAULT 0;

-- STEP 8: Calculate a 10 percent bonus
UPDATE temp_high_salary
SET bonus = salary * 0.10;

-- STEP 9: Display salary and bonus together
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    bonus,
    salary + bonus AS salary_after_bonus
FROM temp_high_salary
ORDER BY salary_after_bonus DESC;

-- STEP 10: Create a temporary table containing average salary
-- for each department
DROP TEMPORARY TABLE IF EXISTS temp_avg_salary;

CREATE TEMPORARY TABLE temp_avg_salary AS
SELECT
    department,
    ROUND(AVG(salary), 2) AS average_salary,
    SUM(salary) AS total_salary,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department;

-- STEP 11: Display department-wise salary analysis
SELECT *
FROM temp_avg_salary
ORDER BY average_salary DESC;

-- STEP 12: Find employees earning above their department average
SELECT
    e.emp_id,
    e.emp_name,
    e.department,
    e.salary,
    a.average_salary
FROM employees AS e
JOIN temp_avg_salary AS a
    ON e.department = a.department
WHERE e.salary > a.average_salary
ORDER BY e.department, e.salary DESC;

-- STEP 13: Count employees in the high-salary temporary table
SELECT COUNT(*) AS high_salary_employee_count
FROM temp_high_salary;

-- STEP 14: Compare original and filtered employee counts
SELECT
    (SELECT COUNT(*) FROM employees) AS total_employees,
    (SELECT COUNT(*) FROM temp_high_salary) AS employees_earning_above_60000;

-- END OF ASSIGNMENT 3

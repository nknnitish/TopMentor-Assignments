
-- ============================================================
-- ASSIGNMENT 6: RANKING AND PARTITION BY
-- Database: ranking_partition_project
-- ============================================================

-- STEP 1: Create and select a separate database
CREATE DATABASE IF NOT EXISTS ranking_partition_project;
USE ranking_partition_project;

-- STEP 2: Reset this assignment's table for safe reruns
DROP TABLE IF EXISTS employees;

-- STEP 3: Create the employees table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

-- STEP 4: Insert sample employee records
INSERT INTO employees
    (employee_id, employee_name, department, salary)
VALUES
    (1, 'Amit', 'IT', 80000),
    (2, 'Priya', 'IT', 90000),
    (3, 'Rahul', 'IT', 90000),
    (4, 'Neha', 'IT', 70000),
    (5, 'Rohan', 'HR', 60000),
    (6, 'Sneha', 'HR', 75000),
    (7, 'Ankit', 'HR', 75000),
    (8, 'Pooja', 'HR', 55000),
    (9, 'Vikas', 'Finance', 85000),
    (10, 'Kiran', 'Finance', 65000),
    (11, 'Meera', 'Finance', 95000),
    (12, 'Arjun', 'Finance', 85000);

-- STEP 5: Display all employee records
SELECT *
FROM employees;

-- STEP 6: Assign a unique row number by salary
SELECT
    employee_name,
    department,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

-- STEP 7: Rank employees by salary
-- RANK() leaves gaps after tied salaries
SELECT
    employee_name,
    department,
    salary,
    RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- STEP 8: Rank employees without gaps
-- DENSE_RANK() does not leave gaps after ties
SELECT
    employee_name,
    department,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_salary_rank
FROM employees;

-- STEP 9: Rank employees separately within each department
SELECT
    employee_name,
    department,
    salary,
    RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS department_rank
FROM employees;

-- STEP 10: Calculate each department's average salary
-- The average is repeated for each employee in that department
SELECT
    employee_name,
    department,
    salary,
    AVG(salary) OVER (
        PARTITION BY department
    ) AS department_avg_salary
FROM employees;

-- STEP 11: Calculate total salary by department
SELECT
    employee_name,
    department,
    salary,
    SUM(salary) OVER (
        PARTITION BY department
    ) AS department_total_salary
FROM employees;

-- STEP 12: Show the top 3 ranked employees in each department
-- Employees tied at rank 3 are also included
SELECT *
FROM (
    SELECT
        employee_id,
        employee_name,
        department,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS department_rank
    FROM employees
) AS ranked_employees
WHERE department_rank <= 3
ORDER BY department, department_rank, employee_name;

-- STEP 13: Compare ROW_NUMBER, RANK, and DENSE_RANK
SELECT
    employee_name,
    department,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department
        ORDER BY salary DESC, employee_id
    ) AS row_num,
    RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS salary_rank,
    DENSE_RANK() OVER (
        PARTITION BY department
        ORDER BY salary DESC
    ) AS dense_salary_rank
FROM employees
ORDER BY department, salary DESC;

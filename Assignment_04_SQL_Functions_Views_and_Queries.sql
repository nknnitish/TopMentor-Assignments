
-- ============================================================
-- ASSIGNMENT 4: SQL FUNCTIONS, VIEWS AND QUERIES
-- Independent project - MySQL Workbench
-- ============================================================

-- STEP 1: Create and select a separate database
CREATE DATABASE IF NOT EXISTS sql_functions_project;
USE sql_functions_project;

-- STEP 2: Remove existing project objects for safe reruns
DROP VIEW IF EXISTS top_five_genres;
DROP VIEW IF EXISTS high_earners;
DROP PROCEDURE IF EXISTS GetHighEarners;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS films;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- STEP 3: Create department table
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);

INSERT INTO departments VALUES
(1, 'HR'),
(2, 'Finance'),
(3, 'IT'),
(4, 'Marketing'),
(5, 'Data Science');

-- STEP 4: Create employee table
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    department_id INT,
    salary DECIMAL(10,2),
    email VARCHAR(100),
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

-- STEP 5: Insert sample employee data
INSERT INTO employees VALUES
(1, 'Alice', 1, 50000, 'alice@example.com'),
(2, 'Bob', 2, 60000, 'bob@example.com'),
(3, 'Charlie', 3, 70000, 'charlie@example.com'),
(4, 'Diana', 4, 71000, 'diana@example.com'),
(5, 'Ethan', 2, 53000, 'ethan@example.com'),
(6, 'Fiona', 3, 66000, 'fiona@example.com'),
(7, 'George', 1, 47000, 'george@example.com'),
(8, 'Hannah', 4, 59000, 'hannah@example.com'),
(9, 'Ian', 3, 64000, 'ian@example.com'),
(10, 'Julia', 5, 80000, 'julia@example.com');

-- STEP 6: Display employee records
SELECT * FROM employees;

-- STEP 7: Use string functions UPPER and CONCAT
SELECT
    emp_id,
    UPPER(CONCAT(name, ' - ', email)) AS employee_details
FROM employees;

-- STEP 8: Find minimum, maximum, average and total salary
SELECT
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary,
    ROUND(AVG(salary), 2) AS average_salary,
    SUM(salary) AS total_salary
FROM employees;

-- STEP 9: Search names using LIKE
SELECT *
FROM employees
WHERE name LIKE 'A%';

-- Find names containing the letter 'a'
SELECT *
FROM employees
WHERE name LIKE '%a%';

-- STEP 10: Filter employees using IN
SELECT *
FROM employees
WHERE department_id IN (1, 3, 5);

-- STEP 11: Group employees by department
SELECT
    d.department_name,
    COUNT(e.emp_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS average_salary,
    SUM(e.salary) AS total_salary
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_salary DESC;

-- STEP 12: Use HAVING to filter grouped results
SELECT
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 60000;

-- STEP 13: Use CASE to categorize salaries
SELECT
    name,
    salary,
    CASE
        WHEN salary >= 70000 THEN 'High Salary'
        WHEN salary >= 55000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM employees;

-- STEP 14: INNER JOIN employees with departments
SELECT
    e.emp_id,
    e.name,
    d.department_name,
    e.salary
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.department_id;

-- STEP 15: LEFT JOIN to show all departments,
-- including departments without employees
SELECT
    d.department_name,
    e.name AS employee_name
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id;

-- STEP 16: Find employees earning above average salary
SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY salary DESC;

-- STEP 17: Use a subquery in the FROM clause
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM (
    SELECT department_id, salary
    FROM employees
    WHERE salary IS NOT NULL
) AS employee_data
GROUP BY department_id;

-- STEP 18: Use a subquery in the SELECT clause
SELECT
    name,
    salary,
    (SELECT ROUND(AVG(salary), 2)
     FROM employees) AS company_average_salary
FROM employees;

-- STEP 19: Find employees in departments where
-- at least one employee earns more than 65000
SELECT name, department_id, salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    WHERE salary > 65000
);

-- STEP 20: Correlated subquery to find employees
-- earning above their own department's average
SELECT e1.name, e1.department_id, e1.salary
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
);

-- STEP 21: Create a view for high-earning employees
CREATE VIEW high_earners AS
SELECT
    e.name,
    d.department_name,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE e.salary > 65000;

-- Query the view
SELECT * FROM high_earners;

-- STEP 22: Create a stored procedure
DELIMITER $$

CREATE PROCEDURE GetHighEarners(IN min_salary DECIMAL(10,2))
BEGIN
    SELECT
        e.name,
        d.department_name,
        e.salary
    FROM employees e
    JOIN departments d
        ON e.department_id = d.department_id
    WHERE e.salary >= min_salary
    ORDER BY e.salary DESC;
END$$

DELIMITER ;

-- Execute the procedure
CALL GetHighEarners(60000);

-- STEP 23: Create sample film and payment tables
-- These demonstrate genre sales analysis independently
CREATE TABLE films (
    film_id INT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    film_id INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (film_id) REFERENCES films(film_id)
);

INSERT INTO films VALUES
(1, 'Data Adventure', 'Adventure'),
(2, 'SQL Mystery', 'Drama'),
(3, 'Python Journey', 'Adventure'),
(4, 'Finance Story', 'Drama'),
(5, 'Marketing World', 'Comedy'),
(6, 'AI Future', 'Sci-Fi'),
(7, 'Space Mission', 'Sci-Fi'),
(8, 'Funny Office', 'Comedy');

INSERT INTO payments VALUES
(1, 1, 500),
(2, 2, 300),
(3, 3, 700),
(4, 4, 400),
(5, 5, 250),
(6, 6, 800),
(7, 7, 650),
(8, 8, 350),
(9, 1, 200),
(10, 6, 450);

-- STEP 24: Calculate total sales by genre
SELECT
    f.genre,
    SUM(p.amount) AS total_sales
FROM films f
JOIN payments p
    ON f.film_id = p.film_id
GROUP BY f.genre
ORDER BY total_sales DESC;

-- STEP 25: Create a view for the top five genres
CREATE VIEW top_five_genres AS
SELECT
    f.genre,
    SUM(p.amount) AS total_sales
FROM films f
JOIN payments p
    ON f.film_id = p.film_id
GROUP BY f.genre
ORDER BY total_sales DESC
LIMIT 5;

-- Display the view
SELECT * FROM top_five_genres;

-- STEP 26: Final checks
SHOW FULL TABLES;
SHOW PROCEDURE STATUS
WHERE Db = 'sql_functions_project';

-- END OF ASSIGNMENT 4

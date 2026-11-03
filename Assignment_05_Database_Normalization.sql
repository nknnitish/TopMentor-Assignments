
-- ============================================================
-- ASSIGNMENT 5: DATABASE NORMALIZATION
-- Topic: UNF, 1NF, 2NF and 3NF
-- ============================================================

-- STEP 1: Create a separate database
CREATE DATABASE IF NOT EXISTS normalization_project;
USE normalization_project;

-- STEP 2: Remove old tables so the script can be rerun
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS student_courses_1nf;
DROP TABLE IF EXISTS student_courses_unnormalized;

-- STEP 3: Create an unnormalized table
-- A student can have multiple courses in one field.
CREATE TABLE student_courses_unnormalized (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    courses VARCHAR(200),
    department VARCHAR(100)
);

INSERT INTO student_courses_unnormalized VALUES
(1, 'Rahul', 'SQL, Python', 'Computer Science'),
(2, 'Priya', 'Excel, Power BI', 'Business Analytics'),
(3, 'Amit', 'SQL, Power BI', 'Computer Science');

-- Display the unnormalized data
SELECT * FROM student_courses_unnormalized;

-- STEP 4: Convert to First Normal Form (1NF)
-- Each row contains one student-course combination.
CREATE TABLE student_courses_1nf (
    student_id INT,
    student_name VARCHAR(100),
    course_name VARCHAR(100),
    department VARCHAR(100),
    PRIMARY KEY (student_id, course_name)
);

INSERT INTO student_courses_1nf VALUES
(1, 'Rahul', 'SQL', 'Computer Science'),
(1, 'Rahul', 'Python', 'Computer Science'),
(2, 'Priya', 'Excel', 'Business Analytics'),
(2, 'Priya', 'Power BI', 'Business Analytics'),
(3, 'Amit', 'SQL', 'Computer Science'),
(3, 'Amit', 'Power BI', 'Computer Science');

SELECT * FROM student_courses_1nf;

-- STEP 5: Create a department table (3NF design)
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO departments VALUES
(1, 'Computer Science'),
(2, 'Business Analytics');

-- STEP 6: Create the students table
-- Department details are stored separately to reduce duplication.
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

INSERT INTO students VALUES
(1, 'Rahul', 1),
(2, 'Priya', 2),
(3, 'Amit', 1);

-- STEP 7: Create the courses table
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO courses VALUES
(101, 'SQL'),
(102, 'Python'),
(103, 'Excel'),
(104, 'Power BI');

-- STEP 8: Create the enrollments table
-- This resolves the many-to-many student-course relationship.
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO enrollments VALUES
(1, 101),
(1, 102),
(2, 103),
(2, 104),
(3, 101),
(3, 104);

-- STEP 9: View students and their departments
SELECT
    s.student_id,
    s.student_name,
    d.department_name
FROM students s
JOIN departments d
    ON s.department_id = d.department_id
ORDER BY s.student_id;

-- STEP 10: View students and their enrolled courses
SELECT
    s.student_id,
    s.student_name,
    c.course_name
FROM enrollments e
JOIN students s
    ON e.student_id = s.student_id
JOIN courses c
    ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_name;

-- STEP 11: Count students enrolled in each course
SELECT
    c.course_name,
    COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY student_count DESC, c.course_name;

-- STEP 12: Count courses for each student
SELECT
    s.student_id,
    s.student_name,
    COUNT(e.course_id) AS course_count
FROM students s
LEFT JOIN enrollments e
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name
ORDER BY s.student_id;

-- STEP 13: Display the normalized table structure
DESCRIBE students;
DESCRIBE departments;
DESCRIBE courses;
DESCRIBE enrollments;

-- STEP 14: Verify all normalized records
SELECT * FROM departments;
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollments;

-- END OF ASSIGNMENT 5

-- 1. Distinct Values
SELECT DISTINCT salary FROM employees;

-- 2. Alias
SELECT age AS Employee_Age, salary AS Employee_Salary FROM employees;

-- 3. WHERE Clause
SELECT * FROM employees WHERE salary > 50000 AND hire_date < '2016-01-01';

-- 4. Fix missing designation
UPDATE employees SET designation = 'Data Scientist' WHERE employee_id = 5004;

-- 5. ORDER BY
SELECT * FROM employees ORDER BY department_id ASC, salary DESC;

-- 6. LIMIT
SELECT * FROM employees WHERE hire_date BETWEEN '2018-01-01' AND '2018-12-31' LIMIT 5;

-- 7a. SUM
SELECT SUM(salary) AS Total_Finance_Salary FROM employees e JOIN departments d ON e.department_id = d.department_id WHERE d.department_name = 'Finance';

-- 7b. MIN
SELECT MIN(age) AS Minimum_Age FROM employees;

-- 8a. GROUP BY - max salary per location
SELECT l.location_name, MAX(e.salary) AS Max_Salary FROM employees e JOIN locations l ON e.location_id = l.location_id GROUP BY l.location_name;

-- 8b. GROUP BY - avg salary per Analyst designation
SELECT designation, AVG(salary) AS Average_Salary FROM employees WHERE designation LIKE '%Analyst%' GROUP BY designation;

-- 9a. HAVING - departments with fewer than 3 employees
SELECT department_id, COUNT(*) AS Employee_Count FROM employees GROUP BY department_id HAVING COUNT(*) < 3;

-- 9b. HAVING - locations with female avg age below 30
SELECT l.location_name, AVG(e.age) AS Average_Age FROM employees e JOIN locations l ON e.location_id = l.location_id WHERE e.gender = 'F' GROUP BY l.location_name HAVING AVG(e.age) < 30;

-- 10. Inner Join
SELECT e.employee_name, e.designation, d.department_name FROM employees e INNER JOIN departments d ON e.department_id = d.department_id;

-- 11. Left Join
SELECT d.department_name, COUNT(e.employee_id) AS Total_Employees FROM departments d LEFT JOIN employees e ON d.department_id = e.department_id GROUP BY d.department_name;

-- 12. Right Join
SELECT l.location_name, e.employee_name FROM employees e RIGHT JOIN locations l ON e.location_id = l.location_id;
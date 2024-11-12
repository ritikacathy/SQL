# BASIC SQL QUERIES

# Retrieve all columns for each employee in the Scranton branch.
SELECT *
FROM employee
WHERE branch_id = 2

# List the names of all clients served by employees in the Stamford branch.
SELECT *
FROM client
WHERE branch_id = 3

# Show the first name, last name, and salary of all employees who report directly to David Wallace.
SELECT first_name, last_name, salary
FROM employee
WHERE super_id = 100


# FILTERING AND SORTING DATA

# Find all employees who earn more than $70,000 and work in the Scranton branch.
SELECT *
FROM employee
WHERE branch_id = 2 AND salary > 70000

# List all suppliers who supply "Paper" products to any branch, 
# sorted alphabetically by supplier_name.
SELECT *
FROM branch_supplier
WHERE supply_type = 'Paper'
ORDER BY supplier_name ASC

# Retrieve a list of employees born before the year 1970, 
# ordered by their birth_day in descending order.
SELECT *
FROM employee
WHERE birth_date < '1970-01-01'
ORDER BY birth_date DESC

# AGGREGATE FUNCTIONS

# What is the total salary expense for each branch?
SELECT branch_id, SUM(salary)
FROM employee
GROUP BY branch_id

# Find the average sales made by employees who work with clients in the Scranton branch.
SELECT AVG(total_sales)
FROM works_with
JOIN client ON client.client_id = works_with.client_id
WHERE branch_id = 2

# Count the number of male and female employees in each branch.
SELECT sex, COUNT(sex) AS count
FROM employee
GROUP BY sex

# GROUPING DATA

# For each branch, show the total number of employees and their combined salary.
SELECT COUNT(*) AS count_of_emp, branch_id, SUM(salary) AS total_salary
FROM employee
GROUP BY branch_id

# Find the total sales for each employee who works with clients, grouped by emp_id.
SELECT employee.first_name, employee.last_name, SUM(total_sales) AS total_sales
FROM works_with
JOIN employee ON works_with.emp_id = employee.emp_id
GROUP BY employee.emp_id

# Group the suppliers by supply_type and count the number of suppliers per type.
SELECT supply_type, COUNT(supplier_name) AS count_of_suppliers
FROM branch_supplier
GROUP BY supply_type

# JOINS

# List each employee's name alongside the branch they work in.
SELECT first_name, last_name, branch.branch_name
FROM employee
JOIN branch ON branch.branch_id = employee.branch_id

# Show each branch's name along with the names of clients associated with that branch.
SELECT branch_name, client.client_name
FROM branch
JOIN client ON branch.branch_id = client.branch_id

# Find the names of all employees who have worked with the client "FedEx."
SELECT first_name, last_name
FROM employee
JOIN works_with ON works_with.emp_id = employee.emp_id
WHERE client_id = 402

# SUBQUERIES

# List the names of all employees whose salary is above the average salary in their branch.
SELECT first_name, last_name
FROM employee a
WHERE salary > (SELECT AVG(salary)
				FROM employee b
				WHERE b.branch_id = a.branch_id); # for comparing a specific branch and not all 3 branches
                
# Find the branches where at least one employee reports directly to David Wallace.
SELECT branch_name
FROM branch
WHERE branch_id IN (SELECT branch_id FROM employee WHERE super_id = 100);

# Retrieve the names of employees who work in branches that supply "Writing Utensils."
SELECT first_name, last_name
FROM employee
WHERE branch_id IN (SELECT branch_id
FROM branch_supplier
WHERE supply_type = 'Writing Utensils');

# DATA MODIFICATION

# Increase the salary by 5% for all employees who work in the Scranton branch.
UPDATE employee
SET salary = salary + salary*5/100
WHERE branch_id = 2

SELECT *
FROM employee

# Transfer "John Daly Law, LLC" to be managed by the Scranton branch.
UPDATE client
SET branch_id = 2
WHERE client_id = 403

SELECT *
FROM client

# Remove the branch named "Buffalo" along with all related data, but keep the employees.
DELETE 
FROM branch
WHERE branch_id = 4

SELECT *
FROM branch

# TABLE CREATION AND MODIFICATION

# Create a new table called training_sessions with columns session_id, 
# emp_id, session_name, and date.
CREATE TABLE training_sessions (
	session_id INT PRIMARY KEY,
    emp_id INT,
    session_name VARCHAR(40),
    session_date DATE,
    FOREIGN KEY training_sessions(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE
);

SELECT *
FROM training_sessions

# Modify the employee table to add a new column job_title.
ALTER TABLE employee
ADD job_title VARCHAR(40);

SELECT *
FROM employee

# Delete the branch_supplier records where the supply type is "Custom Forms."
SET SQL_SAFE_UPDATES = 0;

DELETE FROM branch_supplier
WHERE supply_type = 'Custom Forms';

SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM branch_supplier

# CONSTRAINTS AND INDEXES

# Add a unique constraint to ensure that each branch can only work with a supplier once per supply_type.
ALTER TABLE branch_supplier
ADD CONSTRAINT unique_branch_supplier_supply UNIQUE (branch_id, supplier_name, supply_type);

# Create an index on salary in the employee table to improve the performance of salary-based queries.
CREATE INDEX index_salary
ON employee (salary);

# Add a foreign key to link works_with to a new sales_team table.
# creating sales_team table

CREATE TABLE sales_team (
	team_id INT PRIMARY KEY,
    team_name VARCHAR(40)
);

ALTER TABLE works_with
ADD COLUMN team_id INT,
ADD FOREIGN KEY (team_id) REFERENCES sales_team(team_id);

# VIEWS

# Create a view called high_earning_employees that includes only employees earning more than $100,000.
CREATE VIEW high_earning_employees AS
SELECT first_name, last_name, salary
FROM employee
WHERE salary > 100000

SELECT *
FROM high_earning_employees

# Make a view called branch_clients that lists each branch and its associated clients.
CREATE VIEW branch_clients AS
SELECT branch_name, client.client_name
FROM branch
JOIN client ON branch.branch_id = client.branch_id

SELECT *
FROM branch_clients

# Create a view to show the total sales made by each employee for each client they work with.
CREATE VIEW sales_per_emp_and_client AS
SELECT employee.first_name, employee.last_name, total_sales, client_id
FROM works_with
JOIN employee ON employee.emp_id = works_with.emp_id

SELECT *
FROM sales_per_emp_and_client

# OR

CREATE VIEW sales_per_emp_and_client_2 AS
SELECT employee.first_name, employee.last_name, total_sales, client_name
FROM works_with
JOIN employee ON employee.emp_id = works_with.emp_id
JOIN client ON works_with.client_id = client.client_id

SELECT *
FROM sales_per_emp_and_client_2
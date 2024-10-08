
1) What is the average salary of employees across all departments who have held more than one job within the company?

    Table Schema:

        employees
            id: Serial, unique identifier for each employee.
            first_name: Varchar(255), employee's first name.
            last_name: Varchar(255), employee's last name.
            hire_date: Date, the date when the employee was hired.
            department_id: Integer, links to the departments table.
            inserted_at: Timestamp with timezone, the time when the employee was added.
            updated_at: Timestamp with timezone, the last time the employee's information was updated.

        departments
            id: Serial, unique identifier for each department.
            name: Varchar(255), name of the department.
            location: Varchar(255), location of the department.
            inserted_at: Timestamp with timezone, the time when the department was added.
            updated_at: Timestamp with timezone, the last time the department's information was updated.

        jobs
            id: Serial, unique identifier for each job.
            title: Varchar(255), title of the job.
            min_salary: Numeric, minimum salary for the job.
            max_salary: Numeric, maximum salary for the job.
            inserted_at: Timestamp with timezone, the time when the job was added.
            updated_at: Timestamp with timezone, the last time the job's information was updated.

        salaries
            id: Serial, unique identifier for each salary entry.
            employee_id: Integer, links to the employees table.
            amount: Numeric, the salary amount.
            start_date: Date, the start date of the salary period.
            end_date: Date, the end date of the salary period.
            inserted_at: Timestamp with timezone, the time when the salary entry was added.
            updated_at: Timestamp with timezone, the last time the salary entry was updated.

        employee_jobs
        employee_id: Integer, links to the employees table.
        job_id: Integer, links to the jobs table.
        start_date: Date, the start date of the job assignment.
        end_date: Date, the end date of the job assignment (nullable).
        inserted_at: Timestamp with timezone, the time when the job assignment was added.
        updated_at: Timestamp with timezone, the last time the job assignment was updated.


    Query:

        SELECT AVG(s.amount) AS average_salary
        FROM salaries s 
        JOIN employee_jobs ej ON s.employee_id = ej.employee_id
        JOIN (
            SELECT employee_id
            FROM employee_jobs
            GROUP BY employee_id
            HAVING COUNT(DISTINCT job_id) > 1
        ) multiple_jobs ON ej.employee_id = multiple_jobs.employee_id;


    -- First Join: Establishes the link between employees and their job history, giving us access to both salary and job data.
    -- Second Join: Filters the results further to include only those employees who have held more than one job in the company.

----------------------------------------------

2) Identify the supplier with the most approved parts: Consider only the latest approval for each part, calculate the total cost associated with these approvals, and output supplier name, number of parts, and total cost.

    Table Schema

        SUPPLIER: 
            supplier_id,
            supplier_name,
            supplier_street,
            etc.

        PART: 
            part_id,
            part_name,
            commodity,
            qty_unit,
            inventory,
            status

        APPROVAL_DETAILS: 
            part_appr_id,
            part_id,
            supp_id,
            app_status,
            app_date,
            app_cost

    Query:

        WITH LatestApprovals AS (
            SELECT a.part_id, a.approval_date, a.app_cost, a.supp_id
            FROM APPROVAL_DETAILS a
            WHERE a.app_status = 'APPROVED'
            AND a.approval_date = (
                SELECT MAX(approval_date)
                FROM APPROVAL_DETAILS
                WHERE part_id = a.part_id
            )
        )

        SELECT s.supplier_name, COUNT(DISTINCT l.part_id) AS num_parts, SUM(l.app_cost) AS total_cost
        FROM SUPPLIER s
        JOIN LatestApprovals l ON s.supplier_id = l.supp_id
        GROUP BY s.supplier_id
        ORDER BY num_parts DESC
        LIMIT 1;


-------------------------------------------------------------
3)
    Find the top 5 departments with the highest average GPA.
    Consider only departments where the average age of enrolled students is below 25.
    Include only courses taught by professors with at least 5 years of service.
    Courses must have at least [missing criteria].
    Data Structure (Based on the images):

    Table Schema: 
        Professors:
            professor_id,
            first_name,
            last_name,
            hire_date,
            department_id
        Courses:
            course_id,
            course_name,
            department_id,
            start_date,
            end_date,
            credits
        Departments:
            department_id,
            department_name,
            location
        Enrollments:
            enrollment_id,
            student_id,
            course_id,
            grade
        Students:
            student_id,
            first_name,
            last_name,
            date_of_birth,
            major

    Query:

    WITH EligibleDepartments AS (
        SELECT d.department_id
        FROM Departments d
        
        JOIN Professors p ON d.department_id = p.department_id
        JOIN Courses c ON d.department_id = c.department_id
        JOIN Enrollments e ON c.course_id = e.course_id
        JOIN Students s ON e.student_id = s.student_id

        WHERE p.hire_date <= DATE_ADD(CURDATE(), INTERVAL -5 YEAR) -- Adjust for specific date format
        AND AVG(s.date_of_birth) < DATE_ADD(CURDATE(), INTERVAL -25 YEAR) -- Adjust for specific date format
        AND c.credits >= [minimum credits] -- Replace with the required minimum credits
        GROUP BY d.department_id
        HAVING AVG(e.grade) IS NOT NULL
    )

    SELECT d.department_id, AVG(e.grade) AS average_gpa
    FROM Departments d
    JOIN EligibleDepartments ed ON d.department_id = ed.department_id
    JOIN Courses c ON d.department_id = c.department_id
    JOIN Enrollments e ON c.course_id = e.course_id
    GROUP BY d.department_id
    ORDER BY average_gpa DESC
    LIMIT 5;
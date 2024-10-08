
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
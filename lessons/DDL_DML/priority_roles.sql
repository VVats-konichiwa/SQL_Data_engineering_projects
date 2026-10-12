--We create the foruth table that is the priority_job_snapshot table
--This table is made by adding the job_postings_fact/company_dim + priority_roles table

--for priority_roles, we change it entirely everytime there's a change in the data for the table

CREATE OR REPLACE TABLE staging.priority_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INTEGER
);

INSERT INTO staging.priority_roles (role_id, role_name, priority_lvl)
VALUES
    (1, 'Data Engineer', 1),
    (2, 'Data Analyst', 3),
    (3, 'Senior Data Engineer', 1),
    (4, 'Data Scientist', 2);

SELECT * FROM staging.priority_roles;

-- .read ./lessons/DDL_DML/priority_roles.sql

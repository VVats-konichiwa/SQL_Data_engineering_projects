-- .read ./lessons/DDL_DML_pt2.sql
--USE jobs_mart

--Creating a table based on job_postings_fact and company_dim
CREATE OR REPLACE TABLE staging.job_postings_flat AS 
SELECT 
    jpf.job_id, 
    jpf.job_title_short,
    cd.name as company_name,
    jpf.salary_year_avg,
    jpf.job_location
FROM data_jobs.job_postings_fact as jpf
LEFT JOIN data_jobs.company_dim as cd
    ON jpf.company_id = cd.company_id;

SELECT COUNT(*)
FROM staging.job_postings_flat;


--CREATING VIEW based on job_postins_flat and priority_role
CREATE OR REPLACE VIEW main.priority_jobs_flat_view AS
SELECT 
    jpf.*
FROM staging.job_postings_flat as jpf
JOIN staging.priority_roles as r
    ON r.role_name = jpf.job_title_short
WHERE r.priority_lvl = 1;

SELECT COUNT(*)
FROM main.priority_jobs_flat_view;


--Creating a temp table based on the job_postings_flat only
CREATE OR REPLACE TEMP TABLE senior_jobs_flat_temp AS
SELECT *
FROM main.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';

SELECT COUNT(*)
FROM senior_jobs_flat_temp;

-------DELETING a row

SELECT COUNT(*)
FROM staging.job_postings_flat;

DELETE FROM staging.job_postings_flat
WHERE job_location = 'Pakistan';

SELECT COUNT(*)
FROM staging.job_postings_flat;

--TRUNCATING a table

--TRUNCATE TABLE staging.job_postings_flat; --Removes all the rows, will not execute it


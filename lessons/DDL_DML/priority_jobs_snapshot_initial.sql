--for priority jobs_snapshots


--INITIAL LOADING (we'll only need this one time, after that we'll just use insert, update, delete to take the new data into the account)
--we first create the table, with desired columns and then add the desired values to them
--the values would be join the of all the three tables, job_postings_fact, company_dim, and priority_roles

CREATE OR REPLACE TABLE main.priority_jobs_snapshot(
    job_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP
);

INSERT INTO main.priority_jobs_snapshot(
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at 
)
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    cd.name as company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP  --gives the current timestamp
FROM 
    data_jobs.job_postings_fact as jpf
LEFT JOIN data_jobs.company_dim as cd
    ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles as r
    ON r.role_name = jpf.job_title_short;

SELECT 
    job_title_short,
    COUNT(*) as job_count,
    MIN(priority_lvl) as priority_lvl,
    MIN(updated_at) as updated_at
FROM priority_jobs_snapshot
GROUP BY 
    job_title_short
ORDER BY 
    job_count DESC;


--UPDATE/INSERT/DELETE batch processing


--Same batch processing by MERGE INTO operations

--Create a temp src table
CREATE OR REPLACE TEMP TABLE src_priority_jobs AS
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    cd.name as company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP as updated_at      --gives the current timestamp
FROM 
    data_jobs.job_postings_fact as jpf
LEFT JOIN data_jobs.company_dim as cd
    ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles as r
    ON r.role_name = jpf.job_title_short;



--MERGE INTO 
MERGE INTO 
    main.priority_jobs_snapshot as tgt
USING 
    src_priority_jobs as src
ON 
    tgt.job_id = src.job_id

WHEN MATCHED AND src.priority_lvl IS DISTINCT FROM tgt.priority_lvl THEN 
UPDATE SET
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at

WHEN NOT MATCHED THEN 
INSERT(
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at 
)
VALUES(
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at 
)

WHEN NOT MATCHED BY SOURCE THEN
DELETE;


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
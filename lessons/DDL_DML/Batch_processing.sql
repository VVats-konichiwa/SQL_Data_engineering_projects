--Here we take a look onto how we handle the changes in the data and how do we keep our snapshot table up to date with the changes


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


--Usage of UPDATE when there's a match in both the tables
UPDATE main.priority_jobs_snapshot as tgt
SET 
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at
FROM src_priority_jobs as src
WHERE tgt.job_id = src.job_id
    AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl;



--Usage of INSERT when there a data row in src but not in the target (snapshot vaali table) [Existential matching]
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
    src.*
FROM src_priority_jobs as src
WHERE NOT EXISTS (
    SELECT 1
    FROM main.priority_jobs_snapshot as tgt
    WHERE tgt.job_id = src.job_id
);



--Usage of DELETE when there's a data row in tgr but not in src [Existential matching but reversed]
DELETE FROM main.priority_jobs_snapshot as tgt
WHERE NOT EXISTS(
    SELECT 1
    FROM src_priority_jobs as src
    WHERE src.job_id = tgt.job_id
);


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
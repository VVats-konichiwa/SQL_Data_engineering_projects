SELECT 
    job_id, 
    job_title_short,
    salary_year_avg,
    company_id
FROM
    job_postings_fact
LIMIT 10;

SELECT
    company_id,
    name
FROM 
    company_dim
LIMIT 10;

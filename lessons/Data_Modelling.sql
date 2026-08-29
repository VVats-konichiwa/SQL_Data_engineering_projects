SELECT * 
FROM information_schema.tables
WHERE table_catalog = 'data_jobs';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'job_postings_fact';

SELECT *
FROM information_schema.key_column_usage;

SELECT 
    jpf.job_id,
    cd.name AS comapny_name,
    jpf.job_title_short
FROM 
    job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE jpf.company_id = 5;

SELECT cd.name, COUNT(*) AS num_postings
FROM job_postings_fact jpf
LEFT JOIN company_dim cd ON jpf.company_id = cd.company_id
GROUP BY cd.name;
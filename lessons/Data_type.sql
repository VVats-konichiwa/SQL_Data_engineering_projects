SELECT 
    column_name, 
    data_type
FROM 
    information_schema.columns
WHERE
    table_name = 'job_postings_fact';

SELECT 
    job_id,
    job_title_short,
    CAST(job_no_degree_mention AS INT) AS Degree,
    CAST(salary_year_avg AS DECIMAL(7,1)) AS salary
FROM 
    job_postings_fact
WHERE 
    job_title_short = 'Data Engineer'
    AND CAST(job_no_degree_mention AS INT) <> 0
    AND salary_year_avg IS NOT NULL
LIMIT 10;
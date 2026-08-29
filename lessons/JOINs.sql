SELECT *
FROM 
    skills_job_dim;

SELECT * 
FROM skills_dim;

SELECT 
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills
FROM 
    job_postings_fact as jpf
INNER JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id;

SELECT DISTINCT 
    job_title_short
FROM 
    job_postings_fact;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'job_postings_fact';

DESCRIBE job_postings_fact;

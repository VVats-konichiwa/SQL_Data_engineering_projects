--Subqueries


--We need the data engineering jobs in India only 
SELECT 
    job_id, 
    salary_year_avg,
    job_country
FROM (
    SELECT * FROM job_postings_fact WHERE job_country = 'India'
)
WHERE 
    job_title_short = 'Data Engineer'
    AND salary_year_avg IS NOT NULL
LIMIT 10;

--Complex subqueries
 
--subquery within SELECT 
--Show each job's salary next to the overall market median

SELECT 
    job_title_short,
    salary_year_avg,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
    ) AS median_market
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

--subquery within FROM
--Stage only jobs that are remote before aggregating 
--to determine the remote median salary per job

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS remote_median_salary,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS median_market
FROM (
    SELECT * 
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS remote_jobs
GROUP BY 
    job_title_short
LIMIT 10;


--Subquery in HAVING
-- Keep only job titles whose median salary is above the overall median

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS remote_median_salary,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS median_market
FROM (
    SELECT * 
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS remote_jobs
GROUP BY 
    job_title_short
HAVING
    remote_median_salary > (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    )
ORDER BY 
    remote_median_salary DESC
LIMIT 10;





--CTEs (common table expression)
--Compare how much more (or less) remote roles pay compared to onsite rolse for each job title
-- Use a CTE to calculate the median salary by title and work arrangement, and then compare those medians

WITH title_table AS (
    SELECT 
        job_title_short,
        job_work_from_home,
        MEDIAN(salary_year_avg) AS median_salary
    FROM job_postings_fact
    WHERE 
        job_country = 'India'
    GROUP BY
        job_title_short,
        job_work_from_home
)

SELECT 
    r.job_title_short,
    r.median_salary as remote_median, 
    o.median_salary as onsite_median,
    (r.median_salary - o.median_salary) as remote_premium
FROM title_table as r
INNER JOIN title_table as o
    ON r.job_title_short = o.job_title_short
WHERE r.job_work_from_home = TRUE
    AND o.job_work_from_home = FALSE
ORDER BY
    remote_premium DESC;



--Existential filtering (WHERE EXISTS / WHERE NOT EXISTS)
--Identify the job postings that have no associated skills before loading them into
--data mart

--need jobs, that have no skills associated to them 

SELECT 
    job_title_short, 
    job_location,
    job_country, 
    job_work_from_home
FROM job_postings_fact as src
WHERE NOT EXISTS(
    SELECT 1
    FROM skills_job_dim as tgt
    WHERE src.job_id = tgt.job_id
)
ORDER BY job_id
LIMIT 10;
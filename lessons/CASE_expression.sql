--Bucketting Data
 /*
  < 25 is LOW
  25-50 is MEDIUM
  > 50 is HIGH
 */

SELECT
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg < 25 
            THEN 'Low'
        WHEN salary_hour_avg >= 25 AND salary_hour_avg <= 50
            THEN 'Medium'
        ELSE 'High'
    END as salary_bucket
FROM job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
LIMIT 10;  



--Handling NULL values explicitly
SELECT
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg IS NULL
            THEN 'Not specified'
        WHEN salary_hour_avg < 25 
            THEN 'Low'
        WHEN salary_hour_avg >= 25 AND salary_hour_avg <= 50
            THEN 'Medium'
        ELSE 'High'
    END as salary_bucket
FROM job_postings_fact
LIMIT 10;



--Vategorizing categorical values
--Classifying the job_title coulm values as:
/*
    - Data analyst
    - Data Scientist
    - Data Engineer
*/
SELECT
    job_title,
    CASE 
        WHEN job_title LIKE '%Analyst%' AND job_title LIKE '%DATA%'
            THEN 'Data Analyst'
        WHEN job_title LIKE '%Engineer%' AND job_title LIKE '%DATA%'
            THEN 'Data Engineer'
        WHEN job_title LIKE '%Scientist%' AND job_title LIKE '%DATA%'
            THEN 'Data Scientist'
        ELSE 'Not specified'
    END as title
FROM 
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY RANDOM()
LIMIT 10;
 


/*
Conditional Aggregation
Calculate median salaries for Different Buckets
    -- < 100k $
    -- >= 100k $

job_title, total_postings, median_low, median_high
*/

SELECT
    job_title_short, 
    COUNT(*) as tot_postings,
    MEDIAN(
        CASE
            WHEN salary_year_avg < 100_000 THEN salary_year_avg
        END 
    ) as median_low_salary,
    MEDIAN(
        CASE
            WHEN salary_year_avg >= 100_000 THEN salary_year_avg
        END 
    ) as median_high_salary
FROM 
    job_postings_fact
GROUP BY 
    job_title_short
ORDER BY 
    tot_postings DESC
LIMIT 5; 


/*
Final example

Compute the standardized salary i.e either salary_year_avg or 
salary_hour_avg * 2080

Then categorize the standardized salary as 
    < 75k Low
    < 150_000 Medium
    >= 150_000 High
*/

WITH salaries AS (
    SELECT 
        job_title_short,
        salary_year_avg,
        salary_hour_avg,
        CASE
            WHEN salary_year_avg IS NOT NULL
                THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL
                THEN salary_hour_avg * 2080
    END as standardized_salary
    FROM
        job_postings_fact
    WHERE 
        salary_hour_avg IS NOT NULL
        OR salary_year_avg IS NOT NULL
)

SELECT 
    *,
    CASE
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Meidum'
        ELSE 'High'
    END as salary_bucket
FROM salaries
LIMIT 10;

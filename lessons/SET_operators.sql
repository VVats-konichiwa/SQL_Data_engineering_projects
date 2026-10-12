-- SELECT UNNEST([1,1,1,2])
-- UNION ALL
-- SELECT UNNEST([1,2,3,4]);

-- SELECT UNNEST([1,1,1,2])
-- INTERSECT ALL
-- SELECT UNNEST([1,2,1,4]);

-- SELECT UNNEST([1,2,3,4])
-- EXCEPT ALL
-- SELECT UNNEST([1,1,1,2]);

CREATE OR REPLACE TEMP TABLE job_postings_2023 AS
SELECT * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact 
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023;

CREATE OR REPLACE TEMP TABLE job_postings_2024 AS
SELECT * EXCLUDE (job_id, job_posted_date)
FROM job_postings_fact 
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;


--Which unique job postings appeared im either 2023 or 2024
SELECT *
FROM job_postings_2023
UNION 
SELECT * 
FROM job_postings_2024;

--Which job postings appeared across both the years countine duplicates
SELECT *
FROM job_postings_2023
UNION ALL
SELECT * 
FROM job_postings_2024;

--Which job postings appeared in both 2023 and 2024
SELECT *
FROM job_postings_2023
INTERSECT
SELECT * 
FROM job_postings_2024;

--Which job psotings appeared in both 2023 and 2024 including duplicates
SELECT *
FROM job_postings_2023
INTERSECT ALL
SELECT * 
FROM job_postings_2024;

--Which job postings appeared in 2023 but not in 2024
SELECT *
FROM job_postings_2023
EXCEPT
SELECT * 
FROM job_postings_2024;

--Which job psotings appeared in 2023 but not in 2024, one for one
SELECT *
FROM job_postings_2023
EXCEPT ALL
SELECT * 
FROM job_postings_2024;
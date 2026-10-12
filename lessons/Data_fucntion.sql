SELECT 
    job_posted_date,
    job_posted_date :: DATE as date,
    job_posted_date :: TIME as time,
    job_posted_date :: TIMESTAMPTZ as timestamp_with_zone
FROM
    job_postings_fact
LIMIT 10;

----
SELECT 
    EXTRACT(YEAR from job_posted_date) as year_posted,
    EXTRACT(MONTH from job_posted_date) as month_posted,
    COUNT(job_id) as total_postings
FROM 
    job_postings_fact
WHERE job_title_short = 'Data Engineer'
    AND EXTRACT(YEAR from job_posted_date) > 2022
GROUP BY 
    EXTRACT(YEAR from job_posted_date),
    EXTRACT(MONTH from job_posted_date)
ORDER BY
    year_posted, 
    month_posted;


----
SELECT 
    DATE_TRUNC('month', job_posted_date) AS month_posted,
    COUNT(job_id) as total_postings
FROM 
    job_postings_fact
WHERE job_title_short = 'Data Engineer'
    AND EXTRACT(YEAR from job_posted_date) > 2022
GROUP BY 
    DATE_TRUNC('month', job_posted_date)
ORDER BY
    month_posted;
    

SELECT 
    '2024-06-01 00:00:00+00' :: TIMESTAMPTZ AT TIME ZONE 'Asia/Tokyo';

SELECT * FROM pg_timezone_names() WHERE name LIKE 'Asia/%';

SELECT 
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Kolkata') as local_time,
    COUNT(job_id) as postings
FROM 
    job_postings_fact
WHERE
    job_country = 'India'
GROUP BY 
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Kolkata')
ORDER BY
    local_time;
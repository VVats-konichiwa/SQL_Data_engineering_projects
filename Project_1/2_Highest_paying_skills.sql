/*
Q2 What are the haighest paying skills
1. caculate the median salary for eac skill required for the data
engineer postion 
2. Focus on Data Engineering postiions in India with specified salaries
3. Include the skill frequency 
*/

SELECT 
    sd.skills,
    COUNT(jpf.job_id) as frequency,
    MEDIAN(jpf.salary_year_avg) as median_salary,
FROM 
    job_postings_fact as jpf
INNER JOIN skills_job_dim as sjd
        ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd
        ON sd.skill_id = sjd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'India'
    AND jpf.salary_year_avg IS NOT NULL
GROUP BY
    sd.skills
-- HAVING 
--     COUNT(jpf.job_id) > 50
ORDER BY 
    median_salary DESC
LIMIT 10;

/*

/* ============================================================
   PROJECT #1 - EDA: Q2 - Highest Paying Skills (Data Engineer, India)
   ============================================================

   KEY INSIGHTS:
   1. Python leads on BOTH frequency (242) and median salary ($145,025)
      among skills with reliable sample size (freq > 50) - the clearest
      "no-brainer" skill to prioritize.
   2. SQL is the most in-demand skill overall (Q1) but sits at the
      BOTTOM of the pay table ($110,000) - it's the expected baseline,
      not a salary differentiator.
   3. R matches Python's exact median salary ($145,025) despite 4x lower
      frequency (62 vs 242) - likely rides on Python's coattails since
      R rarely appears alone in DE postings.
   4. Sorting by median salary WITHOUT a demand/frequency filter surfaces
      unreliable outliers (Assembly, Rust, PHP - each from just 1 posting).
      A single data point is not a market signal.
   5. Only skills with a real sample size (e.g. MySQL: 31 postings,
      Git: 42 postings) give a salary figure worth trusting in the
      unfiltered version.
   6. Takeaway: demand and pay must be evaluated TOGETHER (see Q3),
      since salary alone or demand alone each give a misleading picture.

   PROBLEM ENCOUNTERED:
   - COUNT(jpf.job_id) and MEDIAN(jpf.salary_year_avg) were silently
     computed over DIFFERENT row sets in the same GROUP BY.
   - Root cause: COUNT(column) is only NULL-aware for that specific
     column. job_id is never NULL (PK), so COUNT(jpf.job_id) counted
     every joined row - including postings with no salary listed.
     MEDIAN() silently drops NULLs on its own, so the two aggregates
     didn't align.
   - Fix: added explicit `AND jpf.salary_year_avg IS NOT NULL` to WHERE,
     forcing both aggregates to operate over the same filtered rows.
   - Lesson: when combining multiple aggregates (COUNT + MEDIAN/AVG/SUM),
     explicitly filter NULLs on every relevant column - don't assume one
     aggregate's NULL-handling protects the others.
   ============================================================ */

┌───────────┬───────────┬───────────────┐
│  skills   │ frequency │ median_salary │
│  varchar  │   int64   │    double     │
├───────────┼───────────┼───────────────┤
│ assembly  │         1 │      159426.0 │
│ rust      │         1 │      159000.0 │
│ perl      │         2 │      151750.0 │
│ looker    │        14 │      147500.0 │
│ mysql     │        31 │      147500.0 │
│ drupal    │         1 │      147500.0 │
│ php       │         1 │      147500.0 │
│ git       │        42 │      147500.0 │
│ bitbucket │         6 │      147500.0 │
│ sheets    │         1 │      147500.0 │
├───────────┴───────────┴───────────────┤
│ 10 rows                     3 columns │
└───────────────────────────────────────┘
*/
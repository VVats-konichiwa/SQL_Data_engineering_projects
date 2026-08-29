/*
Q3 What are the most optimal skills for Data engieers - balancing both the demand
and the salary
1. Create a ranking column that combienes the demand count and median salary
to find the most optimal skills
2.Focus only on Data engineering postion in India with specified salaries
*/

SELECT 
    sd.skills,
    COUNT(jpf.job_id) as frequency,
    MEDIAN(jpf.salary_year_avg) as median_salary,
    ROUND(LN(COUNT(jpf.job_id)), 1) as LN_frequency,
    ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.job_id)))/1_000_000, 1 ) as rank
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
HAVING 
    COUNT(jpf.job_id) > 50
ORDER BY 
    rank DESC
LIMIT 10;

/*
┌─────────┬───────────┬───────────────┬──────────────┬────────┐
│ skills  │ frequency │ median_salary │ LN_frequency │  rank  │
│ varchar │   int64   │    double     │    double    │ double │
├─────────┼───────────┼───────────────┼──────────────┼────────┤
│ python  │       242 │      145025.0 │          5.5 │    0.8 │
│ nosql   │        68 │      132910.5 │          4.2 │    0.6 │
│ spark   │       133 │      131580.0 │          4.9 │    0.6 │
│ r       │        62 │      145025.0 │          4.1 │    0.6 │
│ hadoop  │        99 │      120705.0 │          4.6 │    0.6 │
│ kafka   │        65 │      135000.0 │          4.2 │    0.6 │
│ java    │        90 │      134620.5 │          4.5 │    0.6 │
│ sql     │       236 │      110000.0 │          5.5 │    0.6 │
│ aws     │       142 │       96773.0 │          5.0 │    0.5 │
│ azure   │       137 │      110000.0 │          4.9 │    0.5 │
├─────────┴───────────┴───────────────┴──────────────┴────────┤
│ 10 rows                                           5 columns │
└─────────────────────────────────────────────────────────────┘

/* ============================================================
   PROJECT #1 - EDA: Q3 - Optimal Skills (Demand + Pay Combined)
   ============================================================

   FORMULA: optimal_score = (median_salary * LN(demand_count)) / 1,000,000
   - Salary kept RAW (its range, ~96k-145k, is already fairly tight)
   - Demand LOG-TRANSFORMED (raw counts range widely, e.g. 62-242+;
     LN compresses this to a comparable scale, ~4-5.5)
   - MULTIPLIED, not added - forces a skill to score decently on BOTH
     axes; a skill can't win purely on salary or purely on demand alone

   KEY INSIGHTS:
   1. Python topped the ranking not because of one dominant metric, but
      because it's the ONLY skill tied for highest salary (145,025,
      shared with R) that ALSO has by far the highest demand (242 vs
      R's 62) - strong on both axes, nothing pulling it down.
   2. Every other skill trades off one metric for the other: SQL has
      near-top demand but lowest salary (110k); R matches Python's
      salary but has 4x lower demand; Kafka/NoSQL are mid on both.
   3. optimal_score is a RANKING device only - the number itself isn't
      a real-world unit (not a salary, not a count), don't interpret
      it literally.

   PROBLEM ENCOUNTERED:
   - First attempt multiplied median_salary * demand_count RAW (no log).
     Result closely mirrored Q1's pure demand ranking - a red flag that
     "salary" wasn't meaningfully influencing the outcome at all.
   - Root cause: demand's raw range (~62-242, ~4x spread) swings the
     product more than salary's range (~96k-145k, ~1.5x spread), so
     demand silently dominated despite both being "in" the formula.
   - Fix: applied LN() to demand_count before multiplying, shrinking its
     spread down to be comparable to salary's spread (~4.1-5.5).

   LESSON LEARNED:
   - When combining two metrics, check whether the combined result
     secretly collapses into looking like just ONE of the original
     metrics - that's a sign one term is dominating due to scale, not
     importance. LN() (or similar transforms) fixes scale mismatches;
     multiplication (vs. addition) enforces "must be good at both."
   ============================================================ */
*/
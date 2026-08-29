/*
Q1 What are the most in demand skills?
1. Identify the top 10 in demand skills for the field of data engineer
2. Focus on jobs that are in India
*/

SELECT 
    sd.skills,
    COUNT(jpf.job_id) as tot_posting
FROM job_postings_fact as jpf
INNER JOIN skills_job_dim as sjd
        ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd
        ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'India'
GROUP BY 
    sd.skills
ORDER BY 
    tot_posting DESC
LIMIT 10;
/*
┌────────────┬─────────────┐
│   skills   │ tot_posting │
│  varchar   │    int64    │
├────────────┼─────────────┤
│ sql        │       29766 │
│ python     │       27049 │
│ aws        │       17026 │
│ azure      │       16189 │
│ spark      │       15744 │
│ databricks │        9186 │
│ hadoop     │        8563 │
│ java       │        8552 │
│ snowflake  │        8534 │
│ pyspark    │        8331 │
├────────────┴─────────────┤
│ 10 rows        2 columns │
└──────────────────────────┘
*/

/* ============================================================
   PROJECT #1 - EDA: Q1 - Top In-Demand Skills (Data Engineer, India)
   Version A: remote-only | Version B: all postings (no remote filter)
   ============================================================

   KEY INSIGHTS:
   1. SQL and Python are #1 and #2 in BOTH versions - stable signal,
      not dependent on remote filter. SQL edges out Python consistently.
   2. Removing the remote filter scales counts up ~10x but ranking
      stays nearly the same - skill demand is consistent across
      remote and on-site DE roles in India.
   3. Multi-cloud market: AWS and Azure both in top 4 - worth knowing
      both, not just one.
   4. Big-data cluster (Spark, Databricks, Hadoop, pyspark) shows up
      together - these tools are usually requested as a bundle.
   5. pyspark appears only in the unfiltered top 10 (java takes its
      spot in remote-only) - pyspark roles may skew slightly more
      on-site/hybrid.

   CAVEAT: Scoped to India only. Raw posting counts, not % of total
   postings - reflects mentions, not market share.
   ============================================================ */
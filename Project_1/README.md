# Project #1: Exploratory Data Analysis (EDA) — Data Engineer Job Postings in India

Based on [Luke Barousse's Data Engineering Bootcamp](https://www.youtube.com/@LukeBarousse), with my own scope variation (all queries scoped to India specifically) and independently debugged issues documented below. Built using SQL on DuckDB, hosted via MotherDuck.

## Scope

**In scope:**
- Job title: `Data Engineer`
- Country: `India`
- Q2 and Q3 additionally filter to postings with a **specified salary** (`salary_year_avg IS NOT NULL`)

**Variation from the base project:**
- Scoped to **India** specifically (a single-country deep dive) rather than a global analysis — a personal addition on top of the base project brief.
- `Senior Data Engineer` postings are excluded — only `Data Engineer` is analyzed.

**Input → Output:** Raw `job_postings_fact` / `skills_job_dim` / `skills_dim` tables on MotherDuck → three ranked SQL queries → three sets of skill insights.

## Tech Stack

| Tool | Why |
|---|---|
| **DuckDB** | Local-dev OLAP engine — fast for analytical/aggregate queries like these, no cloud cost while prototyping |
| **MotherDuck** | Cloud-hosted DuckDB — lets the `data_jobs` dataset live remotely while querying with the same DuckDB syntax |
| **VS Code + Git Bash** | Primary dev environment |
|**Git/GitHub**|For versioned SQL scripts|

## Data Model

![ERD](../Images/Data_Warehouse.png)

---

## Q1: What are the most in-demand skills for Data Engineers?

**Goal:** Identify the top 10 in-demand skills for Data Engineer roles in India.

View the full SQL query in : **[1_In_demand_skills.sql](./1_In_demand_skills.sql)**

### Insights
- **SQL leads Python** as the single most in-demand skill for Data Engineers in India — not a close second, a clear #1.
- **Multi-cloud market:** AWS and Azure both land in the top 4 — worth knowing both ecosystems rather than specializing in just one.
- **Big-data cluster** (Spark, Databricks, Hadoop, PySpark) consistently appears together — these tools are typically requested as a bundle, part of the same big-data processing ecosystem, not independently.
- Snowflake's strong presence (8,534 postings) reflects the market's shift toward modern cloud data warehouses.

**Caveat:** Scoped to India only. Raw posting counts, not % of total postings — reflects mentions, not market share.

---

## Q2: What are the highest-paying skills for Data Engineers?

**Goal:** Calculate the median salary per skill for Data Engineer postings in India with a specified salary, including skill frequency for context.

View the full SQL query in : **[2_Highest_paying_skills.sql](./2_Highest_paying_skills.sql)**
### Insights
- **Sorting purely by median salary surfaces unreliable outliers.** Half the top 10 (Assembly, Rust, Drupal, PHP, Sheets) come from a **single job posting each** — a median from one data point isn't a market signal, it's one company's one salary offer.
- Only a couple of results here are trustworthy on sample size alone — **MySQL (31 postings, $147,500)** and **Git (42 postings, $147,500)**.
- This result directly motivated Q3: neither pure demand (Q1) nor pure salary (this query) alone tells a trustworthy story — they need to be evaluated together, with a minimum sample-size floor.

### Problem Encountered: `COUNT()` and NULL handling mismatch
- **Issue:** `COUNT(jpf.job_id)` and `MEDIAN(jpf.salary_year_avg)` were silently computed over *different* row sets within the same `GROUP BY`.
- **Root cause:** `COUNT(column)` is only NULL-aware for that specific column. `job_id` is a primary key and is never NULL, so `COUNT(jpf.job_id)` counted every joined row — including postings with no salary listed. `MEDIAN()`, meanwhile, silently drops NULLs on its own.
- **Fix:** Added an explicit `AND jpf.salary_year_avg IS NOT NULL` filter so both aggregates operate over the same row set.
- **Takeaway:** When combining multiple aggregates (`COUNT` + `MEDIAN`/`AVG`/`SUM`), explicitly filter NULLs on every relevant column — don't assume one aggregate's NULL-handling protects the others.

---

## Q3: What are the most optimal skills (high demand *and* high pay)?

**Goal:** Create a single ranking that combines demand and salary to identify skills that are both commonly requested and well-paid, for Data Engineer postings in India with specified salaries.

View the full SQL query in : **[3_Most_optimal_skills.sql](./3_Most_optimal_skills.sql)**

**Formula:** `rank = (median_salary * LN(frequency)) / 1,000,000`
- Salary kept **raw** — its range (~$96k–145k) is already fairly tight.
- Demand **log-transformed** — raw counts range widely (62–242+); `LN()` compresses this to a comparable scale (~4–5.5), preventing it from swamping salary in the product.
- **Multiplied, not added** — forces a skill to score decently on *both* axes. A skill can't win purely on salary or purely on demand; addition would let one large term compensate for a weak one.

### Insights
- **Python tops the ranking** — not because of one dominant metric, but because it's the *only* skill tied for the highest salary ($145,025, shared with R) that *also* has by far the highest demand (242 postings vs. R's 62). Strong on both axes, nothing pulling it down.
- Every other skill trades off one metric for the other: **SQL** has near-top demand but the lowest salary; **R** matches Python's salary but has ~4x lower demand; **Kafka/NoSQL** are mid-range on both.
- `rank` is a **ranking device only** — the number itself isn't a real-world unit (not a salary, not a count), and shouldn't be interpreted literally, only compared relatively within this query.

### Problem Encountered: raw multiplication collapsed into a demand-only ranking
- **Issue:** First attempt multiplied `median_salary * demand_count` with no log transform. The resulting ranking closely mirrored Q1's pure-demand ranking — a red flag that salary wasn't meaningfully influencing the outcome at all.
- **Root cause:** Demand's raw range (~62–242, a ~4x spread) swings the product more than salary's range (~$96k–145k, a ~1.5x spread), so demand silently dominated despite both terms being "in" the formula.
- **Fix:** Applied `LN()` to `demand_count` before multiplying, shrinking its spread to be comparable to salary's spread.
- **Takeaway:** When combining two metrics, check whether the combined result secretly collapses into looking like just *one* of the original metrics — that's a sign one term is dominating due to scale, not importance. Log transforms fix scale mismatches; multiplication (vs. addition) enforces "must be good at both," not "good at either."

---


## Overall Takeaways

1. **SQL is table-stakes, not a differentiator.** It's the most in-demand skill for Data Engineers in India, but sits at the bottom of the pay table among top skills — expected everywhere, so it doesn't stand out on its own.
2. **Python is the standout "optimal" skill** — strong demand and strong pay simultaneously, in a market where most skills trade off one for the other.
3. **Neither demand alone (Q1) nor salary alone (Q2, unfiltered) tells a trustworthy story on its own** — demand ignores pay, and raw salary ranking is vulnerable to single-posting outliers. A combined, scale-corrected metric (Q3) was necessary to identify genuinely "optimal" skills to prioritize learning.
4. **Statistical care matters as much as SQL syntax.** This project surfaced two real bugs — a NULL-handling mismatch (Q2) and a scale-dominance issue in a combined formula (Q3) — that produced technically-valid but misleading results. Catching both required checking *why* a number looked the way it did, not just that the query ran without error.

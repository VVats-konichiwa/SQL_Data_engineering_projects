--Arrays
SELECT [1,2,3];
SELECT ['Python', 'R', 'sql'] AS skills_array;

--Creating array using List functions
WITH skill AS(
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
), skills_array AS (
    SELECT LIST(skill ORDER BY skill) AS skills
    FROM skill
)

SELECT skills[2]
FROM skills_array;


--STRUCT
 SELECT {Class : 'First', Section : 'A'} AS struct;

--Using a function to build a Struct
WITH class_struct AS (
    SELECT 
        STRUCT_PACK(
            Class := 'First',
            Section := 'A'
        ) AS s
)

SELECT 
    s.Class AS class,
    s.Section AS section
FROM class_struct;



--Alternate way to create a struct from a table 
WITH School AS (
    SELECT 'First' AS CLASS, 'A' as SECTION
    UNION ALL
    SELECT 'Second', 'B'
    UNION ALL 
    SELECT 'Third', 'C'
), struct AS (
    SELECT
        STRUCT_PACK(
            CLass := CLASS,
            Section := SECTION
        ) AS final_struct
    FROM School
)

SELECT final_struct.Class AS field
FROM struct;




--Array of structs
SELECT [
    {Class : 'First',
    Section : ' A'},

    {Class : 'Second',
    Section : 'B'}
] AS array_of_structs;

--Using fucntions
WITH School AS (
    SELECT 'First' AS CLASS, 'A' as SECTION
    UNION ALL
    SELECT 'Second', 'B'
    UNION ALL 
    SELECT 'Third', 'C'
), array_of_struct AS (
    SELECT
        ARRAY_AGG(
            STRUCT_PACK(
                Class := CLASS,
                Section := SECTION
            ) 
            ORDER BY Class
        ) AS component
    FROM School
)

SELECT 
    component[1].Class
FROM 
    array_of_struct;



--Final Examples


--Arrays 
/*Build a falt skill table for coworkers to access job titles, 
salary info and skills in one table

Then  from prespective of a data analyst, analyze the
median salary per skill
*/
CREATE OR REPLACE TEMP TABLE flat_skill_table AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) as skills_array
FROM job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id
GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;
--We unnest the skills and then based on the unnested skills we 
--need to find the median salary per skill, case of CTE
WITH tempo AS(
    SELECT 
        job_id, 
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) as skills
    FROM flat_skill_table
)

SELECT 
    skills,
    MEDIAN(salary_year_avg) AS med_sal
FROM tempo
GROUP BY skills
ORDER BY med_sal DESC;



--Array of Struct
/*Build a falt skill-type table for coworkers to access job titles, 
salary info and skills in one table

Then  from prespective of a data analyst, analyze the
median salary per skill type
*/

CREATE OR REPLACE TEMP TABLE flat_skill_type_table AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_name := sd.skills,
            skill_type := sd.type
        )
    ) AS skill_type
FROM job_postings_fact as jpf
LEFT JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim as sd
    ON sjd.skill_id = sd.skill_id
GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;

WITH tempo AS(
    SELECT 
        job_id, 
        job_title_short,
        salary_year_avg,
        UNNEST(skill_type).skill_name AS skill_name,
        UNNEST(skill_type).skill_type AS skill_type
    FROM flat_skill_type_table
)

SELECT 
    skill_type,
    MEDIAN(salary_year_avg) AS med_sal
FROM tempo
GROUP BY skill_type
ORDER BY med_sal DESC;
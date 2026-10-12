--.read ./lessons/DMLpt1.sql

USE data_jobs; 

DROP DATABASE 
    IF EXISTS jobs_mart;

CREATE DATABASE 
    IF NOT EXISTS jobs_mart;

SHOW DATABASES;

-- DROP DATABASE                   --drops the database if does exist, if it doesnt, it skips over it
--     IF EXISTS jobs_mart;        --we need this database so I wont execute it

SELECT *
FROM 
    information_schema.schemata;


CREATE SCHEMA
    IF NOT EXISTS
    jobs_mart.staging;

-- DROP SCHEMA
--     IF EXISTS
--     jobs_mart.staging;

USE jobs_mart; --This query makes so that every query after this will affect only jobs_mart and no other data base unless switched again using USE

CREATE SCHEMA 
IF NOT EXISTS
staging;

CREATE TABLE IF NOT EXISTS
    staging.prefered_roles(
        role_id INTEGER PRIMARY KEY,
        role_name VARCHAR
    );

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';

SELECT *
FROM information_schema.key_column_usage
WHERE table_name = 'prefered_roles';

INSERT INTO staging.prefered_roles (role_id, role_name)
VALUES 
    (1, 'Data Engineer'),
    (2, 'Data Analyst'),
    (3, 'Data Scientist');

SELECT * 
FROM staging.prefered_roles;

ALTER TABLE staging.prefered_roles
ADD COLUMN prefered_role BOOLEAN;

SELECT *
FROM staging.prefered_roles;

ALTER TABLE staging.prefered_roles
    ALTER COLUMN prefered_role TYPE INTEGER;
ALTER TABLE staging.prefered_roles
    ALTER COLUMN prefered_role SET DEFAULT 0;

UPDATE staging.prefered_roles
SET prefered_role = 1
WHERE role_name = 'Data Engineer';

UPDATE staging.prefered_roles
SET prefered_role = 0
WHERE role_name <> 'Data Engineer';

ALTER TABLE staging.prefered_roles
RENAME COLUMN prefered_role TO priority_lvl;

ALTER TABLE staging.prefered_roles
RENAME TO priority_roles;

SELECT *
FROM staging.priority_roles;


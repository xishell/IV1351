-- ========================================================================
-- QUERY 4: Teachers Allocated to More Than N Courses in Current Period
-- ========================================================================
-- Description: List employee IDs and names of teachers allocated to more than
-- a specific number of course instances during the current period
--
-- Expected columns: Employment ID, Teacher's Name, Period, No of courses
--
-- Purpose: Identify teachers who are teaching many courses in a single period,
-- which may indicate workload imbalance. This is the most frequently run query
-- (20×/day) so performance is critical.
--
-- Usage: Adjust the HAVING clause threshold and WHERE period code as needed
-- ========================================================================

-- Version 1: Specific Period (e.g., P2)
-- Change 'P2' to desired period (P1, P2, P3, P4)
-- Change threshold (> 1) to desired minimum course count

SELECT
    e.employee_id AS "Employment ID",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",
    sp.code AS "Period",
    COUNT(DISTINCT ci.instance_id) AS "No of courses"
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
JOIN employee_course_instance eci ON e.employee_id = eci.employee_id
JOIN course_instance ci ON eci.instance_id = ci.instance_id
JOIN study_period sp ON ci.study_period = sp.code
WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)  -- Current year
    AND sp.code = 'P2'  -- Specify the period (P1, P2, P3, P4)
GROUP BY e.employee_id, p.first_name, p.last_name, sp.code
HAVING COUNT(DISTINCT ci.instance_id) > 1  -- Change this threshold as needed
ORDER BY "No of courses" DESC, p.last_name;


-- ========================================================================
-- ALTERNATIVE VERSION: All Periods
-- ========================================================================
-- This version shows results for all periods, not just one specific period.
-- Useful for getting a complete overview of teacher workloads across all periods.
-- ========================================================================

/*
SELECT
    e.employee_id AS "Employment ID",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",
    sp.code AS "Period",
    COUNT(DISTINCT ci.instance_id) AS "No of courses"
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
JOIN employee_course_instance eci ON e.employee_id = eci.employee_id
JOIN course_instance ci ON eci.instance_id = ci.instance_id
JOIN study_period sp ON ci.study_period = sp.code
WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY e.employee_id, p.first_name, p.last_name, sp.code
HAVING COUNT(DISTINCT ci.instance_id) > 1  -- Threshold for "high" course load
ORDER BY sp.code, "No of courses" DESC, p.last_name;
*/

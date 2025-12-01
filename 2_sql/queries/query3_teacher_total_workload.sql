-- ========================================================================
-- QUERY 3: Total Allocated Hours per Teacher (All Courses)
-- ========================================================================
-- Description: Calculate total allocated hours (with multiplication factors)
-- for each teacher across all their course instances in the current year
--
-- Expected columns: Course Code, Instance ID, HP, Period, Teacher's Name,
-- Lecture Hours, Tutorial Hours, Lab Hours, Seminar Hours, Other Overhead,
-- Admin, Exam, Total
--
-- Purpose: Shows the complete teaching load for each teacher, listing all
-- their courses and the hours allocated to each. Useful for workload balancing
-- and identifying overloaded teachers.
-- ========================================================================

SELECT
    cl.course_code AS "Course Code",
    ci.instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    sp.code AS "Period",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Lecture'), 0) AS "Lecture Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Tutorial'), 0) AS "Tutorial Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Lab'), 0) AS "Lab Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Seminar'), 0) AS "Seminar Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Project supervision'), 0) AS "Other Overhead Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Course administration'), 0) AS "Admin",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Exam grading'), 0) AS "Exam",
    COALESCE(SUM(pa.planned_hours * ta.factor), 0) AS "Total"
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
JOIN study_period sp ON ci.study_period = sp.code
JOIN employee_course_instance eci ON ci.instance_id = eci.instance_id
JOIN employee e ON eci.employee_id = e.employee_id
JOIN person p ON e.personal_number = p.personal_number
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id
    AND e.employee_id = pa.employee_id
LEFT JOIN teaching_activity ta ON pa.activity_name = ta.activity_name
WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)  -- Filter for current year
GROUP BY cl.course_code, ci.instance_id, cl.hp, sp.code, p.first_name, p.last_name, e.employee_id
ORDER BY p.last_name, p.first_name, cl.course_code;

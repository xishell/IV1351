-- ========================================================================
-- QUERY 2: Actual Allocated Hours per Teacher per Course Instance
-- ========================================================================
-- Description: Calculate total allocated hours (with multiplication factors)
-- with breakdown for each activity and each teacher for current year's courses
--
-- Expected columns: Course Code, Instance ID, HP, Teacher's Name, Designation,
-- Lecture Hours, Tutorial Hours, Lab Hours, Seminar Hours, Other Overhead,
-- Admin, Exam, Total
--
-- Purpose: Shows how many hours each individual teacher is allocated for
-- each course they're teaching. This is the most frequently run query (12×/day).
--
-- Note: This query can be significantly optimized using the materialized view
-- mv_teacher_workload_summary (see ../task2_views.sql)
-- ========================================================================

SELECT
    cl.course_code AS "Course Code",
    ci.instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    p.first_name || ' ' || p.last_name AS "Teacher's Name",
    e.job_title AS "Designation",
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
JOIN employee_course_instance eci ON ci.instance_id = eci.instance_id
JOIN employee e ON eci.employee_id = e.employee_id
JOIN person p ON e.personal_number = p.personal_number
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id
    AND e.employee_id = pa.employee_id  -- Links each teacher to their specific activities
LEFT JOIN teaching_activity ta ON pa.activity_name = ta.activity_name
WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)  -- Filter for current year
GROUP BY cl.course_code, ci.instance_id, cl.hp, p.first_name, p.last_name, e.job_title, e.employee_id
ORDER BY cl.course_code, ci.instance_id, p.last_name;

-- ========================================================================
-- QUERY 1: Planned Hours Calculations per Course Instance
-- ========================================================================
-- Description: Calculate total planned hours (with multiplication factors)
-- and breakdown for each activity for all current year's course instances
--
-- Expected columns: Course Code, Instance ID, HP, Period, # Students,
-- Lecture Hours, Tutorial Hours, Lab Hours, Seminar Hours, Other Overhead,
-- Admin, Exam, Total Hours
--
-- Purpose: Shows the total planned teaching load for each course offering,
-- summed across all teachers assigned to that course.
-- ========================================================================

SELECT
    cl.course_code AS "Course Code",
    ci.instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    sp.code AS "Period",
    ci.num_students AS "# Students",
    -- Sum across all teachers for this course instance
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Lecture'), 0) AS "Lecture Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Tutorial'), 0) AS "Tutorial Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Lab'), 0) AS "Lab Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Seminar'), 0) AS "Seminar Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Project supervision'), 0) AS "Other Overhead Hours",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Course administration'), 0) AS "Admin",
    COALESCE(SUM(pa.planned_hours * ta.factor) FILTER (WHERE ta.activity_name = 'Exam grading'), 0) AS "Exam",
    COALESCE(SUM(pa.planned_hours * ta.factor), 0) AS "Total Hours"
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
JOIN study_period sp ON ci.study_period = sp.code
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id
LEFT JOIN teaching_activity ta ON pa.activity_name = ta.activity_name
WHERE ci.study_year = EXTRACT(YEAR FROM CURRENT_DATE)  -- Filter for current year
GROUP BY cl.course_code, ci.instance_id, cl.hp, sp.code, ci.num_students
ORDER BY cl.course_code, ci.instance_id;

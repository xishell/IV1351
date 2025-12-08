-- ========================================================================
-- QUERY 3 (OPTIMIZED): Total Teacher Workload
-- ========================================================================
-- Description: Optimized version using materialized view mv_teacher_workload_summary
--
-- Frequency: 5×/day
-- ========================================================================

-- Query 3: Show complete workload for each teacher (all courses)
SELECT
    course_code AS "Course Code",
    instance_id AS "Course Instance ID",
    hp AS "HP",
    period_code AS "Period",
    teacher_name AS "Teacher's Name",
    lecture_hours AS "Lecture Hours",
    tutorial_hours AS "Tutorial Hours",
    lab_hours AS "Lab Hours",
    seminar_hours AS "Seminar Hours",
    other_overhead_hours AS "Other Overhead Hours",
    admin_hours AS "Admin",
    exam_hours AS "Exam",
    total_hours AS "Total"
FROM mv_teacher_workload_summary
WHERE study_year = EXTRACT(YEAR FROM CURRENT_DATE)
ORDER BY last_name, first_name, course_code;

-- ========================================================================
-- QUERY 2 (OPTIMIZED): Allocated Hours per Teacher per Course
-- ========================================================================
-- Description: Optimized version using materialized view mv_teacher_workload_summary
--
-- Frequency: 12×/day (second most frequent query)
-- ========================================================================

-- Query 2: Show allocated hours for each teacher for each course in current year
SELECT
    course_code AS "Course Code",
    instance_id AS "Course Instance ID",
    hp AS "HP",
    teacher_name AS "Teacher's Name",
    designation AS "Designation",
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
ORDER BY course_code, instance_id, last_name;

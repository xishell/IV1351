-- ========================================================================
-- QUERY 4 (OPTIMIZED): Teachers with High Course Load
-- ========================================================================
-- Description: Optimized version using materialized view mv_teacher_course_count
--
-- Frequency: 20×/day (HIGHEST frequency - optimization critical!)
-- ========================================================================

-- Query 4: Find teachers with more than N courses in a specific period
SELECT
    employee_id AS "Employment ID",
    teacher_name AS "Teacher's Name",
    period_code AS "Period",
    course_count AS "No of courses"
FROM mv_teacher_course_count
WHERE study_year = EXTRACT(YEAR FROM CURRENT_DATE)
    AND period_code = 'P2'  -- Change to P1, P2, P3, or P4 as needed
    AND course_count > 1    -- Change threshold as needed
ORDER BY course_count DESC, last_name;

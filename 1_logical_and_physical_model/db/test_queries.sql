-- Test Queries for University Database
-- These queries demonstrate various aspects of the schema

-- ============================================================================
-- BASIC QUERIES
-- ============================================================================

-- 1. List all employees with their personal information
SELECT
    e.employee_id,
    p.first_name,
    p.last_name,
    e.job_title,
    e.salary,
    e.department_name
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
ORDER BY e.salary DESC
LIMIT 10;

-- 2. Show all course layouts with their details
SELECT
    course_code,
    layout_version,
    course_name,
    min_students,
    max_students,
    hp
FROM course_layout
ORDER BY course_code;

-- 3. List all active course instances with their period and year
SELECT
    ci.instance_id,
    cl.course_name,
    ci.num_students,
    sp.factor AS period,
    ci.study_year
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
JOIN study_period sp ON ci.study_period = sp.code
ORDER BY ci.study_year DESC, ci.instance_id;

-- ============================================================================
-- TESTING COMPOSITE FOREIGN KEYS
-- ============================================================================

-- 4. Verify composite FK: course_instance -> course_layout
-- This should return all course instances with their matching layouts
SELECT
    ci.instance_id,
    ci.course_code,
    ci.layout_version,
    cl.course_name,
    ci.num_students,
    cl.min_students,
    cl.max_students,
    CASE
        WHEN ci.num_students < cl.min_students THEN 'Under capacity'
        WHEN ci.num_students > cl.max_students THEN 'Over capacity'
        ELSE 'Normal'
    END AS capacity_status
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version;

-- 5. Test composite PK in planned_activity
SELECT
    pa.instance_id,
    pa.activity_name,
    pa.planned_hours,
    ta.factor,
    (pa.planned_hours * ta.factor) AS weighted_hours
FROM planned_activity pa
JOIN teaching_activity ta ON pa.activity_name = ta.activity_name
ORDER BY pa.instance_id, pa.activity_name;

-- ============================================================================
-- AGGREGATION QUERIES
-- ============================================================================

-- 6. Count employees by department and job title
SELECT
    department_name,
    job_title,
    COUNT(*) as employee_count,
    AVG(salary)::INTEGER as avg_salary,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary
FROM employee
GROUP BY department_name, job_title
ORDER BY department_name, avg_salary DESC;

-- 7. Calculate total planned hours per course instance
SELECT
    ci.instance_id,
    cl.course_name,
    SUM(pa.planned_hours) as total_planned_hours,
    COUNT(pa.activity_name) as num_activities
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id
GROUP BY ci.instance_id, cl.course_name
ORDER BY total_planned_hours DESC;

-- 8. Employee workload: count courses per employee
SELECT
    e.employee_id,
    p.first_name,
    p.last_name,
    e.job_title,
    COUNT(eci.instance_id) as num_courses_teaching
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
LEFT JOIN employee_course_instance eci ON e.employee_id = eci.employee_id
GROUP BY e.employee_id, p.first_name, p.last_name, e.job_title
HAVING COUNT(eci.instance_id) > 0
ORDER BY num_courses_teaching DESC;

-- ============================================================================
-- COMPLEX JOINS
-- ============================================================================

-- 9. Show complete course instance details with assigned teachers
SELECT
    ci.instance_id,
    cl.course_name,
    ci.study_year,
    sp.factor as period,
    ci.num_students,
    p.first_name || ' ' || p.last_name as teacher_name,
    e.job_title
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
JOIN study_period sp ON ci.study_period = sp.code
JOIN employee_course_instance eci ON ci.instance_id = eci.instance_id
JOIN employee e ON eci.employee_id = e.employee_id
JOIN person p ON e.personal_number = p.personal_number
ORDER BY ci.instance_id, teacher_name;

-- 10. Teaching activities breakdown per course
SELECT
    ci.instance_id,
    cl.course_name,
    pa.activity_name,
    pa.planned_hours,
    ta.factor,
    (pa.planned_hours * ta.factor) as weighted_hours
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
JOIN planned_activity pa ON ci.instance_id = pa.instance_id
JOIN teaching_activity ta ON pa.activity_name = ta.activity_name
ORDER BY ci.instance_id, pa.planned_hours DESC;

-- ============================================================================
-- SELF-REFERENCING FK QUERIES
-- ============================================================================

-- 11. Employee hierarchy: Show employees and their managers
SELECT
    e.employee_id,
    p.first_name || ' ' || p.last_name as employee_name,
    e.job_title,
    e.department_name,
    CASE
        WHEN e.manager_id IS NULL THEN 'No manager'
        ELSE (SELECT p2.first_name || ' ' || p2.last_name
              FROM employee e2
              JOIN person p2 ON e2.personal_number = p2.personal_number
              WHERE e2.employee_id = e.manager_id)
    END as manager_name
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
ORDER BY e.department_name, e.job_title;

-- 12. Count direct reports per manager
SELECT
    m.employee_id as manager_id,
    p.first_name || ' ' || p.last_name as manager_name,
    m.job_title,
    COUNT(e.employee_id) as num_direct_reports
FROM employee m
JOIN person p ON m.personal_number = p.personal_number
JOIN employee e ON e.manager_id = m.employee_id
GROUP BY m.employee_id, p.first_name, p.last_name, m.job_title
ORDER BY num_direct_reports DESC;

-- ============================================================================
-- SUBQUERIES AND ANALYTICAL QUERIES
-- ============================================================================

-- 13. Find departments with above-average salaries
SELECT
    department_name,
    COUNT(*) as num_employees,
    AVG(salary)::INTEGER as avg_salary
FROM employee
GROUP BY department_name
HAVING AVG(salary) > (SELECT AVG(salary) FROM employee)
ORDER BY avg_salary DESC;

-- 14. Courses with most teaching hours planned
SELECT
    ci.instance_id,
    cl.course_name,
    cl.hp as credit_points,
    SUM(pa.planned_hours) as total_hours,
    (SUM(pa.planned_hours)::FLOAT / cl.hp) as hours_per_credit
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
JOIN planned_activity pa ON ci.instance_id = pa.instance_id
GROUP BY ci.instance_id, cl.course_name, cl.hp
ORDER BY total_hours DESC
LIMIT 10;

-- 15. Teacher period limits vs actual assignments
SELECT
    sp.code as period_code,
    sp.factor as period_name,
    tpl.max_courses,
    COUNT(DISTINCT eci.employee_id) as teachers_assigned,
    COUNT(DISTINCT eci.instance_id) as courses_offered,
    ROUND(COUNT(DISTINCT eci.instance_id)::NUMERIC /
          NULLIF(COUNT(DISTINCT eci.employee_id), 0), 2) as avg_courses_per_teacher
FROM study_period sp
LEFT JOIN teacher_period_limit tpl ON sp.code = tpl.period_code
LEFT JOIN course_instance ci ON sp.code = ci.study_period
LEFT JOIN employee_course_instance eci ON ci.instance_id = eci.instance_id
GROUP BY sp.code, sp.factor, tpl.max_courses
ORDER BY sp.code;

-- ============================================================================
-- DATA QUALITY CHECKS
-- ============================================================================

-- 16. Find courses with student count outside min/max limits
SELECT
    ci.instance_id,
    cl.course_name,
    ci.num_students,
    cl.min_students,
    cl.max_students,
    CASE
        WHEN ci.num_students < cl.min_students THEN 'UNDER MIN'
        WHEN ci.num_students > cl.max_students THEN 'OVER MAX'
    END as issue
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
WHERE ci.num_students < cl.min_students
   OR ci.num_students > cl.max_students;

-- 17. Check for employees without course assignments
SELECT
    e.employee_id,
    p.first_name || ' ' || p.last_name as employee_name,
    e.job_title,
    e.department_name
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
LEFT JOIN employee_course_instance eci ON e.employee_id = eci.employee_id
WHERE eci.instance_id IS NULL
  AND e.job_title IN ('Professor', 'Associate Professor', 'Assistant Professor',
                      'Senior Lecturer', 'Lecturer', 'Department Head')
ORDER BY e.job_title, employee_name;

-- 18. Courses without any planned activities
SELECT
    ci.instance_id,
    cl.course_name,
    ci.study_year,
    sp.factor as period
FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
    AND ci.layout_version = cl.layout_version
JOIN study_period sp ON ci.study_period = sp.code
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id
WHERE pa.instance_id IS NULL;

-- ============================================================================
-- STATISTICAL QUERIES
-- ============================================================================

-- 19. Salary distribution by job title
SELECT
    job_title,
    COUNT(*) as count,
    MIN(salary) as min_salary,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)::INTEGER as q1_salary,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)::INTEGER as median_salary,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary)::INTEGER as q3_salary,
    MAX(salary) as max_salary,
    AVG(salary)::INTEGER as avg_salary
FROM employee
GROUP BY job_title
ORDER BY avg_salary DESC;

-- 20. Course popularity trends by year
SELECT
    study_year,
    COUNT(DISTINCT instance_id) as num_courses,
    SUM(num_students) as total_students,
    ROUND(AVG(num_students), 1) as avg_students_per_course,
    COUNT(DISTINCT study_period) as periods_used
FROM course_instance
GROUP BY study_year
ORDER BY study_year DESC;

-- 21. All employees without course assignments (including non-teaching staff)
SELECT
    e.employee_id,
    p.first_name || ' ' || p.last_name as employee_name,
    e.job_title,
    e.department_name,
    e.salary
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
LEFT JOIN employee_course_instance eci ON e.employee_id = eci.employee_id
WHERE eci.instance_id IS NULL
ORDER BY e.job_title, employee_name;

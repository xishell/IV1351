-- ========================================================================
-- IV1351 Task 1: Course Layout and Teaching Load Database Schema
-- Version 2.0 - CORRECTED VERSION
-- ========================================================================
-- This schema implements all requirements from Task 1 including:
-- - Course layout versioning (when HP or other attributes change)
-- - Salary history tracking (when teacher salaries change)
-- - Max courses per period stored in database (not hardcoded)
-- - Full 3NF normalization
-- ========================================================================

-- Required for exclusion constraint on salary_history date ranges
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Drop existing tables (in reverse dependency order)
DROP TABLE IF EXISTS teacher_period_limit CASCADE;
DROP TABLE IF EXISTS employee_course_instance CASCADE;
DROP TABLE IF EXISTS planned_activity CASCADE;
DROP TABLE IF EXISTS teaching_activity CASCADE;
DROP TABLE IF EXISTS salary_history CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS job_title CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS course_instance CASCADE;
DROP TABLE IF EXISTS study_period CASCADE;
DROP TABLE IF EXISTS course_layout CASCADE;


-- ========================================================================
-- CORE COURSE TABLES
-- ========================================================================

-- Course layout with versioning
-- When any attribute changes (HP, min_students, max_students, name),
-- create a new version rather than updating
CREATE TABLE course_layout (
    course_code VARCHAR(6) NOT NULL,
    layout_version INT NOT NULL,
    course_name VARCHAR(50) NOT NULL,
    min_students INT NOT NULL CHECK (min_students > 0),
    max_students INT NOT NULL CHECK (max_students >= min_students),
    hp DECIMAL(3,1) NOT NULL CHECK (hp > 0),
    PRIMARY KEY (course_code, layout_version)
);

-- Academic periods
CREATE TABLE study_period (
    code VARCHAR(2) NOT NULL,
    description VARCHAR(50),  -- e.g., "Period 1", "Autumn Quarter"
    PRIMARY KEY (code)
);

-- Specific instances of courses in particular periods/years
CREATE TABLE course_instance (
    instance_id VARCHAR(9) NOT NULL,
    course_code VARCHAR(6) NOT NULL,
    layout_version INT NOT NULL,
    num_students INT NOT NULL CHECK (num_students >= 0),
    study_period VARCHAR(2) NOT NULL,
    study_year INT NOT NULL CHECK (study_year > 2000),
    PRIMARY KEY (instance_id),
    FOREIGN KEY (course_code, layout_version)
        REFERENCES course_layout(course_code, layout_version)
        ON DELETE CASCADE,
    FOREIGN KEY (study_period)
        REFERENCES study_period(code)
        ON DELETE CASCADE
);


-- ========================================================================
-- PERSONNEL TABLES
-- ========================================================================

-- Job titles (Professor, Lecturer, Teaching Assistant, etc.)
CREATE TABLE job_title (
    job_title VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (job_title)
);

-- Personal information (separate from employment)
CREATE TABLE person (
    personal_number VARCHAR(12) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(11) NOT NULL,
    address VARCHAR(100) NOT NULL,  -- Fixed typo: "adress" → "address"
    email VARCHAR(50),
    PRIMARY KEY (personal_number)
);

-- Departments (created before employees to allow FK, but manager added after)
CREATE TABLE department (
    department_name VARCHAR(50) NOT NULL UNIQUE,
    manager_id INT,  -- Nullable to avoid circular dependency
    PRIMARY KEY (department_name)
);

-- Employees (teachers and staff)
CREATE TABLE employee (
    employee_id INT NOT NULL UNIQUE,
    personal_number VARCHAR(12) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    skill_set VARCHAR(500),
    current_salary INT NOT NULL CHECK (current_salary > 0),  -- Current salary for convenience
    department_name VARCHAR(50),
    manager_id INT,
    PRIMARY KEY (employee_id),
    FOREIGN KEY (job_title)
        REFERENCES job_title(job_title)
        ON DELETE RESTRICT,  -- Don't delete job_title if employees have it
    FOREIGN KEY (department_name)
        REFERENCES department(department_name)
        ON DELETE SET NULL,
    FOREIGN KEY (personal_number)
        REFERENCES person(personal_number)
        ON DELETE CASCADE,
    FOREIGN KEY (manager_id)
        REFERENCES employee(employee_id)
        ON DELETE SET NULL
);

-- ========================================================================
-- CIRCULAR DEPENDENCY RESOLUTION: department <-> employee
-- ========================================================================
-- Problem: Departments have managers (employees), but employees belong to departments
-- Solution: DEFERRABLE INITIALLY DEFERRED constraint
--
-- This allows both department and manager to be inserted in a single transaction:
--   1. INSERT INTO department (department_name, manager_id=NULL)
--   2. INSERT INTO employee (..., department_name='X')
--   3. UPDATE department SET manager_id=Y WHERE department_name='X'
--   4. COMMIT -- constraint checked here, not at each step
--
-- Additional enforcement via trigger (see trg_department_manager_department):
--   - Ensures manager actually belongs to their own department
--   - Prevents manager from Marketing managing Engineering department
-- ========================================================================
ALTER TABLE department
    ADD CONSTRAINT fk_department_manager
    FOREIGN KEY (manager_id)
    REFERENCES employee(employee_id)
    ON DELETE SET NULL
    DEFERRABLE INITIALLY DEFERRED;

-- *** FIX 1: Salary History ***
-- Tracks salary changes over time for accurate historical cost calculations
-- Required by Task 1: "also a teacher's salary can change"
CREATE TABLE salary_history (
    employee_id INT NOT NULL,
    salary INT NOT NULL CHECK (salary > 0),
    valid_from DATE NOT NULL,
    valid_to DATE,  -- NULL means current/ongoing
    PRIMARY KEY (employee_id, valid_from),
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE CASCADE,
    CHECK (valid_to IS NULL OR valid_to > valid_from)
);

-- ========================================================================
-- TEMPORAL INTEGRITY CONSTRAINTS: Preventing overlapping salary periods
-- ========================================================================
-- Index for querying current salaries and historical lookups
CREATE INDEX idx_salary_history_employee_dates ON salary_history(employee_id, valid_from, valid_to);

-- Constraint 1: Each employee can have at most ONE current (open-ended) salary
-- (valid_to IS NULL means "current salary")
CREATE UNIQUE INDEX idx_salary_history_single_open_row
    ON salary_history(employee_id)
    WHERE valid_to IS NULL;

-- Constraint 2: EXCLUSION constraint prevents overlapping date ranges
-- Requires btree_gist extension (created at top of file)
-- This ensures an employee cannot have two different salaries for the same date
--
-- Example of what this PREVENTS:
--   Row 1: employee_id=1, valid_from=2024-01-01, valid_to=2024-06-30, salary=50000
--   Row 2: employee_id=1, valid_from=2024-06-01, valid_to=2024-12-31, salary=55000
--   Error: Date ranges overlap for June 2024 - which salary applies?
--
-- The && operator checks if date ranges overlap (intersect)
ALTER TABLE salary_history
    ADD CONSTRAINT salary_history_no_overlap
    EXCLUDE USING gist (
        employee_id WITH =,
        daterange(valid_from, COALESCE(valid_to, 'infinity'::date), '[]') WITH &&
    );


-- ========================================================================
-- TEACHING ACTIVITY TABLES
-- ========================================================================

-- *** FIX 2: Changed factor from INT to DECIMAL ***
-- Teaching activities with multiplication factors
-- Factor must be DECIMAL to support values like 2.4, 3.6, 1.8 from requirements
CREATE TABLE teaching_activity (
    activity_name VARCHAR(50) NOT NULL UNIQUE,
    factor DECIMAL(4,2) NOT NULL CHECK (factor > 0),  -- Was INT, now DECIMAL
    PRIMARY KEY (activity_name)
);

-- Planned hours for each teacher's activities in each course
CREATE TABLE planned_activity (
    instance_id VARCHAR(9) NOT NULL,
    employee_id INT NOT NULL,
    activity_name VARCHAR(50) NOT NULL,
    planned_hours INT NOT NULL CHECK (planned_hours >= 0),
    PRIMARY KEY (instance_id, employee_id, activity_name),
    FOREIGN KEY (instance_id)
        REFERENCES course_instance(instance_id)
        ON DELETE CASCADE,
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE CASCADE,
    FOREIGN KEY (activity_name)
        REFERENCES teaching_activity(activity_name)
        ON DELETE CASCADE
);

-- Tracks which employees are assigned to which course instances
CREATE TABLE employee_course_instance (
    instance_id VARCHAR(9) NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (instance_id, employee_id),
    FOREIGN KEY (instance_id)
        REFERENCES course_instance(instance_id)
        ON DELETE CASCADE,
    FOREIGN KEY (employee_id)
        REFERENCES employee(employee_id)
        ON DELETE CASCADE
);

-- ========================================================================
-- ADVANCED REFERENTIAL INTEGRITY: Composite FK Subset Constraint
-- ========================================================================
-- This constraint enforces the business rule:
--   "Planned hours can only be created for teachers assigned to the course"
--
-- Why both individual FKs AND composite FK are needed:
--   1. Individual FKs (instance_id, employee_id, activity_name) ensure
--      each component exists and form the composite primary key
--   2. Composite FK (instance_id, employee_id) ensures the COMBINATION
--      exists in employee_course_instance as a valid assignment
--
-- This prevents orphaned planned_activity records where a teacher has
-- planned hours for a course they're not assigned to. It's a subset
-- constraint pattern: the (instance_id, employee_id) pair in
-- planned_activity must be a subset of pairs in employee_course_instance.
--
-- Example of what this PREVENTS:
--   employee_course_instance: (employee_id=1, instance_id=100)
--   planned_activity: (employee_id=1, instance_id=200, ...) <- BLOCKED!
--   Error: FK violation - employee 1 not assigned to instance 200
-- ========================================================================
ALTER TABLE planned_activity
    ADD CONSTRAINT fk_planned_activity_assignment
    FOREIGN KEY (instance_id, employee_id)
    REFERENCES employee_course_instance(instance_id, employee_id)
    ON DELETE CASCADE;


-- ========================================================================
-- BUSINESS RULES TABLE
-- ========================================================================

-- Maximum courses a teacher can teach in each period
-- Stored in database per Task 1 requirement (not hardcoded)
CREATE TABLE teacher_period_limit (
    period_code VARCHAR(2) NOT NULL,
    max_courses INT NOT NULL CHECK (max_courses > 0),
    PRIMARY KEY (period_code),
    FOREIGN KEY (period_code)
        REFERENCES study_period(code)
        ON DELETE CASCADE
);


-- ========================================================================
-- INDEXES FOR PERFORMANCE
-- ========================================================================

-- Course instance lookups
CREATE INDEX idx_course_instance_course_code_layout_version
    ON course_instance(course_code, layout_version);
CREATE INDEX idx_course_instance_study_period
    ON course_instance(study_period);
CREATE INDEX idx_course_instance_study_year
    ON course_instance(study_year);
CREATE INDEX idx_course_instance_period_year
    ON course_instance(study_period, study_year);

-- Employee lookups
CREATE INDEX idx_employee_job_title
    ON employee(job_title);
CREATE INDEX idx_employee_department_name
    ON employee(department_name);
CREATE INDEX idx_employee_personal_number
    ON employee(personal_number);

-- Planned activity lookups (for Task 2 queries)
CREATE INDEX idx_planned_activity_instance_id
    ON planned_activity(instance_id);
CREATE INDEX idx_planned_activity_employee_id
    ON planned_activity(employee_id);
CREATE INDEX idx_planned_activity_activity_name
    ON planned_activity(activity_name);

-- Employee-course assignments
CREATE INDEX idx_employee_course_instance_instance_id
    ON employee_course_instance(instance_id);
CREATE INDEX idx_employee_course_instance_employee_id
    ON employee_course_instance(employee_id);

-- Period limits
CREATE INDEX idx_teacher_period_limit_period_code
    ON teacher_period_limit(period_code);


-- ========================================================================
-- DATA-INTEGRITY TRIGGERS
-- ========================================================================

-- Enforce that a department's manager belongs to that department
CREATE OR REPLACE FUNCTION enforce_manager_department_match()
RETURNS TRIGGER AS $$
DECLARE
    mgr_department VARCHAR(50);
BEGIN
    IF NEW.manager_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT department_name INTO mgr_department
    FROM employee
    WHERE employee_id = NEW.manager_id;

    IF mgr_department IS NULL THEN
        RAISE EXCEPTION 'Manager % does not exist', NEW.manager_id;
    END IF;

    IF mgr_department IS DISTINCT FROM NEW.department_name THEN
        RAISE EXCEPTION 'Manager % must belong to department %', NEW.manager_id, NEW.department_name;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_department_manager_department
AFTER INSERT OR UPDATE ON department
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE FUNCTION enforce_manager_department_match();

-- Prevent updating current_salary directly; salary_history is the source of truth
CREATE OR REPLACE FUNCTION prevent_direct_current_salary_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.current_salary IS DISTINCT FROM OLD.current_salary THEN
        RAISE EXCEPTION 'Update salary_history instead of employee.current_salary';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_employee_current_salary_guard
BEFORE UPDATE OF current_salary ON employee
FOR EACH ROW
EXECUTE FUNCTION prevent_direct_current_salary_update();

-- Keep employee.current_salary in sync with salary_history
CREATE OR REPLACE FUNCTION refresh_employee_current_salary(p_employee_id INT)
RETURNS VOID AS $$
BEGIN
    UPDATE employee e
    SET current_salary = latest.salary
    FROM (
        SELECT sh.employee_id, sh.salary
        FROM salary_history sh
        WHERE sh.employee_id = p_employee_id
        ORDER BY (sh.valid_to IS NULL) DESC, sh.valid_from DESC
        LIMIT 1
    ) AS latest
    WHERE e.employee_id = latest.employee_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No salary history exists for employee %', p_employee_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_salary_history_sync()
RETURNS TRIGGER AS $$
DECLARE
    target_employee INT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        target_employee = OLD.employee_id;
    ELSE
        target_employee = NEW.employee_id;
    END IF;

    PERFORM refresh_employee_current_salary(target_employee);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_salary_history_sync_aiud
AFTER INSERT OR UPDATE OR DELETE ON salary_history
FOR EACH ROW
EXECUTE FUNCTION trg_salary_history_sync();


-- ========================================================================
-- HELPFUL VIEWS 
-- ========================================================================

-- View to get current salary for each employee
CREATE VIEW v_employee_current_salary AS
WITH latest AS (
    SELECT DISTINCT ON (sh.employee_id)
        sh.employee_id,
        sh.salary,
        sh.valid_from
    FROM salary_history sh
    ORDER BY sh.employee_id, (sh.valid_to IS NULL) DESC, sh.valid_from DESC
)
SELECT
    e.employee_id,
    e.personal_number,
    p.first_name || ' ' || p.last_name AS full_name,
    e.job_title,
    e.department_name,
    latest.salary AS salary,
    latest.valid_from AS salary_effective_date
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
LEFT JOIN latest ON e.employee_id = latest.employee_id;

-- View to get salary at a specific date
CREATE VIEW v_employee_salary_at_date AS
SELECT
    e.employee_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sh.salary,
    sh.valid_from,
    sh.valid_to,
    daterange(sh.valid_from, COALESCE(sh.valid_to, 'infinity'::date), '[]') AS validity_range
FROM employee e
JOIN person p ON e.personal_number = p.personal_number
JOIN salary_history sh ON e.employee_id = sh.employee_id;


-- ========================================================================
-- COMMENTS ON TABLES
-- ========================================================================

COMMENT ON TABLE course_layout IS 'Course definitions with versioning. Create new version when HP or other attributes change.';
COMMENT ON TABLE course_instance IS 'Specific offerings of courses in particular periods/years.';
COMMENT ON TABLE salary_history IS 'Tracks salary changes over time for accurate historical cost calculations.';
COMMENT ON TABLE teaching_activity IS 'Activity types (Lecture, Lab, etc.) with multiplication factors for workload calculation.';
COMMENT ON TABLE planned_activity IS 'Hours allocated to each teacher for each activity in each course instance.';
COMMENT ON TABLE teacher_period_limit IS 'Maximum courses per period (stored in DB per Task 1 requirement).';
COMMENT ON COLUMN teaching_activity.factor IS 'Multiplication factor applied to planned hours (e.g., 2.4 for Labs, 3.6 for Lectures).';
COMMENT ON COLUMN salary_history.valid_to IS 'NULL indicates current/ongoing salary. Otherwise, last date this salary was valid.';

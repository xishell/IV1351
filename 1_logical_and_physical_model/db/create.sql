-- Database schema generated from draw.io diagram
-- Generated automatically - review before executing

-- Drop existing tables (in reverse dependency order)
DROP TABLE IF EXISTS teacher_period_limit CASCADE;
DROP TABLE IF EXISTS employee_course_instance CASCADE;
DROP TABLE IF EXISTS planned_activity CASCADE;
DROP TABLE IF EXISTS teaching_activity CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS job_title CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS course_instance CASCADE;
DROP TABLE IF EXISTS study_period CASCADE;
DROP TABLE IF EXISTS course_layout CASCADE;

CREATE TABLE course_layout (
    course_code VARCHAR(6) NOT NULL,
    layout_version INT NOT NULL,
    course_name VARCHAR(50),
    min_students INT NOT NULL,
    max_students INT NOT NULL,
    hp DECIMAL(3,1) NOT NULL
,
    PRIMARY KEY (course_code, layout_version)

);

CREATE TABLE study_period (
    code VARCHAR(2) NOT NULL  UNIQUE,
    factor VARCHAR(50)
,
    PRIMARY KEY (code)

);

CREATE TABLE course_instance (
    instance_id VARCHAR(9) NOT NULL  UNIQUE,
    course_code VARCHAR(6) NOT NULL,
    layout_version INT NOT NULL,
    num_students INT NOT NULL,
    study_period VARCHAR(2) NOT NULL,
    study_year INT NOT NULL
,
    PRIMARY KEY (instance_id)
,
    FOREIGN KEY (course_code, layout_version) REFERENCES course_layout(course_code, layout_version) ON DELETE CASCADE
,
    FOREIGN KEY (study_period) REFERENCES study_period(code) ON DELETE CASCADE

);

CREATE TABLE department (
    department_name VARCHAR(50) NOT NULL  UNIQUE,
    manager_id INT NOT NULL
,
    PRIMARY KEY (department_name)
,
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id) ON DELETE RESTRICT

);

CREATE TABLE job_title (
    job_title VARCHAR (50) NOT NULL  UNIQUE
,
    PRIMARY KEY (job_title)

);

CREATE TABLE person (
    personal_number VARCHAR(12) NOT NULL  UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(11) NOT NULL,
    adress VARCHAR(100) NOT NULL,
    email VARCHAR(50)
,
    PRIMARY KEY (personal_number)

);

CREATE TABLE employee (
    employee_id INT NOT NULL  UNIQUE,
    personal_number VARCHAR(12) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    skill_set VARCHAR(500) NULL,
    salary INT NOT NULL,
    department_name VARCHAR(50),
    manager_id INT NULL
,
    PRIMARY KEY (employee_id)
,
    FOREIGN KEY (job_title) REFERENCES job_title(job_title) ON DELETE SET NULL
,
    FOREIGN KEY (department_name) REFERENCES department(department_name) ON DELETE SET NULL
,
    FOREIGN KEY (personal_number) REFERENCES person(personal_number) ON DELETE CASCADE
,
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id) ON DELETE SET NULL
);

CREATE TABLE teaching_activity (
    activity_name VARCHAR(50) NOT NULL  UNIQUE,
    factor INT NOT NULL
,
    PRIMARY KEY (activity_name)

);

CREATE TABLE planned_activity (
    instance_id VARCHAR(9) NOT NULL,
    activity_name VARCHAR (50) NOT NULL,
    planned_hours INT NOT NULL
,
    PRIMARY KEY (instance_id, activity_name)
,
    FOREIGN KEY (instance_id) REFERENCES course_instance(instance_id) ON DELETE CASCADE
,
    FOREIGN KEY (activity_name) REFERENCES teaching_activity(activity_name) ON DELETE CASCADE

);

CREATE TABLE employee_course_instance (
    instance_id VARCHAR(9) NOT NULL,
    employee_id INT NOT NULL
,
    PRIMARY KEY (instance_id, employee_id)
,
    FOREIGN KEY (instance_id) REFERENCES course_instance(instance_id) ON DELETE CASCADE
,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE

);

CREATE TABLE teacher_period_limit (
    period_code VARCHAR(2) NOT NULL,
    max_courses INT NOT NULL
,
    PRIMARY KEY (period_code)
,
    FOREIGN KEY (period_code) REFERENCES study_period(code) ON DELETE CASCADE

);

-- Indexes for foreign key columns
CREATE INDEX idx_course_instance_course_code_layout_version ON course_instance(course_code, layout_version);
CREATE INDEX idx_course_instance_study_period ON course_instance(study_period);
CREATE INDEX idx_employee_job_title ON employee(job_title);
CREATE INDEX idx_employee_department_name ON employee(department_name);
CREATE INDEX idx_employee_personal_number ON employee(personal_number);
CREATE INDEX idx_planned_activity_instance_id ON planned_activity(instance_id);
CREATE INDEX idx_planned_activity_activity_name ON planned_activity(activity_name);
CREATE INDEX idx_employee_course_instance_instance_id ON employee_course_instance(instance_id);
CREATE INDEX idx_employee_course_instance_employee_id ON employee_course_instance(employee_id);
CREATE INDEX idx_teacher_period_limit_period_code ON teacher_period_limit(period_code);

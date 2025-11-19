-- Database schema generated from draw.io diagram
-- Generated automatically - review before executing

-- Drop existing tables (in reverse dependency order)
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
    course_code VARCHAR(6) NOT NULL  UNIQUE,
    course_name VARCHAR(50),
    min_students INT NOT NULL,
    max_students INT NOT NULL,
    hp INT NOT NULL
,
    PRIMARY KEY (course_code)

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
    num_students INT NOT NULL,
    study_period VARCHAR(2) NOT NULL,
    study_year INT NOT NULL,
    course_layout_id VARCHAR(6)
,
    PRIMARY KEY (instance_id)
,
    FOREIGN KEY (study_period) REFERENCES study_period(code) ON DELETE CASCADE
,
    FOREIGN KEY (course_layout_id) REFERENCES course_layout(course_code) ON DELETE CASCADE

);

CREATE TABLE department (
    department_name VARCHAR(50) NOT NULL  UNIQUE,
    manager_id VARCHAR(12) NOT NULL
,
    PRIMARY KEY (department_name)

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
    manager VARCHAR(12) NOT NULL,
    person_id VARCHAR(12),
    department_id VARCHAR(50)
,
    PRIMARY KEY (employee_id)
,
    FOREIGN KEY (job_title) REFERENCES job_title(job_title) ON DELETE CASCADE
,
    FOREIGN KEY (department_id) REFERENCES department(department_name) ON DELETE CASCADE
,
    FOREIGN KEY (person_id) REFERENCES person(personal_number) ON DELETE CASCADE

);

CREATE TABLE teaching_activity (
    activity_name VARCHAR(50) NOT NULL  UNIQUE,
    factor INT NOT NULL
,
    PRIMARY KEY (activity_name)

);

CREATE TABLE planned_activity (
    instance_id INT NOT NULL,
    activity_name VARCHAR (50) NOT NULL,
    planned_hours INT NOT NULL,
    teaching_activity_id VARCHAR(50),
    course_instance_id VARCHAR(9)
,
    PRIMARY KEY (instance_id)
,
    FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity(activity_name) ON DELETE CASCADE
,
    FOREIGN KEY (course_instance_id) REFERENCES course_instance(instance_id) ON DELETE CASCADE

);

CREATE TABLE employee_course_instance (
    instance_id INT NOT NULL,
    employee_id INT NOT NULL,
    course_instance_id VARCHAR(9)
,
    PRIMARY KEY (instance_id, employee_id)
,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE
,
    FOREIGN KEY (course_instance_id) REFERENCES course_instance(instance_id) ON DELETE CASCADE

);

-- Indexes for foreign key columns
CREATE INDEX idx_course_instance_study_period ON course_instance(study_period);
CREATE INDEX idx_course_instance_course_layout_id ON course_instance(course_layout_id);
CREATE INDEX idx_employee_job_title ON employee(job_title);
CREATE INDEX idx_employee_department_id ON employee(department_id);
CREATE INDEX idx_employee_person_id ON employee(person_id);
CREATE INDEX idx_planned_activity_teaching_activity_id ON planned_activity(teaching_activity_id);
CREATE INDEX idx_planned_activity_course_instance_id ON planned_activity(course_instance_id);
CREATE INDEX idx_employee_course_instance_employee_id ON employee_course_instance(employee_id);
CREATE INDEX idx_employee_course_instance_course_instance_id ON employee_course_instance(course_instance_id);
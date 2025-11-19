-- Database schema generated from draw.io diagram
-- Generated automatically - review before executing

CREATE TABLE course_layout (
    course_code VARCHAR(6) NOT NULL,
    course_name VARCHAR(50),
    min_students INT NOT NULL,
    max_students INT NOT NULL,
    hp INT NOT NULL
,
    PRIMARY KEY (course_code)

);

CREATE TABLE study_period (
    code VARCHAR(2) NOT NULL,
    factor VARCHAR(50)
,
    PRIMARY KEY (code)

);

CREATE TABLE course_instance (
    instance_id VARCHAR(9) NOT NULL,
    course_code VARCHAR(6) NOT NULL,
    num_students INT NOT NULL,
    study_period VARCHAR(2) NOT NULL,
    study_year INT NOT NULL,
    course_layout_id VARCHAR(6)
,
    PRIMARY KEY (instance_id)
,
    FOREIGN KEY (study_period) REFERENCES study_period(code)
,
    FOREIGN KEY (course_layout_id) REFERENCES course_layout(course_code)

);

CREATE TABLE department (
    department_name VARCHAR(50) NOT NULL,
    manager_id VARCHAR NOT NULL
,
    PRIMARY KEY (department_name)

);

CREATE TABLE job_title (
    job_title VARCHAR (50) NOT NULL
,
    PRIMARY KEY (job_title)

);

CREATE TABLE person (
    personal_number INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(11) NOT NULL,
    adress VARCHAR(100) NOT NULL,
    email VARCHAR(50)
,
    PRIMARY KEY (personal_number)

);

CREATE TABLE employee (
    employee_id INT NOT NULL,
    personal_number INT NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    skill_set VARCHAR(500) NULL,
    salary INT NOT NULL,
    department_name VARCHAR(50),
    manager BOOLEAN NOT NULL,
    person_id INT,
    department_id VARCHAR(50)
,
    PRIMARY KEY (employee_id)
,
    FOREIGN KEY (job_title) REFERENCES job_title(job_title)
,
    FOREIGN KEY (department_id) REFERENCES department(department_name)
,
    FOREIGN KEY (person_id) REFERENCES person(personal_number)

);

CREATE TABLE teaching_activity (
    activity_name VARCHAR(50) NOT NULL,
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
    FOREIGN KEY (teaching_activity_id) REFERENCES teaching_activity(activity_name)
,
    FOREIGN KEY (course_instance_id) REFERENCES course_instance(instance_id)

);

CREATE TABLE employee_course_instance (
    instance_id INT NOT NULL,
    employee_id INT NOT NULL,
    course_instance_id VARCHAR(9)
,
    PRIMARY KEY (instance_id, employee_id)
,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
,
    FOREIGN KEY (course_instance_id) REFERENCES course_instance(instance_id)

);

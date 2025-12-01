-- ========================================================================
-- IV1351 Task 1: Sample Data for Course Layout Database (Version 2)
-- ========================================================================
-- This file populates the database with sample data for testing
-- Updated to match v2 schema requirements:
-- - study_period.description instead of study_period.factor
-- - teaching_activity.factor as DECIMAL instead of INT
-- - person.address instead of person.adress
-- - employee.current_salary instead of employee.salary
-- - Added salary_history table data
-- - Added more 2025 course instances for Task 2 queries
-- ========================================================================

BEGIN;

-- ========================================================================
-- REFERENCE DATA
-- ========================================================================

-- Study periods (8 rows)
INSERT INTO study_period (code, description) VALUES
('P1', 'Period 1'),
('P2', 'Period 2'),
('P3', 'Period 3'),
('P4', 'Period 4'),
('H1', 'Autumn Term First Half'),
('H2', 'Autumn Term Second Half'),
('HT', 'Autumn Term'),
('VT', 'Spring Term');

-- Job titles (6 rows)
INSERT INTO job_title (job_title) VALUES
('Professor'),
('Associate Professor'),
('Assistant Professor'),
('Lecturer'),
('Senior Lecturer'),
('Teaching Assistant');

-- Departments (5 rows)
INSERT INTO department (department_name, manager_id) VALUES
('Computer Science', NULL),  -- Will set manager_id after employees are created
('Mathematics', NULL),
('Physics', NULL),
('Engineering', NULL),
('Information Systems', NULL);

-- Person data (30 rows) - Fixed typo: adress → address
INSERT INTO person (personal_number, first_name, last_name, phone_number, address, email) VALUES
('197001011234', 'Alice', 'Anderson', '0701234567', '123 Main St, Stockholm', 'alice.anderson@university.se'),
('198002022345', 'Bob', 'Brown', '0702345678', '456 Oak Ave, Gothenburg', 'bob.brown@university.se'),
('197503033456', 'Carol', 'Clark', '0703456789', '789 Pine Rd, Malmo', 'carol.clark@university.se'),
('196504044567', 'David', 'Davis', '0704567890', '321 Elm St, Uppsala', 'david.davis@university.se'),
('199005055678', 'Emma', 'Evans', '0705678901', '654 Birch Ln, Linkoping', 'emma.evans@university.se'),
('198506066789', 'Frank', 'Foster', '0706789012', '987 Cedar Dr, Orebro', 'frank.foster@university.se'),
('197007077890', 'Grace', 'Green', '0707890123', '147 Maple Ct, Vasteras', 'grace.green@university.se'),
('198808088901', 'Henry', 'Harris', '0708901234', '258 Spruce Way, Norrkoping', 'henry.harris@university.se'),
('197509099012', 'Iris', 'Ingram', '0709012345', '369 Ash Blvd, Helsingborg', 'iris.ingram@university.se'),
('196010101123', 'Jack', 'Jackson', '0700123456', '741 Willow Pl, Jonkoping', 'jack.jackson@university.se'),
('199011111234', 'Karen', 'King', '0701234560', '852 Poplar St, Umea', 'karen.king@university.se'),
('198512121345', 'Leo', 'Lewis', '0702345601', '963 Beech Ave, Lund', 'leo.lewis@university.se'),
('197013131456', 'Maria', 'Martin', '0703456012', '159 Fir Rd, Boras', 'maria.martin@university.se'),
('198814141567', 'Nathan', 'Nelson', '0704560123', '357 Redwood Dr, Sodertalje', 'nathan.nelson@university.se'),
('197515151678', 'Olivia', 'Olson', '0705601234', '486 Hickory Ln, Eskilstuna', 'olivia.olson@university.se'),
('196516161789', 'Peter', 'Parker', '0706012345', '591 Sycamore Ct, Karlstad', 'peter.parker@university.se'),
('199017171890', 'Quinn', 'Quinn', '0707123450', '624 Magnolia Way, Vaxjo', 'quinn.quinn@university.se'),
('198518181901', 'Rachel', 'Roberts', '0708234501', '735 Dogwood Blvd, Gavle', 'rachel.roberts@university.se'),
('197019192012', 'Steve', 'Smith', '0709345012', '846 Chestnut Pl, Sundsvall', 'steve.smith@university.se'),
('198820202123', 'Tina', 'Taylor', '0700456123', '957 Walnut St, Halmstad', 'tina.taylor@university.se'),
('197521212234', 'Uma', 'Underwood', '0701567234', '168 Cherry Ave, Boden', 'uma.underwood@university.se'),
('196022222345', 'Victor', 'Vance', '0702678345', '279 Plum Rd, Kristianstad', 'victor.vance@university.se'),
('199023232456', 'Wendy', 'White', '0703789456', '380 Peach Dr, Karlskrona', 'wendy.white@university.se'),
('198524242567', 'Xavier', 'Xavier', '0704890567', '481 Pear Ln, Falun', 'xavier.xavier@university.se'),
('197025252678', 'Yara', 'Young', '0705901678', '582 Apple Ct, Skelleftea', 'yara.young@university.se'),
('198826262789', 'Zack', 'Zimmerman', '0706012789', '683 Grape Way, Kalmar', 'zack.zimmerman@university.se'),
('197527272890', 'Amy', 'Adams', '0707123890', '784 Orange Blvd, Trollhattan', 'amy.adams@university.se'),
('196528282901', 'Brian', 'Baker', '0708234901', '885 Lemon Pl, Lidkoping', 'brian.baker@university.se'),
('199029293012', 'Chloe', 'Carter', '0709345012', '986 Lime St, Ludvika', 'chloe.carter@university.se'),
('198530303123', 'Daniel', 'Daniels', '0700456123', '187 Mango Ave, Enkoping', 'daniel.daniels@university.se');

-- Employees (30 rows) - Changed salary → current_salary
INSERT INTO employee (employee_id, personal_number, job_title, skill_set, current_salary, department_name, manager_id) VALUES
(1, '197001011234', 'Professor', 'Algorithms, Data Structures', 75000, 'Computer Science', NULL),
(2, '198002022345', 'Associate Professor', 'Machine Learning, AI', 65000, 'Computer Science', 1),
(3, '197503033456', 'Assistant Professor', 'Database Systems', 55000, 'Computer Science', 1),
(4, '196504044567', 'Lecturer', 'Programming, Java', 48000, 'Computer Science', 1),
(5, '199005055678', 'Teaching Assistant', 'Lab Supervision', 35000, 'Computer Science', 4),
(6, '198506066789', 'Senior Lecturer', 'Software Engineering', 52000, 'Computer Science', 1),
(7, '197007077890', 'Professor', 'Calculus, Linear Algebra', 74000, 'Mathematics', NULL),
(8, '198808088901', 'Associate Professor', 'Statistics', 64000, 'Mathematics', 7),
(9, '197509099012', 'Lecturer', 'Discrete Mathematics', 47000, 'Mathematics', 7),
(10, '196010101123', 'Teaching Assistant', 'Tutorial Sessions', 34000, 'Mathematics', 9),
(11, '199011111234', 'Professor', 'Quantum Mechanics', 76000, 'Physics', NULL),
(12, '198512121345', 'Associate Professor', 'Thermodynamics', 66000, 'Physics', 11),
(13, '197013131456', 'Lecturer', 'Classical Mechanics', 49000, 'Physics', 11),
(14, '198814141567', 'Teaching Assistant', 'Lab Experiments', 36000, 'Physics', 13),
(15, '197515151678', 'Professor', 'Structural Engineering', 77000, 'Engineering', NULL),
(16, '196516161789', 'Associate Professor', 'Electrical Engineering', 67000, 'Engineering', 15),
(17, '199017171890', 'Assistant Professor', 'Mechanical Engineering', 56000, 'Engineering', 15),
(18, '198518181901', 'Lecturer', 'Civil Engineering', 50000, 'Engineering', 15),
(19, '197019192012', 'Teaching Assistant', 'CAD Software', 37000, 'Engineering', 18),
(20, '198820202123', 'Professor', 'Information Systems', 78000, 'Information Systems', NULL),
(21, '197521212234', 'Associate Professor', 'Business Intelligence', 68000, 'Information Systems', 20),
(22, '196022222345', 'Lecturer', 'Enterprise Architecture', 51000, 'Information Systems', 20),
(23, '199023232456', 'Teaching Assistant', 'SQL, NoSQL', 38000, 'Information Systems', 22),
(24, '198524242567', 'Senior Lecturer', 'Web Development', 53000, 'Computer Science', 1),
(25, '197025252678', 'Senior Lecturer', 'Network Security', 54000, 'Computer Science', 1),
(26, '198826262789', 'Assistant Professor', 'Operating Systems', 57000, 'Computer Science', 1),
(27, '197527272890', 'Lecturer', 'Mobile Development', 46000, 'Computer Science', 1),
(28, '196528282901', 'Senior Lecturer', 'Cloud Computing', 58000, 'Computer Science', 1),
(29, '199029293012', 'Teaching Assistant', 'Python, JavaScript', 33000, 'Computer Science', 4),
(30, '198530303123', 'Lecturer', 'DevOps', 45000, 'Computer Science', 1);

-- Update department managers now that employees exist
UPDATE department SET manager_id = 1 WHERE department_name = 'Computer Science';
UPDATE department SET manager_id = 7 WHERE department_name = 'Mathematics';
UPDATE department SET manager_id = 11 WHERE department_name = 'Physics';
UPDATE department SET manager_id = 15 WHERE department_name = 'Engineering';
UPDATE department SET manager_id = 20 WHERE department_name = 'Information Systems';

-- *** NEW: Salary History (60+ rows) ***
-- Initial salaries for all employees (from 2024-01-01)
INSERT INTO salary_history (employee_id, salary, valid_from, valid_to) VALUES
-- Employees who have had no salary changes (valid_to = NULL)
(1, 75000, '2024-01-01', NULL),
(3, 55000, '2024-01-01', NULL),
(5, 35000, '2024-01-01', NULL),
(6, 52000, '2024-01-01', NULL),
(7, 74000, '2024-01-01', NULL),
(9, 47000, '2024-01-01', NULL),
(10, 34000, '2024-01-01', NULL),
(11, 76000, '2024-01-01', NULL),
(13, 49000, '2024-01-01', NULL),
(15, 77000, '2024-01-01', NULL),
(16, 67000, '2024-01-01', NULL),
(17, 56000, '2024-01-01', NULL),
(18, 50000, '2024-01-01', NULL),
(19, 37000, '2024-01-01', NULL),
(20, 78000, '2024-01-01', NULL),
(21, 68000, '2024-01-01', NULL),
(22, 51000, '2024-01-01', NULL),
(23, 38000, '2024-01-01', NULL),
(24, 53000, '2024-01-01', NULL),
(25, 54000, '2024-01-01', NULL),
(26, 57000, '2024-01-01', NULL),
(27, 46000, '2024-01-01', NULL),
(30, 45000, '2024-01-01', NULL),

-- Employee 2: Got a raise on 2024-07-01
(2, 62000, '2024-01-01', '2024-06-30'),
(2, 65000, '2024-07-01', NULL),

-- Employee 4: Two salary increases
(4, 44000, '2024-01-01', '2024-03-31'),
(4, 46000, '2024-04-01', '2024-09-30'),
(4, 48000, '2024-10-01', NULL),

-- Employee 8: Got a raise on 2024-06-01
(8, 61000, '2024-01-01', '2024-05-31'),
(8, 64000, '2024-06-01', NULL),

-- Employee 12: Got a raise on 2024-08-01
(12, 63000, '2024-01-01', '2024-07-31'),
(12, 66000, '2024-08-01', NULL),

-- Employee 14: Two salary increases (teaching assistant promoted)
(14, 32000, '2024-01-01', '2024-05-31'),
(14, 34000, '2024-06-01', '2024-10-31'),
(14, 36000, '2024-11-01', NULL),

-- Employee 28: Got a raise on 2024-09-01
(28, 55000, '2024-01-01', '2024-08-31'),
(28, 58000, '2024-09-01', NULL),

-- Employee 29: Got a raise on 2024-05-01
(29, 31000, '2024-01-01', '2024-04-30'),
(29, 33000, '2024-05-01', NULL);

-- Teaching activities (10 rows) - Fixed: factor now DECIMAL with correct values from requirements
INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 3.6),           -- From requirements Table 2
('Lab', 2.4),               -- From requirements Table 2
('Tutorial', 2.4),          -- From requirements Table 2
('Seminar', 1.8),           -- From requirements Table 2
('Course administration', 1.0),
('Project supervision', 1.0),
('Exam grading', 1.0),
('Office hours', 1.0),
('Thesis supervision', 1.0),
('Workshop', 2.0);

-- ========================================================================
-- COURSE DATA
-- ========================================================================

-- Course layouts (15 rows)
INSERT INTO course_layout (course_code, layout_version, course_name, min_students, max_students, hp) VALUES
('CS338', 1, 'Basic Programming', 25, 80, 7.5),
('CS381', 1, 'Object-Oriented Design', 20, 60, 7.5),
('CS559', 1, 'Database Technology', 15, 50, 7.5),
('CS658', 1, 'Data Structures and Algorithms', 20, 70, 7.5),
('CS754', 1, 'Software Engineering', 15, 40, 7.5),
('CS818', 1, 'Operating Systems', 10, 35, 7.5),
('CS854', 1, 'Machine Learning', 10, 30, 7.5),
('CS990', 1, 'Distributed Systems', 8, 25, 7.5),
('CS559', 2, 'Advanced Database Systems', 15, 50, 15.0),  -- HP changed: 7.5 → 15.0
('CS658', 2, 'Advanced Algorithms', 20, 70, 15.0),        -- HP changed: 7.5 → 15.0
('CS754', 3, 'Agile Software Engineering', 20, 50, 7.5),  -- Name and min students changed
('CS990', 2, 'Cloud and Distributed Systems', 10, 30, 7.5), -- Name and max students changed
('CS338', 2, 'Programming Fundamentals', 30, 100, 7.5),   -- Name and capacity changed
('CS381', 2, 'Advanced OOP', 15, 50, 7.5),                -- Name and capacity changed
('CS818', 2, 'Modern Operating Systems', 15, 45, 7.5);    -- Name and capacity changed

-- Course instances (50+ rows - added many 2025 instances for Task 2)
INSERT INTO course_instance (instance_id, course_code, layout_version, num_students, study_period, study_year) VALUES
-- Historical data (2020-2024)
('CS559P322', 'CS559', 1, 42, 'P3', 2022),
('CS990HT21', 'CS990', 1, 18, 'HT', 2021),
('CS658H123', 'CS658', 1, 58, 'H1', 2023),
('CS818VT20', 'CS818', 1, 28, 'VT', 2020),
('CS658P222', 'CS658', 1, 64, 'P2', 2022),
('CS990P424', 'CS990', 1, 21, 'P4', 2024),
('CS754P225', 'CS754', 1, 35, 'P2', 2025),  -- 2025 instance
('CS658P220', 'CS658', 1, 67, 'P2', 2020),
('CS381P422', 'CS381', 1, 45, 'P4', 2022),
('CS658P325', 'CS658', 1, 70, 'P3', 2025),  -- 2025 instance
('CS658VT23', 'CS658', 1, 55, 'VT', 2023),
('CS381P225', 'CS381', 1, 38, 'P2', 2025),  -- 2025 instance
('CS338HT23', 'CS338', 1, 75, 'HT', 2023),
('CS754P220', 'CS754', 1, 32, 'P2', 2020),
('CS338P221', 'CS338', 1, 68, 'P2', 2021),
('CS658VT21', 'CS658', 1, 61, 'VT', 2021),
('CS854H123', 'CS854', 1, 25, 'H1', 2023),
('CS381VT24', 'CS381', 1, 52, 'VT', 2024),
('CS754P120', 'CS754', 1, 29, 'P1', 2020),
('CS854HT23', 'CS854', 1, 27, 'HT', 2023),

-- *** NEW: More 2025 instances for Task 2 queries (current year) ***
-- Period 1 - 2025
('CS338P125', 'CS338', 2, 85, 'P1', 2025),
('CS559P125', 'CS559', 2, 45, 'P1', 2025),
('CS818P125', 'CS818', 2, 32, 'P1', 2025),
('CS990P125', 'CS990', 2, 24, 'P1', 2025),
('CS854P125', 'CS854', 1, 28, 'P1', 2025),

-- Period 2 - 2025 (in addition to existing ones)
('CS990P225', 'CS990', 2, 22, 'P2', 2025),
('CS818P225', 'CS818', 2, 38, 'P2', 2025),
('CS854P225', 'CS854', 1, 26, 'P2', 2025),

-- Period 3 - 2025 (in addition to existing CS658P325)
('CS338P325', 'CS338', 2, 78, 'P3', 2025),
('CS381P325', 'CS381', 2, 42, 'P3', 2025),
('CS754P325', 'CS754', 3, 36, 'P3', 2025),
('CS990P325', 'CS990', 2, 20, 'P3', 2025),

-- Period 4 - 2025
('CS559P425', 'CS559', 2, 48, 'P4', 2025),
('CS658P425', 'CS658', 2, 65, 'P4', 2025),
('CS754P425', 'CS754', 3, 38, 'P4', 2025),
('CS818P425', 'CS818', 2, 35, 'P4', 2025),
('CS990P425', 'CS990', 2, 19, 'P4', 2025),

-- Autumn Term (HT) - 2025
('CS338HT25', 'CS338', 2, 92, 'HT', 2025),
('CS381HT25', 'CS381', 2, 44, 'HT', 2025),
('CS559HT25', 'CS559', 2, 46, 'HT', 2025),
('CS658HT25', 'CS658', 2, 62, 'HT', 2025),

-- Spring Term (VT) - 2025
('CS754VT25', 'CS754', 3, 40, 'VT', 2025),
('CS818VT25', 'CS818', 2, 36, 'VT', 2025),
('CS854VT25', 'CS854', 1, 29, 'VT', 2025),
('CS990VT25', 'CS990', 2, 23, 'VT', 2025);

-- Employee-Course assignments (80+ rows - added 2025 assignments)
INSERT INTO employee_course_instance (instance_id, employee_id) VALUES
-- Historical assignments (existing data)
('CS559P322', 26),
('CS559P322', 22),
('CS990HT21', 26),
('CS990HT21', 8),
('CS990HT21', 9),
('CS658H123', 26),
('CS818VT20', 4),
('CS818VT20', 13),
('CS818VT20', 28),
('CS658P222', 28),
('CS990P424', 8),
('CS990P424', 7),
('CS754P225', 12),
('CS754P225', 10),
('CS658P220', 8),
('CS381P422', 22),
('CS658P325', 13),
('CS658P325', 6),
('CS658P325', 19),
('CS658VT23', 9),
('CS658VT23', 28),
('CS381P225', 25),
('CS381P225', 24),
('CS381P225', 29),
('CS338HT23', 12),
('CS338HT23', 21),
('CS754P220', 13),
('CS754P220', 22),
('CS754P220', 27),
('CS338P221', 11),
('CS338P221', 1),
('CS338P221', 4),
('CS658VT21', 6),
('CS658VT21', 19),
('CS854H123', 2),
('CS854H123', 4),
('CS381VT24', 14),
('CS381VT24', 12),
('CS381VT24', 24),
('CS754P120', 14),
('CS754P120', 20),
('CS854HT23', 4),
('CS854HT23', 13),
('CS854HT23', 29),

-- *** NEW: 2025 Period 1 assignments ***
('CS338P125', 1),
('CS338P125', 4),
('CS338P125', 5),
('CS559P125', 3),
('CS559P125', 26),
('CS818P125', 28),
('CS818P125', 6),
('CS990P125', 8),
('CS990P125', 9),
('CS854P125', 2),

-- *** NEW: 2025 Period 2 assignments ***
('CS990P225', 7),
('CS990P225', 8),
('CS818P225', 28),
('CS854P225', 2),
('CS854P225', 4),
-- Additional P2 diversification to surface high-load teachers
('CS381P225', 2),
('CS754P225', 7),

-- *** NEW: 2025 Period 3 assignments ***
('CS338P325', 4),
('CS338P325', 5),
('CS381P325', 24),
('CS381P325', 25),
('CS754P325', 12),
('CS754P325', 18),
('CS990P325', 9),

-- *** NEW: 2025 Period 4 assignments ***
('CS559P425', 3),
('CS559P425', 26),
('CS658P425', 6),
('CS658P425', 13),
('CS754P425', 18),
('CS754P425', 12),
('CS818P425', 28),
('CS818P425', 6),
('CS990P425', 8),
('CS990P425', 7),

-- *** NEW: 2025 HT assignments ***
('CS338HT25', 1),
('CS338HT25', 4),
('CS338HT25', 5),
('CS381HT25', 24),
('CS381HT25', 25),
('CS559HT25', 3),
('CS559HT25', 26),
('CS658HT25', 13),
('CS658HT25', 6),

-- *** NEW: 2025 VT assignments ***
('CS754VT25', 12),
('CS754VT25', 18),
('CS754VT25', 10),
('CS818VT25', 28),
('CS818VT25', 6),
('CS854VT25', 2),
('CS990VT25', 8),
('CS990VT25', 9);

-- Planned activities (100+ rows - added activities for 2025 courses)
INSERT INTO planned_activity (instance_id, employee_id, activity_name, planned_hours) VALUES
-- Historical courses (existing data)
('CS559P322', 26, 'Lecture', 20),
('CS559P322', 26, 'Lab', 15),
('CS559P322', 22, 'Tutorial', 12),
('CS990HT21', 26, 'Lecture', 18),
('CS990HT21', 8, 'Tutorial', 10),
('CS990HT21', 9, 'Lab', 14),
('CS658H123', 26, 'Lecture', 22),
('CS818VT20', 4, 'Lecture', 25),
('CS818VT20', 13, 'Lab', 18),
('CS818VT20', 28, 'Tutorial', 16),
('CS658P222', 28, 'Lecture', 24),
('CS990P424', 8, 'Lecture', 19),
('CS990P424', 7, 'Tutorial', 11),
('CS754P225', 12, 'Lecture', 21),
('CS754P225', 10, 'Lab', 13),
('CS658P220', 8, 'Lecture', 23),
('CS381P422', 22, 'Lecture', 17),
('CS658P325', 13, 'Lecture', 26),
('CS658VT23', 9, 'Lecture', 20),
('CS658VT23', 28, 'Lab', 16),
('CS381P225', 25, 'Lecture', 18),
('CS338HT23', 12, 'Lecture', 28),
('CS338HT23', 21, 'Lab', 20),
('CS754P220', 13, 'Lecture', 22),
('CS754P220', 22, 'Lab', 14),
('CS754P220', 27, 'Tutorial', 10),
('CS338P221', 11, 'Lecture', 27),
('CS338P221', 1, 'Lab', 19),
('CS338P221', 4, 'Tutorial', 13),
('CS658VT21', 6, 'Lecture', 21),
('CS658VT21', 19, 'Lab', 17),
('CS854H123', 2, 'Lecture', 16),
('CS854H123', 4, 'Seminar', 12),
('CS381VT24', 14, 'Lecture', 19),
('CS381VT24', 12, 'Lab', 15),
('CS381VT24', 24, 'Course administration', 8),
('CS381VT24', 12, 'Course administration', 23),
('CS754P120', 14, 'Course administration', 29),
('CS754P120', 14, 'Project supervision', 40),
('CS754P120', 20, 'Tutorial', 30),
('CS854HT23', 4, 'Tutorial', 32),
('CS854HT23', 13, 'Lecture', 52),

-- *** NEW: 2025 Period 1 activities ***
('CS338P125', 1, 'Lecture', 25),
('CS338P125', 4, 'Lab', 18),
('CS338P125', 5, 'Tutorial', 15),
('CS559P125', 3, 'Lecture', 22),
('CS559P125', 3, 'Lab', 16),
('CS559P125', 26, 'Tutorial', 12),
('CS818P125', 28, 'Lecture', 20),
('CS818P125', 6, 'Lab', 14),
('CS990P125', 8, 'Lecture', 18),
('CS990P125', 9, 'Seminar', 10),
('CS854P125', 2, 'Lecture', 16),
('CS854P125', 2, 'Lab', 12),

-- *** NEW: 2025 Period 2 activities ***
-- Note: CS754P225 and CS381P225 already defined in historical section above
('CS990P225', 7, 'Lecture', 19),
('CS990P225', 8, 'Tutorial', 10),
('CS818P225', 28, 'Lecture', 21),
('CS818P225', 28, 'Lab', 15),
('CS854P225', 2, 'Lecture', 17),
('CS854P225', 4, 'Seminar', 13),
-- Additional P2 diversification to surface high-load teachers
('CS381P225', 2, 'Seminar', 12),
('CS754P225', 7, 'Lecture', 15),

-- *** NEW: 2025 Period 3 activities ***
-- Note: CS658P325 already defined in historical section above
('CS338P325', 4, 'Lecture', 24),
('CS338P325', 5, 'Lab', 17),
('CS381P325', 24, 'Lecture', 19),
('CS381P325', 25, 'Tutorial', 12),
('CS754P325', 12, 'Lecture', 20),
('CS754P325', 18, 'Project supervision', 30),
('CS990P325', 9, 'Lecture', 17),

-- *** NEW: 2025 Period 4 activities ***
('CS559P425', 3, 'Lecture', 23),
('CS559P425', 26, 'Lab', 17),
('CS658P425', 6, 'Lecture', 25),
('CS658P425', 13, 'Lab', 19),
('CS754P425', 18, 'Lecture', 21),
('CS754P425', 12, 'Tutorial', 13),
('CS818P425', 28, 'Lecture', 22),
('CS818P425', 6, 'Lab', 16),
('CS990P425', 8, 'Lecture', 18),
('CS990P425', 7, 'Seminar', 11),

-- *** NEW: 2025 HT (Autumn Term) activities ***
('CS338HT25', 1, 'Lecture', 28),
('CS338HT25', 4, 'Lab', 20),
('CS338HT25', 5, 'Tutorial', 16),
('CS381HT25', 24, 'Lecture', 20),
('CS381HT25', 25, 'Lab', 15),
('CS559HT25', 3, 'Lecture', 24),
('CS559HT25', 26, 'Lab', 18),
('CS658HT25', 13, 'Lecture', 27),
('CS658HT25', 6, 'Lab', 19),

-- *** NEW: 2025 VT (Spring Term) activities ***
('CS754VT25', 12, 'Lecture', 22),
('CS754VT25', 18, 'Project supervision', 38),
('CS754VT25', 10, 'Lab', 14),
('CS818VT25', 28, 'Lecture', 23),
('CS818VT25', 6, 'Lab', 17),
('CS854VT25', 2, 'Lecture', 18),
('CS854VT25', 2, 'Seminar', 14),
('CS990VT25', 8, 'Lecture', 19),
('CS990VT25', 9, 'Tutorial', 12);

-- Teacher period limits (8 rows)
INSERT INTO teacher_period_limit (period_code, max_courses) VALUES
('P1', 3),
('P2', 4),
('P3', 2),
('P4', 5),
('H1', 2),
('H2', 3),
('HT', 4),
('VT', 5);

-- Commit transaction
COMMIT;

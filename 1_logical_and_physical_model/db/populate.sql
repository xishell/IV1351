-- Fake data generated using Faker library
-- Generated automatically for testing purposes

-- Start transaction for atomicity
BEGIN;

-- Defer constraint checking until commit
SET CONSTRAINTS ALL DEFERRED;

-- Clear existing data
TRUNCATE TABLE teacher_period_limit CASCADE;
TRUNCATE TABLE employee_course_instance CASCADE;
TRUNCATE TABLE planned_activity CASCADE;
TRUNCATE TABLE course_instance CASCADE;
TRUNCATE TABLE employee CASCADE;
TRUNCATE TABLE department CASCADE;
TRUNCATE TABLE teaching_activity CASCADE;
TRUNCATE TABLE person CASCADE;
TRUNCATE TABLE job_title CASCADE;
TRUNCATE TABLE study_period CASCADE;
TRUNCATE TABLE course_layout CASCADE;


-- Course layouts (10 rows)
INSERT INTO course_layout (course_code, layout_version, course_name, min_students, max_students, hp) VALUES
('CS754', 1, 'Customizable 4thgeneration support', 15, 28, 7.5),
('CS381', 1, 'Fully-configurable directional challenge', 9, 34, 15),
('CS854', 1, 'Customer-focused systematic support', 7, 23, 7.5),
('CS658', 1, 'Cross-group optimizing interface', 14, 37, 7.5),
('CS132', 1, 'Assimilated background data-warehouse', 5, 20, 15),
('CS338', 1, 'Profit-focused real-time algorithm', 8, 50, 7.5),
('CS674', 1, 'Exclusive transitional projection', 13, 29, 30),
('CS818', 1, 'Quality-focused intangible definition', 8, 46, 22.5),
('CS559', 1, 'Reverse-engineered even-keeled workforce', 5, 25, 30),
('CS990', 1, 'Adaptive well-modulated workforce', 10, 28, 15);

-- Study periods (8 rows)
INSERT INTO study_period (code, factor) VALUES
('P1', 'Period 1 (Sep-Oct)'),
('P2', 'Period 2 (Nov-Jan)'),
('P3', 'Period 3 (Jan-Mar)'),
('P4', 'Period 4 (Mar-Jun)'),
('H1', 'First half (Sep-Jan)'),
('H2', 'Second half (Jan-Jun)'),
('HT', 'Autumn term'),
('VT', 'Spring term');

-- Job titles (10 rows)
INSERT INTO job_title (job_title) VALUES
('Professor'),
('Associate Professor'),
('Assistant Professor'),
('Senior Lecturer'),
('Lecturer'),
('Teaching Assistant'),
('Lab Assistant'),
('Research Assistant'),
('Administrative Staff'),
('Department Head');

-- Persons (30 rows)
INSERT INTO person (personal_number, first_name, last_name, phone_number, adress, email) VALUES
('196209160001', 'Rolf', 'Friberg', '0735116155', 'Backvägen 1', 'santonsson@example.net'),
('198503110002', 'Maria', 'Lilja', '0710341316', 'Ektorget 25', 'jan41@example.net'),
('198512310003', 'Anna', 'Eriksson', '0776483503', 'Strandvägen 395', 'emmaivarsson@example.net'),
('197705150004', 'Kevin', 'Eriksson', '0788496965', 'Ängsvägen 012', 'lenajohansson@example.org'),
('197309270005', 'Charlotte', 'Johansson', '0748018451', 'Nyvägen 482', 'selinleo@example.net'),
('197910050006', 'Ingvar', 'Holst', '0728809570', 'Bäcktorget 30', 'mariasoderstrom@example.org'),
('199009300007', 'Lisbet', 'Wiklund', '0782278248', 'Aspstigen 3', 'peter57@example.net'),
('197701030008', 'Jörgen', 'Andersson', '0709839301', 'Ringgatan 18', 'larsjonsson@example.net'),
('196105140009', 'Saga', 'Larsson', '0773763116', 'Skolvägen 0', 'anderssoningrid@example.org'),
('196701260010', 'Hussein', 'Johansson', '0762473178', 'Ekstigen 132', 'njosefsson@example.com'),
('199902080011', 'Göran', 'Abdullah', '0764746872', 'Grangatan 8', 'norenbertil@example.net'),
('197804010012', 'Nina', 'Karlsson', '0708121913', 'Bäckstigen 990', 'johanssoncarina@example.net'),
('197005220013', 'Kasper', 'Mattsson', '0753462475', 'Trädgårdsstigen 1', 'knutssonalice@example.org'),
('200008120014', 'Marianne', 'Sjögren', '0754278498', 'Aspgränd 241', 'nordstromgunnar@example.com'),
('198407090015', 'Ingegerd', 'Eklund', '0748740164', 'Industritorget 427', 'hlarsson@example.org'),
('200103110016', 'Gunilla', 'Boström', '0705982620', 'Bäcktorget 533', 'henrikssonbarbro@example.com'),
('200208080017', 'Johanna', 'Svensson', '0732260256', 'Nytorget 1', 'esingh@example.org'),
('196408300018', 'Nina', 'Hellström', '0733036541', 'Ekstigen 85', 'bergmantherese@example.org'),
('198305020019', 'Vendela', 'Andersson', '0796556981', 'Storgatan 6', 'karlssonlinnea@example.net'),
('199002190020', 'Jenny', 'Mattsson', '0756159514', 'Industrivägen 4', 'hakanmalmqvist@example.com'),
('198801270021', 'Michaela', 'Lindström', '0746804436', 'Trädgårdsvägen 3', 'yosman@example.net'),
('196303140022', 'Christian', 'Karlsson', '0795134332', 'Idrottsvägen 1', 'ojensen@example.net'),
('196405300023', 'Hanna', 'Jörgensen', '0732016328', 'Kyrkogatan 727', 'sofia79@example.net'),
('199808050024', 'Rune', 'Sundberg', '0772774348', 'Storvägen 434', 'martin81@example.org'),
('196204110025', 'Patrik', 'Brodin', '0731665876', 'Fabriksvägen 90', 'wjonsson@example.com'),
('199110210026', 'Maria', 'Törnqvist', '0768893734', 'Björkvägen 62', 'nsvensson@example.net'),
('195603160027', 'Per', 'Larsson', '0701627204', 'Granvägen 56', 'josefin64@example.org'),
('197712060028', 'Johanna', 'Andersson', '0753100330', 'Skogsvägen 1', 'tomasfalk@example.com'),
('196302080029', 'Dagny', 'Norén', '0712419049', 'Stationsgatan 931', 'margaretha91@example.net'),
('199303260030', 'Muhammad', 'Johansson', '0751850671', 'Ektorget 26', 'irmawallin@example.com');

-- Departments (5 rows)
INSERT INTO department (department_name, manager_id) VALUES
('Computer Science', 7),
('Mathematics', 25),
('Physics', 11),
('Electrical Engineering', 4),
('Software Engineering', 3);

-- Teaching activities (7 rows)
INSERT INTO teaching_activity (activity_name, factor) VALUES
('Lecture', 1),
('Lab', 2),
('Seminar', 1),
('Tutorial', 2),
('Project supervision', 3),
('Exam grading', 1),
('Course administration', 1);

-- Employees (30 rows)
INSERT INTO employee (employee_id, personal_number, job_title, skill_set, salary, department_name, manager_id) VALUES
(1, '196209160001', 'Lab Assistant', NULL, 26584, 'Physics', NULL),
(2, '198503110002', 'Teaching Assistant', NULL, 39891, 'Physics', NULL),
(3, '198512310003', 'Research Assistant', NULL, 43785, 'Computer Science', NULL),
(4, '197705150004', 'Lab Assistant', NULL, 26291, 'Software Engineering', 3),
(5, '197309270005', 'Department Head', NULL, 86850, 'Software Engineering', 1),
(6, '197910050006', 'Professor', 'Seamless national time-frame, Polarized maximized Internet solution, Upgradable optimizing flexibility', 79482, 'Computer Science', NULL),
(7, '199009300007', 'Associate Professor', 'Inverse dynamic array, Grass-roots local encryption, Versatile maximized open system, Seamless static implementation, Mandatory 4thgeneration methodology', 64554, 'Electrical Engineering', NULL),
(8, '197701030008', 'Teaching Assistant', NULL, 32664, 'Physics', NULL),
(9, '196105140009', 'Lecturer', 'Inverse contextually-based matrix, Extended heuristic website', 54980, 'Mathematics', NULL),
(10, '196701260010', 'Senior Lecturer', 'Fundamental global focus group, Right-sized tangible focus group, Realigned 24/7 model', 62573, 'Electrical Engineering', 9),
(11, '199902080011', 'Senior Lecturer', 'Ergonomic attitude-oriented encoding, Up-sized incremental matrix, Realigned well-modulated encoding, Team-oriented methodical project', 68809, 'Computer Science', 1),
(12, '197804010012', 'Teaching Assistant', NULL, 36572, 'Physics', 10),
(13, '197005220013', 'Teaching Assistant', NULL, 33483, 'Electrical Engineering', NULL),
(14, '200008120014', 'Research Assistant', NULL, 37340, 'Physics', 12),
(15, '198407090015', 'Administrative Staff', NULL, 43830, 'Physics', NULL),
(16, '200103110016', 'Lab Assistant', NULL, 34560, 'Electrical Engineering', NULL),
(17, '200208080017', 'Assistant Professor', 'Universal mobile knowledge user, Ameliorated background frame, Face-to-face impactful solution, Fully-configurable fault-tolerant protocol, Reduced holistic leverage', 51489, 'Computer Science', NULL),
(18, '196408300018', 'Assistant Professor', 'Reactive multi-tasking hardware, Optimized value-added neural-net, Managed heuristic standardization', 62977, 'Electrical Engineering', NULL),
(19, '198305020019', 'Lab Assistant', NULL, 31252, 'Software Engineering', NULL),
(20, '199002190020', 'Administrative Staff', NULL, 39119, 'Software Engineering', NULL),
(21, '198801270021', 'Professor', 'Persevering encompassing function, Function-based discrete capability', 87595, 'Physics', NULL),
(22, '196303140022', 'Teaching Assistant', NULL, 31827, 'Physics', NULL),
(23, '196405300023', 'Research Assistant', NULL, 35053, 'Physics', NULL),
(24, '199808050024', 'Assistant Professor', 'Up-sized content-based functionalities, Decentralized value-added monitoring', 64262, 'Physics', NULL),
(25, '196204110025', 'Administrative Staff', NULL, 44977, 'Mathematics', 6),
(26, '199110210026', 'Administrative Staff', NULL, 47757, 'Software Engineering', NULL),
(27, '195603160027', 'Department Head', NULL, 85621, 'Electrical Engineering', 12),
(28, '197712060028', 'Lecturer', 'Virtual system-worthy contingency, Ergonomic didactic support, Polarized even-keeled success', 45949, 'Mathematics', NULL),
(29, '196302080029', 'Associate Professor', 'Reverse-engineered well-modulated moderator, Right-sized executive attitude', 71991, 'Electrical Engineering', NULL),
(30, '199303260030', 'Administrative Staff', NULL, 47547, 'Mathematics', 16);

-- Course instances (20 rows)
INSERT INTO course_instance (instance_id, course_code, layout_version, num_students, study_period, study_year) VALUES
('CS559P322', 'CS559', 1, 43, 'P3', 2022),
('CS990HT21', 'CS990', 1, 44, 'HT', 2021),
('CS658H123', 'CS658', 1, 33, 'H1', 2023),
('CS818VT20', 'CS818', 1, 25, 'VT', 2020),
('CS658P222', 'CS658', 1, 11, 'P2', 2022),
('CS990P424', 'CS990', 1, 24, 'P4', 2024),
('CS754P225', 'CS754', 1, 13, 'P2', 2025),
('CS658P220', 'CS658', 1, 31, 'P2', 2020),
('CS381P422', 'CS381', 1, 41, 'P4', 2022),
('CS658P325', 'CS658', 1, 40, 'P3', 2025),
('CS658VT23', 'CS658', 1, 22, 'VT', 2023),
('CS381P225', 'CS381', 1, 37, 'P2', 2025),
('CS338HT23', 'CS338', 1, 39, 'HT', 2023),
('CS754P220', 'CS754', 1, 35, 'P2', 2020),
('CS338P221', 'CS338', 1, 22, 'P2', 2021),
('CS658VT21', 'CS658', 1, 37, 'VT', 2021),
('CS854H123', 'CS854', 1, 25, 'H1', 2023),
('CS381VT24', 'CS381', 1, 16, 'VT', 2024),
('CS754P120', 'CS754', 1, 25, 'P1', 2020),
('CS854HT23', 'CS854', 1, 40, 'HT', 2023);

-- Planned activities (66 rows)
INSERT INTO planned_activity (instance_id, activity_name, planned_hours) VALUES
('CS559P322', 'Course administration', 17),
('CS559P322', 'Tutorial', 31),
('CS990HT21', 'Lecture', 68),
('CS990HT21', 'Tutorial', 46),
('CS990HT21', 'Seminar', 64),
('CS658H123', 'Exam grading', 34),
('CS658H123', 'Project supervision', 47),
('CS658H123', 'Tutorial', 37),
('CS658H123', 'Lab', 17),
('CS818VT20', 'Exam grading', 17),
('CS818VT20', 'Project supervision', 16),
('CS818VT20', 'Lecture', 71),
('CS818VT20', 'Seminar', 74),
('CS658P222', 'Lab', 33),
('CS658P222', 'Lecture', 18),
('CS658P222', 'Project supervision', 18),
('CS658P222', 'Exam grading', 40),
('CS990P424', 'Lecture', 15),
('CS990P424', 'Project supervision', 20),
('CS990P424', 'Lab', 63),
('CS754P225', 'Project supervision', 43),
('CS754P225', 'Course administration', 36),
('CS754P225', 'Exam grading', 50),
('CS754P225', 'Seminar', 40),
('CS658P220', 'Tutorial', 68),
('CS658P220', 'Lab', 50),
('CS658P220', 'Seminar', 19),
('CS381P422', 'Tutorial', 22),
('CS381P422', 'Project supervision', 19),
('CS658P325', 'Lab', 54),
('CS658P325', 'Project supervision', 18),
('CS658P325', 'Seminar', 41),
('CS658P325', 'Course administration', 57),
('CS658VT23', 'Lab', 48),
('CS658VT23', 'Tutorial', 77),
('CS658VT23', 'Project supervision', 11),
('CS381P225', 'Course administration', 27),
('CS381P225', 'Project supervision', 43),
('CS381P225', 'Seminar', 24),
('CS381P225', 'Lecture', 23),
('CS338HT23', 'Project supervision', 36),
('CS338HT23', 'Lab', 53),
('CS338HT23', 'Seminar', 36),
('CS338HT23', 'Course administration', 43),
('CS754P220', 'Tutorial', 64),
('CS754P220', 'Seminar', 45),
('CS754P220', 'Lecture', 15),
('CS754P220', 'Project supervision', 10),
('CS338P221', 'Course administration', 30),
('CS338P221', 'Lab', 66),
('CS338P221', 'Seminar', 80),
('CS658VT21', 'Tutorial', 19),
('CS658VT21', 'Project supervision', 29),
('CS658VT21', 'Lecture', 79),
('CS658VT21', 'Exam grading', 14),
('CS854H123', 'Project supervision', 65),
('CS854H123', 'Course administration', 26),
('CS854H123', 'Lab', 15),
('CS381VT24', 'Seminar', 36),
('CS381VT24', 'Lecture', 41),
('CS381VT24', 'Course administration', 23),
('CS754P120', 'Course administration', 29),
('CS754P120', 'Project supervision', 40),
('CS754P120', 'Tutorial', 30),
('CS854HT23', 'Tutorial', 32),
('CS854HT23', 'Lecture', 52);

-- Employee-Course assignments (40 rows)
INSERT INTO employee_course_instance (instance_id, employee_id) VALUES
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
('CS658VT23', 9),
('CS658VT23', 28),
('CS381P225', 25),
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
('CS854HT23', 29);

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
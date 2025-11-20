#!/usr/bin/env python3
"""
Generate fake data for the database schema defined in create.sql.
Uses the Faker library to create realistic test data.
"""

import argparse
import random
from pathlib import Path
from faker import Faker


def format_value(val) -> str:
    """Format a single value for SQL."""
    if val is None:
        return 'NULL'
    elif isinstance(val, bool):
        return 'TRUE' if val else 'FALSE'
    elif isinstance(val, (int, float)):
        return str(val)
    else:
        # Escape single quotes in strings
        escaped = str(val).replace("'", "''")
        return f"'{escaped}'"


def generate_multi_row_insert(table_name: str, columns: list[str], rows: list[list]) -> str:
    """Generate a SQL INSERT statement with multiple rows."""
    if not rows:
        return ""

    values_list = []
    for row in rows:
        formatted_values = [format_value(val) for val in row]
        values_list.append(f"({', '.join(formatted_values)})")

    column_str = ', '.join(columns)
    values_str = ',\n'.join(values_list)

    return f"INSERT INTO {table_name} ({column_str}) VALUES\n{values_str};"


def generate_fake_data(num_records: int = 50, seed: int = 42) -> str:
    """
    Generate fake data for all tables in the database.

    Args:
        num_records: Number of records to generate for each main table
        seed: Random seed for reproducibility

    Returns:
        SQL statements as a string
    """
    fake = Faker('sv_SE')  # Swedish locale for Swedish names, addresses, etc.
    Faker.seed(seed)
    random.seed(seed)

    sql_statements = []
    sql_statements.append("-- Fake data generated using Faker library")
    sql_statements.append("-- Generated automatically for testing purposes")
    sql_statements.append("")
    sql_statements.append("-- Start transaction for atomicity")
    sql_statements.append("BEGIN;")
    sql_statements.append("")
    sql_statements.append("-- Defer constraint checking until commit")
    sql_statements.append("SET CONSTRAINTS ALL DEFERRED;")
    sql_statements.append("")

    # Clear existing data (in reverse dependency order)
    sql_statements.append("-- Clear existing data")
    sql_statements.append("TRUNCATE TABLE teacher_period_limit CASCADE;")
    sql_statements.append("TRUNCATE TABLE employee_course_instance CASCADE;")
    sql_statements.append("TRUNCATE TABLE planned_activity CASCADE;")
    sql_statements.append("TRUNCATE TABLE course_instance CASCADE;")
    sql_statements.append("TRUNCATE TABLE employee CASCADE;")
    sql_statements.append("TRUNCATE TABLE department CASCADE;")
    sql_statements.append("TRUNCATE TABLE teaching_activity CASCADE;")
    sql_statements.append("TRUNCATE TABLE person CASCADE;")
    sql_statements.append("TRUNCATE TABLE job_title CASCADE;")
    sql_statements.append("TRUNCATE TABLE study_period CASCADE;")
    sql_statements.append("TRUNCATE TABLE course_layout CASCADE;\n")

    # Track generated IDs for foreign key relationships
    course_layouts = []  # List of (course_code, layout_version) tuples
    study_periods = []
    job_titles = []
    personal_numbers = []
    employee_ids = []
    department_names = []
    teaching_activities = []
    course_instances = []

    # 1. Generate course_layout (independent)
    sql_statements.append("")
    course_layout_count = max(10, num_records // 5)
    sql_statements.append(f"-- Course layouts ({course_layout_count} rows)")
    course_layout_rows = []
    for i in range(max(10, num_records // 5)):
        course_code = f"CS{fake.random_int(100, 999)}"
        layout_version = 1  # Start with version 1 for each course
        course_name = fake.catch_phrase()[:50]
        min_students = random.randint(5, 15)
        max_students = random.randint(min_students + 10, 50)
        hp = random.choice([7.5, 15, 22.5, 30])

        course_layouts.append((course_code, layout_version))
        course_layout_rows.append([course_code, layout_version, course_name, min_students, max_students, hp])

    sql_statements.append(generate_multi_row_insert(
        'course_layout',
        ['course_code', 'layout_version', 'course_name', 'min_students', 'max_students', 'hp'],
        course_layout_rows
    ))

    # 2. Generate study_period (independent)
    sql_statements.append("")
    periods = [
        ('P1', 'Period 1 (Sep-Oct)'),
        ('P2', 'Period 2 (Nov-Jan)'),
        ('P3', 'Period 3 (Jan-Mar)'),
        ('P4', 'Period 4 (Mar-Jun)'),
        ('H1', 'First half (Sep-Jan)'),
        ('H2', 'Second half (Jan-Jun)'),
        ('HT', 'Autumn term'),
        ('VT', 'Spring term'),
    ]
    sql_statements.append(f"-- Study periods ({len(periods)} rows)")
    study_period_rows = []
    for code, factor in periods:
        study_periods.append(code)
        study_period_rows.append([code, factor])

    sql_statements.append(generate_multi_row_insert(
        'study_period',
        ['code', 'factor'],
        study_period_rows
    ))

    # 3. Generate job_title (independent)
    sql_statements.append("")
    titles = [
        'Professor',
        'Associate Professor',
        'Assistant Professor',
        'Senior Lecturer',
        'Lecturer',
        'Teaching Assistant',
        'Lab Assistant',
        'Research Assistant',
        'Administrative Staff',
        'Department Head'
    ]
    sql_statements.append(f"-- Job titles ({len(titles)} rows)")
    job_title_rows = []
    for title in titles:
        job_titles.append(title)
        job_title_rows.append([title])

    sql_statements.append(generate_multi_row_insert(
        'job_title',
        ['job_title'],
        job_title_rows
    ))

    # 4. Generate person (independent)
    sql_statements.append("")
    sql_statements.append(f"-- Persons ({num_records} rows)")
    person_rows = []
    for i in range(num_records):
        # Swedish personnummer format: YYYYMMDDXXXX (12 characters)
        # YYYYMMDD is full birth date, XXXX is a 4-digit serial number
        # Stored as VARCHAR to properly represent this identifier
        birth_date = fake.date_of_birth(minimum_age=22, maximum_age=70)
        date_part = birth_date.strftime('%Y%m%d')  # YYYYMMDD (full year)
        personal_number = f"{date_part}{i+1:04d}"  # e.g., '196203150001'
        first_name = fake.first_name()
        last_name = fake.last_name()
        phone_number = fake.numerify('07########')  # Swedish mobile format
        address = fake.street_address()[:100]
        email = fake.email()

        personal_numbers.append(personal_number)
        person_rows.append([personal_number, first_name, last_name, phone_number, address, email])

    sql_statements.append(generate_multi_row_insert(
        'person',
        ['personal_number', 'first_name', 'last_name', 'phone_number', 'adress', 'email'],
        person_rows
    ))

    # 5. Generate department (independent)
    sql_statements.append("")
    dept_list = [
        'Computer Science',
        'Mathematics',
        'Physics',
        'Electrical Engineering',
        'Software Engineering'
    ]
    sql_statements.append(f"-- Departments ({len(dept_list)} rows)")
    department_rows = []
    for dept in dept_list:
        department_names.append(dept)
        # manager_id field exists but has no FK constraint in current schema
        manager_id = random.randint(1, num_records)
        department_rows.append([dept, manager_id])

    sql_statements.append(generate_multi_row_insert(
        'department',
        ['department_name', 'manager_id'],
        department_rows
    ))

    # 6. Generate teaching_activity (independent)
    sql_statements.append("")
    activities = [
        ('Lecture', 1),
        ('Lab', 2),
        ('Seminar', 1),
        ('Tutorial', 2),
        ('Project supervision', 3),
        ('Exam grading', 1),
        ('Course administration', 1),
    ]
    sql_statements.append(f"-- Teaching activities ({len(activities)} rows)")
    teaching_activity_rows = []
    for activity_name, factor in activities:
        teaching_activities.append(activity_name)
        teaching_activity_rows.append([activity_name, factor])

    sql_statements.append(generate_multi_row_insert(
        'teaching_activity',
        ['activity_name', 'factor'],
        teaching_activity_rows
    ))

    # 7. Generate employee (depends on job_title, department, person)
    sql_statements.append("")
    sql_statements.append(f"-- Employees ({num_records} rows)")
    employee_rows = []
    for i in range(num_records):
        employee_id = i + 1
        personal_number = personal_numbers[i]
        job_title = random.choice(job_titles)

        # Generate skill set based on job title
        skills = []
        if 'Professor' in job_title or 'Lecturer' in job_title:
            skills = [fake.catch_phrase() for _ in range(random.randint(2, 5))]
        skill_set = ', '.join(skills)[:500] if skills else None

        # Salary based on job title
        salary_ranges = {
            'Professor': (70000, 90000),
            'Associate Professor': (60000, 75000),
            'Assistant Professor': (50000, 65000),
            'Senior Lecturer': (55000, 70000),
            'Lecturer': (45000, 60000),
            'Teaching Assistant': (30000, 40000),
            'Lab Assistant': (25000, 35000),
            'Research Assistant': (35000, 45000),
            'Administrative Staff': (35000, 50000),
            'Department Head': (75000, 95000)
        }
        min_sal, max_sal = salary_ranges.get(job_title, (30000, 60000))
        salary = random.randint(min_sal, max_sal)

        department_name = random.choice(department_names)

        # manager_id should be employee_id of a manager or NULL
        # For simplicity, 30% chance of having a manager (references earlier employee)
        if i > 0 and random.random() < 0.3:
            manager_id = random.randint(1, i)  # Reference an existing employee
        else:
            manager_id = None

        employee_ids.append(employee_id)
        employee_rows.append([employee_id, personal_number, job_title, skill_set, salary,
                             department_name, manager_id])

    sql_statements.append(generate_multi_row_insert(
        'employee',
        ['employee_id', 'personal_number', 'job_title', 'skill_set', 'salary',
         'department_name', 'manager_id'],
        employee_rows
    ))

    # 8. Generate course_instance (depends on course_layout, study_period)
    sql_statements.append("")
    course_instance_count = max(20, num_records // 2)
    sql_statements.append(f"-- Course instances ({course_instance_count} rows)")
    course_instance_rows = []
    used_instance_ids = set()
    for i in range(course_instance_count):
        # Keep trying until we get a unique instance_id
        max_attempts = 100
        for attempt in range(max_attempts):
            course_code, layout_version = random.choice(course_layouts)
            study_period = random.choice(study_periods)
            study_year = random.randint(2020, 2025)

            # Instance ID format: CODECODEYY (e.g., CS101P124)
            instance_id = f"{course_code}{study_period}{str(study_year)[-2:]}"

            if instance_id not in used_instance_ids:
                used_instance_ids.add(instance_id)
                break
        else:
            # If we couldn't find a unique ID after max_attempts, skip this instance
            continue

        # Get course layout to determine student limits
        num_students = random.randint(10, 45)

        course_instances.append(instance_id)
        course_instance_rows.append([instance_id, course_code, layout_version, num_students,
                                    study_period, study_year])

    sql_statements.append(generate_multi_row_insert(
        'course_instance',
        ['instance_id', 'course_code', 'layout_version', 'num_students',
         'study_period', 'study_year'],
        course_instance_rows
    ))

    # 9. Generate planned_activity (depends on teaching_activity, course_instance)
    sql_statements.append("")
    # Count will be determined dynamically
    planned_activity_rows = []
    for course_inst in course_instances:
        # Generate 2-4 unique activities per course instance
        num_activities = random.randint(2, 4)
        selected_activities = random.sample(teaching_activities, min(num_activities, len(teaching_activities)))

        for activity_name in selected_activities:
            planned_hours = random.randint(10, 80)
            # Composite PK: (instance_id, activity_name)
            planned_activity_rows.append([course_inst, activity_name, planned_hours])

    sql_statements.append(f"-- Planned activities ({len(planned_activity_rows)} rows)")
    sql_statements.append(generate_multi_row_insert(
        'planned_activity',
        ['instance_id', 'activity_name', 'planned_hours'],
        planned_activity_rows
    ))

    # 10. Generate employee_course_instance (depends on employee, course_instance)
    sql_statements.append("")
    employee_course_rows = []
    for course_inst in course_instances:
        # Assign 1-3 employees to each course instance
        num_employees = random.randint(1, 3)
        assigned_employees = random.sample(employee_ids, min(num_employees, len(employee_ids)))

        for emp_id in assigned_employees:
            # Composite PK: (instance_id, employee_id)
            employee_course_rows.append([course_inst, emp_id])

    sql_statements.append(f"-- Employee-Course assignments ({len(employee_course_rows)} rows)")
    sql_statements.append(generate_multi_row_insert(
        'employee_course_instance',
        ['instance_id', 'employee_id'],
        employee_course_rows
    ))

    # 11. Generate teacher_period_limit (depends on study_period)
    sql_statements.append("")
    teacher_period_limit_rows = []
    for period_code in study_periods:
        max_courses = random.randint(2, 5)  # Each teacher can teach 2-5 courses per period
        teacher_period_limit_rows.append([period_code, max_courses])

    sql_statements.append(f"-- Teacher period limits ({len(teacher_period_limit_rows)} rows)")
    sql_statements.append(generate_multi_row_insert(
        'teacher_period_limit',
        ['period_code', 'max_courses'],
        teacher_period_limit_rows
    ))

    # Commit transaction
    sql_statements.append("")
    sql_statements.append("-- Commit transaction")
    sql_statements.append("COMMIT;")

    return '\n'.join(sql_statements)


def main():
    parser = argparse.ArgumentParser(
        description='Generate fake data for database testing'
    )
    parser.add_argument(
        '-n', '--num-records',
        type=int,
        default=50,
        help='Number of records to generate for main tables (default: 50)'
    )
    parser.add_argument(
        '-o', '--output',
        type=Path,
        default=Path('1_logical_and_physical_model/db/populate.sql'),
        help='Output SQL file path (default: 1_logical_and_physical_model/db/populate.sql)'
    )
    parser.add_argument(
        '-s', '--seed',
        type=int,
        default=42,
        help='Random seed for reproducibility (default: 42)'
    )

    args = parser.parse_args()

    # Generate fake data
    print(f"Generating {args.num_records} records with seed {args.seed}...")
    sql_content = generate_fake_data(args.num_records, args.seed)

    # Ensure output directory exists
    args.output.parent.mkdir(parents=True, exist_ok=True)

    # Write to file
    args.output.write_text(sql_content)
    print(f"Generated SQL file: {args.output}")
    print(f"Total statements: {sql_content.count('INSERT INTO')}")


if __name__ == '__main__':
    main()

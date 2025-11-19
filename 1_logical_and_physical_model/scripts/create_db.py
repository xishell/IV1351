import os

import psycopg2

from dbconfig.config import DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER, load_sql

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "../db/create.sql")


def init_db():
    if not os.path.exists(DB_PATH):
        print(f"Error: SQL file not found at {DB_PATH}")
        print("Please create the create.sql file in the db directory.")
        return

    print("Connecting to database")

    try:
        conn = psycopg2.connect(
            host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASSWORD, port=DB_PORT
        )
    except psycopg2.Error as e:
        print(f"Error connecting to database: {e}")
        return

    cursor = conn.cursor()

    print(f"Reading SQL from: {DB_PATH}")
    try:
        sql_script = load_sql(DB_PATH)
    except Exception as e:
        print(f"Error reading SQL file: {e}")
        cursor.close()
        conn.close()
        return

    print("Executing create.sql...")
    try:
        cursor.execute(sql_script)
        conn.commit()
        print("Database schema successfully created!")
    except Exception as e:
        conn.rollback()
        print("Error executing SQL:")
        print(e)
    finally:
        cursor.close()
        conn.close()
        print("Connection closed.")


if __name__ == "__main__":
    init_db()

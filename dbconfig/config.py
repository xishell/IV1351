import os

from dotenv import load_dotenv

load_dotenv()


def get_db_config():
    return {
        "host": os.getenv("DB_HOST", "localhost"),
        "dbname": os.getenv("DB_NAME", "university"),
        "user": os.getenv("DB_USER", "postgres"),
        "password": os.getenv("DB_PASSWORD", "SuperSecure"),
        "port": int(os.getenv("DB_PORT", 5432)),
    }


def load_sql(path):
    with open(path, "r") as f:
        return f.read()

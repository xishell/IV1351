import os

from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "university")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "SuperSecure")
DB_PORT = int(os.getenv("DB_PORT", 5432))


def load_sql(path):
    with open(path, "r") as f:
        return f.read()

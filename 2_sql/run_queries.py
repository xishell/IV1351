#!/usr/bin/env python3
"""
Run all Task 2 queries and output results in a formatted way
Usage: python run_queries.py [--format {table|csv|markdown}]
"""

import argparse
import sys
from pathlib import Path

# Add parent directory to path to import dbconfig
sys.path.append(str(Path(__file__).parent.parent))
QUERIES_DIR = Path(__file__).parent / "queries"
try:
    import psycopg2

    from dbconfig.config import get_db_config
except ImportError as e:
    print(f"Error importing required modules: {e}")
    print("Make sure psycopg2 is installed: pip install psycopg2-binary")
    sys.exit(1)


def connect_db():
    """Establish database connection"""
    try:
        config = get_db_config()
        conn = psycopg2.connect(**config)
        return conn
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)


def format_table(headers, rows):
    """Format results as ASCII table"""
    if not rows:
        return "No results"

    # Calculate column widths
    col_widths = [len(str(h)) for h in headers]
    for row in rows:
        for i, val in enumerate(row):
            col_widths[i] = max(col_widths[i], len(str(val)))

    # Create separator
    separator = "+" + "+".join("-" * (w + 2) for w in col_widths) + "+"

    # Format header
    header_row = (
        "|"
        + "|".join(f" {str(h):<{col_widths[i]}} " for i, h in enumerate(headers))
        + "|"
    )

    # Format data rows
    data_rows = []
    for row in rows:
        data_row = (
            "|"
            + "|".join(f" {str(val):<{col_widths[i]}} " for i, val in enumerate(row))
            + "|"
        )
        data_rows.append(data_row)

    # Combine all
    result = [separator, header_row, separator]
    result.extend(data_rows)
    result.append(separator)

    return "\n".join(result)


def format_markdown(headers, rows):
    """Format results as Markdown table"""
    if not rows:
        return "No results"

    # Header row
    header = "| " + " | ".join(str(h) for h in headers) + " |"
    separator = "|" + "|".join("---" for _ in headers) + "|"

    # Data rows
    data_rows = []
    for row in rows:
        data_row = "| " + " | ".join(str(val) for val in row) + " |"
        data_rows.append(data_row)

    result = [header, separator] + data_rows
    return "\n".join(result)


def format_csv(headers, rows):
    """Format results as CSV"""
    if not rows:
        return "No results"

    result = [",".join(str(h) for h in headers)]
    for row in rows:
        result.append(",".join(f'"{val}"' for val in row))

    return "\n".join(result)


def run_query(conn, query_name, query_text, output_format="table"):
    """Run a single query and format output"""
    print(f"\n{'=' * 80}")
    print(f"{query_name}")
    print(f"{'=' * 80}\n")

    try:
        cursor = conn.cursor()
        cursor.execute(query_text)

        # Get results
        rows = cursor.fetchall()
        headers = [desc[0] for desc in cursor.description]

        # Format output
        if output_format == "markdown":
            result = format_markdown(headers, rows)
        elif output_format == "csv":
            result = format_csv(headers, rows)
        else:  # table
            result = format_table(headers, rows)

        print(result)
        print(f"\nRows returned: {len(rows)}\n")

        cursor.close()

    except Exception as e:
        print(f"Error executing query: {e}\n")


def load_queries():
    """Load all .sql files in the queries directory."""
    queries = {}

    for i, filepath in enumerate(sorted(QUERIES_DIR.glob("*.sql")), start=1):
        queries[i] = {
            "name": f"Query {i}: {filepath.stem.replace('_', ' ').title()}",
            "sql": filepath.read_text(),
        }

    return queries


def main():
    parser = argparse.ArgumentParser(description="Run Task 2 SQL queries")
    parser.add_argument(
        "--format",
        choices=["table", "csv", "markdown"],
        default="table",
        help="Output format (default: table)",
    )
    parser.add_argument(
        "--query",
        type=int,
        choices=[1, 2, 3, 4],
        help="Run only specified query (default: run all)",
    )

    args = parser.parse_args()

    # Connect to database
    conn = connect_db()

    queries = load_queries()
    # Run specified query or all queries
    if args.query:
        query = queries[args.query]
        run_query(conn, query["name"], query["sql"], args.format)
    else:
        for query_num in sorted(queries.keys()):
            query = queries[query_num]
            run_query(conn, query["name"], query["sql"], args.format)

    # Close connection
    conn.close()
    print("\nDone!")


if __name__ == "__main__":
    main()

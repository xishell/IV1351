import argparse
import html
import os
import re
import sys
import xml.etree.ElementTree as ET

FIELD_REGEX = r"^(?P<name>\w+)\s*:\s*(?P<type>[\w()]+)\s*(?P<constraints>.*)"


def clean_text(text):
    if not text:
        return ""
    text = re.sub(r"<br\s*/?>", " ", text, flags=re.IGNORECASE)
    text = re.sub(r"</?div>", " ", text, flags=re.IGNORECASE)
    text = html.unescape(text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def is_table_cell(cell):
    vertex = cell.get("vertex", "")
    style = cell.get("style", "")

    if vertex != "1":
        return False

    if "shape=table" in style:
        return True
    if "rounded=0" in style and "whiteSpace=wrap" in style:
        return True

    return False


def parse_field_line(line):
    match = re.match(FIELD_REGEX, line)
    if not match:
        return None

    return {
        "name": match.group("name"),
        "type": match.group("type"),
        "constraints": match.group("constraints").strip(),
    }


def parse_drawio_xml(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    tables = {}
    edges = []
    cell_map = {}

    for cell in root.iter("mxCell"):
        cell_id = cell.get("id", "")
        parent_id = cell.get("parent", "")
        value = cell.get("value", "")
        style = cell.get("style", "")
        vertex = cell.get("vertex", "")
        edge = cell.get("edge", "")
        source = cell.get("source", "")
        target = cell.get("target", "")

        cell_map[cell_id] = {
            "value": value,
            "style": style,
            "parent": parent_id,
            "vertex": vertex,
            "edge": edge,
            "source": source,
            "target": target,
            "children": [],
        }

    for cell_id, cell_data in cell_map.items():
        parent_id = cell_data["parent"]
        if parent_id in cell_map:
            cell_map[parent_id]["children"].append(cell_id)

    for cell_id, cell_data in cell_map.items():
        if cell_data["edge"] == "1":
            edges.append(cell_data)
        elif is_table_cell(cell_map.get(cell_id, {})):
            value = cell_data["value"]
            table_name = clean_text(value)
            if not table_name:
                continue

            table = {
                "name": table_name,
                "cell_id": cell_id,
                "fields": [],
                "pk_fields": [],
                "fk_relations": [],
            }

            for row_id in cell_data["children"]:
                row_data = cell_map.get(row_id, {})
                if "shape=tableRow" in row_data.get("style", ""):
                    row_cells = []
                    for cell_id in row_data.get("children", []):
                        cell_value = cell_map.get(cell_id, {}).get("value", "")
                        row_cells.append(cell_value)

                    process_row(row_cells, table)

            tables[table_name] = table

    process_edges(edges, tables, cell_map)

    return tables


def process_row(cells, table):
    if len(cells) < 2:
        return

    pk_fk_marker = clean_text(cells[0]) if cells else ""
    column_text = clean_text(cells[1]) if len(cells) > 1 else ""
    data_type_text = clean_text(cells[2]) if len(cells) > 2 else ""

    if not column_text:
        return

    field_line = f"{column_text} : {data_type_text}"
    field = parse_field_line(field_line)

    if not field:
        field = {
            "name": column_text,
            "type": data_type_text,
            "constraints": "",
        }

    constraints_parts = []
    if field["constraints"]:
        constraints_parts.append(field["constraints"])

    if "PK" in pk_fk_marker:
        table["pk_fields"].append(field["name"])
        constraints_parts.append("PRIMARY KEY")

    if "FK" in pk_fk_marker:
        fk_match = re.search(
            r"fk\s+(\w+)\s*\(\s*(\w+)\s*\)", field["constraints"], re.IGNORECASE
        )
        if fk_match:
            ref_table = fk_match.group(1)
            ref_column = fk_match.group(2)
            table["fk_relations"].append((field["name"], ref_table, ref_column))

    field["constraints"] = " ".join(constraints_parts)
    table["fields"].append(field)


def process_edges(edges, tables, cell_map):
    cell_to_table = {}
    for table_name, table_data in tables.items():
        cell_to_table[table_data["cell_id"]] = table_name

    for edge in edges:
        source = edge["source"]
        target = edge["target"]
        label = clean_text(edge["value"])

        if not source or not target:
            continue

        source_table = cell_to_table.get(source)
        target_table = cell_to_table.get(target)

        if not source_table or not target_table:
            continue

        if "1:N" in label or "1:n" in label:
            parent_table = source_table
            child_table = target_table
        elif "N:1" in label or "n:1" in label:
            parent_table = target_table
            child_table = source_table
        else:
            continue

        fk_field_name = f"{parent_table}_id"

        parent_pk = (
            tables[parent_table]["pk_fields"][0]
            if tables[parent_table]["pk_fields"]
            else "id"
        )

        child_table_data = tables[child_table]
        existing_field = next(
            (f for f in child_table_data["fields"] if f["name"] == fk_field_name), None
        )

        if not existing_field:
            child_table_data["fields"].append(
                {"name": fk_field_name, "type": "INT", "constraints": "NOT NULL"}
            )

        if (fk_field_name, parent_table, parent_pk) not in child_table_data[
            "fk_relations"
        ]:
            child_table_data["fk_relations"].append(
                (fk_field_name, parent_table, parent_pk)
            )


def topological_sort(tables):
    sorted_tables = []
    visited = set()
    temp_mark = set()

    def visit(table_name):
        if table_name in visited:
            return
        if table_name in temp_mark:
            return

        temp_mark.add(table_name)

        table = tables[table_name]
        for _, ref_table, _ in table["fk_relations"]:
            if ref_table in tables and ref_table != table_name:
                visit(ref_table)

        temp_mark.remove(table_name)
        visited.add(table_name)
        sorted_tables.append(table_name)

    for table_name in tables.keys():
        visit(table_name)

    return sorted_tables


def generate_sql(tables):
    sql_statements = []

    sql_statements.append("-- Database schema generated from draw.io diagram")
    sql_statements.append("-- Generated automatically - review before executing\n")

    sorted_table_names = topological_sort(tables)

    for table_name in sorted_table_names:
        table = tables[table_name]
        sql = generate_create_table(table_name, table)
        sql_statements.append(sql)

    return "\n".join(sql_statements)


def generate_create_table(table_name, table):
    sql = [f"CREATE TABLE {table_name} ("]

    column_definitions = []
    for field in table["fields"]:
        field_type = field["type"] if field["type"] else "VARCHAR(255)"
        constraints = field["constraints"]

        if "PRIMARY KEY" in constraints and len(table["pk_fields"]) > 1:
            constraints = constraints.replace("PRIMARY KEY", "").strip()

        col_def = f"    {field['name']} {field_type}"
        if constraints:
            col_def += f" {constraints}"
        column_definitions.append(col_def)

    sql.append(",\n".join(column_definitions))

    if table["pk_fields"]:
        pk_cols = ", ".join(table["pk_fields"])
        sql.append(f",\n    PRIMARY KEY ({pk_cols})")

    for fk_field, ref_table, ref_column in table["fk_relations"]:
        fk_constraint = (
            f"    FOREIGN KEY ({fk_field}) REFERENCES {ref_table}({ref_column})"
        )
        sql.append(f",\n{fk_constraint}")

    sql.append("\n);\n")

    return "\n".join(sql)


def main():
    parser = argparse.ArgumentParser(
        description="Generate SQL CREATE statements from draw.io diagram XML",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate SQL from diagram
  python3 generate_sql_from_drawio.py -i diagram.xml -o schema.sql

  # With relative paths
  python3 generate_sql_from_drawio.py -i ../model/MyDiagram.xml -o ../db/create.sql
        """,
    )

    parser.add_argument(
        "-i",
        "--input",
        dest="input_xml",
        required=True,
        help="Input draw.io XML file",
    )

    parser.add_argument(
        "-o",
        "--output",
        dest="output_sql",
        required=True,
        help="Output SQL file",
    )

    args = parser.parse_args()

    xml_path = args.input_xml
    output_path = args.output_sql

    print(f"Parsing draw.io XML from: {xml_path}")

    if not os.path.exists(xml_path):
        print(f"Error: XML file not found at {xml_path}")
        sys.exit(1)

    try:
        tables = parse_drawio_xml(xml_path)
        print(f"Found {len(tables)} tables:")
        for table_name in tables.keys():
            print(f"  - {table_name}")

        print("\nGenerating SQL...")
        sql = generate_sql(tables)

        output_dir = os.path.dirname(output_path)
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)

        with open(output_path, "w") as f:
            f.write(sql)

        print(f"\nSQL schema written to: {output_path}")
        print(f"Total SQL length: {len(sql)} characters")

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

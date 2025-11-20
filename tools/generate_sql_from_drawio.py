from __future__ import annotations

import argparse
import html
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Optional


class Cardinality(Enum):
    ONE = "one"
    MANY = "many"


class RelationType(Enum):
    ONE_TO_ONE = "one_to_one"
    ONE_TO_MANY = "one_to_many"
    MANY_TO_ONE = "many_to_one"
    MANY_TO_MANY = "many_to_many"


CARDINALITY_MAP: dict[str, Cardinality] = {
    "ERone": Cardinality.ONE,
    "ERmandOne": Cardinality.ONE,
    "ERzeroToOne": Cardinality.ONE,
    "ERmany": Cardinality.MANY,
    "ERoneToMany": Cardinality.MANY,
    "ERzeroToMany": Cardinality.MANY,
}

FIELD_REGEX = re.compile(
    r"^(?P<name>\w+)\s*:\s*(?P<type>[\w()]+)\s*(?P<constraints>.*)"
)

BR_TAG_PATTERN = re.compile(r"<br\s*/?>", re.IGNORECASE)
DIV_TAG_PATTERN = re.compile(r"</?div>", re.IGNORECASE)
WHITESPACE_PATTERN = re.compile(r"\s+")
FK_PATTERN = re.compile(r"fk\s+(\w+)\s*\(\s*(\w+)\s*\)", re.IGNORECASE)


@dataclass
class Field:
    name: str
    type: str
    constraints: str = ""
    is_fk: bool = False
    is_unique: bool = False


@dataclass
class ForeignKey:
    field_names: tuple[str, ...]  # Support composite FKs
    ref_table: str
    ref_columns: tuple[str, ...]  # Support composite FKs

    def __hash__(self) -> int:
        return hash((self.field_names, self.ref_table, self.ref_columns))

    @property
    def field_name(self) -> str:
        """Backward compatibility: return first field name for single-column FKs."""
        return self.field_names[0] if self.field_names else ""

    @property
    def ref_column(self) -> str:
        """Backward compatibility: return first ref column for single-column FKs."""
        return self.ref_columns[0] if self.ref_columns else ""

    @property
    def is_composite(self) -> bool:
        """Check if this is a composite FK."""
        return len(self.field_names) > 1


@dataclass
class Table:
    name: str
    cell_id: Optional[str] = None
    fields: list[Field] = field(default_factory=list)
    pk_fields: list[str] = field(default_factory=list)
    fk_relations: set[ForeignKey] = field(default_factory=set)

    def get_field_map(self) -> dict[str, Field]:
        return {fld.name: fld for fld in self.fields}

    def has_fk(self, ref_table: str, ref_columns: tuple[str, ...] | str) -> bool:
        """Check if FK to ref_table with specific columns exists."""
        if isinstance(ref_columns, str):
            ref_columns = (ref_columns,)
        return any(
            fk.ref_table == ref_table and fk.ref_columns == ref_columns
            for fk in self.fk_relations
        )

    def has_fk_to_table(self, ref_table: str) -> bool:
        """Check if any FK to ref_table exists."""
        return any(fk.ref_table == ref_table for fk in self.fk_relations)


@dataclass
class CellData:

    value: str
    style: str
    parent: str
    vertex: str
    edge: str
    source: str
    target: str
    children: list[str] = field(default_factory=list)


Multiplicity = tuple[int, int | str]

ARROW_MULTIPLICITY_MAP: dict[str, Multiplicity] = {
    "ERone": (1, 1),
    "ERmandOne": (1, 1),
    "ERzeroToOne": (0, 1),
    "ERmany": (1, "N"),
    "ERoneToMany": (1, "N"),
    "ERzeroToMany": (0, "N"),
}


def clean_text(text: str | None) -> str:
    if not text:
        return ""
    text = BR_TAG_PATTERN.sub(" ", text)
    text = DIV_TAG_PATTERN.sub(" ", text)
    text = html.unescape(text)
    text = WHITESPACE_PATTERN.sub(" ", text)
    return text.strip()


def is_bold_text(text: str | None, style: str | None) -> bool:
    """Check if text is bold based on HTML tags or style attribute."""
    if not text:
        return False

    # Check for HTML bold tags
    if '<b>' in text or '<strong>' in text or '<B>' in text:
        return True

    # Check for fontStyle in style attribute
    # fontStyle values: 1=bold, 2=italic, 4=underline (can be combined)
    if style and 'fontStyle=' in style:
        import re
        match = re.search(r'fontStyle=(\d+)', style)
        if match:
            font_style = int(match.group(1))
            # Check if bold bit is set (fontStyle & 1)
            return (font_style & 1) == 1

    return False


def is_table_cell(cell_data: CellData) -> bool:

    if cell_data.vertex != "1":
        return False

    style = cell_data.style
    return "shape=table" in style or (
        "rounded=0" in style and "whiteSpace=wrap" in style
    )


def parse_field_line(line: str) -> Optional[Field]:

    if not (match := FIELD_REGEX.match(line)):
        return None

    return Field(
        name=match.group("name"),
        type=match.group("type"),
        constraints=match.group("constraints").strip(),
    )


def process_row(cells: list[tuple[str, str]], table: Table) -> None:
    """Process a table row. cells is a list of (value, style) tuples."""
    if len(cells) < 2:
        return

    pk_fk_marker = clean_text(cells[0][0])
    column_text = clean_text(cells[1][0]) if len(cells) > 1 else ""
    column_style = cells[1][1] if len(cells) > 1 else ""
    data_type_text = clean_text(cells[2][0]) if len(cells) > 2 else ""

    if not column_text:
        return

    field_line = f"{column_text} : {data_type_text}"
    parsed_field = parse_field_line(field_line) or Field(
        name=column_text, type=data_type_text, constraints=""
    )

    constraints_parts = [parsed_field.constraints] if parsed_field.constraints else []

    if "PK" in pk_fk_marker:
        table.pk_fields.append(parsed_field.name)
        constraints_parts.append("PRIMARY KEY")

    if "FK" in pk_fk_marker:
        if fk_match := FK_PATTERN.search(parsed_field.constraints):
            table.fk_relations.add(
                ForeignKey((parsed_field.name,), fk_match.group(1), (fk_match.group(2),))
            )
        parsed_field.is_fk = True

    # Check if column name is bold (indicates UNIQUE)
    if is_bold_text(cells[1][0], column_style):
        parsed_field.is_unique = True
        constraints_parts.append("UNIQUE")

    parsed_field.constraints = " ".join(constraints_parts)
    table.fields.append(parsed_field)


def parse_drawio_xml(xml_path: Path) -> dict[str, Table]:
    tree = ET.parse(xml_path)
    root = tree.getroot()

    tables: dict[str, Table] = {}
    edges: list[CellData] = []
    cell_map: dict[str, CellData] = {}

    for cell in root.iter("mxCell"):
        cell_id = cell.get("id", "")
        cell_data = CellData(
            value=cell.get("value", ""),
            style=cell.get("style", ""),
            parent=cell.get("parent", ""),
            vertex=cell.get("vertex", ""),
            edge=cell.get("edge", ""),
            source=cell.get("source", ""),
            target=cell.get("target", ""),
        )
        cell_map[cell_id] = cell_data

        if cell_data.parent in cell_map:
            cell_map[cell_data.parent].children.append(cell_id)

    for cell_id, cell_data in cell_map.items():
        if cell_data.edge == "1":
            edges.append(cell_data)
        elif is_table_cell(cell_data):
            if not (table_name := clean_text(cell_data.value)):
                continue

            table = Table(name=table_name, cell_id=cell_id)

            for row_id in cell_data.children:
                if (
                    row_data := cell_map.get(row_id)
                ) and "shape=tableRow" in row_data.style:
                    row_cells = [
                        (cell_map[child_id].value, cell_map[child_id].style)
                        for child_id in row_data.children
                        if child_id in cell_map
                    ]
                    process_row(row_cells, table)

            tables[table_name] = table

    process_edges(edges, tables, cell_map)

    return tables


def get_multiplicity_from_arrow(arrow_style: Optional[str]) -> Optional[Multiplicity]:
    return ARROW_MULTIPLICITY_MAP.get(arrow_style.strip()) if arrow_style else None


def extract_arrow_types(style_string: str) -> tuple[Optional[str], Optional[str]]:
    if not style_string:
        return None, None

    style_dict = {}
    for part in style_string.split(";"):
        if "=" in part:
            key, value = part.split("=", 1)
            style_dict[key] = value

    return style_dict.get("startArrow"), style_dict.get("endArrow")


def parse_label_multiplicities(
    label: str,
) -> tuple[Optional[Multiplicity], Optional[Multiplicity]]:
    if not label:
        return None, None

    text = label.replace(" ", "").upper()

    multiplicity_patterns = {
        "1:N": ((1, 1), (0, "N")),
        "N:1": ((0, "N"), (1, 1)),
        "1:1": ((1, 1), (1, 1)),
    }

    for pattern, result in multiplicity_patterns.items():
        if pattern in text:
            return result

    if any(tok in text for tok in ("N:N", "M:M", "M:N", "N:M")):
        return (0, "N"), (0, "N")

    return None, None


def classify_relationship(
    start_mult: Optional[Multiplicity], end_mult: Optional[Multiplicity]
) -> Optional[RelationType]:
    if not start_mult or not end_mult:
        return None

    s_max, e_max = start_mult[1], end_mult[1]

    if s_max == "N" and e_max == "N":
        return RelationType.MANY_TO_MANY
    if s_max == 1 and e_max == "N":
        return RelationType.ONE_TO_MANY
    if s_max == "N" and e_max == 1:
        return RelationType.MANY_TO_ONE
    if s_max == 1 and e_max == 1:
        return RelationType.ONE_TO_ONE

    return None


def find_pk_and_type(tables: dict[str, Table], table_name: str) -> tuple[str, str]:
    table = tables[table_name]
    pk_name = table.pk_fields[0] if table.pk_fields else "id"

    field_map = table.get_field_map()
    pk_type = field_map.get(pk_name).type if pk_name in field_map else "INT"

    return pk_name, pk_type or "INT"


def ensure_fk(
    tables: dict[str, Table],
    child_table: str,
    parent_table: str,
    parent_pks: tuple[str, ...] | str,
    optional: bool = False,
) -> None:
    """Ensure FK exists from child to parent table.

    Supports both single and composite foreign keys.
    parent_pks can be a single column name (str) or tuple of column names.
    """
    if isinstance(parent_pks, str):
        parent_pks = (parent_pks,)

    child_table_data = tables[child_table]
    parent_table_data = tables[parent_table]

    # Check if FK already exists
    if child_table_data.has_fk(parent_table, parent_pks):
        return

    # For composite PKs, check if all the PK columns exist as FK fields in child table
    if len(parent_pks) > 1:
        field_map = child_table_data.get_field_map()
        matching_fields = []

        for pk_col in parent_pks:
            # Look for field with same name or similar name
            if pk_col in field_map and field_map[pk_col].is_fk:
                matching_fields.append(pk_col)

        # If we found all the composite PK columns in the child table, create composite FK
        if len(matching_fields) == len(parent_pks):
            # Mark all fields as used for this FK
            for field_name in matching_fields:
                if not optional and "NOT NULL" not in field_map[field_name].constraints:
                    field_map[field_name].constraints = (
                        field_map[field_name].constraints + " NOT NULL"
                    ).strip()

            child_table_data.fk_relations.add(
                ForeignKey(tuple(matching_fields), parent_table, parent_pks)
            )
            return

    # Single column FK handling
    parent_pk = parent_pks[0]
    field_map = child_table_data.get_field_map()

    # First check if any existing FK field in the child table could be referencing this parent
    # This handles cases where FK fields are already defined in the diagram with non-standard names
    for existing_field_name, existing_field in field_map.items():
        if existing_field.is_fk:
            # Check if this field already has an FK relation
            already_used = any(
                existing_field_name in fk.field_names
                for fk in child_table_data.fk_relations
            )

            if not already_used:
                # Check if the field name suggests it references this parent table
                field_lower = existing_field_name.lower()
                parent_lower = parent_table.lower()
                pk_lower = parent_pk.lower()

                # Match if field contains parent table name or parent PK name
                if parent_lower in field_lower or pk_lower in field_lower:
                    # Use this existing field as the FK
                    if not optional and "NOT NULL" not in existing_field.constraints:
                        existing_field.constraints = (
                            existing_field.constraints + " NOT NULL"
                        ).strip()
                    child_table_data.fk_relations.add(
                        ForeignKey((existing_field_name,), parent_table, (parent_pk,))
                    )
                    return

    candidate_names = [
        parent_table,
        f"{parent_table}_id",
        f"{parent_table}_code",
    ]

    fk_field_name = None
    for name in candidate_names:
        if name in field_map:
            fk_field_name = name
            break

    if not fk_field_name:
        for field_name in field_map:
            base = field_name.removesuffix("_id").removesuffix("_code")
            if base == parent_table:
                fk_field_name = field_name
                break

    if not fk_field_name:
        parent_pk_name, parent_pk_type = find_pk_and_type(tables, parent_table)
        parent_pk = parent_pk_name
        fk_field_name = f"{parent_table}_id"

        if fk_field_name not in field_map:
            new_field = Field(
                name=fk_field_name,
                type=parent_pk_type,
                constraints="" if optional else "NOT NULL",
                is_fk=True,
            )
            child_table_data.fields.append(new_field)
        else:
            field_map[fk_field_name].is_fk = True
    else:
        existing_field = field_map[fk_field_name]
        existing_field.is_fk = True
        if not optional and "NOT NULL" not in existing_field.constraints:
            existing_field.constraints = (
                existing_field.constraints + " NOT NULL"
            ).strip()

    child_table_data.fk_relations.add(
        ForeignKey((fk_field_name,), parent_table, (parent_pk,))
    )


def ensure_join_table(
    tables: dict[str, Table], left_table: str, right_table: str
) -> None:
    a, b = sorted([left_table, right_table])
    join_table_name = f"{a}_{b}_rel"

    if join_table_name not in tables:
        tables[join_table_name] = Table(name=join_table_name)

    join_table = tables[join_table_name]
    field_map = join_table.get_field_map()

    for source_table in (left_table, right_table):
        pk_name, pk_type = find_pk_and_type(tables, source_table)
        fk_name = f"{source_table}_id"

        if fk_name not in field_map:
            join_table.fields.append(
                Field(name=fk_name, type=pk_type, constraints="NOT NULL", is_fk=True)
            )

        join_table.fk_relations.add(ForeignKey((fk_name,), source_table, (pk_name,)))

    if not join_table.pk_fields:
        join_table.pk_fields = [f"{left_table}_id", f"{right_table}_id"]


def find_parent_table(
    cell_id: str, cell_map: dict[str, CellData], cell_to_table: dict[str, str]
) -> Optional[str]:
    current_id: Optional[str] = cell_id
    visited: set[str] = set()

    while current_id and current_id not in visited:
        if current_id in cell_to_table:
            return cell_to_table[current_id]

        visited.add(current_id)
        current_id = cell_map[current_id].parent if current_id in cell_map else None

    return None


def process_edges(
    edges: list[CellData], tables: dict[str, Table], cell_map: dict[str, CellData]
) -> None:
    cell_to_table = {
        table_data.cell_id: table_name
        for table_name, table_data in tables.items()
        if table_data.cell_id
    }

    for edge in edges:
        if not edge.source or not edge.target:
            continue

        source_table = find_parent_table(edge.source, cell_map, cell_to_table)
        target_table = find_parent_table(edge.target, cell_map, cell_to_table)

        if not source_table or not target_table or source_table == target_table:
            continue

        label = clean_text(edge.value) if edge.value else ""
        label_start_mult, label_end_mult = parse_label_multiplicities(label)

        if label_start_mult and label_end_mult:
            start_mult, end_mult = label_start_mult, label_end_mult
        else:
            start_arrow, end_arrow = extract_arrow_types(edge.style or "")
            start_mult = get_multiplicity_from_arrow(start_arrow)
            end_mult = get_multiplicity_from_arrow(end_arrow)

        if not start_mult or not end_mult:
            continue

        rel_type = classify_relationship(start_mult, end_mult)
        if not rel_type:
            continue

        if rel_type == RelationType.MANY_TO_MANY:
            ensure_join_table(tables, source_table, target_table)
            continue

        start_optional = start_mult[0] == 0
        end_optional = end_mult[0] == 0

        if rel_type == RelationType.ONE_TO_MANY:
            parent_table, child_table, child_optional = (
                source_table,
                target_table,
                end_optional,
            )
        elif rel_type == RelationType.MANY_TO_ONE:
            parent_table, child_table, child_optional = (
                target_table,
                source_table,
                start_optional,
            )
        else:
            s_min, e_min = start_mult[0], end_mult[0]

            if s_min == 0 and e_min == 1:
                parent_table, child_table, child_optional = (
                    target_table,
                    source_table,
                    True,
                )
            elif e_min == 0 and s_min == 1:
                parent_table, child_table, child_optional = (
                    source_table,
                    target_table,
                    True,
                )
            else:
                if source_table < target_table:
                    parent_table, child_table, child_optional = (
                        source_table,
                        target_table,
                        end_optional,
                    )
                else:
                    parent_table, child_table, child_optional = (
                        target_table,
                        source_table,
                        start_optional,
                    )

        # Get all PK fields from parent table for composite FK support
        parent_table_data = tables[parent_table]
        parent_pks = tuple(parent_table_data.pk_fields) if parent_table_data.pk_fields else ("id",)
        ensure_fk(tables, child_table, parent_table, parent_pks, child_optional)


def detect_circular_dependencies(tables: dict[str, Table]) -> set[tuple[str, str]]:
    """Detect circular FK dependencies and return set of (table, ref_table) pairs to defer."""
    deferred_fks = set()

    def creates_cycle(start_table: str, target_table: str, visited: set[str]) -> bool:
        """Check if adding FK from start_table to target_table would create a cycle."""
        if target_table == start_table:
            return False  # Self-references are OK
        if target_table in visited:
            return True

        visited = visited | {target_table}

        # Check if target_table has path back to start_table
        if target_table in tables:
            for fk in tables[target_table].fk_relations:
                if fk.ref_table == start_table:
                    return True
                if creates_cycle(start_table, fk.ref_table, visited):
                    return True

        return False

    # Check each FK for cycles
    for table_name, table in tables.items():
        for fk in table.fk_relations:
            if fk.ref_table == table_name:
                continue  # Skip self-references

            if creates_cycle(table_name, fk.ref_table, set()):
                deferred_fks.add((table_name, fk.ref_table))

    return deferred_fks


def topological_sort(tables: dict[str, Table], deferred_fks: set[tuple[str, str]] = None) -> list[str]:
    """Sort tables considering dependencies, optionally ignoring deferred FK relationships."""
    if deferred_fks is None:
        deferred_fks = set()

    sorted_tables: list[str] = []
    visited: set[str] = set()
    temp_mark: set[str] = set()

    def visit(table_name: str) -> None:
        if table_name in visited:
            return
        if table_name in temp_mark:
            # Cycle detected - skip this edge
            return

        temp_mark.add(table_name)

        for fk in tables[table_name].fk_relations:
            if fk.ref_table in tables and fk.ref_table != table_name:
                # Skip deferred FKs when determining sort order
                if (table_name, fk.ref_table) not in deferred_fks:
                    visit(fk.ref_table)

        temp_mark.discard(table_name)
        visited.add(table_name)
        sorted_tables.append(table_name)

    for table_name in tables:
        if table_name not in visited:
            visit(table_name)

    return sorted_tables


def generate_create_table(table: Table, deferred_fks: set[tuple[str, str]] = None) -> str:
    """Generate CREATE TABLE statement, optionally deferring circular FK dependencies.

    Args:
        table: The table to generate SQL for
        deferred_fks: Set of (table_name, ref_table) pairs for FKs to defer
    """
    if deferred_fks is None:
        deferred_fks = set()

    column_defs = []

    for fld in table.fields:
        field_type = fld.type or "VARCHAR(255)"
        constraints = fld.constraints

        if table.pk_fields and "PRIMARY KEY" in constraints:
            constraints = constraints.replace("PRIMARY KEY", "").strip()

        col_def = f"    {fld.name} {field_type}"
        if constraints:
            col_def += f" {constraints}"
        column_defs.append(col_def)

    parts = [
        f"CREATE TABLE {table.name} (",
        ",\n".join(column_defs),
    ]

    # Handle PRIMARY KEY
    if table.pk_fields:
        pk_cols = ", ".join(table.pk_fields)
        parts.append(f",\n    PRIMARY KEY ({pk_cols})")
    else:
        # Auto-detect composite PK for tables without explicit PK
        # Use first NOT NULL column as PK
        potential_pk = [f.name for f in table.fields if "NOT NULL" in f.constraints and not f.is_fk]
        if potential_pk:
            parts.append(f",\n    PRIMARY KEY ({potential_pk[0]})")

    # Add UNIQUE constraints
    unique_fields = [f.name for f in table.fields if f.is_unique and f.name not in table.pk_fields]
    for field_name in unique_fields:
        parts.append(f",\n    UNIQUE ({field_name})")

    # Add foreign keys, skipping deferred ones
    for fk in table.fk_relations:
        # Skip if this FK is deferred due to circular dependency
        if (table.name, fk.ref_table) in deferred_fks:
            continue

        # Handle both single and composite FKs
        fk_cols = ", ".join(fk.field_names)
        ref_cols = ", ".join(fk.ref_columns)

        # Determine ON DELETE action (use CASCADE for most, but check constraints)
        on_delete = "CASCADE"
        # For self-references and certain patterns, use SET NULL
        if fk.ref_table == table.name:
            on_delete = "SET NULL"

        parts.append(
            f",\n    FOREIGN KEY ({fk_cols}) "
            f"REFERENCES {fk.ref_table}({ref_cols}) ON DELETE {on_delete}"
        )

    parts.append("\n);\n")

    return "\n".join(parts)


def validate_schema(tables: dict[str, Table]) -> list[str]:
    errors: list[str] = []

    for table_name, table in tables.items():
        field_map = table.get_field_map()

        for fk in table.fk_relations:
            # Handle composite FKs - validate each column
            for i, fk_field_name in enumerate(fk.field_names):
                ref_col = fk.ref_columns[i] if i < len(fk.ref_columns) else None

                if fk_field_name not in field_map:
                    errors.append(
                        f"Table '{table_name}': Foreign key field '{fk_field_name}' "
                        f"not found in table"
                    )
                    continue

                if fk.ref_table not in tables:
                    errors.append(
                        f"Table '{table_name}': Foreign key '{fk_field_name}' "
                        f"references non-existent table '{fk.ref_table}'"
                    )
                    continue

                ref_table = tables[fk.ref_table]
                ref_field_map = ref_table.get_field_map()

                if ref_col and ref_col not in ref_field_map:
                    errors.append(
                        f"Table '{table_name}': Foreign key '{fk_field_name}' "
                        f"references non-existent column '{ref_col}' "
                        f"in table '{fk.ref_table}'"
                    )
                    continue

                if not ref_col:
                    continue

                fk_field = field_map[fk_field_name]
                ref_field = ref_field_map[ref_col]

                fk_type = (
                    fk_field.type.split("(")[0].strip().upper()
                    if fk_field.type
                    else "VARCHAR"
                )
                ref_type = (
                    ref_field.type.split("(")[0].strip().upper()
                    if ref_field.type
                    else "VARCHAR"
                )

                if fk_type != ref_type:
                    errors.append(
                        f"Table '{table_name}': Type mismatch for foreign key '{fk_field_name}' "
                        f"({fk_field.type or 'VARCHAR'}) -> "
                        f"'{fk.ref_table}.{ref_col}' ({ref_field.type or 'VARCHAR'})"
                    )

    return errors


def generate_sql(tables: dict[str, Table]) -> str:
    """Generate SQL CREATE statements with DROP, indexes, and constraints."""
    statements = [
        "-- Database schema generated from draw.io diagram",
        "-- Generated automatically - review before executing",
        "",
        "-- Drop existing tables (in reverse dependency order)",
    ]

    # Detect circular dependencies
    deferred_fks = detect_circular_dependencies(tables)
    if deferred_fks:
        statements.append(f"-- Note: {len(deferred_fks)} circular FK dependencies detected and deferred")

    # Sort tables, ignoring deferred FK edges
    sorted_tables = topological_sort(tables, deferred_fks)
    for table_name in reversed(sorted_tables):
        statements.append(f"DROP TABLE IF EXISTS {table_name} CASCADE;")

    statements.append("")

    # Generate CREATE TABLE statements (with deferred FKs excluded)
    for table_name in sorted_tables:
        statements.append(generate_create_table(tables[table_name], deferred_fks))

    # Add deferred FK constraints using ALTER TABLE
    if deferred_fks:
        statements.append("-- Add deferred foreign key constraints to resolve circular dependencies")
        for table_name, ref_table in sorted(deferred_fks):
            table = tables[table_name]
            # Find the FK(s) that reference ref_table
            for fk in table.fk_relations:
                if fk.ref_table == ref_table:
                    fk_cols = ", ".join(fk.field_names)
                    ref_cols = ", ".join(fk.ref_columns)
                    constraint_name = f"fk_{table_name}_{ref_table}"

                    # Determine ON DELETE action
                    on_delete = "RESTRICT"  # Use RESTRICT for circular deps to prevent cascading deletes

                    statements.append(
                        f"ALTER TABLE {table_name} ADD CONSTRAINT {constraint_name} "
                        f"FOREIGN KEY ({fk_cols}) REFERENCES {ref_table}({ref_cols}) "
                        f"ON DELETE {on_delete};"
                    )
        statements.append("")

    # Generate indexes for foreign keys
    statements.append("-- Indexes for foreign key columns")
    for table_name in sorted_tables:
        table = tables[table_name]
        for fk in table.fk_relations:
            # Handle both single and composite FKs in index names and columns
            fk_fields_joined = "_".join(fk.field_names)
            fk_cols = ", ".join(fk.field_names)
            index_name = f"idx_{table_name}_{fk_fields_joined}"
            statements.append(
                f"CREATE INDEX {index_name} ON {table_name}({fk_cols});"
            )

    return "\n".join(statements)


def main() -> None:
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

    xml_path = Path(args.input_xml)
    output_path = Path(args.output_sql)

    print(f"Parsing draw.io XML from: {xml_path}")

    if not xml_path.exists():
        print(f"Error: XML file not found at {xml_path}")
        sys.exit(1)

    try:
        tables = parse_drawio_xml(xml_path)
        print(f"Found {len(tables)} tables:")
        for table_name in tables:
            print(f"  - {table_name}")

        # Validate schema
        print("\nValidating schema...")
        validation_errors = validate_schema(tables)

        if validation_errors:
            print(f"\nFound {len(validation_errors)} validation error(s):\n")
            for error in validation_errors:
                print(f"  - {error}")
            print(
                "\nPlease fix these errors in your draw.io diagram before generating SQL."
            )
            sys.exit(1)

        print("Schema validation passed")

        print("\nGenerating SQL...")
        sql = generate_sql(tables)

        output_path.parent.mkdir(parents=True, exist_ok=True)

        output_path.write_text(sql)

        print(f"\nSQL schema written to: {output_path}")
        print(f"Total SQL length: {len(sql)} characters")

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

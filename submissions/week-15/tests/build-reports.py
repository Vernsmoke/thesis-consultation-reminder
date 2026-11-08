from __future__ import annotations

import re
from pathlib import Path

from docx import Document
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[3]
REPORTS = ROOT / "submissions" / "week-15" / "reports"
REPORT_FILES = [
    "activity-1-traceability-matrix.md",
    "activity-2-hardening-sprint.md",
    "IA6-integration-testing-hardening.md",
    "reflection.md",
]

INK = RGBColor(0, 0, 0)
MUTED = RGBColor(75, 75, 75)
HEADER_FILL = "17365D"
ALT_FILL = "EDF3F8"
BORDER = "D9D9D9"


def shade(cell, fill: str) -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_margins(cell, top=90, start=110, bottom=90, end=110) -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for tag, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{tag}"))
        if node is None:
            node = OxmlElement(f"w:{tag}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_table_borders(table) -> None:
    tbl_pr = table._tbl.tblPr
    borders = tbl_pr.find(qn("w:tblBorders"))
    if borders is None:
        borders = OxmlElement("w:tblBorders")
        tbl_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        node = borders.find(qn(f"w:{edge}"))
        if node is None:
            node = OxmlElement(f"w:{edge}")
            borders.append(node)
        node.set(qn("w:val"), "single")
        node.set(qn("w:sz"), "4")
        node.set(qn("w:color"), BORDER)


def set_repeat_header(row) -> None:
    tr_pr = row._tr.get_or_add_trPr()
    marker = OxmlElement("w:tblHeader")
    marker.set(qn("w:val"), "true")
    tr_pr.append(marker)


def add_page_field(paragraph) -> None:
    run = paragraph.add_run("Page ")
    begin = OxmlElement("w:fldChar")
    begin.set(qn("w:fldCharType"), "begin")
    instruction = OxmlElement("w:instrText")
    instruction.set(qn("xml:space"), "preserve")
    instruction.text = " PAGE "
    separate = OxmlElement("w:fldChar")
    separate.set(qn("w:fldCharType"), "separate")
    value = OxmlElement("w:t")
    value.text = "1"
    end = OxmlElement("w:fldChar")
    end.set(qn("w:fldCharType"), "end")
    run._r.extend([begin, instruction, separate, value, end])


def remove_paragraph_border(paragraph_or_style) -> None:
    """Remove theme-provided paragraph borders from report titles."""
    paragraph_properties = paragraph_or_style._element.get_or_add_pPr()
    borders = paragraph_properties.find(qn("w:pBdr"))
    if borders is not None:
        paragraph_properties.remove(borders)


def configure(document: Document, short_title: str) -> None:
    section = document.sections[0]
    section.page_height = Inches(11.7)
    section.page_width = Inches(8.3)
    section.top_margin = Inches(0.72)
    section.bottom_margin = Inches(0.72)
    section.left_margin = Inches(0.78)
    section.right_margin = Inches(0.78)

    normal = document.styles["Normal"]
    normal.font.name = "Aptos"
    normal.font.size = Pt(9.5)
    normal.font.color.rgb = INK
    normal.paragraph_format.space_after = Pt(6)
    normal.paragraph_format.line_spacing = 1.08

    for name, size, before, after in (
        ("Title", 22, 0, 12),
        ("Heading 1", 14.5, 12, 5),
        ("Heading 2", 11.5, 9, 4),
        ("Heading 3", 10, 7, 3),
    ):
        style = document.styles[name]
        style.font.name = "Aptos Display"
        style.font.size = Pt(size)
        style.font.bold = True
        style.font.color.rgb = INK
        style.paragraph_format.keep_with_next = True
        style.paragraph_format.space_before = Pt(before)
        style.paragraph_format.space_after = Pt(after)
        if name == "Title":
            remove_paragraph_border(style)

    header = section.header.paragraphs[0]
    header.text = "PFEBSIT 002   PROJECT 29   WEEK 15"
    header.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    for run in header.runs:
        run.font.name = "Aptos"
        run.font.size = Pt(7.5)
        run.font.bold = True
        run.font.color.rgb = MUTED

    footer = section.footer.paragraphs[0]
    footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
    footer.add_run(f"Laurence Matthew B Manuel   BSIT 3A   {short_title}   ")
    add_page_field(footer)
    for run in footer.runs:
        run.font.name = "Aptos"
        run.font.size = Pt(7.2)
        run.font.color.rgb = MUTED


def add_inline(paragraph, text: str) -> None:
    pattern = re.compile(r"(`[^`]+`|\*\*[^*]+\*\*|\*[^*]+\*)")
    position = 0
    for match in pattern.finditer(text):
        if match.start() > position:
            paragraph.add_run(text[position:match.start()])
        token = match.group(0)
        if token.startswith("`"):
            run = paragraph.add_run(token[1:-1])
            run.font.name = "Consolas"
            run.font.size = Pt(8.2)
        elif token.startswith("**"):
            paragraph.add_run(token[2:-2]).bold = True
        else:
            paragraph.add_run(token[1:-1]).italic = True
        position = match.end()
    if position < len(text):
        paragraph.add_run(text[position:])


def add_table(document: Document, rows: list[list[str]]) -> None:
    columns = max(len(row) for row in rows)
    table = document.add_table(rows=len(rows), cols=columns)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = True
    set_table_borders(table)
    for row_index, row in enumerate(rows):
        for column_index in range(columns):
            cell = table.cell(row_index, column_index)
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            set_cell_margins(cell)
            text = row[column_index].strip() if column_index < len(row) else ""
            paragraph = cell.paragraphs[0]
            paragraph.paragraph_format.space_after = Pt(0)
            add_inline(paragraph, text)
            for run in paragraph.runs:
                run.font.name = "Aptos"
                run.font.size = Pt(7.5)
                if row_index == 0:
                    run.font.bold = True
                    run.font.color.rgb = RGBColor(255, 255, 255)
            shade(cell, HEADER_FILL if row_index == 0 else (ALT_FILL if row_index % 2 == 0 else "FFFFFF"))
        if row_index == 0:
            set_repeat_header(table.rows[0])
    document.add_paragraph().paragraph_format.space_after = Pt(0)


def parse_markdown(document: Document, source: str) -> None:
    lines = source.splitlines()
    title_done = False
    index = 0
    while index < len(lines):
        line = lines[index].rstrip()
        if not line.strip():
            index += 1
            continue
        if line.startswith("|") and index + 1 < len(lines) and re.match(r"^\s*\|?\s*:?-+", lines[index + 1]):
            rows = [[cell.strip() for cell in line.strip().strip("|").split("|")]]
            index += 2
            while index < len(lines) and lines[index].lstrip().startswith("|"):
                rows.append([cell.strip() for cell in lines[index].strip().strip("|").split("|")])
                index += 1
            add_table(document, rows)
            continue
        if line.startswith("# "):
            paragraph = document.add_paragraph(style="Title" if not title_done else "Heading 1")
            if not title_done:
                remove_paragraph_border(paragraph)
            add_inline(paragraph, line[2:].strip())
            title_done = True
            index += 1
            continue
        if line.startswith("## "):
            document.add_heading(line[3:].strip(), level=1)
            index += 1
            continue
        if line.startswith("### "):
            document.add_heading(line[4:].strip(), level=2)
            index += 1
            continue
        if line.startswith("- "):
            paragraph = document.add_paragraph(style="List Bullet")
            paragraph.paragraph_format.space_after = Pt(2)
            add_inline(paragraph, line[2:].strip())
            index += 1
            continue
        if re.match(r"^\d+\. ", line):
            paragraph = document.add_paragraph(style="List Number")
            paragraph.paragraph_format.space_after = Pt(2)
            add_inline(paragraph, re.sub(r"^\d+\. ", "", line).strip())
            index += 1
            continue
        paragraph_lines = [line]
        index += 1
        while index < len(lines):
            candidate = lines[index].rstrip()
            if not candidate.strip():
                index += 1
                break
            if candidate.startswith(("#", "|", "- ")) or re.match(r"^\d+\. ", candidate):
                break
            paragraph_lines.append(candidate)
            index += 1
        paragraph = document.add_paragraph()
        add_inline(paragraph, " ".join(part.strip().rstrip("  ") for part in paragraph_lines))


def build(markdown_path: Path) -> Path:
    document = Document()
    short_title = markdown_path.stem.replace("-", " ").upper()
    configure(document, short_title)
    parse_markdown(document, markdown_path.read_text(encoding="utf-8"))
    properties = document.core_properties
    properties.title = short_title
    properties.subject = "PFEBSIT 002 Project 29 Week 15"
    properties.author = "Laurence Matthew B Manuel"
    properties.keywords = "Week 15, IA6, integration testing, security hardening"
    properties.comments = "Prepared from verified Week 15 project evidence."
    output = markdown_path.with_suffix(".docx")
    document.save(output)
    return output


if __name__ == "__main__":
    for report in REPORT_FILES:
        print(build(REPORTS / report))

from __future__ import annotations

import re
from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[3]
REPORTS = ROOT / "submissions" / "week-14" / "reports"

REPORT_FILES = [
    "activity-1-cryptography-cases.md",
    "activity-2-secure-exchange-review.md",
    "SA8-secure-integration-architecture.md",
    "IA5-secure-data-exchange-build.md",
    "reflection.md",
]

ACCENT = "0F5960"
LIGHT = "E8F2F2"
MID = "B8D3D4"
INK = RGBColor(20, 28, 31)
MUTED = RGBColor(78, 91, 95)


def shade(cell, fill: str) -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_margins(cell, top=80, start=100, bottom=80, end=100) -> None:
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
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


def set_repeat_table_header(row) -> None:
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def keep_with_next(paragraph) -> None:
    paragraph.paragraph_format.keep_with_next = True


def add_inline(paragraph, text: str) -> None:
    pattern = re.compile(r"(`[^`]+`|\*\*[^*]+\*\*|\*[^*]+\*)")
    pos = 0
    for match in pattern.finditer(text):
        if match.start() > pos:
            paragraph.add_run(text[pos:match.start()])
        token = match.group(0)
        if token.startswith("`"):
            run = paragraph.add_run(token[1:-1])
            run.font.name = "Consolas"
            run.font.size = Pt(8.5)
            run.font.color.rgb = RGBColor(38, 66, 70)
        elif token.startswith("**"):
            paragraph.add_run(token[2:-2]).bold = True
        else:
            paragraph.add_run(token[1:-1]).italic = True
        pos = match.end()
    if pos < len(text):
        paragraph.add_run(text[pos:])


def configure(document: Document, short_title: str) -> None:
    section = document.sections[0]
    section.page_height = Inches(11.7)
    section.page_width = Inches(8.3)
    section.top_margin = Inches(0.72)
    section.bottom_margin = Inches(0.7)
    section.left_margin = Inches(0.78)
    section.right_margin = Inches(0.72)

    styles = document.styles
    normal = styles["Normal"]
    normal.font.name = "Aptos"
    normal.font.size = Pt(9.5)
    normal.font.color.rgb = INK
    normal.paragraph_format.space_after = Pt(5)
    normal.paragraph_format.line_spacing = 1.08

    for name, size, color in (
        ("Title", 23, RGBColor(15, 89, 96)),
        ("Heading 1", 15, RGBColor(15, 89, 96)),
        ("Heading 2", 11.5, RGBColor(28, 66, 70)),
        ("Heading 3", 10, RGBColor(40, 58, 61)),
    ):
        style = styles[name]
        style.font.name = "Aptos Display"
        style.font.size = Pt(size)
        style.font.bold = True
        style.font.color.rgb = color
        style.paragraph_format.keep_with_next = True
        style.paragraph_format.space_before = Pt(10 if name != "Title" else 0)
        style.paragraph_format.space_after = Pt(4)

    header = section.header
    header.is_linked_to_previous = False
    p = header.paragraphs[0]
    p.text = "PFEBSIT 002  /  PROJECT 29  /  WEEK 14"
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    for run in p.runs:
        run.font.name = "Aptos"
        run.font.size = Pt(7.5)
        run.font.bold = True
        run.font.color.rgb = MUTED

    footer = section.footer
    p = footer.paragraphs[0]
    p.text = f"Laurence Matthew B Manuel  •  BSIT 3A  •  {short_title}"
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    for run in p.runs:
        run.font.name = "Aptos"
        run.font.size = Pt(7.5)
        run.font.color.rgb = MUTED


def add_title(document: Document, title: str) -> None:
    p = document.add_paragraph(style="Title")
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.add_run(title)
    line = document.add_paragraph()
    line.paragraph_format.space_after = Pt(12)
    p_pr = line._p.get_or_add_pPr()
    borders = OxmlElement("w:pBdr")
    bottom = OxmlElement("w:bottom")
    bottom.set(qn("w:val"), "single")
    bottom.set(qn("w:sz"), "18")
    bottom.set(qn("w:space"), "1")
    bottom.set(qn("w:color"), ACCENT)
    borders.append(bottom)
    p_pr.append(borders)


def add_table(document: Document, rows: list[list[str]]) -> None:
    if not rows:
        return
    cols = max(len(row) for row in rows)
    table = document.add_table(rows=len(rows), cols=cols)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = True
    for r_idx, row in enumerate(rows):
        for c_idx in range(cols):
            cell = table.cell(r_idx, c_idx)
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            set_cell_margins(cell)
            text = row[c_idx].strip() if c_idx < len(row) else ""
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            add_inline(p, text)
            for run in p.runs:
                run.font.size = Pt(7.7)
                if r_idx == 0:
                    run.font.bold = True
                    run.font.color.rgb = RGBColor(255, 255, 255)
            shade(cell, ACCENT if r_idx == 0 else ("F7FAFA" if r_idx % 2 else LIGHT))
        if r_idx == 0:
            set_repeat_table_header(table.rows[0])
    document.add_paragraph().paragraph_format.space_after = Pt(0)


def parse_markdown(document: Document, source: str) -> None:
    lines = source.splitlines()
    title_done = False
    i = 0
    in_code = False
    code_lines: list[str] = []
    while i < len(lines):
        raw = lines[i]
        line = raw.rstrip()
        if line.startswith("```"):
            if in_code:
                p = document.add_paragraph()
                p.style = document.styles["Normal"]
                p.paragraph_format.left_indent = Inches(0.18)
                p.paragraph_format.right_indent = Inches(0.18)
                p.paragraph_format.space_after = Pt(6)
                run = p.add_run("\n".join(code_lines))
                run.font.name = "Consolas"
                run.font.size = Pt(7.5)
                shade_dummy = OxmlElement("w:shd")
                shade_dummy.set(qn("w:fill"), "F1F5F5")
                p._p.get_or_add_pPr().append(shade_dummy)
                code_lines = []
                in_code = False
            else:
                in_code = True
            i += 1
            continue
        if in_code:
            code_lines.append(line)
            i += 1
            continue
        if not line.strip():
            i += 1
            continue
        if line.startswith("|") and i + 1 < len(lines) and re.match(r"^\s*\|?\s*:?-+", lines[i + 1]):
            rows = []
            header = [c.strip() for c in line.strip().strip("|").split("|")]
            rows.append(header)
            i += 2
            while i < len(lines) and lines[i].lstrip().startswith("|"):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")])
                i += 1
            add_table(document, rows)
            continue
        if line.startswith("# "):
            if not title_done:
                add_title(document, line[2:].strip())
                title_done = True
            else:
                document.add_heading(line[2:].strip(), level=1)
            i += 1
            continue
        if line.startswith("## "):
            document.add_heading(line[3:].strip(), level=1)
            i += 1
            continue
        if line.startswith("### "):
            document.add_heading(line[4:].strip(), level=2)
            i += 1
            continue
        if line.startswith("#### "):
            document.add_heading(line[5:].strip(), level=3)
            i += 1
            continue
        if re.match(r"^- ", line):
            p = document.add_paragraph(style="List Bullet")
            p.paragraph_format.space_after = Pt(2)
            add_inline(p, line[2:].strip())
            i += 1
            continue
        if re.match(r"^\d+\. ", line):
            p = document.add_paragraph(style="List Number")
            p.paragraph_format.space_after = Pt(2)
            add_inline(p, re.sub(r"^\d+\. ", "", line).strip())
            i += 1
            continue
        paragraph_lines = [line]
        i += 1
        while i < len(lines):
            candidate = lines[i].rstrip()
            if not candidate.strip():
                i += 1
                break
            if candidate.startswith(("#", "|", "```", "- ")) or re.match(r"^\d+\. ", candidate):
                break
            paragraph_lines.append(candidate)
            i += 1
        p = document.add_paragraph()
        add_inline(p, " ".join(x.strip().rstrip("  ") for x in paragraph_lines))


def build(md_path: Path) -> Path:
    document = Document()
    short_title = md_path.stem.replace("-", " ").upper()
    configure(document, short_title)
    parse_markdown(document, md_path.read_text(encoding="utf-8"))
    core = document.core_properties
    core.title = short_title
    core.subject = "PFEBSIT 002 Project 29 Week 14"
    core.author = "Laurence Matthew B Manuel"
    core.keywords = "Week 14, SA8, IA5, secure data exchange, authenticated encryption"
    core.comments = "Prepared from verified Week 14 project evidence."
    out = md_path.with_suffix(".docx")
    document.save(out)
    return out


if __name__ == "__main__":
    for name in REPORT_FILES:
        print(build(REPORTS / name))

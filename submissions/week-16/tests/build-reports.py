from __future__ import annotations

import importlib.util
from pathlib import Path

from docx import Document


ROOT = Path(__file__).resolve().parents[3]
REPORTS = ROOT / "submissions" / "week-16" / "reports"
FILES = [
    "activity-1-workload-models.md",
    "activity-2-deployment-review.md",
    "week-16-deployment-evaluation.md",
    "reflection-preparation.md",
]

spec = importlib.util.spec_from_file_location(
    "week15_builder", ROOT / "submissions" / "week-15" / "tests" / "build-reports.py"
)
builder = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(builder)


def build(name: str) -> Path:
    output = builder.build(REPORTS / name)
    document = Document(output)
    document.sections[0].header.paragraphs[0].text = "PFEBSIT 002   PROJECT 29   WEEK 16"
    properties = document.core_properties
    properties.subject = "PFEBSIT 002 Project 29 Week 16"
    properties.keywords = "Week 16, performance, reliability, deployment evaluation"
    properties.comments = "Prepared from verified Week 16 project evidence."
    document.save(output)
    return output


if __name__ == "__main__":
    for item in FILES:
        print(build(item))

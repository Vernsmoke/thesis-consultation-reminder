# Project Status

## Project and current milestone

- Student: Laurence Matthew B Manuel
- Section: BSIT 3A
- Project: Project 29, Thesis Consultation Reminder System
- Workspace: `C:/Users/Laure/Documents/ChatGPT/IPT`
- Current authorized milestone: Week 15, IA6 Integration Testing and Security Hardening
- Work/evidence date: 2026-11-08 Asia/Manila; no evidence was backdated
- Required stack: Flutter Web, Laravel API, XAMPP MariaDB/MySQL-compatible database

## Confirmed Git state

- Branch: `master`; confirmed Week 15 release commit: `134077c9a7ef13dd607c0bc763c80989144fe9bb`.
- Week 14 annotated tag `v2.0.0` remains at `82f005afcb8e9ec94b83299aeb72f0d210a5a2bd`; Week 15 does not rewrite it.
- `origin` is configured as `https://github.com/Vernsmoke/thesis-consultation-reminder.git`.
- Five reviewed Week 15 commits were created under the user's explicit authorization. `master` and annotated tag `v3.0.0` were pushed and verified with `git ls-remote`; the tag resolves to release commit `134077c9a7ef13dd607c0bc763c80989144fe9bb`.
- Reviewed exact-path commands remain recorded in `docs/week-15-git-commands.ps1`; future-week prompts and temporary QA folders were excluded.

## Week 15 implementation completed

- Added validated consultation pagination (`page` 1–10000, `per_page` 1–100) with `total` and `has_more`, plus a Flutter notice when more records exist.
- Moved secure-envelope receiver role/recipient rejection ahead of cryptographic opening while retaining authenticated recipient metadata inside the envelope contract.
- Added default-deny/frame-deny CSP, Permissions Policy, one-year HSTS, and retained no-store/nosniff/no-referrer response controls.
- Made Flutter timeout guidance idempotency-aware and classified malformed success responses as safe 502 protocol failures rather than network outages.
- Aligned Flutter email/password limits with the server without reintroducing the discovered short-viewport layout regression.

## Verification and evidence

- Initial targeted run preserved five real failures: pagination, early authorization, CSP, non-idempotent timeout guidance, and malformed-response classification. All five original tests pass after the fixes.
- Laravel regression: 24 tests, 227 assertions, all passing. Flutter regression: 22 tests, all passing. Flutter analysis, Laravel Pint, and release web build pass.
- Live controlled HTTPS: 14/14 expected outcomes passed, covering normal, duplicate replay/conflict, invalid, maximum boundary, unauthorized, forbidden, not-found, pagination/bounds, early authorization, headers, unavailable dependency, and recovery.
- Composer audit reports no advisories. The final generated-secret scan covered 244 candidate text files and found zero generated-secret/private-key matches; protected paths remain ignored.
- A first full Flutter rerun exposed a genuine short-viewport login regression caused by visible counters. It was preserved, corrected while retaining validators, and the full suite reran successfully.
- Actual Edge and VS Code evidence APP-01–04 and SRC-01–02 was captured 2026-11-08 21:45–21:48 +08:00 with fictional data and indexed SHA-256 hashes.
- Four DOCX reports and matching PDFs were rendered through LibreOffice. All seven A4 pages were visually inspected; accessibility audits report zero high, medium, or low findings.

## Submission artifacts

- Test strategy and 25-row traceability matrix; exported ten-request Postman collection and deterministic PowerShell equivalent; controlled fixtures; JSON/JUnit results and sanitized logs.
- Initial failure, defect, failure-injection/recovery, hardening backlog, before/after, regression, and remaining-risk records.
- Activity 1, Activity 2, IA6, and evidence-grounded reflection in Markdown, verified DOCX, and PDF.
- Editable Mermaid, structural JSON, and SVG test-architecture diagram.
- Evidence index, exhaustive Week 15 requirement checklist, submission contents, and working-tree source manifest.

## Pending external or user actions

1. Apply any instructor-prescribed template or AI acknowledgment wording and complete instructor marking/oral assessment. None was supplied or invented.
2. Remove the controlled local CA from the user trust store when the local evidence environment is no longer needed.

## Next action

Week 15 technical work, documents, Git release, and source provenance are complete for the controlled local scope. Remain on Week 15 unless the user explicitly requests Week 16. Do not refresh earlier submission evidence with Week 15 output.

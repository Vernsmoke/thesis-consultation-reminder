# Week 13 evidence index

All execution/capture dates are actual 2026-11-08 Asia/Manila. Source is an uncommitted Week 13 working tree, not a confirmed v1.0.0 release. `tests/source-manifest.json` identifies final source with SHA-256. Earlier experiment evidence predates final presentation/formatting changes; behavior is tied to its recorded working-tree phase, not falsely assigned a later commit. Final regression verifies the final source.

| Evidence ID | Artifact | Scenario result and limits |
|---|---|---|
| ENV-01 | logs/environment.txt | Actual installed runtime versions, execution timezone and Git state |
| REQ-01 | SUBMISSION_CHECKLIST.md | Original DOCX-derived topics, procedures, activities, assessment, rubric/reflection and P29 map |
| API-01 | tests/http-results.json; tests/Invoke-Week13Api.ps1 | 22 actual loopback HTTP checks, sanitized requests/responses, per-case timestamps/status/latency/correlation; login token/password omitted |
| TEST-01 | tests/phpunit-results.xml; logs/backend-tests.txt | 15 tests / 131 assertions pass; 13 domain tests plus two scaffold tests. Due-clock travel is a labeled test mechanism, not evidence backdating |
| TEST-02 | logs/flutter-tests.txt; frontend/test/ | 15 tests pass: signed-in and login widths, form validation, loading/empty/HTTP/network/timeout feedback. Mock API widget tests, not browser screenshots |
| BUILD-01 | logs/flutter-analysis.txt; logs/flutter-build.txt | Final analysis/build outputs; compiled web target, no claim of observed browser execution |
| REL-01 | logs/controlled-delivery.json | Captured 2026-11-08T18:09:45+08:00; 190.52 real seconds; success 1 attempt; transient 2; permanent manual_review 1; persistent timeout manual_review 3; two receipts, seven attempts, no pending events |
| AUTO-01 | logs/four-automation-triggers.json; logs/four-automation-command.txt | Actual 18:16:53 Manila run: all four automation kinds; repeated scans stayed at nine total outbox events; five due deliveries in 31.14ms; no pending, two previously retained manual-review events. Small-fixture timing, not capacity benchmark |
| AUTO-02 | logs/schedule-list.txt; logs/schedule-run.txt | Minute schedule registered; actual schedule:run executed consultations:tick successfully; continuous schedule:work remains operator task |
| FAIL-01 | logs/initial-verification.txt; logs/flutter-expanded-initial-failure.txt | Retained fixture/compile failures, diagnosis and corrections; final logs are reruns |
| SEC-01 | logs/composer-audit.json; tests/artifact-checks.json | Composer advisories/abandoned empty at audit time; exact local secret exclusion and file checks, not a complete security audit |
| DIAG-01 | diagrams/workflow.json/.mmd/.svg | Workflow boundary and human decisions |
| DIAG-02 | diagrams/dataflow.json/.mmd/.svg | Trust boundaries, private config, safe logs and manual handling |
| DIAG-03 | diagrams/screenflow.json/.mmd/.svg | Flutter navigation and feedback |
| DIAG-04 | diagrams/delivery-sequence.json/.mmd/.svg | Transactional delivery, alternative failure and manual handling |
| DIAG-QA | logs/diagram-validation.txt | Canonical static validation, structural previews and custom vector exports; final SVG exports visually reviewed after rasterization. No Mermaid host parity claim |
| DOC-01 | reports/SA7-automation-report.pdf/.docx | Three-page case, evidence, maintainability and residual risks |
| DOC-02 | reports/activity-1-pattern-selection.pdf/.docx | Three comparative workflows and one-page interpretation |
| DOC-03 | reports/activity-2-failure-injection.pdf/.docx | Failure experiment and one-page interpretation |
| DOC-04 | reports/reflection-preparation.pdf/.docx | Complete evidence-based reflection draft; student must review, reproduce the cited behavior and revise unsupported personal claims before submission |
| DOC-QA | logs/docx-render-attempt.txt; logs/docx-render-final.txt; tmp/docx-qa-final/ and tmp/pdf-qa-final/ (local QA output) | Initial DOCX rendering failed while LibreOffice was unavailable. Final four DOCX files rendered successfully; the nine current pages were visually inspected after correcting title, heading spacing and reflection page balance. Matching PDFs were converted from the final DOCX files and all nine pages were rendered and checked. The final PDF path replaced a fragile independent layout after QA exposed inconsistent font rendering |
| SRC-01 | screenshots/source/SRC-01-laravel-automation.png | Actual VS Code capture at 2026-11-08T19:21:33+08:00 from the exact working tree; Laravel idempotent outbox enqueue and reminder/missed/deadline scan logic; SHA-256 `92eb4dc79a5e4607ac2161ad402fa835d0634b9b042e7bfccc083ed3f383d8ad` |
| SRC-02 | screenshots/source/SRC-02-flutter-follow-up.png | Actual VS Code capture at 2026-11-08T19:22:18+08:00 from the exact working tree; Flutter consultation status, action-item and follow-up UI source; SHA-256 `463d3f43441bc114c553112aca6678c2de915da755edf903bf1fd5e6f814eec4` |
| APP pending | screenshots/PENDING_CAPTURES.md | Flutter local origin remains blocked by saved permission/managed policy. Specific pending application views listed; no fabricated screenshots or alternate-browser workaround |
| SOURCE-01 | source/preparation.md; local ignored artifacts/week-13-source-4a761a3.zip | Source-only snapshot created from confirmed source commit 4a761a31244c00176f016ffe26ff069118b0f0c9; 136 entries; forbidden-path listing clean; SHA-256 recorded in preparation.md. Local ignored artifact, not part of repository history |

Recorded request, fixture and audit data are fictional. No real student ID, live secret or third-party notification used. Test/action descriptions are not student personal work-history claims.

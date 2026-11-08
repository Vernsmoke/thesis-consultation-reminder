# Week 13 evidence index

All execution/capture dates are actual 2026-11-08 Asia/Manila. Application source is fixed at confirmed source commit `4a761a31244c00176f016ffe26ff069118b0f0c9`; later commits add evidence and submission documents without changing application behavior. `tests/source-manifest.json` identifies that source with SHA-256. Earlier experiment evidence remains tied to its recorded working-tree phase; final regression verifies the confirmed source.

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
| DOC-04 | reports/reflection-preparation.pdf/.docx | Evidence-based reflection reviewed by the student, who confirmed on 2026-11-08 that it reflects their understanding |
| DOC-QA | logs/docx-render-attempt.txt; logs/docx-render-final.txt; tmp/docx-qa-final/ and tmp/pdf-qa-final/ (local QA output) | Initial DOCX rendering failed while LibreOffice was unavailable. Final four DOCX files rendered successfully; the nine current pages were visually inspected after correcting title, heading spacing and reflection page balance. Matching PDFs were converted from the final DOCX files and all nine pages were rendered and checked. The final PDF path replaced a fragile independent layout after QA exposed inconsistent font rendering |
| SRC-01 | screenshots/source/SRC-01-laravel-automation.png | Actual VS Code capture at 2026-11-08T19:21:33+08:00 from the exact working tree; Laravel idempotent outbox enqueue and reminder/missed/deadline scan logic; SHA-256 `92eb4dc79a5e4607ac2161ad402fa835d0634b9b042e7bfccc083ed3f383d8ad` |
| SRC-02 | screenshots/source/SRC-02-flutter-follow-up.png | Actual VS Code capture at 2026-11-08T19:22:18+08:00 from the exact working tree; Flutter consultation status, action-item and follow-up UI source; SHA-256 `463d3f43441bc114c553112aca6678c2de915da755edf903bf1fd5e6f814eec4` |
| APP-00 | screenshots/app/APP-00-running-login-desktop.png | Actual user-captured running Flutter Web login at 2026-11-08T19:39:30+08:00, 1103×717; sanitized fictional-data banner and responsive desktop sign-in layout; SHA-256 `f866db3ee675d5aa476e52c08f46cc64a5986e87a407b53811a9cd2f1711d46d`. This proves rendering only, not a connected workflow result |
| APP-01 | screenshots/app/APP-01-student-request-success-desktop.png | 2026-11-08T19:51:44+08:00, 1906x949; connected student request saved successfully; SHA-256 `745fbeeae5cd480411ff7c935660a4e09da45043535e8eb3fab6e9a86cfcd440` |
| APP-02 | screenshots/app/APP-02-adviser-confirmation.png | 2026-11-08T19:52:47+08:00, 1913x948; adviser confirmation and role-specific controls; SHA-256 `8426da958818ee03b039e607c5fe43bbee72145c2e7c92fcb18c601878b28b04` |
| APP-03 | screenshots/app/APP-03-adviser-action-item.png | 2026-11-08T19:53:27+08:00, 1912x951; added action item with deadline and follow-up; SHA-256 `7077355b720b59366216145e4a3c99c833f493fc1f54535c2a47b2dde6b17a40` |
| APP-04 | screenshots/app/APP-04-validation-error.png | 2026-11-08T19:54:24+08:00, 1908x952; empty agenda rejected by client validation; SHA-256 `6540d0a9198f4f90feb19ccd2f2cf76725182bc8cc3cceed7ebb0c199fad6eaa` |
| APP-05 | screenshots/app/APP-05-coordinator-manual-review.png | 2026-11-08T19:57:18+08:00, 1911x952; permanent and exhausted failures retained for human handling; SHA-256 `7214c2dafe9c27b4573eee07f115e143c7476c90be5c9f452cdd307ab1ac10a0` |
| APP-06 | screenshots/app/APP-06-coordinator-metrics.png | 2026-11-08T19:57:47+08:00, 1911x952; coordinator metrics and delivered automation kinds; SHA-256 `ee57cd484e25eabdfd93e2519bec0c1405eed06f0676fc5e98491af493af401b` |
| APP-07 | screenshots/app/APP-07-narrow-layout.png | 2026-11-08T19:58:59+08:00, 616x891; readable narrow workflow; SHA-256 `c28b59764dd3bdef9a6071d7b3dbfd7e15abfc7a90894d3785818e04f6dc1e73` |
| APP-08 | screenshots/app/APP-08-tablet-layout.png | 2026-11-08T19:59:27+08:00, 918x912; readable tablet workflow; SHA-256 `ca88f55425e29e97f2c0ddc2ba7b5ddfbb53b11020089112c5b776e6017d6bd0` |
| APP-QA | screenshots/PENDING_CAPTURES.md | Complete capture record and boundary: screenshots establish visible states; API/tests/logs establish behavior. Manual Tab-order and browser-console checks were not independently recorded |
| SOURCE-01 | source/preparation.md; local ignored artifacts/week-13-source-4a761a3.zip | Source-only snapshot created from confirmed source commit 4a761a31244c00176f016ffe26ff069118b0f0c9; 136 entries; forbidden-path listing clean; SHA-256 recorded in preparation.md. Local ignored artifact, not part of repository history |

Recorded request, fixture and audit data are fictional. No real student ID, live secret or third-party notification used. Test/action descriptions are not student personal work-history claims.

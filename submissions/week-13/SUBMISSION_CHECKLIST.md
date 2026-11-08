# Week 13 requirement-to-artifact checklist

Prepared 2026-11-08, Asia/Manila, before application implementation. Source: original teacher project guide (common requirements and Project 29) and complete Module 13, read directly from DOCX XML. Status starts planned; final reconciliation must link real evidence. No marks or approval implied.

| ID | Requirement and acceptance check | Planned artifact |
|---|---|---|
| P29 | Students, advisers, panel members, coordinators; requests → confirmation → agenda → status → action items → follow-up, no document/grading features | docs/architecture.md; API and Flutter source |
| P29-A | Reminders, missed-session handling, action deadlines, progress summaries | automation service, execution tests |
| T1 | Distinguish task/integration/orchestration/business-process automation; boundary, ownership, preconditions, trusted inputs, approvals, outputs, non-goals | docs/architecture.md |
| T1-C | Boundary map and decision record with context, alternatives, disadvantages, consequences, review conditions | docs/decisions.md; diagrams |
| T2 | Compare schedules, queues, webhooks, polling, change-data events, hybrid: latency, duplicates, loss, ordering, timezone, back-pressure and ownership | docs/decisions.md |
| T2-C | Pattern matrix and trigger contract | docs/automation.md |
| T3 | Transient/permanent/business failures; bounded exponential backoff, jitter, timeouts, circuit breaker, dead letters, checkpoints, compensation and manual recovery | docs/automation.md; worker and tests |
| T3-C | Failure taxonomy, retry policy, recovery runbook | docs/automation.md |
| T4 | Least privilege, secrets, environment separation, validation, safe logs, rotation, dependency control, auditability | docs/security.md; config examples and tests |
| T4-C | Security checklist and protected configuration evidence | docs/security.md; evidence index |
| T5 | Structured logs, correlation, metrics/alerts/dashboard/SLIs; runtime, throughput, error/retry rates, queue depth, change impact and ownership | metrics API; logs; SA7 evaluation |
| H1.1 | Evidence folder, date/environment/runtime/scope log; feature branch | logs/environment; work completed on existing `master` because no feature branch was created before implementation |
| H1.2 | Actors, trigger, trusted inputs, validation, processing, outputs, dependencies, non-goals | architecture |
| H1.3 | Data flow/sequence: trust boundaries, credentials, sensitive fields, logs, failures, human points | diagrams |
| H1.4 | Measurable success/invalid/unauthorized/dependency/recovery criteria | tests/scenarios.md |
| H1.5 | Fictional fixtures and example env; no live secrets/records/endpoints | seeder; .env.example; scan record |
| H1.6 | Approach and alternative, advantages and rejection reason | decisions |
| H1.7 | Flutter screen flow, reusable widgets, validation, responsiveness, API states/feedback | architecture; Flutter |
| H2.1 | Smallest end-to-end path; separate UI/domain/config/transport | source |
| H2.2 | Validation, consistent safe boundary errors, protected diagnostics | API; tests |
| H2.3 | Credentials/config outside source; example only | security; ignore rules |
| H2.4 | Correlation and safe state-transition/outcome logs | source; sanitized logs |
| H2.5 | Success plus ≥4 adverse paths: predictions, requests, expected/actual, real timestamps | repeatable API tests; results |
| H2.6 | Meaningful commit checkpoint | reviewed commands, user executes |
| H2.7 | Connected Flutter: loading/success/validation/authentication/authorization/empty/failure | browser evidence and tests |
| H3.1 | Predict controlled failure before execution, preserve actual | scenarios; failure results |
| H3.2 | Safe failure, actionable signal, no corruption/secrets/unbounded processing | retry and manual-review tests |
| H3.3 | Justified improvement, failed-case rerun and regression | defect/improvement record |
| H3.4 | Counts/timings/logs; facts distinct from interpretation | SA7 report |
| H3.5 | README, decisions, diagrams, limits/recovery match build | docs |
| H3.6 | Controlled demo with backup evidence | demo script |
| H3.7 | Desktop/tablet/narrow, client/server validation, usability/recovery | browser screenshots/checks |
| A1 | Three contrasting office workflows; trigger/execution choices vs latency, volume, reliability, security, staffing; ≥2 alternatives, disadvantages, assumptions, authority, adverse case, next improvement | Activity 1 report and matrix |
| A1-O | Concise decision/test record, diagram/matrix, applicable source/config, repeatable checks, one-page facts/conclusions/recommendations | Activity 1 DOCX |
| A2 | Controlled failure injection: prevent duplicates, endless retry and silent loss using logs/metrics; alternatives, constraints, authority and next improvement | Activity 2 report, worker, results |
| A2-O | Decision/test record, diagram/matrix, source/config, repeatable evidence, one-page interpretation | Activity 2 DOCX |
| SA7 | Automation case and lab portfolio: source/config/workflow/logs/failure/recovery/maintainability | SA7 DOCX and portfolio |
| AS-15 | Concept check (15%): accurate explanations and justified patterns/controls | decisions, SA7 |
| AS-35 | Guided build (35%): working Flutter/API, config/validation/execution evidence | source and tests/browser |
| AS-25A | Adverse test (25%): prediction, controlled execution, logs, interpretation, handling | Activity 2 |
| AS-25B | Portfolio/viva (25%): decisions/diagram/tests/limits/maintenance and oral explanation | SA7; viva prep (actual oral pending) |
| R1 | Technical correctness: bounded usable Flutter/API, defined cases | verification |
| R2 | Evidence/testing: reproducible, traceable, adverse aware, accurate interpretation | index, results |
| R3 | Security/reliability: justified/tested controls and residual risk | security; tests |
| R4 | Documentation: setup, decisions, limits, recovery understandable | README, runbook |
| R5 | Professional defense: requirements → alternatives → evidence → limitations | preparation; real defense pending |
| F1 | Decision with greatest reliability/security effect and evidence | student-reviewed reflection identifies the durable outbox and REL-01 |
| F2 | Hardest failure/limitation to reproduce; improve test design | student-reviewed reflection explains test-clock/session-expiry failure and improvement |
| F3 | Independently explainable/modifiable work with exact artifact | student-reviewed reflection identifies exact source and verification steps |
| F4 | Next maintainer verification and why outside evidence | student-reviewed reflection identifies transport, HTTPS, retention and workload gaps |
| WEB | Modern browser, navigation, desktop/tablet/narrow, client/server validation, eight API feedback states, no client secrets, keyboard/labels/contrast/focus | Flutter source and browser evidence |
| QC | Exact build/environment/fixtures/time, expected/actual, retain failures, no sensitive data, explain controls/limits at all three stages | evidence index and logs |
| ETH | Approval/registry, AI/source acknowledgment, no fabricated student contribution/marks/feedback, controlled data | registration and reflection confirmed by user; acknowledgments and limits retained |
| PACK | Matching source provenance, no dependencies/live env/caches; archive only after checks/commit confirmation | source/preparation.md; confirmed source snapshot and release packaging record |

All activities must answer reproducibility, evidential strength, proportional consequences, and unfinished scope. Module completion also requires the student's independent understanding; automation cannot attest to it.

## Final reconciliation 2026-11-08

| IDs | Current evidence and status |
|---|---|
| P29, P29-A, H2.1–H2.5 | Implemented; API-01, TEST-01, REL-01, AUTO-01 verify workflow, roles/validation and all automations |
| T1, T1-C, H1.2–H1.4, H1.6 | Written architecture/decisions/API/scenarios; DIAG-01/02/04 exported and visually checked |
| T2, T2-C | Pattern matrix in docs/decisions.md and Activity 1; trigger contract in docs/automation.md; AUTO-01/02 verify actual scan/schedule |
| T3, T3-C, H3.1–H3.4 | Retry taxonomy/runbook and REL-01/TEST-01; timeouts are controlled simulated outcomes, external network provider timing not claimed |
| T4, T4-C, H1.5, H2.3–H2.4 | Private generated config, .env.example, minimum roles, audit fields; SEC-01 scan/audit and API adverse checks |
| T5 | Coordinator metrics show pending/manual/delivered/attempt counts; command timing and fixture records evaluated in SA7. Operator alert thresholds documented, no independent alert service or production SLI claim |
| H1.1, H2.6 | Evidence folder/environment ready; six reviewed commit groups executed under the user explicit exception and master pushed by direct URL; no remote configured |
| H1.7, H2.7, H3.7, WEB | Implemented and widget-tested; APP-00–APP-08 show actual login, connected success, role actions, validation, manual review, desktop, tablet and narrow layouts. Manual Tab-order/browser-console inspection was not independently recorded and is stated as a limitation |
| H3.5–H3.6 | README/runbook/decisions/diagrams and backup evidence ready; real application captures support the prepared demonstration. The actual assessed presentation remains an instructor event |
| A1, A1-O | Activity 1 PDF and editable DOCX produced; three cases/matrix, assumptions/alternatives/consequences and one-page interpretation. Other two cases are comparative examples, not implemented |
| A2, A2-O | Activity 2 PDF/DOCX produced; actual real-time and repeatable controlled failure evidence, interpretation and source/config links |
| SA7, AS-15, AS-35, AS-25A, AS-25B | Reports/lab source, DOCX/PDF soft copies, execution evidence and real application/source captures complete. Actual oral assessment and marking remain external |
| R1–R4 | Source/tests/docs and real application captures provide evidence; no rubric mark is assigned; DOCX/PDF and responsive layouts visually verified |
| R5, F1–F4, ETH | Student confirmed the reflection reflects their understanding, AI assistance is fine and Project 29 registration is approved on 2026-11-08. Actual oral-defense result, marks and any instructor-prescribed AI wording remain external |
| QC | Timestamped real results, initial failures retained, source/screenshot hashes and secret/file checks; no screenshot fabricated |
| PACK | Confirmed source commit and ignored source-only snapshot complete; master push complete. Final evidence commit, `v1.0.0` tag and release ZIP follow the final verification recorded in this package |

The Week 13 technical and digital submission package is complete and submission-ready for the available course requirements. The student reviewed and confirmed the reflection, confirmed Project 29 registration, and supplied real running-application evidence. Four DOCX and four PDF soft copies were regenerated, rendered and visually verified on 2026-11-08. The actual submission, oral assessment, instructor marking and any prescribed acknowledgment wording remain external actions and are not fabricated. No future week has been started.

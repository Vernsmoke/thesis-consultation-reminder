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
| H1.1 | Evidence folder, date/environment/runtime/scope log; feature branch | logs/environment; branch pending user (Git ownership overrides procedure) |
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
| F1 | Decision with greatest reliability/security effect and evidence | evidence-based reflection draft completed; student review pending |
| F2 | Hardest failure/limitation to reproduce; improve test design | evidence-based reflection draft completed; student review pending |
| F3 | Independently explainable/modifiable work with exact artifact | draft identifies exact source and verification steps; student reproduction/verification pending |
| F4 | Next maintainer verification and why outside evidence | evidence-based reflection draft completed |
| WEB | Modern browser, navigation, desktop/tablet/narrow, client/server validation, eight API feedback states, no client secrets, keyboard/labels/contrast/focus | Flutter source and browser evidence |
| QC | Exact build/environment/fixtures/time, expected/actual, retain failures, no sensitive data, explain controls/limits at all three stages | evidence index and logs |
| ETH | Approval/registry, AI/source acknowledgment, no fabricated student contribution/marks/feedback, controlled data | status; acknowledgments; pending external items |
| PACK | Matching source provenance, no dependencies/live env/caches; archive only after checks/commit confirmation | source/preparation.md; final packaging pending user commit |

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
| H1.7, H2.7, H3.7, WEB | Implemented and widget-tested; browser execution, screenshots, manual keyboard/focus/contrast and actual connected responsive evidence PENDING due tool permissions |
| H3.5–H3.6 | README/runbook/decisions/diagrams and demo backup ready; actual browser demo pending |
| A1, A1-O | Activity 1 PDF and editable DOCX produced; three cases/matrix, assumptions/alternatives/consequences and one-page interpretation. Other two cases are comparative examples, not implemented |
| A2, A2-O | Activity 2 PDF/DOCX produced; actual real-time and repeatable controlled failure evidence, interpretation and source/config links |
| SA7, AS-15, AS-35, AS-25A, AS-25B | Reports/lab source and evidence prepared; DOCX/PDF visual verification complete; required browser evidence and oral assessment remain pending |
| R1–R4 | Source/tests/docs provide evidence; no rubric mark assigned; browser usability remains unobserved because managed permissions rejected capture; DOCX/PDF layout verified |
| R5, F1–F4, ETH | Reflection/viva preparation provided; personal reflection, independent explanation, course registration/acceptance remain pending. User confirmed AI assistance is fine |
| QC | Timestamped real results, initial failures retained, source hashes and secret/file checks; screenshots unavailable rather than invented |
| PACK | Confirmed source commit and ignored source-only snapshot complete; master push complete. v1.0.0 tag and final submission ZIP withheld pending screenshot and instructor-only evidence completion |

The application and automated evidence are prepared as far as available access permits. An evidence-based reflection draft is complete, but the student must read it, reproduce the cited behavior, and revise any statement they cannot explain. This folder is not labeled fully submission-ready because real app/source screenshots, project-registration confirmation, student verification and oral/instructor actions remain pending. Four DOCX and four PDF soft copies were rendered and visually verified on 2026-11-08. No future week has been started.

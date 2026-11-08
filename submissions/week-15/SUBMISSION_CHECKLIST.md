# Week 15 Submission Checklist

Status legend: **verified** means supported by executed evidence; **prepared** means the artifact is complete but instructor acceptance is external; **pending** means an external/user action remains.

## Module topics and checkpoints

| Requirement | Status | Artifact/evidence |
|---|---|---|
| Integration purpose, interfaces, dependencies, test levels and environment | verified | `docs/week-15-test-strategy.md`; IA6 report |
| API positive, negative, boundary, auth, duplicate and recovery testing | verified | `tests/traceability-matrix.md`; `tests/api-results.json`; PHPUnit XML |
| Security hardening: authz, validation, transport/config, logging, headers, secret handling | verified | defect records; hardening backlog; Activity 2; source tests |
| Failure diagnosis, controlled injection, rollback/retry/recovery | verified | `tests/failure-injection-record.md`; initial failure and regression records |
| Evidence-based prioritization and residual risk | verified | Activity 2; IA6 report; `tests/hardening-backlog.md` |

## Hands-on procedure

| Required step | Status | Artifact/evidence |
|---|---|---|
| Part 1: prepare environment, fixtures, expected results, and repeatable tools | verified | controlled fixtures; environment JSON; Postman collection; PowerShell runners |
| Part 2: execute normal/adverse API and Flutter tests and preserve actual results | verified | 14/14 live HTTPS, 24/227 Laravel, 22 Flutter; logs and screenshots |
| Part 3: diagnose, prioritize, fix, rerun failures and regression | verified | five initial failures, five fixes, layout regression and final passes |

## Required behavior coverage

| Category | Status | Representative evidence |
|---|---|---|
| Normal, invalid, boundary | verified | API-01/API-04/API-05/API-10; Laravel/Flutter tests |
| Unauthorized, forbidden, not-found | verified | API-06/API-07/API-08/API-11 |
| Duplicate/idempotency | verified | API-02/API-03; workflow tests |
| Timeout and dependency failure | verified | two Flutter timeout tests; API-13 |
| Recovery and rollback | verified | API-14; automation rollback/exactly-once tests |
| Client/server validation agreement | verified | IA6 report; boundary tests; APP-03 |
| Loading, empty, validation, authn, authz, network, server/protocol errors | verified | 22 Flutter tests; traceability matrix |
| Desktop, tablet, narrow layout; labels/focus/contrast/feedback | verified for tested browser/widget scope | Flutter tests and APP-01–04; cross-browser/AT remains pending |

## Activities, IA6, rubric and reflection

| Deliverable/rubric element | Status | Artifact |
|---|---|---|
| Activity 1: requirements-to-tests matrix, expected/actual and interpretation | prepared | Activity 1 DOCX/PDF; complete 25-row matrix |
| Activity 2: labeled weak fixture, ranking, bounded sprint, before/after, interpretation | prepared | Activity 2 DOCX/PDF; weak/hardened YAML; defect records |
| IA6 integration testing and security hardening report | prepared | IA6 DOCX/PDF |
| Test design completeness and traceability | verified | strategy, matrix, collection and results |
| Execution accuracy and evidence quality | verified | actual timestamps, logs, JUnit, screenshots, hashes |
| Hardening justification and regression | verified | five evidence-supported fixes and final full rerun |
| Professional reporting, limitations and recommendations | prepared | IA6 and activity reports; evidence index |
| Reflection prompts | prepared | reflection DOCX/PDF; factual technical reflection and AI acknowledgment |

## Project 29 continuity and package

| Requirement | Status | Evidence |
|---|---|---|
| Continuous Flutter/Laravel/MariaDB application; bounded consultation workflow retained | verified | source and full regression |
| Reminders, missed sessions, deadlines, progress summaries and manual recovery retained | verified | Laravel workflow/automation regression |
| No Week 13/14 submission evidence silently refreshed | verified | Git status/diff review |
| Equivalent exported collection, controlled fixtures, results/logs | verified | `tests/Thesis-Consultation-Week15.postman_collection.json` and test folder |
| Final DOCX/PDF render and accessibility QA | verified | reports and document-audit logs |
| Evidence index and contents list | verified | `EVIDENCE_INDEX.md`; `SUBMISSION_CONTENTS.md` |
| Source snapshot/ZIP bound to confirmed Week 15 commit/tag | pending | regenerate after user commits; see `source/MANIFEST.md` |
| Instructor template/AI wording, marking, oral explanation or acceptance | pending external | no template/result was supplied or invented |

Conclusion: the controlled Week 15 technical scope is verified and the written artifacts are prepared. Submission provenance remains pending until the user creates the reviewed commits and confirms the final source revision; instructor evaluation remains external.

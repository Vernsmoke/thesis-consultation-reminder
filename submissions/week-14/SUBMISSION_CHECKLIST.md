# Week 14 Requirement to Artifact Checklist

Status values are **verified** or **pending external action**. Evidence dates use the actual Asia/Manila execution date. The historical 2026-11-06 deadline is not used as a completion date.

## Prerequisites and scope

| Requirement | Planned artifact or evidence | Status |
|---|---|---|
| Extend the verified Week 13 application without rewriting the milestone | `PROJECT_STATUS.md`; Git evidence showing `v1.0.0` at `707ef93` | verified |
| Record date, environment, runtime, approved scope, controlled data, and source state | `logs/environment.json`; `tests/security-test-record.md`; `EVIDENCE_INDEX.md` | verified |
| Preserve Project 29 workflow and roles | `docs/security-architecture.md`; application tests | verified |
| Bound non-goals and acceptance criteria for normal, invalid, unauthorized, dependency failure, and recovery | `reports/SA8-secure-integration-architecture.md`; `tests/security-test-record.md` | verified |
| Compare at least two feasible approaches with disadvantages and selection reason | `docs/cryptographic-decision.md`; Activity 1 and Activity 2 reports | verified |

## Topic checkpoints

| Module checkpoint | Artifact or evidence | Status |
|---|---|---|
| Data-flow diagram and protection-requirements matrix | `diagrams/secure-data-flow.*`; `docs/protection-requirements.md` | verified |
| Control-selection rationale with misuse warnings | `docs/control-rationale.md` | verified |
| Cryptographic design sketch and algorithm decision record | `diagrams/secure-exchange-sequence.*`; `docs/cryptographic-decision.md` | verified |
| Key lifecycle plan and secure-configuration evidence | `docs/key-lifecycle.md`; sanitized configuration and secret-scan evidence | verified |
| Security test record and residual-risk register | `tests/security-test-record.md`; `docs/residual-risk-register.md` | verified |

## Required implementation

| Requirement | Implementation or evidence | Status |
|---|---|---|
| Authentication and expiring protected sessions | Laravel API session middleware and tests | verified |
| Role-based authorization and ownership | Laravel policies at API boundaries and adverse tests | verified |
| HTTPS with certificate validation in the controlled environment | Local TLS endpoint, certificate details, and verification log | verified |
| Server-side validation and safe errors | Request validation, consistent no-store responses, correlation IDs, tests | verified |
| Protected configuration and secrets outside source | ignored `.env`; nonsecret `.env.example`; configuration tests and scan | verified |
| Structured safe logging | allowlisted security/audit events without tokens, keys, ciphertext, or sensitive request bodies | verified |
| Data minimization and retention decisions | minimized secure record; replay receipt retention and documentation | verified |
| Established authenticated-encryption library | PHP OpenSSL AES-256-GCM with random 96-bit nonce and 128-bit tag | verified |
| Keys absent from Flutter and source control | source inspection and secret scan | verified |
| Replay prevention and bounded validity | unique message ID, authenticated timestamps, five-minute window, database uniqueness | verified |
| Flutter Web over HTTPS with clear states and responsive behavior | API configuration, secure-exchange sender/receiver UI, browser evidence | verified |

## Hands-on preparation and design

| Procedure | Artifact or evidence | Status |
|---|---|---|
| Actors, trigger, trusted inputs, steps, outputs, dependencies, and non-goals | SA8 report and security architecture | verified |
| Diagram trust boundaries, credentials, sensitive data, logs, failures, and human approval | secure data-flow and sequence diagrams | verified |
| Measurable acceptance criteria | security test record | verified |
| Fictional data and nonsecret example environment | test fixtures and `.env.example` | verified |
| Implementation choice and rejected alternative | cryptographic decision record | verified |
| Flutter screen flow, validation, responsive behavior, states, feedback | UI tests and browser evidence | verified |

## Hands-on implementation and verification

| Procedure | Artifact or evidence | Status |
|---|---|---|
| Smallest end-to-end approved sender/receiver path | Laravel secure-exchange service/routes plus Flutter UI | verified |
| Explicit boundary validation and protected diagnostics | feature tests and sanitized logs | verified |
| Externalized environment settings | configuration source and scan | verified |
| Correlation-aware structured logs | security event log evidence | verified |
| Success path and at least four adverse paths with expected and actual outcomes | scripted and PHPUnit results | verified |
| Loading, success, validation, authentication, authorization, empty, and failure states | Flutter tests and browser evidence | verified |

## Failure evidence and completion

| Procedure | Artifact or evidence | Status |
|---|---|---|
| Predict and execute a controlled failure | tamper test record | verified |
| Safe failure without corruption, disclosure, or unbounded work | API/database assertions and logs | verified |
| Justified improvement, failed-case rerun, and regression set | initial/final records and regression logs | verified |
| Counts, timings, observations, interpretation, and recommendations separated | Activity 2 and IA5 reports | verified |
| Updated README, decision record, diagrams, limitations, and recovery | shared and Week 14 documentation | verified |
| Desktop and narrow browser verification; client/server validation agreement | Flutter tests and screenshots | verified |

## Required adverse cases

| Case | Expected safe outcome | Status |
|---|---|---|
| Altered ciphertext or authenticated metadata | reject without creating receipt or exposing plaintext | verified |
| Replay of an already accepted message | reject with conflict; one receipt only | verified |
| Expired envelope or API session | reject; require new envelope or sign-in | verified |
| Invalid or malformed input | reject with validation error and correlation reference | verified |
| Unauthorized role or unassigned receiver | reject without plaintext | verified |
| Wrong or unknown key | reject safely; no plaintext or receipt | verified |
| Unavailable or missing key configuration | safe service-unavailable response; recovery after restoring configuration | verified |
| Invalid certificate | TLS client rejects unless the controlled CA is explicitly trusted | verified |

## Activities and assessments

| Deliverable | Required contents | Status |
|---|---|---|
| Activity 1 | Five hashing/encryption proposals, objectives, corrections, assumptions, two approaches, adverse case, one-page interpretation | verified |
| Activity 2 | Source/config inspection, HTTPS verification, tamper test, secret scan, residual risks, improvement and rerun, one-page interpretation | verified |
| SA8 | Threat summary, protection matrix/data flow, rationale/misuse warnings, crypto design, key lifecycle, evidence, limitations, decision record | verified |
| IA5 | Working sender/receiver build, code excerpts, configuration example, normal/adverse tests, recovery, limitations | verified |
| Technical reflection | Evidence-grounded first-person reflection and independently explainable artifact choice | verified |

## Rubric and evidence quality

| Criterion | Evidence strategy | Status |
|---|---|---|
| Technical correctness | End-to-end Flutter/API build and repeatable regression tests | verified |
| Evidence and testing | Expected/actual/timestamp/build traceability for normal and adverse cases | verified |
| Security and reliability | Justified controls, negative tests, recovery, residual risk | verified |
| Documentation | Setup, maintenance responsibility, decisions, limits, recovery | verified |
| Professional defense | Evidence-linked decision and limitation notes; actual viva remains external | pending external action |
| Concept check 15 percent | Activity 1 and control rationale | verified |
| Guided build 35 percent | Working Flutter/API secure exchange | verified |
| Adverse test 25 percent | Tamper, replay, expiry, invalid, unauthorized, key and TLS cases | verified |
| Technical portfolio 25 percent | Reports, diagrams, evidence index, limitations, maintenance notes | verified |

## Final packaging

| Requirement | Artifact | Status |
|---|---|---|
| Evidence index with descriptive IDs, paths, scenario, result, build, and time | `EVIDENCE_INDEX.md` | verified |
| Actual source and application screenshots with sanitized fictional data | `screenshots/source/`; `screenshots/app/` | verified |
| Verified DOCX and PDF soft copies | `reports/*.docx`; `reports/*.pdf`; render logs | verified |
| AI and third-party assistance acknowledgment | report references/acknowledgment; exact institutional wording remains unconfirmed | verified |
| Reviewed explicit Git groups and `v2.0.0` commands | `docs/week-14-git-commands.ps1`; committed source revision `03d9ed3` | verified |
| Oral reproduction, instructor marks, and any prescribed acknowledgment | User/instructor action; never fabricated | pending external action |

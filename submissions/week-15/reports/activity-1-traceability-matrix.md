# Activity 1 Requirements to Test Traceability

Laurence Matthew B Manuel  
BSIT 3A  
PFEBSIT 002 Project 29 Week 15

## Purpose and conclusion

I converted the approved thesis consultation workflow and its main risks into tests with unambiguous expected results. I selected a layered Laravel, Flutter, and live HTTPS strategy because it tests provider behavior, client interpretation, and interoperability. A Postman-only alternative is easier to run but cannot deterministically prove database rollback, widget states, or viewport behavior. The final evidence covers every required normal and adverse category and retains the initial failures that led to hardening.

## Assumptions and authority

The test environment is local and nonproduction, all identities are fictional, notification transport is simulated, and Asia/Manila is the evidence timezone while API timestamps remain UTC. The instructor is authorized to accept IA6; the student owns reproduction and explanation. Broader deployment, concurrency thresholds, and external email or SMS are outside this activity.

## Traceability summary

| Class | Representative test | Expected result | Actual result and evidence |
|---|---|---|---|
| Positive | valid consultation request | 201 and one requested record | API-01 passed; workflow test passed |
| Negative | missing schedule and short agenda | 422 with field-safe response | API-04 passed |
| Boundary | 1000-character agenda; `per_page=0` | maximum accepted once; zero rejected 422 | API-05/API-10 passed; APP-02 shows record |
| Authentication | no bearer token | 401 without protected data | API-06 passed |
| Authorization | student automation; panel receive | 403; crypto not attempted for disallowed role | API-07/API-11 passed |
| Not found | unknown action | 404 safe response | API-08 passed |
| Duplicate | same and changed idempotency key payloads | replay original; changed input 409 | API-02/API-03 passed |
| Timeout | idempotent versus non-idempotent request | same-key retry only when protected | Flutter tests passed |
| Dependency failure | unused local HTTPS port | bounded error, no loop or data leak | API-13 passed |
| Recovery | healthy request after unavailable probe | 200 and normal data | API-14 passed |
| UI states | loading, empty, validation, 401, 403, 500, network | visible actionable feedback | 22 Flutter tests passed |
| Responsive | 390, 768, 1440 logical widths | no overflow or uncaught error | widget tests passed; APP-04 supports review |

The complete 25-row matrix is in `tests/traceability-matrix.md`, and the editable test architecture diagram is in `diagrams/test-architecture.mmd`.

## Reproducible method

1. Run the live HTTPS collection with `Invoke-Week15Api.ps1`; it reads the private fixture password but never saves it.
2. Run `Run-Week15Verification.ps1` to execute Laravel, Flutter, analysis, build, audit, and environment capture.
3. Compare `api-results.json`, JUnit XML, and logs with the matrix. Use screenshots only as supporting evidence.
4. Reproduce an initial weakness with the named targeted test, inspect the defect record, and confirm the final full regression.

## Interpretation

**Observed facts.** All 14 live HTTPS cases, 24 Laravel tests with 227 assertions, and 22 Flutter tests passed after hardening. The first targeted run failed five protections, and the first full Flutter rerun exposed a layout regression; both records remain preserved.

**Reasoned conclusion.** The evidence supports the bounded integration contracts on this working tree and environment. Layered tests found defects that a normal demonstration and a collection-only approach had missed.

**Recommendation.** Keep the matrix as the change gate, add action-item idempotency, and use Week 16 measurements before selecting rate limits or making any readiness claim.

## Limitations and acknowledgment

The evidence does not cover production hosting, public network faults, high concurrency, or all browsers and assistive technologies. AI assistance was used for implementation and documentation and was reviewed against actual source and results. Official Postman and OWASP guidance listed in the module informed the test categories; installed framework behavior was verified locally.

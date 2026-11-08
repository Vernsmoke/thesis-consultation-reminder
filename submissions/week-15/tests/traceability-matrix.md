# Week 15 Requirements to Test Traceability Matrix

| ID | Requirement or risk | Layer and test | Expected safe result | Evidence | Result |
|---|---|---|---|---|---|
| W15-REQ-01 | Normal consultation request | HTTPS API-01; Workflow complete path | 201 and one requested record | `api-results.json`; PHPUnit | Pass |
| W15-REQ-02 | Invalid required fields | HTTPS API-04; invalid missing schedule | 422 with safe field errors | `api-results.json`; PHPUnit | Pass |
| W15-REQ-03 | Agenda maximum boundary | HTTPS API-05 | 1000 characters accepted once | `api-results.json`; APP-02 | Pass |
| W15-REQ-04 | Pagination bounds and metadata | HTTPS API-09/API-10; Week15HardeningTest | one record plus metadata; zero rejected 422 | JSON, JUnit, SRC-02 | Pass |
| W15-REQ-05 | Missing authentication | HTTPS API-06; expired session test | 401 and no protected data | JSON, PHPUnit | Pass |
| W15-REQ-06 | Role authorization | HTTPS API-07/API-11; forbidden-role tests | 403 before protected operation | JSON, PHPUnit, SRC-01 | Pass |
| W15-REQ-07 | Unknown resource | HTTPS API-08; missing entity test | 404 safe message | JSON, PHPUnit | Pass |
| W15-REQ-08 | Duplicate request replay | HTTPS API-02; duplicate key test | original ID, replayed true, no duplicate row | JSON, PHPUnit | Pass |
| W15-REQ-09 | Duplicate key changed input | HTTPS API-03 | 409 conflict, original unchanged | JSON, PHPUnit | Pass |
| W15-REQ-10 | Dependency unavailable | HTTPS API-13; Flutter network test | bounded failure, no retry loop or sensitive output | JSON, Flutter log | Pass |
| W15-REQ-11 | Recovery after dependency failure | HTTPS API-14; secure key recovery test | healthy request succeeds after controlled failure | JSON, PHPUnit | Pass |
| W15-REQ-12 | Timeout handling | Flutter idempotent/non-idempotent timeout tests; automation timeout test | same-key retry only for idempotent request; three worker attempts then review | Flutter/Laravel logs | Pass |
| W15-REQ-13 | Partial failure rollback | Workflow transport crash test | receipt rolls back, event remains pending, later retry delivers once | PHPUnit | Pass |
| W15-REQ-14 | Malformed service response | Flutter protocol-failure test | status 502 and actionable safe message | Flutter log | Pass |
| W15-REQ-15 | Loading state | Flutter pending-request widget test | visible progress indicator, control disabled | Flutter log | Pass |
| W15-REQ-16 | Empty state | Flutter empty response widget test | understandable no-consultations message | Flutter log | Pass |
| W15-REQ-17 | Client validation | Flutter form tests and browser APP-03 | invalid form blocked before network | Flutter log; APP-03 | Pass |
| W15-REQ-18 | Authentication feedback | Flutter HTTP 401 state | safe error and local sign-out | Flutter log | Pass |
| W15-REQ-19 | Authorization feedback | Flutter HTTP 403 state | safe visible denial | Flutter log | Pass |
| W15-REQ-20 | Network/server feedback | Flutter network and HTTP 500 states | actionable safe messages without diagnostic leakage | Flutter log | Pass |
| W15-REQ-21 | Responsive interface | widget widths 390/768/1440; Edge effective 640 CSS px | no overflow or uncaught exception | Flutter log; APP-04 | Pass |
| W15-REQ-22 | Security headers | HTTPS API-12; Week15HardeningTest | CSP, Permissions-Policy, HSTS | JSON, PHPUnit | Pass |
| W15-REQ-23 | Safe logging/correlation | security log test; all live API responses | correlation IDs retained; no ciphertext/key/password | PHPUnit, JSON, secret scan | Pass |
| W15-REQ-24 | Dependency posture | Composer audit | no known advisories in installed PHP dependencies | `composer-audit.json` | Pass |
| W15-REQ-25 | Secret hygiene | Week 15 secret scan | no exact generated-secret or private-key match; protected paths ignored | `secret-scan.json` | Pass |

The matrix is the Activity 1 technical output and the IA6 traceability source. “Pass” means the cited controlled test matched its expectation; it does not generalize to untested production environments.

# Week 15 Defect Records

| Finding | Priority | Reproduction and initial result | Root cause | Fix | Retest |
|---|---|---|---|---|---|
| W15-DEF-01 silent list truncation | High | `GET /consultations?per_page=2` returned all 3 fixtures and no metadata | fixed `limit(100)` ignored client bounds and exposed no continuation signal | validate page/per_page, return total and has_more, show UI notice | targeted Laravel test and API-09/API-10 pass |
| W15-DEF-02 crypto before role rejection | High | panel submitted structurally valid but cryptographically invalid envelope and received 422 instead of early 403 | receiver role check occurred after `SecureExchange::open` | reject non-adviser or mismatched declared recipient before cryptographic work; authenticated envelope still verifies metadata | targeted Laravel test and API-11 pass |
| W15-DEF-03 incomplete API browser headers | Medium | CSP absent on an HTTPS API response | middleware supplied no-store/nosniff/referrer policy only | add CSP, Permissions-Policy, and HSTS consistently | targeted Laravel test and API-12 pass |
| W15-DEF-04 unsafe generic timeout instruction | High | non-idempotent POST timeout advised retrying the same form | client did not distinguish presence of an idempotency key | same-key retry guidance only when a key exists; otherwise instruct status check before retry | two Flutter timeout tests pass |
| W15-DEF-05 malformed response misclassified | Medium | HTTP 200 HTML body became generic network status 0 | decode/cast errors fell through the connectivity catch | classify invalid JSON/object response as safe 502 protocol failure | Flutter malformed-response test passes |
| W15-REG-01 client validation layout regression | Medium | initial full Flutter rerun produced off-screen login controls at 600 px height | added visible counters increased form height | keep 100/128 validation without layout-changing counters; update idempotent timeout test with its key | full 22-test Flutter suite passes |

These are real observations from tests against the Week 14 baseline or the first Week 15 implementation. No vulnerability was deliberately introduced.

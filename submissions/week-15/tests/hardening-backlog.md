# Prioritized Hardening Backlog

| Rank | Item | Status | Rationale and evidence | Next condition |
|---|---|---|---|---|
| P1 | Bound consultation collection with explicit pagination | Implemented and verified | prevents silent truncation/unbounded response; W15-DEF-01 | add UI page navigation if real datasets exceed 100 |
| P1 | Reject unauthorized secure receiver before cryptographic work | Implemented and verified | reduces unauthorized work and error-detail distinction; W15-DEF-02 | retain authenticated recipient verification inside envelope open |
| P1 | Differentiate timeout retry guidance by idempotency | Implemented and verified | reduces duplicate state changes; W15-DEF-04 | extend idempotency to action creation before advising safe automatic retry |
| P2 | Classify malformed API output separately | Implemented and verified | improves diagnosis without exposing raw body; W15-DEF-05 | add schema validation for every response model |
| P2 | Emit CSP, Permissions-Policy, and HSTS | Implemented and verified | defense in depth for browser-facing API; W15-DEF-03 | confirm final reverse proxy does not overwrite policy |
| P2 | Preserve client/server email and password boundaries | Implemented and verified | blocks avoidable mismatched requests | localize and centralize shared constraint documentation |
| P2 | Add action-item idempotency | Pending | action creation can be ambiguous after a network timeout | design a resource-scoped idempotency table and client key |
| P2 | Add rate controls to remaining write endpoints | Pending | login and secure exchange are throttled, other mutations rely on authentication | choose per-user limits from measured workload in Week 16 |
| P3 | Multi-browser and accessibility-tool audit | Pending | Edge and widget semantics are covered, not independent assistive technology/browser combinations | test authorized browser/AT matrix before broader use |
| P3 | Concurrency and performance thresholds | Pending | isolated transaction tests do not establish peak behavior | Week 16 workload and deployment evaluation |

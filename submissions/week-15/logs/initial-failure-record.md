# Week 15 Initial Failure Record

Captured: 2026-11-08 21:34:41 +08:00  
Source: uncommitted Week 15 tests applied to Week 14 release commit `133b0c8`  
Data: fictional in-memory test fixtures

## Baseline

Before the new tests, all 21 Laravel tests (199 assertions), all 18 Flutter tests, Flutter analysis, and Laravel Pint passed. Passing earlier tests did not exercise the Week 15 protection expectations below.

## Predicted and actual failures

| Finding | Prediction | Initial actual result | Risk |
|---|---|---|---|
| W15-DEF-01 bounded pagination | `per_page=2` returns two of three records plus explicit pagination metadata; zero is rejected | Laravel returned all three records and no pagination contract | A client can silently receive a truncated or unexpectedly large list without knowing more records exist |
| W15-DEF-02 early authorization | A panel user is rejected with 403 before envelope cryptography | Laravel attempted secure-envelope processing and returned 422 for invalid cryptographic content | An unauthorized caller can trigger unnecessary cryptographic work and observe a lower-level failure category |
| W15-DEF-03 API hardening headers | HTTPS API responses include CSP, Permissions Policy, and HSTS | `Content-Security-Policy` was absent; the test stopped at the first missing header | Browser-facing API responses lacked explicit defense-in-depth restrictions |
| W15-DEF-04 timeout semantics | Non-idempotent requests instruct the user to inspect status before retrying | Flutter advised retrying the same form for every timeout | Retrying a non-idempotent action could duplicate a state change |
| W15-DEF-05 malformed upstream response | Non-JSON success content is classified as a 502 protocol failure | Flutter classified it as a generic network failure with status 0 | Operators receive misleading diagnosis and cannot distinguish connectivity from invalid service output |

## Raw test summary

- Laravel targeted run: 3 tests failed, 17 assertions reached. Failures were record count 3 versus 2, expected 403 versus actual 422, and missing `Content-Security-Policy`.
- Flutter targeted run: 1 test passed and 2 failed. The safe same-key timeout test passed; non-idempotent timeout guidance and malformed-response classification failed as predicted.
- No production endpoint, live credential, or real personal record was used.

The targeted tests remain in the main suites and are rerun after each fix and again in the full regression set.

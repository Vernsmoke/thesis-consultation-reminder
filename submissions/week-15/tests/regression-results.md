# Week 15 Regression Results

## Initial targeted failures

Five expected protections failed against the Week 14 baseline: pagination, early authorization, API hardening headers, non-idempotent timeout guidance, and malformed-response classification. The exact expected/actual summary is retained in `logs/initial-failure-record.md`.

## Implementation regression discovered

The first full Flutter rerun after adding client email/password boundaries failed. Visible character counters increased the login card height, placing the sign-in control outside the default 800 by 600 test viewport; dependent authentication, error-state, and secure-exchange widget tests then failed. The pre-existing timeout test also called the consultation endpoint without an idempotency key while expecting same-form retry advice.

The correction removed layout-changing counters while retaining explicit 100/128-character validators, and supplied the idempotency key in the test that claims safe same-key retry. This failure is a test-design and UI-regression lesson: a valid constraint can still break operability at a boundary viewport.

## Final regression

- Laravel: 24 tests, 227 assertions, all passed.
- Flutter: 22 tests, all passed, including logical widths 390, 768, and 1440.
- Live HTTPS API: 14 of 14 expected outcomes matched.
- Flutter analysis, release web build, Laravel Pint, Composer audit, collection parse, and secret scan passed.
- Final secret scan: 244 candidate text files; zero exact generated-secret/private-key matches; protected paths remained ignored.

The final results show the tested working tree is regression-safe for the covered paths. They do not prove production capacity, all browser combinations, or untested concurrency.

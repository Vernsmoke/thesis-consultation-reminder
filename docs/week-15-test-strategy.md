# Week 15 Integration Test Strategy

## Decision and scope

Project 29 uses a layered, risk-based strategy: Laravel feature tests verify server contracts and state, Flutter unit/widget tests verify client interpretation and visible states, and a live HTTPS collection verifies interoperability through the local TLS gateway and MariaDB. This was selected over a collection-only strategy because a collection cannot deterministically drive rollback, timeout, widget layout, or cryptographic dependency states. The disadvantage is maintenance across three test layers and the need to prevent duplicate coverage from becoming inconsistent.

The tested workflow remains consultation request, confirmation, agenda, meeting status, action items, follow-up, reminders, missed-session handling, deadlines, summaries, and secure adviser exchange. Document management, grading, plagiarism detection, video meetings, production integrations, and production-readiness claims remain outside scope.

## Environment and ownership

- Build under test: uncommitted Week 15 working tree based on `133b0c8` (`master`); no commit or tag is claimed.
- Execution: 2026-11-08, Asia/Manila. Exact start/end times are in `submissions/week-15/logs/environment.json` and `tests/api-results.json`.
- Runtime: PHP 8.2.12, Laravel 12.71.0, Flutter 3.47.8, Dart 3.13.7, MariaDB 10.4.32 from XAMPP.
- Data: fictional `example.test` users and controlled records. The private fixture password and key material stay outside the repository and output.
- Acceptance authority: the instructor evaluates IA6; the student can reproduce and explain the evidence but does not claim instructor acceptance.

## Test layers and exit criteria

| Layer | Purpose | Principal evidence | Exit criterion |
|---|---|---|---|
| Laravel feature | Validation, authorization, idempotency, state, automation, rollback, secure exchange, headers, pagination | `phpunit-results.xml`, `backend-tests.txt` | All tests pass with no database residue between tests |
| Flutter unit and widget | Request interpretation, timeouts, malformed responses, loading, empty, validation, auth, server/network feedback, responsive layouts | `flutter-tests.txt`, app screenshots | All tests pass at 390, 768, and 1440 logical widths with no uncaught exception |
| Live HTTPS collection | Client/API/TLS/MariaDB interoperability and status contracts | Postman collection, `Invoke-Week15Api.ps1`, `api-results.json` | Every expected/actual result matches and outputs contain no secret |
| Static and build checks | Maintainability and dependency/build posture | Pint, analysis, release build, Composer audit, secret scan | All commands exit successfully; no advisory or generated-secret match |

## Acceptance rules

Normal operations must return documented success codes and observable state. Invalid and boundary input must be rejected or accepted at the exact defined limit. Missing authentication returns 401; authenticated but disallowed roles return 403; absent resources return 404; semantic conflicts and duplicate-key conflicts return 409. Dependency failures must be bounded, correlated where the API is reached, and recover without silent duplication or corruption. Client/server validators must agree on agenda (5-1000), action text (5-500), resolution (10-500), email (valid and at most 100), password (1-128), future UTC timestamps, and pagination (1-100).

## Evidence integrity

Each executable result records expected and actual outcomes, time, fixture, build state, and correlation ID where available. Initial failures are retained in `logs/initial-failure-record.md`; the first full Flutter regression failure is retained in `tests/regression-results.md`. Screenshots support browser/source review but do not replace JUnit, JSON results, or logs.

## Limitations

The collection ran on one Windows workstation and local HTTPS/MariaDB environment. It does not establish performance under concurrency, public-network behavior, multi-browser compatibility beyond Edge, or production deployment readiness. Those are evaluated later or require an authorized environment.

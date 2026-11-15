# Week 16 Performance Reliability and Deployment Evaluation

**Student:** Laurence Matthew B Manuel | **Section:** BSIT 3A | **Project:** Project 29 Thesis Consultation Reminder System | **Milestone:** v4.0.0 working tree based on v3.0.0 | **Date:** 15 November 2026 Asia Manila

## Recommendation

The application is conditionally ready for controlled ordinary-use UAT on the same machine. It is not ready for peak-deadline or production operation. Ordinary load passed every declared threshold, health and recovery behavior passed after a documented improvement, and all regressions passed. Peak throughput reached 6.648 requests/second against the declared 8 requests/second target.

## Scope and deployment

The bounded workflow remains consultation request, schedule confirmation, agenda, meeting status, action items and follow-up, with simulated reminders and summaries. The deployment uses a Flutter release build on HTTPS 8444, a Python TLS gateway on HTTPS 8443, Laravel on loopback 8000, XAMPP MariaDB 10.4.32, and the Laravel scheduler. All data is fictional. Thesis document storage, grading, plagiarism detection, live meetings, real notification delivery and public hosting remain out of scope.

The selected loopback deployment provides real TLS, browser, API, database and scheduler behavior without publishing controlled data. A hosted staging alternative was rejected for this milestone because no public hosting, credential, data-governance or cost decision was approved. The selected topology is reproducible but uses development-grade process supervision and a single PHP worker.

## Workload and results

The recorded mix was 70 percent authenticated consultation reads, 15 percent liveness and 15 percent database readiness. The ordinary model used two workers and 60 requests; the peak model used twelve workers and 240 requests after warm-up.

| Criterion | Ordinary result | Peak result | Decision |
|---|---:|---:|---|
| Unexpected errors | 0 of 60 | 0 of 240 | Pass |
| Error-rate limit | 0% of required 0% | 0% of allowed 1% | Pass |
| p95 latency | 334.015 ms <= 1,000 | 1,897.461 ms <= 2,000 | Pass |
| Throughput | 6.601 rps >= 2 | 6.648 rps < 8 | Ordinary pass, peak fail |
| Process working set | All below 48 MiB | All below 48 MiB | Pass within short sample |
| Recovery readiness | Not applicable | Main service returned 200 after fixture | Pass |

An initial `localhost` run failed timing thresholds because the Python client attempted IPv6 before the IPv4-only gateway. The complete failed summary and raw rows were retained. Explicit `127.0.0.1` removed that address-resolution delay without changing workload or thresholds.

## Monitoring and failure detection

`/up` reports process liveness. `/ready` checks the configured database socket and executes a query. The first unreachable-database test timed out after five seconds. A PDO timeout setting alone remained too slow on Windows, so a one-second socket preflight was added. The rerun returned safe HTTP 503 in about 1.36 seconds, protected logs recorded only the exception class, and the main service returned HTTP 200 after the isolated fixture stopped.

Correlation IDs connect API responses to protected logs. The controlled environment still lacks an alert manager, time-series dashboard and automated restart; the local operator owns manual probes and recovery.

## Environment separation and security

Automated tests use a dedicated `_test` schema. Local development may use HTTP and a Flutter development server. Week 16 uses a release build and short-lived trusted localhost certificate. Private `.env`, passwords, the encryption keyring and TLS private keys remain ignored. The final scan inspected 287 candidate text files and found no generated-secret or private-key match. The local CA expires on 22 November 2026 and must be removed from the user trust store after the exercise.

## Verification

The final backend suite passed 27 tests and 238 assertions. Flutter passed 22 tests, static analysis reported no issues, Laravel Pint passed, and the release web build completed. Actual Edge screenshots show the valid HTTPS login and live readiness response. A VS Code screenshot shows the database readiness implementation. These screenshots supplement raw requests and logs; they do not substitute for backend evidence.

## Rollback and recovery

Week 16 adds no migration, so the verified source rollback boundary is tag `v3.0.0` at `134077c`. Stop incoming work and the scheduler, preserve logs, deploy the tagged source with matching lockfiles, retain the private configuration, and require liveness, readiness, login, consultation read and full regressions before resuming. The Week 16 exercise required recovery, not data restoration, because its isolated failure never reached the main database.

## Prioritized improvements

1. Deploy an approved multi-worker application server behind a maintained reverse proxy and rerun the peak model until throughput reaches the declared target.
2. Add automated health polling, time-series metrics, alert windows and an assigned responder.
3. Rehearse encrypted backup restoration on a dedicated staging copy and measure recovery time and data-loss limits.
4. Run spike and endurance workloads with representative network delay.
5. Replace the local CA and manual secrets with approved certificate and secret lifecycles.

## Limitations

This is a short single-machine loopback test. Fresh TLS negotiation is included in each measured request. Shared hardware, the PHP CLI server and Python gateway limit inference. No real users, public network, maintained staging host, backup restoration, centralized monitoring, institutional certificate, real notification transport or production approval was tested.

## Acknowledgment

This work used Flutter, Laravel, MariaDB, Python, LibreOffice-compatible document tooling and AI-assisted drafting and verification. Final acknowledgment wording remains subject to institutional or instructor requirements.

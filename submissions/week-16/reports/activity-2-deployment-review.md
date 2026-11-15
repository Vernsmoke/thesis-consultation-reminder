# Activity 2 Incomplete Release Package Review

**Student:** Laurence Matthew B Manuel | **Section:** BSIT 3A | **Date:** 15 November 2026

## Review decision

The reviewed package is conditionally usable for controlled ordinary-use UAT on the same machine. It is incomplete for peak-deadline or production operation because the peak throughput target failed and operational controls remain local and manual.

## Incomplete package fixture

The tabletop fixture assumed a package with the Week 15 source, release Flutter build, example configuration, local HTTPS scripts and database migrations, but without Week 16 health separation, bounded database probe, workload evidence, automated restart, centralized monitoring, backup restoration evidence, or an institutional certificate lifecycle.

## Blockers and conditional risks

| Priority | Finding | Evidence | Disposition |
|---|---|---|---|
| Blocker | Peak throughput is 6.648 rps against an 8 rps target | Final performance summary | Block peak-deadline promotion; retest multi-worker topology. |
| Blocker | No approved production host, certificate or operational owner | Environment comparison | Do not claim production readiness. |
| High | Initial readiness probe exceeded five seconds on unreachable database | Initial failure record | Fixed with one-second socket preflight; rerun passed. |
| High | No automatic alerting or supervised restart | Monitoring map | Manual operator only for controlled UAT. |
| High | No staging backup restoration exercise | Rollback plan | Rehearse on a dedicated staging copy before broader use. |
| Medium | Short local run cannot establish endurance | Workload record | Add at least a one-hour endurance test after topology change. |
| Medium | Seven-day local CA requires manual rotation and removal | Environment record | Replace with approved certificate lifecycle. |

## Approaches compared

The selected approach keeps the existing loopback environment and adds explicit health, raw measurements, manual response ownership, and a rollback boundary. It is inexpensive and reproducible for the course, but capacity and recovery conclusions are narrow. The alternative is a dedicated staging host with a multi-worker server, managed reverse proxy, centralized logs, scheduled backups, and alerting. That approach better represents deployment, but needs infrastructure approval, credentials, maintenance responsibility, and possibly cost.

## Adverse case and improvement

The isolated package first left PDO connection timing unbounded, so readiness did not answer within five seconds. Adding `DB_CONNECT_TIMEOUT=3` alone still took about 8.5 seconds on Windows. A one-second TCP socket preflight was then added before the database query. The rerun returned 503 in about 1.36 seconds, exposed no connection detail, and the main service returned 200 after fixture termination. Full Laravel and Flutter regressions passed.

## Prioritized plan

1. Replace the PHP CLI server and Python gateway with a maintained multi-worker application server and reverse proxy, then rerun the identical peak model.
2. Add automated readiness polling, time-series metrics, alert windows and named response ownership.
3. Rehearse encrypted backup restoration on a dedicated staging database and record recovery time and data-loss limits.
4. Run spike and one-hour endurance models with representative network latency.
5. Establish approved certificate and secret rotation before any broader deployment.

## Interpretation

The evidence supports the package as a controlled learning and UAT environment under ordinary load. The failed peak threshold is a release blocker for deadline-burst use. The readiness improvement demonstrates safe failure detection, but it does not replace operational alerting or backup proof. The authorized reviewer should accept only the bounded recommendation and keep every broader claim pending.

## Acknowledgment

This review used Flutter, Laravel, MariaDB, Python and AI-assisted drafting and verification. Final acknowledgment wording remains subject to institutional or instructor requirements.

# Rollback and Recovery Plan

## Triggers

Rollback or stop routing new work when readiness stays 503, unexpected response errors exceed 1 percent, migrations fail, secrets appear in an artifact, authentication/authorization regressions occur, or p95 latency remains above the approved workload threshold. The peak throughput miss in this evaluation blocks promotion to peak-deadline use but does not require reverting the readiness endpoint.

## Compatible rollback boundary

Week 16 adds no database migration and does not change the workflow contract. The source rollback boundary is the verified Week 15 tag `v3.0.0` at `134077c`. The user, not the agent, owns any Git checkout or tag action. Before rollback, preserve logs and timestamps, stop the scheduler and incoming requests, and confirm that no migration or data repair is pending.

## Procedure

1. Record the trigger, time, current source revision, health responses and correlation identifiers.
2. Stop the scheduler and HTTPS/static processes so no new work enters the deployment.
3. Preserve the private `.env`, keyring and database backup outside the source package. Never copy secrets into evidence.
4. Deploy the reviewed `v3.0.0` source snapshot with its matching lockfiles and run `composer install` and `flutter pub get` from approved sources.
5. Restore a database backup only if integrity is affected. No restore was needed in the Week 16 failure exercise because the isolated fixture never connected to or changed the main database.
6. Start MariaDB, Laravel, scheduler, gateway and Flutter static host in that order.
7. Require `/up` 200, `/ready` 200, login and one bounded consultation read, then rerun the regression set.
8. Document the result and do not resume broader use until the authorized reviewer accepts the evidence.

## Rehearsed recovery

The fixture launched a separate Laravel process with an unreachable database port. The system reported liveness 200 and readiness 503 in about 1.36 seconds after the socket-preflight fix. The fixture was terminated, and the main environment returned readiness 200. No database restore or source rollback was required. This rehearses dependency isolation and service recovery, not a destructive backup restoration.

# Thesis Consultation Automation Case

Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29

Prepared 8 November 2026 | Asia/Manila | Week 13 SA7

## Purpose and bounded result

The Week 13 prototype connects a Flutter Web interface, Laravel API and XAMPP MariaDB to manage thesis consultation requests, human schedule confirmation, agendas, meeting status, action items and follow-up. A durable outbox automates reminders, missed-session handling, action deadlines and progress summaries. Delivery is a controlled simulated database receipt; it is not email or SMS and has no instructor-approved transport claim.

## Workflow and decision authority

Students request their own consultations. Assigned advisers confirm schedules, add action items and record outcomes. Panel members read assigned consultations. Coordinators review the workflow and record human handling of delivery exceptions. The server determines role and ownership from authenticated stored users. Automation does not approve meetings, assess research quality or award grades.

## Architecture and alternatives

The selected hybrid handles human state changes through validated API calls and scans due work each minute. A relational outbox preserves work when the scheduler is stopped and deduplicates business events with unique keys. Browser timers were rejected because they stop with the client. A separate broker queue could reduce latency and improve scale, but adds a service and worker operations to this local prototype. Database scanning incurs read and locking costs and needs an operator to keep scheduling alive.

## Evidence scope

The portfolio contains implementation source, configuration examples, repeatable tests, sanitized execution records, editable diagrams, decisions and recovery guidance. Tests cover successful and adverse paths. Real source captures and user-supplied running Flutter screenshots preserve the request, confirmation, action-item, validation, manual-review, desktop, tablet and narrow-layout states. Automated tests and HTTP/log evidence remain the behavioral proof behind those visual records.

# Reliable Execution and Protected Configuration

Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29

Prepared 8 November 2026 | Asia/Manila | Week 13 SA7

## Triggers and time rules

Timestamps are stored in UTC; the interface labels Manila display times and UTC form input. A confirmed future meeting within 24 hours receives one reminder. A confirmed meeting without a recorded outcome becomes missed after 30 minutes. Open action items reaching due time generate one deadline event. A current-day progress summary is due at or after 17:00 Manila. These are explicit project decisions, not instructor-established rules. Prior-day summary backfill is a known limitation.

## Failure and recovery contract

The worker processes at most 50 eligible events per batch. Transient failures receive exponential delays of 60 then 120 seconds plus 0 to 15 seconds jitter. Three total attempts is the cap. Permanent failures immediately enter manual review. Early runs skip the next-available timestamp. A simple circuit breaker stops a batch after three transient failures. Stale reminder/deadline work is superseded rather than delivered. This is not a distributed production circuit breaker.

## Idempotency and durable checkpoints

Consultation creation requires a per-user idempotency key and matching payload hash. A replay returns the stored consultation ID, while changed input under the same key returns 409. Automation uses unique event keys and one receipt per outbox row. Row locks serialize processing. For this simulated transport, the receipt, attempt state and audit commit in one transaction; a controlled crash test verifies rollback and safe rerun. A real external provider would need its own deduplication and reconciliation.

## Configuration and access

The backend uses private environment configuration, generated local credentials, password hashes and hashed two-hour bearer sessions. Flutter contains no confidential service credentials. CORS is restricted to loopback origins; it is not an authorization control. Role and ownership checks, server validation, safe JSON errors, correlation identifiers and allowlisted audit fields protect the local foundation. HTTPS and the Week 14 secure-exchange exercise remain outside Week 13.

# Verification Evaluation and Limitations

Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29

Prepared 8 November 2026 | Asia/Manila | Week 13 SA7

## Observed controlled delivery

The real-time experiment took 190.52 seconds. A success produced one receipt at attempt 1; a transient failure recovered at attempt 2; a permanent failure entered manual review at attempt 1; and a persistent timeout entered manual review at attempt 3. The final state contains two receipts and two manual-review events, with zero pending events. Capture time: 2026-11-08T18:09:45+08:00. The complete attempt timeline, correlations and sanitized audits are preserved in logs/controlled-delivery.json.

## Repeatable checks and improvement

The backend suite exercises the full request-to-follow-up path, invalid and boundary input, expired authentication, wrong roles/owners, idempotency conflicts, missing records, invalid transitions, stale reminders, all four automations, retry recovery, exhaustion and crash rollback. The initial suite had one fixture failure: advancing the clock to 2030 expired 2026 sessions. Renewing the controlled test session after clock travel corrected the fixture without weakening production authentication. Initial failures remain documented; the final log and JUnit report provide exact current counts.

## Performance and maintainability

Worker output records elapsed milliseconds, processed count, transient failures and pending/manual backlog. The experiment demonstrates bounded behavior for a small controlled fixture; it does not measure peak throughput, resource usage or production availability. Separate controller, automation, transport and audit components allow a future transport change without moving service credentials into the client. Lockfiles, dedicated test schemas and one command for due scans support reproduction. Scans currently load matching rows into memory and require workload evaluation before broader use.

## Residual risk and maintenance

An operator must monitor scheduler exit status, pending age and manual-review count. The prototype has no independent external alert channel, real delivery guarantee, full account administration or production deployment evaluation. Action creation must be reconciled after an ambiguous response. The coordinator records human handling without resetting failed attempts. Before wider use, verify secure transport, provider idempotency/timeouts, data retention, workload behavior and operational ownership.

## Sources and academic responsibility

Teacher Project 29 and Module 13 define the scope. Official Laravel 12 deployment/scheduling documentation, Flutter responsive design guidance and Microsoft Azure Retry pattern informed implementation decisions; URLs are listed in docs/decisions.md. AI assisted source, tests and documentation with user permission. On 8 November 2026, the student confirmed that the reflection reflects their understanding and that Project 29 registration is approved. Any instructor-prescribed acknowledgment wording, final oral assessment and marks remain outside this report.

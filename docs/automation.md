# Trigger contract retry and recovery

## Contract and project decisions

`php artisan consultations:tick` scans durable trusted server state then attempts at most 50 due deliveries. `php artisan schedule:work` invokes the registered minute schedule; it must remain running. Scheduler overlap lock expires after five minutes; database row locks protect repeated/concurrent processing. API requests do not invoke worker controls.

All stored timestamps UTC; Flutter labels converted Manila timestamps and explicitly requests UTC input. Local display zone Asia/Manila. Reminder: one event when confirmed future meeting is ≤24h away. Missed: confirmed meeting reaches scheduled time +30m without completed/cancelled status; coordinator/adviser can reconcile completion. Deadline: open action reaches due time. Summary: one current-day event per student at/after 17:00 Manila with completed/missed meeting counts and open action count. Repeated scans use keys reminder:ID, missed:ID, deadline:ID, summary:STUDENT:DATE. No backfill for missed prior-day summaries; outage limitation is explicit. Late reminders beyond meeting time are suppressed; missed handling replaces them.

Trusted inputs: validated database rows and server time. Preconditions: available MariaDB, migrations, fictional users, running scheduler, correct host clock. Outputs: one simulated receipt and an audit transition or a retained retry/manual-review row. Payload includes minimal entity references/times or aggregate counts, not agenda/description or real contacts. Receipt recipient_id identifies the fictional student. Human role boundaries remain server controlled.

## Failure taxonomy and policy

| Category | Examples | Safe behavior |
|---|---|---|
| Invalid/business | Missing agenda, past time, wrong adviser role, impossible transition | 422/409, no mutation, no retry |
| Authentication/authorization | Expired token, other owner, panel attempts mutation | 401/403, no privileged work |
| Transient | Injected temporary unavailable/timeout | Retain row, backoff; no receipt until success |
| Permanent | Injected invalid recipient | First attempt manual_review, visible coordinator queue |
| Exhausted | Persistent timeout | Third total attempt manual_review, later ticks do nothing |
| Crash/database outage | Exception while writing receipt/state | Transaction rollback and command failure; rerun after recovery |
| Stale work | Cancellation/completion before delivery | Superseded, no delivery |

Exponential backoff: 60×2^(attempt−1) seconds plus random 0–15s jitter. Three total attempts (initial plus two retries), not three extra retries. Early ticks skip unavailable_at. Stop a batch after three transient failures; next minute retries eligible records. This is a simple batch circuit breaker, not a complete distributed implementation. Simulated transport has bounded local database work and no network wait. Laravel MySQL PDO connect timeout defaults are not an external-provider timeout. A future real transport must set an explicit short connection/request timeout and share the durable idempotency key with the provider.

## Recovery runbook

1. Operator checks command exit status and coordinator automation metrics. Any manual_review >0 requires coordinator review; pending age >5m warrants scheduler/database inspection.
2. Check XAMPP MariaDB and `php artisan schedule:list`; restart the local scheduler only after database health is restored. Never dump .env or tokens into evidence.
3. Run `php artisan consultations:tick` once and retain sanitized JSON timing/backlog output. Do not delete pending rows or reset attempts.
4. For a permanent/exhausted row, inspect event kind/entity/correlation and protected audit. Reconcile whether the student received simulated receipt. Record controlled human follow-up and close through coordinator resolve API; do not pretend notification was delivered.
5. An operator-authorized new notification would require a separately documented new business event; the UI deliberately does not reset retries. Resolved rows stay auditable.
6. If crash occurs during simulated delivery, receipt and attempt rollback together; rerun safely. External provider side effects would require provider deduplication or reconciliation and are outside this prototype guarantee.

Checkpoints are persisted event status and attempts. No destructive compensation: supersede stale notification work rather than reversing adviser decisions. Keep operational logs protected; retain only sanitized exports for assessment. Local prototype retention decision: clear controlled fixture sessions at test reset, keep evidence intentionally; production retention requires approval.

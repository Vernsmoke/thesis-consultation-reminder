# Week 13 decisions and pattern comparison

Date 2026-11-08. Decisions are project choices, not instructor-approved rules. Authority: user controls scope, adviser confirms meetings, coordinator handles delivery exceptions; instructor decides course acceptance.

## ADR 01 Automation boundary

Question: how can a consultation workflow stay explainable and recoverable on the required local stack? Select Laravel domain services plus relational outbox; Flutter handles interaction only. Alternative: client timers are quick but disappear when browsers close and expose privileged decisions. Separate queue broker workers offer scale and low latency but add another service and operational burden. A database transaction is available in XAMPP and allows receipt, audit and delivery state to commit together for this simulated transport. Consequence: scans and locks add database load; one host owns scheduling. Review when moving to a real provider or several workers.

## ADR 02 Trigger patterns

| Pattern | Latency and volume | Reliability risks | Security and staffing |
|---|---|---|---|
| Time schedule | Up to one minute plus outage catch-up, batch 50 deliveries | Clock drift or stopped scheduler; persistent due rows catch up | No inbound callback; operator starts scheduler |
| Queue | Low latency, natural back-pressure | At-least-once delivery requires deduplication and worker management | Broker credentials and extra service |
| Webhook | Near-real-time external event | Duplicate/out-of-order/lost callbacks | Authenticated receiver and replay protection required |
| Polling | Interval latency, repeated reads | Missed intermediate changes unless checkpointed | Simple local ownership, database cost |
| Change-data event | Low latency at high volume | Ordering/schema and connector checkpoints | Privileged database connector; excessive for local prototype |
| Hybrid selected | Human state updates immediately; time scans enqueue due work | Unique event keys plus transactions; scanner outage still delays alerts | No public worker endpoint, local CLI owned by operator |

## Activity 1 Three contrasting office workflows

These are self-created classroom examples using the module's university-office setting. Only consultation workflow is implemented; the other two are comparative cases.

| Workflow | Assumed constraints | Selected vs alternative | Failure and owner |
|---|---|---|---|
| Consultation reminders | 100 consultations/day, ≤1-minute scan latency acceptable, one operator | Scheduled scan + durable outbox vs browser timers. Durable recovery wins; polling/locks cost reads | Scheduler unavailable: retain due rows, operator runs tick and checks age |
| Urgent service request acknowledgment | 500/day, seconds latency, office staffed during service hours | API transaction + queue vs nightly batch. Queue meets latency but needs worker monitoring | Duplicate request: stable key returns existing result; coordinator handles poison input |
| Daily office pending summary | 1/day per responsible office, fixed cutoff, modest volume | Scheduled snapshot vs webhook per record. Schedule gives clear day boundary but can be late | Date-keyed output, catch-up same day; office operator checks missing summary |

Interpretation: observed facts are limited to implemented consultation tests and timing records. Assumed office volumes are decision inputs, not measurements. The selected hybrid suits local reproducibility and one operator, with weaker outage notification and scaling than a managed queue. A real provider needs provider-side idempotency and timeouts; SQL receipts cannot establish real email delivery. Next improvement: oldest-pending alert to the coordinator through an independently monitored channel. Acceptance remains instructor/authorized office owner dependent.

## ADR 03 Reliability and recovery

Select durable rows, unique business event keys, row locks and transactional simulated receipts over in-memory callbacks. Retry only transient failures, stop at three total attempts, and record exceptions visibly. Permanent failures never auto-resend. Cost: manual backlog and operational review. Circuit breaking is per batch after three transient outcomes; it is not a distributed, time-window circuit breaker. Review for production external transport. A compensating action cancels stale pending reminders, without undoing a real human consultation decision.

## ADR 04 Protected configuration

Select private .env with generated secrets and hashed bearer sessions over client-held shared service credentials. Role comes from stored user, never client role input. Dependencies locked. Cost: operator must provision/rotate local secrets and keep .env outside artifacts. Production identity lifecycle, HTTPS and crypto exchange are deferred to requested Week 14. Local loopback HTTP is not a secure deployment.

## ADR 05 Evidence and maintainability

Select automated API/worker assertions, durable audits and real browser captures over screenshots alone. They give reproducible outcomes; screenshots show usability but cannot prove transactions. Small services separate scheduling, delivery and audit. Cost: test fixtures need clock/session discipline and schema ownership. Metrics expose backlog, deliveries and attempts; no claim of full monitoring, high-volume capacity, availability SLA or production readiness. Review when workloads, hosting or notification transport change.

## Sources and assistance

AI assisted implementation, tests, documentation and review. Student must review, reproduce and independently explain work; no personal contribution claim is manufactured. Framework/library authors retain their licenses. Original teacher guides define requirements and are not redistributed.

Official references consulted 2026-11-08: https://laravel.com/docs/12.x/deployment ; https://laravel.com/docs/12.x/scheduling ; https://docs.flutter.dev/ui/adaptive-responsive ; https://learn.microsoft.com/azure/architecture/patterns/retry . Laravel dependency requirements verified against installed PHP through Composer. Runtime versions come from actual commands, not web assumptions.

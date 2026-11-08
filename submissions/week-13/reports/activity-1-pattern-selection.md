# Office Workflow Trigger Selection

Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29

Prepared 8 November 2026 | Asia/Manila | Week 13 SA7

## Task and assumptions

This Activity 1 record compares three self-created classroom workflows within the module university-office setting. Only Project 29 consultation automation is implemented. Volumes are assumptions for choosing a pattern, not measured workload results. The instructor or authorized office owner decides acceptance. Controlled data, one operator and no production integrations constrain the build.

## Consultation reminders

Assume 100 consultations per day and up to one minute of scan latency. Select scheduled database scans with durable outbox delivery over browser timers. The chosen pattern survives client closure and retains due records during scheduler outages; it costs repeated reads and requires clock and scheduler checks. A unique meeting reminder key prevents duplicate output. An unavailable scheduler delays notification, so the operator must inspect pending age and run a recovery tick.

## Urgent request acknowledgment

Assume 500 service requests per day and a seconds-level acknowledgment goal during staffed hours. Select transactional enqueue followed by queue execution over a nightly batch. A queue decouples response latency and supports back-pressure, but duplicate delivery and poison input still require idempotency and a human exception owner. A broker adds credential management and worker staffing. This is comparative design, not an implemented or benchmarked second application.

## Daily pending office summary

Assume one summary per office per day with a known cutoff and modest volume. Select a date-keyed scheduled snapshot over a webhook for every record change. The schedule matches the reporting boundary and requires fewer events; it can be late if the scheduler stops. Webhooks provide freshness but require authenticated callbacks, replay control and ordering logic. The office operator checks for a missing date-keyed summary. Prior-day catch-up requires an explicit retention and backfill policy.

## Matrix and verification

docs/decisions.md compares schedules, queues, webhooks, polling, change-data events and the selected hybrid across latency, reliability, security and staffing. diagrams/workflow.svg and screenflow.svg show the implemented workflow. Reproduce the consultation behavior with php artisan test and consultations:tick. The safe adverse cases include duplicate requests, invalid input, wrong roles and dependency failure. Configuration changes are confined to the implemented Project 29 service and example environment.

# Activity One Interpretation

Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29

Prepared 8 November 2026 | Asia/Manila | Week 13 SA7

## Observed facts

The consultation implementation creates durable due events, enforces server roles and processes a bounded batch. Repeated scan and worker tests assert no duplicate receipt. Controlled execution records show transient recovery and retained manual-review states. Other office examples have no execution evidence and are not presented as working software. Test logs and source must be inspected alongside the diagrams; diagrams describe structure rather than prove execution.

## Reasoned conclusions

A hybrid of immediate human state updates and scheduled due scans is a reasonable local choice where minutes of latency are acceptable and MariaDB is already required. The relational outbox reduces service count and provides persistent checkpoints. A low-latency acknowledgment workflow would justify queue operations that reminders alone do not. A daily summary needs a reporting cutoff more than it needs an event for every field change. These conclusions depend on assumed volume and staffing.

## Consequences and recommendations

The selected local design introduces database reads, lock contention and scheduler ownership. Its maintainability benefit is explicit services, versioned dependencies and reproducible tests; it does not eliminate operations. Compare ordinary and peak workloads before claiming capacity. Add an independently monitored oldest-pending alert and define multi-day summary backfill before institutional use. A real notification provider needs bounded network timeouts and provider-side idempotency. Keep human approval for exceptional cases and restrict the prototype to fictional data until authorized.

## Self check and limitation

Another learner can rebuild the tested services from the setup instructions, but must supply private configuration and a running XAMPP database. Browser verification, source screenshot permissions, project registration and the student explanation remain external gaps. No option is declared production ready. A reviewer should use the requirement checklist and evidence index to distinguish tested consultation behavior from the comparative scenarios.

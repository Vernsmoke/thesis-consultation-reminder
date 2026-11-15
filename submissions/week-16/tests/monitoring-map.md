# Monitoring Map and Detection Walkthrough

| Signal | Meaning | Evidence or threshold | Owner and response |
|---|---|---|---|
| `GET /up` | Laravel process liveness only | HTTP 200 | Local operator restarts the process if unavailable. It does not prove database readiness. |
| `GET /ready` | Database socket and query readiness | HTTP 200 with `database: up`; HTTP 503 with `database: down` | Local operator stops routing new work, checks MariaDB and configuration, then requires a 200 recovery probe. |
| `X-Correlation-ID` | One API request across client response and protected log | Present on API responses | Developer uses the identifier to locate the matching safe log event. |
| Structured workflow log | State transition or outcome without payload secrets | Laravel log and audit rows | Coordinator or developer investigates permanent/retry outcomes. |
| Workload error rate | Unexpected status, timeout, or transport error | ordinary 0%; peak limit 1% | Developer halts readiness claim if exceeded. |
| p95 latency and throughput | User-facing delay and achieved capacity | ordinary <=1,000 ms and >=2 rps; peak <=2,000 ms and >=8 rps | Developer compares raw rows and topology before attributing a bottleneck. |
| Working set samples | Per-process memory signal | below 1 GiB in this exercise | Developer investigates sustained growth; short samples cannot prove leak freedom. |
| Scheduler output | Automation loop remains active | scheduled command output and process state | Local operator restarts the scheduler and checks overdue work. |

Detection walkthrough: the isolated fixture points its separate Laravel process to an unreachable database port. Liveness remains 200 because PHP can serve requests. The one-second socket preflight makes readiness return 503 with a safe dependency label. A warning log records the exception class without connection credentials. The fixture is terminated, and the unchanged main environment must return readiness 200. This distinguishes process availability from the ability to serve database-backed work.

No production alert manager exists. During controlled UAT, the local operator owns manual probes and log review. Before broader use, an approved monitoring service must poll the endpoints, retain time-series metrics, define alert windows, and assign an operational responder.

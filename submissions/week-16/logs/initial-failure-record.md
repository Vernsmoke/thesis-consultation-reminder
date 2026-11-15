# Initial Week 16 Failure Record

## Observation

At 2026-11-15 21:49 Asia/Manila, the first completed workload rerun reached the isolated database-dependency exercise. The fixture launched a separate Laravel process on port 8001 with `DB_PORT=65530`. Its `/up` liveness response succeeded, but `/ready` did not respond within the harness's five-second timeout. Python raised `TimeoutError` while awaiting the response, and the harness correctly refused to write a passing summary.

The earlier attempt at 21:38 also failed to finalize because the fixture process output pipe remained inherited after termination. That was a harness shutdown defect, not an application result. The pipe was replaced with a null sink and the attempt was excluded from measurements.

## Prediction and actual result

| Item | Predicted | Actual |
|---|---|---|
| Liveness with database unavailable | HTTP 200 | HTTP 200 |
| Readiness with database unavailable | HTTP 503 within five seconds | Client timeout after five seconds |
| Main environment | Unaffected | Remained available |
| Data or secret exposure | None | None observed |

## Root cause and improvement

The database configuration had no explicit PDO connection timeout, so an unreachable dependency could consume the readiness probe's entire client budget. `DB_CONNECT_TIMEOUT=3` was added to the nonsecret example configuration and applied to both MySQL and MariaDB PDO options. A manual rerun showed that Windows PDO still needed about 8.5 seconds to reject the unreachable port, so that setting alone did not satisfy the five-second probe and was not accepted as the complete fix. The readiness route now performs a one-second TCP socket preflight before the query. It still validates a real query when the socket is reachable, while failing fast when the dependency cannot be contacted. The response reports only `database: down`; protected logs retain only the exception class.

## Required rerun

Rerun the isolated fixture and require HTTP 503 before the five-second client limit, then confirm the main deployment returns HTTP 200 readiness. Rerun ordinary and peak workloads and the complete backend/Flutter regressions so the configuration change is not accepted on the failure case alone.

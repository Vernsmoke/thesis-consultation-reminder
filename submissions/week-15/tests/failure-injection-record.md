# Week 15 Controlled Failure Injection Record

| ID | Predicted behavior | Injection | Actual observation | Recovery and data integrity | Evidence |
|---|---|---|---|---|---|
| FI-01 unavailable endpoint | fail within two seconds, no loop, no sensitive output | HTTPS client calls unused localhost port 65530 | connection failure was bounded; live suite continued | next authorized API request returned 200 | API-13/API-14 JSON |
| FI-02 request timeout | distinguish idempotent and non-idempotent advice | Flutter `MockClient` throws `TimeoutException` | idempotent request advises same form/key; non-idempotent request advises status check | caller retains control; no automatic duplicate request | Flutter tests |
| FI-03 worker timeout exhaustion | three attempts then human review | simulated transport timeout | outbox stopped at three attempts with zero receipts | manual-review path remains actionable; no endless retry | Laravel test |
| FI-04 process crash after tentative receipt | rollback all partial state | simulated delivery writes then throws | receipt count returned to zero; outbox remained pending with attempts zero | normal worker rerun delivered exactly once | Laravel test |
| FI-05 duplicate submission | same request returns prior result; changed input conflicts | same idempotency key replayed | same payload returned original ID; changed agenda returned 409 | consultation count remained one in isolated test | API-02/API-03 and Laravel test |
| FI-06 malformed upstream payload | report protocol failure, not network outage | HTTP 200 contains HTML | Flutter emitted safe 502 message | user can retry/contact coordinator without raw content exposure | Flutter test |

Observed facts are limited to these controlled paths. Concurrency under many simultaneous external clients and public-network faults remain untested.

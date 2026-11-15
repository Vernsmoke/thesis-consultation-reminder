# Environment and Configuration Comparison

| Area | Automated test | Local development | Week 16 controlled deployment | Broader nonproduction requirement |
|---|---|---|---|---|
| Frontend | Flutter widget test process | Flutter development server | Release web build on HTTPS 8444 | Maintained static host or reverse proxy |
| API | Laravel test kernel | `artisan serve` on HTTP loopback | `artisan serve` behind local HTTPS gateway | Multi-worker application server behind maintained TLS proxy |
| Database | Dedicated `_test` schema with rollback | XAMPP MariaDB controlled schema | Same controlled schema and fictional data | Dedicated staging database, backup/restore rehearsal, least privilege |
| Secrets | Test fixtures | Private ignored `.env` | Private ignored `.env`, keyring, TLS keys | Approved secret injection and rotation service |
| TLS | Framework simulation where applicable | Optional HTTP | Seven-day local CA and TLS 1.2+ | Approved certificate lifecycle and trust chain |
| Health | Feature tests | Manual | `/up` liveness and `/ready` database readiness | Automated polling, metrics and alert ownership |
| Logging | Test output | Local log | Structured local log and correlation IDs | Central protected retention and access policy |
| Automation | Command tests | Optional scheduler | `schedule:work` process | Supervised scheduled worker with restart policy |
| Capacity | Not representative | Interactive only | Short single-machine ordinary and peak runs | Endurance, spike, representative network and multi-worker tests |

The selected environment is appropriate for repeatable course evidence because it uses the required Flutter, Laravel, and XAMPP-compatible MariaDB stack without publishing data. Its local CA, PHP CLI server, Python gateway, manual process supervision, and shared machine resources make it unsuitable as a production topology.

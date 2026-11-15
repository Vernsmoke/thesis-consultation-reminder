# Week 16 Requirement to Artifact Checklist

Student: Laurence Matthew B Manuel  
Section: BSIT 3A  
Milestone: v4.0.0 working tree based on verified Week 15 tag v3.0.0  
Evidence date: 2026-11-15 Asia/Manila

| Requirement | Planned or verified artifact | Status |
|---|---|---|
| Topic 1 workload questions, user journeys, request mix, volume, concurrency, think time, warm-up, duration, thresholds | `tests/workload-models.md`, Activity 1 report | Complete |
| Topic 2 response-time percentiles, throughput, errors, resources, dependency timing, bounded interpretation | `tests/performance-summary.json`, `tests/performance-raw.csv`, evaluation report | Complete; peak throughput failed and is retained |
| Topic 3 liveness, readiness, logs, metrics, alerts, correlation, dependency and recovery signals | `/up`, `/ready`, `tests/monitoring-map.md`, failure record | Complete for controlled local scope |
| Topic 4 configuration, secrets, build, migrations, permissions, backups, release and environment separation | `tests/environment-comparison.md`, deployment checklist, `.env.example` review | Complete for controlled local scope |
| Topic 5 rollback triggers, data compatibility, backup restoration, degraded operation, communication and readiness | `tests/rollback-plan.md`, recovery record, readiness recommendation | Complete; staging restore remains external |
| Preparation: bounded workflow, trust boundaries, non-goals | evaluation report and deployment diagram | Complete |
| Preparation: measurable normal, invalid, unauthorized, dependency-failure and recovery criteria | `tests/workload-models.md` and scenario results | Complete |
| Preparation: fictional data and nonsecret example configuration | existing `example.test` fixtures and `backend/.env.example`; scan record | Complete |
| Preparation: compare two approaches with disadvantages | evaluation report and Activity 1 | Complete |
| Implementation: controlled nonproduction deployment | loopback HTTPS deployment record | Complete |
| Implementation: success plus at least four adverse paths | automated Laravel tests and live scenarios | Complete through 27-test regression and failure evidence |
| Implementation: Flutter loading, success, empty, validation, authentication, authorization, network and server states | prior regression plus Week 16 browser verification | Complete through 22 tests and real browser deployment |
| Failure stage: prediction, safe injection, actionable signal, no corruption or secret disclosure | isolated invalid-database deployment record | Complete |
| Failure stage: justified improvement and regression rerun | readiness endpoint tests and full regressions | Complete |
| Desktop and narrow browser evidence | actual desktop screenshots; narrow automated regression | Complete; Week 16 narrow proof is automated, prior real narrow capture remains Week 15 |
| Activity 1: ordinary and peak workload models, limits of inference, adverse case and one-page interpretation | `reports/activity-1-workload-models.*` | Complete |
| Activity 2: incomplete-release tabletop review, blockers, conditional risks and prioritized evidence-linked plan | `reports/activity-2-deployment-review.*` | Complete |
| Assessment: measurements, configuration, monitoring, recovery, rollback, limitations and readiness recommendation | `reports/week-16-deployment-evaluation.*` | Complete |
| Reflection prompts answered from evidence without inventing personal experience | `reports/reflection-preparation.*` | Draft complete; student confirmation pending |
| Rubric: technical correctness | full regression, live deployment and failure evidence | Complete within stated scope |
| Rubric: reproducible and traceable evidence | scripts, raw results, index and hashes | Complete |
| Rubric: justified security and reliability with residual risk | evaluation and limitation records | Complete |
| Rubric: maintainer setup, decisions, recovery | README, deployment and rollback records | Complete for controlled environment |
| Rubric: professional defense and individual contribution | evidence-linked report; oral defense remains external | Prepared; defense external |
| Project 29: response time, throughput, errors, resources, health, environment comparison and recovery | Week 16 evidence set | Complete with failed peak criterion explicit |
| Acknowledgment of AI, libraries and external sources according to institutional wording | report acknowledgment; exact instructor wording | Pending instructor wording |
| Verified DOCX and PDF soft copies | rendered reports with page-by-page visual QA | Complete; 6 final pages visually inspected |

External actions that cannot be claimed here: instructor marking, oral defense, instructor-prescribed acknowledgment wording, and any approval for broader or production deployment.

# Project Status

## Project and current milestone

- Student: Laurence Matthew B Manuel
- Section: BSIT 3A
- Project: Project 29, Thesis Consultation Reminder System
- Workspace: `C:/Users/Laure/Documents/ChatGPT/IPT`
- Current authorized milestone: Week 16, Performance Reliability and Deployment Evaluation
- Work and evidence date: 2026-11-15 Asia/Manila; no evidence was backdated
- Required stack: Flutter Web, Laravel API, XAMPP MariaDB/MySQL-compatible database

## Confirmed Git state

- Branch: `master`; local Week 16 report revision is `e93f9a59be4628b77e19aa530dd818e278dd66b1`; `origin/master` remains at the verified Week 15 handoff until the authorized release push.
- Verified Week 15 tag `v3.0.0` remains at source release commit `134077c9a7ef13dd607c0bc763c80989144fe9bb`. Week 16 does not rewrite it.
- `origin` is `https://github.com/Vernsmoke/thesis-consultation-reminder.git`.
- At the user's explicit request on 2026-11-15, Week 16 was divided into four coherent commits: `2eaa689` readiness implementation, `db97652` evaluation design, `4574797` actual evidence, and `e93f9a5` reports.
- `v4.0.0` does not yet exist at this checkpoint. The reviewed release record is in `docs/week-16-git-commands.ps1`.
- Unrelated untracked future prompts, generated caches and prior `tmp` folders remain excluded from the release.

## Week 16 implementation completed

- Added distinct Laravel `/up` liveness and `/ready` database readiness contracts.
- Added a one-second database socket preflight followed by a real query, safe 503 response, protected warning log and explicit PDO connection timeout configuration.
- Added a deterministic HTTPS workload harness with ordinary and peak models, raw request rows, percentiles, throughput, error rates and Windows process resource samples.
- Added an isolated unreachable-database fixture that does not interrupt or modify the main controlled database.
- Preserved the bounded Week 15 workflow and added no schema migration or unrelated feature.

## Controlled deployment and findings

- Local nonproduction topology: Flutter release build on HTTPS 8444, Python TLS gateway on HTTPS 8443, Laravel on loopback 8000, XAMPP MariaDB 10.4.32 on 3306, and Laravel scheduler.
- The prior seven-day local certificate had expired on 2026-11-15. It was rotated and its new public CA was added to the current-user trust store. The new certificate expires 2026-11-22 21:31 Asia/Manila; private keys remain ignored.
- Initial database failure made readiness exceed the five-second probe. PDO timeout configuration alone still took about 8.5 seconds on Windows. The socket preflight reduced the observed failure response to about 1.36 seconds; the main environment recovered to readiness 200.
- Initial `localhost` workload evidence was retained after it exposed an IPv6-to-IPv4 address-resolution delay. The unchanged workload reran against certificate-covered `127.0.0.1`.
- Ordinary model: 60 requests, zero errors, 6.601 rps, p95 334.015 ms. All declared criteria passed.
- Peak model: 240 requests, zero errors, 6.648 rps, p95 1,897.461 ms. Error, p95, memory and recovery passed, but the declared 8 rps throughput target failed.
- Maximum sampled working sets were 46.80 MiB Laravel, 32.51 MiB gateway, 47.92 MiB MariaDB and 46.18 MiB scheduler.
- Readiness recommendation: conditionally ready only for controlled ordinary-use UAT on the same machine. Not ready for peak-deadline or production operation.

## Verification and evidence

- Laravel: 27 tests, 238 assertions, all passing; Pint passes.
- Flutter: 22 tests pass; analysis reports no issues; release web build succeeds. The build log retains a non-blocking Flutter tag-fetch network warning before successful compilation.
- Final secret scan: 287 candidate text files, zero generated-secret or private-key matches; protected paths remain ignored.
- Actual sanitized evidence captured in Edge and VS Code: trusted HTTPS Flutter login, live database readiness, and readiness source implementation.
- Four DOCX reports and four matching PDFs were created. Six final A4 pages were rendered and visually inspected; no clipping, overlap, broken tables or missing glyphs were found.
- The reflection document is an evidence-grounded preparation draft. Student confirmation of personal voice and independent contribution remains pending.

## Submission artifacts

- Workload definitions and acceptance criteria, raw/final/failed performance results, resource samples and reproducible harness.
- Monitoring map, detection walkthrough, environment comparison, deployment checklist, rollback plan and recovery record.
- Activity 1, Activity 2, main Week 16 evaluation and reflection preparation in Markdown, DOCX and PDF.
- Editable Mermaid deployment/monitoring diagram source, actual screenshots, evidence index, submission checklist, contents list and source manifest.
- Source and submission ZIPs will be generated locally from the confirmed `v4.0.0` tag after the release is pushed and verified.

## Pending external or user actions

1. Review and confirm that `reports/reflection-preparation.*` reflects the student's own understanding and individual contribution.
2. Apply any instructor-prescribed template or AI acknowledgment wording and complete instructor marking or oral assessment.
3. Create and verify annotated tag `v4.0.0`, push `master` and the tag, and build provenance-checked local packages.
4. Remove the local test CA from the current-user trust store after the controlled HTTPS environment is no longer needed.
5. Before peak-deadline or broader use, test an approved multi-worker staging topology, automated monitoring, supervised restart, backup restoration, endurance and institutional certificate/secret lifecycles.

## Next action

Remain on Week 16 until the Git release and packages are verified. Do not begin Week 17 or refresh earlier submission evidence. Student confirmation of the reflection's personal voice remains an external submission check and must not be fabricated.

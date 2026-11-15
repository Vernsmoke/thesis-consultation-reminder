# Activity 1 Ordinary and Peak Workload Models

**Student:** Laurence Matthew B Manuel | **Section:** BSIT 3A | **Date:** 15 November 2026 | **Course:** PFEBSIT 002

## Decision

I used a deterministic local HTTPS harness to evaluate the same bounded consultation read, liveness, and readiness paths under ordinary and peak models. The evidence supports controlled ordinary-use UAT. It does not support the predeclared peak throughput target or a production-readiness claim.

## Models and criteria

The ordinary model used two workers and 60 requests. The peak model used twelve workers and 240 requests. Both used a 70 percent authenticated consultation-read, 15 percent liveness, and 15 percent readiness mix after 20 warm-up requests. Ordinary acceptance required zero errors, p95 at most 1,000 ms, throughput at least 2 requests/second, and less than 1 GiB per sampled process. Peak acceptance allowed at most 1 percent errors, p95 at most 2,000 ms, throughput at least 8 requests/second, the same memory ceiling, and readiness recovery after failure.

## Alternatives and risks

The local harness required no external account and kept fictional data on the machine, but its fresh TLS setup, shared resources and short duration limit inference. A hosted load service would better represent network conditions, but would introduce unapproved hosting, data-handling and cost decisions. Browser-only timing cannot reproduce concurrency or preserve raw distributions.

## Observed facts

The first `localhost` run produced zero errors but failed both timing targets because the Python client tried the non-listening IPv6 loopback before IPv4. That failed summary and 300 raw rows were retained. The corrected `127.0.0.1` rerun kept the same thresholds and workload.

| Model | Requests | Errors | Throughput | p50 | p95 | p99 |
|---|---:|---:|---:|---:|---:|---:|
| Ordinary | 60 | 0 | 6.601 rps | 302.318 ms | 334.015 ms | 344.401 ms |
| Peak | 240 | 0 | 6.648 rps | 1,797.850 ms | 1,897.461 ms | 1,982.119 ms |

Maximum working sets were 46.80 MiB for Laravel, 32.51 MiB for the gateway, 47.92 MiB for MariaDB, and 46.18 MiB for the scheduler. The isolated database fixture returned readiness 503 and the main environment recovered to 200.

## Interpretation

The ordinary model passed every criterion. The peak model passed error, p95, memory, and recovery criteria but missed the 8 rps throughput target at 6.648 rps. The similar ordinary and peak throughput shows the single-worker PHP CLI topology reached its capacity ceiling while queueing increased latency. This does not show that Laravel or MariaDB cannot meet the target under a maintained multi-worker topology.

## Recommendation and limits

Use the deployment only for controlled ordinary-use UAT. Do not schedule peak-deadline evaluation until a maintained multi-worker server and reverse proxy are configured and the same workload is rerun. These short loopback results cannot establish internet latency, endurance, multi-host scaling, institutional backup readiness, or production operation.

## Evidence

The workload model, final and failed summaries, raw CSV, resource samples, and failure/recovery JSON preserve the reproducible record. This work used Flutter, Laravel, MariaDB, Python and AI-assisted drafting and verification; final acknowledgment wording remains subject to instructor requirements.

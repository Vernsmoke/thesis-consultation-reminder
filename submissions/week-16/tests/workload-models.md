# Week 16 Workload Models and Acceptance Criteria

## Decision question

Can the bounded consultation application support a small office's controlled UAT workload on the available local nonproduction stack while producing measurable health, error, timing, and recovery evidence?

## Selected approach and alternative

The selected approach uses a deterministic Python standard-library harness against the same loopback HTTPS gateway used by the Flutter release build. The harness uses the certificate-covered `127.0.0.1` address so Windows does not spend about two seconds attempting the non-listening IPv6 `localhost` address before IPv4. The initial failed `localhost` run is preserved separately. The harness preserves per-request rows, workload summaries, and process samples without adding a service or credential. Its disadvantages are fresh TLS setup per request, single-machine resource contention, and a short duration that cannot establish endurance.

The rejected alternative was a hosted load-testing platform or public staging host. It would better represent network latency and distributed load, but it would add external accounts, data-handling decisions, cost or quota risk, and a deployment scope that the user has not approved. A local browser-only timing exercise was also considered but rejected as the sole method because it does not provide reproducible concurrency, raw distributions, or resource samples.

## Common bounded journey and request mix

- Controlled fictional `example.test` student signs in once over HTTPS.
- 70 percent authenticated `GET /api/consultations?per_page=10` requests exercise session lookup, role visibility, pagination, database reads, and JSON serialization.
- 15 percent `GET /up` requests exercise process liveness.
- 15 percent `GET /ready` requests exercise database-backed readiness.
- Twenty requests at concurrency two warm the runtime before recorded workloads.
- Every response has an expected status. A timeout, transport exception, or different status counts as an error; no retry hides a failure.

## Model A ordinary office use

Two concurrent workers issue 60 total requests. This approximates a small office where a student and staff member browse or refresh during normal use. The harness does not add think time between completed requests, so it is deliberately more concentrated than interactive clicking.

Acceptance thresholds:

- zero unexpected responses;
- p95 response time at or below 1,000 ms;
- throughput at or above 2 requests per second;
- no sampled application process exceeds 1 GiB working set;
- readiness stays HTTP 200 throughout the healthy run.

## Model B peak deadline use

Twelve concurrent workers issue 240 total requests with the same mix. This represents a short deadline burst, not a sustained enrollment-scale or internet-wide load.

Acceptance thresholds:

- error rate at or below 1 percent;
- p95 response time at or below 2,000 ms;
- throughput at or above 8 requests per second;
- no sampled application process exceeds 1 GiB working set;
- the service recovers to readiness HTTP 200 after the separate dependency-failure fixture.

## Adverse and recovery criteria

An isolated Laravel process is started with an unreachable database port. Before execution, the predicted contract is liveness HTTP 200, readiness HTTP 503 with only a safe database-down indicator, then HTTP 200 readiness in the main environment after the fixture is stopped. The fixture must not modify data, disclose connection credentials, or interrupt the main controlled deployment.

## What these models cannot prove

The results cannot prove production readiness, long-duration stability, multi-machine scaling, public-network behavior, maintained certificate rotation, backup restoration at institutional scale, or real notification delivery. The authorized acceptance role for this evidence is the student/instructor within the course evaluation; broader operational acceptance remains outside scope.

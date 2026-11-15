# Week 16 Reflection

**Student:** Laurence Matthew B Manuel | **Section:** BSIT 3A | **Status:** Confirmed by the student on 15 November 2026

## Decision with the greatest effect

The separation of liveness from database readiness had the greatest effect on reliability. The first failure exercise showed that a process could answer `/up` while the database dependency made `/ready` exceed the probe timeout. The one-second socket preflight followed by a real query changed the result to a safe 503 in about 1.36 seconds. That evidence confirmed that a health endpoint must represent a specific contract rather than a general claim that the application is healthy.

## Most difficult limitation to reproduce

The most difficult issue was separating application latency from the test environment. The first finalized workload showed about 2.2 seconds per request, but direct comparisons did not show the same server delay. The Python client was attempting the non-listening IPv6 loopback before IPv4. Preserving the failed run and repeating the same model with the certificate-covered IPv4 address made the cause visible. A better future test would record DNS/address selection and connection timing separately from server response time.

## Work that can be explained and modified

The artifact I can explain and modify is `backend/routes/web.php`, supported by `SRC-01-readiness-implementation.png` and the failure/recovery record. It contains the liveness/readiness distinction, bounded socket preflight, real database query, safe 503 response and protected warning log.

## What a maintainer should verify next

An authorized maintainer should replace the single-worker local server with an approved multi-worker staging topology and rerun the unchanged peak workload. Peak throughput failed at 6.648 requests/second against the 8 requests/second target even though p95 and errors passed. That work is outside the current evidence because no staging infrastructure, public hosting, certificate lifecycle or operational owner was approved.

## Confirmation

I reviewed this reflection and confirmed on 15 November 2026 that it represents my understanding and individual contribution. No instructor mark or oral-defense result is claimed.

# Loopback Address Performance Finding

At 2026-11-15 21:52 to 21:54 Asia/Manila, the first finalized workload used `https://localhost:8443`. It produced zero HTTP errors but failed both selected performance thresholds: ordinary throughput was 0.900 requests/second with p95 2,254.645 ms, and peak throughput was 5.148 requests/second with p95 2,497.231 ms.

Three direct `curl` comparisons then showed Laravel HTTP requests around 155-191 ms and gateway HTTPS requests around 25 ms, which did not support an application or gateway processing bottleneck of 2.2 seconds. The Python client was resolving `localhost` to the non-listening IPv6 loopback before IPv4. Because the test certificate includes `127.0.0.1` as a subject alternative name and the gateway is intentionally bound to IPv4 loopback, the harness was corrected to use `https://127.0.0.1:8443` explicitly.

The failed summary and all 300 raw request rows remain in `performance-initial-localhost.json` and `performance-initial-localhost-raw.csv`. Acceptance thresholds were not changed. The same workloads must pass on the corrected address before any conditional UAT recommendation.

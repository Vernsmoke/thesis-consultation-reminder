# Controlled Deployment Checklist

- [x] Week 15 tag `v3.0.0` exists at `134077c`; Week 16 starts from master `17e8860` with no Git mutation by the agent.
- [x] PHP 8.2.12, Laravel 12.71.0, Flutter 3.47.8, Dart 3.13.7, and MariaDB 10.4.32 recorded.
- [x] Private `.env`, database password, demo password, keyring and TLS private keys remain ignored.
- [x] Secret scan covered 287 candidate text files with zero generated-secret/private-key matches.
- [x] Short-lived localhost certificate rotated after the prior certificate expired; new certificate expires 2026-11-22 21:31 Asia/Manila.
- [x] Flutter release build targets `https://localhost:8443/api` and is served over HTTPS 8444.
- [x] Laravel runs on loopback 8000; HTTPS gateway runs on loopback 8443; MariaDB runs on 3306; scheduler is active.
- [x] Database migrations from the existing milestone are compatible; Week 16 adds no schema change.
- [x] `/up` and `/ready` verified in tests and live browser.
- [x] Ordinary and peak raw results, percentiles, error rates, throughput and resource samples preserved.
- [x] Database dependency failure predicted, executed in an isolated process, and recovered without modifying the main data.
- [x] 27 Laravel tests with 238 assertions, 22 Flutter tests, analysis, Pint and release build pass.
- [x] Actual sanitized browser and source screenshots captured and hashed.
- [ ] Peak throughput reaches 8 requests/second. Actual: 6.648; blocks peak-deadline readiness.
- [ ] Maintained multi-worker application server, centralized monitoring, automated restart, staging backup restore and institutional certificate management. Outside current local scope.
- [ ] Instructor approval, marking and any prescribed acknowledgment wording. External.

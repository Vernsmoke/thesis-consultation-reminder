# Week 14 Security Test Record

Student: Laurence Matthew B Manuel
Section: BSIT 3A
Timezone: Asia/Manila
Source state: Week 14 uncommitted working tree extending Week 13 commit `707ef93` (`v1.0.0`)

## Environment

The controlled environment used PHP 8.2.12, Laravel 12.71.0, Composer 2.10.2, Flutter 3.47.8, Dart 3.13.7, MariaDB 10.4.32, and the PHP OpenSSL extension. Full machine-readable details are in `../logs/environment.json`.

## Acceptance criteria and results

| ID | Case | Expected result | Actual result | Evidence | Result |
|---|---|---|---|---|---|
| SEC-01 | Coordinator creates an envelope for an assigned adviser | `200`; AES-GCM envelope contains authenticated metadata but no plaintext key | `200`; adviser accepted the envelope once | `http-security-results.json`; `../screenshots/app/APP-02-authenticated-envelope.png`; PHPUnit XML | Pass |
| SEC-02 | Replay the accepted envelope | `409`; no second receipt | `409`; database uniqueness preserved one receipt | `http-security-results.json`; `../screenshots/app/APP-04-replay-rejected.png` | Pass |
| SEC-03 | Alter ciphertext | `422`; no plaintext and no receipt | `422` with safe generic integrity error | `http-security-results.json`; `../logs/backend-tests-final.txt` | Pass |
| SEC-04 | Alter authenticated recipient metadata | `422`; integrity failure precedes use | PHPUnit rejected the envelope and created no receipt | `../logs/backend-tests-final.txt`; `phpunit-results.xml` | Pass |
| SEC-05 | Authentic but expired envelope | `422`; require a new envelope | PHPUnit rejected it and created no receipt | `../logs/backend-tests-final.txt`; `phpunit-results.xml` | Pass |
| SEC-06 | Invalid malformed payload | `422` with field-level validation, correlation ID | `422`; no sensitive detail exposed | `http-security-results.json`; `phpunit-results.xml` | Pass |
| SEC-07 | Student calls coordinator-only create route | `403`; no envelope | `403` | `http-security-results.json`; `phpunit-results.xml` | Pass |
| SEC-08 | Adviser other than assigned recipient receives envelope | `403`; no plaintext and no receipt | PHPUnit returned `403` | `../logs/backend-tests-final.txt`; `phpunit-results.xml` | Pass |
| SEC-09 | Unknown/wrong key | Safe `422`/`503`; no receipt; recovery after correct key restored | PHPUnit exercised rejection and restoration; regression passed | `../logs/backend-tests-final.txt`; `phpunit-results.xml` | Pass |
| SEC-10 | Missing key service configuration | Safe `503`; no key value or internal path disclosed | Generic unavailable response; regression passed after restoration | `../logs/backend-tests-final.txt`; `phpunit-results.xml` | Pass |
| SEC-11 | Trusted HTTPS endpoint | Certificate chain validates with controlled CA; TLS 1.2+ | TLS 1.3 negotiated with `TLS_AES_256_GCM_SHA384` | `tls-results.json` | Pass |
| SEC-12 | Client without trust anchor | TLS handshake rejected | Python client rejected the certificate until the controlled CA was supplied | `tls-results.json` | Pass |
| SEC-13 | Secret scan | No generated key, fixture password, or private-key material in reviewed source/evidence | No exact generated-secret or private fixture-password match | `../logs/secret-scan.json` | Pass |
| SEC-14 | Dependency audit | No known Composer advisory in installed dependency set | No advisories reported | `../logs/composer-audit.json` | Pass |
| SEC-15 | Flutter validation and states | Create, receive, and malformed JSON states render; all regressions pass | 18 tests passed; static analysis reported no issues | `../logs/flutter-tests.txt`; `../logs/flutter-analysis.txt` | Pass |

## Controlled failure and improvement record

The first browser attempt over HTTPS failed at the CORS preflight boundary because the TLS gateway did not forward the browser's requested-method and requested-header metadata. The failure was safe: no authenticated request reached Laravel, no record changed, and the UI displayed a network error. The gateway was corrected to allowlist and forward only `Access-Control-Request-Method` and `Access-Control-Request-Headers`. The browser flow was rerun over HTTPS and completed successfully. This demonstrates diagnosis and a bounded improvement rather than weakening certificate or origin checks.

An automated backend test also initially expected an internal configuration message. Laravel's global exception response correctly converted the condition to a generic `503`. The test was corrected to assert the public contract and non-disclosure. The implementation was not weakened to expose the diagnostic.

## Regression summary

- Backend: 21 tests, 199 assertions, all passing.
- Flutter: 18 tests, all passing; analysis found no issues.
- Formatting: Laravel Pint passed after formatting four Week 14 PHP files.
- Flutter Web production build completed successfully.
- Live HTTPS script: five of five requested API scenarios matched expected status codes.

## Interpretation

Observed results support the limited claim that the controlled Week 14 build authenticates users, enforces route and record-level roles, validates inputs, transports the web/API traffic over a trusted local HTTPS boundary, and protects the sender/receiver record with AES-256-GCM plus replay and expiry checks. They do not establish internet-facing production readiness, resistance to a compromised endpoint, or operational key management at institutional scale. Those remain explicit residual risks.

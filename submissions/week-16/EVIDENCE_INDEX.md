# Week 16 Evidence Index

Source state: uncommitted Week 16 working tree based on `v3.0.0` (`134077c`) and master `17e8860`. Times are Asia/Manila on 15 November 2026. All accounts and records are fictional.

| ID | Artifact | Scenario and result |
|---|---|---|
| PERF-01 | `tests/performance-initial-localhost.json` and raw CSV | Failed address-resolution run retained; zero errors but both timing targets failed. |
| PERF-02 | `tests/performance-summary.json` and `performance-raw.csv` | Corrected IPv4 run; ordinary passed, peak throughput failed 6.648 vs 8 rps, other peak criteria passed. |
| PERF-03 | `tests/resource-samples.json` | 48 samples per process; maximum working sets 32.51-47.92 MiB. |
| REL-01 | `logs/initial-failure-record.md` | Readiness initially exceeded five-second dependency-failure probe. |
| REL-02 | `tests/failure-recovery.json` | Isolated database failure returned 503 after fix; main environment recovered 200. |
| TEST-01 | `logs/backend-tests.txt`, `tests/phpunit-results.xml` | 27 Laravel tests, 238 assertions, all pass. |
| TEST-02 | `logs/flutter-tests.txt`, `logs/flutter-analysis.txt` | 22 Flutter tests pass; analysis has no issues. |
| BUILD-01 | `logs/flutter-build.txt`, `logs/pint.txt` | Release web build and Pint pass; Flutter's optional update check logged a network fetch warning before the successful build. |
| SEC-01 | `logs/secret-scan.json` | 287 candidate text files, zero generated-secret/private-key matches; protected paths ignored. |
| ENV-01 | `logs/environment.json`, environment comparison | Actual versions, ports, certificate date and topology. |
| APP-01 | `screenshots/app/APP-01-https-desktop-login.png` | Edge shows sanitized release Flutter login over trusted HTTPS. SHA-256 begins `A6D8C0`. |
| APP-02 | `screenshots/app/APP-02-browser-readiness.png` | Edge shows live readiness `database: up` over HTTPS. SHA-256 begins `C9880A`. |
| SRC-01 | `screenshots/source/SRC-01-readiness-implementation.png` | VS Code shows bounded readiness source. SHA-256 begins `731174`. |
| DOC-01 | `reports/week-16-deployment-evaluation.docx/.pdf` | Main assessment report after render verification. |
| DOC-02 | `reports/activity-1-workload-models.docx/.pdf` | Activity 1 decision/test record and interpretation. |
| DOC-03 | `reports/activity-2-deployment-review.docx/.pdf` | Activity 2 tabletop review and improvement plan. |
| DOC-04 | `reports/reflection-preparation.docx/.pdf` | Evidence-grounded reflection draft; student confirmation remains pending. |

Screenshots are actual Windows captures saved from the controlled browser/editor sessions. Raw performance rows and logs, not screenshots, are the primary proof of backend behavior.

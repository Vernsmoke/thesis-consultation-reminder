# Week 14 Evidence Index

Student: Laurence Matthew B Manuel
Section: BSIT 3A
Capture date: 2026-11-08
Timezone: Asia/Manila
Verified source revision: `03d9ed372bbf2e83c59d50c9e5707e0cddf86b7d`, extending Week 13 `v1.0.0` (`707ef93`)

All application data shown is fictional. No private key, secure-exchange key, bearer token, or live student record is included.

## Application and source screenshots

| ID | Path | Scenario and observed result | Captured | SHA-256 |
|---|---|---|---|---|
| APP-01 | `screenshots/app/APP-01-https-coordinator.png` | Edge loaded the Flutter Web coordinator workspace over trusted `https://localhost:8444`; authenticated role and workflow state visible | 2026-11-08 20:35:19 +08:00 | `8034B283469C58AEB7D70ED78037F4CCED504612428C299EC7E67CBA1B8A5337` |
| APP-02 | `screenshots/app/APP-02-authenticated-envelope.png` | Coordinator prepared an AES-256-GCM metadata-and-ciphertext envelope; no key displayed | 2026-11-08 20:35:47 +08:00 | `0F4F4DD61624C88280C9CE149C2FA833A33E7E30F49DE4DC725C490E074CC607` |
| APP-03 | `screenshots/app/APP-03-secure-receive-success.png` | Assigned adviser received and displayed the minimized consultation record once | 2026-11-08 20:39:04 +08:00 | `74FAFD1DB2FC9703CDD5D2B849B10AD3C054E6AA9DE065AD80486CC84A472C64` |
| APP-04 | `screenshots/app/APP-04-replay-rejected.png` | Second use of the same envelope was rejected with a conflict message | 2026-11-08 20:39:23 +08:00 | `B9C9FA1CD509D1DDA72A4CC4EA39C870FB4DE6523F57CE9A90942B07CADD9B92` |
| SRC-01 | `screenshots/source/SRC-01-aes-gcm-envelope.png` | Actual AES-GCM encryption and authenticated-data construction in VS Code | 2026-11-08 20:45:33 +08:00 | `BE80E8A7D4F4906E6A5C5F34ABA98D53783E738D5DC6E505B99FA0B2FDDACCCF` |
| SRC-02 | `screenshots/source/SRC-02-authorization-replay-control.png` | Actual receiver authorization and unique receipt/replay control in VS Code | 2026-11-08 20:46:09 +08:00 | `6A2CDD1FE2D79FA7ECEBF3625EFA6EDE3CAC8C35F032A3ACF0C32D31F12AA5D0` |

## Repeatable technical evidence

| ID | Path | Scenario and result | Executed |
|---|---|---|---|
| TEST-01 | `tests/http-security-results.json` | Live HTTPS success, replay, altered ciphertext, unauthorized role, and invalid payload: 5/5 expected statuses | 2026-11-08 20:37:08 +08:00 |
| TEST-02 | `tests/tls-results.json` | Trusted local CA negotiated TLS 1.3; missing trust anchor was rejected | 2026-11-08 20:37:12 +08:00 |
| TEST-03 | `tests/phpunit-results.xml` and `logs/backend-tests-final.txt` | Backend regression: 21 tests, 199 assertions, all passing | 2026-11-08 |
| TEST-04 | `logs/flutter-tests.txt` | Flutter regression: 18 tests, all passing | 2026-11-08 |
| TEST-05 | `logs/flutter-analysis.txt` | Flutter static analysis: no issues | 2026-11-08 |
| TEST-06 | `logs/flutter-build-final.txt` | Flutter Web production build completed | 2026-11-08 |
| TEST-07 | `logs/secret-scan.json` | No exact generated key/private fixture password or private-key material in reviewed source/evidence | 2026-11-08 |
| TEST-08 | `logs/composer-audit.json` | Composer dependency audit reported no advisories | 2026-11-08 |
| TEST-09 | `logs/pint-final.txt` | Laravel Pint formatting check passed | 2026-11-08 |
| TEST-10 | `tests/security-test-record.md` | Expected/actual matrix, controlled failures, regression counts, and interpretation | 2026-11-08 |
| ENV-01 | `logs/environment.json` | Runtime, framework, database, and cryptographic-extension versions | 2026-11-08 20:51:43 +08:00 |

## Design and decision evidence

| ID | Path | Purpose |
|---|---|---|
| DES-01 | `diagrams/secure-data-flow.mmd`, `.json`, `.svg` | Trust boundaries, actors, protected data, HTTPS/API flow, logging, and ignored key storage |
| DES-02 | `diagrams/secure-exchange-sequence.mmd`, `.json`, `.svg` | Authentication, AEAD, authorization, replay rejection, and audit sequence |
| DES-03 | `../../docs/protection-requirements.md` | Data classification and protection requirements matrix |
| DES-04 | `../../docs/cryptographic-decision.md` | Algorithm decision, alternatives, assumptions, and misuse warnings |
| DES-05 | `../../docs/key-lifecycle.md` | Generation, storage, activation, rotation, recovery, retention, and destruction plan |
| DES-06 | `../../docs/residual-risk-register.md` | Evidence-linked remaining risks and owners |

## Evidence limitations

The screenshots prove visible states of this controlled build, while the JSON/XML/log evidence proves specific API and test outcomes. The evidence was originally captured against the uncommitted working tree and was subsequently preserved unchanged in source revision `03d9ed3`. It does not prove production hosting, institution-managed certificates, user acceptance, instructor approval, or an oral defense.

# Thesis Consultation Reminder System

Week 15 extends the same application with an evidence-linked integration and hardening gate. The verified local working tree passes 24 Laravel tests with 227 assertions, 22 Flutter tests, and 14 live HTTPS API scenarios. Five baseline weaknesses were reproduced, fixed, and retested; the evidence is under `submissions/week-15`.

## Week 15 verification

With the Week 14 local HTTPS services and controlled private fixture password available, run from the repository root:

```powershell
& 'submissions/week-15/tests/Invoke-Week15Api.ps1'
& 'submissions/week-15/tests/Run-Week15Verification.ps1'
```

The first script runs deterministic normal, invalid, boundary, unauthorized, forbidden, not-found, duplicate, pagination, dependency-failure, and recovery cases without exporting credentials. The second reruns Laravel, Flutter, static analysis, release build, Composer audit, secret scanning, and environment capture. See `docs/week-15-test-strategy.md` and `submissions/week-15/tests/traceability-matrix.md` before interpreting the results; the findings apply to the controlled local environment, not production readiness.

Week 14 adds a controlled secure-exchange exercise to the Week 13 workflow. The browser uses local HTTPS, Laravel authenticates and authorizes every request, and the server creates AES-256-GCM envelopes for an assigned adviser without exposing the key to Flutter.

## Week 14 controlled HTTPS setup

1. Provision the ignored server keyring from `backend` with `C:\xampp\php\php.exe artisan secure-exchange:key`.
2. Build Flutter with `E:\Flutter\flutter_windows_3.47.8-stable\flutter\bin\flutter.bat build web --release --dart-define=API_URL=https://localhost:8443/api`.
3. Provision the seven-day localhost certificate with the bundled workspace Python runtime and `tools/provision_week14_tls.py --output backend/storage/app/private/tls`.
4. Trust only the generated public `ca.crt` in the current-user root store for the controlled exercise. Do not trust or share either private key.
5. Start Laravel on loopback port 8000. Start `tools/serve_week14_https.py` as an API proxy on 8443 and a static Flutter server on 8444 with the protected certificate and key.
6. Open `https://localhost:8444`. A certificate warning is a failed setup condition; do not bypass it.
7. Run `submissions/week-14/tests/Invoke-Week14Security.ps1` and `tools/verify_week14_tls.py` for repeatable HTTPS and certificate evidence.

The localhost gateway is a controlled nonproduction transport. For broader use, replace it with a maintained reverse proxy, approved certificate lifecycle, and protected secret service. Detailed rotation, recovery, and CA removal guidance is in `docs/key-lifecycle.md`.

Individual PFEBSIT 002 Project 29, Laurence Matthew B Manuel, BSIT 3A. Week 13 educational prototype: Flutter Web → Laravel API → XAMPP MariaDB, with a controlled simulated notification transport. The user confirmed Project 29 registration on November 8, 2026. Historical deadline October 30, 2026; actual work/evidence November 8, 2026.

## Requirements and installation

Verified: PHP 8.2.12, Composer 2.10.2, Laravel 12.71.0, Flutter 3.47.8, Dart 3.13.7, MariaDB 10.4.32 (XAMPP). Android Studio is the preferred Flutter editor. Web is the assessed target.

Start XAMPP MySQL/MariaDB. Provision two dedicated empty schemas `thesis_consultation_w13` and `thesis_consultation_w13_test`, and a private account limited to those schemas. Existing unrelated databases must not be changed. In PowerShell from the repository root:

```powershell
Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT/backend'
composer install
Copy-Item .env.example .env  # only on a fresh installation; never overwrite an existing private env
# Privately edit DB_PASSWORD and DEMO_PASSWORD, and your database username.
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=127.0.0.1 --port=8000
```

Second terminal:

```powershell
Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT/frontend'
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080 --dart-define=API_URL=http://127.0.0.1:8000/api
```

Third terminal, keep open for automatic minute processing:

```powershell
Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT/backend'
php artisan schedule:work
```

Accounts: `student@example.test`, `adviser@example.test`, `panel@example.test`, `coordinator@example.test`, `otherstudent@example.test`; password is the private DEMO_PASSWORD chosen during setup. No live credentials are documented. Do not publish .env, database dumps, sessions, or screenshots containing credentials. Current machine has generated private setup already; do not overwrite it.

## Workflow and verification

Student signs in, requests a future UTC schedule and agenda. Adviser confirms and adds action items; student completes follow-up. Adviser records completion. Panel reads assigned records. Coordinator sees automation queue and records human handling of permanent/exhausted failures. UI displays schedule in Manila; forms explicitly request UTC. See [API contract](docs/api.md), [decisions](docs/decisions.md), [runbook](docs/automation.md), and [security](docs/security.md).

```powershell
Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT/backend'
php artisan test
php artisan consultations:tick
php artisan week13:evidence  # controlled local fixtures; real backoff experiment takes about four minutes
Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT/frontend'
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
```

Tests forcibly use the dedicated `_test` schema and roll back fixtures. Never modify phpunit.xml to point to other data. `week13:evidence` adds fictional summary events without deleting records. It preserves attempts, real elapsed times, safe audits and correlation IDs under the Week 13 logs folder. It never contacts email/SMS.

## Limitations and review

Loopback prototype, simulated delivery only, no production authorization. Full Week 14 HTTPS/authenticated-encryption exercise is not included. Actual source captures and user-supplied running Flutter screenshots are indexed for login, connected workflow, validation, manual review, desktop, tablet and narrow layouts. Week 13 DOCX and PDF soft copies were rendered and visually verified on 2026-11-08. The student confirmed that the reflection reflects their understanding and that project registration is approved. No evidence implies an oral-defense result, instructor mark, production approval or real notification delivery.

The user normally owns Git operations. For this final Week 13 release, the user explicitly authorized the agent to complete the reviewed commit, direct push and `v1.0.0` tag. The exact record is in `docs/week-13-git-commands.ps1`. The source-only archive matches confirmed source commit `4a761a31244c00176f016ffe26ff069118b0f0c9`; see the submission source preparation instructions.

# Thesis Consultation Reminder System

Individual PFEBSIT 002 Project 29, Laurence Matthew B Manuel, BSIT 3A. Week 13 educational prototype: Flutter Web → Laravel API → XAMPP MariaDB, with a controlled simulated notification transport. Project registration remains unconfirmed. Historical deadline October 30, 2026; actual work/evidence November 8, 2026.

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

Loopback prototype, simulated delivery only, no production authorization. Full Week 14 HTTPS/authenticated-encryption exercise not included. Browser and source screenshot capture remains pending because managed local-tool permissions rejected access; status and evidence index distinguish unavailable evidence from tests. Week 13 DOCX and PDF soft copies were rendered and visually verified on 2026-11-08. Student must review AI-assisted work and write their own personal reflection. No evidence implies instructor approval, defense completion, grade, or user acceptance.

The user owns all Git operations. Reviewed commands belong in `docs/week-13-git-commands.ps1`; execute only after reviewing file contents and the pending items. Source archives are deferred until a source commit is confirmed; see the submission source preparation instructions.

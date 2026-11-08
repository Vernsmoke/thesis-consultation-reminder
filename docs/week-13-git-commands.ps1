# REVIEWED WEEK 13 COMMAND RECORD - executed under explicit user authorization on 2026-11-08.
# The six groups below record the exact paths and commit messages used.
# The original six groups and later evidence commits were executed under explicit user authorization.
Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT'
git status --short

# Group 1: Week 13: define consultation scope and automation decisions (26 exact files)
git add -- '.gitignore' 'AGENTS.md' 'docs/api.md' 'docs/architecture.md' 'docs/automation.md' 'docs/decisions.md'
git add -- 'docs/security.md' 'prompts/week-13.md' 'submissions/week-13/SUBMISSION_CHECKLIST.md' 'submissions/week-13/diagrams/dataflow.json' 'submissions/week-13/diagrams/dataflow.mmd' 'submissions/week-13/diagrams/dataflow.structural.svg'
git add -- 'submissions/week-13/diagrams/dataflow.svg' 'submissions/week-13/diagrams/delivery-sequence.json' 'submissions/week-13/diagrams/delivery-sequence.mmd' 'submissions/week-13/diagrams/delivery-sequence.structural.svg' 'submissions/week-13/diagrams/delivery-sequence.svg' 'submissions/week-13/diagrams/screenflow.json'
git add -- 'submissions/week-13/diagrams/screenflow.mmd' 'submissions/week-13/diagrams/screenflow.structural.svg' 'submissions/week-13/diagrams/screenflow.svg' 'submissions/week-13/diagrams/workflow.json' 'submissions/week-13/diagrams/workflow.mmd' 'submissions/week-13/diagrams/workflow.structural.svg'
git add -- 'submissions/week-13/diagrams/workflow.svg' 'submissions/week-13/tests/build-diagrams.py'
git diff --cached --check
if ($LASTEXITCODE -ne 0) { throw 'Fix staged whitespace errors before committing.' }
git diff --cached --stat
git commit -m 'Week 13: define consultation scope and automation decisions'

# Group 2: Week 13: add validated Laravel consultation API and MariaDB schema (58 exact files)
git add -- 'backend/.editorconfig' 'backend/.env.example' 'backend/.gitattributes' 'backend/.gitignore' 'backend/README.md' 'backend/app/Http/Controllers/ConsultationController.php'
git add -- 'backend/app/Http/Controllers/Controller.php' 'backend/app/Http/Middleware/ApiContext.php' 'backend/app/Models/User.php' 'backend/app/Providers/AppServiceProvider.php' 'backend/app/Services/Audit.php' 'backend/artisan'
git add -- 'backend/bootstrap/app.php' 'backend/bootstrap/cache/.gitignore' 'backend/bootstrap/providers.php' 'backend/composer.json' 'backend/composer.lock' 'backend/config/app.php'
git add -- 'backend/config/auth.php' 'backend/config/cache.php' 'backend/config/cors.php' 'backend/config/database.php' 'backend/config/filesystems.php' 'backend/config/logging.php'
git add -- 'backend/config/mail.php' 'backend/config/queue.php' 'backend/config/services.php' 'backend/config/session.php' 'backend/database/.gitignore' 'backend/database/factories/UserFactory.php'
git add -- 'backend/database/migrations/0001_01_01_000000_create_users_table.php' 'backend/database/migrations/0001_01_01_000001_create_cache_table.php' 'backend/database/migrations/0001_01_01_000002_create_jobs_table.php' 'backend/database/migrations/2026_11_08_000001_create_consultation_workflow.php' 'backend/database/migrations/2026_11_08_000002_add_receipt_payload_to_existing_installation.php' 'backend/database/seeders/DatabaseSeeder.php'
git add -- 'backend/package.json' 'backend/public/.htaccess' 'backend/public/favicon.ico' 'backend/public/index.php' 'backend/public/robots.txt' 'backend/resources/css/app.css'
git add -- 'backend/resources/js/app.js' 'backend/resources/js/bootstrap.js' 'backend/resources/views/welcome.blade.php' 'backend/routes/api.php' 'backend/routes/web.php' 'backend/storage/app/.gitignore'
git add -- 'backend/storage/app/private/.gitignore' 'backend/storage/app/public/.gitignore' 'backend/storage/framework/.gitignore' 'backend/storage/framework/cache/.gitignore' 'backend/storage/framework/cache/data/.gitignore' 'backend/storage/framework/sessions/.gitignore'
git add -- 'backend/storage/framework/testing/.gitignore' 'backend/storage/framework/views/.gitignore' 'backend/storage/logs/.gitignore' 'backend/vite.config.js'
git diff --cached --check
if ($LASTEXITCODE -ne 0) { throw 'Fix staged whitespace errors before committing.' }
git diff --cached --stat
git commit -m 'Week 13: add validated Laravel consultation API and MariaDB schema'

# Group 3: Week 13: build Flutter Web consultation and follow-up workflow (15 exact files)
git add -- 'frontend/.gitignore' 'frontend/.metadata' 'frontend/README.md' 'frontend/analysis_options.yaml' 'frontend/lib/api.dart' 'frontend/lib/main.dart'
git add -- 'frontend/pubspec.lock' 'frontend/pubspec.yaml' 'frontend/web/favicon.png' 'frontend/web/icons/Icon-192.png' 'frontend/web/icons/Icon-512.png' 'frontend/web/icons/Icon-maskable-192.png'
git add -- 'frontend/web/icons/Icon-maskable-512.png' 'frontend/web/index.html' 'frontend/web/manifest.json'
git diff --cached --check
if ($LASTEXITCODE -ne 0) { throw 'Fix staged whitespace errors before committing.' }
git diff --cached --stat
git commit -m 'Week 13: build Flutter Web consultation and follow-up workflow'

# Group 4: Week 13: add durable scheduled automation and bounded recovery (6 exact files)
git add -- 'backend/app/Console/Commands/Week13Evidence.php' 'backend/app/Console/Commands/Week13Fixtures.php' 'backend/app/Services/Automation.php' 'backend/app/Services/SimulatedTransport.php' 'backend/config/automation.php' 'backend/routes/console.php'
git diff --cached --check
if ($LASTEXITCODE -ne 0) { throw 'Fix staged whitespace errors before committing.' }
git diff --cached --stat
git commit -m 'Week 13: add durable scheduled automation and bounded recovery'

# Group 5: Week 13: preserve API automation and Flutter verification evidence (31 exact files)
git add -- 'backend/phpunit.xml' 'backend/tests/Feature/ExampleTest.php' 'backend/tests/Feature/WorkflowTest.php' 'backend/tests/TestCase.php' 'backend/tests/Unit/ExampleTest.php' 'frontend/test/api_test.dart'
git add -- 'frontend/test/connected_states_test.dart' 'frontend/test/workflow_test.dart' 'submissions/week-13/logs/backend-tests.txt' 'submissions/week-13/logs/composer-audit.json' 'submissions/week-13/logs/controlled-delivery.json' 'submissions/week-13/logs/diagram-validation.txt'
git add -- 'submissions/week-13/logs/docx-render-attempt.txt' 'submissions/week-13/logs/docx-render-final.txt' 'submissions/week-13/logs/environment.txt' 'submissions/week-13/logs/flutter-analysis.txt' 'submissions/week-13/logs/flutter-build.txt' 'submissions/week-13/logs/flutter-expanded-initial-failure.txt'
git add -- 'submissions/week-13/logs/flutter-tests.txt' 'submissions/week-13/logs/four-automation-command.txt' 'submissions/week-13/logs/four-automation-triggers.json' 'submissions/week-13/logs/initial-verification.txt' 'submissions/week-13/logs/schedule-list.txt' 'submissions/week-13/logs/schedule-run.txt'
git add -- 'submissions/week-13/tests/Invoke-Week13Api.ps1' 'submissions/week-13/tests/artifact-checks.json' 'submissions/week-13/tests/http-results.json' 'submissions/week-13/tests/phpunit-results.xml' 'submissions/week-13/tests/review-package.py' 'submissions/week-13/tests/scenarios.md'
git add -- 'submissions/week-13/tests/source-manifest.json'
git diff --cached --check
if ($LASTEXITCODE -ne 0) { throw 'Fix staged whitespace errors before committing.' }
git diff --cached --stat
git commit -m 'Week 13: preserve API automation and Flutter verification evidence'

# Group 6: Week 13: prepare SA7 activity reports and milestone handoff (21 exact files)
git add -- 'CHANGELOG.md' 'PROJECT_STATUS.md' 'README.md' 'docs/week-13-git-commands.ps1' 'submissions/week-13/EVIDENCE_INDEX.md' 'submissions/week-13/reports/SA7-automation-report.docx'
git add -- 'submissions/week-13/reports/SA7-automation-report.md' 'submissions/week-13/reports/SA7-automation-report.pdf' 'submissions/week-13/reports/activity-1-pattern-selection.docx' 'submissions/week-13/reports/activity-1-pattern-selection.md' 'submissions/week-13/reports/activity-1-pattern-selection.pdf' 'submissions/week-13/reports/activity-2-failure-injection.docx'
git add -- 'submissions/week-13/reports/activity-2-failure-injection.md' 'submissions/week-13/reports/activity-2-failure-injection.pdf' 'submissions/week-13/reports/demo-and-reflection-preparation.md' 'submissions/week-13/reports/reflection-preparation.docx' 'submissions/week-13/reports/reflection-preparation.md' 'submissions/week-13/reports/reflection-preparation.pdf'
git add -- 'submissions/week-13/screenshots/PENDING_CAPTURES.md' 'submissions/week-13/source/preparation.md' 'submissions/week-13/tests/build-reports.py'
git diff --cached --check
if ($LASTEXITCODE -ne 0) { throw 'Fix staged whitespace errors before committing.' }
git diff --cached --stat
git commit -m 'Week 13: prepare SA7 activity reports and milestone handoff'

# Executed successfully: master pushed by direct URL. No remote was configured.
git push 'https://github.com/Vernsmoke/thesis-consultation-reminder.git' master

# Final evidence reconciliation group: exact paths only; future-week prompts stay untracked.
git add -- 'AGENTS.md' 'CHANGELOG.md' 'PROJECT_STATUS.md' 'README.md' 'docs/week-13-git-commands.ps1'
git add -- 'submissions/week-13/EVIDENCE_INDEX.md' 'submissions/week-13/SUBMISSION_CHECKLIST.md' 'submissions/week-13/SUBMISSION_CONTENTS.md'
git add -- 'submissions/week-13/reports/SA7-automation-report.docx' 'submissions/week-13/reports/SA7-automation-report.md' 'submissions/week-13/reports/SA7-automation-report.pdf'
git add -- 'submissions/week-13/reports/activity-1-pattern-selection.docx' 'submissions/week-13/reports/activity-1-pattern-selection.md' 'submissions/week-13/reports/activity-1-pattern-selection.pdf'
git add -- 'submissions/week-13/reports/activity-2-failure-injection.docx' 'submissions/week-13/reports/activity-2-failure-injection.md' 'submissions/week-13/reports/activity-2-failure-injection.pdf'
git add -- 'submissions/week-13/reports/demo-and-reflection-preparation.md' 'submissions/week-13/reports/reflection-preparation.docx' 'submissions/week-13/reports/reflection-preparation.md' 'submissions/week-13/reports/reflection-preparation.pdf'
git add -- 'submissions/week-13/screenshots/PENDING_CAPTURES.md' 'submissions/week-13/screenshots/app/APP-01-student-request-success-desktop.png' 'submissions/week-13/screenshots/app/APP-02-adviser-confirmation.png'
git add -- 'submissions/week-13/screenshots/app/APP-03-adviser-action-item.png' 'submissions/week-13/screenshots/app/APP-04-validation-error.png' 'submissions/week-13/screenshots/app/APP-05-coordinator-manual-review.png'
git add -- 'submissions/week-13/screenshots/app/APP-06-coordinator-metrics.png' 'submissions/week-13/screenshots/app/APP-07-narrow-layout.png' 'submissions/week-13/screenshots/app/APP-08-tablet-layout.png'
git add -- 'submissions/week-13/tests/artifact-checks.json' 'submissions/week-13/tests/build-reports.py' 'submissions/week-13/tests/review-package.py' 'submissions/week-13/tests/source-manifest.json'
git diff --cached --check
git diff --cached --stat
git commit -m 'Week 13: finalize browser evidence and submission readiness'
git push 'https://github.com/Vernsmoke/thesis-consultation-reminder.git' master

# Release: executed only after final tests, artifact checks and tag-existence check pass.
git tag --list v1.0.0
git tag -a v1.0.0 -m 'Week 13: automation foundation'
git push 'https://github.com/Vernsmoke/thesis-consultation-reminder.git' v1.0.0

# Future-week prompt files are original user context and deliberately excluded; no teacher documents, secrets, caches or ZIPs included.

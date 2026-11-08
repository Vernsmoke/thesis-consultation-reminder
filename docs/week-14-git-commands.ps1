# Run from C:\Users\Laure\Documents\ChatGPT\IPT after reviewing each group.
# Execution record: groups 1–4 produced commits a487cbe, 593bd52, d5c096c, and 03d9ed3 after explicit user authorization. The final portfolio group and release commands below complete the milestone.

# Group 1: Week 14 scope and security design
git add -- 'prompts/week-14.md' 'docs/security-architecture.md' 'docs/protection-requirements.md' 'docs/control-rationale.md' 'docs/cryptographic-decision.md' 'docs/key-lifecycle.md' 'docs/residual-risk-register.md' 'submissions/week-14/diagrams/secure-data-flow.json' 'submissions/week-14/diagrams/secure-data-flow.mmd' 'submissions/week-14/diagrams/secure-data-flow.svg' 'submissions/week-14/diagrams/secure-exchange-sequence.json' 'submissions/week-14/diagrams/secure-exchange-sequence.mmd' 'submissions/week-14/diagrams/secure-exchange-sequence.svg'
git diff --cached --check
git diff --cached --stat
git commit -m 'docs(week-14): define secure exchange architecture'

# Group 2: Laravel authenticated exchange and adverse tests
git add -- 'backend/.env.example' 'backend/app/Console/Commands/ProvisionSecureExchangeKey.php' 'backend/app/Http/Controllers/ConsultationController.php' 'backend/app/Http/Middleware/ApiContext.php' 'backend/app/Services/SecureExchange.php' 'backend/config/cors.php' 'backend/config/secure_exchange.php' 'backend/database/migrations/2026_11_08_140001_create_secure_exchange_receipts.php' 'backend/routes/api.php' 'backend/tests/Feature/SecureExchangeTest.php'
git diff --cached --check
git diff --cached --stat
git commit -m 'feat(api): add authenticated encrypted consultation exchange'

# Group 3: Flutter receiver workflow and controlled HTTPS tooling
git add -- 'frontend/lib/api.dart' 'frontend/lib/main.dart' 'frontend/test/secure_exchange_test.dart' 'tools/provision_week14_tls.py' 'tools/serve_week14_https.py' 'tools/verify_week14_tls.py' 'tools/scan_week14_secrets.ps1' 'README.md' 'CHANGELOG.md'
git diff --cached --check
git diff --cached --stat
git commit -m 'feat(web): add secure sender receiver workflow over HTTPS'

# Group 4: Repeatable Week 14 verification and evidence
git add -- 'submissions/week-14/tests/Invoke-Week14Security.ps1' 'submissions/week-14/tests/build-reports.py' 'submissions/week-14/tests/security-test-record.md' 'submissions/week-14/tests/http-security-results.json' 'submissions/week-14/tests/tls-results.json' 'submissions/week-14/tests/phpunit-results.xml' 'submissions/week-14/logs/environment.json' 'submissions/week-14/logs/initial-failure-record.md' 'submissions/week-14/logs/backend-tests-final.txt' 'submissions/week-14/logs/backend-tests.txt' 'submissions/week-14/logs/composer-audit.json' 'submissions/week-14/logs/flutter-analysis.txt' 'submissions/week-14/logs/flutter-build-final.txt' 'submissions/week-14/logs/flutter-build.txt' 'submissions/week-14/logs/flutter-tests.txt' 'submissions/week-14/logs/pint-final.txt' 'submissions/week-14/logs/pint.txt' 'submissions/week-14/logs/secret-scan.json' 'submissions/week-14/logs/document-audit/activity-1-cryptography-cases-a11y.json' 'submissions/week-14/logs/document-audit/activity-1-cryptography-cases-style.json' 'submissions/week-14/logs/document-audit/activity-2-secure-exchange-review-a11y.json' 'submissions/week-14/logs/document-audit/activity-2-secure-exchange-review-style.json' 'submissions/week-14/logs/document-audit/IA5-secure-data-exchange-build-a11y.json' 'submissions/week-14/logs/document-audit/IA5-secure-data-exchange-build-style.json' 'submissions/week-14/logs/document-audit/reflection-a11y.json' 'submissions/week-14/logs/document-audit/reflection-style.json' 'submissions/week-14/logs/document-audit/SA8-secure-integration-architecture-a11y.json' 'submissions/week-14/logs/document-audit/SA8-secure-integration-architecture-style.json' 'submissions/week-14/screenshots/app/APP-01-https-coordinator.png' 'submissions/week-14/screenshots/app/APP-02-authenticated-envelope.png' 'submissions/week-14/screenshots/app/APP-03-secure-receive-success.png' 'submissions/week-14/screenshots/app/APP-04-replay-rejected.png' 'submissions/week-14/screenshots/source/SRC-01-aes-gcm-envelope.png' 'submissions/week-14/screenshots/source/SRC-02-authorization-replay-control.png'
git diff --cached --check
git diff --cached --stat
git commit -m 'test(week-14): preserve security and recovery evidence'

# Group 5: Assessments, portfolio reconciliation, and handoff
git add -- 'submissions/week-14/reports/activity-1-cryptography-cases.md' 'submissions/week-14/reports/activity-1-cryptography-cases.docx' 'submissions/week-14/reports/activity-1-cryptography-cases.pdf' 'submissions/week-14/reports/activity-2-secure-exchange-review.md' 'submissions/week-14/reports/activity-2-secure-exchange-review.docx' 'submissions/week-14/reports/activity-2-secure-exchange-review.pdf' 'submissions/week-14/reports/SA8-secure-integration-architecture.md' 'submissions/week-14/reports/SA8-secure-integration-architecture.docx' 'submissions/week-14/reports/SA8-secure-integration-architecture.pdf' 'submissions/week-14/reports/IA5-secure-data-exchange-build.md' 'submissions/week-14/reports/IA5-secure-data-exchange-build.docx' 'submissions/week-14/reports/IA5-secure-data-exchange-build.pdf' 'submissions/week-14/reports/reflection.md' 'submissions/week-14/reports/reflection.docx' 'submissions/week-14/reports/reflection.pdf' 'submissions/week-14/EVIDENCE_INDEX.md' 'submissions/week-14/SUBMISSION_CHECKLIST.md' 'submissions/week-14/SUBMISSION_CONTENTS.md' 'submissions/week-14/source/MANIFEST.md' 'docs/week-14-git-commands.ps1' 'PROJECT_STATUS.md'
git diff --cached --check
git diff --cached --stat
git commit -m 'docs(week-14): finalize SA8 and IA5 portfolio'

# Confirm the final source and documentation state before tagging.
git status --short
git log --oneline --decorate -7

# Create the course milestone tag only after the five commits above succeed.
git tag -a v2.0.0 -m 'Week 14: secure data exchange and encryption'

# No remote is configured. Push the actual current branch and the new tag directly.
git push 'https://github.com/Vernsmoke/thesis-consultation-reminder.git' master
git push 'https://github.com/Vernsmoke/thesis-consultation-reminder.git' v2.0.0

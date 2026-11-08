# Review and run from C:/Users/Laure/Documents/ChatGPT/IPT.
# Prepared but not executed by the agent. Stop on unrelated/private changes.

Set-Location 'C:/Users/Laure/Documents/ChatGPT/IPT'
git status --short
git diff --check

# Group 1 - Laravel/API hardening and focused tests.
$group1 = @(
  'backend/app/Http/Controllers/ConsultationController.php',
  'backend/app/Http/Middleware/ApiContext.php',
  'backend/tests/Feature/Week15HardeningTest.php'
)
git add -- $group1
git diff --cached --check
git diff --cached --stat
git commit -m 'test(api): harden pagination authorization and headers'

# Group 2 - Flutter handling, validation, responsive state, and HTTPS forwarding.
$group2 = @(
  'frontend/lib/api.dart',
  'frontend/lib/main.dart',
  'frontend/test/api_test.dart',
  'frontend/test/week15_hardening_test.dart',
  'tools/serve_week14_https.py'
)
git add -- $group2
git diff --cached --check
git diff --cached --stat
git commit -m 'test(flutter): add safe timeout and protocol handling'

# Group 3 - Repeatable verification, fixtures, actual results, diagrams, and screenshots.
$group3 = @(
  'docs/week-15-test-strategy.md',
  'submissions/week-15/diagrams/test-architecture.json',
  'submissions/week-15/diagrams/test-architecture.mmd',
  'submissions/week-15/diagrams/test-architecture.svg',
  'submissions/week-15/tests/api-results.json',
  'submissions/week-15/tests/controlled-fixtures.md',
  'submissions/week-15/tests/defect-records.md',
  'submissions/week-15/tests/failure-injection-record.md',
  'submissions/week-15/tests/hardening-backlog.md',
  'submissions/week-15/tests/Invoke-Week15Api.ps1',
  'submissions/week-15/tests/phpunit-results.xml',
  'submissions/week-15/tests/README.md',
  'submissions/week-15/tests/regression-results.md',
  'submissions/week-15/tests/Run-Week15Verification.ps1',
  'submissions/week-15/tests/Thesis-Consultation-Week15.postman_collection.json',
  'submissions/week-15/tests/traceability-matrix.md',
  'submissions/week-15/tests/training-fixture-hardened-config.yaml',
  'submissions/week-15/tests/training-fixture-weak-config.yaml',
  'submissions/week-15/logs/backend-tests.txt',
  'submissions/week-15/logs/composer-audit.json',
  'submissions/week-15/logs/environment.json',
  'submissions/week-15/logs/flutter-analysis.txt',
  'submissions/week-15/logs/flutter-build.txt',
  'submissions/week-15/logs/flutter-tests.txt',
  'submissions/week-15/logs/initial-failure-record.md',
  'submissions/week-15/logs/pint.txt',
  'submissions/week-15/logs/README.md',
  'submissions/week-15/logs/secret-scan.json',
  'submissions/week-15/screenshots/app/APP-01-week15-login-https.png',
  'submissions/week-15/screenshots/app/APP-02-boundary-and-normal-records.png',
  'submissions/week-15/screenshots/app/APP-03-client-validation.png',
  'submissions/week-15/screenshots/app/APP-04-effective-640px-layout.png',
  'submissions/week-15/screenshots/source/SRC-01-early-authorization-hardening.png',
  'submissions/week-15/screenshots/source/SRC-02-traceable-hardening-tests.png'
)
git add -- $group3
git diff --cached --check
git diff --cached --stat
git commit -m 'test(week15): preserve integration and hardening evidence'

# Group 4 - Student-facing activities, IA6, reflection, and verified document QA.
$group4 = @(
  'submissions/week-15/tests/build-reports.py',
  'submissions/week-15/reports/activity-1-traceability-matrix.md',
  'submissions/week-15/reports/activity-1-traceability-matrix.docx',
  'submissions/week-15/reports/activity-1-traceability-matrix.pdf',
  'submissions/week-15/reports/activity-2-hardening-sprint.md',
  'submissions/week-15/reports/activity-2-hardening-sprint.docx',
  'submissions/week-15/reports/activity-2-hardening-sprint.pdf',
  'submissions/week-15/reports/IA6-integration-testing-hardening.md',
  'submissions/week-15/reports/IA6-integration-testing-hardening.docx',
  'submissions/week-15/reports/IA6-integration-testing-hardening.pdf',
  'submissions/week-15/reports/reflection.md',
  'submissions/week-15/reports/reflection.docx',
  'submissions/week-15/reports/reflection.pdf',
  'submissions/week-15/logs/document-audit/activity-1-traceability-matrix-a11y.json',
  'submissions/week-15/logs/document-audit/activity-1-traceability-matrix-a11y.txt',
  'submissions/week-15/logs/document-audit/activity-1-traceability-matrix-headings.txt',
  'submissions/week-15/logs/document-audit/activity-1-traceability-matrix-style.json',
  'submissions/week-15/logs/document-audit/activity-1-traceability-matrix-style.txt',
  'submissions/week-15/logs/document-audit/activity-2-hardening-sprint-a11y.json',
  'submissions/week-15/logs/document-audit/activity-2-hardening-sprint-a11y.txt',
  'submissions/week-15/logs/document-audit/activity-2-hardening-sprint-headings.txt',
  'submissions/week-15/logs/document-audit/activity-2-hardening-sprint-style.json',
  'submissions/week-15/logs/document-audit/activity-2-hardening-sprint-style.txt',
  'submissions/week-15/logs/document-audit/IA6-integration-testing-hardening-a11y.json',
  'submissions/week-15/logs/document-audit/IA6-integration-testing-hardening-a11y.txt',
  'submissions/week-15/logs/document-audit/IA6-integration-testing-hardening-headings.txt',
  'submissions/week-15/logs/document-audit/IA6-integration-testing-hardening-style.json',
  'submissions/week-15/logs/document-audit/IA6-integration-testing-hardening-style.txt',
  'submissions/week-15/logs/document-audit/reflection-a11y.json',
  'submissions/week-15/logs/document-audit/reflection-a11y.txt',
  'submissions/week-15/logs/document-audit/reflection-headings.txt',
  'submissions/week-15/logs/document-audit/reflection-style.json',
  'submissions/week-15/logs/document-audit/reflection-style.txt'
)
git add -- $group4
git diff --cached --check
git diff --cached --stat
git commit -m 'docs(week15): add IA6 activities reports and reflection'

# Group 5 - Requirement reconciliation, provenance, shared guidance, and handoff.
$group5 = @(
  'CHANGELOG.md',
  'README.md',
  'PROJECT_STATUS.md',
  'docs/api.md',
  'docs/week-15-git-commands.ps1',
  'prompts/week-15.md',
  'submissions/week-15/EVIDENCE_INDEX.md',
  'submissions/week-15/SUBMISSION_CHECKLIST.md',
  'submissions/week-15/SUBMISSION_CONTENTS.md',
  'submissions/week-15/source/MANIFEST.md'
)
git add -- $group5
git diff --cached --check
git diff --cached --stat
git commit -m 'docs(status): reconcile Week 15 IA6 milestone'

# Confirm only expected future prompts and temporary QA directories remain untracked.
git status --short
git log --oneline -5

# No remote was configured at preparation time. Add the supplied repository only if still absent;
# stop rather than silently replace a differently configured origin.
$expectedOrigin = 'https://github.com/Vernsmoke/thesis-consultation-reminder.git'
$currentOrigin = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
  git remote add origin $expectedOrigin
} elseif ($currentOrigin -ne $expectedOrigin) {
  throw "Existing origin is '$currentOrigin'; review it before pushing."
}
git remote -v

git tag -a v3.0.0 -m 'Week 15: integration testing and security hardening'
git push origin master
git push origin v3.0.0
git ls-remote origin refs/heads/master refs/tags/v3.0.0 refs/tags/v3.0.0^{}

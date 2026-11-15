# Run from C:\Users\Laure\Documents\ChatGPT\IPT after reviewing `git diff` and `git status`.
# Reviewed release sequence. Executed by the agent on 2026-11-15 after the user explicitly authorized the GitHub release.

# Group 1 - Week 16 scope and readiness implementation
git add -- 'prompts/week-16.md' 'README.md' 'CHANGELOG.md' 'backend/.env.example' 'backend/config/database.php' 'backend/routes/web.php' 'backend/tests/Feature/ExampleTest.php'
git diff --cached --check
git commit -m 'feat(week16): add bounded deployment readiness signals'

# Group 2 - Reproducible workload and operational evaluation design
git add -- 'submissions/week-16/diagrams/deployment-monitoring.mmd' 'submissions/week-16/tests/build-reports.py' 'submissions/week-16/tests/deployment-checklist.md' 'submissions/week-16/tests/environment-comparison.md' 'submissions/week-16/tests/monitoring-map.md' 'submissions/week-16/tests/rollback-plan.md' 'submissions/week-16/tests/run_week16_evaluation.py' 'submissions/week-16/tests/workload-models.md'
git diff --cached --check
git commit -m 'test(week16): define workloads monitoring and recovery evaluation'

# Group 3 - Actual performance reliability and browser evidence
git add -- 'submissions/week-16/logs/artifact-validation.txt' 'submissions/week-16/logs/backend-tests.txt' 'submissions/week-16/logs/environment.json' 'submissions/week-16/logs/flutter-analysis.txt' 'submissions/week-16/logs/flutter-build.txt' 'submissions/week-16/logs/flutter-tests.txt' 'submissions/week-16/logs/initial-failure-record.md' 'submissions/week-16/logs/performance-address-finding.md' 'submissions/week-16/logs/performance-run.txt' 'submissions/week-16/logs/pint.txt' 'submissions/week-16/logs/render-final-activity-1-workload-models.txt' 'submissions/week-16/logs/render-final-activity-2-deployment-review.txt' 'submissions/week-16/logs/render-final-reflection-preparation.txt' 'submissions/week-16/logs/render-final2-week-16-deployment-evaluation.txt' 'submissions/week-16/logs/secret-scan.json' 'submissions/week-16/screenshots/app/APP-01-https-desktop-login.png' 'submissions/week-16/screenshots/app/APP-02-browser-readiness.png' 'submissions/week-16/screenshots/source/SRC-01-readiness-implementation.png' 'submissions/week-16/tests/failure-recovery.json' 'submissions/week-16/tests/performance-initial-localhost-raw.csv' 'submissions/week-16/tests/performance-initial-localhost.json' 'submissions/week-16/tests/performance-raw.csv' 'submissions/week-16/tests/performance-summary.json' 'submissions/week-16/tests/phpunit-results.xml' 'submissions/week-16/tests/resource-samples-initial-localhost.json' 'submissions/week-16/tests/resource-samples.json'
git diff --cached --check
git commit -m 'test(week16): preserve deployment performance and recovery evidence'

# Group 4 - Activities and assessment reports
git add -- 'submissions/week-16/reports/activity-1-workload-models.md' 'submissions/week-16/reports/activity-1-workload-models.docx' 'submissions/week-16/reports/activity-1-workload-models.pdf' 'submissions/week-16/reports/activity-2-deployment-review.md' 'submissions/week-16/reports/activity-2-deployment-review.docx' 'submissions/week-16/reports/activity-2-deployment-review.pdf' 'submissions/week-16/reports/week-16-deployment-evaluation.md' 'submissions/week-16/reports/week-16-deployment-evaluation.docx' 'submissions/week-16/reports/week-16-deployment-evaluation.pdf' 'submissions/week-16/reports/reflection-preparation.md' 'submissions/week-16/reports/reflection-preparation.docx' 'submissions/week-16/reports/reflection-preparation.pdf' 'submissions/week-16/EVIDENCE_INDEX.md' 'submissions/week-16/SUBMISSION_CHECKLIST.md' 'submissions/week-16/SUBMISSION_CONTENTS.md'
git diff --cached --check
git commit -m 'docs(week16): complete deployment evaluation portfolio'

# Provenance handoff and release. The reflection remains explicitly marked as preparation until the student confirms its personal voice.
git status --short --branch
git log -4 --oneline
git tag -a v4.0.0 -m 'Week 16: performance reliability and deployment evaluation'
git push origin master
git push origin v4.0.0

# Verify the pushed branch and annotated tag without changing repository state.
git ls-remote --heads origin master
git ls-remote --tags origin v4.0.0 'v4.0.0^{}'

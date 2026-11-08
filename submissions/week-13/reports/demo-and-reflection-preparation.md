# Week 13 demonstration and reflection preparation

## Demonstration

1. Show versions and requirement map; explain the controlled simulated transport and the student's 8 November 2026 registration confirmation.
2. Student requests future UTC consultation with fictional agenda; adviser confirms and adds a future action; student completes follow-up; adviser completes meeting; panel reviews assigned outcome.
3. Coordinator opens automation metrics and manual-review records. Show real-time controlled-delivery.json: success, transient→retry→delivered, permanent→manual_review, timeout→three attempts→manual_review. Explain each correlation and why early reruns do not process.
4. Reproduce invalid input, wrong role and duplicate key using repeatable tests. Explain stale reminder suppression and crash rollback.
5. Show runbook, source, limitations and source manifest. Backup: sanitized test output and JSON audit evidence. Backup is not a substitute for a working browser when assessment requires it.

## Student reflection prompts requiring personal answers

1. Which decision most affected reliability/security, and which evidence changed or confirmed your view? Review transactional outbox and duplicate/recovery tests, then state your own conclusion.
2. Which failure/limitation was hardest for you to reproduce, and how would you improve the test design? Initial records include clock-travel expiry and Flutter test syntax; do not describe these as your personal experience unless you reproduced them.
3. What exact submitted artifact can you explain and modify independently? Reproduce a controlled change to Automation.php or a Flutter form and identify the artifact and check. No independent contribution is certified here.
4. What should an authorized maintainer verify next before broader use, and why is it beyond current evidence? Consider HTTPS, real transport idempotency, large datasets and independent scheduler alerts.

## Viva preparation

Explain task versus integration automation, why browser timers were rejected, why retries exclude validation failures, how UTC and Manila differ, why a transaction protects only the simulated receiver, what manual review means, and what the source manifest does not prove. The student confirmed that the reflection reflects their understanding. Actual oral-defense results, marks and instructor decisions remain external and are not claimed.

# Project Status

## Project and current milestone

- Student: Laurence Matthew B Manuel
- Section: BSIT 3A
- Project: Project 29, Thesis Consultation Reminder System
- Workspace: `C:/Users/Laure/Documents/ChatGPT/IPT`
- Current authorized milestone: Week 14, SA8 and IA5
- Week 14 work completed on 2026-11-08 Asia/Manila; the historical 2026-11-06 deadline was not used as an evidence date
- Required stack: Flutter Web, Laravel API, XAMPP MariaDB/MySQL-compatible database

## Confirmed Git state

- Branch: `master`
- Week 14 source/evidence checkpoint: `03d9ed372bbf2e83c59d50c9e5707e0cddf86b7d`; it extends the verified Week 13 milestone without rewriting it
- No Git remote is configured. The intended repository is `https://github.com/Vernsmoke/thesis-consultation-reminder.git`
- The user explicitly authorized the Week 14 commit, tag, and direct-push operations in this chat
- Reviewed exact-path commands and five meaningful commit groups are recorded in `docs/week-14-git-commands.ps1`; future Week 15–18 prompts and temporary QA files are excluded

## Week 14 implementation completed

- Added coordinator-created, adviser-received consultation envelopes using PHP OpenSSL AES-256-GCM with a random 96-bit nonce, 128-bit tag, and canonical authenticated metadata.
- Bound envelopes to version, key ID, UUID message ID, issue/expiry time, sender, and recipient. The five-minute lifetime, 30-second future-skew allowance, and unique receipt table reject stale or replayed messages.
- Kept keys outside Flutter and tracked source through an ignored server keyring. Added a provisioning/rotation command that does not print the key and retains only the previous bounded-use key.
- Enforced expiring authentication, coordinator/adviser roles, exact recipient and consultation assignment, route throttles, server validation, generic safe errors, no-store/security response headers, correlation IDs, and allowlisted security logs.
- Minimized exchanged plaintext to record type, consultation ID, agenda, scheduled time, status, and open-action count; names, email, action text, sessions, automation history, and audit history are excluded.
- Added controlled local HTTPS for the Flutter build and API with a short-lived localhost CA/certificate, TLS 1.2 minimum, strict origin allowlist, and no warning bypass. The evidence gateway is explicitly not a production proxy.
- Extended Flutter Web with coordinator envelope creation, adviser paste/receive, accepted record, replay/auth/network/validation feedback, and HTTPS API default.

## Verification and evidence

- Backend regression: 21 tests, 199 assertions, all passing. Cases cover normal acceptance, altered ciphertext, altered authenticated metadata, replay, authentic expiry, invalid input, unauthorized/unassigned users, wrong key, missing-key recovery, and safe log contents.
- Live HTTPS script executed 2026-11-08T20:37:08+08:00: five of five expected outcomes matched (`200`, `409`, `422`, `403`, `422`).
- TLS verification executed 2026-11-08T20:37:12+08:00: TLS 1.3 with `TLS_AES_256_GCM_SHA384`; the client without the controlled trust anchor rejected the certificate.
- Flutter regression: 18 tests pass, static analysis reports no issues, and the release web build succeeds with the HTTPS API URL.
- Laravel Pint passes. Composer audit reports no advisories. Final pre-release secret scan covered 184 candidate text files and found no exact generated key/private fixture-password match; protected private paths remain ignored.
- Actual Edge and VS Code evidence: APP-01 through APP-04 and SRC-01 through SRC-02, captured 2026-11-08 20:35–20:46 +08:00 with fictional data and indexed SHA-256 hashes.
- Initial controlled CORS preflight failure, safe behavior, allowlisted fix, and successful browser rerun are preserved. Backend and Flutter test expectation/viewport failures and their regressions are also recorded honestly.
- Five DOCX reports and matching PDFs were rendered through LibreOffice. All ten pages were visually inspected. Accessibility audits report zero high, medium, or low findings; style-lint reports are retained for transparency.

## Submission artifacts

- Reports: Activity 1, Activity 2, SA8, IA5, and the evidence-grounded technical reflection in Markdown, DOCX, and PDF.
- Shared records: security architecture, protection requirements, control rationale, cryptographic decision, key lifecycle, residual-risk register, and updated setup/changelog.
- Diagrams: editable Mermaid, structural JSON, and SVG exports for secure data flow and sender/receiver sequence.
- Evidence: expected/actual security test record, live HTTPS/TLS JSON, PHPUnit XML, sanitized build/test/audit/scan logs, screenshots, evidence index, and requirement checklist.
- A clean local ignored archive was generated from source commit `03d9ed3`; it contains 156 entries and has SHA-256 `28e188b53d663d800e36e998899bcb7728f1110aea6e4cfa0fba9b670c5349f7`. Provenance is recorded in `submissions/week-14/source/MANIFEST.md`.

## Pending external or user actions

1. Apply any instructor-prescribed AI acknowledgment wording or submission template; none was supplied.
2. Conduct any instructor oral assessment, marking, or acceptance. No result is claimed.
3. Remove the controlled local CA from the user trust store when the evidence environment is no longer needed.

## Next action

Week 14 is ready for the `v2.0.0` release operation. After the authorized tag and push complete, remain on Week 14 unless the user explicitly requests Week 15.

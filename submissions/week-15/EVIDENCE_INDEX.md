# Week 15 Evidence Index

Student: Laurence Matthew B Manuel  
Section: BSIT 3A  
Project: Project 29, Thesis Consultation Reminder System  
Evidence date/timezone: 2026-11-08, Asia/Manila (Windows records `Singapore Standard Time`, the same UTC+08:00 offset)  
Source state: uncommitted Week 15 working tree based on `133b0c8`

## Executed verification

| ID | Evidence | Observed result | Path |
|---|---|---|---|
| RUN-01 | Final full gate, 22:13:45–22:15:01 +08:00 | Laravel 24/227; Flutter 22; analyze, Pint, release web build passed | `logs/environment.json`, `logs/backend-tests.txt`, `logs/flutter-tests.txt`, `logs/flutter-analysis.txt`, `logs/flutter-build.txt`, `logs/pint.txt` |
| API-01–14 | Live HTTPS collection, 21:42:17–21:42:25 +08:00 | 14/14 expected normal/adverse outcomes passed | `tests/api-results.json` |
| FAIL-01 | Initial targeted tests | Five protections failed before implementation | `logs/initial-failure-record.md` |
| REG-01 | Full regression | Initial layout regression retained; corrected rerun passed | `tests/regression-results.md` |
| AUD-01 | Dependency/hygiene, 22:15:03 +08:00 | Composer: no advisory; final secret scan: 244 files, zero generated-secret/private-key matches | `logs/composer-audit.json`, `logs/secret-scan.json` |
| DOC-01 | DOCX/PDF QA | Seven A4 pages visually inspected; four DOCX audits report 0 high/medium/low accessibility findings | `logs/document-audit/` and final reports |
| DIA-01 | Test architecture | Editable Mermaid, structural JSON, and SVG agree | `diagrams/test-architecture.*` |

## Actual application screenshots

| ID | Time +08:00 | Scenario and result | File | SHA-256 |
|---|---|---|---|---|
| APP-01 | 21:45:12 | Week 15 Flutter login over trusted local HTTPS; no credential visible | `screenshots/app/APP-01-week15-login-https.png` | `e496bd595425d551057d11fce2abec348ecfe10c3041f7f3e8499924c227f4e0` |
| APP-02 | 21:46:04 | Authenticated student list with maximum-boundary and normal fictional records | `screenshots/app/APP-02-boundary-and-normal-records.png` | `018df45d0e35ce24194f5453d059c8ae9ed67bfeefd5ea32dfac4641f4d80ac1` |
| APP-03 | 21:46:34 | Client validation prevents invalid consultation submission | `screenshots/app/APP-03-client-validation.png` | `b419030bfffa2468ba711b1045cd8946673882909daab1e70ed3a7a2384f485e` |
| APP-04 | 21:47:43 | Effective 640 CSS-pixel review using Edge 300% zoom; responsive layout remains usable | `screenshots/app/APP-04-effective-640px-layout.png` | `b53b7ae901c97e138e3175ca035c7ab8d4e22cbc0efa5fa6d966651ec692219c` |

## Actual source screenshots

| ID | Time +08:00 | Scenario and result | File | SHA-256 |
|---|---|---|---|---|
| SRC-01 | 21:47:57 | Early receiver-role and recipient authorization before envelope opening | `screenshots/source/SRC-01-early-authorization-hardening.png` | `29ad7d9d9a7e791af7fb783bb74a2978c7788b5df5a5791767d3cb05da66d47c` |
| SRC-02 | 21:48:29 | Traceable Week 15 Laravel hardening tests | `screenshots/source/SRC-02-traceable-hardening-tests.png` | `faf4d571d75280e0a569f6cf739ca03400531d051fdd1313e19574427ab799ef` |

## Provenance and limitations

All identities and consultation content are fictional. Screenshots are actual Edge/VS Code captures, not generated execution evidence. Logs omit passwords, bearer tokens, envelope keys, and private certificate material. The live collection uses the controlled local HTTPS gateway and MariaDB fixture database. Performance, public hosting, concurrency capacity, all browsers/assistive technologies, instructor marking, and production acceptance are not evidenced. Regenerate the source package after the user confirms the Week 15 source commit; no uncommitted working tree is labeled as `v3.0.0`.

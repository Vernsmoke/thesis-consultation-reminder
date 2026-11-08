# Week 14 Initial Failure and Improvement Record

All times are 2026-11-08 Asia/Manila unless a tool emitted an explicit offset.

| Failure | Safe observed behavior | Improvement | Rerun outcome |
|---|---|---|---|
| Browser CORS preflight failed through the local TLS gateway | No authenticated request reached the API; no data changed; the UI reported an unavailable service | Forward only the browser-requested method/header metadata and continue to allow only `https://localhost:8444` | HTTPS login, envelope creation, receipt, and replay rejection succeeded in Edge |
| Missing secure-exchange key test expected an internal explanation | Laravel returned a generic `503`; key/path detail remained private | Corrected the test to assert the external safe-error contract | Backend regression: 21 tests and 199 assertions passed |
| Flutter secure-exchange widget test could not find controls below the lazy viewport | Test failed without changing application state | Scrolled the test surface before interacting, matching real UI navigation | Flutter regression: 18 tests passed |

These are genuine development failures. They are not evidence of an instructor-supplied vulnerable system and are not represented as historical events before 2026-11-08.

# Controlled Fixture Record

## Identities and data

The local seeder maintains fictional `student`, `adviser`, `panel`, `coordinator`, and second-student accounts under `example.test`. The private fixture password is loaded from `backend/.env` only at runtime and is excluded from saved output. Automated tests use in-memory or test-database users clearly named Week 15 or Fictional.

Live API records use agendas `Week 15 controlled integration test`, a maximum-length string of 1000 `x` characters, and future UTC schedule times generated at execution. Past times appear only where a controlled missed-session or deadline test requires them; their record creation and capture timestamps are current and are not backdated.

## Cleanup and isolation

Laravel feature tests use `RefreshDatabase`. The live collection intentionally leaves its clearly labeled controlled records available for browser evidence; it does not alter earlier submission folders. Credentials, bearer tokens, private keys, full encrypted envelopes, and database passwords are never written to the Week 15 results.

## Reproduction

1. Configure the private backend `.env` from `.env.example`, migrate, and seed locally.
2. Start the Laravel server and the controlled HTTPS proxy and web server.
3. Run `submissions/week-15/tests/Invoke-Week15Api.ps1` from the repository root.
4. Run `submissions/week-15/tests/Run-Week15Verification.ps1` for full tests, analysis, build, audit, and environment capture.

# Week 13 security and configuration checklist

- Server-side user role and assignment checks; panel read-only; student owns request/action follow-up; adviser owns assigned confirmation/action entry; coordinator all workflow/manual handling.
- Opaque two-hour bearer sessions stored hashed; password verification through Laravel Hash; no token persistence in browser storage. Logout invalidates current token. Demo password generated privately; seeder refuses nonlocal/nontesting use.
- Login limited to ten requests/minute. CORS limited to loopback frontend origins. CORS is not authorization. No credentials or service tokens compiled into Flutter.
- Dedicated database account restricted to the development/test schemas. Migration privileges are local development privileges; deployment needs a lower privilege runtime account.
- .env, dependencies, cache, database files, logs, tmp and generated archives excluded. Example contains no secrets. Operator retrieves fixture password privately from local .env without copying to submission.
- APP_DEBUG=false; safe API errors return correlation; logs use explicit fields (IDs, outcomes, attempts) without request body, password, token or agenda. Protected framework errors may contain internal details; do not export them wholesale.
- Lockfiles control dependencies; run Composer audit and Flutter analysis/tests. Rotate demo password by editing ignored .env, rerun seeder and revoke sessions; rotate app/database secrets only with operator coordination and backups.
- No production endpoints, real data, mail/SMS claims or instructor approval. HTTP only on loopback; HTTPS and fuller security evaluation belong to Week 14.

Residual risks: no production identity administration, HTTPS, distributed rate limiting or external alert delivery; local host compromise defeats .env protection; summaries catch up only today's cutoff; scans currently load matching records into memory; no measured production volume or external notification guarantee. These are reasons to keep use controlled, not unsupported claims of safety.

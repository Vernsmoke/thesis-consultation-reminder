# Week 13 API contract

Base `http://127.0.0.1:8000/api` (loopback development). JSON requests with Accept/Content-Type application/json. Bearer opaque two-hour session except login. No confidential service credential in Flutter. Server creates X-Correlation-ID. Errors are JSON `{message, correlation_id, errors?}`; 500 hides diagnostics. CORS allows only loopback port 8080.

| Method path | Request | Authority and result |
|---|---|---|
| POST /login | email, password | 200 token and user id/name/role; 401 invalid; 422 validation; 429 login rate limit |
| POST /logout | empty | Authenticated; deletes current session; 200 |
| GET /consultations | none | Own/assigned/all for coordinator; newest 100, nested actions, adviser/panel directory |
| POST /consultations | agenda 5–1000 characters, scheduled_at future UTC `YYYY-MM-DDTHH:MM:SSZ`, adviser_id valid adviser, nullable panel_id valid panel | Student; Idempotency-Key 8–80 alphanumeric/underscore/hyphen; 201 id, 200 same-key replay, 409 changed payload |
| PATCH /consultations/{id} | status confirmed/completed/cancelled | Assigned adviser or coordinator; requested→confirmed/cancelled; confirmed/missed→completed/cancelled; 200 or 409 |
| POST /consultations/{id}/actions | description 5–500 characters, due_at future strict UTC | Adviser/coordinator, meeting confirmed/completed/missed; 201 id |
| PATCH /actions/{id}/complete | empty | Student owner/coordinator; idempotent done; 200 |
| GET /automation | none | Coordinator, newest 100 events, pending/manual_review/delivered/attempt counters |
| POST /automation/{id}/resolve | resolution 10–500 characters | Coordinator; manual_review only; 200 resolved without resend; 409 other status |

All protected endpoints: 401 unauthenticated/expired, 403 wrong role/owner, 404 missing numeric item, 422 invalid input, 500 dependency/server failure. Validation may return field-specific errors. Client timeout: eight seconds on send and eight seconds on streamed response; timeout does not prove server failure. Keep the request form/key and retry unchanged. Request idempotency applies to consultation creation; action creation has no separate idempotency key and must be reconciled through refresh after ambiguous failure. This is a residual limitation, not an exactly-once guarantee.

Session roles cannot be supplied in request fields. Opaque token hashes never appear in responses except the one-time plaintext token at successful login. Operational audits record IDs/transitions, not payload text. API response fields use fictional data and do not establish production data-retention rules.

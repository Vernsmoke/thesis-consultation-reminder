# Week 13 scope and architecture

Project 29 is a controlled educational prototype. Registration is unconfirmed. AI assistance allowed per user; no instructor approval claimed. Date: 2026-11-08 Asia/Manila.

Students request consultations with a proposed UTC time and agenda. Assigned advisers or coordinators confirm, complete or cancel a consultation and record action items. Students complete their own action items. Panel members read assigned consultations. Coordinators inspect automation and resolve permanent failures. Human decisions remain human; automation never confirms a consultation or grades progress.

Task automation means one reminder delivery; integration automation connects validated API state to the notification transport; orchestration coordinates due scans, durable outbox, attempts and recovery; the bounded business process includes student requests and human confirmation/follow-up.

Trust boundary: public Flutter browser → loopback Laravel API → dedicated XAMPP MariaDB schema. The API authenticates opaque session tokens, assigns roles from stored users, validates ownership and state transitions. Configuration and token hashes stay server-side. Notification transport is a controlled database receipt, not email/SMS. Agenda/action text are fictional but excluded from operational logs. Correlation IDs and numeric entity IDs support investigation.

Screen flow: sign in → consultation list/empty state → request form → consultation detail → confirmation/completion and action items → follow-up; coordinator automation panel shows retries/manual handling. Reusable status, form and error widgets support loading, validation, authentication, forbidden, network and server feedback. Layout changes at 700px; all controls have readable labels and keyboard focus.

Non-goals: thesis files, grading, plagiarism, video, production integrations, mobile packages, Week 14 crypto evaluation. Local HTTP is for loopback development only; secure transport remains Week 14 work.

Acceptance: valid request creates one row; replay creates none; invalid request 422; unauthenticated 401; unassigned role 403; invalid state 409; missing item 404. Each due event creates one durable outbox key. Transient attempts remain queued, permanent/exhausted attempts become manual_review. Repeated scans do not duplicate receipts. Review requires coordinator and reason.

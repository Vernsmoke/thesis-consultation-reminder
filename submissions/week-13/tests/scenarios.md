# Predicted outcomes before evidence execution

Build: uncommitted Week 13 working tree; actual source manifest produced after final checks. All records fictional. Unit/feature test clocks may advance for due behavior; the capture/execution timestamp remains real.

| Scenario | Prediction and pass criterion |
|---|---|
| S01 successful workflow | Student requests once; assigned adviser confirms, creates action, completes meeting; student completes action; panel can read |
| S02 invalid inputs | Empty/too-long agenda and past time →422; no new consultation |
| S03 authentication | No token, expired token, wrong password →401 |
| S04 forbidden | Student/panel/other owner cannot manage; other student list empty |
| S05 idempotency | Same key+payload returns same ID; changed input →409; one consultation |
| S06 not found/state | Missing ID →404; requested→completed →409 |
| S07 delivery success | Repeated worker and enqueue cause one outbox/receipt, one attempt |
| S08 transient recovery | First attempt retry with 60–75s delay; early call no increment; after due second delivers once |
| S09 permanent/manual | First attempt manual_review; student forbidden to resolve; coordinator records handling; no resend |
| S10 retry exhaustion | Persistent timeout reaches manual_review after exactly three attempts, never an endless loop |
| S11 four automations | Controlled clock after cutoff yields reminder, missed, deadline and summary; second scan no duplicate |
| S12 stale reminder | Cancelled consultation's pending reminder becomes superseded with no receipt |
| S13 rollback/recovery | Exception after simulated receipt insert rolls transaction back; pending row retained, rerun one receipt |
| UI01 validation | Empty email/password blocked locally with labels |
| UI02 responsiveness | 390/768/1440 widths no layout exception; real browser checks also needed |
| UI03 failure mapping | API 403 preserves reference, network/timeout safe feedback |

Repeat: backend `php artisan test`; frontend `flutter analyze`, `flutter test`, `flutter build web --no-wasm-dry-run`. Backend test database is forcibly named thesis_consultation_w13_test; never point test credentials at another schema. RefreshDatabase recreates only this dedicated test schema.

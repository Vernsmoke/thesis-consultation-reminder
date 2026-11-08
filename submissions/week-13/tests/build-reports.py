"""Generate editable reports and matching LibreOffice-converted PDFs.
Run with the bundled Python, then visually verify the DOCX and PDF renders.
"""
import json
import shutil
import subprocess
import tempfile
from pathlib import Path
from docx import Document
from docx.shared import Inches,Pt,RGBColor
from docx.oxml.ns import qn

root=Path(__file__).resolve().parents[3]
out=root/'submissions/week-13/reports'
run=json.loads((root/'submissions/week-13/logs/controlled-delivery.json').read_text())
identity='Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29'
date='Prepared 8 November 2026 | Asia/Manila | Week 13 SA7'
reports={
'SA7-automation-report':[
('Thesis Consultation Automation Case',[
('Purpose and bounded result','The Week 13 prototype connects a Flutter Web interface, Laravel API and XAMPP MariaDB to manage thesis consultation requests, human schedule confirmation, agendas, meeting status, action items and follow-up. A durable outbox automates reminders, missed-session handling, action deadlines and progress summaries. Delivery is a controlled simulated database receipt; it is not email or SMS and has no instructor-approved transport claim.'),
('Workflow and decision authority','Students request their own consultations. Assigned advisers confirm schedules, add action items and record outcomes. Panel members read assigned consultations. Coordinators review the workflow and record human handling of delivery exceptions. The server determines role and ownership from authenticated stored users. Automation does not approve meetings, assess research quality or award grades.'),
('Architecture and alternatives','The selected hybrid handles human state changes through validated API calls and scans due work each minute. A relational outbox preserves work when the scheduler is stopped and deduplicates business events with unique keys. Browser timers were rejected because they stop with the client. A separate broker queue could reduce latency and improve scale, but adds a service and worker operations to this local prototype. Database scanning incurs read and locking costs and needs an operator to keep scheduling alive.'),
('Evidence scope','The portfolio contains implementation source, configuration examples, repeatable tests, sanitized execution records, editable diagrams, decisions and recovery guidance. Tests cover successful and adverse paths. Real source captures and user-supplied running Flutter screenshots preserve the request, confirmation, action-item, validation, manual-review, desktop, tablet and narrow-layout states. Automated tests and HTTP/log evidence remain the behavioral proof behind those visual records.'),
]),
('Reliable Execution and Protected Configuration',[
('Triggers and time rules','Timestamps are stored in UTC; the interface labels Manila display times and UTC form input. A confirmed future meeting within 24 hours receives one reminder. A confirmed meeting without a recorded outcome becomes missed after 30 minutes. Open action items reaching due time generate one deadline event. A current-day progress summary is due at or after 17:00 Manila. These are explicit project decisions, not instructor-established rules. Prior-day summary backfill is a known limitation.'),
('Failure and recovery contract','The worker processes at most 50 eligible events per batch. Transient failures receive exponential delays of 60 then 120 seconds plus 0 to 15 seconds jitter. Three total attempts is the cap. Permanent failures immediately enter manual review. Early runs skip the next-available timestamp. A simple circuit breaker stops a batch after three transient failures. Stale reminder/deadline work is superseded rather than delivered. This is not a distributed production circuit breaker.'),
('Idempotency and durable checkpoints','Consultation creation requires a per-user idempotency key and matching payload hash. A replay returns the stored consultation ID, while changed input under the same key returns 409. Automation uses unique event keys and one receipt per outbox row. Row locks serialize processing. For this simulated transport, the receipt, attempt state and audit commit in one transaction; a controlled crash test verifies rollback and safe rerun. A real external provider would need its own deduplication and reconciliation.'),
('Configuration and access','The backend uses private environment configuration, generated local credentials, password hashes and hashed two-hour bearer sessions. Flutter contains no confidential service credentials. CORS is restricted to loopback origins; it is not an authorization control. Role and ownership checks, server validation, safe JSON errors, correlation identifiers and allowlisted audit fields protect the local foundation. HTTPS and the Week 14 secure-exchange exercise remain outside Week 13.'),
]),
('Verification Evaluation and Limitations',[
('Observed controlled delivery',f'The real-time experiment took {run["elapsed_seconds"]} seconds. A success produced one receipt at attempt 1; a transient failure recovered at attempt 2; a permanent failure entered manual review at attempt 1; and a persistent timeout entered manual review at attempt 3. The final state contains two receipts and two manual-review events, with zero pending events. Capture time: {run["captured_at_manila"]}. The complete attempt timeline, correlations and sanitized audits are preserved in logs/controlled-delivery.json.'),
('Repeatable checks and improvement','The backend suite exercises the full request-to-follow-up path, invalid and boundary input, expired authentication, wrong roles/owners, idempotency conflicts, missing records, invalid transitions, stale reminders, all four automations, retry recovery, exhaustion and crash rollback. The initial suite had one fixture failure: advancing the clock to 2030 expired 2026 sessions. Renewing the controlled test session after clock travel corrected the fixture without weakening production authentication. Initial failures remain documented; the final log and JUnit report provide exact current counts.'),
('Performance and maintainability','Worker output records elapsed milliseconds, processed count, transient failures and pending/manual backlog. The experiment demonstrates bounded behavior for a small controlled fixture; it does not measure peak throughput, resource usage or production availability. Separate controller, automation, transport and audit components allow a future transport change without moving service credentials into the client. Lockfiles, dedicated test schemas and one command for due scans support reproduction. Scans currently load matching rows into memory and require workload evaluation before broader use.'),
('Residual risk and maintenance','An operator must monitor scheduler exit status, pending age and manual-review count. The prototype has no independent external alert channel, real delivery guarantee, full account administration or production deployment evaluation. Action creation must be reconciled after an ambiguous response. The coordinator records human handling without resetting failed attempts. Before wider use, verify secure transport, provider idempotency/timeouts, data retention, workload behavior and operational ownership.'),
('Sources and academic responsibility','Teacher Project 29 and Module 13 define the scope. Official Laravel 12 deployment/scheduling documentation, Flutter responsive design guidance and Microsoft Azure Retry pattern informed implementation decisions; URLs are listed in docs/decisions.md. AI assisted source, tests and documentation with user permission. On 8 November 2026, the student confirmed that the reflection reflects their understanding and that Project 29 registration is approved. Any instructor-prescribed acknowledgment wording, final oral assessment and marks remain outside this report.'),
])],
'activity-1-pattern-selection':[
('Office Workflow Trigger Selection',[
('Task and assumptions','This Activity 1 record compares three self-created classroom workflows within the module university-office setting. Only Project 29 consultation automation is implemented. Volumes are assumptions for choosing a pattern, not measured workload results. The instructor or authorized office owner decides acceptance. Controlled data, one operator and no production integrations constrain the build.'),
('Consultation reminders','Assume 100 consultations per day and up to one minute of scan latency. Select scheduled database scans with durable outbox delivery over browser timers. The chosen pattern survives client closure and retains due records during scheduler outages; it costs repeated reads and requires clock and scheduler checks. A unique meeting reminder key prevents duplicate output. An unavailable scheduler delays notification, so the operator must inspect pending age and run a recovery tick.'),
('Urgent request acknowledgment','Assume 500 service requests per day and a seconds-level acknowledgment goal during staffed hours. Select transactional enqueue followed by queue execution over a nightly batch. A queue decouples response latency and supports back-pressure, but duplicate delivery and poison input still require idempotency and a human exception owner. A broker adds credential management and worker staffing. This is comparative design, not an implemented or benchmarked second application.'),
('Daily pending office summary','Assume one summary per office per day with a known cutoff and modest volume. Select a date-keyed scheduled snapshot over a webhook for every record change. The schedule matches the reporting boundary and requires fewer events; it can be late if the scheduler stops. Webhooks provide freshness but require authenticated callbacks, replay control and ordering logic. The office operator checks for a missing date-keyed summary. Prior-day catch-up requires an explicit retention and backfill policy.'),
('Matrix and verification','docs/decisions.md compares schedules, queues, webhooks, polling, change-data events and the selected hybrid across latency, reliability, security and staffing. diagrams/workflow.svg and screenflow.svg show the implemented workflow. Reproduce the consultation behavior with php artisan test and consultations:tick. The safe adverse cases include duplicate requests, invalid input, wrong roles and dependency failure. Configuration changes are confined to the implemented Project 29 service and example environment.'),
]),
('Activity One Interpretation',[
('Observed facts','The consultation implementation creates durable due events, enforces server roles and processes a bounded batch. Repeated scan and worker tests assert no duplicate receipt. Controlled execution records show transient recovery and retained manual-review states. Other office examples have no execution evidence and are not presented as working software. Test logs and source must be inspected alongside the diagrams; diagrams describe structure rather than prove execution.'),
('Reasoned conclusions','A hybrid of immediate human state updates and scheduled due scans is a reasonable local choice where minutes of latency are acceptable and MariaDB is already required. The relational outbox reduces service count and provides persistent checkpoints. A low-latency acknowledgment workflow would justify queue operations that reminders alone do not. A daily summary needs a reporting cutoff more than it needs an event for every field change. These conclusions depend on assumed volume and staffing.'),
('Consequences and recommendations','The selected local design introduces database reads, lock contention and scheduler ownership. Its maintainability benefit is explicit services, versioned dependencies and reproducible tests; it does not eliminate operations. Compare ordinary and peak workloads before claiming capacity. Add an independently monitored oldest-pending alert and define multi-day summary backfill before institutional use. A real notification provider needs bounded network timeouts and provider-side idempotency. Keep human approval for exceptional cases and restrict the prototype to fictional data until authorized.'),
('Self check and limitation','Another learner can rebuild the tested services from the setup instructions, but must supply private configuration and a running XAMPP database. Real source and running-application screenshots are indexed, and the student confirmed the reflection and project registration on 8 November 2026. Manual keyboard and browser-console inspection was not independently recorded, so automated widget checks and the visible responsive layouts must not be overstated. No option is declared production ready. A reviewer should use the requirement checklist and evidence index to distinguish tested consultation behavior from the comparative scenarios.'),
])],
'activity-2-failure-injection':[
('Controlled Automation Failure Injection',[
('Task and predicted safe behavior','Activity 2 tests duplicate processing, endless retries and silent data loss. Before execution, scenarios.md predicts one receipt for successful work, one recovered receipt after a transient retry, immediate manual review for permanent failure, and manual review after exactly three persistent-timeout attempts. Invalid and unauthorized requests must not mutate workflow state. A simulated process crash after receipt insertion must roll back receipt and attempt together, leaving the event available for recovery.'),
('Method and controlled changes','Local-only week13:evidence adds four fictional progress-summary events with success, transient, permanent and timeout injection modes. Injection is not exposed through a public API. It uses the configured retry clock and waits in real time, without resetting attempts or changing the host clock. PHPUnit separately uses controlled test-clock advancement to verify due rules and early retry suppression. Expected and actual results, source build label, real capture timestamps and correlations remain in JSON/JUnit evidence.'),
('Observed real time result',f'The run {run["run"]} completed in {run["elapsed_seconds"]} seconds. Success: delivered, 1 attempt. Transient: delivered, 2 attempts. Permanent: manual_review, 1 attempt. Persistent timeout: manual_review, 3 attempts. There were seven attempts, two receipts, two manual-review records and zero pending events. No real email/SMS was sent. The final capture was {run["captured_at_manila"]}.'),
('Prevention controls and alternatives','Unique request/event keys and one receipt per outbox ID prevent duplicate simulated processing. Status and available-at checkpoints prevent premature retry; a three-attempt ceiling prevents endless retry; retained manual-review rows prevent failures from disappearing. A transactional receiver gives a stronger local recovery guarantee than an in-memory send-then-log callback. A real external receiver would need provider deduplication or reconciliation because an SQL rollback cannot undo an external message.'),
('Improvement and rerun','An initial backend fixture failed because clock travel expired its session, correctly producing 401. The fixture now renews only controlled session expiry after changing test time. The failed-case rerun and regression suite passed; no access rule was removed. Initial Flutter analysis/test failures were also retained and corrected. Stale reminders are superseded after cancellation, and a crash test confirms a retained pending event can produce exactly one receipt on rerun. Consult final logs for the latest suite counts.'),
]),
('Activity Two Interpretation',[
('Observed facts','The real-time timeline shows a transient event waiting before its second attempt and then reaching delivered. Permanent and exhausted events remain visible as manual_review. The API tests reject student attempts to close a manual-review item and allow the coordinator to record a handling decision without sending again. A separate transaction test deliberately throws after inserting a simulated receipt; the receipt and attempt roll back, and a clean rerun succeeds. Duplicate scan/worker assertions retain one event and receipt.'),
('Reasoned conclusions','The combination of durable checkpoints, uniqueness constraints, row locking and transaction boundaries supports safe retry for this controlled receiver. Bounded backoff and an explicit manual owner make failure actionable. This evidence is stronger than a single success screenshot, but remains limited to small fixtures on one host. It does not prove external delivery, production concurrency, unlimited outage recovery or a complete distributed circuit breaker.'),
('Recommendations and operational authority','The coordinator should review every manual-review row, reconcile the fictional recipient and record a follow-up decision. Operators should not delete failures or reset attempts to make a demo appear green. Before a real provider is introduced, test provider-side idempotency, network timeout and ambiguous-response reconciliation. Measure pending age and alert through a channel independent of the failed transport. Evaluate scanner memory and throughput on bounded ordinary and peak workloads in the later authorized milestone.'),
('Evidence and remaining work','Use logs/controlled-delivery.json, tests/phpunit-results.xml, backend-tests.txt and the source manifest. Run php artisan week13:evidence to repeat a real-time test; run php artisan test for regression and crash checks. These records contain fictional identifiers and no credentials. Real source and running Flutter screenshots are indexed with actual capture times and hashes. The student confirmed the reflection and project registration on 8 November 2026. The actual oral assessment, marks and any instructor-prescribed acknowledgment wording remain external actions.'),
])],
'reflection-preparation':[
('Week Thirteen Reflection',[
('Purpose and review confirmation','This reflection answers the Week 13 prompts using verified project evidence. On 8 November 2026, I reviewed it and confirmed that it reflects my understanding. It does not claim an oral-defense result, an instructor mark, or production readiness.'),
('Decision with greatest effect','Based on the evidence, I would identify the durable relational outbox as the decision with the greatest effect on reliability. A consultation reminder or deadline is stored before delivery, so closing the Flutter client or temporarily stopping the scheduler does not erase the work. Unique event keys, row locking, one receipt per outbox record, and an attempt ceiling also reduce duplicate processing and endless retries. The controlled-delivery record confirmed this choice: one transient failure recovered on attempt two, while permanent and exhausted failures remained visible for manual review instead of disappearing.'),
('Most informative failure','The most informative failure in the record occurred when a test moved the clock to 2030. The fixture expected the automation request to continue, but the session created in 2026 had correctly expired and the API returned 401. The test was repaired by renewing only the controlled test session after changing the clock; the production expiry rule was not weakened. This case shows that time-based tests must control both the business clock and authentication lifetime. A better test design would create the session after setting the simulated time and would assert the intended expiry boundary separately.'),
]),
('Reflection Review and Next Steps',[
('Independent understanding to demonstrate','The most useful part to demonstrate independently is the request-to-follow-up path and the automation worker that processes its events. The relevant source is ConsultationController.php, Automation.php, and SimulatedTransport.php, supported by WorkflowTest.php. During review, I should be able to explain how server validation and role checks protect a request, how an idempotency key prevents duplicate consultation creation, and how an outbox event moves through pending, delivered, or manual review. I should rerun one focused test and one complete suite before claiming that I can modify this path independently.'),
('Next maintainer verification','Before broader use, an authorized maintainer should verify HTTPS, a real notification provider, provider-side idempotency, ambiguous timeout reconciliation, retention rules, and ordinary and peak workloads. These items remain outside Week 13 evidence because the current transport writes controlled database receipts, the application runs on loopback HTTP, and the tests use small local fixtures. An independent alert for an old pending event or a growing manual-review queue is also needed because the failed notification channel cannot be the only warning mechanism.'),
('Acknowledgment and remaining external actions','AI assisted the implementation, tests, diagrams, and reflection with my permission. I reviewed the reflection and confirmed that it reflects my understanding on 8 November 2026. Project registration is approved. Real source and running Flutter screenshots were captured with fictional data and indexed using their actual times. Any instructor-prescribed acknowledgment wording and the actual oral assessment remain external actions. The historical deadline was 30 October 2026; the evidence uses its real execution date of 8 November 2026.'),
])],
}

bundled_soffice=Path('C:/Program Files/LibreOffice/program/soffice.exe')
soffice=str(bundled_soffice if bundled_soffice.is_file() else (shutil.which('soffice') or ''))
if not Path(soffice).is_file():
    raise RuntimeError('LibreOffice soffice is required to create matching PDF soft copies.')
for name,pages in reports.items():
    doc=Document();section=doc.sections[0];section.top_margin=section.bottom_margin=Inches(.7);section.left_margin=section.right_margin=Inches(.75)
    normal=doc.styles['Normal'];normal.font.name='Calibri';normal.font.size=Pt(10.5);normal.paragraph_format.space_after=Pt(7)
    for style in ['Title','Heading 1','Heading 2']:
        doc.styles[style].font.color.rgb=RGBColor(0,0,0)
    title_style=doc.styles['Title']
    title_style.paragraph_format.space_after=Pt(18)
    title_style.paragraph_format.keep_with_next=True
    title_ppr=title_style.element.get_or_add_pPr()
    title_border=title_ppr.find(qn('w:pBdr'))
    if title_border is not None:
        title_ppr.remove(title_border)
    for style_name in ['Heading 1','Heading 2']:
        heading_style=doc.styles[style_name]
        heading_style.paragraph_format.space_before=Pt(12)
        heading_style.paragraph_format.space_after=Pt(5)
        heading_style.paragraph_format.keep_with_next=True
    doc.core_properties.author='Laurence Matthew B Manuel';doc.core_properties.title=pages[0][0]
    md=[]
    for i,(title,sections) in enumerate(pages):
        if i: doc.add_page_break()
        title_paragraph=doc.add_paragraph(title,'Title' if i==0 else 'Heading 1')
        title_paragraph.paragraph_format.space_after=Pt(18)
        doc.add_paragraph(identity);doc.add_paragraph(date)
        md += ['# '+title,'',identity,'',date,'']
        for heading,text in sections:
            heading_paragraph=doc.add_paragraph(heading,'Heading 2')
            heading_paragraph.paragraph_format.space_before=Pt(16 if name=='reflection-preparation' else 12)
            heading_paragraph.paragraph_format.space_after=Pt(6 if name=='reflection-preparation' else 5)
            heading_paragraph.paragraph_format.keep_with_next=True
            doc.add_paragraph(text)
            md += ['## '+heading,'',text,'']
    docx_path=out/f'{name}.docx'
    doc.save(docx_path)
    with tempfile.TemporaryDirectory(prefix='week13_pdf_') as temp_dir:
        profile_dir=Path(temp_dir)/'profile'
        output_dir=Path(temp_dir)/'output'
        profile_dir.mkdir()
        output_dir.mkdir()
        subprocess.run([
            soffice,f'-env:UserInstallation={profile_dir.as_uri()}',
            '--invisible','--headless','--norestore','--convert-to','pdf',
            '--outdir',str(output_dir),str(docx_path)
        ],check=True,capture_output=True,text=True)
        shutil.copyfile(output_dir/f'{name}.pdf',out/f'{name}.pdf')
    (out/f'{name}.md').write_text('\n'.join(md),encoding='utf-8')
print('Created four report DOCX files and four matching LibreOffice-converted PDFs. Run visual QA after regeneration.')

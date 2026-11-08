# Week Thirteen Reflection Draft

Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29

Prepared 8 November 2026 | Asia/Manila | Week 13 SA7

## Purpose and review requirement

This draft answers the Week 13 reflection prompts using verified project evidence. It does not claim instructor approval, an oral defense, or work that has not been reproduced by the student. Before submission, each answer must be read carefully, checked against the cited evidence, and revised if the student cannot explain it in their own words.

## Decision with greatest effect

Based on the evidence, I would identify the durable relational outbox as the decision with the greatest effect on reliability. A consultation reminder or deadline is stored before delivery, so closing the Flutter client or temporarily stopping the scheduler does not erase the work. Unique event keys, row locking, one receipt per outbox record, and an attempt ceiling also reduce duplicate processing and endless retries. The controlled-delivery record confirmed this choice: one transient failure recovered on attempt two, while permanent and exhausted failures remained visible for manual review instead of disappearing.

## Most informative failure

The most informative failure in the record occurred when a test moved the clock to 2030. The fixture expected the automation request to continue, but the session created in 2026 had correctly expired and the API returned 401. The test was repaired by renewing only the controlled test session after changing the clock; the production expiry rule was not weakened. This case shows that time-based tests must control both the business clock and authentication lifetime. A better test design would create the session after setting the simulated time and would assert the intended expiry boundary separately.

# Reflection Review and Next Steps

Laurence Matthew B Manuel | BSIT 3A | PFEBSIT 002 | Project 29

Prepared 8 November 2026 | Asia/Manila | Week 13 SA7

## Independent understanding to demonstrate

The most useful part to demonstrate independently is the request-to-follow-up path and the automation worker that processes its events. The relevant source is ConsultationController.php, Automation.php, and SimulatedTransport.php, supported by WorkflowTest.php. During review, I should be able to explain how server validation and role checks protect a request, how an idempotency key prevents duplicate consultation creation, and how an outbox event moves through pending, delivered, or manual review. I should rerun one focused test and one complete suite before claiming that I can modify this path independently.

## Next maintainer verification

Before broader use, an authorized maintainer should verify HTTPS, a real notification provider, provider-side idempotency, ambiguous timeout reconciliation, retention rules, and ordinary and peak workloads. These items remain outside Week 13 evidence because the current transport writes controlled database receipts, the application runs on loopback HTTP, and the tests use small local fixtures. An independent alert for an old pending event or a growing manual-review queue is also needed because the failed notification channel cannot be the only warning mechanism.

## Acknowledgment and pending actions

AI assisted the implementation, tests, diagrams, and this draft with the user permission recorded for the project. I remain responsible for reviewing the evidence, understanding the source, and explaining the final reflection. DOCX and PDF visual verification completed on 8 November 2026. Project registration, any instructor-prescribed acknowledgment wording, browser screenshots, and the actual oral assessment remain pending. The historical deadline was 30 October 2026; the evidence uses its real execution date of 8 November 2026.

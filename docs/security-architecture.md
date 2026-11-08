# Week 14 Security Architecture

## Decision question and boundary

How can the existing Project 29 application exchange a minimized consultation record so that only the assigned adviser can accept it, changes are detected, replays are blocked, keys remain outside the Flutter client and source control, and a reviewer can reproduce the evidence in the controlled local environment?

The controlled boundary contains a Flutter Web public client, a trusted localhost TLS gateway, a Laravel API, XAMPP MariaDB, an ignored server keyring, and allowlisted application logs. The workflow remains consultation request, schedule confirmation, agenda, meeting status, action items, and follow-up. It does not add document management, grading, plagiarism detection, messaging providers, production hosting, or production key management.

## Actors and permissions

- Student: signs in, sees only owned consultations, creates requests, completes owned action items, and cannot create or receive secure envelopes.
- Adviser: signs in, sees assigned consultations, manages valid meeting transitions and action items, and may receive only an authenticated envelope addressed to that adviser for an assigned consultation.
- Panel member: signs in and sees assigned consultation state but cannot create or receive secure envelopes.
- Coordinator: signs in, sees the bounded workflow, handles automation failures, and creates a short-lived adviser envelope. The coordinator cannot receive an envelope addressed to an adviser.
- Local operator: provisions the ignored keyring and local CA, starts controlled services, rotates or revokes keys, and retains recovery evidence. This operational role is not an application account.

## End-to-end security flow

1. The browser validates the short-lived localhost certificate and loads Flutter over HTTPS.
2. Flutter sends credentials and later a bearer session only to `https://localhost:8443/api`. The opaque session is stored only in application memory and the server stores only its SHA-256 token hash with a two-hour expiry.
3. Laravel authorizes the coordinator and reads one assigned consultation. The secure payload contains only record type, consultation ID, agenda, schedule, status, and open-action count.
4. `SecureExchange` creates a UUID message ID, five-minute validity window, random 96-bit nonce, and authenticated metadata. PHP OpenSSL encrypts the JSON payload with AES-256-GCM and a 128-bit tag. The key comes from the ignored keyring; it never enters Flutter, logs, responses, screenshots, or tracked files.
5. The assigned adviser submits the envelope. Laravel validates its shape, validity window, sender, authentication tag, adviser identity, and consultation assignment.
6. A unique database constraint records the accepted message ID once. A repeated accepted envelope returns HTTP 409 without another receipt. Altered, expired, malformed, wrong-key, unavailable-key, and unauthorized paths return safe errors with a correlation reference and no plaintext.

TLS terminates at the controlled gateway and forwards to Laravel only over loopback. This is suitable for local evidence, not a production topology. A production deployment should terminate TLS at a maintained reverse proxy on the same host or private network and protect any proxy-to-application hop as required by its threat model.

## Acceptance criteria

| Case | Measurable result |
|---|---|
| Normal | Coordinator receives HTTP 201 envelope; assigned adviser receives HTTP 200 minimized record; exactly one receipt exists. |
| Invalid | Missing or malformed envelope fields return HTTP 422 with no receipt. |
| Altered | Changed ciphertext or authenticated metadata returns HTTP 422 with no plaintext and no receipt. |
| Replay | Second valid submission returns HTTP 409 and receipt count remains one. |
| Expired | An authentic envelope submitted after five minutes returns HTTP 422 before plaintext release. |
| Unauthorized | Student or panel cannot create an envelope; nonrecipient cannot receive one; HTTP 403. |
| Wrong key | Authentication fails safely; no plaintext or receipt. |
| Key unavailable | HTTP 503 generic response; after restoring the protected key, normal creation and receipt succeed. |
| Invalid certificate | A client lacking the controlled CA rejects the TLS connection. |

## Recovery

If the keyring is missing or unreadable, stop exchange processing, restore the protected backup, verify its active key ID, clear configuration cache if used, and rerun the missing-key and success tests. Never generate a replacement key and claim old ciphertext is recoverable. If a key is suspected compromised, rotate it, allow only the five-minute in-flight window for the previous key, then remove the previous key and document affected message IDs. If the localhost CA is removed, re-import only the public CA certificate for the controlled session or regenerate the short-lived test material; never share the CA private key.

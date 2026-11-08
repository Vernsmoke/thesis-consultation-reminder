# Week 14 Control Rationale and Misuse Warnings

## Selected controls

- HTTPS protects browser-to-API confidentiality and authenticates the controlled endpoint. Payload encryption does not replace certificate validation, and TLS does not protect data after an authorized endpoint decrypts it.
- AES-256-GCM was selected because PHP 8.2 OpenSSL is installed and provides authenticated encryption. It detects changes to ciphertext and authenticated metadata while keeping one symmetric key operationally manageable for the bounded sender/receiver exercise.
- A fresh random 96-bit nonce is created for every envelope. Nonces are not secrets, but reuse with the same GCM key can destroy confidentiality and integrity.
- UUID message IDs, authenticated timestamps, a five-minute lifetime, and a unique receipt constraint jointly limit replay. Encryption by itself does not prevent replay.
- Server-side session, role, recipient, ownership, and transition checks remain authoritative. An authenticated envelope does not grant application permission.
- Passwords use Laravel's adaptive password hashing. Passwords are not encrypted for later recovery and are never stored with a fast general-purpose hash.
- Logs use explicit allowlists and correlation IDs. Troubleshooting value does not justify logging passwords, bearer tokens, keys, ciphertext, complete agendas, or validation bodies.

## Misuse warnings

1. Never reuse a nonce with the same AES-GCM key or replace `random_bytes` with timestamps, counters without durable coordination, or predictable values.
2. Never decrypt before tag verification, ignore a failed `openssl_decrypt`, shorten the tag, or treat base64 as encryption.
3. Never accept an envelope merely because it decrypts. Recheck expiry, recipient, application role, consultation assignment, and the unique replay receipt.
4. Never embed the key in Flutter, JavaScript, source control, a CI log, a screenshot, a test result, or the example environment file.
5. Never use one symmetric key indefinitely. Rotate on schedule or suspected exposure, preserve the previous key only for the bounded in-flight window, then revoke it.
6. Never disable certificate validation or click through a browser certificate warning for evidence. The controlled CA must be trusted explicitly.
7. Never use reversible encryption for passwords or a raw SHA family hash as password storage. Use an adaptive password hash through the framework.
8. Never describe AES-GCM as providing nonrepudiation. Sender and receiver share the secret, so either can produce a valid message.
9. Never claim production readiness from localhost TLS and test fixtures. Public deployment, centralized secrets, monitoring, backup protection, certificate automation, and operational review remain outside Week 14 evidence.

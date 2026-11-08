# Cryptographic Decision Record

## Context

The Week 14 exercise requires a small authenticated sender/receiver integration for a minimized consultation record, with keys outside the public client and source, rejection of altered and replayed messages, protected transport, and repeatable adverse tests. PHP 8.2.12 includes OpenSSL but the Sodium extension is not installed.

## Decision

Use PHP OpenSSL AES-256-GCM with a 32-byte random key, 12-byte random nonce, 16-byte authentication tag, and canonical JSON additional authenticated data. Authenticate version, key ID, UUID message ID, issue time, expiry time, sender, and recipient user ID. Keep a five-minute lifetime and 30-second future clock skew. Store one accepted message ID in MariaDB under a unique constraint. Load the active and immediately previous key from an ignored JSON keyring. Use TLS 1.2 or later for browser transport.

## Alternatives

| Alternative | Advantages | Disadvantages and decision |
|---|---|---|
| OpenSSL AES-256-GCM | Installed, standards-based AEAD, efficient, testable, no new package | Selected. Requires strict nonce discipline, shared-key distribution, and careful rotation. It does not provide nonrepudiation. |
| Sodium XChaCha20-Poly1305 | Large nonce space, misuse-resistant nonce generation ergonomics, modern API | Preferred if Sodium were installed, but unavailable in the verified PHP runtime. Adding an extension would expand environment setup and course risk. |
| Asymmetric hybrid encryption and signatures | Separate encryption/decryption authority, public verification, easier multi-receiver trust separation | Rejected for the bounded local exercise. Certificate/public-key lifecycle and signature governance add complexity not justified by one server-owned sender/receiver path. |
| TLS only | Simple and essential for data in transit | Rejected as the complete answer because the module explicitly requires an authenticated-encryption payload exercise and replay/tamper evidence. TLS remains mandatory in addition to the envelope. |

## Consequences

The implementation is individually explainable and uses only installed framework/runtime facilities. The server owns secret storage, encryption, decryption, validation, authorization, replay receipts, and audit outcomes; Flutter carries ciphertext and safe results only. Operators must back up, rotate, and revoke the keyring, protect the TLS CA private key, keep clocks accurate, and remove the local CA when the exercise ends. Compromise of the shared AES key allows forged envelopes until revocation, and the design does not prove which of two shared-key holders created a message.

## Evidence and review condition

Twenty-one Laravel tests with 199 assertions, five live HTTPS API cases, TLS validation, browser sender/receiver evidence, and source/configuration scans support this decision for the controlled Week 14 environment. Review the decision if Sodium becomes part of the approved runtime, multiple independent systems require separate keys, nonrepudiation becomes a real requirement, or the application moves beyond localhost.

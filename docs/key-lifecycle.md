# Week 14 Key Lifecycle Plan

## Generation and storage

Run `php artisan secure-exchange:key` once from `backend`. The command generates 256 random bits and writes only the base64 representation to `storage/app/private/secure-exchange-keyring.json`. The directory is ignored by Git. The command never prints the key. The local TLS script creates a separate short-lived CA and server key under `storage/app/private/tls`; encryption and TLS keys are never reused for each other.

## Use and access

Only the Laravel process and local operator account need read access. Flutter, the database, test results, logs, screenshots, source, and `.env.example` must not contain key material. The envelope exposes only a nonsecret key identifier. The keyring may hold the active key and one previous key so an envelope created immediately before rotation can finish within its five-minute lifetime.

## Rotation

1. Back up the current protected keyring to an access-controlled location outside the repository.
2. Run `php artisan secure-exchange:key --rotate`.
3. Run the success, wrong-key, tamper, replay, and missing-key recovery tests.
4. Allow no more than the five-minute envelope lifetime for the previous key.
5. Remove the previous key from the protected keyring, record its key ID and removal time without recording its value, and rerun success and old-envelope rejection tests.

## Compromise and revocation

Stop envelope creation and receipt, preserve audit metadata, rotate immediately, remove the suspected key rather than retaining it for the normal grace window, expire active sessions if the incident includes server compromise, and identify message IDs created or accepted during the exposure window. Notify only the authorized maintainer/instructor according to institutional procedure. Do not attempt to conceal the incident by deleting evidence.

## Backup, loss, and destruction

Back up the protected keyring separately from the repository and application database. Verify restoration in a controlled copy. If all copies are lost, old envelopes cannot be recovered; generate a new key, reject old envelopes, and document the loss. Destroy retired test keys and the CA private key when evidence review is complete and no recovery requirement remains. Remove the public local CA from the current-user trust store if it is no longer needed.

## Ownership and review

The local operator performs provisioning and rotation; the coordinator owns application decisions but does not see key material. A future production deployment requires an approved secret manager or operating-system protected store, access review, automatic certificate renewal, centralized monitoring, and a formally assigned incident owner.

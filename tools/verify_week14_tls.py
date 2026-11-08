"""Verify valid local CA trust and rejection when the trust anchor is absent."""

from __future__ import annotations

import argparse
import json
import socket
import ssl
from datetime import datetime, timezone
from pathlib import Path


def connect(context: ssl.SSLContext, host: str, port: int) -> dict[str, object]:
    with socket.create_connection((host, port), timeout=5) as raw:
        with context.wrap_socket(raw, server_hostname=host) as tls:
            certificate = tls.getpeercert()
            return {
                "protocol": tls.version(),
                "cipher": tls.cipher()[0],
                "subject": certificate.get("subject"),
                "issuer": certificate.get("issuer"),
                "not_after": certificate.get("notAfter"),
            }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ca", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=8443)
    args = parser.parse_args()
    valid = connect(ssl.create_default_context(cafile=str(args.ca)), args.host, args.port)
    untrusted = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    untrusted.check_hostname = True
    untrusted.verify_mode = ssl.CERT_REQUIRED
    rejected = False
    error = None
    try:
        connect(untrusted, args.host, args.port)
    except ssl.SSLCertVerificationError as exception:
        rejected = True
        error = exception.verify_message
    result = {
        "executed_at": datetime.now(timezone.utc).astimezone().isoformat(),
        "trusted_ca_connection": valid,
        "missing_trust_anchor_rejected": rejected,
        "rejection_reason": error,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    if not rejected:
        raise SystemExit("Expected a client without the controlled CA to reject the server certificate.")
    print(f"PASS: {valid['protocol']} with {valid['cipher']}; missing trust anchor rejected.")


if __name__ == "__main__":
    main()

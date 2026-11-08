"""Provision a short-lived localhost CA and server certificate for controlled Week 14 evidence."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import ipaddress
from pathlib import Path

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import ExtendedKeyUsageOID, NameOID


def private_bytes(key: rsa.RSAPrivateKey) -> bytes:
    return key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption(),
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--rotate", action="store_true")
    args = parser.parse_args()
    out = args.output.resolve()
    server_certificate = out / "localhost.crt"
    if server_certificate.exists() and not args.rotate:
        print("TLS material already exists; no key material was changed.")
        return
    out.mkdir(parents=True, exist_ok=True)
    now = dt.datetime.now(dt.UTC)
    not_before = now - dt.timedelta(minutes=5)
    not_after = now + dt.timedelta(days=7)

    ca_key = rsa.generate_private_key(public_exponent=65537, key_size=3072)
    ca_name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "Week 14 Local Test CA")])
    ca_cert = (
        x509.CertificateBuilder()
        .subject_name(ca_name)
        .issuer_name(ca_name)
        .public_key(ca_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(not_before)
        .not_valid_after(not_after)
        .add_extension(x509.BasicConstraints(ca=True, path_length=0), critical=True)
        .add_extension(
            x509.KeyUsage(
                digital_signature=True,
                key_encipherment=False,
                content_commitment=False,
                data_encipherment=False,
                key_agreement=False,
                key_cert_sign=True,
                crl_sign=True,
                encipher_only=False,
                decipher_only=False,
            ),
            critical=True,
        )
        .sign(ca_key, hashes.SHA256())
    )

    server_key = rsa.generate_private_key(public_exponent=65537, key_size=3072)
    server_name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "localhost")])
    server_cert = (
        x509.CertificateBuilder()
        .subject_name(server_name)
        .issuer_name(ca_name)
        .public_key(server_key.public_key())
        .serial_number(x509.random_serial_number())
        .not_valid_before(not_before)
        .not_valid_after(not_after)
        .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=True)
        .add_extension(
            x509.SubjectAlternativeName(
                [x509.DNSName("localhost"), x509.IPAddress(ipaddress.ip_address("127.0.0.1"))]
            ),
            critical=False,
        )
        .add_extension(x509.ExtendedKeyUsage([ExtendedKeyUsageOID.SERVER_AUTH]), critical=False)
        .sign(ca_key, hashes.SHA256())
    )

    files = {
        "ca.key": private_bytes(ca_key),
        "ca.crt": ca_cert.public_bytes(serialization.Encoding.PEM),
        "localhost.key": private_bytes(server_key),
        "localhost.crt": server_cert.public_bytes(serialization.Encoding.PEM),
    }
    for name, data in files.items():
        path = out / name
        path.write_bytes(data)
        if name.endswith(".key"):
            try:
                path.chmod(0o600)
            except OSError:
                pass
    fingerprint = hashlib.sha256(files["ca.crt"]).hexdigest().upper()
    print(f"Provisioned short-lived localhost TLS material through {not_after.isoformat()}.")
    print(f"CA certificate SHA-256: {fingerprint}")
    print("Private keys were written only to the ignored protected storage directory.")


if __name__ == "__main__":
    main()

"""Serve the Flutter build or proxy the Laravel API over controlled local HTTPS."""

from __future__ import annotations

import argparse
import http.server
import ssl
import urllib.error
import urllib.request
from pathlib import Path


SAFE_REQUEST_HEADERS = {
    "accept",
    "access-control-request-headers",
    "access-control-request-method",
    "authorization",
    "content-type",
    "idempotency-key",
    "origin",
}
SAFE_RESPONSE_HEADERS = {
    "cache-control",
    "content-type",
    "access-control-allow-origin",
    "access-control-allow-methods",
    "access-control-allow-headers",
    "access-control-expose-headers",
    "x-correlation-id",
    "x-content-type-options",
    "referrer-policy",
    "content-security-policy",
    "permissions-policy",
    "strict-transport-security",
}


class ProxyHandler(http.server.BaseHTTPRequestHandler):
    target = "http://127.0.0.1:8000"
    protocol_version = "HTTP/1.1"

    def do_GET(self) -> None:
        self.proxy()

    def do_POST(self) -> None:
        self.proxy()

    def do_PATCH(self) -> None:
        self.proxy()

    def do_OPTIONS(self) -> None:
        self.proxy()

    def proxy(self) -> None:
        length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(length) if length else None
        headers = {key: value for key, value in self.headers.items() if key.lower() in SAFE_REQUEST_HEADERS}
        request = urllib.request.Request(
            self.target + self.path,
            data=body,
            headers=headers,
            method=self.command,
        )
        try:
            response = urllib.request.urlopen(request, timeout=15)
        except urllib.error.HTTPError as error:
            response = error
        except (urllib.error.URLError, TimeoutError):
            payload = b'{"message":"TLS gateway could not reach the API."}'
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
            return
        payload = response.read()
        self.send_response(response.status)
        for key, value in response.headers.items():
            if key.lower() in SAFE_RESPONSE_HEADERS:
                self.send_header(key, value)
        if "Strict-Transport-Security" not in response.headers:
            self.send_header("Strict-Transport-Security", "max-age=31536000")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format: str, *args: object) -> None:
        print(f"TLS API {self.address_string()} {format % args}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--cert", type=Path, required=True)
    parser.add_argument("--key", type=Path, required=True)
    parser.add_argument("--proxy")
    parser.add_argument("--directory", type=Path)
    args = parser.parse_args()
    if bool(args.proxy) == bool(args.directory):
        parser.error("choose exactly one of --proxy or --directory")
    if args.proxy:
        ProxyHandler.target = args.proxy.rstrip("/")
        handler = ProxyHandler
    else:
        directory = str(args.directory.resolve())
        handler = lambda *items, **options: http.server.SimpleHTTPRequestHandler(  # noqa: E731
            *items, directory=directory, **options
        )
    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.minimum_version = ssl.TLSVersion.TLSv1_2
    context.load_cert_chain(args.cert, args.key)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    print(f"Serving controlled HTTPS on https://localhost:{args.port}")
    server.serve_forever()


if __name__ == "__main__":
    main()

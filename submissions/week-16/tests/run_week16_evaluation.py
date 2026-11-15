"""Reproducible Week 16 local performance and dependency-failure evaluation."""

from __future__ import annotations

import argparse
import concurrent.futures
import csv
import ctypes
import ctypes.wintypes
import http.client
import json
import math
import os
import ssl
import statistics
import subprocess
import threading
import time
import urllib.error
import urllib.request
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo


MANILA = ZoneInfo("Asia/Manila")


@dataclass
class Result:
    workload: str
    sequence: int
    path: str
    expected_status: int
    actual_status: int
    latency_ms: float
    passed: bool
    error: str
    captured_at: str


def now() -> str:
    return datetime.now(MANILA).isoformat()


def percentile(values: list[float], fraction: float) -> float:
    ordered = sorted(values)
    if not ordered:
        return 0.0
    position = (len(ordered) - 1) * fraction
    lower = math.floor(position)
    upper = math.ceil(position)
    if lower == upper:
        return ordered[lower]
    return ordered[lower] + (ordered[upper] - ordered[lower]) * (position - lower)


def private_value(path: Path, name: str) -> str:
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith(name + "="):
            return line.split("=", 1)[1].strip().strip("\"'")
    raise RuntimeError(f"{name} is not configured in the private environment")


def sign_in(base_url: str, context: ssl.SSLContext, password: str) -> str:
    data = json.dumps({"email": "student@example.test", "password": password}).encode()
    request = urllib.request.Request(
        base_url + "/api/login",
        data=data,
        headers={"Content-Type": "application/json", "Accept": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, context=context, timeout=15) as response:
        return json.load(response)["token"]


def call_once(
    workload: str,
    sequence: int,
    host: str,
    port: int,
    context: ssl.SSLContext,
    token: str,
) -> Result:
    selector = sequence % 20
    if selector < 14:
        path, expected, headers = (
            "/api/consultations?per_page=10",
            200,
            {"Authorization": f"Bearer {token}", "Accept": "application/json"},
        )
    elif selector < 17:
        path, expected, headers = "/up", 200, {"Accept": "text/html"}
    else:
        path, expected, headers = "/ready", 200, {"Accept": "application/json"}

    started = time.perf_counter()
    status = 0
    error = ""
    connection = http.client.HTTPSConnection(host, port, context=context, timeout=15)
    try:
        connection.request("GET", path, headers=headers)
        response = connection.getresponse()
        status = response.status
        response.read()
    except Exception as exception:  # evidence records the bounded client error class only
        error = type(exception).__name__
    finally:
        connection.close()
    elapsed = (time.perf_counter() - started) * 1000
    return Result(
        workload,
        sequence,
        path,
        expected,
        status,
        round(elapsed, 3),
        status == expected,
        error,
        now(),
    )


def run_workload(
    name: str,
    requests: int,
    concurrency: int,
    host: str,
    port: int,
    context: ssl.SSLContext,
    token: str,
) -> tuple[list[Result], float]:
    started = time.perf_counter()
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as pool:
        futures = [
            pool.submit(call_once, name, sequence, host, port, context, token)
            for sequence in range(requests)
        ]
        results = [future.result() for future in concurrent.futures.as_completed(futures)]
    return sorted(results, key=lambda item: item.sequence), time.perf_counter() - started


class ProcessProbe:
    PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
    PROCESS_VM_READ = 0x0010

    def __init__(self, pid: int, label: str):
        self.pid = pid
        self.label = label
        self.handle = ctypes.windll.kernel32.OpenProcess(
            self.PROCESS_QUERY_LIMITED_INFORMATION | self.PROCESS_VM_READ, False, pid
        )

    def snapshot(self) -> dict[str, object] | None:
        if not self.handle:
            return None
        creation = ctypes.wintypes.FILETIME()
        exit_time = ctypes.wintypes.FILETIME()
        kernel = ctypes.wintypes.FILETIME()
        user = ctypes.wintypes.FILETIME()
        if not ctypes.windll.kernel32.GetProcessTimes(
            self.handle,
            ctypes.byref(creation),
            ctypes.byref(exit_time),
            ctypes.byref(kernel),
            ctypes.byref(user),
        ):
            return None

        class MemoryCounters(ctypes.Structure):
            _fields_ = [
                ("cb", ctypes.wintypes.DWORD),
                ("PageFaultCount", ctypes.wintypes.DWORD),
                ("PeakWorkingSetSize", ctypes.c_size_t),
                ("WorkingSetSize", ctypes.c_size_t),
                ("QuotaPeakPagedPoolUsage", ctypes.c_size_t),
                ("QuotaPagedPoolUsage", ctypes.c_size_t),
                ("QuotaPeakNonPagedPoolUsage", ctypes.c_size_t),
                ("QuotaNonPagedPoolUsage", ctypes.c_size_t),
                ("PagefileUsage", ctypes.c_size_t),
                ("PeakPagefileUsage", ctypes.c_size_t),
            ]

        memory = MemoryCounters()
        memory.cb = ctypes.sizeof(memory)
        ctypes.windll.psapi.GetProcessMemoryInfo(
            self.handle, ctypes.byref(memory), ctypes.sizeof(memory)
        )
        cpu_100ns = (
            (kernel.dwHighDateTime << 32)
            + kernel.dwLowDateTime
            + (user.dwHighDateTime << 32)
            + user.dwLowDateTime
        )
        return {
            "time": now(),
            "pid": self.pid,
            "process": self.label,
            "working_set_bytes": int(memory.WorkingSetSize),
            "cpu_seconds": round(cpu_100ns / 10_000_000, 6),
        }

    def close(self) -> None:
        if self.handle:
            ctypes.windll.kernel32.CloseHandle(self.handle)


def sample_processes(probes: list[ProcessProbe], stop: threading.Event, output: list[dict]) -> None:
    while not stop.is_set():
        for probe in probes:
            item = probe.snapshot()
            if item:
                output.append(item)
        stop.wait(1.0)


def http_status(url: str, timeout: float = 5) -> tuple[int, object]:
    try:
        with urllib.request.urlopen(url, timeout=timeout) as response:
            data = response.read().decode("utf-8", "replace")
            return response.status, json.loads(data) if data.startswith("{") else data[:80]
    except urllib.error.HTTPError as error:
        data = error.read().decode("utf-8", "replace")
        return error.code, json.loads(data) if data.startswith("{") else data[:80]


def dependency_failure(root: Path, php: str) -> dict[str, object]:
    environment = os.environ.copy()
    environment["DB_PORT"] = "65530"
    environment["APP_ENV"] = "week16_failure_fixture"
    flags = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0
    process = subprocess.Popen(
        [php, "artisan", "serve", "--host=127.0.0.1", "--port=8001"],
        cwd=root / "backend",
        env=environment,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=flags,
    )
    record: dict[str, object] = {
        "predicted": {
            "liveness": 200,
            "readiness": 503,
            "main_environment_after_fixture": 200,
        },
        "started_at": now(),
        "fixture": "isolated Laravel process with unreachable DB port 65530",
    }
    try:
        deadline = time.time() + 20
        while time.time() < deadline:
            try:
                status, _ = http_status("http://127.0.0.1:8001/up", 1)
                if status == 200:
                    break
            except Exception:
                time.sleep(0.25)
        live_status, live_body = http_status("http://127.0.0.1:8001/up")
        ready_status, ready_body = http_status("http://127.0.0.1:8001/ready")
        record["actual"] = {
            "liveness_status": live_status,
            "liveness_body_excerpt": str(live_body)[:80],
            "readiness_status": ready_status,
            "readiness_body": ready_body,
        }
        record["passed"] = live_status == 200 and ready_status == 503
    finally:
        process.terminate()
        try:
            process.wait(timeout=10)
        except subprocess.TimeoutExpired:
            process.kill()
        record["completed_at"] = now()
    return record


def summarize(name: str, results: list[Result], elapsed: float) -> dict[str, object]:
    latencies = [item.latency_ms for item in results]
    failures = [item for item in results if not item.passed]
    return {
        "name": name,
        "requests": len(results),
        "elapsed_seconds": round(elapsed, 3),
        "throughput_requests_per_second": round(len(results) / elapsed, 3),
        "errors": len(failures),
        "error_rate_percent": round(len(failures) * 100 / len(results), 3),
        "latency_ms": {
            "minimum": min(latencies),
            "mean": round(statistics.fmean(latencies), 3),
            "p50": round(percentile(latencies, 0.50), 3),
            "p95": round(percentile(latencies, 0.95), 3),
            "p99": round(percentile(latencies, 0.99), 3),
            "maximum": max(latencies),
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository-root", type=Path, required=True)
    parser.add_argument("--base-url", default="https://127.0.0.1:8443")
    parser.add_argument("--ca", type=Path, required=True)
    parser.add_argument("--php", default=r"C:\xampp\php\php.exe")
    parser.add_argument("--process", action="append", default=[], help="PID:label")
    args = parser.parse_args()

    root = args.repository_root.resolve()
    output = root / "submissions" / "week-16" / "tests"
    context = ssl.create_default_context(cafile=str(args.ca.resolve()))
    host_port = args.base_url.removeprefix("https://").split(":")
    host, port = host_port[0], int(host_port[1])
    password = private_value(root / "backend" / ".env", "DEMO_PASSWORD")
    token = sign_in(args.base_url, context, password)
    password = ""

    probes = []
    for value in args.process:
        pid, label = value.split(":", 1)
        probes.append(ProcessProbe(int(pid), label))
    samples: list[dict] = []
    stop = threading.Event()
    sampler = threading.Thread(target=sample_processes, args=(probes, stop, samples), daemon=True)
    sampler.start()
    started = now()
    try:
        run_workload("warmup", 20, 2, host, port, context, token)
        print("Running ordinary model: 60 requests at concurrency 2", flush=True)
        ordinary, ordinary_elapsed = run_workload(
            "ordinary", 60, 2, host, port, context, token
        )
        print("Running peak model: 240 requests at concurrency 12", flush=True)
        peak, peak_elapsed = run_workload("peak", 240, 12, host, port, context, token)
        print("Running isolated database-dependency failure fixture", flush=True)
    finally:
        stop.set()
        sampler.join(timeout=3)
        for probe in probes:
            probe.close()

    failure = dependency_failure(root, args.php)
    main_ready, main_ready_body = http_status("http://127.0.0.1:8000/ready")
    failure["main_environment_after_fixture"] = {
        "status": main_ready,
        "body": main_ready_body,
        "passed": main_ready == 200,
    }
    failure["passed"] = bool(failure["passed"] and main_ready == 200)

    all_results = ordinary + peak
    with (output / "performance-raw.csv").open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(asdict(all_results[0]).keys()))
        writer.writeheader()
        writer.writerows(asdict(item) for item in all_results)
    (output / "resource-samples.json").write_text(
        json.dumps(samples, indent=2), encoding="utf-8"
    )
    (output / "failure-recovery.json").write_text(
        json.dumps(failure, indent=2), encoding="utf-8"
    )

    summary = {
        "executed_at": started,
        "completed_at": now(),
        "timezone": "Asia/Manila",
        "source_state": "Week 16 uncommitted working tree based on v3.0.0 / 17e8860",
        "environment": "loopback HTTPS gateway, Laravel CLI server, XAMPP MariaDB, release Flutter build",
        "request_mix": {"authenticated_consultation_read_percent": 70, "liveness_percent": 15, "readiness_percent": 15},
        "ordinary": summarize("ordinary", ordinary, ordinary_elapsed),
        "peak": summarize("peak", peak, peak_elapsed),
        "dependency_failure_and_recovery_passed": failure["passed"],
        "limitations": [
            "Single-machine loopback measurements include a fresh TLS connection per request.",
            "The PHP CLI server and Python TLS gateway are evaluation tools, not a production topology.",
            "The short run does not establish endurance, multi-host capacity, or internet latency.",
        ],
    }
    (output / "performance-summary.json").write_text(
        json.dumps(summary, indent=2), encoding="utf-8"
    )
    print(json.dumps(summary, indent=2))
    if summary["ordinary"]["errors"] or summary["peak"]["errors"] or not failure["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()

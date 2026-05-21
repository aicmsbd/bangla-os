#!/usr/bin/env python3
"""Bangla OS ISO test: offline verify + optional GUI QEMU boot."""
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ISO = ROOT / "output" / "bangla-os-1.0-amd64-patched.iso"
VERIFY = ROOT / "scripts" / "host" / "verify-iso.sh"
GUI_BOOT = ROOT / "scripts" / "host" / "boot-qemu-test.ps1"


def wsl_path(p: Path) -> str:
    return p.as_posix().replace("C:", "/mnt/c").replace("\\", "/")


def run_offline_verify() -> int:
    if not ISO.is_file():
        print(f"Missing ISO: {ISO}", file=sys.stderr)
        return 1
    print(f"[live-test] Offline verify: {ISO.name}", flush=True)
    r = subprocess.run(
        ["wsl", "bash", wsl_path(VERIFY), wsl_path(ISO)],
        text=True,
    )
    if r.returncode != 0:
        print("[live-test] FAIL: offline verify", flush=True)
        return r.returncode
    print("[live-test] PASS: offline verify (boot files, branding, packages)", flush=True)
    return 0


def launch_gui_boot() -> int:
    if not GUI_BOOT.is_file():
        print(f"Missing script: {GUI_BOOT}", file=sys.stderr)
        return 1
    ram = os.environ.get("BANGLA_TEST_RAM_MB", "8192")
    cpu = os.environ.get("BANGLA_TEST_CPU", "4")
    print(f"[live-test] Launching GUI QEMU ({ram} MB, {cpu} vCPU)...", flush=True)
    print("[live-test] Login: live / evolution", flush=True)
    env = os.environ.copy()
    env["BANGLA_TEST_RAM_MB"] = ram
    env["BANGLA_TEST_CPU"] = cpu
    return subprocess.call(
        ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(GUI_BOOT)],
        env=env,
    )


def main() -> int:
    code = run_offline_verify()
    if code != 0:
        return code
    if os.environ.get("BANGLA_GUI_BOOT", "0") == "1":
        return launch_gui_boot()
    print(
        "[live-test] Headless serial boot is broken in QEMU (live initramfs panic). "
        "Use GUI boot for live desktop testing:\n"
        "  $env:BANGLA_GUI_BOOT='1'; python scripts/host/qemu-live-test.py\n"
        "  or: .\\scripts\\host\\boot-qemu-test.ps1",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

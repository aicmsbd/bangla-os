#!/usr/bin/env python3
"""Download latest ISO from build VM with progress."""
import os
import re
import sys
import paramiko

HOST, PORT, USER, PASS = "127.0.0.1", 2222, "banglaos", "banglaos"
OUT = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\Z\Desktop\Bangla OS\output\bangla-os-1.0-amd64.iso"


def sudo_out(c, shell_cmd: str) -> str:
    _, stdout, _ = c.exec_command(
        f"echo {PASS} | sudo -S sh -c {repr(shell_cmd)}",
        get_pty=True,
    )
    raw = stdout.read().decode(errors="replace")
    code = stdout.channel.recv_exit_status()
    if code != 0:
        raise SystemExit(f"remote failed ({code}): {shell_cmd}\n{raw}")
    for line in reversed(raw.splitlines()):
        line = line.strip()
        if line and "password for" not in line.lower() and not line.startswith("[sudo"):
            return line
    m = re.search(r"(/home/eggs/\S+\.iso)", raw)
    return m.group(1) if m else ""


def main():
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect(HOST, port=PORT, username=USER, password=PASS, timeout=30)

    iso = sudo_out(c, "ls -t /home/eggs/egg-of_*.iso 2>/dev/null | head -1")
    if not iso.startswith("/"):
        raise SystemExit(f"bad iso path: {iso!r}")
    print(f"[download] Remote: {iso}")

    sudo_out(c, f"cp '{iso}' /tmp/bangla-os.iso && chmod 644 /tmp/bangla-os.iso")

    sftp = c.open_sftp()
    size = sftp.stat("/tmp/bangla-os.iso").st_size
    print(f"[download] Size: {size // 1024 // 1024} MB")

    def cb(x, y):
        if y and x and x % (100 * 1024 * 1024) < 512 * 1024:
            print(f"[download] {x * 100 // y}%")

    sftp.get("/tmp/bangla-os.iso", OUT, callback=cb)
    sftp.close()
    c.close()
    print(f"[download] Saved: {OUT} ({os.path.getsize(OUT) // 1024 // 1024} MB)")


if __name__ == "__main__":
    main()

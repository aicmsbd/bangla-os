#!/usr/bin/env python3
"""SSH helper for QEMU build VM (password auth via paramiko)."""
import sys
import paramiko

HOST, PORT, USER, PASS = "127.0.0.1", 2222, "banglaos", "banglaos"


def connect():
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect(HOST, port=PORT, username=USER, password=PASS, timeout=15)
    return c


def run(cmd, sudo=False):
    c = connect()
    if sudo:
        cmd = f"echo {PASS} | sudo -S bash -c {repr(cmd)}"
    _, stdout, stderr = c.exec_command(cmd, get_pty=True)
    out = stdout.read().decode(errors="replace")
    err = stderr.read().decode(errors="replace")
    code = stdout.channel.recv_exit_status()
    c.close()
    if out:
        print(out, end="" if out.endswith("\n") else "\n")
    if err and code != 0:
        print(err, file=sys.stderr)
    return code


def upload(local, remote):
    c = connect()
    sftp = c.open_sftp()
    sftp.put(local, remote)
    sftp.close()
    c.close()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("usage: qemu-ssh.py run|sudo|upload ...")
    op = sys.argv[1]
    if op == "run":
        sys.exit(run(" ".join(sys.argv[2:])))
    if op == "sudo":
        sys.exit(run(" ".join(sys.argv[2:]), sudo=True))
    if op == "upload":
        sys.exit(0 if upload(sys.argv[2], sys.argv[3]) is None else 1)
    sys.exit(1)

"""Run make + test scripts on Mac over SSH (paramiko).

Credentials: set env vars or create scripts/snc_ssh.env (see snc_ssh.env.example).
"""
import os
import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from mac_ssh_common import default_remote_dir, load_snc_ssh_env

import paramiko

load_snc_ssh_env()

_USER = os.environ.get("SNC_SSH_USER", "asishsharma")
HOST = os.environ.get("SNC_SSH_HOST", "192.168.0.113")
USER = _USER
PASSWORD = os.environ.get("SNC_SSH_PASSWORD", "")
REMOTE_DIR = os.environ.get("SNC_SSH_REMOTE_DIR", default_remote_dir(_USER))


def main() -> int:
    if not PASSWORD:
        print("Set SNC_SSH_PASSWORD.", file=sys.stderr)
        return 2
    # Single-line bash to avoid CRLF / quoting issues from Windows.
    remote = (
        f'cd "{REMOTE_DIR}" && '
        "git pull 2>&1 || true && "
        "make clean && make && "
        "bash tests/compile_test.sh && "
        "bash tests/runtime_test.sh"
    )
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(
            hostname=HOST,
            username=USER,
            password=PASSWORD,
            timeout=30,
            allow_agent=False,
            look_for_keys=False,
        )
    except Exception as e:
        print("CONNECT_FAILED:", e, file=sys.stderr)
        return 1
    try:
        stdin, stdout, stderr = client.exec_command(
            "bash -lc " + repr(remote), timeout=300
        )
        out = stdout.read().decode("utf-8", errors="replace")
        err = stderr.read().decode("utf-8", errors="replace")
        sys.stdout.write(out)
        if err:
            sys.stderr.write(err)
        return stdout.channel.recv_exit_status()
    finally:
        client.close()


if __name__ == "__main__":
    raise SystemExit(main())

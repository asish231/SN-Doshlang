"""SFTP key source files to Mac, rebuild, run tests.

Credentials: env vars or scripts/snc_ssh.env (see snc_ssh.env.example).
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

ROOT = Path(__file__).resolve().parents[1]
_SN_USER = os.environ.get("SNC_SSH_USER", "asishsharma")
HOST = os.environ.get("SNC_SSH_HOST", "192.168.0.113")
USER = _SN_USER
PWD = os.environ.get("SNC_SSH_PASSWORD", "")
REMOTE = os.environ.get("SNC_SSH_REMOTE_DIR", default_remote_dir(_SN_USER))
FILES = ["src/parser.s", "src/data.s"]


def main() -> int:
    if not PWD:
        print(
            "Set SNC_SSH_PASSWORD or scripts/snc_ssh.env",
            file=sys.stderr,
        )
        return 2
    t = paramiko.Transport((HOST, 22))
    t.connect(username=USER, password=PWD)
    sftp = paramiko.SFTPClient.from_transport(t)
    for rel in FILES:
        local = ROOT / rel
        remote = f"{REMOTE}/{rel.replace(chr(92), '/')}"
        sftp.put(str(local), remote)
        print("put", rel)
    sftp.close()
    t.close()

    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect(
        HOST,
        username=USER,
        password=PWD,
        timeout=30,
        allow_agent=False,
        look_for_keys=False,
    )
    cmd = (
        f'cd "{REMOTE}" && make 2>&1 && bash tests/compile_test.sh 2>&1 && '
        f"bash tests/runtime_test.sh 2>&1"
    )
    _, out, err = c.exec_command("bash -lc " + repr(cmd), timeout=300)
    sys.stdout.write(out.read().decode("utf-8", errors="replace"))
    e = err.read().decode("utf-8", errors="replace")
    if e:
        sys.stderr.write(e)
    code = out.channel.recv_exit_status()
    c.close()
    return code


if __name__ == "__main__":
    raise SystemExit(main())

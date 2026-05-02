"""Write a .sn on Mac and run snc; print full compiler output.

Credentials: env vars or scripts/snc_ssh.env (gitignored template: snc_ssh.env.example).
"""
import base64
import os
import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from mac_ssh_common import default_remote_dir, load_snc_ssh_env

import paramiko

load_snc_ssh_env()

_SN_USER = os.environ.get("SNC_SSH_USER", "asishsharma")
HOST = os.environ.get("SNC_SSH_HOST", "192.168.0.113")
USER = _SN_USER
PWD = os.environ.get("SNC_SSH_PASSWORD", "")
REMOTE_BASE = os.environ.get("SNC_SSH_REMOTE_DIR", default_remote_dir(_SN_USER))
SN = r"""contract Worker {
    fn run()
}

blueprint Task follows Worker {
    fn run() {
        print(1)
    }
}

fn worker() {
    Task t()
    t.run()
}

fn main() {
    spawn worker()
    print(2)
}
"""
REMOTE = "/tmp/spawn_repro.sn"
SNC = f"{REMOTE_BASE}/snc"

if __name__ == "__main__":
    if not PWD:
        print(
            "Set SNC_SSH_PASSWORD or scripts/snc_ssh.env",
            file=sys.stderr,
        )
        sys.exit(2)
    b64 = base64.b64encode(SN.encode("utf-8")).decode("ascii")
    remote_cmd = (
        f"echo {b64} | base64 -D > {REMOTE} 2>/dev/null || "
        f"echo {b64} | base64 -d > {REMOTE}; "
        f"cd {REMOTE_BASE} && {SNC} {REMOTE} 2>&1; echo exit:$?"
    )
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
    _, out, err = c.exec_command("bash -lc " + repr(remote_cmd), timeout=60)
    sys.stdout.write(out.read().decode("utf-8", errors="replace"))
    e = err.read().decode("utf-8", errors="replace")
    if e:
        sys.stderr.write(e)
    c.close()

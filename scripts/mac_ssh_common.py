"""Load SSH settings from scripts/snc_ssh.env (optional, gitignored)."""
from __future__ import annotations

import os
from pathlib import Path

_ENV_FILENAME = "snc_ssh.env"


def load_snc_ssh_env(*, overwrite: bool = False) -> None:
    env_path = Path(__file__).resolve().parent / _ENV_FILENAME
    if not env_path.is_file():
        return
    for raw in env_path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, val = line.split("=", 1)
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if not key:
            continue
        if overwrite or key not in os.environ or os.environ[key] == "":
            os.environ[key] = val


def default_remote_dir(user: str) -> str:
    return f"/Users/{user}/programming/snc"

# Run from Windows PowerShell after SSH auth works (password prompt or SSH keys).
# Usage:
#   .\scripts\remote_mac_build.ps1
#   .\scripts\remote_mac_build.ps1 -SkipPull
param(
    [string]$SshHost = "192.168.0.113",
    [string]$SshUser = "asishsharma",
    [string]$RemotePath = "/Users/asishsharma/programming/snc",
    [switch]$SkipPull
)

$remote = "${SshUser}@${SshHost}"
if ($SkipPull) {
    $inner = "cd $RemotePath && make clean && make && bash tests/runtime_test.sh"
} else {
    $inner = "cd $RemotePath && git pull --rebase origin main && make clean && make && bash tests/runtime_test.sh"
}

ssh $remote "bash -lc `"$inner`""

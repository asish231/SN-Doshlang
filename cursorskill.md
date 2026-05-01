# Cursor SSH Workflow

Use this repo with Cursor and keep the Mac as the real test target.

## Goal

- Edit locally in Cursor.
- Push changes to `origin`.
- Pull the branch on the Mac over SSH.
- Build and test there.
- Repeat until the Mac run is clean.

## SSH Access

Use the same host you tested with:

- Host: `192.168.0.113`
- User: `asishsharma`
- Password: `Asish@2006`

Recommended approach in Cursor:

1. Open the repo in Cursor.
2. Open the integrated terminal.
3. Use `ssh asishsharma@192.168.0.113`.
4. If you prefer non-interactive automation, use an SSH-capable terminal tool or a small helper script like the one Codex used here.

## Remote Loop

Run this cycle on every meaningful change:

1. Edit locally in Cursor.
2. Commit locally.
3. `git push origin main`
4. On the Mac: `git pull --rebase origin main`
5. Build: `make clean && make`
6. Run the relevant tests.
7. Fix anything that fails.
8. Repeat.

## What To Test On The Mac

Focus on the paths that matter most here:

- `tests/test_string.sh`
- `tests/compile_test.sh`
- `tests/runtime_test.sh`
- `tests/test_modules.sh`
- `tests/test_math.sh`
- direct repros for `slice`, map mutation, and `cast(int, str)`

## Tracker Files

Keep the repo state files current after each fix batch:

- Update `ISSUES.md` when something is still broken or partially fixed.
- Update `RESOLVED_ISSUES.md` when a bug is fixed and verified.
- Update `AGENT_STATE.md` before and after touching shared `src/*.s` areas.

## Practical Rules

- Don’t assume a fix is done until the Mac run passes.
- If a test is flaky on Windows but clean on macOS, trust the Mac result.
- Keep commits small and test after each commit.
- If you change a shared interface, document it in `AGENT_STATE.md` immediately.


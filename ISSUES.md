# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Current Status

- No active blocking compiler regressions are currently open from the prior checklist.
- Validation baseline is green on macOS for build + module + runtime + math suites.
- Ongoing language enhancement work continues as normal feature development, not break/fix blockers.

## Contract/Follows and Spawn — compile failure

- **Problem:** `contract` + `follows` blueprint and `spawn` statement fail to compile.
  - Test: `tests/runtime_test.sh` → "Contract/Follows and Spawn"
  - Errors on line 13 (blueprint closing `}`) and line 17 (`spawn worker()`)
  - Error messages are empty (bug in error reporting: shows `"line line X: "` with no message)
- **Status:** FAIL — `runtime_test.sh` reports `PASS=10 FAIL=1`
- **Next steps:** Debug parser handling of `follows` clause and `spawn` keyword in `src/parser.s`; fix empty error message bug in error reporting.

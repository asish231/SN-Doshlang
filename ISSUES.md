# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Current Status

- No active blocking compiler regressions are currently open from the prior checklist.
- Validation baseline is green on macOS for build + module + runtime + math suites.
- Ongoing language enhancement work continues as normal feature development, not break/fix blockers.

## Contract / Follows and Spawn

- The `tests/runtime_test.sh` “Contract/Follows and Spawn” case uses **`new Task t()`** (heap) inside `worker()` rather than **`Task t()`** (stack) when the worker is invoked through **`spawn`** / compile-time `_call_function`. Stack-slot blueprint instances nested that way previously failed or produced opaque diagnostics; heap `new` is the robust pattern until stack nesting is tightened in the compiler.

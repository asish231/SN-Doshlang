# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Contract/Follows and Spawn — compile failure

- **Problem:** `contract` + `follows` blueprint and `spawn` statement fail to compile.
  - Test: `tests/runtime_test.sh` → "Contract/Follows and Spawn"
  - Current error: `error: unknown function on line 13: _run`
  - Line 13 is the closing `}` of the `Task` blueprint — the `run()` method isn't being registered correctly in the function table
  - Line 17 (`spawn worker()`) also fails after the blueprint error
- **Status:** FAIL — `runtime_test.sh` reports `PASS=10 FAIL=1`
- **Next steps:** Debug why blueprint methods (like `run()`) aren't registered when using `follows` clause. Check `src/parser.s` blueprint method parsing and function table registration.
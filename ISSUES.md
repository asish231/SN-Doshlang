# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Current Status

- No active blocking compiler regressions are currently open from the prior checklist.
- Validation baseline is green on macOS for build + module + runtime + math suites.
- Ongoing language enhancement work continues as normal feature development, not break/fix blockers.

## Contract/Follows and Blueprint Methods — compile failure

- **Problem:** `contract` + `follows` blueprint, blueprint method calls, and general user-defined functions fail to compile.
- **Root cause:** Multiple issues in parser.s:
  1. Double underscore bug in method name synthesis (`__method` instead of `_method`)
  2. `current_blueprint_parse` global not set during blueprint parsing — causes methods to not find their blueprint
  3. User functions not being emitted by codegen at all — only `_main` and runtime helpers appear in output
- **Test cases:**
  - `tests/test_contract_follows.sn` → error: blueprint does not implement required contract method
  - `tests/test_method_no_contract.sn` → c.draw() generates error: unknown function `_draw`
  - `tests/test_direct_fn.sn` → draw_simple() generates error: unknown function `_draw_simple`
- **Status:** UNDER INVESTIGATION
- **Next steps:** Fix codegen to emit user-defined functions (both top-level and blueprint methods)
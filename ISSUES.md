# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Current Status

- No active blocking compiler regressions are currently open from the prior checklist.
- Validation baseline is green on macOS for build + module + runtime + math suites.
- Ongoing language enhancement work continues as normal feature development, not break/fix blockers.

## Windows follow-up

- Full Windows build verification is still pending because `clang` is not available on `PATH` in the current Windows workspace.
- The current Windows build flow targets ARM64, so `snc.exe` is cross-buildable from `x64` Windows but not natively runnable there.
- Native support for standard `x64` Windows would require a larger port or alternate backend, not just build-script changes.

## String cast hardening status

- ✅ `cast(int, str)` chained concat path fixed
- ✅ runtime `cast(bool, str)` now uses live stack value (not compile-time metadata)
- ✅ runtime `cast(dec, str)` validated in dynamic concat path coverage (`tests/runtime_test.sh`)

## Map diagnostics hardening status

- ✅ missing map-key lookups now report `error: map key not found` in compile-time-resolvable lookup paths
- ✅ added focused example coverage for missing-key diagnostic behavior
- ✅ dedicated runtime dynamic map store/insert op path added and validated (`m[k]=v` with variable keys/values)

## String slice status

- ✅ parser and codegen wiring for `str.slice(start, end)` has been added
- ✅ runtime helper `_string_slice` is emitted again
- ✅ `_string_slice` now clamps bounds and guards null/empty cases to avoid out-of-range reads
- ✅ macOS re-run now passes for `tests/test_slice_only.sn`, `tests/test_slice_literals.sn`, and `tests/test_slice.sn`

## Module system

- ✅ `use module.path` syntax parsing
- ✅ Single and multiple module imports work
- ✅ Dotted module paths
- ✅ Module file loading and parsing
- ✅ Imported functions callable from importing file
- ✅ Duplicate `use` handled safely
- ✅ Module search paths (`.` and `stdlib` by default)
- ✅ transitive re-export style usage covered (`tests/modules/transitive_reexport`)

See `ANTIGRAVITY_ISSUE.md` — RESOLVED.

## Nested function multiple calls

- ✅ repeated nested-function calls with `if` return path validated in runtime suite (`tests/runtime_test.sh`)

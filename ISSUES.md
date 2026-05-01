# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Remaining self-hosting gaps

- advanced `list<T>` semantics (beyond core literal/index/for-in/mutation)
  — richer methods, stronger bounds diagnostics, nested generic edge cases
- advanced `map<K,V>` semantics (beyond core literal/read/update-existing-key)
  — key insertion semantics, clearer missing-key diagnostics, nested generic edge cases
- stronger runtime reliability
- better compiler diagnostics
- hardened strings and file I/O
- fuller multi-return support
- `std.math.pow()` semantic mismatch in current runtime validation (`pow(2, 3)` prints `2`, expected `8`)

## String cast hardening status

- ✅ `cast(int, str)` chained concat path fixed
- ✅ runtime `cast(bool, str)` now uses live stack value (not compile-time metadata)
- ⚠️ runtime `cast(dec, str)` in deeply dynamic paths still needs broader validation coverage

## Map diagnostics hardening status

- ✅ missing map-key lookups now report `error: map key not found` in compile-time-resolvable lookup paths
- ✅ added focused example coverage for missing-key diagnostic behavior
- ⚠️ dynamic runtime map store/insert semantics still need a dedicated runtime op for full “modern map” behavior

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
- ❌ Symbol resolution across multiple chained modules (cannot access symbols from transitive imports; must import each module directly)

See `ANTIGRAVITY_ISSUE.md` — RESOLVED.

## Next concrete milestone

- Expand test coverage for module imports with multiple functions
- Diagnostics for typed returns, cast paths, list/map edge cases, file I/O

## Nested function multiple calls (proper fix pending)

- Workaround in place (move nested fns to top-level) but the root cause — op recording using absolute rather than relative slot indices per call frame — is not yet fixed

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

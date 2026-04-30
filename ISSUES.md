# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Remaining self-hosting gaps

- advanced `list<T>` semantics (beyond core literal/index/for-in/mutation)
  — richer methods, stronger bounds diagnostics, nested generic edge cases
- advanced `map<K,V>` semantics (beyond core literal/read/update-existing-key)
  — key insertion semantics, clearer missing-key diagnostics, nested generic edge cases
- full module system
- stronger runtime reliability
- better compiler diagnostics
- small stdlib
- hardened strings and file I/O
- fuller multi-return support

## Next concrete milestone

- expand test coverage and diagnostics for typed returns, cast paths, list/map edge cases, and file I/O runtime behavior


## Nested function multiple calls (proper fix pending)

- Workaround in place (move nested fns to top-level) but the root cause — op recording using absolute rather than relative slot indices per call frame — is not yet fixed

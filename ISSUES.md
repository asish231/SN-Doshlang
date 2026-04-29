# Open Issues

Resolved work now lives in `RESOLVED_ISSUES.md`.

## Remaining self-hosting gaps

- advanced `list<T>` semantics (beyond core literal/index/for-in/mutation)
  examples: richer methods, stronger bounds diagnostics, nested generic edge cases
- advanced `map<K,V>` semantics (beyond core literal/read/update-existing-key)
  examples: key insertion semantics, clearer missing-key diagnostics, nested generic edge cases
- full module system
- stronger runtime reliability
- better compiler diagnostics
- small stdlib
- hardened strings and file I/O
- fuller multi-return support if the compiler design depends on it

## Next concrete milestone

- expand test coverage and diagnostics for typed returns, cast paths, list/map edge cases, and file I/O runtime behavior

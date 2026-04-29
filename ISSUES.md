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

## Print issues to resolve 
- [FIXED] The print in same line isn't yet configured -> Use `printn(...)` (now documented in README).

## run.sh issues
- [FIXED] Timestamp calculation error and selector fallthrough hardened.

## Map issues
- [FIXED] `for (node in graph[1])` iteration works.

## Nested function issues
- [FIXED] Multiple invocations of nested functions with `if` returns verified.
- [FIXED] Nested functions inside `if` blocks supported.

## three_if.sn issues
- [FIXED] Missing return enforcement added.
- [FIXED] Parameter shadowing and brace mismatches cleaned up in example.

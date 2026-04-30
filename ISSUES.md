# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Remaining self-hosting gaps

- advanced `list<T>` semantics (beyond core literal/index/for-in/mutation)
  — richer methods, stronger bounds diagnostics, nested generic edge cases
- advanced `map<K,V>` semantics (beyond core literal/read/update-existing-key)
  — key insertion semantics, clearer missing-key diagnostics, nested generic edge cases
- stronger runtime reliability
- better compiler diagnostics
- small stdlib
- hardened strings and file I/O
- fuller multi-return support

## Module system (partially implemented)

- ✅ `use module.path` syntax parsing
- ✅ Single and multiple module imports work
- ✅ Dotted module paths
- ✅ Module loading tracking infrastructure in place
- ❌ `_load_module` crashes on any real `use` statement — see `ANTIGRAVITY_ISSUE.md`
- ❌ Actual file loading and parsing blocked by above crash
- ❌ Symbol resolution (imported functions not callable)
- ❌ Module search paths (infrastructure done, blocked by crash)

## Next concrete milestone

- Implement actual module file loading and parsing
- Add symbol resolution for imported functions
- Expand test coverage and diagnostics for typed returns, cast paths, list/map edge cases, and file I/O runtime behavior

## Pointer ops

- `Lemit_op_map_load` in `codegen.s` is incomplete — `mov x3, #key_type` emission is missing (`asm_mov_x3_imm` not yet wired in); runtime map lookup by variable key will crash until this is done

## Nested function multiple calls (proper fix pending)

- Workaround in place (move nested fns to top-level) but the root cause — op recording using absolute rather than relative slot indices per call frame — is not yet fixed
# Antigravity Issue — Module Loading Crash

## Status
OPEN

## Summary

The compiler crashes (segfault) when any `use` statement is present and the full
`_load_module` implementation is active. The crash is isolated to inside
`_load_module` — stubbing it to `mov x0, #0 / ret` makes everything work.

---

## What Works

- `use module.path` syntax parsing ✅
- Multiple `use` statements ✅
- Module name tracking ✅
- `_init_default_search_paths` ✅
- `_find_module` ✅
- Everything when `_load_module` is a no-op stub ✅

## What Crashes

- `_load_module` with real implementation → segfault
- Crash happens inside `_load_module` before reaching `_module_path_to_file`
  or `_file_exists` (confirmed by binary stubbing)

---

## Root Cause (Suspected)

`_load_module` calls `_module_path_to_file` which calls `_malloc` and
`_cstring_length` on search path pointers stored in `module_search_paths`.

The search paths are initialized by `_init_default_search_paths` which stores
pointers to static `.data` strings (`"."` and `"stdlib"`) into the BSS
`module_search_paths` array.

The suspected issue is a **register clobber** inside `_module_path_to_file`
during the search path loop — `x21` is used both as the `module_search_count`
value and later overwritten with the `_cstring_length` result, causing a bad
pointer dereference on the next iteration.

A rewrite of `_module_path_to_file` was attempted with clean register
allocation (`x19-x24` for all persistent values) but the crash persists,
suggesting the issue may be earlier — possibly in how `_find_module` interacts
with the `_match_span_span` call when the module name pointer points into the
source buffer (which may not be null-terminated at the exact right offset).

---

## Reproduction

```sh
cat > /tmp/test.sn << 'EOF'
use math

fn main() {
    print("hello")
}
EOF
./snc /tmp/test.sn
# → Segmentation fault: 11
```

Without `use`:
```sh
cat > /tmp/test.sn << 'EOF'
fn main() {
    print("hello")
}
EOF
./snc /tmp/test.sn
# → works fine
```

---

## Files Involved

| File | Relevance |
|------|-----------|
| `src/utils.s` | `_load_module`, `_find_module`, `_module_path_to_file`, `_file_exists` |
| `src/parser.s` | `_parse_use_statement_after_keyword` — calls `_load_module` |
| `src/main.s` | calls `_init_default_search_paths` before `_parse_program` |
| `src/data.s` | `module_names`, `module_paths`, `module_search_paths`, `module_count` |

---

## Current Workaround

`_load_module` is stubbed to `mov x0, #0 / ret` so that:
- `use` statements parse and compile without crashing
- Module names are NOT tracked
- No file loading or symbol resolution happens

This means multiple `use` statements work syntactically but imported functions
are not callable.

---

## Next Steps to Fix

1. Add `write` debug output at the start of `_load_module` to confirm it is
   being entered (rules out crash in `_init_default_search_paths`)
2. Add debug output after `_find_module` call to confirm it returns cleanly
3. Add debug output after `_module_path_to_file` call
4. Narrow crash to exact instruction using `lldb`

The most likely fix once narrowed:
- Ensure `_find_module` is called with `x0=x19, x1=x20` explicitly set
  (not relying on registers being preserved from before the save)
- Ensure `_module_path_to_file` uses only `x19-x24` for persistent state
  and never clobbers them with `bl` return values without saving first

---

## Related Issues

- `ISSUES.md` — Module system section
- `RESOLVED_ISSUES.md` — Issues #26 and #27 (module foundation and multiple use fix)

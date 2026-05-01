# SNlang Open Issues

Current test suite status: **34/34 pass** (`make test`).
The issues below are failures found outside the official test suite — in `tests/` and `examples/` files not yet covered by `make test`.

---

## 1. `string.slice()` — Not Implemented

**Affected files:** `tests/test_slice.sn`, `tests/test_slice_literals.sn`, `tests/test_slice_only.sn`, `examples/slice_*.sn`, `examples/string_slice_test.sn`

**Error:** `line line N:` (silent parse failure)

**Root cause:** `Lprimary_member_slice` in `src/parser.s` (line ~5447) is a stub — it just does `b Lprimary_fail`. The keyword `slice` is recognized but the method body is never parsed. No op 90 is ever recorded, so the codegen for `Lemit_op_string_slice` (which exists and is correct) is never reached.

**What needs doing:**
- Implement `Lprimary_member_slice` in `src/parser.s` to parse `s.slice(start, end)`, allocate a temp var, and record op 90 with `(dest, unused, source_slot, start_val_or_slot+100, end_val_or_slot+100)`.
- Uncomment `asm_string_slice_runtime` emission in `src/codegen.s` (line ~290) so `_string_slice` is included in output.

---

## 2. `string.split()` — Not Implemented

**Affected files:** `tests/test_string_split.sn`

**Error:** `line line N:` (silent parse failure)

**Root cause:** `s.split(delim)` has no parser path at all. There is no `kw_split` check in `Lprimary_member_access`, no codegen op, and no runtime helper for splitting a string by delimiter.

**What needs doing:**
- Add `kw_split` keyword to `src/data.s`.
- Add a dispatch branch in `Lprimary_member_access` in `src/parser.s`.
- Add a `_string_split` runtime helper that returns a `list<str>`.
- Add codegen for the new op.

---

## 3. `for` loop with C-style init/condition/step — Broken for complex conditions

**Affected files:** `examples/debug_and.sn`, `examples/debug_prime.sn`, `examples/dsa_binary_exponentiation.sn`, `examples/minimal_and.sn`, `examples/simple_and.sn`

**Error:** `error: expected character on line N: ,` or `error: expected character on line N: )`

**Root cause:** The counted `for` loop `for (int d = 2, d * d <= x && prime, d += 1)` fails when the condition contains `&&` (logical and) or a compound expression like `d * d <= x`. The parser's condition expression inside the for-loop header does not fully support logical operators or complex binary expressions in that position.

**What needs doing:**
- Ensure `_parse_expr_value` (which handles `and`/`or`) is used for the condition slot of the counted for loop, not a simpler comparison-only parser.

---

## 4. Module / `use` — Runtime Loading Not Implemented

**Affected files:** `tests/test_local.sn`, `tests/test_local_use.sn`, `tests/test_simple_use.sn`, `tests/test_stdlib.sn`, `tests/test_module_main.sn`, `examples/main_use_maths.sn`, `examples/maths.sn`

**Error:** `error: unknown variable on line N: <module_name>` or `error: expected statement`

**Root cause:** `use module.path` syntax parses correctly, but the module file is not actually loaded and its symbols are not made available. The module system is parse-only — there is no file I/O to read the imported `.sn` file, no second-pass parse of it, and no symbol merging into the current scope.

**What needs doing:**
- In `src/main.s` or `src/parser.s`, when a `use` statement is encountered, locate the `.sn` file on the search path, load it, and parse its top-level function definitions into the current `fn_table`.

---

## 5. Chained Module Calls — Symbol Not Resolved Across Files

**Affected files:** `tests/test_chained_main.sn`

**Error:** `error: unknown function on line 3: c2`

**Root cause:** Even if module loading were implemented, transitive imports are not supported. `use test_chained_2` would need to expose `c2()`, but the symbol resolution only looks in the directly imported file's scope, not in anything it in turn imports.

**What needs doing:** Depends on #4 being fixed first. After that, ensure imported function definitions are merged into the global `fn_table`.

---

## 6. Top-level Variable Declarations — Not Supported

**Affected files:** `examples/function_scope_shadowing.sn`

**Error:** `error: expected character on line 4: (`

**Root cause:** `int value = 99` at the top level (outside any function) is not valid in the current parser. `parse_statement` is only called inside function bodies. The parser sees `int value = 99` at the top level and fails when it hits the next `fn` keyword.

**What needs doing:**
- Allow variable declarations at the top level, emitting them as `.data` section globals, or restrict the example to only use variables inside functions.

---

## 7. Old/Alternate Function Parameter Syntax — Not Supported

**Affected files:** `examples/binary_search.sn`

**Error:** `error: expected character on line 3: <`

**Root cause:** `fn binary_search(list: [int], target: int)` uses a colon-based parameter syntax (`name: type`) which is not the current SNlang syntax. Current syntax is `fn f(type name)`.

**What needs doing:** Either update the example file to use correct syntax, or add support for the alternate syntax in the parser.

---

## 8. `nested_for_control.sn` — `for (value in values)` Inside Nested Scope Fails

**Affected files:** `examples/nested_for_control.sn`

**Error:** `error: expected character on line 20: (`

**Root cause:** A `for (value in values)` loop nested inside another loop or block fails at line 20. The `(` after `for` is not being consumed correctly in the nested context, likely a cursor state issue after the outer loop's block parsing.

**What needs doing:** Investigate cursor state after nested block exit in the for-in loop parser path.

---

## 9. `test_string_lib.sn` — `string` Used as Namespace

**Affected files:** `tests/test_string_lib.sn`

**Error:** `error: unknown variable on line 7: string`

**Root cause:** The test uses `string.slice(...)` as a namespace-qualified call (e.g. `string.slice(s, 1, 3)`) rather than the method syntax `s.slice(1, 3)`. There is no namespace/module object support.

**What needs doing:** Either update the test to use method syntax once `slice` is implemented, or implement namespace-qualified function calls.

---

## 10. `decimals_invalid_scale.sn` / `decimals_invalid_arg.sn` — Expected Errors Not Triggering Correctly

**Affected files:** `examples/decimals_invalid_scale.sn`, `examples/decimals_invalid_arg.sn`

**Error:** `line line N:` (generic parse failure instead of specific decimal error message)

**Root cause:** These files are expected to fail with a specific error (e.g. `error: invalid decimal scale`), but instead fail with a generic line error. The error reporting path for these specific decimal validation cases is not reaching the right error message.

**What needs doing:** Trace the decimal validation path for scale and argument errors and ensure the correct `msg_*` string is emitted before the generic failure.

---

## Summary Table

| # | Issue | Files Affected | Effort |
|---|-------|---------------|--------|
| 1 | `string.slice()` not implemented | 8 files | Medium — codegen exists, need parser impl |
| 2 | `string.split()` not implemented | 1 file | High — needs parser + runtime helper |
| 3 | `for` loop complex conditions (`&&` in header) | 5 files | Medium — use full expr parser in for header |
| 4 | Module `use` runtime loading | 7 files | High — needs file I/O + symbol merge |
| 5 | Chained module symbol resolution | 1 file | Blocked by #4 |
| 6 | Top-level variable declarations | 1 file | Low — fix example or add top-level var support |
| 7 | Old parameter syntax `name: type` | 1 file | Low — fix example file |
| 8 | Nested `for-in` cursor state bug | 1 file | Medium — debug cursor after nested block |
| 9 | `string.method()` namespace syntax | 1 file | Low — fix example file |
| 10 | Decimal error messages (scale/arg) | 2 files | Low — fix error reporting path |

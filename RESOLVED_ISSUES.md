# Resolved Issues

This file tracks issues that have been fixed and locally verified.

## 2026-04-29

### 1) `cast(int, str)` in chained string concatenation

- Problem:
  - expressions like `print("k=" + cast(k, str) + ", j=" + cast(j, str))` either failed or produced wrong output
- Fix summary:
  - corrected temporary-variable stack accounting for generated programs
  - fixed concat literal-folding length handling in expression parsing
- Verification:
  - `examples/cast_string_concat.sn` prints `k=2, j=5`
  - `examples/void_return_example.sn` prints correct nested `k=..., j=...` lines

### 2) `cast(bool, str)` in concatenation

- Problem:
  - bool cast inside concatenation did not produce correct string content
- Fix summary:
  - bool cast now resolves to real string pointers (`"true"` / `"false"`)
  - variable-backed bool values are read correctly for cast paths
- Verification:
  - `examples/cast_bool_concat.sn` prints `b=true`

### 3) `cast(dec, str)` in concatenation

- Problem:
  - decimal cast-to-string used non-string payloads and produced incorrect output
- Fix summary:
  - added decimal-to-cstring helper in runtime utils
  - parser cast path now uses helper and correct runtime string lengths
- Verification:
  - `examples/cast_decimal_concat.sn` prints `d=10.50`

### 4) Missing return enforcement for typed functions

- Problem:
  - `fn f() -> int { ... }` could end without `return` and still compile
- Fix summary:
  - added missing-return validation when typed function bodies close
  - introduced clear compiler diagnostic: `error: missing return in typed function ...`
- Verification:
  - a typed function missing return now fails compilation
  - a void-like function without return still compiles and runs

### 5) List and map indexed mutation support

- Problem:
  - statements like `nums[1] = 99` and `ages["Bob"] = 31` were parsed as unknown statements
- Fix summary:
  - added indexed assignment parsing in statement assignment flow
  - added type checks for index/key and assigned value type
  - added pool updates for list elements and existing map keys
- Verification:
  - `examples/list_mutation.sn` prints `10`, `99`, `30`
  - `examples/map_mutation.sn` prints `25`, `31`

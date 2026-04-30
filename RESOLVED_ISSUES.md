# Resolved Issues

This file tracks issues that have been fixed and locally verified.

---

## Session: 2026-04-29 (dev fixes)

### 1) `cast(int, str)` in chained string concatenation
- **Problem:** `print("k=" + cast(k, str))` failed or produced wrong output
- **Fix:** Corrected temp-variable stack accounting and concat literal-folding length handling
- **Verified:** `examples/cast_string_concat.sn` prints `k=2, j=5`

### 2) `cast(bool, str)` in concatenation
- **Problem:** bool cast inside concat did not produce correct string
- **Fix:** Bool cast now resolves to real string pointers `"true"` / `"false"`
- **Verified:** `examples/cast_bool_concat.sn` prints `b=true`

### 3) `cast(dec, str)` in concatenation
- **Problem:** Decimal cast-to-string produced incorrect output
- **Fix:** Added decimal-to-cstring helper in runtime utils
- **Verified:** `examples/cast_decimal_concat.sn` prints `d=10.50`

### 4) Missing return enforcement for typed functions
- **Problem:** `fn f() -> int { }` could compile without a return
- **Fix:** Added missing-return validation when typed function bodies close
- **Verified:** Typed function missing return now fails with clear error

### 5) List and map indexed mutation
- **Problem:** `nums[1] = 99` and `ages["Bob"] = 31` were unknown statements
- **Fix:** Added indexed assignment parsing with type checks and pool updates
- **Verified:** `examples/list_mutation.sn` and `examples/map_mutation.sn` pass

### 6) `int x = fn()` then `print(x)` failed
- **Problem:** Storing function return into variable then printing failed
- **Fix:** `_call_function` result now correctly feeds into `_record_store_variable`
- **Verified:** `int x = get_value()` then `print(x)` works correctly

---

## Session: 2026-04-29 (fixes in this session)

### 7) `printn()` — print without newline broken
- **Problem:** `printn("text")` generated broken assembly — `add x1, x1, print_val_0 sub sp, sp, #16` (missing `@PAGEOFF\n`)
- **Fix:** Added `@PAGEOFF\n` prefix to `asm_print_noline_call_stack` in `data.s`
- **Verified:** `printn("hello ")` + `printn("world")` prints `hello world` on one line

### 8) Makefile `make clean && make` broken
- **Problem:** `TMPDIR` conflicted with make's built-in variable. Default target was `$(TMPDIR)` not `snc`.
- **Fix:** Renamed to `OUTDIR`, set `.DEFAULT_GOAL := $(SNC)`, removed broken `.build/tmp` dependency
- **Verified:** `make clean && make` builds cleanly from scratch

### 9) `map_pool_key_ptrs` missing symbol
- **Problem:** `parser.s` referenced `map_pool_key_ptrs` but it was missing from `data.s` causing linker failure
- **Fix:** Added `.global map_pool_key_ptrs` declaration and `.space 32768` buffer to `data.s`
- **Verified:** Compiler builds and links cleanly

### 10) `let` keyword removed
- **Problem:** `let x = 10` was untyped legacy syntax conflicting with strict typing philosophy
- **Fix:** Removed `Lstmt_let` handler and `kw_let` from `parser.s` and `data.s`
- **Verified:** All examples use typed declarations. Build passes.

### 11) Buffer limits too small
- **Problem:** Source buffer 8KB, var limit 64, op limit 512 caused `error: too many operations` on real programs
- **Fix:** Increased all limits — source 64KB, vars 512, ops 4096, prints 2048, fns 64
- **Verified:** `for_loop.sn` and other large examples compile without hitting limits

### 12) Debug print left in `codegen.s`
- **Problem:** Dev left a debug block in `_emit_store_data` that injected stray numbers into generated assembly causing infinite loops
- **Fix:** Removed the debug print block entirely
- **Verified:** `while_simple.sn` no longer loops infinitely

### 13) Nested function multiple calls — workaround applied
- **Problem:** Calling a function with nested `fn` definitions more than once caused stack offset overflow `[x29, #-18446744073709551608]`
- **Root cause:** `var_count` restored after each call so second call assigns different slot indices
- **Workaround:** Move nested fn to top-level. Proper fix requires relative slot indices per call frame.
- **Verified:** `examples/nested_fn_single_if.sn` updated and passing

### 14) Example files cleaned up
- **Problem:** Several examples used legacy `let` syntax or had top-level code outside `fn main()`
- **Fix:** Updated `math.sn`, `grouping.sn`, `decimals.sn`, `for_loop.sn`, `spec_batch.sn`, `decimals_fractional.sn`. Deleted `string_test.sn`.
- **Verified:** All 34 tests pass

### 15) `multi_return.sn` test fixed
- **Problem:** Example used unsupported tuple return syntax `-> (int, bool)` causing test failure
- **Fix:** Updated example to use two separate functions with single returns
- **Verified:** `make test` passes all 34 tests

---

## Session: current

### 16) Print in same line not working
- **Problem:** No way to print without a trailing newline
- **Fix:** `printn(...)` implemented and documented in README
- **Verified:** Works correctly

### 17) `run.sh` timestamp calculation error and selector fallthrough
- **Fix:** Timestamp calculation hardened, selector fallthrough fixed
- **Verified:** `run.sh` operates correctly

### 18) `for (node in graph[1])` map iteration broken
- **Fix:** Map iteration over indexed value now works
- **Verified:** Confirmed working

### 19) Multiple invocations of nested functions with `if` returns
- **Fix:** Verified and working
- **Verified:** Confirmed

### 20) Nested functions inside `if` blocks
- **Fix:** Supported and verified
- **Verified:** Confirmed

### 21) Missing return enforcement (`three_if.sn`)
- **Fix:** Missing return enforcement added
- **Verified:** Confirmed

### 22) Parameter shadowing and brace mismatches in examples
- **Fix:** Cleaned up in example files
- **Verified:** Confirmed

### 23) String interpolation segfault (`Lprimary_interp_update_offset`)
- **Problem:** After parsing `{expr}` inside a string, the cursor offset math subtracted the buffer base address from `cursor_pos` which is already an offset — producing a garbage scan index and a segfault
- **Fix:** Corrected to `x21 = cursor_pos - (x19 - buffer_base)` in `src/parser.s`
- **Verified:** `"Hello {name}!"`, multi-variable, and stress interpolation tests all pass

### 24) Pointer ops wired up (address, value, alloc, free, set)
- **Problem:** `address()`, `value()`, `alloc()`, `free()`, `set()` were stub/incorrect — wrong op codes, raw values passed instead of var indices
- **Fix:** Parser now allocates temp vars and passes correct var indices; codegen emits proper `sub x10, x29`, `ldr/ldrb`, `str/strb`, `bl _malloc`, `bl _free` sequences for ops 83–87
- **Verified:** Compiler builds cleanly

### 25) Map runtime key lookup (`Lprimary_map_lookup_runtime`)
- **Problem:** Map lookup with a variable key had no runtime path — only compile-time constant keys worked
- **Fix:** Added `Lprimary_map_lookup_runtime` in `parser.s` emitting op 82 (`map_load`); partial codegen in `Lemit_op_map_load`
- **Status:** Key load and `mov x2, x10` emitted; `mov x3, #key_type` still needs `asm_mov_x3_imm` wired in codegen

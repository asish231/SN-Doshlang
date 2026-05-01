# Handoff State: Native `string.split()` Implementation

This document summarizes the current state of the native `string.split()` implementation and the ongoing debugging process for the next agent.

## Objective
Implement native `.split(delimiter)` support for strings in SNlang, returning a `list<str>`.

## Current Status
- **Parser**: Syntax `.split(delim)` is recognized. It emits Op 91.
- **Codegen**: Op 91 generates a call to `_string_split` in the runtime.
- **Runtime**: `_string_split` is implemented in `data.s` and correctly populates the `list_pool`.
- **Feature Extension**: Updated List Indexing (Op 80) to support "dynamic bases" (where the list pool index is stored in a stack slot rather than being a compile-time constant).

## The Blocker
A test case `tests/test_string_split.sn` fails with a parser error: `line line 4:`.
Line 4 is: `str x = p[0]` (where `p` is the result of `s.split(",")`).

### Observations:
1. The compiler fails during parsing, not at runtime.
2. `p` is correctly typed as `List` (type 4).
3. The metadata for `p` has the element type `str` (type 2) in the upper 32 bits.
4. `Lprimary_indexing` in `parser.s` is triggered.
5. I recently fixed a register clobbering bug in `Lprimary_list_index_runtime` (line 6057), but the "line line 4" error remains.

## Technical Details

### Op Codes Involved
- **Op 91**: `string_split(result_slot, source_slot, delimiter_slot)`.
- **Op 80**: `list_load(dest_slot, index, base, flags)`.
  - Flags bit 0: Element is a string.
  - Flags bit 1: Index is immediate (vs slot).
  - **Flags bit 2 (New)**: Base is a slot (vs immediate). Used for dynamic lists.

### Files Modified
- `src/parser.s`: 
  - Added `Lprimary_member_split`.
  - Updated `Lprimary_indexing` and `Lprimary_list_index_runtime` for bit 2 flags.
  - Simplified the `.` member dispatcher in `Lprimary_suffix_loop_start`.
- `src/codegen.s`:
  - Added `Lemit_op_string_split` (Op 91).
  - Updated `Lemit_op_list_load` (Op 80) to support bit 2 of flags (loading base from slot).
- `src/data.s`:
  - Added `_string_split` and its helper `L_snl_split_copy_token`.
  - Added `asm_call_string_split` and `asm_add_x10_x10_x11`.

### Unfinished Work / Bugs
- **Parser Crash**: Why is `p[0]` failing to parse? The error prefix `line line 4: ` implies `_expect_char` or similar failed inside `Lprimary_indexing`.
- **Runtime Length**: `p.length()` currently returns 0 because the compiler doesn't know the count at compile-time and there is no runtime list-length lookup yet.

## Next Steps for the Next LLM
1. **Debug `parser.s:Lprimary_indexing`**: Use print-debugging in the compiler or trace the `_parse_expr_value` call for the index.
2. **Verify `_lookup_variable`**: Ensure that when `p` is looked up, its type (4) and metadata are correctly returned in `x2` and `x3`.
3. **Check `out.s` generation**: If you can get the compiler to emit `out.s` before it crashes (by commenting out the failing line), verify the stack offsets for the dynamic list base.

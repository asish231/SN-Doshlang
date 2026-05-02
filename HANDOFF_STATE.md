# Handoff State — 2026-05-02

## Current Issue: Contract/Follows and Blueprint Methods Not Working

### Summary
The contract/follows feature and blueprint methods are currently broken. Tests fail during compile with errors about missing required methods, even when they are defined.

### What Was Done
1. Fixed double-underscore bug in `_build_method_synth_name` (was writing `__method` instead of `_method`)
2. Added `current_blueprint_parse` storage during blueprint registration

### Root Cause (Still Blocking)
**User functions are NOT being emitted by codegen at all.** The generated assembly only contains:
- `_main` entry point
- Runtime helpers (`_cstring_length`, `_str_concat`, etc.)
- Print format strings in `.data`

But NO user-defined functions like `draw_simple()` or blueprint methods like `Circle__draw()` are generated.

### Test Failures
```
tests/test_contract_follows.sn → error: blueprint does not implement required contract method
tests/test_method_no_contract.sn → error: unknown function _draw  
tests/test_direct_fn.sn → error: unknown function _draw_simple
```

### Investigation Notes
- Parser correctly parses definitions (verified via trace)
- `_lookup_function` returns failure in codegen path
- No `.global` directives for user functions in output
- Function body operations not being converted to emitted assembly

### Next Steps (for next agent)
1. Investigate why `_emit_operation` doesn't emit user functions
2. Check if function bodies are being visited during codegen traversal
3. The fix likely requires adding a codegen pass that iterates function table and emits each defined function

### Code Locations
- `_emit_program`: `src/codegen.s:6`
- `_emit_operation`: `src/codegen.s` (search for this)
- Function tables: `src/data.s` (fn_name_ptrs, fn_body_cursors, etc.)
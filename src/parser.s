#include "platform.inc"
 .text
 .align 4
.global _parse_program
.global _parse_statement
.global _parse_function_body
.global _pow10_u64


_parse_program:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    LOAD_ADDR x9, current_parse_fn_id
    mov x10, #-1
    str x10, [x9]

    bl _preparse_functions
    cbnz x0, Lprogram_fail

    LOAD_ADDR x9, cursor_pos
    str xzr, [x9]
    LOAD_ADDR x9, current_line
    mov x10, #1
    str x10, [x9]

Lprogram_loop:
    bl _skip_whitespace
    bl _is_eof
    cbnz x0, Lprogram_ok

    bl _parse_statement
    cbz x0, Lprogram_loop
    cmp x0, #5
    b.eq Lprogram_quiet_fail
    b Lprogram_fail

Lprogram_ok:
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

// Statement already printed a diagnostic (return code 5); exit without generic message.
Lprogram_quiet_fail:
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret

Lprogram_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret

_preparse_functions:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    LOAD_ADDR x9, cursor_pos
    str xzr, [x9]
    LOAD_ADDR x9, current_line
    mov x10, #1
    str x10, [x9]

Lpreparse_loop:
    bl _skip_whitespace
    bl _is_eof
    cbnz x0, Lpreparse_done

    bl _parse_identifier
    cbz x0, Lpreparse_non_ident
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_blueprint
    bl _match_cstr_span
    cbnz x0, Lpreparse_blueprint_label
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_contract
    bl _match_cstr_span
    cbnz x0, Lpreparse_skip_decl_block
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_fn
    bl _match_cstr_span
    cbz x0, Lpreparse_loop
    bl _parse_fn_definition
    cbnz x0, Lpreparse_fail
    b Lpreparse_loop

Lpreparse_non_ident:
    bl _peek_char
    cmp w0, #'"'
    b.ne Lpreparse_advance
    bl _parse_string_literal
    cbz x0, Lpreparse_fail
    b Lpreparse_loop

Lpreparse_skip_decl_block:
    bl _skip_decl_block
    cbnz x0, Lpreparse_fail
    b Lpreparse_loop

Lpreparse_blueprint_label:
    bl _preparse_blueprint_methods
    cbnz x0, Lpreparse_fail
    b Lpreparse_loop

Lpreparse_advance:
    bl _advance_char
    b Lpreparse_loop

Lpreparse_done:
    mov x0, #0
    b Lpreparse_return

Lpreparse_fail:
    mov x0, #1

Lpreparse_return:
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_statement:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    // Alternate array-type declaration `[T] name = <expr>` (e.g. `[int] nums =
    // [1,2,3]`). A statement starting with '[' is a list declaration in the
    // bracket dialect; route it to the shared list-declaration path.
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'['
    b.eq Lstmt_bracket_list_decl

    bl _parse_identifier
    cbz x0, Lstmt_need_keyword
    mov x19, x0
    mov x20, x1

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_let
    bl _match_cstr_span
    cbnz x0, Lstmt_let

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_print_noline
    bl _match_cstr_span
    cbnz x0, Lstmt_print_noline

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_printx
    bl _match_cstr_span
    cbnz x0, Lstmt_print_noline

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_print
    bl _match_cstr_span
    cbnz x0, Lstmt_print

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_int
    bl _match_cstr_span
    cbnz x0, Lstmt_int

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_bool
    bl _match_cstr_span
    cbnz x0, Lstmt_bool

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_byte
    bl _match_cstr_span
    cbnz x0, Lstmt_byte

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_dec
    bl _match_cstr_span
    cbnz x0, Lstmt_dec

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_const
    bl _match_cstr_span
    cbnz x0, Lstmt_const

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_fn
    bl _match_cstr_span
    cbnz x0, Lstmt_fn

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_if
    bl _match_cstr_span
    cbnz x0, Lstmt_if

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_while
    bl _match_cstr_span
    cbnz x0, Lstmt_while

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_for
    bl _match_cstr_span
    cbnz x0, Lstmt_for

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_stop
    bl _match_cstr_span
    cbnz x0, Lstmt_stop

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_skip
    bl _match_cstr_span
    cbnz x0, Lstmt_skip

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_str
    bl _match_cstr_span
    cbnz x0, Lstmt_str

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_list
    bl _match_cstr_span
    cbnz x0, Lstmt_list

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_chan
    bl _match_cstr_span
    cbnz x0, Lstmt_chan

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_task
    bl _match_cstr_span
    cbnz x0, Lstmt_task

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_scope
    bl _match_cstr_span
    cbnz x0, Lstmt_scope

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_ref
    bl _match_cstr_span
    cbnz x0, Lstmt_ref

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_map
    bl _match_cstr_span
    cbnz x0, Lstmt_map

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_match
    bl _match_cstr_span
    cbnz x0, Lstmt_match

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_use
    bl _match_cstr_span
    cbnz x0, Lstmt_use

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_blueprint
    bl _match_cstr_span
    cbnz x0, Lstmt_blueprint

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_contract
    bl _match_cstr_span
    cbnz x0, Lstmt_contract

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_spawn
    bl _match_cstr_span
    cbnz x0, Lstmt_spawn

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_new
    bl _match_cstr_span
    cbnz x0, Lstmt_new

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_return
    bl _match_cstr_span
    cbnz x0, Lstmt_return_val

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_throw
    bl _match_cstr_span
    cbnz x0, Lstmt_throw

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_try
    bl _match_cstr_span
    cbnz x0, Lstmt_try

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_set
    bl _match_cstr_span
    cbnz x0, Lstmt_set

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_free
    bl _match_cstr_span
    cbnz x0, Lstmt_free

    mov x0, x19
    mov x1, x20
    bl _lookup_blueprint_id
    cbnz x0, Lstmt_stack_object


    b Lstmt_assign

Lstmt_blueprint:
    bl _parse_blueprint
    cbnz x0, Lstmt_return
    mov x0, #0
    b Lstmt_return

Lstmt_contract:
    bl _parse_contract
    cbnz x0, Lstmt_return
    mov x0, #0
    b Lstmt_return

#ifndef _WIN32
// spawn worker(): captures worker body ops in a separate buffer, emits pthread-backed run at codegen.
Lstmt_spawn:
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x21, x0
    mov x22, x1
    
    // Check if it is a method call: obj.method()
    LOAD_ADDR x9, source_ptr
    ldr x9, [x9]
    LOAD_ADDR x10, cursor_pos
    ldr x10, [x10]
    ldrb w11, [x9, x10]
    cmp w11, #'.'
    b.ne Lstmt_spawn_simple
    // A '.' here means `spawn obj.method()`. Report the clear "not yet
    // supported" error immediately -- the method-capture path below is dead
    // (it clobbered the object-name registers before _lookup_variable, then
    // used an out-of-range spawn slot), so it only produced an empty error.
    b Lstmt_spawn_method_fail

    // Method call detected (dead code, kept for reference)
    add x10, x10, #1
    LOAD_ADDR x9, cursor_pos
    str x10, [x9]
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x23, x0 // method name
    mov x24, x1

    // Look up object
    mov x0, x21
    mov x1, x22
    bl _lookup_variable
    cbz x0, Lstmt_fail
    // x0=value, x1=type, x2=meta (blueprint id if type=10/11), x3=slot
    
    // Only support stack/heap objects (10/11)
    cmp x1, #10
    b.eq Lstmt_spawn_method_ok
    cmp x1, #11
    b.ne Lstmt_spawn_simple // fallback or fail

Lstmt_spawn_method_ok:
    // Spawning a blueprint METHOD (`spawn obj.method()`) is NOT yet supported.
    // The old capture path wrote into an out-of-range spawn buffer slot (63,
    // while the spawn tables hold only 32 entries) and its worker was never
    // emitted by codegen, so it only ever produced a confusing EMPTY diagnostic
    // and failed to compile. Report a clear error instead. (`spawn fn()` on a
    // zero-arg function works, and wait() joins it -- see examples/spawn_wait.sn.)
    b Lstmt_spawn_method_fail

Lstmt_spawn_simple:
    LOAD_ADDR x9, spawn_capture_fn_id
    ldr x10, [x9]
    cmn x10, #1
    b.ne Lstmt_spawn_nested_fail
    mov x0, x21
    mov x1, x22
    bl _is_imported_function
    cbnz x0, Lstmt_spawn_import_fail
    mov x0, x21
    mov x1, x22
    bl _lookup_function
    cbz x0, Lstmt_fail
    mov x23, x1
    LOAD_TBL x9, fn_param_counts
    ldr x10, [x9, x23, lsl #3]
    cbnz x10, Lstmt_spawn_params_fail
    
    // Consume '()'
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail

    // Set capture mode
    LOAD_ADDR x9, spawn_capture_fn_id
    str x23, [x9]
    
    // Clear spawn buffer for this function
    LOAD_ADDR x9, spawn_fn_op_counts
    str xzr, [x9, x23, lsl #3]

    // Record a simple call to the function into its own spawn buffer.
    // This is much cleaner than re-parsing the body.
    mov x0, #13
    mov x1, x23
    bl _record_operation
    
    // Reset capture mode
    LOAD_ADDR x9, spawn_capture_fn_id
    mov x10, #-1
    str x10, [x9]

    // Record the spawn op in the main stream
    mov x0, #91
    mov x1, x23
    mov x2, #0
    bl _record_operation
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_spawn_nested_fail:
    LOAD_ADDR x0, msg_spawn_nested
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_spawn_import_fail:
    LOAD_ADDR x0, msg_spawn_imported
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_spawn_params_fail:
    LOAD_ADDR x0, msg_spawn_params
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_spawn_method_fail:
    LOAD_ADDR x0, msg_spawn_method
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

#else
// Windows-hosted compiler: spawn still runs the callee at compile time into the main op stream.
Lstmt_spawn:
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x21, x0
    mov x22, x1
    bl _skip_whitespace
    mov x0, x21
    mov x1, x22
    bl _call_function
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return
#endif

Lstmt_new:
    bl _parse_new_object
    cbnz x0, Lstmt_return
    mov x0, #0
    b Lstmt_return

Lstmt_stack_object:
    bl _parse_stack_object
    cbnz x0, Lstmt_return
    mov x0, #0
    b Lstmt_return

Lstmt_set:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // pointer value
    mov x22, x2 // type ID
    cmp x22, #9 // must be ref
    b.ne Lstmt_type_mismatch
    mov x26, x3 // element type metadata
    mov x27, x4 // ptr var idx

    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x23, x1 // value to set
    mov x24, x2 // type ID
    cmp x24, x26
    b.ne Lstmt_type_mismatch
    mov x25, x4 // set var idx

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _consume_optional_semicolon

    // Emit pointer set operation (87)
    mov x0, #87 // op_set_ptr
    mov x1, x27 // ptr var idx
    mov x2, x23 // value to set (imm)
    mov x3, x25 // set var idx
    mov x4, x26 // element type
    bl _record_operation4
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_free:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // pointer value
    mov x22, x2 // type ID
    cmp x22, #9 // must be ref
    b.ne Lstmt_type_mismatch
    mov x23, x4 // ptr var idx

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _consume_optional_semicolon

    // Emit free operation (86)
    mov x0, #86 // op_free_ptr
    mov x1, x23 // ptr var idx
    mov x2, x21 // ptr val
    bl _record_operation
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_throw:
    // An uncaught throw would bypass the scope-end join. Throws caught by an
    // enclosing try remain valid because control stays inside the scope.
    LOAD_ADDR x9, task_scope_depth
    ldr x10, [x9]
    cbz x10, Lstmt_throw_scope_ok
    LOAD_ADDR x9, current_catch_label
    ldr x10, [x9]
    cbz x10, Lstmt_scope_control_fail
Lstmt_throw_scope_ok:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _skip_whitespace
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // error message value
    mov x22, x2 // type ID (should be str)
    mov x23, x3 // length (meta) -- string literal length lives in x3

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _consume_optional_semicolon

    // A string-literal message is a raw source pointer; intern it into the
    // data table so error_value stores a stable data-value id (a small int
    // that `mov x0, #id` can load) -- mirrors Lstmt_let_str. This makes the
    // caught variable `e` a normal str whose value prints correctly.
    cmp x22, #2
    b.ne Lstmt_throw_emit
    mov x0, x21
    mov x1, #2
    mov x2, x23
    bl _record_data_value
    mov x21, x0 // data-value id

Lstmt_throw_emit:
    // If we are lexically inside a block try's body, a throw must NOT exit the
    // program: set error_value/flag WITHOUT exiting (op 108), then branch to the
    // enclosing catch label. Outside any try, keep the terminating throw (op 95).
    LOAD_ADDR x9, current_catch_label
    ldr x9, [x9]
    cbz x9, Lstmt_throw_toplevel

    mov x0, #108 // op_throw_no_exit
    mov x1, x21  // error message data-value id
    mov x2, x23  // string length
    bl _record_operation
    cbnz x0, Lstmt_fail

    mov x0, #41  // op_jump: real unconditional branch to the enclosing catch
                 // (op 35 merely PLACES a label -- see Lemit_op_if_end)
    LOAD_ADDR x9, current_catch_label
    ldr x1, [x9]
    sub x1, x1, #1   // recover the true label id (stored as id+1; see Lstmt_try_block_impl)
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_throw_toplevel:
    // Emit throw operation (95): set error_value/flag and exit(1).
    mov x0, #95 // op_throw
    mov x1, x21 // error message data-value id
    mov x2, x23 // string length
    bl _record_operation
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_try:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'{'
    b.eq Lstmt_try_block_impl

    // Expression form: try expr catch (e) { ... } or try expr catch fallback
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // try expression value
    mov x22, x2 // try expression type
    mov x23, x4 // try expression meta

    bl _skip_whitespace
    LOAD_ADDR x0, kw_catch
    bl _consume_keyword
    cbz x0, Lstmt_fail

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.eq Lstmt_try_catch_block_form

    // Simple form: try expr catch fallback_expr
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x24, x1 // fallback value
    mov x25, x2 // fallback type
    mov x26, x4 // fallback meta

    // Type check: try result and fallback must be compatible
    cmp x22, x25
    b.ne Lstmt_type_mismatch

    // Emit try-catch operation (96)
    mov x0, #96 // op_try_catch
    mov x1, x21 // try value
    mov x2, x23 // try meta
    mov x3, x24 // fallback value
    mov x4, x26 // fallback meta
    bl _record_operation5
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_try_catch_block_form:
    // Form: try expr catch (e) { statements }
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    // Store error variable name for catch block

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail

Lstmt_try_block:
    // Mixed form `try expr catch (e) { ... }` still falls through here and is
    // unsupported (errors cleanly). The pure block form is handled below.
    b Lstmt_fail

// ============================================================
// Block form:  try { A } catch (e) { B }   (also `catch { B }`)
// Emits a REAL runtime error path (no compile-time faking):
//   [op105] clear error_flag                 <- try entry, start clean
//   <A>            (throws inside A set error_value/flag via op108 and
//                   jump straight to Lcatch via op35 -- see Lstmt_throw)
//   [op106] if error_flag != 0 goto Lcatch   <- also catches built-in errors
//   [op35]  b Lend                           <- success path skips catch
//   [op36]  Lcatch:
//   [op107] e = error_value                  <- bind catch var (if present)
//   [op105] clear error_flag                 <- consume the error
//   <B>
//   [op36]  Lend:
// current_catch_label makes throws inside A target THIS catch; it is saved and
// restored so nested try blocks behave correctly. Cursor enters at the try
// body's '{'.
// ============================================================
Lstmt_try_block_impl:
    bl _get_next_label
    mov x24, x0                 // Lcatch
    bl _get_next_label
    mov x25, x0                 // Lend

    // Save the enclosing catch label and install ours for the try body.
    // We store (catch_label_id + 1) so that a real label id of 0 is still
    // distinguishable from the "not inside a try" sentinel (0). `throw`
    // subtracts 1 to recover the true id.
    LOAD_ADDR x9, current_catch_label
    ldr x26, [x9]
    add x10, x24, #1
    str x10, [x9]

    // op105: clear error_flag at entry
    mov x0, #105
    mov x1, #0
    mov x2, #0
    bl _record_operation
    cbnz x0, Ltryb_fail_restore

    // consume the try body '{'
    mov w0, #'{'
    bl _expect_char
    cbz x0, Ltryb_fail_restore

Ltryb_try_body:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Ltryb_try_done
    cbz w0, Ltryb_unclosed
    bl _parse_statement
    cbz x0, Ltryb_try_body
    cmp x0, #2                  // stop: jump op already recorded
    b.eq Ltryb_try_body
    cmp x0, #3                  // skip: jump op already recorded
    b.eq Ltryb_try_body
    cmp x0, #4                  // return: op already recorded
    b.eq Ltryb_try_body
    b Ltryb_fail_restore

Ltryb_try_done:
    bl _advance_char            // consume '}'

    // Restore the enclosing catch label BEFORE the catch body, so throws in the
    // catch body (or after the whole try) do not target our own catch.
    LOAD_ADDR x9, current_catch_label
    str x26, [x9]

    // op106: if a built-in error set error_flag during A, go to Lcatch.
    mov x0, #106
    mov x1, x24
    mov x2, #0
    bl _record_operation
    cbnz x0, Ltryb_fail

    // op41: success -> unconditionally jump over the catch block to Lend.
    // (op 35 merely PLACES a label; using it here duplicated the Lend label.)
    mov x0, #41
    mov x1, x25
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Ltryb_fail

    // op36: place Lcatch.
    mov x0, #36
    mov x1, x24
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Ltryb_fail

    // expect the `catch` keyword
    bl _skip_whitespace
    LOAD_ADDR x0, kw_catch
    bl _consume_keyword
    cbz x0, Ltryb_fail

    // optional `(e)`
    mov x27, #0                 // catch var name ptr (0 = none)
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Ltryb_catch_clear
    mov w0, #'('
    bl _expect_char
    cbz x0, Ltryb_fail
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x27, x0                 // name ptr
    mov x28, x1                 // name len
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Ltryb_fail

    // Bind `e` (reuse if it already exists so nested catches with the same name
    // do not trip the duplicate-variable check). e is a str whose value is the
    // thrown message's data-value id; op107 loads error_value into its slot.
    mov x0, x27
    mov x1, x28
    bl _lookup_variable
    cbnz x0, Ltryb_evar_ready
    mov x0, x27
    mov x1, x28
    mov x2, #0
    mov x3, #0
    mov x4, #2                  // type str
    mov x5, #0
    bl _define_variable
    cbnz x0, Ltryb_fail
    mov x0, x27
    mov x1, x28
    bl _lookup_variable
    cbz x0, Ltryb_fail
Ltryb_evar_ready:
    mov x1, x4                  // e slot
    mov x0, #107
    mov x2, #0
    bl _record_operation
    cbnz x0, Ltryb_fail

Ltryb_catch_clear:
    // op105: clear error_flag (the error is now handled).
    mov x0, #105
    mov x1, #0
    mov x2, #0
    bl _record_operation
    cbnz x0, Ltryb_fail

    // consume the catch body '{'
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Ltryb_fail

Ltryb_catch_body:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Ltryb_catch_done
    cbz w0, Ltryb_unclosed
    bl _parse_statement
    cbz x0, Ltryb_catch_body
    cmp x0, #2
    b.eq Ltryb_catch_body
    cmp x0, #3
    b.eq Ltryb_catch_body
    cmp x0, #4
    b.eq Ltryb_catch_body
    b Ltryb_fail

Ltryb_catch_done:
    bl _advance_char            // consume '}'

    // op36: place Lend.
    mov x0, #36
    mov x1, x25
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Ltryb_fail

    mov x0, #0
    b Lstmt_return

Ltryb_unclosed:
    LOAD_ADDR x9, current_catch_label
    str x26, [x9]
    b Lwhile_unclosed

Ltryb_fail_restore:
    LOAD_ADDR x9, current_catch_label
    str x26, [x9]
Ltryb_fail:
    b Lstmt_fail

Lstmt_let:
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _try_parse_input_call
    cbnz x0, Lstmt_let_input

    // Try runtime binary expression first (var op var, var op imm)
    bl _try_parse_runtime_var_bin_expr
    cbnz x0, Lstmt_let_runtime_expr

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1
    mov x22, x2
    mov x23, x3
    mov x24, x4

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x22
    mov x5, x23
    bl _define_variable
    cbnz x0, Lstmt_fail

    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x26, x4 // target slot

    cmp x22, #2 // str
    b.eq Lstmt_let_str
    cmp x22, #4 // list
    b.eq Lstmt_let_collection
    cmp x22, #8 // map
    b.eq Lstmt_let_collection
    cmp x22, #5 // dec
    b.eq Lstmt_let_done

    cmn x24, #1
    b.eq Lstmt_let_store_imm
    // Variable source: emit op 45 (store_var_var) for runtime copy
    mov x0, #45
    mov x1, x26
    mov x2, x24
    bl _record_operation
    cbnz x0, Lstmt_fail
    b Lstmt_let_done
Lstmt_let_store_imm:
    mov x0, x26
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
    b Lstmt_let_done

Lstmt_let_str:
    // Op 72 for constant string literal
    cmn x24, #-1
    b.ne Lstmt_let_store_var_var
    // Intern the string into the print/data table to get a stable ID
    mov x0, x21
    mov x1, #2
    mov x2, x23
    bl _record_data_value
    mov x21, x0 // data id
    mov x0, #72
    mov x1, x26
    mov x2, x21
    bl _record_operation
    b Lstmt_let_done

Lstmt_let_collection:
    // Just use Op 1 for collection base index?
    // Actually collections are just an index into the pool.
    mov x0, x26
    mov x1, x21
    bl _record_store_variable
    b Lstmt_let_done

Lstmt_let_store_var_var:
    mov x0, #45
    mov x1, x26
    mov x2, x24
    bl _record_operation
    b Lstmt_let_done

Lstmt_let_done:
    mov x0, #0
    b Lstmt_return

Lstmt_let_runtime_expr:
    // _try_parse_runtime_var_bin_expr returned:
    // x1 = lhs var index, x2 = op (1=add,2=sub,3=mul,4=div,5=mod)
    // x3 = rhs (var idx or imm), x4 = 1 if rhs is var, 0 if imm
    mov x21, x1  // lhs var index
    mov x22, x2  // op type
    mov x23, x3  // rhs operand
    mov x24, x4  // rhs_is_var flag

    bl _consume_optional_semicolon

    // Compute compile-time value for define_variable
    LOAD_TBL x9, var_values
    ldr x25, [x9, x21, lsl #3]  // lhs compile-time value
    mov x26, x23
    cbz x24, Lstmt_let_rt_rhs_ready
    ldr x26, [x9, x23, lsl #3]  // rhs compile-time value
Lstmt_let_rt_rhs_ready:
    cmp x22, #1
    b.eq Lstmt_let_rt_eval_add
    cmp x22, #2
    b.eq Lstmt_let_rt_eval_sub
    cmp x22, #3
    b.eq Lstmt_let_rt_eval_mul
    cmp x22, #4
    b.eq Lstmt_let_rt_eval_div
    cmp x22, #5
    b.eq Lstmt_let_rt_eval_mod
    b Lstmt_fail
Lstmt_let_rt_eval_add:
    add x28, x25, x26
    b Lstmt_let_rt_define
Lstmt_let_rt_eval_sub:
    sub x28, x25, x26
    b Lstmt_let_rt_define
Lstmt_let_rt_eval_mul:
    mul x28, x25, x26
    b Lstmt_let_rt_define
Lstmt_let_rt_eval_div:
    cbz x26, Lstmt_fail
    udiv x28, x25, x26
    b Lstmt_let_rt_define
Lstmt_let_rt_eval_mod:
    cbz x26, Lstmt_fail
    udiv x9, x25, x26
    msub x28, x9, x26, x25

Lstmt_let_rt_define:
    // Define variable with compile-time value x28
    mov x0, x19
    mov x1, x20
    mov x2, x28
    mov x3, #0    // not const
    mov x4, #0    // int type
    mov x5, #0    // no length
    bl _define_variable
    cbnz x0, Lstmt_fail

    // Look up new var slot
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x27, x4  // dest var index

    // Record runtime operation
    cbz x24, Lstmt_let_rt_record_imm
    // Both operands are vars: op = x22 + 27
    add x0, x22, #27
    mov x1, x27
    mov x2, x21
    mov x3, x23
    bl _record_operation3
    cbnz x0, Lstmt_fail
    b Lstmt_let_done
Lstmt_let_rt_record_imm:
    // LHS is var, RHS is immediate: op = x22 + 22
    add x0, x22, #22
    mov x1, x27
    mov x2, x21
    mov x3, #0
    mov x4, x23
    bl _record_operation4
    cbnz x0, Lstmt_fail
    b Lstmt_let_done

Lstmt_let_input:
    mov x21, x1 // prompt ptr
    mov x23, x2 // prompt len
    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, #0
    mov x3, #0
    mov x4, #2
    mov x5, #0
    bl _define_variable
    cbnz x0, Lstmt_fail

    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail

    mov x0, #47
    mov x1, x4
    mov x2, x21
    mov x3, x23
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_int:
    bl _skip_whitespace
    mov x23, #0
    bl _peek_char
    cmp w0, #'?'
    b.ne Lstmt_int_name
    bl _advance_char
    mov x23, #16
Lstmt_int_name:
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // value
    mov x22, x2 // type
    mov x25, x4 // source var id

    cmp x22, #0
    b.eq Lstmt_int_value_ok
    cmp x23, #16
    b.ne Lstmt_type_mismatch
    cmp x22, #16
    b.eq Lstmt_int_value_ok
    cmp x22, #7
    b.ne Lstmt_type_mismatch
    Lstmt_int_value_ok:

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x23
    bl _define_variable
    cbnz x0, Lstmt_fail
    mov x26, x4 // target slot id

    cmn x25, #1
    b.ne Lstmt_int_store_var

    mov x0, x26
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
    b Lstmt_int_done

    Lstmt_int_store_var:
    mov x0, #45
    mov x1, x26
    mov x2, x25
    bl _record_operation
    cbnz x0, Lstmt_fail

    Lstmt_int_done:
    mov x0, #0
    b Lstmt_return
Lstmt_bool:
    bl _skip_whitespace
    mov x23, #1
    bl _peek_char
    cmp w0, #'?'
    b.ne Lstmt_bool_name
    bl _advance_char
    mov x23, #17
Lstmt_bool_name:
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // value
    mov x22, x2 // type
    mov x25, x4 // source var id

    cmp x22, #1
    b.eq Lstmt_bool_value_ok
    cmp x23, #17
    b.ne Lstmt_type_mismatch
    cmp x22, #17
    b.eq Lstmt_bool_value_ok
    cmp x22, #7
    b.ne Lstmt_type_mismatch
    Lstmt_bool_value_ok:

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x23
    mov x5, #0
    bl _define_variable
    cbnz x0, Lstmt_fail
    mov x26, x4 // target slot id

    cmn x25, #1
    b.ne Lstmt_bool_store_var

    mov x0, x26
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
    b Lstmt_bool_done

    Lstmt_bool_store_var:
    mov x0, #45
    mov x1, x26
    mov x2, x25
    bl _record_operation
    cbnz x0, Lstmt_fail

    Lstmt_bool_done:
        mov x0, #0
        b Lstmt_return

    Lstmt_byte:

    bl _skip_whitespace
    mov x23, #3
    bl _peek_char
    cmp w0, #'?'
    b.ne Lstmt_byte_name
    bl _advance_char
    mov x23, #19
Lstmt_byte_name:
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    cmp x2, #0
    b.eq Lstmt_byte_type_ok
    cmp x2, #3
    b.eq Lstmt_byte_type_ok
    cmp x23, #19
    b.ne Lstmt_type_mismatch
    cmp x2, #19
    b.eq Lstmt_byte_type_ok
    cmp x2, #7
    b.ne Lstmt_type_mismatch
Lstmt_byte_type_ok:
    mov x21, x1

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x23 // type byte/byte?
    mov x5, #0
    bl _define_variable
    cbnz x0, Lstmt_fail
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x0, x4
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_byte_done:
    mov x0, #0
    b Lstmt_return

Lstmt_dec:
    bl _parse_decimal_type_suffix
    cbz x0, Lstmt_fail
    mov x23, x1 // scale
    mov x24, #6
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'?'
    b.ne Lstmt_dec_name
    bl _advance_char
    mov x24, #22
Lstmt_dec_name:

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // value
    mov x22, x2 // type
    mov x27, x3 // source scale
    mov x25, x4 // source var id

    cmp x24, #22
    b.eq Lstmt_dec_check_nullable
    cmp x22, #6
    b.ne Lstmt_type_mismatch
    b Lstmt_dec_check_scale
    Lstmt_dec_check_nullable:
    cmp x22, #7
    b.eq Lstmt_dec_value_ok
    cmp x22, #22
    b.eq Lstmt_dec_check_scale
    cmp x22, #6
    b.ne Lstmt_type_mismatch
    b Lstmt_dec_check_scale
    Lstmt_dec_check_scale:
    cmp x27, x23
    b.ne Lstmt_decimal_scale_error
    Lstmt_dec_value_ok:

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x24 // type dec/dec?
    mov x5, x23 // scale
    bl _define_variable
    cbnz x0, Lstmt_fail
    mov x26, x4 // target slot id

    cmn x25, #1
    b.ne Lstmt_dec_store_var

    mov x0, x26
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
    b Lstmt_dec_done

    Lstmt_dec_store_var:
    mov x0, #45
    mov x1, x26
    mov x2, x25
    bl _record_operation
    cbnz x0, Lstmt_fail

    Lstmt_dec_done:
    mov x0, #0
    b Lstmt_return
Lstmt_str:
    bl _skip_whitespace
    mov x23, #2
    bl _peek_char
    cmp w0, #'?'
    b.ne Lstmt_str_name
    bl _advance_char
    mov x23, #18
Lstmt_str_name:
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _try_parse_input_call
    cbnz x0, Lstmt_str_input

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    cmp x2, #2
    b.eq Lstmt_str_value_ok
    cmp x23, #18
    b.ne Lstmt_fail
    cmp x2, #18
    b.eq Lstmt_str_value_ok
    cmp x2, #7
    b.ne Lstmt_fail
Lstmt_str_value_ok:
    mov x24, x4 // source var id (or -1 if immediate)
    mov x21, x1 // ptr/value
    mov x22, x3 // len

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x23 // type str/str?
    mov x5, x22
    bl _define_variable
    cbnz x0, Lstmt_fail

    // Emit runtime store into stack slot.
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x26, x4 // dest var idx

    cmp x24, #-1
    b.ne Lstmt_str_store_from_var
    // Immediate string: intern into print/data table then store its address.
    mov x0, x21
    mov x1, #2
    mov x2, x22
    bl _record_data_value
    mov x21, x0 // print/data id
    mov x0, #72
    mov x1, x26
    mov x2, x21
    mov x3, #0
    bl _record_operation3
    cbnz x0, Lstmt_fail
    b Lstmt_str_store_done

Lstmt_str_store_from_var:
    // Source is another var/temp: store var->var.
    mov x0, #45
    mov x1, x26
    mov x2, x24
    bl _record_operation
    cbnz x0, Lstmt_fail

Lstmt_str_store_done:

    mov x0, #0
    b Lstmt_return

Lstmt_str_input:
    mov x21, x1 // prompt ptr
    mov x22, x2 // prompt len

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, #0
    mov x3, #0
    mov x4, x23 // type str/str?
    mov x5, #0 // runtime input string length unknown at compile time
    bl _define_variable
    cbnz x0, Lstmt_fail

    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail

    mov x0, #47
    mov x1, x4
    mov x2, x21
    mov x3, x22
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_bracket_list_decl:
    // `[T] name = <expr>` (bracket array-type dialect). _parse_type_spec handles
    // the whole `[T]` and returns x1=4 (list type), x2=(elemType<<32); converge
    // on the shared list path (name, '=', value, element-type check).
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    lsr x23, x2, #32 // element type
    mov x25, #0      // element length/scale (overwritten by the value's metadata)
    mov x24, #4      // unified list type ID
    b Lstmt_list_name

// `chan<T> name` or `chan<T> name = chan<T>()`.
// Channels are stable compile-time handles into the emitted shared runtime.
// Payloads are one machine word: int, bool, byte, or string pointer.
Lstmt_chan:
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    mov x23, x1                 // payload type
    cmp x23, #0
    b.eq Lstmt_chan_type_ok
    cmp x23, #1
    b.eq Lstmt_chan_type_ok
    cmp x23, #2
    b.eq Lstmt_chan_type_ok
    cmp x23, #3
    b.ne Lstmt_type_mismatch
Lstmt_chan_type_ok:
    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    LOAD_ADDR x24, channel_count
    ldr x21, [x24]
    cmp x21, #64
    b.ge Lstmt_fail

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'='
    b.ne Lstmt_chan_define
    bl _advance_char
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x25, x0
    mov x26, x1
    mov x0, x25
    mov x1, x26
    LOAD_ADDR x2, kw_chan
    bl _match_cstr_span
    cbz x0, Lstmt_fail
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    cmp x1, x23
    b.ne Lstmt_type_mismatch
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lstmt_fail
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail

Lstmt_chan_define:
    mov x0, x19
    mov x1, x20
    mov x2, x21                 // stable channel id
    mov x3, #1                  // channel handles cannot be reassigned
    mov x4, #12                 // channel type id
    mov x5, x23                 // payload type metadata
    bl _define_variable
    cbnz x0, Lstmt_fail
    mov x0, #122                // initialize/reset this declaration site
    mov x1, x21
    mov x2, #0
    bl _record_operation
    cbnz x0, Lstmt_fail
    add x21, x21, #1
    str x21, [x24]
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

// `task<T> name = async function()` starts one zero-argument function and
// stores a typed task handle. The existing spawn worker wrapper is reused;
// op 132 starts the result-bearing task at runtime.
Lstmt_task:
    LOAD_ADDR x9, task_runtime_used
    mov x10, #1
    str x10, [x9]
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    mov x23, x1                 // task result type
    cmp x23, #0
    b.eq Lstmt_task_type_ok
    cmp x23, #1
    b.eq Lstmt_task_type_ok
    cmp x23, #2
    b.ne Lstmt_type_mismatch
Lstmt_task_type_ok:
    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1
    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_async
    bl _match_cstr_span
    cbz x0, Lstmt_fail
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    bl _lookup_callable_function
    cbz x0, Lstmt_fail
    mov x24, x1                 // function id
    cmp x24, #32                // current worker wrapper table size
    b.ge Lstmt_fail
    LOAD_TBL x9, fn_param_counts
    ldr x10, [x9, x24, lsl #3]
    cbnz x10, Lstmt_fail
    LOAD_TBL x9, fn_return_types
    ldr x10, [x9, x24, lsl #3]
    cmp x10, x23
    b.ne Lstmt_type_mismatch
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail

    mov x0, x19
    mov x1, x20
    mov x2, #0
    mov x3, #1                  // task handles are immutable
    mov x4, #13                 // task type id
    mov x5, x23                 // result type metadata
    bl _define_variable
    cbnz x0, Lstmt_fail
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x25, x4                 // destination task slot

    // Register the function with the existing worker dispatcher.
    LOAD_ADDR x9, spawn_fn_op_counts
    str xzr, [x9, x24, lsl #3]
    LOAD_ADDR x9, spawn_capture_fn_id
    str x24, [x9]
    mov x0, #13
    mov x1, x24
    bl _record_operation
    LOAD_ADDR x9, spawn_capture_fn_id
    mov x10, #-1
    str x10, [x9]

    mov x0, #132
    mov x1, x25
    mov x2, x24
    bl _record_operation
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

// `scope { ... }` records the current task-count marker and joins every task
// created after it before normal block exit. Early exits are rejected while a
// scope is active so cleanup cannot be bypassed in this first structured form.
Lstmt_scope:
    LOAD_ADDR x9, task_runtime_used
    mov x10, #1
    str x10, [x9]
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _allocate_temp_var
    mov x19, x0
    cmn x19, #1
    b.eq Lstmt_fail
    mov x0, #139
    mov x1, x19
    mov x2, #0
    bl _record_operation
    cbnz x0, Lstmt_fail
    LOAD_ADDR x9, task_scope_depth
    ldr x20, [x9]
    add x10, x20, #1
    str x10, [x9]

Lstmt_scope_body:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lstmt_scope_done
    cbz w0, Lstmt_scope_unclosed
    bl _parse_statement
    cbz x0, Lstmt_scope_body
    mov x21, x0
    b Lstmt_scope_fail_restore

Lstmt_scope_done:
    bl _advance_char
    LOAD_ADDR x9, task_scope_depth
    str x20, [x9]
    mov x0, #140
    mov x1, x19
    mov x2, #0
    bl _record_operation
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_scope_unclosed:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x21, #5
Lstmt_scope_fail_restore:
    LOAD_ADDR x9, task_scope_depth
    str x20, [x9]
    cmp x21, #5
    b.eq Lstmt_scope_fail_reported
    b Lstmt_fail
Lstmt_scope_fail_reported:
    mov x0, #5
    b Lstmt_return

Lstmt_list:
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    mov x23, x1 // element type
    mov x25, x2 // element length/scale
    mov x24, #4 // unified list type ID

    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'?'
    b.ne Lstmt_list_name
    bl _advance_char
    add x24, x24, #16
Lstmt_list_name:

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // value
    mov x22, x2 // type ID
    mov x25, x3 // metadata (element type and count)

    // Check if types match exactly
    cmp x22, x24
    b.eq Lstmt_list_element_check

    // Handle nullability: allowed if target is list? (20) and source is list (4) or none (7)
    cmp x24, #20
    b.ne Lstmt_type_mismatch
    cmp x22, #7 // none
    b.eq Lstmt_list_value_ok
    cmp x22, #4 // non-nullable list
    b.ne Lstmt_type_mismatch
    // proceed to element check for list -> list?

Lstmt_list_element_check:
    // If it's a list, we MUST check element type too
    cmp x22, #4
    b.ne Lstmt_list_value_ok
    lsr x9, x25, #32 // actual element type
    cmp x9, x23 // expected element type
    b.ne Lstmt_type_mismatch

Lstmt_list_value_ok:

    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x24
    mov x5, x25
    bl _define_variable
    cbnz x0, Lstmt_fail

    mov x0, #0
    b Lstmt_return

Lstmt_ref:
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    mov x23, x1 // element type
    mov x24, #9 // ref type ID

    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'?'
    b.ne Lstmt_ref_name
    bl _advance_char
    add x24, x24, #16
Lstmt_ref_name:

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // value
    mov x22, x2 // type ID
    mov x25, x3 // metadata (for ref it could be element type, but maybe just value is enough)
    mov x26, x4 // src var idx (temp var from address/alloc, or -1 if immediate)

    // Check if types match exactly or none
    cmp x22, x24
    b.eq Lstmt_ref_value_ok

    cmp x24, #25 // ref?
    b.ne Lstmt_type_mismatch
    cmp x22, #7 // none
    b.eq Lstmt_ref_value_ok
    cmp x22, #9 // ref
    b.ne Lstmt_type_mismatch

Lstmt_ref_value_ok:
    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x24
    mov x5, x23 // store element type in length metadata field
    bl _define_variable
    cbnz x0, Lstmt_fail

    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    // x4 = newly defined var idx

    cmp x26, #-1
    b.eq Lstmt_ref_store_imm

    // Result is in a temp var — emit store_var_var (45)
    mov x0, #45
    mov x1, x4   // dest var idx
    mov x2, x26  // src var idx (temp)
    bl _record_operation
    cbnz x0, Lstmt_fail
    b Lstmt_ref_done

Lstmt_ref_store_imm:
    mov x0, x4
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail

Lstmt_ref_done:
    mov x0, #0
    b Lstmt_return


Lstmt_map:
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    mov x23, x1 // key type

    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lstmt_fail
    mov x26, x1 // value type

    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lstmt_fail

    mov x24, #8 // map type ID

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // value
    mov x22, x2 // type ID
    mov x25, x3 // metadata

    // Type check
    cmp x22, x24
    b.ne Lstmt_type_mismatch
    // check metadata (key and value types)
    lsr x9, x25, #40 // actual key type
    cmp x9, x23
    b.ne Lstmt_type_mismatch
    
    ubfx x9, x25, #32, #8 // actual val type
    cmp x9, x26
    b.ne Lstmt_type_mismatch

Lstmt_map_value_ok:
    bl _consume_optional_semicolon
    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, x24
    mov x5, x25
    bl _define_variable
    cbnz x0, Lstmt_fail
    mov x0, #0
    b Lstmt_return

Lstmt_const:
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x21, x0
    mov x22, x1

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_int
    bl _match_cstr_span
    cbnz x0, Lstmt_const_int

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_bool
    bl _match_cstr_span
    cbnz x0, Lstmt_const_bool

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_str
    bl _match_cstr_span
    cbnz x0, Lstmt_const_str

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_dec
    bl _match_cstr_span
    cbnz x0, Lstmt_const_dec

    LOAD_ADDR x0, msg_expected_type
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_const_int:
    mov x22, #0
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    cmp x2, #0
    b.ne Lstmt_type_mismatch
    mov x21, x1
    mov x24, #0
    b Lstmt_const_store

Lstmt_const_bool:
    mov x22, #1
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    cmp x2, #1
    b.ne Lstmt_type_mismatch
    mov x21, x1
    mov x24, #0
    b Lstmt_const_store

Lstmt_const_str:
    mov x22, #2
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    cmp x2, #2
    b.ne Lstmt_fail
    mov x21, x1
    mov x24, x4
    b Lstmt_const_store

Lstmt_const_dec:
    mov x22, #6
    bl _parse_decimal_type_suffix
    cbz x0, Lstmt_fail
    mov x24, x1
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_need_name
    mov x19, x0
    mov x20, x1

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    cmp x2, #6
    b.ne Lstmt_type_mismatch
    cmp x3, x24
    b.ne Lstmt_decimal_scale_error
    mov x21, x1

Lstmt_const_store:
    bl _consume_optional_semicolon

    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, #1
    mov x4, x22
    mov x5, x24
    bl _define_variable
    cbnz x0, Lstmt_fail
    cmp x22, #2
    b.eq Lstmt_const_store_done
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x0, x4
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
Lstmt_const_store_done:

    mov x0, #0
    b Lstmt_return

Lstmt_print_noline:
    LOAD_ADDR x9, print_noline_flag
    mov x10, #1
    str x10, [x9]
    b Lstmt_print

Lstmt_print:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lstmt_print_plain
    bl _advance_char
    bl _try_parse_runtime_var_bin_expr
    cbnz x0, Lstmt_print_runtime_expr
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x19, x1
    mov x22, x2
    mov x23, x3
    mov x24, x4
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail
    b Lstmt_print_record

Lstmt_print_plain:
    bl _try_parse_runtime_var_bin_expr
    cbnz x0, Lstmt_print_runtime_expr
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x19, x1
    mov x22, x2
    mov x23, x3
    mov x24, x4
    b Lstmt_print_record

Lstmt_print_runtime_expr:
    // x1=lhs var idx, x2=op code 1..5, x3=rhs value/index, x4=rhs kind (0 imm, 1 var)
    cbnz x4, Lstmt_print_runtime_expr_record
    cmp x2, #4
    b.eq Lstmt_print_runtime_expr_check_zero
    cmp x2, #5
    b.ne Lstmt_print_runtime_expr_record
Lstmt_print_runtime_expr_check_zero:
    cbz x3, Lstmt_assign_divide_zero
Lstmt_print_runtime_expr_record:
    cbz x4, Lstmt_print_runtime_expr_record_imm
    add x0, x2, #17
    b Lstmt_print_runtime_expr_record_common
Lstmt_print_runtime_expr_record_imm:
    add x0, x2, #7
Lstmt_print_runtime_expr_record_common:
    mov x2, x3
    mov x1, x1
    bl _record_operation
    cbnz x0, Lstmt_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.ne Lstmt_print_runtime_done
    bl _advance_char
Lstmt_print_runtime_done:
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_print_record:
    bl _consume_optional_semicolon

    cmp x24, #-1
    b.eq Lstmt_print_immediate
    cmp x22, #2
    b.ne Lstmt_print_check_decimal
    cbnz x23, Lstmt_print_immediate
    b Lstmt_print_variable
Lstmt_print_check_decimal:
    cmp x22, #6
    b.eq Lstmt_print_decimal_variable
Lstmt_print_variable:
    mov x0, x24
    mov x1, x22
    bl _record_print_variable
    b Lstmt_print_done

Lstmt_print_decimal_variable:
    mov x0, #56
    mov x1, x24
    mov x2, x23
    mov x3, #0
    bl _record_operation3
    b Lstmt_print_done

Lstmt_print_immediate:
    mov x0, x19 // value
    mov x1, x22 // type
    mov x2, x23 // length
    LOAD_ADDR x3, print_noline_flag
    ldr x3, [x3]
    bl _record_print_value

Lstmt_print_done:
    LOAD_ADDR x9, print_noline_flag
    str xzr, [x9]
    cbnz x0, Lstmt_fail
    mov x0, #0
    b Lstmt_return

Lstmt_fn:
    // NESTED FUNCTIONS: a `fn` inside a function body used to be skipped
    // WITHOUT being registered (so `inner(...)` later in the same body failed
    // with "unknown function"). _parse_fn_definition only registers metadata
    // and skips the body (no ops are recorded into the current stream), and it
    // is redefinition-safe (reuses the slot if the name already exists), so it
    // is safe to run in both top-level and compilation mode. The nested fn's
    // body is compiled later: the main fn-body loop re-reads fn_count each
    // iteration, picking up functions registered mid-parse.
Lstmt_fn_real:
    bl _parse_fn_definition
    cbnz x0, Lstmt_fail
    mov x0, #0
    b Lstmt_return

Lstmt_fn_unclosed:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_if:
    bl _parse_if_statement_after_keyword
    cbz x0, Lstmt_if_ok
    cmp x0, #2
    b.eq Lstmt_return  // propagate stop
    cmp x0, #3
    b.eq Lstmt_return  // propagate skip
    cmp x0, #4
    b.eq Lstmt_return  // propagate return
    b Lstmt_fail
Lstmt_if_ok:
    mov x0, #0
    b Lstmt_return

Lstmt_while:
    bl _parse_while_statement_after_keyword
    cbz x0, Lstmt_while_ok
    cmp x0, #4
    b.eq Lstmt_return
    b Lstmt_fail
Lstmt_while_ok:
    mov x0, #0
    b Lstmt_return

Lstmt_for:
    bl _parse_for_statement_after_keyword
    cbz x0, Lstmt_for_ok
    cmp x0, #4
    b.eq Lstmt_return
    b Lstmt_fail
Lstmt_for_ok:
    mov x0, #0
    b Lstmt_return

Lstmt_stop:
    LOAD_ADDR x9, task_scope_depth
    ldr x10, [x9]
    cbnz x10, Lstmt_scope_control_fail
    bl _consume_optional_semicolon
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    cbz x10, Lstmt_stop_outside_loop
    LOAD_ADDR x9, current_loop_end
    ldr x1, [x9]
    cbz x1, Lstmt_stop_no_emit
    // emit jump to loop end for runtime-coded loops
    mov x0, #41
    mov x2, #0
    mov x3, #0
    bl _record_operation
Lstmt_stop_no_emit:
    mov x0, #2
    b Lstmt_return

Lstmt_stop_outside_loop:
    LOAD_ADDR x0, msg_loop_control
    bl _report_error_prefix
    LOAD_ADDR x0, kw_stop
    mov x1, #4
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_skip:
    LOAD_ADDR x9, task_scope_depth
    ldr x10, [x9]
    cbnz x10, Lstmt_scope_control_fail
    bl _consume_optional_semicolon
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    cbz x10, Lstmt_skip_outside_loop
    LOAD_ADDR x9, current_loop_start
    ldr x1, [x9]
    cbz x1, Lstmt_skip_no_emit
    // emit jump to loop start/update for runtime-coded loops
    mov x0, #41
    mov x2, #0
    mov x3, #0
    bl _record_operation
Lstmt_skip_no_emit:
    mov x0, #3
    b Lstmt_return

Lstmt_skip_outside_loop:
    LOAD_ADDR x0, msg_loop_control
    bl _report_error_prefix
    LOAD_ADDR x0, kw_skip
    mov x1, #4
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_match:
    bl _parse_match_statement_after_keyword
    cbz x0, Lstmt_match_ok
    cmp x0, #2
    b.eq Lstmt_return
    cmp x0, #3
    b.eq Lstmt_return
    cmp x0, #4
    b.eq Lstmt_return
    b Lstmt_fail
Lstmt_match_ok:
    mov x0, #0
    b Lstmt_return

Lstmt_use:
    bl _parse_use_statement_after_keyword
    cbnz x0, Lstmt_fail
    mov x0, #0
    b Lstmt_return

Lstmt_return_val:
    LOAD_ADDR x9, task_scope_depth
    ldr x10, [x9]
    cbnz x10, Lstmt_scope_control_fail
    bl _skip_whitespace
    bl _peek_char
    // Check for tuple return: return (a, b)
    cmp w0, #'('
    b.ne Lstmt_return_single
    bl _advance_char
    bl _skip_whitespace
    bl _parse_expr_value
    cbz x0, Lstmt_return_single_fail
    mov x19, x1 // first value
    mov x20, x2 // first type
    mov x21, x3 // first length
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lstmt_return_single_fail
    bl _skip_whitespace
    bl _parse_expr_value
    cbz x0, Lstmt_return_single_fail
    mov x22, x1 // second value
    mov x23, x2 // second type
    mov x24, x3 // second length
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_return_single_fail
    // Store tuple return value (two values packed)
    LOAD_ADDR x9, fn_return_value
    str x19, [x9]
    LOAD_ADDR x9, fn_return_length
    str x21, [x9]
    LOAD_ADDR x9, fn_return_extra
    str x22, [x9]
    LOAD_ADDR x9, fn_return_extra_type
    str x23, [x9]
    LOAD_ADDR x9, fn_return_flag
    mov x10, #1
    str x10, [x9]
    bl _consume_optional_semicolon
    mov x0, #4 // special return code: return
    b Lstmt_return

Lstmt_return_single:
    // Check if there's an expression to return
    cmp w0, #'}'
    b.eq Lstmt_return_void
    cmp w0, #0
    b.eq Lstmt_return_void
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x24, x4 // runtime result/source var slot when expression materialized one
    // Store return value
    LOAD_ADDR x9, fn_return_value
    str x1, [x9]
    LOAD_ADDR x9, fn_return_length
    str x3, [x9]
    LOAD_ADDR x9, fn_return_flag
    mov x10, #1
    str x10, [x9]

    // If returning an immediate string literal (type str, no runtime slot),
    // materialize it into a temp slot via op 72 (store_str_lit) so the return
    // path loads a real stack slot instead of the raw data pointer.
    cmp x2, #2
    b.ne Lstmt_return_scalar_mat
    cmn x24, #1
    b.ne Lstmt_return_single_record
    mov x0, x1      // str data ptr
    mov x1, #2      // type str
    mov x2, x3      // len
    bl _record_data_value
    mov x23, x0     // data id
    bl _allocate_temp_var
    mov x24, x0     // temp slot -> becomes the return slot
    mov x0, #72
    mov x1, x24
    mov x2, x23
    bl _record_operation
    b Lstmt_return_single_record

Lstmt_return_scalar_mat:
    // If returning an immediate SCALAR literal with no runtime slot (a bool
    // literal `return true`/`return false`, or byte/int immediate), materialize
    // it into a temp slot via op 1 (store_var). The return op (op 4) treats its
    // argument as a *slot* to load from; without a slot it would load the raw
    // value 1/0 as a stack offset and return garbage. (Int literals already get
    // a slot from Lprimary_number; this covers bool/byte/int-immediate paths.)
    cmn x24, #1
    b.ne Lstmt_return_single_record   // already has a runtime slot
    cmp x2, #1                        // bool
    b.eq Lstmt_return_scalar_do
    cmp x2, #3                        // byte
    b.eq Lstmt_return_scalar_do
    cmp x2, #0                        // int
    b.ne Lstmt_return_single_record
Lstmt_return_scalar_do:
    stp x1, x2, [sp, #-16]!           // save value, type across the calls
    LOAD_ADDR x0, hidden_var_name_storage // valid ptr, zero-length: never matched
    mov x1, #0
    ldr x2, [sp]                      // compile-time value
    mov x3, #0                        // not const
    ldr x4, [sp, #8]                  // type
    mov x5, #0
    bl _define_variable
    mov x24, x4                       // temp slot becomes the return slot
    ldr x2, [sp]                      // reload value as op-1 arg1
    mov x0, #1                        // op 1: store_var (immediate -> slot)
    mov x1, x24
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    add sp, sp, #16

Lstmt_return_single_record:
    // Record return operation (gated: inline method body vs normal function --
    // see _record_return_op). x1 = op4 arg (slot when available); x2 = the true
    // runtime slot (-1 if none) that an inlined return copies into its result.
    cmp x24, #-1
    csel x1, x24, x1, ne  // return runtime result slot when available
    mov x2, x24
    bl _record_return_op
    cbnz x0, Lstmt_fail
    
    bl _consume_optional_semicolon
    mov x0, #4 // special return code: return
    b Lstmt_return

Lstmt_return_single_fail:
    // Fallback to single return parsing
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lstmt_return_void
    cmp w0, #0
    b.eq Lstmt_return_void
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x24, x4 // runtime result/source var slot when expression materialized one
    // Store return value
    LOAD_ADDR x9, fn_return_value
    str x1, [x9]
    LOAD_ADDR x9, fn_return_length
    str x3, [x9]
    LOAD_ADDR x9, fn_return_flag
    mov x10, #1
    str x10, [x9]
    // Record return operation for fallback single-expression parsing too.
    cmp x24, #-1
    csel x1, x24, x1, ne
    mov x2, x24
    bl _record_return_op
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #4 // special return code: return
    b Lstmt_return

Lstmt_return_void:
    LOAD_ADDR x9, fn_return_flag
    mov x10, #1
    str x10, [x9]
    LOAD_ADDR x9, fn_return_value
    str xzr, [x9]
    LOAD_ADDR x9, fn_return_length
    str xzr, [x9]
    
    // Record void return operation (gated: inline method body vs normal)
    mov x1, #-1 // -1 indicates void return
    mov x2, #-1 // no runtime slot to copy for an inlined return
    bl _record_return_op
    cbnz x0, Lstmt_fail
    
    mov x0, #4 // special return code: return
    b Lstmt_return

Lstmt_assign:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'.'
    b.eq Lstmt_member_dispatch
    // Tuple assignment: a, b = expr
    cmp w0, #','
    b.eq Lstmt_tuple_assign
    cmp w0, #'['
    b.eq Lstmt_index_assign
    cmp w0, #'='
    b.eq Lstmt_assign_set
    cmp w0, #'+'
    b.eq Lstmt_assign_plus
    cmp w0, #'-'
    b.eq Lstmt_assign_minus
    cmp w0, #'*'
    b.eq Lstmt_assign_multiply
    cmp w0, #'/'
    b.eq Lstmt_assign_divide
    cmp w0, #'%'
    b.eq Lstmt_assign_mod
    cmp w0, #'('
    b.eq Lstmt_fn_call
    b Lstmt_unknown

Lstmt_member_dispatch:
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_self
    bl _match_cstr_span
    cbnz x0, Lstmt_self_member
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_method_call
    cmp x2, #10
    b.eq Lstmt_object_member
    cmp x2, #11
    b.eq Lstmt_object_member
    cmp x2, #12
    b.eq Lstmt_channel_member
    b Lstmt_method_call

Lstmt_channel_member:
    mov x23, x1                 // channel id
    mov x24, x3                 // payload type
    bl _advance_char
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x2, x0
    mov x3, x1
    mov x0, x23
    mov x1, x24
    bl _parse_channel_method
    cbz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_self_member:
    LOAD_ADDR x9, current_self_instance
    ldr x23, [x9]
    LOAD_ADDR x9, current_self_type
    ldr x24, [x9]
    LOAD_ADDR x9, current_self_meta
    ldr x25, [x9]
    cbz x24, Lstmt_fail
    b Lstmt_object_member_ready

Lstmt_object_member:
    mov x23, x1
    mov x24, x2
    // Blueprint id for dispatch: use object_blueprint_ids[instance] (authoritative at alloc).
    // var_lengths can disagree in nested/spawn-expanded bodies, yielding synth names like "_run".
    LOAD_ADDR x9, object_blueprint_ids
    ldr x25, [x9, x23, lsl #3]
Lstmt_object_member_ready:
    bl _advance_char
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x21, x0
    mov x22, x1
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.eq Lstmt_object_method_call
    cmp w0, #'+'
    b.eq Lstmt_object_field_op_plus
    cmp w0, #'-'
    b.eq Lstmt_object_field_op_minus
    cmp w0, #'*'
    b.eq Lstmt_object_field_op_mul
    cmp w0, #'/'
    b.eq Lstmt_object_field_op_div
    cmp w0, #'%'
    b.eq Lstmt_object_field_op_mod
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    mov x0, x25
    mov x1, x21
    mov x2, x22
    bl _lookup_blueprint_field
    cbz x0, Lstmt_object_field_lookup_fail
    ldp x11, x12, [sp], #16
    ldp x9, x10, [sp], #16
    mov x13, x1
    mov x14, x2
    cmp x10, x14
    b.eq Lstmt_object_field_store
    cmp x14, #27
    b.ne Lstmt_fail
    cmp x10, #7
    b.ne Lstmt_fail
Lstmt_object_field_store:
    mov x16, x23
    lsl x16, x16, #3
    add x16, x16, x13
    LOAD_ADDR x17, object_field_var_idxs
    ldr x16, [x17, x16, lsl #3]
    LOAD_TBL x17, var_values
    str x9, [x17, x16, lsl #3]
    LOAD_TBL x17, var_types
    str x10, [x17, x16, lsl #3]
    LOAD_TBL x17, var_lengths
    str x11, [x17, x16, lsl #3]
    cmn x12, #1
    b.eq Lstmt_object_field_record_imm
    mov x0, #45
    mov x1, x16
    mov x2, x12
    bl _record_operation
    b Lstmt_object_field_done
Lstmt_object_field_record_imm:
    mov x0, x16
    mov x1, x9
    bl _record_store_variable
Lstmt_object_field_done:
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_object_field_lookup_fail:
    add sp, sp, #32
    b Lstmt_fail

Lstmt_object_method_call:
    mov x0, x23
    mov x1, x24
    mov x2, x25
    mov x3, x21
    mov x4, x22
    bl _call_object_method
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

// Compound assignment on an object field: self.field OP= rhs, or self.field ++/--.
// The field is backed by a real variable slot (x16), so we lower to the same
// runtime compound ops (23-32) used for plain variables, computed on that slot.
// Entry: x23=instance id, x25=blueprint id, x21/x22=field name ptr/len. Each op
// handler sets x26=op type (1=add 2=sub 3=mul 4=div 5=mod), then converges on
// _common with the rhs in x9 (imm value) / x12 (slot id, -1 = immediate).
Lstmt_object_field_op_plus:
    bl _advance_char // consume '+'
    bl _peek_char
    cmp w0, #'+'
    b.eq Lstmt_object_field_incr
    mov x26, #1
    b Lstmt_object_field_compound_parse
Lstmt_object_field_incr:
    bl _advance_char // consume second '+'
    mov x26, #1
    mov x9, #1
    mov x12, #-1
    b Lstmt_object_field_compound_common
Lstmt_object_field_op_minus:
    bl _advance_char // consume '-'
    bl _peek_char
    cmp w0, #'-'
    b.eq Lstmt_object_field_decr
    mov x26, #2
    b Lstmt_object_field_compound_parse
Lstmt_object_field_decr:
    bl _advance_char // consume second '-'
    mov x26, #2
    mov x9, #1
    mov x12, #-1
    b Lstmt_object_field_compound_common
Lstmt_object_field_op_mul:
    bl _advance_char // consume '*'
    mov x26, #3
    b Lstmt_object_field_compound_parse
Lstmt_object_field_op_div:
    bl _advance_char // consume '/'
    mov x26, #4
    b Lstmt_object_field_compound_parse
Lstmt_object_field_op_mod:
    bl _advance_char // consume '%'
    mov x26, #5
    b Lstmt_object_field_compound_parse

Lstmt_object_field_compound_parse:
    // consumed the op char; expect '=' then parse the rhs expression.
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x9, x1  // rhs immediate value (valid when slot == -1)
    mov x12, x4 // rhs slot id (-1 = immediate)

Lstmt_object_field_compound_common:
    // Resolve the field's backing variable slot, then apply target = target OP rhs.
    // Save rhs value/slot across the field lookup (x9/x12 are caller-saved).
    stp x9, x12, [sp, #-16]!
    mov x0, x25
    mov x1, x21
    mov x2, x22
    bl _lookup_blueprint_field
    cbz x0, Lstmt_object_field_compound_lookup_fail
    mov x13, x1 // field offset within instance
    ldp x9, x12, [sp], #16
    // backing var idx x16 = object_field_var_idxs[instance*8 + field_offset]
    mov x16, x23
    lsl x16, x16, #3
    add x16, x16, x13
    LOAD_ADDR x17, object_field_var_idxs
    ldr x16, [x17, x16, lsl #3]
    // If rhs came from a slot, load its compile-time value into x9.
    cmn x12, #1
    b.eq Lstmt_object_field_compound_rhs_ready
    LOAD_TBL x17, var_values
    ldr x9, [x17, x12, lsl #3]
Lstmt_object_field_compound_rhs_ready:
    // current field compile-time value -> x10
    LOAD_TBL x17, var_values
    ldr x10, [x17, x16, lsl #3]
    cmp x26, #1
    b.eq Lstmt_ofc_add
    cmp x26, #2
    b.eq Lstmt_ofc_sub
    cmp x26, #3
    b.eq Lstmt_ofc_mul
    cmp x26, #4
    b.eq Lstmt_ofc_div
    cmp x26, #5
    b.eq Lstmt_ofc_mod
    b Lstmt_fail
Lstmt_ofc_add:
    add x11, x10, x9
    b Lstmt_ofc_store
Lstmt_ofc_sub:
    sub x11, x10, x9
    b Lstmt_ofc_store
Lstmt_ofc_mul:
    mul x11, x10, x9
    b Lstmt_ofc_store
Lstmt_ofc_div:
    cbz x9, Lstmt_assign_divide_zero
    udiv x11, x10, x9
    b Lstmt_ofc_store
Lstmt_ofc_mod:
    cbz x9, Lstmt_assign_divide_zero
    udiv x17, x10, x9
    msub x11, x17, x9, x10
Lstmt_ofc_store:
    // store new compile-time value into the field slot
    LOAD_TBL x17, var_values
    str x11, [x17, x16, lsl #3]
    // record the runtime compound op on var slot x16 (target = target OP rhs)
    cmn x12, #1
    b.eq Lstmt_ofc_record_imm
    add x0, x26, #27 // ops 28-32: var OP var-slot
    mov x1, x16
    mov x2, x16
    mov x3, x12
    bl _record_operation3
    b Lstmt_ofc_done
Lstmt_ofc_record_imm:
    add x0, x26, #22 // ops 23-27: var OP immediate
    mov x1, x16
    mov x2, x16
    mov x3, #0
    mov x4, x9
    bl _record_operation4
Lstmt_ofc_done:
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return
Lstmt_object_field_compound_lookup_fail:
    add sp, sp, #16
    b Lstmt_fail

Lstmt_index_assign:
    // Parse target index/key: name[expr] = expr
    LOAD_ADDR x9, stmt_target_name
    str x19, [x9]
    LOAD_ADDR x9, stmt_target_len
    str x20, [x9]
    bl _advance_char // consume '['
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // key/index value
    mov x22, x2 // key/index type
    mov x23, x3 // key/index length
    mov x24, x4 // key/index var id

    bl _skip_whitespace
    mov w0, #']'
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x25, x1 // rhs value
    mov x26, x2 // rhs type
    mov x27, x3 // rhs length
    mov x28, x4 // rhs var id
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16

    // Resolve target variable
    LOAD_ADDR x9, stmt_target_name
    ldr x19, [x9]
    LOAD_ADDR x9, stmt_target_len
    ldr x20, [x9]
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var_assign
    mov x9, x1  // target start index in pool
    mov x10, x2 // target type
    mov x11, x3 // target metadata
    mov x18, x4 // target variable slot id

    // If rhs comes from var/temp, load concrete value+len now.
    cmn x28, #1
    b.eq Lstmt_index_rhs_ready
    LOAD_TBL x12, var_values
    ldr x25, [x12, x28, lsl #3]
    LOAD_TBL x12, var_lengths
    ldr x27, [x12, x28, lsl #3]
Lstmt_index_rhs_ready:

    // list/list? index assignment
    cmp x10, #4
    b.eq Lstmt_index_assign_list
    cmp x10, #20
    b.eq Lstmt_index_assign_list

    // map assignment
    cmp x10, #8
    b.eq Lstmt_index_assign_map
    b Lstmt_type_mismatch

Lstmt_index_assign_list:
    // index must be int
    cmp x22, #0
    b.ne Lstmt_type_mismatch

    // Detect whether the target list is a function PARAMETER (its runtime value
    // is a pool base, so element access must happen at run time). Mirror the
    // read path (Lprimary_list_index): slot in [fn_scope_base, base+param_count).
    mov x16, #0                 // is_param flag
    LOAD_ADDR x12, current_parse_fn_id
    ldr x12, [x12]
    cmn x12, #1
    b.eq Lstmt_ial_param_done
    LOAD_TBL x13, fn_scope_bases
    ldr x13, [x13, x12, lsl #3]
    cmp x18, x13
    b.lt Lstmt_ial_param_done
    LOAD_TBL x14, fn_param_counts
    ldr x14, [x14, x12, lsl #3]
    add x14, x13, x14
    cmp x18, x14
    b.ge Lstmt_ial_param_done
    mov x16, #1                 // target is a list parameter
Lstmt_ial_param_done:

    // Was this local list already runtime-mutated (params are always runtime)?
    mov x17, #0
    cbnz x16, Lstmt_ial_decide
    LOAD_TBL x12, list_base_is_runtime
    ldrb w17, [x12, x9]

Lstmt_ial_decide:
    // Runtime store (op 109) is required when the index is a variable, the
    // target is a parameter, or the list was already runtime-mutated. Otherwise
    // (local list, immediate index, never runtime) fold at compile time so the
    // literal's emitted initial data reflects the write.
    cmn x24, #1
    b.ne Lstmt_ial_runtime      // variable index
    cbnz x16, Lstmt_ial_runtime // parameter target
    cbnz w17, Lstmt_ial_runtime // already runtime-mutated

    // ---- compile-time fold (constant index into a local literal list) ----
    and x12, x11, #0xFFFFFFFF // count
    cmp x21, x12
    b.ge Lstmt_fail
    lsr x13, x11, #32 // element type
    cmp x26, x13
    b.ne Lstmt_type_mismatch
    add x14, x9, x21
    LOAD_TBL x15, list_pool_values
    str x25, [x15, x14, lsl #3]
    LOAD_TBL x15, list_pool_lengths
    str x27, [x15, x14, lsl #3]
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_ial_runtime:
    // Mark a local list base as runtime-mutated so later reads (even with a
    // constant index) resolve against runtime memory instead of the folded
    // literal. (Its element count is already recorded in list_base_counts.)
    cbnz x16, Lstmt_ial_rt_flags
    LOAD_TBL x12, list_base_is_runtime
    mov w13, #1
    strb w13, [x12, x9]

Lstmt_ial_rt_flags:
    // flags: bit1 = immediate index, bit2 = runtime/param base, bit3 = imm rhs
    mov x5, #0
    cmn x24, #1
    b.ne Lstmt_ial_flag_base
    orr x5, x5, #2
Lstmt_ial_flag_base:
    cbz x16, Lstmt_ial_flag_rhs
    orr x5, x5, #4
Lstmt_ial_flag_rhs:
    cmn x28, #1
    b.ne Lstmt_ial_emit
    orr x5, x5, #8

Lstmt_ial_emit:
    // op 109: list_store(arg0=rhs, arg1=index, arg2=base, arg3=flags)
    mov x0, #109
    // arg0 = rhs value (immediate) or slot
    cmn x28, #1
    b.ne Lstmt_ial_a0_slot
    mov x1, x25
    b Lstmt_ial_a1
Lstmt_ial_a0_slot:
    mov x1, x28
Lstmt_ial_a1:
    // arg1 = index value (immediate) or slot
    cmn x24, #1
    b.ne Lstmt_ial_a1_slot
    mov x2, x21
    b Lstmt_ial_a2
Lstmt_ial_a1_slot:
    mov x2, x24
Lstmt_ial_a2:
    // arg2 = pool base (local) or param base slot
    cbz x16, Lstmt_ial_a2_local
    mov x3, x18
    b Lstmt_ial_a3
Lstmt_ial_a2_local:
    mov x3, x9
Lstmt_ial_a3:
    mov x4, x5
    bl _record_operation4
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_index_assign_map:
    // key type + value type
    lsr x12, x11, #40         // key type
    ubfx x13, x11, #32, #8    // value type
    and x14, x11, #0xFFFFFFFF // count

    cmp x22, x12
    b.ne Lstmt_type_mismatch
    cmp x26, x13
    b.ne Lstmt_type_mismatch

    // Runtime dynamic map store path: if key or value comes from a variable slot,
    // emit op 88 and defer key matching/insertion to runtime helper.
    cmn x24, #1
    b.ne Lstmt_index_map_runtime
    cmn x28, #1
    b.ne Lstmt_index_map_runtime

    // If key came from a variable, read actual key value+len.
    cmn x24, #1
    b.eq Lstmt_index_map_key_ready
    LOAD_TBL x15, var_values
    ldr x21, [x15, x24, lsl #3]
    LOAD_TBL x15, var_lengths
    ldr x23, [x15, x24, lsl #3]
Lstmt_index_map_key_ready:

    // Update existing key only.
    mov x15, #0
Lstmt_index_map_loop:
    cmp x15, x14
    b.ge Lstmt_index_map_insert_new
    add x16, x9, x15
    LOAD_TBL x17, map_pool_keys
    ldr x18, [x17, x16, lsl #3]

    cmp x12, #2 // string key?
    b.eq Lstmt_index_map_cmp_str
    cmp x18, x21
    b.eq Lstmt_index_map_store
    b Lstmt_index_map_next

Lstmt_index_map_insert_new:
    // Key not found - insert new key. Grow the map pool on demand instead of
    // failing at a fixed cap. x12 (key type) is caller-saved yet used AFTER this
    // point (the string-key check below), so stash it across the grow call;
    // _snc_grow_map_pool preserves x19-x28 (so the key/val data in x21/x23/x25/x27
    // and var name/len in x19/x20 survive) but NOT x9-x18.
    LOAD_ADDR x17, map_pool_count
    ldr x18, [x17]
    LOAD_ADDR x16, map_pool_capacity
    ldr x16, [x16]
    cmp x18, x16
    b.lt Lstmt_index_map_have_space
    str x12, [sp, #-16]!
    bl _snc_grow_map_pool
    ldr x12, [sp], #16
    LOAD_ADDR x17, map_pool_count
    ldr x18, [x17]
Lstmt_index_map_have_space:
    mov x16, x18 // Use current global count for the new entry

    LOAD_TBL x17, map_pool_keys
    str x21, [x17, x16, lsl #3]
    LOAD_TBL x17, map_pool_key_lengths
    str x23, [x17, x16, lsl #3]

    // Store key pointer for string keys
    cmp x12, #2
    b.ne Lstmt_index_map_insert_skip_ptr
    LOAD_TBL x17, map_pool_key_ptrs
    str x21, [x17, x16, lsl #3]
Lstmt_index_map_insert_skip_ptr:
    LOAD_TBL x17, map_pool_values
    str x25, [x17, x16, lsl #3]
    LOAD_TBL x17, map_pool_lengths
    str x27, [x17, x16, lsl #3]

    LOAD_ADDR x17, map_pool_count
    add x18, x18, #1
    str x18, [x17]

    // Update local variable metadata (count)
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x11, x3 // current metadata
    add x11, x11, #1 // increment count (lower 32 bits)

    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _set_variable_metadata

    b Lstmt_index_map_store_done

Lstmt_index_map_cmp_str:
    LOAD_TBL x17, map_pool_key_lengths
    ldr x0, [x17, x16, lsl #3]
    cmp x0, x23
    b.ne Lstmt_index_map_next
    mov x0, x18
    mov x1, x23
    mov x2, x21
    bl _match_span_span
    cbnz x0, Lstmt_index_map_store

Lstmt_index_map_next:
    add x15, x15, #1
    b Lstmt_index_map_loop

Lstmt_index_map_store:
    LOAD_TBL x17, map_pool_values
    str x25, [x17, x16, lsl #3]
    LOAD_TBL x17, map_pool_lengths
    str x27, [x17, x16, lsl #3]
Lstmt_index_map_store_done:
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_index_map_runtime:
    // Build op 88 payload:
    //   arg0=map base index
    //   arg1=key (slot or immediate value/data-id)
    //   arg2=value (slot or immediate value/data-id)
    //   arg3=packed(key_type,val_type,key_is_imm,val_is_imm)
    //   arg4=key_len (for immediate string keys only, else 0)
    mov x15, x24 // key operand
    mov x17, x28 // value operand
    mov x5, #0   // immediate key length (str only)
    mov x4, x12
    lsl x4, x4, #56
    orr x4, x4, x13, lsl #48

    // Key operand encode
    cmn x24, #1
    b.ne Lstmt_index_map_runtime_key_done
    // immediate key path
    orr x4, x4, #(1 << 47)
    cmp x12, #2
    b.ne Lstmt_index_map_runtime_key_int_imm
    // immediate string key -> materialize data-id
    mov x0, x21
    mov x1, #2
    mov x2, x23
    bl _record_data_value
    mov x15, x0
    mov x5, x23
    b Lstmt_index_map_runtime_key_done
Lstmt_index_map_runtime_key_int_imm:
    mov x15, x21
Lstmt_index_map_runtime_key_done:

    // Value operand encode
    cmn x28, #1
    b.ne Lstmt_index_map_runtime_val_done
    // immediate value path
    orr x4, x4, #(1 << 46)
    cmp x13, #2
    b.ne Lstmt_index_map_runtime_val_imm_non_str
    mov x0, x25
    mov x1, #2
    mov x2, x27
    bl _record_data_value
    mov x17, x0
    b Lstmt_index_map_runtime_val_done
Lstmt_index_map_runtime_val_imm_non_str:
    mov x17, x25
Lstmt_index_map_runtime_val_done:

    mov x0, #88
    mov x1, x9
    mov x2, x15
    mov x3, x17
    bl _record_operation5
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_tuple_assign:

    // x19=name ptr, x20=name len (first var) already set by identifier parse
    bl _advance_char
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x23, x0 // second var name ptr
    mov x24, x1 // second var name len

    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1 // expr value
    mov x22, x2 // expr type
    mov x25, x3 // expr length

    // Store first value (typed)
    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, x25
    bl _set_variable_full
    cbnz x0, Lstmt_fail
    // Emit runtime store for first var
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    cmp x2, #2
    b.eq Lstmt_tuple_first_done
    mov x0, x4
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
Lstmt_tuple_first_done:

    // Store second return value from fn_return_extra (typed)
    LOAD_ADDR x9, fn_return_extra
    ldr x21, [x9]
    LOAD_ADDR x9, fn_return_extra_type
    ldr x22, [x9]
    mov x0, x23
    mov x1, x24
    mov x2, x21
    mov x3, x22
    mov x4, #0
    bl _set_variable_full
    cbnz x0, Lstmt_fail
    // Emit runtime store for second var
    mov x0, x23
    mov x1, x24
    bl _lookup_variable
    cbz x0, Lstmt_fail
    cmp x2, #2
    b.eq Lstmt_tuple_second_done
    mov x0, x4
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
Lstmt_tuple_second_done:

    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_fn_call:
    // x19=name ptr, x20=name len
    mov x0, x19
    mov x1, x20
    bl _call_function
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_method_call:
    bl _advance_char
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x21, x0
    mov x22, x1

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_push
    bl _match_cstr_span
    cbnz x0, Lstmt_method_push

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_pop
    bl _match_cstr_span
    cbnz x0, Lstmt_method_pop

    b Lstmt_fail

Lstmt_method_push:
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var
    mov x9, x1
    mov x10, x2
    mov x11, x3
    cmp x10, #4
    b.ne Lstmt_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x23, x0
    mov x24, x1
    mov x25, x2
    mov x26, x3
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail
    and x12, x11, #0xFFFFFFFF
    LOAD_TBL x13, list_pool_values
    LOAD_TBL x14, list_pool_lengths
    add x27, x12, #1
    and x11, x11, #0xFFFFFFFF00000000
    orr x11, x11, x27
    str x23, [x13, x12, lsl #3]
    str x24, [x14, x12, lsl #3]
    mov x0, x9
    mov x1, x12
    mov x2, x11
    bl _set_variable_full
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_method_pop:
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var
    mov x9, x1
    mov x10, x2
    mov x11, x3
    cmp x10, #4
    b.ne Lstmt_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstmt_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstmt_fail
    and x12, x11, #0xFFFFFFFF
    cmp x12, #0
    b.eq Lstmt_fail
    LOAD_TBL x13, list_pool_values
    ldr x23, [x13, x12, lsl #3]
    LOAD_TBL x14, list_pool_lengths
    lsr x24, x11, #32
    ldr x25, [x14, x12, lsl #3]
    sub x12, x12, #1
    and x11, x11, #0xFFFFFFFF00000000
    orr x11, x11, x12
    mov x0, x9
    mov x1, x12
    mov x2, x11
    bl _set_variable_full
    mov x0, #4
    mov x1, x23
    mov x2, x24
    mov x3, #0
    bl _record_print_value
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_unknown_var:
    LOAD_ADDR x0, msg_unknown_var
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_assign_set:
    bl _advance_char
    // Check for tuple assignment: a, b = expr
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #','
    b.ne Lstmt_assign_single_var
    // Multi-assignment: a, b = expr
    bl _advance_char
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstmt_fail
    mov x23, x0 // second var name ptr
    mov x24, x1 // second var name len
    // Store second var name for later
    sub sp, sp, #16
    str x23, [sp]
    str x24, [sp, #8]
    bl _skip_whitespace
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_assign_multi_restore
    bl _parse_expr_value
    cbz x0, Lstmt_assign_multi_restore
    mov x21, x1 // expr value
    mov x22, x2 // expr type
    mov x25, x3 // expr length
    // Restore second var
    ldr x23, [sp]
    ldr x24, [sp, #8]
    add sp, sp, #16
    // Look up first variable (stored in x19, x20)
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var_assign
    mov x26, x4 // first var index
    // Look up second variable
    mov x0, x23
    mov x1, x24
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var_assign
    mov x27, x4 // second var index
    // Store first return value
    mov x0, x26
    mov x1, x21
    bl _set_variable
    cbnz x0, Lstmt_fail
    // Store second return value from fn_return_extra
    LOAD_ADDR x9, fn_return_extra
    ldr x1, [x9]
    mov x0, x27
    bl _set_variable
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_assign_multi_restore:
    ldr x23, [sp]
    ldr x24, [sp, #8]
    add sp, sp, #16
    b Lstmt_fail

Lstmt_assign_single_var:
    bl _try_parse_runtime_var_bin_expr
    cbnz x0, Lstmt_assign_runtime_expr
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x21, x1  // source value
    mov x22, x2  // source type
    mov x24, x3  // source metadata/length
    mov x28, x4  // source var id (-1 if immediate)
    b Lstmt_assign_store

Lstmt_assign_input:
    mov x21, x1 // prompt ptr
    mov x24, x2 // prompt len
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var_assign
    cmp x2, #2
    b.ne Lstmt_type_mismatch
    mov x23, x4

    mov x0, x19
    mov x1, x20
    mov x2, #0
    mov x3, #2
    mov x4, #0
    bl _set_variable_full
    cbnz x0, Lstmt_fail

    bl _consume_optional_semicolon

    mov x0, #47
    mov x1, x23
    mov x2, x21
    mov x3, x24
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lstmt_fail
    mov x0, #0
    b Lstmt_return

Lstmt_assign_runtime_expr:
    // record runtime form for target = lhs op rhs, while keeping compile-time state updated too
    mov x21, x1
    mov x22, x2
    mov x23, x3
    mov x24, x4
    cbnz x24, Lstmt_assign_runtime_expr_lookup
    cmp x22, #4
    b.eq Lstmt_assign_runtime_expr_check_zero
    cmp x22, #5
    b.ne Lstmt_assign_runtime_expr_lookup
Lstmt_assign_runtime_expr_check_zero:
    cbz x23, Lstmt_assign_divide_zero
Lstmt_assign_runtime_expr_lookup:
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x27, x4

    LOAD_TBL x9, var_values
    ldr x25, [x9, x21, lsl #3]
    mov x26, x23
    cbz x24, Lstmt_assign_runtime_rhs_ready
    ldr x26, [x9, x23, lsl #3]
Lstmt_assign_runtime_rhs_ready:
    cmp x22, #1
    b.eq Lstmt_assign_runtime_eval_add
    cmp x22, #2
    b.eq Lstmt_assign_runtime_eval_sub
    cmp x22, #3
    b.eq Lstmt_assign_runtime_eval_mul
    cmp x22, #4
    b.eq Lstmt_assign_runtime_eval_div
    cmp x22, #5
    b.eq Lstmt_assign_runtime_eval_mod
    b Lstmt_fail

Lstmt_assign_runtime_eval_add:
    add x28, x25, x26
    b Lstmt_assign_runtime_update
Lstmt_assign_runtime_eval_sub:
    sub x28, x25, x26
    b Lstmt_assign_runtime_update
Lstmt_assign_runtime_eval_mul:
    mul x28, x25, x26
    b Lstmt_assign_runtime_update
Lstmt_assign_runtime_eval_div:
    // An immediate zero divisor was rejected before variable lookup. For a
    // runtime RHS, x26 is only the compiler's tracking value and may be zero
    // even though the value produced at runtime is non-zero (for example, a
    // function-call result). ARM64 udiv by zero is defined to return zero, so
    // it is safe to keep tracking without issuing a false compile-time error.
    udiv x28, x25, x26
    b Lstmt_assign_runtime_update
Lstmt_assign_runtime_eval_mod:
    udiv x9, x25, x26
    msub x28, x9, x26, x25

Lstmt_assign_runtime_update:
    // Record runtime op before mutating compiler-side variable state so the
    // original lhs/rhs operands cannot be lost across helper calls.
    sub sp, sp, #16
    str x28, [sp]
    cbz x24, Lstmt_assign_runtime_expr_record_imm
    add x0, x22, #27
    mov x1, x27
    mov x2, x21
    mov x3, x23
    bl _record_operation3
    b Lstmt_assign_runtime_record_done
Lstmt_assign_runtime_expr_record_imm:
    add x0, x22, #22
    mov x1, x27
    mov x2, x21
    mov x3, #0
    mov x4, x23
    bl _record_operation4
Lstmt_assign_runtime_record_done:
    cbnz x0, Lstmt_assign_runtime_record_fail
    ldr x28, [sp]
    add sp, sp, #16
    mov x0, x19
    mov x1, x20
    mov x2, x28
    bl _set_variable
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_assign_runtime_record_fail:
    add sp, sp, #16
    b Lstmt_fail

Lstmt_assign_runtime_fallback:
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x25, x1
    mov x26, x23
    cbz x24, Lstmt_assign_runtime_fallback_rhs_ready
    LOAD_TBL x9, var_values
    ldr x26, [x9, x23, lsl #3]
Lstmt_assign_runtime_fallback_rhs_ready:
    cmp x22, #1
    b.eq Lstmt_assign_rt_add
    cmp x22, #2
    b.eq Lstmt_assign_rt_sub
    cmp x22, #3
    b.eq Lstmt_assign_rt_mul
    cmp x22, #4
    b.eq Lstmt_assign_rt_div
    cmp x22, #5
    b.eq Lstmt_assign_rt_mod
    b Lstmt_fail

Lstmt_assign_rt_add:
    add x21, x25, x26
    b Lstmt_assign_store
Lstmt_assign_rt_sub:
    sub x21, x25, x26
    b Lstmt_assign_store
Lstmt_assign_rt_mul:
    mul x21, x25, x26
    b Lstmt_assign_store
Lstmt_assign_rt_div:
    cbz x26, Lstmt_assign_divide_zero
    udiv x21, x25, x26
    b Lstmt_assign_store
Lstmt_assign_rt_mod:
    cbz x26, Lstmt_assign_divide_zero
    udiv x9, x25, x26
    msub x21, x9, x26, x25
    b Lstmt_assign_store

Lstmt_assign_plus:
    // '+' seen at statement level after an identifier: distinguish 'x++' (increment)
    // from 'x += rhs' (compound add). Consume the first '+', then look ahead one char.
    bl _advance_char // consume first '+'
    bl _peek_char
    cmp w0, #'+'
    b.eq Lstmt_incdec_plus
    mov x21, #1
    b Lstmt_assign_compound_after_op
Lstmt_incdec_plus:
    bl _advance_char // consume second '+'
    mov x21, #1
    b Lstmt_incdec_apply
Lstmt_assign_minus:
    // '-' seen: distinguish 'x--' (decrement) from 'x -= rhs' (compound sub).
    bl _advance_char // consume first '-'
    bl _peek_char
    cmp w0, #'-'
    b.eq Lstmt_incdec_minus
    mov x21, #2
    b Lstmt_assign_compound_after_op
Lstmt_incdec_minus:
    bl _advance_char // consume second '-'
    mov x21, #2
    b Lstmt_incdec_apply

Lstmt_incdec_apply:
    // x21 = 1 (++) or 2 (--). Treat as 'target (+/-)= 1' by reusing the shared
    // compound eval/record/set path with an immediate rhs of 1.
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var_assign
    mov x22, x4 // target idx
    mov x23, x2 // target type
    mov x25, x1 // current value
    mov x26, x3 // scale
    cmp x23, #6
    b.eq Lstmt_type_mismatch // ++/-- on decimal unsupported
    mov x24, #1  // rhs immediate 1
    mov x27, #-1 // immediate (no rhs slot)
    b Lstmt_assign_compound_rhs_ready

Lstmt_assign_add:
    mov x21, #1
    b Lstmt_assign_compound_shared
Lstmt_assign_subtract:
    mov x21, #2
    b Lstmt_assign_compound_shared
Lstmt_assign_multiply:
    mov x21, #3
    b Lstmt_assign_compound_shared
Lstmt_assign_divide:
    mov x21, #4
    b Lstmt_assign_compound_shared
Lstmt_assign_mod:
    mov x21, #5
    b Lstmt_assign_compound_shared

Lstmt_assign_compound_shared:
    // x21 = op type (1=add, 2=sub, 3=mul, 4=div, 5=mod)
    bl _advance_char // consume op
Lstmt_assign_compound_after_op:
    mov w0, #'='
    bl _expect_char
    cbz x0, Lstmt_fail
    
    // Look up target variable
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var_assign
    mov x22, x4 // target_idx
    mov x23, x2 // target_type
    mov x25, x1 // target current value (for compile-time update)
    mov x26, x3 // target scale (if decimal)

    // Parse RHS
    bl _parse_expr_value
    cbz x0, Lstmt_fail
    
    // Check for decimals
    cmp x23, #6
    b.eq Lstmt_assign_compound_decimal
    cmp x2, #6
    b.eq Lstmt_type_mismatch
    mov x27, x4 // rhs slot id (-1 when immediate)
    mov x24, x1 // rhs immediate value, or placeholder until rhs var load
    cmn x27, #1
    b.eq Lstmt_assign_compound_rhs_ready
    LOAD_TBL x9, var_values
    ldr x24, [x9, x27, lsl #3]
Lstmt_assign_compound_rhs_ready:
    cmp x21, #1
    b.eq Lstmt_assign_compound_eval_add
    cmp x21, #2
    b.eq Lstmt_assign_compound_eval_sub
    cmp x21, #3
    b.eq Lstmt_assign_compound_eval_mul
    cmp x21, #4
    b.eq Lstmt_assign_compound_eval_div
    cmp x21, #5
    b.eq Lstmt_assign_compound_eval_mod
    b Lstmt_fail

Lstmt_assign_compound_eval_add:
    add x28, x25, x24
    b Lstmt_assign_compound_record
Lstmt_assign_compound_eval_sub:
    sub x28, x25, x24
    b Lstmt_assign_compound_record
Lstmt_assign_compound_eval_mul:
    mul x28, x25, x24
    b Lstmt_assign_compound_record
Lstmt_assign_compound_eval_div:
    cbz x24, Lstmt_assign_divide_zero
    udiv x28, x25, x24
    b Lstmt_assign_compound_record
Lstmt_assign_compound_eval_mod:
    cbz x24, Lstmt_assign_divide_zero
    udiv x9, x25, x24
    msub x28, x9, x24, x25

Lstmt_assign_compound_record:
    sub sp, sp, #16
    str x28, [sp]
    cmn x27, #1
    b.eq Lstmt_assign_compound_record_imm
    add x0, x21, #27
    mov x1, x22
    mov x2, x22
    mov x3, x27
    bl _record_operation3
    b Lstmt_assign_compound_record_done
Lstmt_assign_compound_record_imm:
    add x0, x21, #22
    mov x1, x22
    mov x2, x22
    mov x3, #0
    mov x4, x24
    bl _record_operation4
Lstmt_assign_compound_record_done:
    cbnz x0, Lstmt_assign_compound_record_fail
    ldr x28, [sp]
    add sp, sp, #16
    mov x0, x19
    mov x1, x20
    mov x2, x28
    bl _set_variable
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_assign_compound_record_fail:
    add sp, sp, #16
    b Lstmt_fail

Lstmt_assign_compound_decimal:
    // lhs_type=x23=6, rhs_type=x2, rhs_val=x1, lhs_val=x25, lhs_scale=x26, rhs_scale=x3, op=x21
    cmp x2, #6
    b.ne Lstmt_type_mismatch
    cmp x3, x26
    b.ne Lstmt_decimal_scale_error
    mov x23, x21
    mov x27, x4
    mov x28, x1
    
    // Dispatch op
    cmp x23, #1
    b.eq Lstmt_assign_dec_add
    cmp x23, #2
    b.eq Lstmt_assign_dec_sub
    cmp x23, #3
    b.eq Lstmt_assign_dec_mul
    cmp x23, #4
    b.eq Lstmt_assign_dec_div
    // mod not supported for dec
    b Lstmt_fail

Lstmt_assign_dec_add:
    add x21, x25, x1
    mov x24, x26
    b Lstmt_assign_dec_record
Lstmt_assign_dec_sub:
    sub x21, x25, x1
    mov x24, x26
    b Lstmt_assign_dec_record
Lstmt_assign_dec_mul:
    mul x21, x25, x1
    mov x0, x26
    bl _pow10_u64
    udiv x21, x21, x0
    mov x24, x26
    b Lstmt_assign_dec_record
Lstmt_assign_dec_div:
    cbz x1, Lstmt_assign_divide_zero
    mov x0, x26
    bl _pow10_u64
    mul x21, x25, x0
    sdiv x21, x21, x1
    mov x24, x26
    b Lstmt_assign_dec_record

Lstmt_assign_dec_record:
    sub sp, sp, #16
    str x21, [sp]
    cmn x27, #1
    b.eq Lstmt_assign_dec_record_imm
    add x0, x23, #51
    mov x1, x22
    mov x2, x26
    mov x3, x27
    bl _record_operation3
    b Lstmt_assign_dec_record_done
Lstmt_assign_dec_record_imm:
    add x0, x23, #47
    mov x1, x22
    mov x2, x26
    mov x3, #0
    mov x4, x28
    bl _record_operation4
Lstmt_assign_dec_record_done:
    cbnz x0, Lstmt_assign_compound_record_fail
    ldr x21, [sp]
    add sp, sp, #16
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl _set_variable
    cbnz x0, Lstmt_fail
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_assign_divide_zero:
    LOAD_ADDR x0, msg_divide_zero
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_assign_store:
    mov x25, x21
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x23, x2
    mov x26, x3
    cmp x23, #16
    b.ge Lstmt_assign_check_nullable_target
    cmp x23, #6
    b.eq Lstmt_assign_check_decimal_target
    cmp x23, #4
    b.eq Lstmt_assign_check_list_target
    cmp x23, #2
    b.eq Lstmt_assign_do_store_full
    cmp x23, #3
    b.eq Lstmt_assign_check_byte_target
    cmp x22, x23
    b.ne Lstmt_type_mismatch
    cmp x23, #10
    b.eq Lstmt_assign_check_object_meta
    cmp x23, #11
    b.eq Lstmt_assign_check_object_meta
    b Lstmt_assign_do_store

Lstmt_assign_check_object_meta:
    cmp x24, x26
    b.ne Lstmt_type_mismatch
    b Lstmt_assign_do_store

Lstmt_assign_check_list_target:
    cmp x22, #4
    b.ne Lstmt_type_mismatch
    lsr x9, x24, #32 // source element type
    lsr x10, x26, #32 // target element type
    cmp x9, x10
    b.ne Lstmt_type_mismatch
    b Lstmt_assign_do_store_full

Lstmt_assign_check_byte_target:
    cmp x22, #0
    b.eq Lstmt_assign_do_store
    cmp x22, #3
    b.ne Lstmt_type_mismatch
    b Lstmt_assign_do_store

Lstmt_assign_check_decimal_target:
    cmp x22, #6
    b.ne Lstmt_type_mismatch
    cmp x24, x26
    b.ne Lstmt_decimal_scale_error
    b Lstmt_assign_do_store

Lstmt_assign_check_nullable_target:
    cmp x22, #7
    b.eq Lstmt_assign_do_store_full
    cmp x22, x23
    b.eq Lstmt_assign_do_store_full
    sub x9, x23, #16
    cmp x9, #6
    b.eq Lstmt_assign_check_nullable_decimal
    cmp x22, x9
    b.ne Lstmt_type_mismatch
    b Lstmt_assign_do_store_full

Lstmt_assign_check_nullable_decimal:
    cmp x22, #6
    b.ne Lstmt_type_mismatch
    cmp x24, x26
    b.ne Lstmt_decimal_scale_error
    b Lstmt_assign_do_store_full

Lstmt_assign_do_store:
    mov x0, x19
    mov x1, x20
    cmp x22, #4
    b.eq Lstmt_assign_do_store_full
    cmp x22, #5
    b.eq Lstmt_assign_do_store_full
    mov x2, x25
    bl _set_variable
    cbnz x0, Lstmt_fail
    mov x21, x25
    mov x2, x21
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    cmp x2, #2
    b.eq Lstmt_assign_store_done
    // Check if source is a variable (x28 != -1)
    cmn x28, #1
    b.eq Lstmt_assign_do_store_imm
    // Source is a variable: emit op 45 (store_var_var) for runtime copy
    mov x0, #45
    mov x1, x4     // dest var idx
    mov x2, x28    // src var idx
    bl _record_operation
    cbnz x0, Lstmt_fail
    b Lstmt_assign_store_done
Lstmt_assign_do_store_imm:
    mov x0, x4
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail
Lstmt_assign_store_done:
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstmt_return

Lstmt_assign_do_store_full:
    // x19,x20 = target name
    // x23 = target type
    // x24 = source metadata/length
    // x25 = source value (immediate)
    // x26 = target length/scale
    // x28 = source var_id (temp var id or -1 if immediate)

    // For string type, handle runtime store separately
    cmp x23, #2
    b.eq Lstmt_assign_str_full
    cmp x23, #18
    b.eq Lstmt_assign_str_full

    mov x0, x19
    mov x1, x20
    mov x2, x25    // source value
    mov x3, x23    // target type
    mov x4, x26    // target length/scale
    bl _set_variable_full
    cbnz x0, Lstmt_fail

    mov x9, x23
    cmp x9, #16
    b.lt Lstmt_assign_do_store_full_base_ready
    sub x9, x9, #16
Lstmt_assign_do_store_full_base_ready:
    cmp x9, #4
    b.eq Lstmt_assign_store_done
    cmp x9, #5
    b.eq Lstmt_assign_store_done
    cmp x9, #6
    b.eq Lstmt_assign_store_done
    // Simple type: use _record_store_variable
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x0, x4
    mov x1, x25
    bl _record_store_variable
    cbnz x0, Lstmt_fail
    b Lstmt_assign_store_done

Lstmt_assign_str_full:
    // String assignment: set compile-time value then emit runtime store
    // For immediate: x25=ptr, x24=length
    // For runtime (concat): x28=temp var id
    cmn x28, #1
    b.eq Lstmt_assign_str_full_imm
    // Runtime: just emit store_var_var (op 45)
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x26, x4    // dest var idx
    mov x0, #45
    mov x1, x26
    mov x2, x28    // src = temp var id
    bl _record_operation
    b Lstmt_assign_store_done

Lstmt_assign_str_full_imm:
    // Immediate string: set compile-time value
    // x25 = string ptr, x24 = length (saved from Lstmt_assign_single_var)
    mov x0, x19
    mov x1, x20
    mov x2, x25    // string ptr
    mov x3, x23    // type str/str?
    mov x4, x24    // length
    bl _set_variable_full
    cbnz x0, Lstmt_fail
    // Emit op 72 to store string literal address
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x26, x4    // dest var idx
    // Use x25 (saved ptr) and x24 (saved length)
    mov x0, x25    // ptr
    mov x1, #2
    mov x2, x24    // length
    bl _record_data_value
    mov x21, x0    // data id
    mov x0, #72
    mov x1, x26
    mov x2, x21
    mov x3, #0
    bl _record_operation3
    b Lstmt_assign_store_done

Lstmt_unknown_var_assign:
    LOAD_ADDR x0, msg_unknown_var
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_unknown:
    LOAD_ADDR x0, msg_unknown_stmt
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_type_mismatch:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    // Debug: print types
    // mov x0, x22
    // bl _print_int_debug
    // mov x0, x24
    // bl _print_int_debug
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_decimal_scale_error:
    LOAD_ADDR x0, msg_decimal_scale
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_need_keyword:
    // Check if this is a map literal starting with {
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'{'
    b.eq Lstmt_map_literal
    
    // Check if this is a list literal starting with [
    cmp w0, #'['
    b.eq Lstmt_list_literal
    
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_scope_control_fail:
    LOAD_ADDR x0, msg_scope_control
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

Lstmt_map_literal:
    // Parse map literal as an expression statement
    mov x0, #-1
    bl _parse_map_literal_value
    cbz x0, Lstmt_fail
    mov x0, #0
    b Lstmt_return

Lstmt_list_literal:
    // Parse list literal as an expression statement
    mov x0, #-1
    bl _parse_list_literal_value
    cbz x0, Lstmt_fail
    mov x0, #0
    b Lstmt_return

Lstmt_need_name:
    LOAD_ADDR x0, msg_expected_name
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    b Lstmt_return

// Generic failure: print location only (_report_error_prefix already emits "line N: ")
Lstmt_fail:
    LOAD_ADDR x0, msg_empty
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5

Lstmt_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_try_parse_runtime_var_bin_expr:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    bl _parse_identifier
    cbz x0, Lrt_expr_restore_fail
    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    bl _lookup_variable
    cbz x0, Lrt_expr_restore_fail
    mov x23, x4
    mov x25, x2 // type
    cmp x2, #6
    b.eq Lrt_expr_restore_fail

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'+'
    b.eq Lrt_expr_add
    
    cmp x25, #2 // str
    b.eq Lrt_expr_restore_fail
    
    cmp w0, #'-'
    b.eq Lrt_expr_sub
    cmp w0, #'*'
    b.eq Lrt_expr_mul
    cmp w0, #'/'
    b.eq Lrt_expr_div
    cmp w0, #'%'
    b.eq Lrt_expr_mod
    b Lrt_expr_restore_fail

Lrt_expr_add:
    mov x24, #1
    b Lrt_expr_take_op
Lrt_expr_sub:
    mov x24, #2
    b Lrt_expr_take_op
Lrt_expr_mul:
    mov x24, #3
    b Lrt_expr_take_op
Lrt_expr_div:
    mov x24, #4
    b Lrt_expr_take_op
Lrt_expr_mod:
    mov x24, #5

Lrt_expr_take_op:
    bl _advance_char
    bl _skip_whitespace
    bl _parse_number
    cbz x0, Lrt_expr_try_var_rhs
    mov x0, #1
    mov x2, x24
    mov x3, x1
    mov x4, #0
    mov x1, x23
    b Lrt_expr_finish_check

Lrt_expr_try_var_rhs:
    bl _parse_identifier
    cbz x0, Lrt_expr_restore_fail
    mov x25, x0
    mov x26, x1
    mov x0, x25
    mov x1, x26
    bl _lookup_variable
    cbz x0, Lrt_expr_restore_fail
    cmp x2, #2
    b.eq Lrt_expr_restore_fail
    mov x0, #1
    mov x2, x24
    mov x3, x4
    mov x4, #1
    mov x1, x23
    b Lrt_expr_finish_check

Lrt_expr_finish_check:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'+'
    b.eq Lrt_expr_restore_fail
    cmp w0, #'-'
    b.eq Lrt_expr_restore_fail
    cmp w0, #'*'
    b.eq Lrt_expr_restore_fail
    cmp w0, #'/'
    b.eq Lrt_expr_restore_fail
    cmp w0, #'%'
    b.eq Lrt_expr_restore_fail
    b Lrt_expr_return

Lrt_expr_restore_fail:
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    mov x0, #0

Lrt_expr_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_if_statement_after_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    mov x24, #0 // whether op34 (else label placement) was emitted

    // Parentheses around the condition are OPTIONAL: `if (c) {` and `if c {`
    // both parse. Peek for '(' and remember whether we consumed it, so we only
    // require the matching ')' when an opening '(' was actually present.
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lif_cond_no_paren
    bl _advance_char // consume '('
    mov x22, #1
    b Lif_cond_parse
Lif_cond_no_paren:
    mov x22, #0
Lif_cond_parse:
    bl _parse_condition_value
    cbz x0, Lif_fail
    mov x19, x1 // temp_var_id

    cbz x22, Lif_cond_no_close
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lif_fail
Lif_cond_no_close:

    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lif_fail

    // allocate labels
    bl _get_next_label
    mov x20, x0 // else_label
    bl _get_next_label
    mov x21, x0 // end_label

    // emit op 33 (if start)
    mov x0, #33
    mov x1, x19
    mov x2, x20
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    LOAD_ADDR x9, fn_exec_depth
    ldr x23, [x9]
    cbz x23, Lif_body_loop
    LOAD_TBL x9, var_values
    ldr x23, [x9, x19, lsl #3] // compile-time condition value
    cbz x23, Lif_skip_then_body

Lif_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lif_body_done
    cbz w0, Lif_unclosed
    bl _parse_statement
    cbz x0, Lif_body_loop
    cmp x0, #2
    b.eq Lif_body_loop
    cmp x0, #3
    b.eq Lif_body_loop
    cmp x0, #4
    b.eq Lif_body_return_stmt
    b Lif_fail

Lif_body_return_stmt:
    // Compile mode (fn_exec_depth == 0): a `return` inside the block is just
    // a recorded op -- keep parsing the rest of the block so the code after
    // the if statement is still compiled. Interpret mode must propagate.
    LOAD_ADDR x9, fn_exec_depth
    ldr x9, [x9]
    cbz x9, Lif_body_loop
    b Lif_return_propagate

Lif_return_propagate:
    cbnz x24, Lif_return_emit_end_only
    // Return happened in the then-body before else/end labels were emitted.
    mov x0, #34
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    mov x24, #1
Lif_return_emit_end_only:
    mov x0, #35
    mov x1, x21
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    b Lif_return

Lif_skip_then_body:
    bl _skip_block_contents
    cbnz x0, Lif_fail
    b Lif_after_then

Lif_body_done:
    bl _advance_char

Lif_after_then:

    // emit op 34 (if else label)
    mov x0, #34
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    mov x24, #1

    // check for else
    LOAD_ADDR x9, fn_exec_depth
    ldr x9, [x9]
    cbz x9, Lif_exec_else_path
    cbz x23, Lif_exec_else_path
    bl _skip_whitespace
    LOAD_ADDR x0, kw_else
    bl _consume_keyword
    cbz x0, Lif_no_else

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'{'
    b.ne Lif_skip_else_if
    bl _advance_char

    bl _skip_block_contents
    cbnz x0, Lif_fail
    b Lif_no_else

Lif_skip_else_if:
    LOAD_ADDR x0, kw_if
    bl _consume_keyword
    cbz x0, Lif_fail
    bl _skip_if_statement_after_keyword
    cbnz x0, Lif_fail
    b Lif_no_else

Lif_exec_else_path:
    bl _skip_whitespace
    LOAD_ADDR x0, kw_else
    bl _consume_keyword
    cbz x0, Lif_no_else

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'{'
    b.ne Lif_check_else_if
    bl _advance_char

Lif_else_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lif_else_done
    cbz w0, Lif_unclosed
    bl _parse_statement
    cbz x0, Lif_else_loop
    cmp x0, #2
    b.eq Lif_else_loop
    cmp x0, #3
    b.eq Lif_else_loop
    cmp x0, #4
    b.eq Lif_else_return_stmt
    b Lif_fail

Lif_else_return_stmt:
    // Same compile-mode rule as the then-body (see Lif_body_return_stmt).
    LOAD_ADDR x9, fn_exec_depth
    ldr x9, [x9]
    cbz x9, Lif_else_loop
    b Lif_return_propagate

Lif_check_else_if:
    LOAD_ADDR x0, kw_if
    bl _consume_keyword
    cbz x0, Lif_fail
    bl _parse_if_statement_after_keyword
    cbz x0, Lif_else_done
    cmp x0, #2
    b.eq Lif_return
    cmp x0, #3
    b.eq Lif_return
    cmp x0, #4
    b.eq Lif_return_propagate
    b Lif_fail

Lif_else_done:
    bl _peek_char
    cmp w0, #'}'
    b.ne Lif_no_else
    bl _advance_char

Lif_no_else:
    // emit op 35 (if end label)
    mov x0, #35
    mov x1, x21
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4

    mov x0, #0
    b Lif_return

Lif_unclosed:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    b Lif_fail

Lif_fail:
    mov x0, #1
    b Lif_return

Lif_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_skip_if_statement_after_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lskip_if_fail
    bl _skip_paren_group
    cbnz x0, Lskip_if_fail

    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lskip_if_fail
    bl _skip_block_contents
    cbnz x0, Lskip_if_fail

    bl _consume_optional_else
    cbz x0, Lskip_if_done
    LOAD_ADDR x0, kw_if
    bl _consume_keyword
    cbz x0, Lskip_if_else_block
    bl _skip_if_statement_after_keyword
    b Lskip_if_return

Lskip_if_else_block:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lskip_if_fail
    bl _skip_block_contents
    cbnz x0, Lskip_if_fail

Lskip_if_done:
    mov x0, #0
    b Lskip_if_return

Lskip_if_fail:
    mov x0, #1

Lskip_if_return:
    ldp x29, x30, [sp], #16
    ret

_parse_while_statement_after_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    mov x24, #0

    // push old loop labels
    LOAD_ADDR x9, current_loop_start
    ldr x19, [x9]
    LOAD_ADDR x9, current_loop_end
    ldr x20, [x9]

    // allocate labels
    bl _get_next_label
    mov x21, x0 // start_label
    bl _get_next_label
    mov x22, x0 // end_label

    // set new loop labels
    LOAD_ADDR x9, current_loop_start
    str x21, [x9]
    LOAD_ADDR x9, current_loop_end
    str x22, [x9]

    // emit op 36 (while start label)
    mov x0, #36
    mov x1, x21
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4

    // Parentheses around the condition are OPTIONAL: `while (c) {` and `while c {`
    // both parse. The open '(' and its close ')' are each consumed only if present
    // (a bare '{' terminates the condition either way).
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lwhile_cond_parse
    bl _advance_char // consume '('
Lwhile_cond_parse:
    bl _parse_condition_value
    cbz x0, Lwhile_fail
    mov x23, x1 // temp_var_id

    // emit op 37 (while condition)
    mov x0, #37
    mov x1, x23
    mov x2, x22
    mov x3, #0
    mov x4, #0
    bl _record_operation4

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.ne Lwhile_cond_no_close
    bl _advance_char // consume ')'
Lwhile_cond_no_close:

    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lwhile_fail
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    LOAD_ADDR x9, current_blueprint_parse
    str x23, [x9]
    mov x24, #1

Lwhile_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lwhile_body_done
    cbz w0, Lwhile_unclosed
    bl _parse_statement
    cbz x0, Lwhile_body_loop
    cmp x0, #2
    b.eq Lwhile_body_loop
    cmp x0, #3
    b.eq Lwhile_body_loop
    cmp x0, #4
    b.eq Lwhile_body_return_stmt
    b Lwhile_fail

Lwhile_body_return_stmt:
    // Compile mode: `return` inside a while body is a recorded op; keep
    // parsing so the loop is closed properly (op 38) and code after the
    // loop still compiles. Interpret mode propagates the return.
    LOAD_ADDR x9, fn_exec_depth
    ldr x9, [x9]
    cbz x9, Lwhile_body_loop
    b Lwhile_return_propagate

Lwhile_return_propagate:
    cbz x24, Lwhile_return_restore_only
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    mov x24, #0
Lwhile_return_restore_only:
    LOAD_ADDR x9, current_loop_start
    str x19, [x9]
    LOAD_ADDR x9, current_loop_end
    str x20, [x9]
    b Lwhile_return

Lwhile_body_done:
    bl _advance_char
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    mov x24, #0

    // emit op 38 (while end label)
    mov x0, #38
    mov x1, x21
    mov x2, x22
    mov x3, #0
    mov x4, #0
    bl _record_operation4

    // pop old loop labels
    LOAD_ADDR x9, current_loop_start
    str x19, [x9]
    LOAD_ADDR x9, current_loop_end
    str x20, [x9]

    mov x0, #0
    b Lwhile_return

Lwhile_unclosed:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    b Lwhile_fail

Lwhile_fail:
    cbz x24, Lwhile_fail_restore_only
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    mov x24, #0
Lwhile_fail_restore_only:
    LOAD_ADDR x9, current_loop_start
    str x19, [x9]
    LOAD_ADDR x9, current_loop_end
    str x20, [x9]
    mov x0, #1
    b Lwhile_return

Lwhile_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// ========================================================
// for (init, condition, update) { body }
// Runtime codegen via labels/branches (no compile-time unrolling).
// ========================================================
_parse_for_statement_after_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    sub sp, sp, #48

    LOAD_ADDR x9, current_loop_start
    ldr x10, [x9]
    LOAD_ADDR x9, current_loop_end
    ldr x11, [x9]
    stp x10, x11, [sp]
    str xzr, [sp, #16]

    // Block scoping: save the current variable floor and count, then start a
    // fresh block at the current count. The duplicate-variable check is bounded
    // by var_scope_base, so a loop counter (or a body-local) may now shadow an
    // outer variable of the same name, and two sibling loops may each declare
    // the same counter name. On exit (Lfor_return) both are restored, popping
    // the loop's block-local variables and freeing their slots for reuse.
    LOAD_ADDR x9, var_scope_base
    ldr x10, [x9]
    str x10, [sp, #32]
    LOAD_ADDR x9, var_count
    ldr x11, [x9]
    str x11, [sp, #40]
    LOAD_ADDR x9, var_scope_base
    str x11, [x9]

    // Parentheses around the for-header are OPTIONAL: `for (…) {` and `for … {`
    // both parse. Consume the '(' only if present; the header still terminates
    // at '{' (and each form only requires a matching ')' when '(' was consumed).
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lfor_no_open_paren
    bl _advance_char // consume '('
Lfor_no_open_paren:

    // Probe for `for (item in iterable)` first.
    LOAD_ADDR x9, cursor_pos
    ldr x26, [x9]
    LOAD_ADDR x9, current_line
    ldr x27, [x9]

    bl _parse_identifier
    cbz x0, Lfor_counted_restore
    mov x24, x0
    mov x25, x1

    LOAD_ADDR x0, kw_in
    bl _consume_keyword
    cbz x0, Lfor_counted_restore
    b Lfor_in_setup

Lfor_counted_restore:
    LOAD_ADDR x9, cursor_pos
    str x26, [x9]
    LOAD_ADDR x9, current_line
    str x27, [x9]

    // Parse init once (e.g. int i = 0)
    bl _parse_statement
    cbnz x0, Lfor_counted_fail

    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lfor_counted_fail

    // Save condition cursor
    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    // Allocate labels: start, end, update
    bl _get_next_label
    mov x21, x0
    bl _get_next_label
    mov x22, x0
    bl _get_next_label
    mov x23, x0

    // For `skip`, jump to update label. `stop` still jumps to end label.
    LOAD_ADDR x9, current_loop_start
    str x23, [x9]
    LOAD_ADDR x9, current_loop_end
    str x22, [x9]

    // op 36: start label
    mov x0, #36
    mov x1, x21
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lfor_counted_fail

    // Parse condition once from saved cursor
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]

    bl _parse_condition_value
    cbz x0, Lfor_counted_fail
    mov x26, x1 // condition temp var id

    // op 37: branch to end when condition is false
    mov x0, #37
    mov x1, x26
    mov x2, x22
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lfor_counted_fail

    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lfor_counted_fail

    // Save update cursor for replay after body
    LOAD_ADDR x9, cursor_pos
    ldr x24, [x9]
    LOAD_ADDR x9, current_line
    ldr x25, [x9]

Lfor_skip_update_text:
    bl _peek_char
    cbz w0, Lfor_counted_fail
    cmp w0, #')'
    b.eq Lfor_update_end
    // Paren-less header: the update text ends at '{' (no closing ')').
    cmp w0, #'{'
    b.eq Lfor_update_at_brace
    bl _advance_char
    b Lfor_skip_update_text

Lfor_update_end:
    bl _advance_char // consume ')'
Lfor_update_at_brace:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lfor_counted_fail
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    mov x10, #1
    str x10, [sp, #16]

Lfor_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lfor_body_done
    cbz w0, Lfor_unclosed
    bl _parse_statement
    cbz x0, Lfor_body_loop
    cmp x0, #2
    b.eq Lfor_body_loop
    cmp x0, #3
    b.eq Lfor_body_loop
    cmp x0, #4
    b.eq Lfor_body_return_stmt
    b Lfor_counted_fail

Lfor_body_return_stmt:
    // Compile mode: keep parsing the for body after a `return` (the op is
    // already recorded); interpret mode propagates the return upward.
    LOAD_ADDR x9, fn_exec_depth
    ldr x9, [x9]
    cbz x9, Lfor_body_loop
    b Lfor_counted_return_propagate

Lfor_body_done:
    bl _advance_char
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    str xzr, [sp, #16]

    // Save cursor after body to restore it later
    adrp x9, cursor_pos@PAGE
    add x9, x9, cursor_pos@PAGEOFF
    ldr x27, [x9]
    adrp x9, current_line@PAGE
    add x9, x9, current_line@PAGEOFF
    ldr x28, [x9]

    // op 46: update label (target of `skip`)
    mov x0, #46
    mov x1, x23
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lfor_counted_fail

    // Parse update once from saved header cursor
    LOAD_ADDR x9, cursor_pos
    str x24, [x9]
    LOAD_ADDR x9, current_line
    str x25, [x9]

    bl _parse_statement
    cbnz x0, Lfor_counted_fail

    // Restore cursor to after the body so main parser continues correctly
    adrp x9, cursor_pos@PAGE
    add x9, x9, cursor_pos@PAGEOFF
    str x27, [x9]
    adrp x9, current_line@PAGE
    add x9, x9, current_line@PAGEOFF
    str x28, [x9]

    // op 38: branch back to start and place end label
    mov x0, #38
    mov x1, x21
    mov x2, x22
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lfor_counted_fail

    // Restore previous loop labels
    ldp x10, x11, [sp]
    LOAD_ADDR x9, current_loop_start
    str x10, [x9]
    LOAD_ADDR x9, current_loop_end
    str x11, [x9]

    mov x0, #0
    b Lfor_return

Lfor_unclosed:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
     mov x2, #2
     bl _write_buffer_fd
     bl _write_newline_stderr
     b Lfor_counted_fail
 
 Lfor_counted_return_propagate:
     // Restore previous loop labels before propagating return
     ldr x12, [sp, #16]
     cbz x12, Lfor_counted_return_restore_labels
     LOAD_ADDR x9, loop_context_depth
     ldr x10, [x9]
     sub x10, x10, #1
     str x10, [x9]
     str xzr, [sp, #16]
Lfor_counted_return_restore_labels:
     ldp x10, x11, [sp]
     LOAD_ADDR x9, current_loop_start
     str x10, [x9]
     LOAD_ADDR x9, current_loop_end
     str x11, [x9]
     mov x0, #4
     b Lfor_return
 
 Lfor_skip_block_done:
     bl _skip_block_contents
     cbnz x0, Lfor_fail
     ldr x12, [sp, #16]
     cbz x12, Lfor_skip_block_done_no_depth
     LOAD_ADDR x9, loop_context_depth
     ldr x10, [x9]
     sub x10, x10, #1
     str x10, [x9]
     str xzr, [sp, #16]
Lfor_skip_block_done_no_depth:
     ldp x10, x11, [sp]
     LOAD_ADDR x9, current_loop_start
     str x10, [x9]
     LOAD_ADDR x9, current_loop_end
     str x11, [x9]
     mov x0, #0
     b Lfor_return
 
Lfor_counted_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    // Restore previous loop labels on counted-loop failure
    ldr x12, [sp, #16]
    cbz x12, Lfor_counted_fail_restore_labels
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    str xzr, [sp, #16]
Lfor_counted_fail_restore_labels:
    ldp x10, x11, [sp]
    LOAD_ADDR x9, current_loop_start
    str x10, [x9]
    LOAD_ADDR x9, current_loop_end
    str x11, [x9]
    mov x0, #1
    b Lfor_return

Lfor_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    ldr x12, [sp, #16]
    cbz x12, Lfor_fail_restore_labels
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    str xzr, [sp, #16]
Lfor_fail_restore_labels:
    ldp x10, x11, [sp]
    LOAD_ADDR x9, current_loop_start
    str x10, [x9]
    LOAD_ADDR x9, current_loop_end
    str x11, [x9]
    mov x0, #1

Lfor_return:
    // Restore the enclosing block's variable floor and pop this loop's
    // block-local variables (preserve x0 = return status).
    ldr x10, [sp, #32]
    LOAD_ADDR x9, var_scope_base
    str x10, [x9]
    ldr x11, [sp, #40]
    LOAD_ADDR x9, var_count
    str x11, [x9]
    add sp, sp, #48
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lfor_in_setup:
    bl _parse_for_iterable_value
    cbz x0, Lfor_fail
    mov x19, x1 // list start index (compile-time base)
    mov x20, x2 // list count (compile-time; unknown for a list parameter)
    mov x21, x3 // element type
    str x4, [sp, #24] // source var slot (or -1) -> lets us detect a list parameter

    // Close ')' is optional (matches the optional open paren for the for-header).
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.ne Lfor_in_no_close
    bl _advance_char // consume ')'
Lfor_in_no_close:

    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lfor_fail
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]
    mov x10, #1
    str x10, [sp, #16]

    // Capture the body-start cursor (used by the str compile-time unroll path,
    // which re-parses the body once per element).
    LOAD_ADDR x9, cursor_pos
    ldr x22, [x9]
    LOAD_ADDR x9, current_line
    ldr x23, [x9]

    // STRING element lists normally keep the proven compile-time unroll:
    // list_pool_values holds a str element's data-value id (not a runtime
    // pointer), so op 80 can't load it as a runtime string. EXCEPTION: a
    // runtime-count str list (a str.split result) stores real runtime char*
    // pointers in the pool and its count is only known at run time, so it must
    // use the runtime loop (op 80 str path loads the pointer directly).
    // Integer/scalar lists always use the runtime loop below.
    cmp x21, #2
    b.ne Lfor_in_use_runtime_loop
    LOAD_TBL x9, list_base_is_runtime
    ldrb w9, [x9, x19]
    cbz w9, Lfor_in_iteration

Lfor_in_use_runtime_loop:
    // Emit a real runtime loop (no compile-time unrolling). This works for
    // both local lists (base immediate, count constant) and list PARAMETERS
    // (base = the param's runtime slot, count computed at runtime via op 81).
    // The loop var name is in x24/x25 (captured at the for-statement entry).
    mov x0, x19             // compile-time base index
    mov x1, x20             // compile-time count
    mov x2, x21             // element type
    ldr x3, [sp, #24]       // source var slot (or -1)
    mov x4, x24             // loop var name ptr
    mov x5, x25             // loop var name len
    bl _emit_for_in_runtime_loop
    cbz x0, Lfor_fail
    b Lfor_in_done

    // ---- STRING element compile-time unroll (preserves pre-existing behavior) ----
Lfor_in_iteration:
    cbz x20, Lfor_skip_block_done
    bl _get_next_label
    LOAD_ADDR x9, current_loop_end
    str x0, [x9]
    mov x26, #0

Lfor_in_str_iter:
    cmp x26, x20
    b.ge Lfor_in_done

    bl _get_next_label
    LOAD_ADDR x9, current_loop_start
    str x0, [x9]

    add x9, x19, x26
    LOAD_TBL x10, list_pool_values
    ldr x27, [x10, x9, lsl #3]
    LOAD_TBL x10, list_pool_lengths
    ldr x28, [x10, x9, lsl #3]

    mov x0, x24
    mov x1, x25
    bl _lookup_variable
    cbz x0, Lfor_in_str_define

    mov x0, x24
    mov x1, x25
    mov x2, x27
    mov x3, x21
    mov x4, x28
    bl _set_variable_full
    cbnz x0, Lfor_fail
    b Lfor_in_str_body_reset

Lfor_in_str_define:
    mov x0, x24
    mov x1, x25
    mov x2, x27
    mov x3, #0
    mov x4, x21
    mov x5, x28
    bl _define_variable
    cbnz x0, Lfor_fail

Lfor_in_str_body_reset:
    LOAD_ADDR x9, cursor_pos
    str x22, [x9]
    LOAD_ADDR x9, current_line
    str x23, [x9]

Lfor_in_str_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lfor_in_str_body_done
    cbz w0, Lwhile_unclosed
    bl _parse_statement
    cbz x0, Lfor_in_str_body_loop
    cmp x0, #2
    b.eq Lfor_in_str_stop
    cmp x0, #3
    b.eq Lfor_in_str_skip_rest
    b Lfor_fail

Lfor_in_str_body_done:
    bl _advance_char
    mov x0, #35
    LOAD_ADDR x9, current_loop_start
    ldr x1, [x9]
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    add x26, x26, #1
    b Lfor_in_str_iter

Lfor_in_str_skip_rest:
    bl _skip_block_contents
    cbnz x0, Lfor_fail
    mov x0, #35
    LOAD_ADDR x9, current_loop_start
    ldr x1, [x9]
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    add x26, x26, #1
    b Lfor_in_str_iter

Lfor_in_str_stop:
    bl _skip_block_contents
    cbnz x0, Lfor_fail
    ldr x12, [sp, #16]
    cbz x12, Lfor_in_str_stop_no_depth
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    str xzr, [sp, #16]
Lfor_in_str_stop_no_depth:
    mov x0, #35
    LOAD_ADDR x9, current_loop_end
    ldr x1, [x9]
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    ldp x10, x11, [sp]
    LOAD_ADDR x9, current_loop_start
    str x10, [x9]
    LOAD_ADDR x9, current_loop_end
    str x11, [x9]
    mov x0, #0
    b Lfor_return

Lfor_in_done:
    // The runtime loop is fully emitted by _emit_for_in_runtime_loop (which
    // also placed the end label via op 38 and restored the outer loop labels).
    // Here we only close the loop-context depth and restore the saved labels
    // for consistency with the counted-for exit paths, then return 0.
    ldr x12, [sp, #16]
    cbz x12, Lfor_in_done_no_depth
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    str xzr, [sp, #16]
Lfor_in_done_no_depth:
    ldp x10, x11, [sp]
    LOAD_ADDR x9, current_loop_start
    str x10, [x9]
    LOAD_ADDR x9, current_loop_end
    str x11, [x9]
    mov x0, #0
    b Lfor_return

_parse_for_iterable_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    bl _parse_expr_value
    cbz x0, Lfor_iterable_fail
    mov x23, x1 // list start index
    mov x24, x2 // list type
    mov x22, x3 // list metadata
    mov x21, x4 // source var slot when the iterable is a plain variable (or -1)

    cmp x24, #4 // list<T>
    b.eq Lfor_iterable_list_unified
    cmp x24, #20 // list<T>?
    b.eq Lfor_iterable_nullable_list_unified
    b Lfor_iterable_fail

Lfor_iterable_nullable_list_unified:
    cmp x23, #-1
    b.eq Lfor_iterable_fail

Lfor_iterable_list_unified:
    mov x0, #1
    mov x1, x23 // start index
    and x2, x22, #0xFFFFFFFF // count
    lsr x3, x22, #32 // element type
    mov x4, x21 // source var slot (or -1) so the caller can detect a list parameter
    b Lfor_iterable_return

Lfor_iterable_fail:
    LOAD_ADDR x0, msg_expected_list
    bl _report_error_prefix
    mov x0, #0
    mov x4, #-1

Lfor_iterable_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// ========================================================
// _emit_for_in_runtime_loop
//   x0 = compile-time base index (pool base for a local list/literal)
//   x1 = compile-time count (valid for a local list; ignored for a param)
//   x2 = element type
//   x3 = source var slot of the iterable, or -1 (used to detect a list param)
//   x4 = loop variable name ptr
//   x5 = loop variable name len
// Emits a REAL runtime loop over the list (no compile-time unrolling), so it
// works for local lists (base immediate, count constant) AND for list
// PARAMETERS (base = the param's runtime slot value, count read at runtime via
// op 81), and large loops no longer overflow the fixed op table. The body is
// parsed exactly once; `stop`/`skip`/`return` inside it are handled by
// _parse_statement via the current_loop_start/current_loop_end globals, exactly
// like the counted-for loop. Cursor must sit just after the opening '{'; on
// return the closing '}' has been consumed. Returns x0 = 1 ok, 0 on failure.
// Stack scratch (sub sp,#64):
//   [0]  saved current_loop_start   [8]  saved current_loop_end
//   [16] base_ct                    [24] count_ct
//   [32] elemtype                   [40] srcslot
//   [48] cnt_slot                   [56] is_param, then reused for cond slot
// ========================================================
_emit_for_in_runtime_loop:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    sub sp, sp, #64

    str x0, [sp, #16]           // base_ct
    str x1, [sp, #24]           // count_ct
    str x2, [sp, #32]           // elemtype
    str x3, [sp, #40]           // srcslot
    mov x24, x4                 // loop var name ptr (kept until define/lookup)
    mov x25, x5                 // loop var name len

    // Save outer loop labels so nested loops restore correctly.
    LOAD_ADDR x9, current_loop_start
    ldr x10, [x9]
    str x10, [sp, #0]
    LOAD_ADDR x9, current_loop_end
    ldr x10, [x9]
    str x10, [sp, #8]

    // -------- is the iterable a list PARAMETER? store 0/1 at sp[56] --------
    mov x12, #0
    ldr x28, [sp, #40]          // srcslot
    cmn x28, #1
    b.eq Lforr_param_stored     // -1 -> not a variable -> local
    LOAD_ADDR x9, current_parse_fn_id
    ldr x9, [x9]
    cmn x9, #1
    b.eq Lforr_param_stored     // not inside a function
    LOAD_TBL x10, fn_scope_bases
    ldr x10, [x10, x9, lsl #3]
    cmp x28, x10
    b.lt Lforr_param_stored     // slot < scope base -> not a param
    LOAD_TBL x11, fn_param_counts
    ldr x11, [x11, x9, lsl #3]
    add x11, x10, x11
    cmp x28, x11
    b.ge Lforr_param_stored     // slot >= scope base + param count -> not a param
    mov x12, #1                 // it's a list parameter
Lforr_param_stored:
    str x12, [sp, #56]          // is_param

    // -------- define / look up loop variable, get its slot (x23) ----------
    mov x0, x24
    mov x1, x25
    bl _lookup_variable
    cbnz x0, Lforr_loopvar_found
    mov x0, x24
    mov x1, x25
    mov x2, #0                  // initial value (overwritten each iteration)
    mov x3, #0                  // not const
    ldr x4, [sp, #32]           // type = element type
    mov x5, #0                  // length
    bl _define_variable
    cbnz x0, Lforr_fail
    mov x0, x24
    mov x1, x25
    bl _lookup_variable
    cbz x0, Lforr_fail
Lforr_loopvar_found:
    mov x23, x4                 // loop var slot

    // -------- counter slot idx = 0 (materialized as a runtime store) ------
    mov x0, #0
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lforr_fail
    mov x19, x0                 // idx_slot (held across body)

    // -------- count slot: param OR runtime-count local -> runtime op 81;
    // plain local -> compile-time constant. -------------------------------
    ldr x9, [sp, #56]           // is_param
    cbnz x9, Lforr_cnt_param
    // Runtime-count local list (e.g. a str.split result held in a local)?
    ldr x0, [sp, #16]           // base_ct
    LOAD_TBL x9, list_base_is_runtime
    ldrb w9, [x9, x0]
    cbnz w9, Lforr_cnt_rtlocal
    ldr x0, [sp, #24]           // compile-time count
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lforr_fail
    str x0, [sp, #48]           // cnt_slot
    b Lforr_cnt_done
Lforr_cnt_rtlocal:
    // Base is an immediate; materialize it into a slot, then op 81 reads
    // list_base_counts[base] at run time. Element access still uses the
    // immediate base (is_param stays 0 below).
    ldr x0, [sp, #16]           // base_ct
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lforr_fail
    str x0, [sp, #48]           // stash base slot temporarily in cnt_slot
    bl _allocate_temp_var
    ldr x2, [sp, #48]           // arg1 = base slot
    str x0, [sp, #48]           // cnt_slot (dest)
    mov x1, x0                  // arg0 = dest
    mov x0, #81                 // op list_length_runtime
    bl _record_operation
    cbnz x0, Lforr_fail
    b Lforr_cnt_done
Lforr_cnt_param:
    bl _allocate_temp_var
    str x0, [sp, #48]           // cnt_slot (dest)
    mov x1, x0                  // arg0 = dest
    ldr x2, [sp, #40]           // arg1 = source list-parameter slot
    mov x0, #81                 // op list_length_runtime
    bl _record_operation
    cbnz x0, Lforr_fail
Lforr_cnt_done:

    // -------- base operand (x27) and op-80 flags (x28) --------------------
    // index is always a var (idx_slot) -> bit1 stays clear.
    // base: local = immediate (bit2 clear); param = var slot (bit2 set).
    // element type str -> bit0 set (codegen loads a string pointer).
    ldr x9, [sp, #32]           // elemtype
    cmp x9, #2
    cset x28, eq                // bit0 = (elemtype == str)
    ldr x9, [sp, #56]           // is_param
    cbnz x9, Lforr_base_param
    ldr x27, [sp, #16]          // base_ct (immediate)
    b Lforr_base_done
Lforr_base_param:
    ldr x27, [sp, #40]          // param slot (runtime base)
    orr x28, x28, #4            // bit2 = base is a var
Lforr_base_done:

    // -------- allocate labels: start (x20), end (x21), cont (x22) ---------
    bl _get_next_label
    mov x20, x0
    bl _get_next_label
    mov x21, x0
    bl _get_next_label
    mov x22, x0

    // skip -> cont label (still runs the increment); stop -> end label.
    LOAD_ADDR x9, current_loop_start
    str x22, [x9]
    LOAD_ADDR x9, current_loop_end
    str x21, [x9]

    // op 36: start label
    mov x0, #36
    mov x1, x20
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lforr_fail

    // op 40: cond = (idx < cnt) into a fresh temp (stored at sp[56])
    bl _allocate_temp_var
    str x0, [sp, #56]           // cond slot
    mov x4, x0                  // dest = cond slot
    mov x0, #40
    mov x1, x19                 // left = idx
    ldr x2, [sp, #48]           // right = cnt
    mov x3, #3                  // operator: less-than
    bl _record_operation4
    cbnz x0, Lforr_fail

    // op 37: branch to end when the condition is false
    mov x0, #37
    ldr x1, [sp, #56]           // cond slot
    mov x2, x21                 // end label
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lforr_fail

    // op 80: loop_var = list[base + idx]
    mov x0, #80
    mov x1, x23                 // dest = loop var slot
    mov x2, x19                 // index = idx slot (var; bit1 clear)
    mov x3, x27                 // base (immediate for local, slot for param)
    mov x4, x28                 // flags
    bl _record_operation4
    cbnz x0, Lforr_fail

    // -------- parse the loop body exactly once --------
Lforr_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lforr_body_done
    cbz w0, Lforr_unclosed
    bl _parse_statement
    cbz x0, Lforr_body_loop
    cmp x0, #2                  // stop: its jump op is already recorded
    b.eq Lforr_body_loop
    cmp x0, #3                  // skip: its jump op is already recorded
    b.eq Lforr_body_loop
    cmp x0, #4                  // return: op already recorded (compile mode)
    b.eq Lforr_body_loop
    b Lforr_fail

Lforr_body_done:
    bl _advance_char

    // op 46: continue label (target of `skip`)
    mov x0, #46
    mov x1, x22
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lforr_fail

    // op 104: idx = idx + 1
    mov x0, #104
    mov x1, x19
    mov x2, #0
    bl _record_operation
    cbnz x0, Lforr_fail

    // op 38: branch back to start and place the end label
    mov x0, #38
    mov x1, x20
    mov x2, x21
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lforr_fail

    mov x0, #1                  // success
    b Lforr_restore

Lforr_unclosed:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
Lforr_fail:
    mov x0, #0
Lforr_restore:
    // Restore the outer loop labels (nested-loop safe).
    ldr x10, [sp, #0]
    LOAD_ADDR x9, current_loop_start
    str x10, [x9]
    ldr x10, [sp, #8]
    LOAD_ADDR x9, current_loop_end
    str x10, [x9]
    add sp, sp, #64
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_list_literal_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x19, x0 // expected element type, -1 to infer

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'['
    b.ne Llist_fail
    bl _advance_char

    LOAD_ADDR x9, list_pool_count
    ldr x20, [x9]
    mov x21, #0
    mov x22, x19

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #']'
    b.ne Llist_loop
    bl _advance_char
    cmp x22, #-1
    b.eq Llist_fail
    mov x0, #1
    mov x1, x20
    mov x2, x21
    mov x3, x22
    b Llist_return

Llist_loop:
    bl _parse_expr_value
    cbz x0, Llist_fail
    mov x23, x1
    mov x24, x2
    mov x25, x3

    cmp x22, #-1
    b.ne Llist_check_type
    cmp x24, #0 // int
    b.eq Llist_set_type
    cmp x24, #1 // bool
    b.eq Llist_set_type
    cmp x24, #2 // str
    b.eq Llist_set_type
    cmp x24, #3 // byte
    b.eq Llist_set_type
    cmp x24, #6 // dec
    b.eq Llist_set_type
    b Llist_fail

Llist_set_type:
    mov x22, x24
    b Llist_store

Llist_check_type:
    cmp x24, x22
    b.ne Llist_fail

Llist_store:
    // Grow the list pool on demand if it is full before pushing this element.
    // x20 (base) and x21 (local elem counter) are callee-saved and survive
    // _snc_grow_list_pool (which saves x19-x24 and leaves x25-x28 untouched), as
    // do x22 (elem type), x23 (value) and x25 (length). After the check the code
    // below RE-LOADS list_pool_count and the pool base via LOAD_TBL so it always
    // sees the current (possibly moved) buffer -- do NOT cache a base across grow.
    LOAD_ADDR x9, list_pool_count
    ldr x10, [x9]
    LOAD_ADDR x11, list_pool_capacity
    ldr x11, [x11]
    cmp x10, x11
    b.lt Llist_store_have_space
    bl _snc_grow_list_pool
Llist_store_have_space:
    LOAD_ADDR x9, list_pool_count
    ldr x10, [x9]
    LOAD_TBL x11, list_pool_values
    str x23, [x11, x10, lsl #3]
    LOAD_TBL x11, list_pool_lengths
    str x25, [x11, x10, lsl #3]
    add x10, x10, #1
    str x10, [x9]
    add x21, x21, #1

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #','
    b.eq Llist_take_comma
    cmp w0, #']'
    b.eq Llist_done
    b Llist_fail

Llist_take_comma:
    bl _advance_char
    b Llist_loop

Llist_done:
    bl _advance_char
    // Record this list's element count at its pool BASE index so that a
    // runtime .length() on a list PARAMETER can read list_base_counts[base]
    // (the param carries the pool base as its runtime value). x20=base,
    // x21=count.
    LOAD_TBL x9, list_base_counts
    str x21, [x9, x20, lsl #3]
    mov x0, #1
    mov x1, x20 // list start index
    mov x2, #4 // unified list type ID
    // bit-pack: element type (x22) in upper 32, count (x21) in lower 32
    lsl x3, x22, #32
    orr x3, x3, x21
    b Llist_return

Llist_fail:
    mov x0, #0

Llist_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_map_literal_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    // Expected metadata in x0 if any, else -1 to infer
    mov x19, x0 

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'{'
    b.ne Lmap_fail
    bl _advance_char

    LOAD_ADDR x9, map_pool_count
    ldr x20, [x9]
    mov x21, #0 // count
    
    // x22 will hold metadata (key_type << 32 | val_type)
    mov x22, x19

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lmap_done_empty

Lmap_loop:
    bl _parse_expr_value
    cbz x0, Lmap_fail
    mov x23, x1 // key value
    mov x24, x2 // key type
    mov x25, x3 // key length

    bl _skip_whitespace
    mov w0, #':'
    bl _expect_char
    cbz x0, Lmap_fail

    bl _parse_expr_value
    cbz x0, Lmap_fail
    mov x26, x1 // val value
    mov x27, x2 // val type
    mov x28, x3 // val length

    // Type inference/checking
    cmp x22, #-1
    b.eq Lmap_set_types
    // Check key type
    lsr x9, x22, #32
    cmp x24, x9
    b.ne Lmap_fail
    // Check val type
    and x9, x22, #0xFFFFFFFF
    cmp x27, x9
    b.ne Lmap_fail
    b Lmap_store

Lmap_set_types:
    lsl x22, x24, #32
    orr x22, x22, x27

Lmap_store:
    // Grow the map pool on demand if it is full before storing this entry. The
    // grow routine saves x19-x24 and never touches x25-x28, so the live base/
    // count/metadata (x20-x22) and key/val data (x23-x28) all survive. The code
    // below RE-LOADS map_pool_count and the pool base via LOAD_TBL.
    LOAD_ADDR x9, map_pool_count
    ldr x10, [x9]
    LOAD_ADDR x11, map_pool_capacity
    ldr x11, [x11]
    cmp x10, x11
    b.lt Lmap_store_have_space
    bl _snc_grow_map_pool
Lmap_store_have_space:
    LOAD_ADDR x9, map_pool_count
    ldr x10, [x9]
    LOAD_TBL x11, map_pool_keys
    str x23, [x11, x10, lsl #3]
    LOAD_TBL x11, map_pool_key_lengths
    str x25, [x11, x10, lsl #3]
    LOAD_TBL x11, map_pool_values
    str x26, [x11, x10, lsl #3]
    LOAD_TBL x11, map_pool_lengths
    str x28, [x11, x10, lsl #3] 
    
    add x10, x10, #1
    str x10, [x9]
    add x21, x21, #1

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #','
    b.eq Lmap_take_comma
    cmp w0, #'}'
    b.eq Lmap_done
    b Lmap_fail

Lmap_take_comma:
    bl _advance_char
    b Lmap_loop

Lmap_done_empty:
    // If empty map and no inference, we might need a way to represent it.
    // For now, fail if no inference.
    cmp x22, #-1
    b.eq Lmap_fail

Lmap_done:
    bl _advance_char
    mov x0, #1
    mov x1, x20 // start index
    mov x2, #8 // unified map type ID
    // Pack: key_type (8 bits), val_type (8 bits), count (32 bits)
    // Actually let's just use: (key_type << 40) | (val_type << 32) | count
    lsr x9, x22, #32 // key type
    and x10, x22, #0xFFFFFFFF // val type
    lsl x9, x9, #40
    lsl x10, x10, #32
    orr x3, x9, x10
    orr x3, x3, x21 // count
    b Lmap_return

Lmap_fail:
    mov x0, #0

Lmap_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// Parse a channel method after its name has already been consumed.
// x0=channel id, x1=payload type, x2=method ptr, x3=method len.
// Returns the standard expression tuple (x0=1, x1=value, x2=type,
// x3=metadata, x4=runtime slot), or x0=0 on error.
_parse_channel_method:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    mov x19, x0                 // channel id
    mov x20, x1                 // payload type
    mov x21, x2                 // method name
    mov x22, x3

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_send
    bl _match_cstr_span
    cbnz x0, Lchannel_method_send
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_receive
    bl _match_cstr_span
    cbnz x0, Lchannel_method_receive
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_close
    bl _match_cstr_span
    cbnz x0, Lchannel_method_close
    b Lchannel_method_fail

Lchannel_method_send:
    mov w0, #'('
    bl _expect_char
    cbz x0, Lchannel_method_fail
    bl _parse_expr_value
    cbz x0, Lchannel_method_fail
    mov x23, x1                 // compile-time value
    mov x24, x2                 // actual type
    mov x25, x3                 // string length/metadata
    mov x26, x4                 // source runtime slot
    cmp x24, x20
    b.ne Lchannel_method_type_error
    mov w0, #')'
    bl _expect_char
    cbz x0, Lchannel_method_fail
    cmn x26, #1
    b.ne Lchannel_method_send_record

    cmp x20, #2
    b.eq Lchannel_method_materialize_string
    mov x0, x23
    bl _expr_materialize_ct_int
    mov x26, x0
    cmn x26, #1
    b.eq Lchannel_method_fail
    b Lchannel_method_send_record

Lchannel_method_materialize_string:
    mov x0, x23
    mov x1, #2
    mov x2, x25
    bl _record_data_value
    mov x27, x0                 // emitted string data id
    bl _allocate_temp_var
    mov x26, x0
    mov x0, #72                 // store string literal into temp slot
    mov x1, x26
    mov x2, x27
    mov x3, #0
    bl _record_operation3
    cbnz x0, Lchannel_method_fail

Lchannel_method_send_record:
    bl _allocate_temp_var
    mov x27, x0                 // bool result slot
    mov x0, #119
    mov x1, x27
    mov x2, x19
    mov x3, x26
    bl _record_operation3
    cbnz x0, Lchannel_method_fail
    mov x0, #1
    mov x1, #1                  // optimistic tracking value
    mov x2, #1                  // bool result
    mov x3, #0
    mov x4, x27
    b Lchannel_method_return

Lchannel_method_receive:
    mov w0, #'('
    bl _expect_char
    cbz x0, Lchannel_method_fail
    mov w0, #')'
    bl _expect_char
    cbz x0, Lchannel_method_fail
    bl _allocate_temp_var
    mov x27, x0
    mov x0, #120
    mov x1, x27
    mov x2, x19
    bl _record_operation
    cbnz x0, Lchannel_method_fail
    mov x0, #1
    mov x1, #0
    mov x2, x20                 // payload type
    mov x3, #0
    mov x4, x27
    b Lchannel_method_return

Lchannel_method_close:
    mov w0, #'('
    bl _expect_char
    cbz x0, Lchannel_method_fail
    mov w0, #')'
    bl _expect_char
    cbz x0, Lchannel_method_fail
    bl _allocate_temp_var
    mov x27, x0
    mov x0, #121
    mov x1, x27
    mov x2, x19
    bl _record_operation
    cbnz x0, Lchannel_method_fail
    mov x0, #1
    mov x1, #1
    mov x2, #1                  // bool result
    mov x3, #0
    mov x4, x27
    b Lchannel_method_return

Lchannel_method_type_error:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    bl _write_newline_stderr
Lchannel_method_fail:
    mov x0, #0
Lchannel_method_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global _parse_use_statement_after_keyword
_parse_use_statement_after_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Luse_fail
    
    mov x19, x0  // module name start
    mov x20, x1  // initial module name len
    mov x21, x0  // track current end position
    add x21, x21, x1
    LOAD_ADDR x9, current_line
    ldr x24, [x9] // line containing the final module-path component

Luse_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'.'
    b.ne Luse_done
    bl _advance_char
    
    bl _parse_identifier
    cbz x0, Luse_fail
    
    // Update total length: from x19 to current end
    add x22, x0, x1  // end of new identifier
    sub x20, x22, x19  // total length from start
    mov x21, x22  // update current end
    LOAD_ADDR x9, current_line
    ldr x24, [x9]
    b Luse_loop

Luse_done:
    // Load first so every function has module ownership metadata available to
    // the visibility filter. Module loading saves/restores this source cursor.
    mov x0, x19
    mov x1, x20
    bl _load_module
    cbnz x0, Luse_load_error

    mov x0, x19
    mov x1, x20
    bl _find_module
    cmn x0, #1
    b.eq Luse_load_error
    mov x23, x0                 // loaded module id

    // _skip_whitespace in the dotted-path loop may already have crossed the
    // newline. A modifier is valid only on the module path's original line.
    LOAD_ADDR x9, current_line
    ldr x9, [x9]
    cmp x9, x24
    b.ne Luse_regular

    LOAD_ADDR x9, cursor_pos
    ldr x27, [x9]               // restore point if next token is not a modifier
    bl _parse_identifier
    cbz x0, Luse_regular
    mov x25, x0
    mov x26, x1
    mov x0, x25
    mov x1, x26
    LOAD_ADDR x2, kw_only
    bl _match_cstr_span
    cbnz x0, Luse_selective_only
    mov x0, x25
    mov x1, x26
    LOAD_ADDR x2, kw_except
    bl _match_cstr_span
    cbnz x0, Luse_selective_except

    LOAD_ADDR x9, cursor_pos
    str x27, [x9]

Luse_regular:
    mov x0, x23
    mov x1, #1
    bl _set_module_import_visibility
    b Luse_success

Luse_selective_only:
    mov x28, #1                 // selected names become visible
    mov x0, x23
    mov x1, #0                  // hide the module first
    bl _set_module_import_visibility
    b Luse_selector_loop

Luse_selective_except:
    mov x28, #0                 // selected names become hidden
    mov x0, x23
    mov x1, #1                  // expose the module first
    bl _set_module_import_visibility

Luse_selector_loop:
    // Skip horizontal whitespace only; selectors never continue on a later
    // line. Commas are optional, so both `only a, b` and `only a b` work.
    bl _peek_char
    cmp w0, #' '
    b.eq Luse_selector_take_space
    cmp w0, #'\t'
    b.eq Luse_selector_take_space
    cmp w0, #'\r'
    b.eq Luse_selector_take_space
    b Luse_selector_ready
Luse_selector_take_space:
    bl _advance_char
    b Luse_selector_loop

Luse_selector_ready:
    LOAD_ADDR x9, current_line
    ldr x9, [x9]
    cmp x9, x24
    b.ne Luse_success
    bl _peek_char
    cmp w0, #','
    b.ne Luse_selector_name
    bl _advance_char
    b Luse_selector_loop

Luse_selector_name:
    cmp w0, #'\n'
    b.eq Luse_success
    cmp w0, #';'
    b.eq Luse_success
    cbz w0, Luse_success
    bl _parse_identifier
    cbz x0, Luse_fail
    // _parse_identifier returns ptr in x0 and len in x1.
    mov x2, x1
    mov x1, x0
    mov x0, x23
    mov x3, x28
    bl _set_module_named_visibility
    cbz x0, Luse_fail
    b Luse_selector_loop

Luse_success:
    bl _consume_optional_semicolon
    mov x0, #0
    b Luse_return

Luse_load_error:
    LOAD_ADDR x0, msg_module_load_error
    bl _report_error_prefix
    mov x0, #1
    b Luse_return

Luse_fail:
    LOAD_ADDR x0, msg_expected_name
    bl _report_error_prefix
    mov x0, #1
Luse_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// x0=module id, x1=visibility. Apply to every function owned by the module.
_set_module_import_visibility:
    LOAD_ADDR x9, fn_count
    ldr x10, [x9]
    mov x11, #0
    LOAD_TBL x12, fn_module_ids
    LOAD_TBL x13, fn_import_visible
Lset_module_visibility_loop:
    cmp x11, x10
    b.ge Lset_module_visibility_done
    ldr x14, [x12, x11, lsl #3]
    cmp x14, x0
    b.ne Lset_module_visibility_next
    str x1, [x13, x11, lsl #3]
Lset_module_visibility_next:
    add x11, x11, #1
    b Lset_module_visibility_loop
Lset_module_visibility_done:
    ret

// x0=module id, x1=name ptr, x2=name len, x3=visibility -> x0=found.
_set_module_named_visibility:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    LOAD_ADDR x9, fn_count
    ldr x23, [x9]
    mov x24, #0
Lset_module_named_loop:
    cmp x24, x23
    b.ge Lset_module_named_not_found
    LOAD_TBL x9, fn_module_ids
    ldr x10, [x9, x24, lsl #3]
    cmp x10, x19
    b.ne Lset_module_named_next
    LOAD_TBL x9, fn_name_lens
    ldr x10, [x9, x24, lsl #3]
    cmp x10, x21
    b.ne Lset_module_named_next
    LOAD_TBL x9, fn_name_ptrs
    ldr x2, [x9, x24, lsl #3]
    mov x0, x20
    mov x1, x21
    bl _match_span_span
    cbz x0, Lset_module_named_next
    LOAD_TBL x9, fn_import_visible
    str x22, [x9, x24, lsl #3]
    mov x0, #1
    b Lset_module_named_return
Lset_module_named_next:
    add x24, x24, #1
    b Lset_module_named_loop
Lset_module_named_not_found:
    mov x0, #0
Lset_module_named_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_match_statement_after_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lmatch_fail

    bl _parse_match_case_value
    cbz x0, Lmatch_fail
    mov x19, x1
    mov x20, x2
    mov x21, x3

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lmatch_fail
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lmatch_fail

    mov x22, #0 // matched already?

Lmatch_case_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lmatch_done
    cbz w0, Lmatch_unclosed

    LOAD_ADDR x0, kw_default
    bl _consume_keyword
    cbnz x0, Lmatch_default

    bl _parse_match_case_value
    cbz x0, Lmatch_fail
    mov x23, x1
    mov x24, x2
    mov x25, x3

    mov x26, #0
    cmp x20, #2
    b.eq Lmatch_case_str
    cmp x24, #2
    b.eq Lmatch_case_value_checked
    cmp x19, x23
    cset x26, eq
    b Lmatch_case_value_checked

Lmatch_case_str:
    cmp x24, #2
    b.ne Lmatch_case_value_checked
    cmp x21, x25
    b.ne Lmatch_case_value_checked
    mov x0, x19
    mov x1, x21
    mov x2, x23
    bl _match_span_span
    mov x26, x0

Lmatch_case_value_checked:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lmatch_fail

    cbnz x22, Lmatch_skip_case
    cbz x26, Lmatch_skip_case
    mov x22, #1

Lmatch_exec_case_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lmatch_exec_case_done
    cbz w0, Lmatch_unclosed
    bl _parse_statement
    cbz x0, Lmatch_exec_case_loop
    cmp x0, #2
    b.eq Lmatch_return_propagate
    cmp x0, #3
    b.eq Lmatch_return_propagate
    cmp x0, #4
    b.eq Lmatch_return_propagate
    b Lmatch_fail

Lmatch_exec_case_done:
    bl _advance_char
    b Lmatch_case_loop

Lmatch_skip_case:
    bl _skip_block_contents
    cbnz x0, Lmatch_fail
    b Lmatch_case_loop

Lmatch_default:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lmatch_fail
    cbnz x22, Lmatch_skip_default
    mov x22, #1

Lmatch_exec_default_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lmatch_exec_default_done
    cbz w0, Lmatch_unclosed
    bl _parse_statement
    cbz x0, Lmatch_exec_default_loop
    cmp x0, #2
    b.eq Lmatch_return_propagate
    cmp x0, #3
    b.eq Lmatch_return_propagate
    cmp x0, #4
    b.eq Lmatch_return_propagate
    b Lmatch_fail

Lmatch_exec_default_done:
    bl _advance_char
    b Lmatch_case_loop

Lmatch_skip_default:
    bl _skip_block_contents
    cbnz x0, Lmatch_fail
    b Lmatch_case_loop

Lmatch_done:
    bl _advance_char
    mov x0, #0
    b Lmatch_return

Lmatch_unclosed:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr

Lmatch_return_propagate:
    // x0 already contains the control-flow code we need to bubble upward.
    b Lmatch_return

Lmatch_fail:
    mov x0, #1

Lmatch_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_match_case_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'"'
    b.eq Lmatch_case_string
    bl _parse_expr_value
    cbz x0, Lmatch_case_fail
    ldp x29, x30, [sp], #16
    ret

Lmatch_case_string:
    bl _parse_string_literal
    cbz x0, Lmatch_case_fail
    mov x3, x2
    mov x2, #2
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret

Lmatch_case_fail:
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

_skip_paren_group:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, #1

Lskip_paren_loop:
    bl _peek_char
    cbz w0, Lskip_paren_fail
    cmp w0, #'('
    b.eq Lskip_paren_open
    cmp w0, #')'
    b.eq Lskip_paren_close
    bl _advance_char
    b Lskip_paren_loop

Lskip_paren_open:
    bl _advance_char
    add x19, x19, #1
    b Lskip_paren_loop

Lskip_paren_close:
    bl _advance_char
    sub x19, x19, #1
    cbnz x19, Lskip_paren_loop
    mov x0, #0
    b Lskip_paren_return

Lskip_paren_fail:
    mov x0, #1

Lskip_paren_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _parse_expr_value: the value-context expression entry point. It parses a
// full additive expression (via _parse_addsub_value) and then, if a single
// relational operator follows, lowers "L <cmp> R" into a runtime 0/1 boolean
// temp -- the exact same lowering _parse_condition_atom uses (ops 39/40).
// This makes comparisons usable as FIRST-CLASS VALUES:
//     print(a > b)        bool b = a > b        return a > b
// not only inside if/while/for conditions. A lone '=' (assignment) is never
// consumed here: '==' / '!=' are recognised only via a two-char lookahead.
// Conditions are unaffected because _parse_condition_atom parses its operands
// through _parse_addsub_value directly and keeps handling comparisons itself.
_parse_expr_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!   // preserve caller live state (see addsub note)

    bl _parse_addsub_value
    cbz x0, Lcmpv_fail
    mov x19, x4    // left slot (-1 if immediate)
    mov x20, x1    // left value (immediate / compile-time)
    mov x25, x2    // left type (kept for the passthrough case)
    mov x26, x3    // left meta (kept for the passthrough case)

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'='
    b.eq Lcmpv_maybe_eq
    cmp w0, #'!'
    b.eq Lcmpv_maybe_ne
    cmp w0, #'>'
    b.eq Lcmpv_gt
    cmp w0, #'<'
    b.eq Lcmpv_lt
    b Lcmpv_passthrough

Lcmpv_maybe_eq:
    bl _peek_next_char
    cmp w0, #'='
    b.ne Lcmpv_passthrough      // single '=' is assignment: leave it alone
    bl _advance_char            // consume first '='
    bl _advance_char            // consume second '='
    mov x21, #0                 // EQ
    b Lcmpv_parse_right
Lcmpv_maybe_ne:
    bl _peek_next_char
    cmp w0, #'='
    b.ne Lcmpv_passthrough      // lone '!' is not a value operator
    bl _advance_char            // consume '!'
    bl _advance_char            // consume '='
    mov x21, #1                 // NE
    b Lcmpv_parse_right
Lcmpv_gt:
    bl _advance_char
    bl _peek_char
    cmp w0, #'='
    b.eq Lcmpv_ge
    mov x21, #2                 // GT
    b Lcmpv_parse_right
Lcmpv_ge:
    bl _advance_char
    mov x21, #4                 // GE
    b Lcmpv_parse_right
Lcmpv_lt:
    bl _advance_char
    bl _peek_char
    cmp w0, #'='
    b.eq Lcmpv_le
    mov x21, #3                 // LT
    b Lcmpv_parse_right
Lcmpv_le:
    bl _advance_char
    mov x21, #5                 // LE
    b Lcmpv_parse_right

Lcmpv_parse_right:
    bl _parse_addsub_value
    cbz x0, Lcmpv_fail
    mov x22, x4                 // right slot (-1 if immediate)
    mov x23, x1                 // right value (immediate)

    bl _allocate_temp_var
    mov x24, x0                 // dest temp id

    // Compile-time truth value (mirrors _parse_condition_atom) so the
    // compile-time interpreter path stays consistent with the emitted op.
    mov x25, x20                // left value
    cmn x19, #1
    b.eq Lcmpv_left_ready
    LOAD_TBL x9, var_values
    ldr x25, [x9, x19, lsl #3]
Lcmpv_left_ready:
    mov x26, x23                // right value
    cmn x22, #1
    b.eq Lcmpv_right_ready
    LOAD_TBL x9, var_values
    ldr x26, [x9, x22, lsl #3]
Lcmpv_right_ready:
    cmp x21, #0
    b.eq Lcmpv_eval_eq
    cmp x21, #1
    b.eq Lcmpv_eval_ne
    cmp x21, #2
    b.eq Lcmpv_eval_gt
    cmp x21, #3
    b.eq Lcmpv_eval_lt
    cmp x21, #4
    b.eq Lcmpv_eval_ge
    cmp x21, #5
    b.eq Lcmpv_eval_le
    mov x26, #0
    b Lcmpv_store_eval
Lcmpv_eval_eq:
    cmp x25, x26
    cset x26, eq
    b Lcmpv_store_eval
Lcmpv_eval_ne:
    cmp x25, x26
    cset x26, ne
    b Lcmpv_store_eval
Lcmpv_eval_gt:
    cmp x25, x26
    cset x26, gt
    b Lcmpv_store_eval
Lcmpv_eval_lt:
    cmp x25, x26
    cset x26, lt
    b Lcmpv_store_eval
Lcmpv_eval_ge:
    cmp x25, x26
    cset x26, ge
    b Lcmpv_store_eval
Lcmpv_eval_le:
    cmp x25, x26
    cset x26, le
Lcmpv_store_eval:
    LOAD_TBL x9, var_values
    str x26, [x9, x24, lsl #3]

    cmn x22, #1                 // right immediate?
    b.eq Lcmpv_emit_imm
    mov x0, #40                 // op cmp var
    mov x1, x19
    mov x2, x22
    mov x3, x21
    mov x4, x24
    bl _record_operation4
    cbnz x0, Lcmpv_fail
    b Lcmpv_result
Lcmpv_emit_imm:
    mov x0, #39                 // op cmp imm
    mov x1, x19
    mov x2, x23
    mov x3, x21
    mov x4, x24
    bl _record_operation4
    cbnz x0, Lcmpv_fail

Lcmpv_result:
    LOAD_TBL x9, var_values
    ldr x1, [x9, x24, lsl #3]   // x1 = compile-time truth value (0/1)
    mov x0, #1
    mov x2, #1                  // type = bool
    mov x3, #0
    mov x4, x24                 // runtime temp slot holding the result
    b Lcmpv_return

Lcmpv_passthrough:
    mov x0, #1
    mov x1, x20                 // original value
    mov x2, x25                 // original type
    mov x3, x26                 // original meta
    mov x4, x19                 // original slot
    b Lcmpv_return

Lcmpv_fail:
    mov x0, #0
    mov x1, #0

Lcmpv_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _parse_addsub_value: the additive layer (formerly the body of
// _parse_expr_value). Handles '+', '-', and the 'otherwise' nullable operator.
// Comparisons are handled one level up in the _parse_expr_value wrapper.
_parse_addsub_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x27, x28, [sp, #-16]!   // runtime math paths use x27/x28; callers
                                // (e.g. _call_function) keep live state there

    bl _parse_term_value
    cbz x0, Lexpr_fail
    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x24, x4

Lexpr_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'+'
    b.eq Lexpr_add
    cmp w0, #'-'
    b.eq Lexpr_subtract

Lexpr_maybe_otherwise:
    bl _skip_whitespace
    LOAD_ADDR x0, kw_otherwise
    bl _consume_keyword
    cbz x0, Lexpr_done
    bl _parse_expr_value
    cbz x0, Lexpr_fail
    cmp x20, #7
    b.eq Lexpr_otherwise_use_rhs
    cmp x20, #16
    b.lt Lexpr_loop
    sub x9, x20, #16
    cmp x2, x9
    b.ne Lexpr_type_mismatch
    cmp x9, #6
    b.ne Lexpr_otherwise_nullable_ok
    cmp x3, x21
    b.ne Lexpr_type_mismatch
Lexpr_otherwise_nullable_ok:
    cmp x19, #-1
    b.eq Lexpr_otherwise_use_rhs
    sub x20, x20, #16
    b Lexpr_loop

Lexpr_otherwise_use_rhs:
    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x24, x4
    b Lexpr_loop

Lexpr_done:
    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x24
    b Lexpr_return

Lexpr_add:
    bl _advance_char
    bl _parse_term_value
    cbz x0, Lexpr_fail
    cmp x20, #2
    b.eq Lexpr_add_str
    cmp x2, #2
    b.eq Lexpr_add_left_int_right_str
    cmp x20, #6
    b.eq Lexpr_add_dec
    cmp x2, #6
    b.eq Lexpr_type_mismatch
    cmp x24, #-1
    b.ne Lexpr_add_runtime_int
    cmp x4, #-1
    b.ne Lexpr_add_runtime_int
    add x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lexpr_loop

Lexpr_add_runtime_int:
    add x27, x19, x1
    stp x1, x2, [sp, #-48]!
    stp x3, x4, [sp, #16]
    stp x27, x24, [sp, #32]
    bl _allocate_temp_var
    mov x28, x0
    ldp x1, x2, [sp]
    ldp x3, x4, [sp, #16]
    ldp x27, x24, [sp, #32]
    add sp, sp, #48
    cmp x24, #-1
    b.eq Lexpr_add_runtime_left_imm
    cmp x4, #-1
    b.eq Lexpr_add_runtime_right_imm
    mov x0, #28
    mov x1, x28
    mov x2, x24
    mov x3, x4
    bl _record_operation3
    cbnz x0, Lexpr_fail
    b Lexpr_add_runtime_done
Lexpr_add_runtime_left_imm:
    // Materialize the compile-time left value into its own slot, then fall
    // through to the var-var add (op 28) -- safest, proven op path.
    stp x1, x4, [sp, #-16]!
    mov x0, x19
    bl _expr_materialize_ct_int
    mov x24, x0
    ldp x1, x4, [sp], #16
    cmn x24, #1
    b.eq Lexpr_fail
    cmn x4, #1
    b.eq Lexpr_add_runtime_right_imm
    b Lexpr_add_runtime_varvar
Lexpr_add_runtime_right_imm:
    mov x0, x1
    bl _expr_materialize_ct_int
    mov x4, x0
    cmn x4, #1
    b.eq Lexpr_fail
Lexpr_add_runtime_varvar:
    mov x0, #28
    mov x1, x28
    mov x2, x24
    mov x3, x4
    bl _record_operation3
    cbnz x0, Lexpr_fail
Lexpr_add_runtime_done:
    mov x19, x27
    mov x20, #0
    mov x21, #0
    mov x24, x28
    b Lexpr_loop

Lexpr_add_str:
    cmp x2, #2
    b.eq Lexpr_add_str_ok
    // Left is str, right is not: allow int(0) right operand by auto-casting it
    // to a string (op 73 int->str), turning "str + int" into "str + str".
    cmp x2, #0
    b.ne Lexpr_type_mismatch
    // preserve left operand state across the cast/materialize helper calls
    stp x19, x20, [sp, #-32]!
    stp x21, x24, [sp, #16]
    cmn x4, #1
    b.ne Lexpr_add_r_hasvar
    mov x0, x1                    // immediate int value
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lexpr_add_coerce_fail_r
    mov x4, x0
Lexpr_add_r_hasvar:
    mov x0, #0                    // src type = int
    mov x1, #2                    // dst type = str
    mov x2, #0
    mov x3, x4                    // src var slot
    bl _emit_cast_op
    cmn x0, #1
    b.eq Lexpr_add_coerce_fail_r
    mov x4, x0                    // right is now a runtime str var
    ldp x21, x24, [sp, #16]
    ldp x19, x20, [sp], #32
    mov x1, #0
    mov x2, #2
    mov x3, #0
    b Lexpr_add_str_ok
Lexpr_add_coerce_fail_r:
    ldp x21, x24, [sp, #16]
    ldp x19, x20, [sp], #32
    b Lexpr_type_mismatch

Lexpr_add_left_int_right_str:
    // Left is not str, right is str. Allow int(0) left operand by auto-casting
    // it to a string, turning "int + str" into "str + str".
    cmp x20, #0
    b.ne Lexpr_type_mismatch
    // preserve right operand state across the cast/materialize helper calls
    stp x1, x2, [sp, #-32]!
    stp x3, x4, [sp, #16]
    cmn x24, #1
    b.ne Lexpr_add_l_hasvar
    mov x0, x19                   // immediate int value
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lexpr_add_coerce_fail_l
    mov x24, x0
Lexpr_add_l_hasvar:
    mov x0, #0                    // src type = int
    mov x1, #2                    // dst type = str
    mov x2, #0
    mov x3, x24                   // src var slot
    bl _emit_cast_op
    cmn x0, #1
    b.eq Lexpr_add_coerce_fail_l
    mov x24, x0                   // left is now a runtime str var
    mov x19, #0
    mov x20, #2
    mov x21, #0
    ldp x3, x4, [sp, #16]
    ldp x1, x2, [sp], #32
    b Lexpr_add_str_ok
Lexpr_add_coerce_fail_l:
    ldp x3, x4, [sp, #16]
    ldp x1, x2, [sp], #32
    b Lexpr_type_mismatch

Lexpr_add_str_ok:
    // Both are strings. 
    // x19=left_val, x20=2, x21=left_len, x24=left_var_id
    // x1=right_val, x2=2, x3=right_len, x4=right_var_id
    
    cmp x24, #-1
    b.ne Lexpr_add_str_runtime
    cmp x4, #-1
    b.ne Lexpr_add_str_runtime
    
    // Both are literals. Concatenate at compile-time.
    sub sp, sp, #16
    str x3, [sp]
    mov x0, x19   // left ptr
    mov x2, x1    // right ptr (save it before overwriting x1)
    mov x1, x21   // left len
    // x3 is already right_len
    bl _str_concat_len
    ldr x3, [sp]
    add sp, sp, #16
    cbz x0, Lexpr_fail
    mov x19, x0   // new heap ptr
    add x21, x21, x3 // new length
    mov x20, #2
    mov x24, #-1
    b Lexpr_loop

Lexpr_add_str_runtime:
    // One or both are runtime variables.
    stp x1, x2, [sp, #-32]!
    str x3, [sp, #16]
    str x4, [sp, #24]
    bl _allocate_temp_var
    mov x28, x0 // dest var id
    ldr x4, [sp, #24]
    ldr x3, [sp, #16]
    ldp x1, x2, [sp], #32

    // Record op 60: str_concat
    // arg0: dest, arg1: left, arg2: right, arg3: flags
    mov x25, #0
    
    // Handle left
    cmp x24, #-1
    b.ne Lexpr_add_str_left_var
    // left is imm
    stp x1, x2, [sp, #-32]!
    str x3, [sp, #16]
    str x4, [sp, #24]
    mov x0, x19
    mov x1, #2
    mov x2, x21
    bl _record_data_value
    mov x19, x0 // print id
    ldr x4, [sp, #24]
    ldr x3, [sp, #16]
    ldp x1, x2, [sp], #32
    mov x25, #1
    b Lexpr_add_str_right
Lexpr_add_str_left_var:
    mov x19, x24

Lexpr_add_str_right:
    cmp x4, #-1
    b.ne Lexpr_add_str_right_var
    // right is imm
    mov x0, x1
    mov x1, #2
    mov x2, x3
    bl _record_data_value
    mov x21, x0 // print id
    orr x25, x25, #2
    b Lexpr_add_str_emit
Lexpr_add_str_right_var:
    mov x21, x4

Lexpr_add_str_emit:
    mov x0, #60
    mov x1, x28
    mov x2, x19
    mov x3, x21
    mov x4, x25
    bl _record_operation4
    
    mov x19, #0
    mov x20, #2
    mov x21, #0
    mov x24, x28
    b Lexpr_loop

Lexpr_add_dec:
    cmp x2, #6
    b.ne Lexpr_type_mismatch
    cmp x3, x21
    b.ne Lexpr_scale_error
    add x19, x19, x1
    mov x20, #6
    mov x24, #-1
    b Lexpr_loop

Lexpr_subtract:
    bl _advance_char
    bl _parse_term_value
    cbz x0, Lexpr_fail
    cmp x20, #6
    b.eq Lexpr_sub_dec
    cmp x2, #6
    b.eq Lexpr_type_mismatch
    cmp x24, #-1
    b.ne Lexpr_sub_runtime_int
    cmp x4, #-1
    b.ne Lexpr_sub_runtime_int
    sub x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lexpr_loop

Lexpr_sub_runtime_int:
    // At least one side lives in a runtime slot: record op 29 (var - var).
    // Non-slot sides are materialized first (op 24's operand order is fixed
    // var-minus-imm, so materializing keeps left/right order correct).
    sub x27, x19, x1              // compile-time tracking value
    stp x1, x2, [sp, #-48]!
    stp x3, x4, [sp, #16]
    stp x27, x24, [sp, #32]
    bl _allocate_temp_var
    mov x28, x0                   // destination slot
    ldp x1, x2, [sp]
    ldp x3, x4, [sp, #16]
    ldp x27, x24, [sp, #32]
    add sp, sp, #48
    cmn x24, #1
    b.ne Lexpr_sub_rt_left_ok
    stp x1, x4, [sp, #-16]!
    mov x0, x19
    bl _expr_materialize_ct_int
    mov x24, x0
    ldp x1, x4, [sp], #16
    cmn x24, #1
    b.eq Lexpr_fail
Lexpr_sub_rt_left_ok:
    cmn x4, #1
    b.ne Lexpr_sub_rt_right_ok
    mov x0, x1
    bl _expr_materialize_ct_int
    mov x4, x0
    cmn x4, #1
    b.eq Lexpr_fail
Lexpr_sub_rt_right_ok:
    mov x0, #29
    mov x1, x28
    mov x2, x24
    mov x3, x4
    bl _record_operation3
    cbnz x0, Lexpr_fail
    mov x19, x27
    mov x20, #0
    mov x21, #0
    mov x24, x28
    b Lexpr_loop

Lexpr_sub_dec:
    cmp x2, #6
    b.ne Lexpr_type_mismatch
    cmp x3, x21
    b.ne Lexpr_scale_error
    sub x19, x19, x1
    mov x20, #6
    mov x24, #-1
    b Lexpr_loop

Lexpr_type_mismatch:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lexpr_fail

Lexpr_scale_error:
    LOAD_ADDR x0, msg_decimal_scale
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lexpr_fail

Lexpr_fail:
    mov x0, #0

Lexpr_return:
    ldp x27, x28, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// ------------------------------------------------------------------
// _expr_materialize_ct_int
// x0 = compile-time int value. Allocates a temp var slot and records
// op 1 (store value -> slot) so the value exists at runtime.
// Returns x0 = slot, or -1 on failure.
// Preserves x19-x24, x27, x28 (x25/x26 are clobbered by the record
// helpers and must not be live across this call).
// ------------------------------------------------------------------
_expr_materialize_ct_int:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    mov x19, x0
    bl _allocate_temp_var
    mov x20, x0
    mov x0, x20
    mov x1, x19
    bl _record_store_variable
    cbnz x0, Lexpr_mat_ct_fail
    mov x0, x20
    b Lexpr_mat_ct_ret
Lexpr_mat_ct_fail:
    mov x0, #-1
Lexpr_mat_ct_ret:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_condition_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    LOAD_ADDR x0, kw_not
    bl _consume_keyword
    cbz x0, Lcond_parse_first
    bl _parse_condition_value
    cbz x0, Lcond_fail
    // x1 = temp var id of the inner condition (0/1). Emit a runtime
    // "inner == 0" compare into a fresh temp so NOT works at run time.
    mov x19, x1
    bl _allocate_temp_var
    mov x22, x0
    LOAD_TBL x9, var_values
    ldr x10, [x9, x19, lsl #3]
    cmp x10, #0
    cset x10, eq
    str x10, [x9, x22, lsl #3]
    mov x0, #39 // op cmp imm
    mov x1, x19 // left var slot
    mov x2, #0  // right immediate 0
    mov x3, #0  // operator EQ
    mov x4, x22 // dest temp var
    bl _record_operation4
    mov x0, #1
    mov x1, x22
    mov x2, #1  // type = var
    mov x3, #0
    b Lcond_return

Lcond_parse_first:
    // "( condition )" grouping: only take this path when the lookahead
    // scanner sees condition-level operators inside the parens; plain
    // arithmetic groups like "(x + 1) > 2" stay on the atom/expr path.
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lcond_parse_atom_first
    bl _cond_group_lookahead
    cbz x0, Lcond_parse_atom_first
    bl _advance_char              // consume '('
    bl _parse_condition_value
    cbz x0, Lcond_fail
    mov x19, x1
    mov x20, #1
    mov x21, #0
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lcond_fail
    b Lcond_logic_loop

Lcond_parse_atom_first:
    bl _parse_condition_atom
    cbz x0, Lcond_fail
    mov x19, x1
    mov x20, x2
    mov x21, x3

Lcond_logic_loop:
    LOAD_ADDR x0, kw_and
    bl _consume_keyword
    cbnz x0, Lcond_logic_and

    LOAD_ADDR x0, kw_or
    bl _consume_keyword
    cbnz x0, Lcond_logic_or

    // Also accept the C-style operators "&&" and "||" as aliases for the
    // "and"/"or" keywords, routing them through the same runtime logic paths.
    mov w0, #'&'
    bl _consume_double_char_op
    cbnz x0, Lcond_logic_and
    mov w0, #'|'
    bl _consume_double_char_op
    cbnz x0, Lcond_logic_or

    mov x0, #1
    mov x1, x19
    mov x2, #0 // int
    mov x3, #0 // length 0
    b Lcond_return

Lcond_logic_and:
    bl _parse_condition_value
    cbz x0, Lcond_fail
    // x19 = left condition temp id, x1 = right condition temp id.
    // Condition atoms always yield 0/1, so a runtime multiply is an exact
    // logical AND. Record dest = left * right into a fresh temp.
    mov x20, x1
    bl _allocate_temp_var
    mov x22, x0
    LOAD_TBL x9, var_values
    ldr x10, [x9, x19, lsl #3]
    ldr x11, [x9, x20, lsl #3]
    cmp x10, #0
    cset x10, ne
    cmp x11, #0
    cset x11, ne
    and x10, x10, x11
    str x10, [x9, x22, lsl #3]
    mov x0, #30 // op 30: target = var * var
    mov x1, x22
    mov x2, x19
    mov x3, x20
    bl _record_operation3
    cbnz x0, Lcond_fail
    mov x19, x22
    b Lcond_logic_loop

Lcond_logic_or:
    bl _parse_condition_value
    cbz x0, Lcond_fail
    // Atoms yield 0/1, so runtime addition preserves truthiness for OR
    // (0, 1 or 2 => branch tests only check non-zero).
    mov x20, x1
    bl _allocate_temp_var
    mov x22, x0
    LOAD_TBL x9, var_values
    ldr x10, [x9, x19, lsl #3]
    ldr x11, [x9, x20, lsl #3]
    orr x10, x10, x11
    cmp x10, #0
    cset x10, ne
    str x10, [x9, x22, lsl #3]
    mov x0, #28 // op 28: target = var + var
    mov x1, x22
    mov x2, x19
    mov x3, x20
    bl _record_operation3
    cbnz x0, Lcond_fail
    mov x19, x22
    b Lcond_logic_loop

Lcond_fail:
    mov x0, #0
    mov x1, #0

Lcond_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _cond_group_lookahead: read-only scan starting at '(' (cursor must point
// at it after whitespace). Returns x0=1 when the parenthesized text up to
// the matching ')' contains condition-level operators (==, !=, <, >, &&,
// ||, " and ", " or "), i.e. it must be parsed as a grouped condition.
// Skips over string literals. Never moves the cursor.
_cond_group_lookahead:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    LOAD_ADDR x9, source_ptr
    ldr x1, [x9]
    LOAD_ADDR x9, cursor_pos
    ldr x2, [x9]
    add x1, x1, x2                // pointer at '('
    mov x3, #0                    // paren depth
    mov x0, #0                    // found flag
Lcgl_loop:
    ldrb w4, [x1]
    cbz w4, Lcgl_ret
    cmp w4, #'"'
    b.eq Lcgl_string
    cmp w4, #'('
    b.eq Lcgl_open
    cmp w4, #')'
    b.eq Lcgl_close
    cmp x3, #1
    b.lt Lcgl_next                // only inspect text inside the parens
    cmp w4, #'<'
    b.eq Lcgl_found
    cmp w4, #'>'
    b.eq Lcgl_found
    ldrb w5, [x1, #1]
    cmp w4, #'='
    b.eq Lcgl_eq
    cmp w4, #'!'
    b.eq Lcgl_eq
    cmp w4, #'&'
    b.eq Lcgl_dbl
    cmp w4, #'|'
    b.eq Lcgl_dbl
    cmp w4, #' '
    b.eq Lcgl_word
    b Lcgl_next
Lcgl_eq:
    cmp w5, #'='
    b.eq Lcgl_found
    b Lcgl_next
Lcgl_dbl:
    cmp w5, w4
    b.eq Lcgl_found
    b Lcgl_next
Lcgl_word:
    // match " and " / " or "
    ldrb w6, [x1, #2]
    cmp w5, #'a'
    b.ne Lcgl_word_or
    cmp w6, #'n'
    b.ne Lcgl_next
    ldrb w6, [x1, #3]
    cmp w6, #'d'
    b.ne Lcgl_next
    ldrb w6, [x1, #4]
    cmp w6, #' '
    b.eq Lcgl_found
    b Lcgl_next
Lcgl_word_or:
    cmp w5, #'o'
    b.ne Lcgl_next
    cmp w6, #'r'
    b.ne Lcgl_next
    ldrb w6, [x1, #3]
    cmp w6, #' '
    b.eq Lcgl_found
    b Lcgl_next
Lcgl_string:
    add x1, x1, #1
Lcgl_str_loop:
    ldrb w4, [x1]
    cbz w4, Lcgl_ret
    cmp w4, #'"'
    b.eq Lcgl_next
    add x1, x1, #1
    b Lcgl_str_loop
Lcgl_open:
    add x3, x3, #1
    b Lcgl_next
Lcgl_close:
    subs x3, x3, #1
    b.le Lcgl_ret                 // reached the matching ')'
    b Lcgl_next
Lcgl_next:
    add x1, x1, #1
    b Lcgl_loop
Lcgl_found:
    mov x0, #1
Lcgl_ret:
    ldp x29, x30, [sp], #16
    ret

// _consume_double_char_op: w0 = a character c. If the next non-whitespace
// input is exactly "cc" (e.g. "&&" or "||"), consume both characters and
// return x0=1. Otherwise leave the cursor/line untouched and return x0=0.
_consume_double_char_op:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov w19, w0
    LOAD_ADDR x9, cursor_pos
    ldr x20, [x9]
    LOAD_ADDR x9, current_line
    ldr x21, [x9]

    bl _skip_whitespace
    bl _peek_char
    cmp w0, w19
    b.ne Lcdc_restore
    bl _advance_char
    bl _peek_char
    cmp w0, w19
    b.ne Lcdc_restore
    bl _advance_char
    mov x0, #1
    b Lcdc_ret

Lcdc_restore:
    LOAD_ADDR x9, cursor_pos
    str x20, [x9]
    LOAD_ADDR x9, current_line
    str x21, [x9]
    mov x0, #0

Lcdc_ret:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _lookahead_is_lparen: return x0=1 if the next non-whitespace input character
// is '(', else x0=0. Never consumes input (cursor_pos/current_line restored).
// Used so call-only builtins (value/address/alloc/cast) are only treated as
// keywords when actually applied as a call -- otherwise those words are usable
// as ordinary identifiers (variable / parameter / loop names).
_lookahead_is_lparen:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    cset x0, eq
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_condition_atom:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    // Parse operands via the additive layer, NOT _parse_expr_value: the atom
    // consumes its own relational operator below, so going through the
    // comparison-aware wrapper here would double-parse it.
    bl _parse_addsub_value
    cbz x0, Lcond_atom_fail
    mov x19, x4 // left var slot id (or -1 if immediate)
    mov x20, x1 // left value (for immediate case)

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'='
    b.eq Lcond_equal
    cmp w0, #'!'
    b.eq Lcond_not_equal
    cmp w0, #'>'
    b.eq Lcond_greater
    cmp w0, #'<'
    b.eq Lcond_less

    // no op -> compare left var with immediate 0 using NE
    mov x21, #1 // NE
    mov x22, #-1 // right is immediate (no var slot)
    mov x23, #0 // right value is 0
    b Lcond_emit_op

Lcond_equal:
    bl _advance_char
    mov w0, #'='
    bl _expect_char
    cbz x0, Lcond_atom_fail
    mov x21, #0 // EQ
    b Lcond_parse_right

Lcond_not_equal:
    bl _advance_char
    mov w0, #'='
    bl _expect_char
    cbz x0, Lcond_atom_fail
    mov x21, #1 // NE
    b Lcond_parse_right

Lcond_greater:
    bl _advance_char
    bl _peek_char
    cmp w0, #'='
    b.eq Lcond_ge
    mov x21, #2 // GT
    b Lcond_parse_right
Lcond_ge:
    bl _advance_char
    mov x21, #4 // GE
    b Lcond_parse_right

Lcond_less:
    bl _advance_char
    bl _peek_char
    cmp w0, #'='
    b.eq Lcond_le
    mov x21, #3 // LT
    b Lcond_parse_right
Lcond_le:
    bl _advance_char
    mov x21, #5 // LE
    b Lcond_parse_right

Lcond_parse_right:
    bl _parse_addsub_value
    cbz x0, Lcond_atom_fail
    mov x22, x4 // right var slot id (or -1 if immediate)
    mov x23, x1 // right value (for immediate case)

Lcond_emit_op:
    // allocate temp var
    bl _allocate_temp_var
    mov x24, x0 // dest temp var id

    // Compute the compile-time truth value for function execution paths.
    mov x25, x20
    cmn x19, #1
    b.eq Lcond_left_ready
    LOAD_TBL x9, var_values
    ldr x25, [x9, x19, lsl #3]
Lcond_left_ready:
    mov x26, x23
    cmn x22, #1
    b.eq Lcond_right_ready
    LOAD_TBL x9, var_values
    ldr x26, [x9, x22, lsl #3]
Lcond_right_ready:
    cmp x21, #0
    b.eq Lcond_eval_eq
    cmp x21, #1
    b.eq Lcond_eval_ne
    cmp x21, #2
    b.eq Lcond_eval_gt
    cmp x21, #3
    b.eq Lcond_eval_lt
    cmp x21, #4
    b.eq Lcond_eval_ge
    cmp x21, #5
    b.eq Lcond_eval_le
    mov x26, #0
    b Lcond_store_eval
Lcond_eval_eq:
    cmp x25, x26
    cset x26, eq
    b Lcond_store_eval
Lcond_eval_ne:
    cmp x25, x26
    cset x26, ne
    b Lcond_store_eval
Lcond_eval_gt:
    cmp x25, x26
    cset x26, gt
    b Lcond_store_eval
Lcond_eval_lt:
    cmp x25, x26
    cset x26, lt
    b Lcond_store_eval
Lcond_eval_ge:
    cmp x25, x26
    cset x26, ge
    b Lcond_store_eval
Lcond_eval_le:
    cmp x25, x26
    cset x26, le
Lcond_store_eval:
    LOAD_TBL x9, var_values
    str x26, [x9, x24, lsl #3]

    cmn x22, #1 // right var slot == -1 means immediate
    b.eq Lcond_emit_imm
    
    // right is var
    mov x0, #40 // op cmp var
    mov x1, x19 // left var
    mov x2, x22 // right var
    mov x3, x21 // operator
    mov x4, x24 // dest temp var
    bl _record_operation4
    b Lcond_atom_done

Lcond_emit_imm:
    mov x0, #39 // op cmp imm
    mov x1, x19 // left var slot
    mov x2, x23 // right immediate value
    mov x3, x21 // operator
    mov x4, x24 // dest temp var
    bl _record_operation4

Lcond_atom_done:
    mov x0, #1
    mov x1, x24 // return temp var id
    mov x2, #1  // type = var
    b Lcond_atom_return

Lcond_atom_fail:
    mov x0, #0
    mov x1, #0

Lcond_atom_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_term_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x27, x28, [sp, #-16]!   // runtime math tail clobbers x27/x28

    bl _parse_power_value
    cbz x0, Lterm_fail
    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x24, x4

Lterm_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'*'
    b.eq Lterm_multiply
    cmp w0, #'/'
    b.eq Lterm_divide
    cmp w0, #'%'
    b.eq Lterm_modulo
    b Lterm_done

Lterm_multiply:
    bl _advance_char
    bl _parse_power_value
    cbz x0, Lterm_fail
    cmp x20, #6
    b.eq Lterm_mul_dec
    cmp x2, #6
    b.eq Lterm_type_mismatch
    cmp x24, #-1
    b.ne Lterm_mul_runtime_int
    cmp x4, #-1
    b.ne Lterm_mul_runtime_int
    mul x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lterm_loop

Lterm_mul_runtime_int:
    mul x27, x19, x1              // compile-time tracking value
    mov x23, #30                  // op 30: target = var * var
    b Lterm_math_runtime_common

Lterm_mul_dec:
    cmp x2, #6
    b.ne Lterm_type_mismatch
    cmp x3, x21
    b.ne Lterm_scale_error
    mul x19, x19, x1
    mov x0, x21
    bl _pow10_u64
    udiv x19, x19, x0
    mov x20, #6
    mov x24, #-1
    b Lterm_loop

Lterm_divide:
    bl _advance_char
    bl _parse_power_value
    cbz x0, Lterm_fail
    cmp x20, #6
    b.eq Lterm_div_dec_check
    cmp x2, #6
    b.eq Lterm_type_mismatch
    cmp x24, #-1
    b.ne Lterm_div_runtime_int
    cmp x4, #-1
    b.ne Lterm_div_runtime_int
    cbz x1, Lterm_divide_zero
    udiv x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lterm_loop

Lterm_div_dec_check:
    // decimals still fold at compile time; keep the zero check for them
    cbz x1, Lterm_divide_zero
    b Lterm_div_dec

Lterm_div_runtime_int:
    // Runtime division: the right side's compile-time value may be an
    // unknown placeholder (often 0), so no compile-time zero error here.
    // ARM64 udiv/sdiv by zero yields 0, so the tracking fold is safe.
    udiv x27, x19, x1             // compile-time tracking value
    mov x23, #31                  // op 31: target = var / var
    b Lterm_math_runtime_common

Lterm_div_dec:
    cmp x2, #6
    b.ne Lterm_type_mismatch
    cmp x3, x21
    b.ne Lterm_scale_error
    mov x22, x1
    mov x0, x21
    bl _pow10_u64
    mul x19, x19, x0
    sdiv x19, x19, x22
    mov x20, #6
    mov x24, #-1
    b Lterm_loop

Lterm_modulo:
    bl _advance_char
    bl _parse_power_value
    cbz x0, Lterm_fail
    cmp x20, #6
    b.eq Lterm_unsupported_decimal
    cmp x2, #6
    b.eq Lterm_unsupported_decimal
    cmp x24, #-1
    b.ne Lterm_mod_runtime_int
    cmp x4, #-1
    b.ne Lterm_mod_runtime_int
    cbz x1, Lterm_divide_zero
    udiv x9, x19, x1
    msub x19, x9, x1, x19
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lterm_loop

Lterm_mod_runtime_int:
    udiv x9, x19, x1              // safe: udiv by 0 yields 0 on ARM64
    msub x27, x9, x1, x19         // compile-time tracking value
    mov x23, #32                  // op 32: target = var % var
    b Lterm_math_runtime_common

// Shared tail for runtime * / % at the term level.
// In: x23 = op kind (30/31/32), x27 = compile-time folded value,
//     left value/slot in x19/x24, right value/slot in x1/x4.
Lterm_math_runtime_common:
    stp x1, x2, [sp, #-48]!
    stp x3, x4, [sp, #16]
    stp x27, x24, [sp, #32]
    bl _allocate_temp_var
    mov x28, x0                   // destination slot
    ldp x1, x2, [sp]
    ldp x3, x4, [sp, #16]
    ldp x27, x24, [sp, #32]
    add sp, sp, #48
    cmn x24, #1
    b.ne Lterm_math_rt_left_ok
    stp x1, x4, [sp, #-16]!
    mov x0, x19
    bl _expr_materialize_ct_int
    mov x24, x0
    ldp x1, x4, [sp], #16
    cmn x24, #1
    b.eq Lterm_fail
Lterm_math_rt_left_ok:
    cmn x4, #1
    b.ne Lterm_math_rt_right_ok
    mov x0, x1
    bl _expr_materialize_ct_int
    mov x4, x0
    cmn x4, #1
    b.eq Lterm_fail
Lterm_math_rt_right_ok:
    mov x0, x23
    mov x1, x28
    mov x2, x24
    mov x3, x4
    bl _record_operation3
    cbnz x0, Lterm_fail
    mov x19, x27
    mov x20, #0
    mov x21, #0
    mov x24, x28
    b Lterm_loop

Lterm_divide_zero:
    LOAD_ADDR x0, msg_divide_zero
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lterm_fail

Lterm_unsupported_decimal:
    LOAD_ADDR x0, msg_unsupported_decimal
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lterm_fail

Lterm_type_mismatch:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lterm_fail

Lterm_scale_error:
    LOAD_ADDR x0, msg_decimal_scale
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lterm_fail

Lterm_done:
    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x24
    b Lterm_return

Lterm_fail:
    mov x0, #0

Lterm_return:
    ldp x27, x28, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_power_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    bl _parse_primary_value
    cbz x0, Lpow_fail
    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x24, x4

Lpow_loop:
    bl _skip_whitespace
    LOAD_ADDR x9, cursor_pos
    ldr x22, [x9]
    LOAD_ADDR x9, current_line
    ldr x23, [x9]
    bl _peek_char
    cmp w0, #'*'
    b.ne Lpow_done
    bl _advance_char
    bl _peek_char
    cmp w0, #'*'
    b.ne Lpow_restore_done
    bl _advance_char
    bl _parse_primary_value
    cbz x0, Lpow_fail
    mov x22, x1
    mov x23, #1
    cbz x22, Lpow_zero_exp

Lpow_mul_loop:
    mul x23, x23, x19
    sub x22, x22, #1
    cbnz x22, Lpow_mul_loop
    mov x19, x23
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lpow_loop

Lpow_zero_exp:
    mov x19, #1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lpow_loop

Lpow_restore_done:
    LOAD_ADDR x9, cursor_pos
    str x22, [x9]
    LOAD_ADDR x9, current_line
    str x23, [x9]
    b Lpow_done

Lpow_done:
    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x24
    b Lpow_return

Lpow_fail:
    mov x0, #0

Lpow_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_primary_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lprimary_fail

    cmp w0, #'('
    b.eq Lprimary_group

    cmp w0, #'['
    b.eq Lprimary_list_entry

    cmp w0, #'{'
    b.eq Lprimary_map_entry

    cmp w0, #'"'
    b.eq Lprimary_string
    cmp w0, #'+'
    b.eq Lprimary_unary_plus

    cmp w0, #'-'
    b.eq Lprimary_unary_minus

    cmp w0, #'0'
    b.lt Lprimary_identifier
    cmp w0, #'9'
    b.le Lprimary_number
    // Check for 'try' keyword expression before treating as identifier
    b Lprimary_check_try

Lprimary_check_try:
    // Check for 'try' keyword expression
    // Use x21, x22, x23 temporarily (callee-saved, will be restored)
    // Get pointer to current position
    LOAD_ADDR x9, source_ptr
    ldr x21, [x9]       // x21 = source_ptr
    LOAD_ADDR x9, cursor_pos
    ldr x22, [x9]       // x22 = cursor_pos
    add x23, x21, x22   // x23 = pointer to current position
    // For _match_cstr_span: x0=pointer, x1=length (like in statement parsing)
    mov x0, x23         // x0 = pointer to current position
    mov x1, #3          // x1 = length of "try"
    LOAD_ADDR x2, kw_try
    bl _match_cstr_span
    cbz x0, Lprimary_identifier
    // Matched 'try', now parse try expression
    b Lprimary_try_expr

Lprimary_try_expr:
    // try expr catch fallback
    // First advance past 'try' (3 characters)
    LOAD_ADDR x9, cursor_pos
    ldr x21, [x9]
    add x21, x21, #3
    str x21, [x9]
    bl _skip_whitespace
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    mov x25, x1 // try value
    mov x26, x2 // try type
    mov x27, x3 // try meta
    mov x28, x4 // try var idx

    bl _skip_whitespace
    LOAD_ADDR x0, kw_catch
    bl _consume_keyword
    cbz x0, Lprimary_fail

    bl _skip_whitespace
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    // x1=fallback value, x2=fallback type, x3=fallback meta, x4=fallback var idx

    // Type check: try result and fallback must be compatible
    cmp x26, x2
    b.ne Lprimary_type_mismatch

    // Record try-catch operation (96)
    // Store the result to a new hidden variable and return that
    // x28 = try var idx, x4 = fallback var idx
    mov x0, #96 // op_try_catch
    mov x1, x25 // try value
    mov x2, x28 // try var_idx (-1 = immediate, >=0 = var slot)
    mov x3, x1  // fallback value
    // x4 already contains fallback var_idx
    bl _record_operation5
    cbnz x0, Lprimary_fail

    // Return the result as a computed value
    // The try-catch operation returns the value in x10
    // We need to store it to a variable and return that
    mov x1, x25
    mov x2, x26
    mov x3, #-1  // immediate result
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_unary_plus:
    bl _advance_char
    bl _skip_whitespace
    bl _parse_numeric_literal
    cbnz x0, Lprimary_unary_plus_lit
    // Not a literal: +expr is just expr (variable, call, paren group).
    bl _parse_primary_value
    cbz x0, Lprimary_fail
    b Lprimary_suffix_loop
Lprimary_unary_plus_lit:
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_unary_minus:
    bl _advance_char
    bl _skip_whitespace
    bl _parse_numeric_literal
    cbnz x0, Lprimary_unary_minus_lit
    // Not a literal: negate a full primary (variable, call, paren group)
    // by recording dest = 0 - value at runtime.
    bl _parse_primary_value
    cbz x0, Lprimary_fail
    cmp x2, #0                    // only int values can be negated
    b.ne Lprimary_fail
    cmn x4, #1
    b.ne Lprimary_unary_minus_rt
    neg x1, x1                    // folded compile-time value
    mov x4, #-1
    b Lprimary_suffix_loop
Lprimary_unary_minus_rt:
    mov x19, x1                   // compile-time tracking value
    mov x20, x4                   // source var slot
    mov x0, #0
    bl _expr_materialize_ct_int   // slot holding the constant 0
    mov x21, x0
    cmn x21, #1
    b.eq Lprimary_fail
    bl _allocate_temp_var
    mov x22, x0                   // destination slot
    neg x19, x19
    LOAD_TBL x9, var_values
    str x19, [x9, x22, lsl #3]
    mov x0, #29                   // op 29: target = var - var
    mov x1, x22
    mov x2, x21
    mov x3, x20
    bl _record_operation3
    cbnz x0, Lprimary_fail
    mov x1, x19
    mov x2, #0
    mov x3, #0
    mov x4, x22
    b Lprimary_suffix_loop
Lprimary_unary_minus_lit:
    neg x1, x1
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_group:
    bl _advance_char
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x22, x4

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x22
    b Lprimary_suffix_loop

Lprimary_list_entry:
    mov x0, #-1
    bl _parse_list_literal_value
    cbz x0, Lprimary_fail
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_map_entry:
    mov x0, #-1
    bl _parse_map_literal_value
    cbz x0, Lprimary_fail
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_suffix_loop:
    mov x25, x1 // value
    mov x26, x2 // type
    mov x27, x3 // metadata
    mov x28, x4 // var index

Lprimary_suffix_loop_start:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'.'
    b.eq Lprimary_member_access
    cmp w0, #'['
    b.eq Lprimary_indexing
    
    mov x0, #1          // success: peek may have returned 0 at EOF, so x0
                        // must be set explicitly or callers see a false fail
    mov x1, x25
    mov x2, x26
    mov x3, x27
    mov x4, x28
    b Lprimary_return

Lprimary_member_access:
    // Snapshot the source operand (value/len/var) BEFORE parsing the member
    // name and running the _match_cstr_span dispatch chain. This keeps the
    // string-method source stable regardless of how many dispatch checks run
    // before the matching handler (the live x25/x27/x28 were being read stale
    // by the later-checked .upper()/.lower() handlers).
    LOAD_ADDR x9, member_src_val
    str x25, [x9]
    LOAD_ADDR x9, member_src_len
    str x27, [x9]
    LOAD_ADDR x9, member_src_var
    str x28, [x9]
    bl _advance_char
    bl _parse_identifier
    cbz x0, Lprimary_fail
    mov x21, x0 // name ptr
    mov x22, x1 // name len

    cmp x26, #10
    b.eq Lprimary_member_object
    cmp x26, #11
    b.eq Lprimary_member_object
    cmp x26, #12
    b.eq Lprimary_member_channel
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_length
    bl _match_cstr_span
    cbnz x0, Lprimary_member_length
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_slice
    bl _match_cstr_span
    cbnz x0, Lprimary_member_slice
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_contains
    bl _match_cstr_span
    cbnz x0, Lprimary_str_contains
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_replace
    bl _match_cstr_span
    cbnz x0, Lprimary_str_replace
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_split
    bl _match_cstr_span
    cbnz x0, Lprimary_str_split
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_upper
    bl _match_cstr_span
    cbnz x0, Lprimary_str_upper
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_lower
    bl _match_cstr_span
    cbnz x0, Lprimary_str_lower
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_startswith
    bl _match_cstr_span
    cbnz x0, Lprimary_str_startswith
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_endswith
    bl _match_cstr_span
    cbnz x0, Lprimary_str_endswith
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_indexof
    bl _match_cstr_span
    cbnz x0, Lprimary_str_indexof
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_trim
    bl _match_cstr_span
    cbnz x0, Lprimary_str_trim
    
    b Lprimary_fail

Lprimary_member_channel:
    mov x0, x25                 // channel id
    mov x1, x27                 // payload type metadata
    mov x2, x21                 // member name
    mov x3, x22
    bl _parse_channel_method
    cbz x0, Lprimary_fail
    mov x25, x1
    mov x26, x2
    mov x27, x3
    mov x28, x4
    b Lprimary_suffix_loop_start

Lprimary_member_object:
    LOAD_ADDR x9, object_blueprint_ids
    ldr x27, [x9, x25, lsl #3]
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.eq Lprimary_member_object_method
    mov x0, x25
    mov x1, x27
    mov x2, x21
    mov x3, x22
    bl _resolve_object_field_value
    cbz x0, Lprimary_fail
    mov x25, x1
    mov x26, x2
    mov x27, x3
    mov x28, x4
    b Lprimary_suffix_loop_start

Lprimary_member_object_method:
    mov x0, x25
    mov x1, x26
    mov x2, x27
    mov x3, x21
    mov x4, x22
    bl _call_object_method
    cbnz x0, Lprimary_fail
    // A method returns its value in a RUNTIME result slot (x4), matching the
    // _call_function convention. Use that slot so an expression like
    // `print(a.get())` sees THIS instance's computed value, instead of the old
    // compile-time fn_return_value (which was the shared template's value and
    // made every method appear to return the template default, e.g. 0).
    mov x26, x2                 // return type
    mov x27, x3                 // return length / meta
    mov x28, x4                 // runtime result slot
    mov x25, #0                 // compile-time value unused when a slot is present
    b Lprimary_suffix_loop_start

Lprimary_member_length:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lprimary_member_length_check
    bl _advance_char
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
Lprimary_member_length_check:
    cmp x26, #4 // list
    b.eq Lprimary_list_length_val
    cmp x26, #20 // list?
    b.eq Lprimary_list_length_val
    cmp x26, #2 // str
    b.eq Lprimary_str_length_val
    b Lprimary_fail

Lprimary_list_length_val:
    // Runtime-count list (e.g. a str.split result): its element count is only
    // known at run time in list_base_counts[base]. The base is a compile-time
    // immediate held in x25; materialize it into a slot and emit op 81.
    LOAD_TBL x9, list_base_is_runtime
    ldrb w9, [x9, x25]
    cbz w9, Lprimary_list_length_check_param
    mov x0, x25
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lprimary_fail
    mov x19, x0                  // slot holding base
    bl _allocate_temp_var
    mov x2, x19                  // arg1 = base slot
    mov x19, x0                  // dest temp
    mov x1, x19                  // arg0 = dest
    mov x0, #81                  // op list_length_runtime
    bl _record_operation
    cbnz x0, Lprimary_fail
    mov x25, #0
    mov x26, #0
    mov x27, #0
    mov x28, x19
    b Lprimary_suffix_loop_start
Lprimary_list_length_check_param:
    // If the list source is a function PARAMETER, its element count is only
    // known at runtime: the param carries the list's pool BASE index as its
    // runtime value, and list_pool_lengths[base] holds the count. Emit a
    // runtime length load (op 81). Literals / local lists keep the compile-time
    // fold, whose count lives in the low 32 bits of x27.
    cmn x28, #1
    b.eq Lprimary_list_length_fold
    LOAD_ADDR x9, current_parse_fn_id
    ldr x9, [x9]
    cmn x9, #1
    b.eq Lprimary_list_length_fold
    LOAD_TBL x10, fn_scope_bases
    ldr x10, [x10, x9, lsl #3]
    cmp x28, x10
    b.lt Lprimary_list_length_fold
    LOAD_TBL x11, fn_param_counts
    ldr x11, [x11, x9, lsl #3]
    add x11, x10, x11
    cmp x28, x11
    b.ge Lprimary_list_length_fold
    // It's a list parameter -> emit runtime length load.
    mov x19, x28                 // remember base var slot
    bl _allocate_temp_var
    mov x2, x19                  // arg1 = base var slot
    mov x19, x0                  // dest temp
    mov x1, x19                  // arg0 = dest
    mov x0, #81                  // op list_length_runtime
    bl _record_operation
    cbnz x0, Lprimary_fail
    mov x25, #0                  // runtime value unknown
    mov x26, #0                  // type int
    mov x27, #0
    mov x28, x19                 // result is in temp slot
    b Lprimary_suffix_loop_start
Lprimary_list_length_fold:
    and x25, x27, #0xFFFFFFFF
    mov x26, #0
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_str_length_val:
    // If the string lives in a variable/temp slot (x28 != -1) its length is
    // only known at runtime (str params, concatenation, file_read results,
    // interpolation, etc.), so emit op 103 to compute strlen at runtime.
    // A bare string literal (x28 == -1) keeps the compile-time fold in x27.
    cmn x28, #1
    b.eq Lprimary_str_length_fold
    mov x19, x28                 // remember source string var slot
    bl _allocate_temp_var
    mov x2, x19                  // arg1 = source string var slot
    mov x19, x0                  // dest temp
    mov x1, x19                  // arg0 = dest
    mov x0, #103                 // op str_length_runtime
    bl _record_operation
    cbnz x0, Lprimary_fail
    mov x25, #0                  // runtime value unknown
    mov x26, #0                  // type int
    mov x27, #0
    mov x28, x19                 // result is in the temp slot
    b Lprimary_suffix_loop_start
Lprimary_str_length_fold:
    mov x25, x27
    mov x26, #0
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_member_slice:
    // str.slice(start, end) -> str
    cmp x26, #2
    b.ne Lprimary_fail
    LOAD_ADDR x9, slice_tmp_source_val
    str x25, [x9]
    LOAD_ADDR x9, slice_tmp_source_len
    str x27, [x9]
    LOAD_ADDR x9, slice_tmp_source_var
    str x28, [x9]

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail

    // Parse start
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #0
    b.ne Lprimary_fail
    LOAD_ADDR x9, slice_tmp_start_val
    str x1, [x9]
    LOAD_ADDR x9, slice_tmp_start_var
    str x4, [x9]

    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lprimary_fail

    // Parse end
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #0
    b.ne Lprimary_fail
    LOAD_ADDR x9, slice_tmp_end_val
    str x1, [x9]
    LOAD_ADDR x9, slice_tmp_end_var
    str x4, [x9]

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    // Materialize source into a temp var when source is an immediate string.
    LOAD_ADDR x9, slice_tmp_source_var
    ldr x19, [x9]
    cmn x19, #1
    b.ne Lprimary_member_slice_source_ready
    LOAD_ADDR x9, slice_tmp_source_val
    ldr x0, [x9]
    mov x1, #2
    LOAD_ADDR x9, slice_tmp_source_len
    ldr x2, [x9]
    bl _record_data_value
    mov x24, x0
    bl _allocate_temp_var
    mov x19, x0
    mov x0, #72
    mov x1, x19
    mov x2, x24
    bl _record_operation
    cbnz x0, Lprimary_fail
    LOAD_ADDR x9, slice_tmp_source_var
    str x19, [x9]

Lprimary_member_slice_source_ready:
    // Encode start arg (immediate or var-slot with bit63 set).
    LOAD_ADDR x9, slice_tmp_start_val
    ldr x20, [x9]
    LOAD_ADDR x9, slice_tmp_start_var
    ldr x21, [x9]
    cmn x21, #1
    b.ne Lprimary_member_slice_start_var
    b Lprimary_member_slice_start_done
Lprimary_member_slice_start_var:
    mov x9, #1
    lsl x9, x9, #63
    orr x20, x21, x9
Lprimary_member_slice_start_done:

    // Encode end arg (immediate or var-slot with bit63 set).
    LOAD_ADDR x9, slice_tmp_end_val
    ldr x22, [x9]
    LOAD_ADDR x9, slice_tmp_end_var
    ldr x25, [x9]
    cmn x25, #1
    b.ne Lprimary_member_slice_end_var
    b Lprimary_member_slice_end_done
Lprimary_member_slice_end_var:
    mov x9, #1
    lsl x9, x9, #63
    orr x22, x25, x9
Lprimary_member_slice_end_done:

    // op 90: string_slice(dest, src_var, start, end)
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #90
    mov x1, x23
    LOAD_ADDR x9, slice_tmp_source_var
    ldr x2, [x9]
    mov x3, x20
    mov x4, x22
    bl _record_operation4
    cbnz x0, Lprimary_fail
    mov x25, #0
    mov x26, #2
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

// String methods - .contains(substr), .replace(old, new), .split(sep), .upper(), .lower()

Lprimary_str_contains:
    // str.contains(substr) -> bool
    cmp x26, #2
    b.ne Lprimary_fail
    // Save/materialize source before helper calls clobber x28.
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    
    // Parse substring argument
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #2
    b.ne Lprimary_fail
    
    LOAD_ADDR x9, str_contains_tmp_substr_val
    str x1, [x9]
    LOAD_ADDR x9, str_contains_tmp_substr_var
    str x4, [x9]
    LOAD_ADDR x9, str_method_sub_len
    str x3, [x9]
    
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    
    // Materialize the substring into a temp var if it is a literal (var == -1),
    // so codegen can load it from a stack slot instead of emitting a bad
    // `mov x1, #<huge-address>` immediate.
    LOAD_ADDR x9, str_contains_tmp_substr_var
    ldr x19, [x9]
    cmn x19, #1
    b.ne Lprimary_str_contains_sub_ready
    LOAD_ADDR x9, str_contains_tmp_substr_val
    ldr x0, [x9]
    mov x1, #2
    LOAD_ADDR x9, str_method_sub_len
    ldr x2, [x9]
    bl _record_data_value
    mov x24, x0
    bl _allocate_temp_var
    mov x19, x0
    mov x0, #72
    mov x1, x19
    mov x2, x24
    bl _record_operation
    cbnz x0, Lprimary_fail
    LOAD_ADDR x9, str_contains_tmp_substr_var
    str x19, [x9]
Lprimary_str_contains_sub_ready:
    // Encode substr var into arg2 with bit63 set so codegen loads it from stack.
    LOAD_ADDR x9, str_contains_tmp_substr_var
    ldr x20, [x9]
    mov x9, #1
    lsl x9, x9, #63
    orr x20, x20, x9
    
    // Allocate result variable and record operation
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #97 // op_str_contains
    mov x1, x23 // dest
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9] // source var (saved)
    mov x3, x20  // substr var (bit63 tagged) -> arg2
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lprimary_fail
    
    mov x25, #0
    mov x26, #1 // bool result
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

Lprimary_str_replace:
    // str.replace(old, new) -> str
    cmp x26, #2
    b.ne Lprimary_fail
    // Save/materialize the source before helper calls clobber x28.
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    
    // Parse old substring; materialize into a var (bit63-tagged) so codegen
    // loads it from a stack slot rather than emitting a bad huge immediate.
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #2
    b.ne Lprimary_fail
    // x1=val, x3=len, x4=var(-1 if literal)
    mov x0, x1
    mov x1, x3
    mov x2, x4
    bl _str_method_materialize_arg   // returns x0 = (var|bit63)
    LOAD_ADDR x9, str_replace_tmp_old_var
    str x0, [x9]
    
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lprimary_fail
    
    // Parse new substring (same materialization).
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #2
    b.ne Lprimary_fail
    mov x0, x1
    mov x1, x3
    mov x2, x4
    bl _str_method_materialize_arg
    LOAD_ADDR x9, str_replace_tmp_new_var
    str x0, [x9]
    
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    
    // Allocate result and record operation
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #98 // op_str_replace
    mov x1, x23 // dest
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9] // source var (saved)
    LOAD_ADDR x9, str_replace_tmp_old_var
    ldr x3, [x9] // old var (bit63 tagged)
    LOAD_ADDR x9, str_replace_tmp_new_var
    ldr x4, [x9] // new var (bit63 tagged)
    bl _record_operation4
    cbnz x0, Lprimary_fail
    
    mov x25, #0
    mov x26, #2
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

Lprimary_str_split:
    // str.split(sep) -> list<str>. The result is a REAL, indexable/iterable list:
    // a fixed-capacity block is reserved in the compile-time list pool (its base
    // is a compile-time immediate), and the runtime _str_split fills that block
    // with malloc'd piece pointers and writes the piece count into
    // list_base_counts[base]. The base is flagged runtime-count so .length() and
    // for-in read the count at run time instead of folding the reserved capacity.
    cmp x26, #2
    b.ne Lprimary_fail
    // Capture/materialize the source string before helper calls clobber x28.
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail

    // Parse separator (must be str); materialize into a bit63-tagged var slot so
    // codegen loads it from the stack rather than as a huge immediate.
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #2
    b.ne Lprimary_fail
    mov x0, x1
    mov x1, x3
    mov x2, x4
    bl _str_method_materialize_arg
    LOAD_ADDR x9, str_split_tmp_sep_var
    str x0, [x9]

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    // Reserve a 64-element block in the list pool; base = current pool count.
    // GROW the pool (realloc-double) until it can hold base+64 elements instead
    // of hard-failing at a fixed cap. x23 (base) is callee-saved and preserved
    // across _snc_grow_list_pool (which saves x19-x24). The list_base_is_runtime/
    // list_base_counts writes below use LOAD_TBL so they see the current buffer.
    LOAD_ADDR x9, list_pool_count
    ldr x23, [x9]              // base
Lsplit_reserve_grow:
    add x10, x23, #64          // need capacity for base+64 elements
    LOAD_ADDR x9, list_pool_capacity
    ldr x11, [x9]
    cmp x10, x11
    b.le Lsplit_reserve_ok
    bl _snc_grow_list_pool
    b Lsplit_reserve_grow
Lsplit_reserve_ok:
    LOAD_ADDR x9, list_pool_count
    str x10, [x9]
    // Flag this base as a runtime-count list and zero its runtime count.
    LOAD_TBL x9, list_base_is_runtime
    mov w11, #1
    strb w11, [x9, x23]
    LOAD_TBL x9, list_base_counts
    str xzr, [x9, x23, lsl #3]

    // Record op 99: arg0=base, arg1=source var, arg2=sep var (bit63), arg3=0.
    mov x0, #99
    mov x1, x23
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9]
    LOAD_ADDR x9, str_split_tmp_sep_var
    ldr x3, [x9]
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lprimary_fail

    // Return the reserved base as a list<str> value: metadata = (2<<32)|64
    // (element type str=2 in the high 32 bits, reserved capacity in the low 32).
    mov x25, x23              // value = pool base
    mov x26, #4               // unified list type ID
    mov x27, #64             // low 32 = reserved capacity
    movk x27, #2, lsl #32    // high 32 = element type str (2)
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_str_upper:
    // str.upper() -> str
    cmp x26, #2
    b.ne Lprimary_fail
    // Save (or materialize) the source var BEFORE any helper calls, since
    // _expect_char/_skip_whitespace/_allocate_temp_var clobber x28. A literal
    // source (x28 == -1) is materialized into a temp var (op 72), mirroring slice.
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    
    // Record operation
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #100 // op_str_upper
    mov x1, x23 // dest
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9] // source var (saved)
    bl _record_operation   // 3-arg: op, arg0=dest, arg1=source (op2 drops arg1!)
    cbnz x0, Lprimary_fail
    
    mov x25, #0
    mov x26, #2
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

Lprimary_str_lower:
    // str.lower() -> str
    cmp x26, #2
    b.ne Lprimary_fail
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    
    // Record operation
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #101 // op_str_lower
    mov x1, x23 // dest
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9] // source var (saved)
    bl _record_operation   // 3-arg: op, arg0=dest, arg1=source (op2 drops arg1!)
    cbnz x0, Lprimary_fail
    
    mov x25, #0
    mov x26, #2
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

// Helper: capture the string-method source operand into str_method_src_var.
// Uses x25 (val), x27 (len), x28 (var) from the current primary. If the source
// is a literal (x28 == -1) it is materialized into a temp var via op 72 so the
// runtime helpers always receive a real stack slot holding the string pointer.
// Returns x0 = 0 on success, non-zero on failure.
_str_method_prepare_source:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    // Read the source operand from the snapshot taken at member-access entry.
    LOAD_ADDR x9, member_src_var
    ldr x21, [x9]        // source var (or -1 for a literal)
    cmn x21, #1
    b.ne Lsmps_have_var
    LOAD_ADDR x9, member_src_val
    ldr x0, [x9]         // literal value
    mov x1, #2           // type str
    LOAD_ADDR x9, member_src_len
    ldr x2, [x9]         // length
    bl _record_data_value
    mov x20, x0          // data id
    bl _allocate_temp_var
    mov x21, x0          // source now materialized in a temp var
    mov x0, #72
    mov x1, x21
    mov x2, x20
    bl _record_operation
    cbnz x0, Lsmps_fail
Lsmps_have_var:
    LOAD_ADDR x9, str_method_src_var
    str x21, [x9]
    mov x0, #0
    b Lsmps_ret
Lsmps_fail:
    mov x0, #1
Lsmps_ret:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// Helper: materialize a string argument into a bit63-tagged var slot so codegen
// always loads it from a stack slot (never as a huge immediate). Inputs:
//   x0 = literal value, x1 = length, x2 = source var (-1 if a literal).
// Returns x0 = (var | bit63). On a literal it records the data (op 72) into a
// fresh temp var first.
_str_method_materialize_arg:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    mov x19, x0          // value
    mov x20, x1          // length
    mov x21, x2          // var (-1 if literal)
    cmn x21, #1
    b.ne Lsmma_have_var
    mov x0, x19
    mov x1, #2           // type str
    mov x2, x20
    bl _record_data_value
    mov x22, x0          // data id
    bl _allocate_temp_var
    mov x21, x0          // temp var holding the string
    mov x0, #72
    mov x1, x21
    mov x2, x22
    bl _record_operation
Lsmma_have_var:
    mov x9, #1
    lsl x9, x9, #63
    orr x0, x21, x9      // (var | bit63)
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lprimary_str_startswith:
    // str.startswith(prefix) -> bool
    cmp x26, #2
    b.ne Lprimary_fail
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #2
    b.ne Lprimary_fail
    mov x0, x1
    mov x1, x3
    mov x2, x4
    bl _str_method_materialize_arg
    mov x20, x0                 // (var | bit63)
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #110
    mov x1, x23
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9]
    mov x3, x20
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lprimary_fail
    mov x25, #0
    mov x26, #1                 // bool result
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

Lprimary_str_endswith:
    // str.endswith(suffix) -> bool
    cmp x26, #2
    b.ne Lprimary_fail
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #2
    b.ne Lprimary_fail
    mov x0, x1
    mov x1, x3
    mov x2, x4
    bl _str_method_materialize_arg
    mov x20, x0
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #111
    mov x1, x23
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9]
    mov x3, x20
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lprimary_fail
    mov x25, #0
    mov x26, #1                 // bool result
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

Lprimary_str_indexof:
    // str.indexof(substr) -> int (first index, or -1 if not found)
    cmp x26, #2
    b.ne Lprimary_fail
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #2
    b.ne Lprimary_fail
    mov x0, x1
    mov x1, x3
    mov x2, x4
    bl _str_method_materialize_arg
    mov x20, x0
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #112
    mov x1, x23
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9]
    mov x3, x20
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lprimary_fail
    mov x25, #0
    mov x26, #0                 // int result
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

Lprimary_str_trim:
    // str.trim() -> str (strips leading/trailing space/tab/newline/CR)
    cmp x26, #2
    b.ne Lprimary_fail
    bl _str_method_prepare_source
    cbnz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _allocate_temp_var
    mov x23, x0
    mov x0, #113
    mov x1, x23
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9]
    bl _record_operation
    cbnz x0, Lprimary_fail
    mov x25, #0
    mov x26, #2                 // str result
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

Lprimary_member_push:
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_push
    bl _match_cstr_span
    cbz x0, Lprimary_member_pop
    cmp x26, #4
    b.ne Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    and x9, x27, #0xFFFFFFFF
    LOAD_TBL x10, list_pool_values
    LOAD_TBL x11, list_pool_lengths
    add x12, x9, #1
    and x27, x27, #0xFFFFFFFF00000000
    orr x27, x27, x12
    str x19, [x10, x9, lsl #3]
    str x20, [x11, x9, lsl #3]
    mov x25, x9
    mov x26, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_member_pop:
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_pop
    bl _match_cstr_span
    cbz x0, Lprimary_member_contains
    cmp x26, #4
    b.ne Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    and x9, x27, #0xFFFFFFFF
    cmp x9, #0
    b.eq Lprimary_fail
    sub x9, x9, #1
    LOAD_TBL x10, list_pool_values
    ldr x25, [x10, x9, lsl #3]
    LOAD_TBL x11, list_pool_lengths
    lsr x26, x27, #32
    ldr x27, [x11, x9, lsl #3]
    add x12, x9, #1
    and x27, x27, #0xFFFFFFFF00000000
    orr x27, x27, x12
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_member_contains:
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_contains
    bl _match_cstr_span
    cbz x0, Lprimary_member_has
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    cmp x26, #4
    b.eq Lprimary_list_contains
    cmp x26, #8
    b.eq Lprimary_map_contains
    b Lprimary_fail

Lprimary_list_contains:
    and x9, x27, #0xFFFFFFFF
    LOAD_TBL x10, list_pool_values
    LOAD_TBL x11, list_pool_lengths
    lsr x23, x27, #32
    mov x24, #0
Llist_contains_loop:
    cmp x24, x9
    b.ge Llist_contains_not_found
    ldr x28, [x10, x24, lsl #3]
    ldr x25, [x11, x24, lsl #3]
    cmp x23, x20
    b.ne Llist_contains_next
    cmp x28, x19
    b.ne Llist_contains_next
    cmp x25, x21
    b.ne Llist_contains_next
    mov x25, #1
    mov x26, #1
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start
Llist_contains_next:
    add x24, x24, #1
    b Llist_contains_loop
Llist_contains_not_found:
    mov x25, #0
    mov x26, #1
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_map_contains:
    and x9, x27, #0xFFFFFFFF
    cbz x9, Lmap_contains_not_found
    lsr x23, x27, #40
    mov x24, #0
Lmap_contains_loop:
    cmp x24, x9
    b.ge Lmap_contains_not_found
    LOAD_TBL x10, map_pool_keys
    ldr x28, [x10, x24, lsl #3]
    LOAD_TBL x11, map_pool_key_lengths
    ldr x25, [x11, x24, lsl #3]
    cmp x23, x20
    b.ne Lmap_contains_next
    cbz x20, Lmap_contains_int_cmp
    cmp x25, x21
    b.ne Lmap_contains_next
    LOAD_TBL x10, map_pool_key_ptrs
    ldr x28, [x10, x24, lsl #3]
    mov x0, x28
    mov x1, x25
    mov x2, x19
    bl _compare_cstr
    cbz x0, Lmap_contains_found
    b Lmap_contains_next
Lmap_contains_int_cmp:
    cmp x28, x19
    b.eq Lmap_contains_found
    b Lmap_contains_next
Lmap_contains_found:
    mov x25, #1
    mov x26, #1
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start
Lmap_contains_next:
    add x24, x24, #1
    b Lmap_contains_loop
Lmap_contains_not_found:
    mov x25, #0
    mov x26, #1
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_member_has:
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_has
    bl _match_cstr_span
    cbz x0, Lprimary_member_keys
    cmp x26, #8
    b.ne Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    and x9, x27, #0xFFFFFFFF
    cbz x9, Lmap_has_not_found
    lsr x23, x27, #40
    mov x24, #0
Lmap_has_loop:
    cmp x24, x9
    b.ge Lmap_has_not_found
    LOAD_TBL x10, map_pool_keys
    ldr x28, [x10, x24, lsl #3]
    LOAD_TBL x11, map_pool_key_lengths
    ldr x25, [x11, x24, lsl #3]
    cmp x23, x20
    b.ne Lmap_has_next
    cbz x20, Lmap_has_int_cmp
    cmp x25, x21
    b.ne Lmap_has_next
    LOAD_TBL x10, map_pool_key_ptrs
    ldr x28, [x10, x24, lsl #3]
    mov x0, x28
    mov x1, x25
    mov x2, x19
    bl _compare_cstr
    cbz x0, Lmap_has_found
    b Lmap_has_next
Lmap_has_int_cmp:
    cmp x28, x19
    b.eq Lmap_has_found
    b Lmap_has_next
Lmap_has_found:
    mov x25, #1
    mov x26, #1
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start
Lmap_has_next:
    add x24, x24, #1
    b Lmap_has_loop
Lmap_has_not_found:
    mov x25, #0
    mov x26, #1
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_member_keys:
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_keys
    bl _match_cstr_span
    cbz x0, Lprimary_member_values
    cmp x26, #8
    b.ne Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    and x9, x27, #0xFFFFFFFF
    mov x25, #0
    mov x26, #4
    lsl x9, x9, #32
    orr x27, x25, x9
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_member_values:
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_values
    bl _match_cstr_span
    cbz x0, Lprimary_indexing
    cmp x26, #8
    b.ne Lprimary_fail
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail
    and x9, x27, #0xFFFFFFFF
    mov x25, #0
    mov x26, #4
    lsl x9, x9, #32
    orr x27, x25, x9
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_indexing:
    bl _advance_char
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    bl _parse_expr_value
    cbz x0, Lprimary_indexing_fail_restore
    mov x23, x1 // index
    mov x24, x2 // index type
    mov x21, x3 // index metadata/length
    mov x22, x4 // index source var slot
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    
    bl _skip_whitespace
    mov w0, #']'
    bl _expect_char
    cbz x0, Lprimary_fail
    
    cmp x26, #8 // map
    b.eq Lprimary_map_lookup_val
    cmp x26, #2 // str -> single-char index, lowered to slice(i, i+1)
    b.eq Lprimary_str_index
    cmp x26, #4 // list
    b.ne Lprimary_fail
    
    // If it's a list, index must be an int
    cmp x24, #0
    b.ne Lprimary_fail

    mov x20, #0 // op80 runtime-base flag

    // Function parameters carry their list pool base at runtime in their
    // stack slot. Do not fold `param[imm]` against compile-time pool 0.
    cmn x28, #1
    b.eq Lprimary_list_index_source_ready
    LOAD_ADDR x9, current_parse_fn_id
    ldr x9, [x9]
    cmn x9, #1
    b.eq Lprimary_list_index_source_ready
    LOAD_TBL x10, fn_scope_bases
    ldr x10, [x10, x9, lsl #3]
    cmp x28, x10
    b.lt Lprimary_list_index_source_ready
    LOAD_TBL x11, fn_param_counts
    ldr x11, [x11, x9, lsl #3]
    add x11, x10, x11
    cmp x28, x11
    b.ge Lprimary_list_index_source_ready
    mov x20, #4
    b Lprimary_list_index_runtime

Lprimary_list_index_source_ready:

    // If the local list was runtime-mutated (op 109 store), resolve reads against
    // runtime memory even for a constant index, so prior element writes are seen.
    cbnz x20, Lprimary_list_index_rtflag_done
    LOAD_TBL x9, list_base_is_runtime
    ldrb w9, [x9, x25]
    cbnz w9, Lprimary_list_index_runtime
Lprimary_list_index_rtflag_done:

    // If index expression came from a variable/temp slot, emit runtime load.
    cmn x22, #1
    b.ne Lprimary_list_index_runtime

    and x9, x27, #0xFFFFFFFF // count
    cmp x23, x9
    b.ge Lprimary_fail

    add x10, x25, x23 // pool index
    b Lprimary_list_index_load_pool

    Lprimary_list_index_runtime:
    // x25 = list pool base index
    // x22 = index var slot id
    // x27 = list metadata
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    bl _allocate_temp_var
    mov x19, x0 // dest var id
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16

    // op 80: list_load(dest, index_var, base_idx, flags)
    mov x0, #80
    mov x1, x19 // dest
    mov x2, x22 // use index slot id
    mov x3, x25 // base pool index
    cbz x20, Lprimary_list_index_base_ready
    mov x3, x28 // runtime list-base slot id
Lprimary_list_index_base_ready:

    lsr x9, x27, #32 // element type
    cmp x9, #2 // str
    cset x4, eq
    orr x4, x4, x20

    cmn x22, #1
    cset x9, eq
    orr x4, x4, x9, lsl #1
    b.ne Lprimary_list_index_runtime_args
    mov x2, x23 // pass immediate value
Lprimary_list_index_runtime_args:

    bl _record_operation4
    cbnz x0, Lprimary_fail

    mov x25, #0 // runtime value unknown
    lsr x26, x27, #32 // element type
    mov x27, #0 // runtime length unknown
    mov x28, x19 // var index
    b Lprimary_suffix_loop_start

Lprimary_indexing_fail_restore:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    b Lprimary_fail

Lprimary_str_index:
    // str[i] -> a 1-char string, lowered to op 102 (str_char_at). The index
    // may be an immediate (folded constant) or a runtime variable, so it is
    // passed like contains' substring: an immediate value, or a var slot with
    // bit63 set so codegen loads it from the stack at run time (fixes loops).
    // On entry: x25=val x26=2 x27=len x28=src var(-1 if literal);
    //           x23=index val, x24=index type, x22=index var slot(-1 if imm).
    cmp x24, #0
    b.ne Lprimary_fail          // index must be int
    LOAD_ADDR x9, str_method_sub_len
    str x23, [x9]               // stash index immediate value
    LOAD_ADDR x9, str_contains_tmp_substr_var
    str x22, [x9]               // stash index var slot (-1 if immediate)
    cmn x28, #1
    b.ne Lprimary_str_index_var_src
    // literal source -> materialize into a temp var (op 72)
    mov x0, x25
    mov x1, #2
    mov x2, x27
    bl _record_data_value
    mov x24, x0
    bl _allocate_temp_var
    LOAD_ADDR x9, str_method_src_var
    str x0, [x9]
    mov x1, x0
    mov x0, #72
    mov x2, x24
    bl _record_operation
    cbnz x0, Lprimary_fail
    b Lprimary_str_index_emit
Lprimary_str_index_var_src:
    LOAD_ADDR x9, str_method_src_var
    str x28, [x9]
Lprimary_str_index_emit:
    // Encode the index arg: immediate value, or (var slot | bit63).
    LOAD_ADDR x9, str_contains_tmp_substr_var
    ldr x20, [x9]               // index var slot
    cmn x20, #1
    b.ne Lprimary_str_index_var_arg
    LOAD_ADDR x9, str_method_sub_len
    ldr x20, [x9]               // immediate index value
    b Lprimary_str_index_arg_ready
Lprimary_str_index_var_arg:
    mov x9, #1
    lsl x9, x9, #63
    orr x20, x20, x9            // (var | bit63)
Lprimary_str_index_arg_ready:
    bl _allocate_temp_var
    mov x23, x0                 // dest
    mov x0, #102               // op str_char_at(dest, src_var, index)
    mov x1, x23
    LOAD_ADDR x9, str_method_src_var
    ldr x2, [x9]                // src var
    mov x3, x20                 // index (immediate or var|bit63)
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lprimary_fail
    mov x25, #0
    mov x26, #2                 // str
    mov x27, #0
    mov x28, x23
    b Lprimary_suffix_loop_start

    Lprimary_list_index_load_pool:
    LOAD_TBL x11, list_pool_values
    ldr x25, [x11, x10, lsl #3]
    LOAD_TBL x11, list_pool_lengths
    ldr x9, [x11, x10, lsl #3]
    lsr x26, x27, #32 // element type from metadata
    mov x27, x9 // element length
    mov x28, #-1
    b Lprimary_suffix_loop_start
Lprimary_map_lookup_val:
    lsr x9, x27, #40 // expected key type
    cmp x24, x9
    b.ne Lprimary_fail

    and x20, x27, #0xFFFFFFFF // count
    cbz x20, Lmap_lookup_not_found_val

    // If key came from a variable/temp slot, emit runtime load.
    cmn x22, #1
    b.ne Lprimary_map_lookup_runtime

    mov x22, #0 // loop counter
Lmap_lookup_loop_val:
    add x10, x25, x22
    LOAD_TBL x11, map_pool_keys
    ldr x12, [x11, x10, lsl #3]

    // If it's a string, we need to compare using _match_span_span
    cmp x24, #2
    b.eq Lmap_lookup_str_val

    // Not a string, normal compare
    cmp x12, x23
    b.eq Lmap_lookup_found_val
    b Lmap_lookup_next_val

Lmap_lookup_str_val:
    LOAD_TBL x11, map_pool_key_lengths
    ldr x13, [x11, x10, lsl #3]
    // x12=pool ptr, x13=pool len, x23=lookup ptr, x21=lookup len
    cmp x13, x21
    b.ne Lmap_lookup_next_val

    // Call _match_span_span(x12, x13, x23)
    stp x20, x22, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    mov x0, x12
    mov x1, x13
    mov x2, x23
    bl _match_span_span
    mov x12, x0 // result

    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x20, x22, [sp], #16

    cbnz x12, Lmap_lookup_found_val

Lmap_lookup_next_val:
    add x22, x22, #1
    cmp x22, x20
    b.lt Lmap_lookup_loop_val
    b Lmap_lookup_not_found_val

Lmap_lookup_not_found_val:
    LOAD_ADDR x0, msg_key_not_found
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lprimary_fail

Lprimary_map_lookup_runtime:
    // x25 = map pool base index
    // x22 = key var slot id
    // x27 = map metadata
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    bl _allocate_temp_var
    mov x19, x0 // dest var id
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16

    // op 82: map_load(dest, key_var, base_idx, packed_flags, fallback_str_id)
    mov x0, #82
    mov x1, x19 // dest
    mov x2, x22 // use key var slot id
    mov x3, x25 // base pool index
    and x4, x27, #0xFFFFFFFF // count
    lsr x9, x27, #40 // key type
    lsl x9, x9, #56
    orr x4, x4, x9
    ubfx x9, x27, #32, #8 // val type
    orr x4, x4, x9, lsl #48
    mov x5, #0 // fallback string-id for runtime map miss (only used for str values)
    cmp x9, #2
    b.ne Lprimary_map_lookup_runtime_emit
    LOAD_ADDR x0, kw_none
    mov x1, #2
    mov x2, #4
    bl _record_data_value
    mov x5, x0
Lprimary_map_lookup_runtime_emit:
    mov x0, #82
    mov x1, x19
    mov x2, x22
    mov x3, x25
    bl _record_operation5
    cbnz x0, Lprimary_fail

    mov x25, #0
    ubfx x26, x27, #32, #8 // val type
    mov x27, #0
    mov x28, x19
    b Lprimary_suffix_loop_start

Lmap_lookup_found_val:

    add x10, x25, x22 // restore x10 just in case
    LOAD_TBL x11, map_pool_values
    ldr x25, [x11, x10, lsl #3]
    LOAD_TBL x11, map_pool_lengths
    ldr x9, [x11, x10, lsl #3]
    ubfx x26, x27, #32, #8 // val_type
    mov x27, x9 // val length
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_identifier:
    bl _parse_identifier
    cbz x0, Lprimary_missing
    mov x19, x0
    mov x20, x1

    // Check for module qualified access (module.func)
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'.'
    b.ne Lprimary_check_keywords

    // A '.' follows. If this identifier names a known variable, the '.' is
    // MEMBER access (var.length, var.slice(...), obj.field, obj.method()),
    // which is resolved by the suffix loop after normal variable lookup -- it
    // must NOT be swallowed by module-qualified-access parsing. Only fall
    // through to module access when the identifier is not a variable.
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbnz x0, Lprimary_check_keywords

    // Handle a fully-qualified module call. Keep the original start pointer;
    // the final identifier before '(' is the function name and everything
    // before its preceding dot is the complete module path.
    mov x21, x19
Lprimary_module_segment:
    bl _advance_char  // consume '.'
    bl _parse_identifier
    cbz x0, Lprimary_missing
    mov x19, x0   // function name
    mov x20, x1   // function name length
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'.'
    b.eq Lprimary_module_segment
    cmp w0, #'('
    b.ne Lprimary_missing  // Must be a function call

    sub x22, x19, x21
    sub x22, x22, #1       // complete module path excludes final '.'
    
    // Look up the function in the specified module
    mov x0, x19  // function name
    mov x1, x20  // function name length
    mov x2, x21  // module name
    mov x3, x22  // module name length
    bl _lookup_module_function
    cmn x0, #1
    b.eq Lprimary_missing
    
    // Force exactly this owned function for one call. The plus-one encoding
    // leaves zero available for the normal unqualified lookup path.
    add x10, x0, #1
    LOAD_ADDR x9, forced_call_fn_id_plus1
    str x10, [x9]
    mov x0, x19
    mov x1, x20
    bl _call_function
    cbnz x0, Lprimary_fail
    mov x20, x1
    mov x21, x2
    LOAD_ADDR x9, fn_return_value
    ldr x1, [x9]
    mov x0, #1
    mov x2, x20
    cmp x20, #2
    b.eq Lprimary_fn_call_load_len
    cmp x20, #18
    b.eq Lprimary_fn_call_load_len
    cmp x20, #6
    b.eq Lprimary_fn_call_load_len
    cmp x20, #22
    b.eq Lprimary_fn_call_load_len
    cmp x20, #4
    b.eq Lprimary_fn_call_load_len
    cmp x20, #20
    b.eq Lprimary_fn_call_load_len
    b Lprimary_suffix_loop

Lprimary_check_keywords:
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_none
    bl _match_cstr_span
    cbnz x0, Lprimary_none

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_true
    bl _match_cstr_span
    cbnz x0, Lprimary_true

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_false
    bl _match_cstr_span
    cbnz x0, Lprimary_false
    
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_cast
    bl _match_cstr_span
    cbz x0, Lprimary_kw_after_cast
    bl _lookahead_is_lparen
    cbnz x0, Lprimary_cast
Lprimary_kw_after_cast:

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_address
    bl _match_cstr_span
    cbz x0, Lprimary_kw_after_address
    bl _lookahead_is_lparen
    cbnz x0, Lprimary_address
Lprimary_kw_after_address:

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_value
    bl _match_cstr_span
    cbz x0, Lprimary_kw_after_value
    bl _lookahead_is_lparen
    cbnz x0, Lprimary_value
Lprimary_kw_after_value:

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_alloc
    bl _match_cstr_span
    cbz x0, Lprimary_kw_after_alloc
    bl _lookahead_is_lparen
    cbnz x0, Lprimary_alloc
Lprimary_kw_after_alloc:

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_self
    bl _match_cstr_span
    cbnz x0, Lprimary_self

    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lprimary_try_fn_call
    b Lprimary_suffix_loop


Lprimary_try_fn_call:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lprimary_unknown_var
    mov x0, x19
    mov x1, x20
    bl _call_function
    cbnz x0, Lprimary_fail
    mov x22, x1
    mov x23, x2
    mov x24, x3
    mov x25, x4
    LOAD_ADDR x9, compilation_mode
    ldr x9, [x9]
    cbnz x9, Lprimary_fn_call_compiled_result
    mov x20, x1
    mov x21, x2
    LOAD_ADDR x9, fn_return_value
    ldr x1, [x9]
    mov x0, #1
    mov x2, x20
    cmp x20, #2
    b.eq Lprimary_fn_call_load_len
    cmp x20, #18
    b.eq Lprimary_fn_call_load_len
    cmp x20, #6
    b.eq Lprimary_fn_call_load_len
    cmp x20, #22
    b.eq Lprimary_fn_call_load_len
    cmp x20, #4
    b.eq Lprimary_fn_call_load_len
    cmp x20, #20
    b.eq Lprimary_fn_call_load_len
    cmp x20, #5
    b.eq Lprimary_fn_call_load_len
    cmp x20, #21
    b.ne Lprimary_fn_call_non_str
Lprimary_fn_call_load_len:
    LOAD_ADDR x9, fn_return_length
    ldr x3, [x9]
    cmp x20, #6
    b.eq Lprimary_fn_call_dec_len
    cmp x20, #22
    b.ne Lprimary_fn_call_done
Lprimary_fn_call_dec_len:
    mov x3, x21
    b Lprimary_fn_call_done
Lprimary_fn_call_non_str:
    mov x3, #0
Lprimary_fn_call_done:
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_fn_call_compiled_result:
    mov x0, #1
    mov x1, x22
    mov x2, x23
    mov x3, x24
    mov x4, x25
    b Lprimary_suffix_loop

Lprimary_true:
    mov x0, #1
    mov x1, #1
    mov x2, #1 // bool
    mov x3, #0
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_self:
    LOAD_ADDR x9, current_self_type
    ldr x2, [x9]
    cbz x2, Lprimary_fail
    LOAD_ADDR x9, current_self_instance
    ldr x1, [x9]
    LOAD_ADDR x9, current_self_meta
    ldr x3, [x9]
    mov x0, #1
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_false:
    mov x0, #1
    mov x1, #0
    mov x2, #1 // bool
    mov x3, #0
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_none:
    mov x0, #1
    mov x1, #-1
    mov x2, #7
    mov x3, #0
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_number:
    bl _parse_numeric_literal
    cbz x0, Lprimary_fail
    // Store literal in a variable slot
    // x1=value, x2=type, x3=metadata, x4=-1 (no slot yet)
    cmp x4, #-1
    b.ne Lprimary_suffix_loop  // Already has a slot
    // Save value/type/metadata across the calls below.
    stp x1, x2, [sp, #-16]!  // [sp+16]=value, [sp+24]=type (after next push)
    stp x3, x4, [sp, #-16]!  // [sp]=metadata, [sp+8]=-1
    // Allocate a temp slot for the literal. _define_variable expects
    // x0=name_ptr, x1=len, x2=value, x3=const, x4=type, x5=length and
    // returns the new slot index in x4 (x0=0 on success).
    // IMPORTANT: the name must be a valid pointer with length 0 so that
    // _lookup_variable can never match (or dereference) this hidden temp.
    // Passing the literal value/type here (as before) poisoned the table:
    // e.g. 1.50 -> name_ptr=150, name_len=6, and any 6-char identifier
    // lookup then dereferenced address 150 and crashed the compiler.
    LOAD_ADDR x0, hidden_var_name_storage // valid address, never matched
    mov x1, #0          // zero-length name: cannot equal any identifier
    ldr x2, [sp, #16]   // compile-time value
    mov x3, #0          // not const
    ldr x4, [sp, #24]   // real type
    ldr x5, [sp]        // length/scale metadata
    bl _define_variable
    mov x21, x4  // real slot index returned by _define_variable
    // Record the store: kind=1 (store_var), arg0=slot, arg1=literal value.
    ldr x2, [sp, #16]  // reload the literal value as arg1
    mov x0, #1  // store_var operation
    mov x1, x21  // arg0 = dest slot
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    // Restore the real return registers: x1=value, x2=type, x3=metadata.
    ldp x3, x4, [sp], #16  // x3=metadata, x4=-1
    ldp x1, x2, [sp], #16  // x1=value, x2=type
    mov x4, x21  // var index = temp slot
    b Lprimary_suffix_loop

Lprimary_string:
    bl _parse_string_literal
    cbz x0, Lprimary_fail
    // x1=ptr, x2=len, x3=interpolated flag
    cbnz x3, Lprimary_string_interpolated
    mov x3, x2 // length
    mov x2, #2 // type str
    mov x0, #1
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_string_interpolated:
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    mov x19, x1 // full string content ptr
    mov x20, x2 // full string content len
    mov x21, #0 // current offset relative to x19
    mov x22, #-1 // result var id (-1 = none yet)

Lprimary_interp_loop:
    cmp x21, x20
    b.ge Lprimary_interp_done
    
    // Find next '{'
    mov x23, x21
Lprimary_interp_find_brace:
    cmp x23, x20
    b.ge Lprimary_interp_last_part
    add x9, x19, x23
    ldrb w10, [x9]
    cmp w10, #'{'
    b.eq Lprimary_interp_part_found
    add x23, x23, #1
    b Lprimary_interp_find_brace

Lprimary_interp_part_found:
    // Prefix literal: [x21, x23)
    sub x1, x23, x21
    cbz x1, Lprimary_interp_expr_start
    
    add x0, x19, x21
    mov x1, #2 // type str
    sub x2, x23, x21 // len
    bl _record_data_value
    mov x24, x0 // data id
    
    bl _allocate_temp_var
    mov x25, x0 // temp var id
    
    mov x0, #72 // store_str_lit
    mov x1, x25
    mov x2, x24
    bl _record_operation
    
    cmn x22, #1
    b.ne Lprimary_interp_prefix_concat
    mov x22, x25
    b Lprimary_interp_expr_start

Lprimary_interp_prefix_concat:
    bl _allocate_temp_var
    mov x26, x0
    mov x0, #60 // concat_str
    mov x1, x26 // dest
    mov x2, x22 // left
    mov x3, x25 // right
    mov x4, #0  // flags: both are vars
    bl _record_operation4
    mov x22, x26

Lprimary_interp_expr_start:
    // Update cursor to just after '{'
    add x23, x23, #1
    // Use the active source buffer. Imported modules are parsed from their own
    // heap buffers, so subtracting the compiler's primary `buffer` produced a
    // wild cursor offset whenever interpolation appeared inside a module.
    LOAD_ADDR x9, source_ptr
    ldr x10, [x9]
    sub x11, x19, x10
    add x11, x11, x23
    LOAD_ADDR x9, cursor_pos
    str x11, [x9]
    
    bl _parse_expr_value
    cbz x0, Linterp_fail
    mov x24, x1 // value
    mov x25, x2 // type
    mov x26, x4 // var id
    
    bl _skip_whitespace
    mov w0, #'}'
    bl _expect_char
    cbz x0, Linterp_fail
    
    // Cast result to str if needed
    cmp x25, #2
    b.eq Lprimary_interp_expr_is_str
    
    mov x0, x25
    mov x1, #2
    mov x2, x24
    mov x3, x26
    bl _emit_cast_op
    mov x26, x0 // result var id
    b Lprimary_interp_expr_concat

Lprimary_interp_expr_is_str:
    cmn x26, #1
    b.ne Lprimary_interp_expr_concat
    // Immediate string - intern it
    mov x0, x24
    mov x1, #2
    mov x2, #0 // length unknown
    bl _record_data_value
    mov x24, x0
    bl _allocate_temp_var
    mov x26, x0
    mov x0, #72
    mov x1, x26
    mov x2, x24
    bl _record_operation

Lprimary_interp_expr_concat:
    cmn x22, #1
    b.ne Lprimary_interp_expr_concat_real
    mov x22, x26
    b Lprimary_interp_update_offset

Lprimary_interp_expr_concat_real:
    bl _allocate_temp_var
    mov x27, x0 // Safe register.
    mov x0, #60 // concat_str
    mov x1, x27 // dest
    mov x2, x22 // left
    mov x3, x26 // right
    mov x4, #0  // flags: both are vars
    bl _record_operation4
    mov x22, x27


Lprimary_interp_update_offset:
    // cursor_pos is an offset from the active source_ptr.
    // x19 is an absolute pointer into that source buffer.
    // x21 must be the new offset relative to x19 (the string content start).
    LOAD_ADDR x9, cursor_pos
    ldr x11, [x9]              // x11 = current cursor offset from source base
    LOAD_ADDR x9, source_ptr
    ldr x9, [x9]
    sub x10, x19, x9           // x10 = string-content offset from source base
    sub x21, x11, x10          // x21 = cursor offset relative to string content start
    b Lprimary_interp_loop

Lprimary_interp_last_part:
    // Literal from x21 to x20
    sub x1, x20, x21
    cbz x1, Lprimary_interp_done
    
    add x0, x19, x21
    mov x1, #2
    sub x2, x20, x21
    bl _record_data_value
    mov x24, x0
    
    bl _allocate_temp_var
    mov x25, x0
    mov x0, #72
    mov x1, x25
    mov x2, x24
    bl _record_operation
    
    cmn x22, #1
    b.ne Lprimary_interp_last_concat
    mov x22, x25
    b Lprimary_interp_done

Lprimary_interp_last_concat:
    bl _allocate_temp_var
    mov x26, x0
    mov x0, #60 // concat_str
    mov x1, x26 // dest
    mov x2, x22 // left
    mov x3, x25 // right
    mov x4, #0  // flags: both are vars
    bl _record_operation4
    mov x22, x26

Lprimary_interp_done:
    // Restore cursor past the entire literal (content + closing quote)
    LOAD_ADDR x9, source_ptr
    ldr x10, [x9]
    sub x11, x19, x10
    add x11, x11, x20
    add x11, x11, #1
    LOAD_ADDR x9, cursor_pos
    str x11, [x9]

    mov x1, #0
    mov x2, #2
    mov x3, #0
    mov x4, x22
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    b Lprimary_suffix_loop

Linterp_fail:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    b Lprimary_fail

_emit_cast_op:
    // x0=src_type, x1=dst_type, x2=src_val, x3=src_var
    // Returns x0=new_var_id
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    // Currently only supports int->str (73) and bool->str (future)
    cmp x20, #2
    b.ne Lemit_cast_unsupported
    cmp x19, #0
    b.eq Lemit_cast_int_to_str_op

Lemit_cast_unsupported:
    mov x0, #-1
    b Lemit_cast_ret

Lemit_cast_int_to_str_op:
    bl _allocate_temp_var
    mov x23, x0

    mov x0, #73
    mov x1, x23
    mov x2, x22
    bl _record_operation
    mov x0, x23

Lemit_cast_ret:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
// address(varname) — takes address of a named variable
// Returns type=9 (ref), value=var_slot_idx, metadata=element_type
Lprimary_address:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lprimary_fail
    mov x21, x0   // var name ptr
    mov x22, x1   // var name len

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    // Look up the variable to get its type
    mov x0, x21
    mov x1, x22
    bl _lookup_variable
    cbz x0, Lprimary_fail
    // x4 = var_idx, x2 = type, x3 = length (metadata)
    mov x19, x4   // var_idx
    mov x23, x2   // element type

    // Allocate temp var for the resulting pointer
    stp x19, x23, [sp, #-16]!
    bl _allocate_temp_var
    mov x20, x0 // dest var id
    ldp x19, x23, [sp], #16

    // emit op_address (83)
    mov x0, #83
    mov x1, x20 // dest var id
    mov x2, x19 // source var idx
    bl _record_operation
    cbnz x0, Lprimary_fail

    mov x0, #1
    mov x1, #0
    mov x2, #9    // ref type
    mov x3, x23   // element type
    mov x4, x20
    b Lprimary_suffix_loop

// value(ptr_var) — dereference a ref<T>
// Returns type=element_type, value=<dereferenced>
Lprimary_value:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail

    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #9    // must be ref type
    b.ne Lprimary_fail
    mov x21, x1   // pointer value
    mov x22, x4   // ptr var id
    mov x23, x3   // element type stored in metadata

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    // Allocate temp var for deref result
    stp x21, x22, [sp, #-16]!
    stp x23, xzr, [sp, #-16]!
    bl _allocate_temp_var
    mov x20, x0 // dest var id
    ldp x23, xzr, [sp], #16
    ldp x21, x22, [sp], #16

    // Emit op_deref (84)
    mov x0, #84
    mov x1, x20 // dest
    mov x2, x21 // ptr value (if imm)
    mov x3, x22 // ptr var id
    mov x4, x23 // element type
    bl _record_operation4
    cbnz x0, Lprimary_fail

    mov x0, #1
    mov x1, #0
    mov x2, x23   // element type
    mov x3, #0
    mov x4, x20
    b Lprimary_suffix_loop

// alloc(size_expr) — malloc wrapper, returns ref<byte>
Lprimary_alloc:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lprimary_fail

    bl _parse_expr_value
    cbz x0, Lprimary_fail
    cmp x2, #0    // must be int
    b.ne Lprimary_fail
    mov x21, x1   // size value
    mov x22, x4   // size var idx

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    // Allocate temp var for the allocated pointer
    stp x21, x22, [sp, #-16]!
    bl _allocate_temp_var
    mov x20, x0 // dest var id
    ldp x21, x22, [sp], #16

    // emit op_alloc (85)
    mov x0, #85
    mov x1, x20 // dest
    mov x2, x21 // size value
    mov x3, x22 // size var idx
    bl _record_operation3
    cbnz x0, Lprimary_fail

    mov x0, #1
    mov x1, #0
    mov x2, #9    // ref type
    mov x3, #3    // element type = byte
    mov x4, x20
    b Lprimary_suffix_loop

Lprimary_missing:

    LOAD_ADDR x0, msg_expected_expr
    bl _report_error_prefix
    b Lprimary_fail

Lprimary_unknown_var:
    LOAD_ADDR x0, msg_unknown_var
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr

Lprimary_type_mismatch:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #0
    b Lprimary_return

Lprimary_fail:
    mov x0, #0

Lprimary_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lprimary_cast:
    bl _parse_cast_expression
    b Lprimary_return

_pow10_u64:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x1, #1
    mov x2, #10
Lpow10_loop:
    cbz x0, Lpow10_done
    mul x1, x1, x2
    sub x0, x0, #1
    b Lpow10_loop
Lpow10_done:
    mov x0, x1
    ldp x29, x30, [sp], #16
    ret

_parse_decimal_type_suffix:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lparse_dec_suffix_fail
    bl _parse_number
    cbz x0, Lparse_dec_suffix_fail
    mov x19, x1
    mov w0, #')'
    bl _expect_char
    cbz x0, Lparse_dec_suffix_fail
    mov x0, #1
    mov x1, x19
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
Lparse_dec_suffix_fail:
    mov x0, #0
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_type_spec:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    // Alternate array-type syntax `[T]` == `list<T>` (used by the paren-less
    // dialect, e.g. `fn f(xs: [int])` / `[int] nums = [...]`). Peek for '[';
    // if present, parse the element type and emit the same list encoding.
    bl _peek_char
    cmp w0, #'['
    b.eq Lparse_type_bracket_list

    bl _parse_identifier
    cbz x0, Lparse_type_fail
    mov x19, x0
    mov x20, x1

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_int
    bl _match_cstr_span
    cbnz x0, Lparse_type_int

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_bool
    bl _match_cstr_span
    cbnz x0, Lparse_type_bool

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_byte
    bl _match_cstr_span
    cbnz x0, Lparse_type_byte

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_str
    bl _match_cstr_span
    cbnz x0, Lparse_type_str

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_dec
    bl _match_cstr_span
    cbnz x0, Lparse_type_dec

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_error
    bl _match_cstr_span
    cbnz x0, Lparse_type_error

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_list
    bl _match_cstr_span
    cbnz x0, Lparse_type_list

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_map
    bl _match_cstr_span
    cbnz x0, Lparse_type_map

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_ref
    bl _match_cstr_span
    cbnz x0, Lparse_type_ref

    mov x0, x19
    mov x1, x20
    bl _lookup_blueprint_id
    cbz x0, Lparse_type_fail
    mov x2, x1
    mov x0, #1
    mov x1, #10
    b Lparse_type_return

Lparse_type_fail:
    mov x0, #0
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lparse_type_int:
    mov x0, #1
    mov x1, #0
    mov x2, #0
    b Lparse_type_return
Lparse_type_bool:
    mov x0, #1
    mov x1, #1
    mov x2, #0
    b Lparse_type_return
Lparse_type_byte:
    mov x0, #1
    mov x1, #3
    mov x2, #0
    b Lparse_type_return
Lparse_type_str:
    mov x0, #1
    mov x1, #2
    mov x2, #0
    b Lparse_type_return
Lparse_type_dec:
    bl _parse_decimal_type_suffix
    cbz x0, Lparse_type_fail
    mov x2, x1
    mov x1, #6
    mov x0, #1
    b Lparse_type_return

Lparse_type_error:
    mov x0, #1
    mov x1, #7
    mov x2, #0
    b Lparse_type_return

Lparse_type_list:
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lparse_type_fail
    bl _skip_whitespace
    
    // Support nested/any type
    bl _parse_type_spec
    cbz x0, Lparse_type_fail
    mov x19, x1 // element type
    
    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lparse_type_fail
    mov x0, #1
    mov x1, #4 // base list type
    lsl x2, x19, #32 // list metadata: element type in upper bits, unknown count=0
    b Lparse_type_return

Lparse_type_bracket_list:
    // `[T]` array-type shorthand -> same encoding as `list<T>`.
    bl _advance_char // consume '['
    bl _skip_whitespace
    bl _parse_type_spec // element type (recursion supports nested `[[int]]`)
    cbz x0, Lparse_type_fail
    mov x19, x1 // element type
    bl _skip_whitespace
    mov w0, #']'
    bl _expect_char
    cbz x0, Lparse_type_fail
    mov x0, #1
    mov x1, #4 // base list type
    lsl x2, x19, #32 // element type in upper bits
    b Lparse_type_return

Lparse_type_ref:
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lparse_type_fail
    bl _skip_whitespace
    
    bl _parse_type_spec
    cbz x0, Lparse_type_fail
    mov x19, x1 // element type
    
    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lparse_type_fail
    cmp x19, #10
    b.ne Lparse_type_ref_plain
    mov x0, #1
    mov x1, #11 // object ref type
    mov x2, x2
    b Lparse_type_return
Lparse_type_ref_plain:
    mov x0, #1
    mov x1, #9 // base ref type
    mov x2, x19 // store element type
    b Lparse_type_return

Lparse_type_map:
    bl _skip_whitespace
    mov w0, #'<'
    bl _expect_char
    cbz x0, Lparse_type_fail
    bl _skip_whitespace
    
    bl _parse_type_spec
    cbz x0, Lparse_type_fail
    mov x19, x1 // key type
    
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lparse_type_fail
    bl _skip_whitespace
    
    bl _parse_type_spec
    cbz x0, Lparse_type_fail
    mov x20, x1 // value type
    
    bl _skip_whitespace
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lparse_type_fail
    
    mov x0, #1
    mov x1, #8 // base map type ID
    lsl x2, x19, #32
    orr x2, x2, x20 // metadata: key_type in upper, value_type in lower
    b Lparse_type_return

Lparse_type_return:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'?'
    b.ne Lparse_type_return_done
    bl _advance_char
    add x1, x1, #16
Lparse_type_return_done:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_cast_expression:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lcast_fail
    bl _parse_expr_value
    cbz x0, Lcast_fail
    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x24, x4

    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lcast_fail
    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lcast_fail
    mov x22, x1
    mov x23, x2
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lcast_fail

    // Handle none source type specially
    cmp x20, #-1
    b.ne Lcast_not_none_source
    // If source is none, only allow nullable targets
    cmp x22, #16
    b.lt Lcast_type_mismatch
    cmp x22, #22
    b.gt Lcast_type_mismatch
    mov x0, #1
    mov x1, x19
    mov x2, x22
    mov x3, #0
    mov x4, #-1
    b Lcast_return

Lcast_not_none_source:
    cmp x22, #6
    b.eq Lcast_to_dec
    cmp x22, #0
    b.eq Lcast_to_int
    cmp x22, #2
    b.eq Lcast_to_str
    cmp x22, #1
    b.eq Lcast_to_bool
    b Lcast_type_mismatch

Lcast_to_str:
    // Convert int/bool/dec to string - simplified: copy value as string
    cmp x20, #0
    b.eq Lcast_int_to_str
    cmp x20, #1
    b.eq Lcast_bool_to_str
    cmp x20, #6
    b.eq Lcast_dec_to_str
    b Lcast_type_mismatch

Lcast_int_to_str:
    cmp x24, #-1
    b.ne Lcast_int_to_str_runtime
    mov x0, x19
    bl _i64_to_cstr
    cbz x0, Lcast_fail
    mov x19, x0
    bl _cstring_length
    mov x3, x0
    mov x0, #1
    mov x1, x19
    mov x2, #2
    mov x4, #-1
    b Lcast_return

Lcast_int_to_str_runtime:
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    bl _allocate_temp_var
    mov x25, x0
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    sub sp, sp, #16
    str x25, [sp]
    mov x0, #73
    ldr x1, [sp]
    mov x2, x24
    bl _record_operation
    cbnz x0, Lcast_int_to_str_runtime_fail
    ldr x25, [sp]
    add sp, sp, #16
    mov x0, #1
    mov x1, #0
    mov x2, #2
    mov x3, #0
    mov x4, x25
    b Lcast_return

Lcast_int_to_str_runtime_fail:
    add sp, sp, #16
    b Lcast_fail

Lcast_bool_to_str:
    // Convert bool to "true"/"false" string literals.
    // Runtime source vars must be converted at runtime, not via compile-time metadata.
    cmp x24, #-1
    b.ne Lcast_bool_to_str_runtime
    mov x0, #1
    mov x2, #2
    cmp x19, #0
    b.eq Lcast_bool_false
    LOAD_ADDR x1, kw_true
    mov x3, #4
    b Lcast_bool_str_done
Lcast_bool_false:
    LOAD_ADDR x1, kw_false
    mov x3, #5
Lcast_bool_str_done:
    mov x4, #-1
    b Lcast_return

Lcast_bool_to_str_runtime:
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    bl _allocate_temp_var
    mov x25, x0

    LOAD_ADDR x0, kw_true
    mov x1, #2
    mov x2, #4
    bl _record_data_value
    mov x26, x0

    LOAD_ADDR x0, kw_false
    mov x1, #2
    mov x2, #5
    bl _record_data_value
    mov x27, x0

    mov x0, #74
    mov x1, x25
    mov x2, x24
    mov x3, x26
    mov x4, x27
    bl _record_operation4
    cbnz x0, Lcast_bool_to_str_runtime_fail

    mov x0, #1
    mov x1, #0
    mov x2, #2
    mov x3, #0
    mov x4, x25
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    b Lcast_return

Lcast_bool_to_str_runtime_fail:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    b Lcast_fail

Lcast_dec_to_str:
    // Convert decimal scaled value to a real string.
    mov x0, x19
    mov x1, x21
    bl _dec_to_cstr
    cbz x0, Lcast_fail
    mov x19, x0
    mov x0, x19
    bl _cstring_length
    mov x3, x0
    mov x0, #1
    mov x1, x19
    mov x2, #2
    mov x4, #-1
    b Lcast_return

Lcast_to_bool:
    // Convert int/none to bool
    cmp x20, #0
    b.eq Lcast_int_to_bool
    cmp x20, #1
    b.eq Lcast_bool_same
    cmp x20, #6
    b.eq Lcast_dec_to_bool
    cmp x20, #7
    b.eq Lcast_none_to_bool
    b Lcast_type_mismatch

Lcast_int_to_bool:
    cmp x19, #0
    cset x19, ne
    mov x0, #1
    mov x1, x19
    mov x2, #1
    mov x3, #0
    mov x4, #-1
    b Lcast_return

Lcast_dec_to_bool:
    cmp x19, #0
    cset x19, ne
    mov x0, #1
    mov x1, x19
    mov x2, #1
    mov x3, #0
    mov x4, #-1
    b Lcast_return

Lcast_none_to_bool:
    mov x0, #1
    mov x1, #0
    mov x2, #1
    mov x3, #0
    mov x4, #-1
    b Lcast_return

Lcast_bool_same:
    mov x0, #1
    mov x1, x19
    mov x2, #1
    mov x3, #0
    mov x4, #-1
    b Lcast_return

Lcast_to_dec:
    cmp x20, #0
    b.eq Lcast_int_to_dec
    cmp x20, #6
    b.ne Lcast_type_mismatch
    cmp x21, x23
    b.eq Lcast_dec_same
    b.gt Lcast_dec_to_smaller
    sub x0, x23, x21
    bl _pow10_u64
    mul x19, x19, x0
    b Lcast_dec_finish
Lcast_dec_to_smaller:
    sub x0, x21, x23
    bl _pow10_u64
    sdiv x19, x19, x0
    b Lcast_dec_finish
Lcast_dec_same:
Lcast_dec_finish:
    mov x0, #1
    mov x1, x19
    mov x2, #6
    mov x3, x23
    mov x4, #-1
    b Lcast_return

Lcast_int_to_dec:
    mov x0, x23
    bl _pow10_u64
    mul x19, x19, x0
    mov x0, #1
    mov x1, x19
    mov x2, #6
    mov x3, x23
    mov x4, #-1
    b Lcast_return

Lcast_to_int:
    cmp x20, #0
    b.eq Lcast_int_same
    cmp x20, #6
    b.eq Lcast_dec_to_int
    cmp x20, #2
    b.eq Lcast_str_to_int_runtime
    b Lcast_type_mismatch

Lcast_dec_to_int:
    mov x0, x21
    bl _pow10_u64
    sdiv x19, x19, x0
    b Lcast_int_same

Lcast_str_to_int_runtime:
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    bl _allocate_temp_var
    mov x25, x0
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16

    // op 78: cast_str_to_int(dest, src_var)
    mov x0, #78
    mov x1, x25
    mov x2, x24
    bl _record_operation
    cbnz x0, Lcast_fail

    mov x0, #1
    mov x1, #0
    mov x2, #0
    mov x3, #0
    mov x4, x25
    b Lcast_return

Lcast_int_same:

    mov x0, #1
    mov x1, x19
    mov x2, #0
    mov x3, #0
    mov x4, #-1
    b Lcast_return

Lcast_type_mismatch:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    bl _write_newline_stderr
Lcast_fail:
    mov x0, #0

Lcast_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_numeric_literal:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    LOAD_ADDR x9, cursor_pos
    ldr x21, [x9]
    LOAD_ADDR x9, current_line
    ldr x22, [x9]

    bl _parse_number
    cbz x0, Lnum_lit_fail
    mov x19, x1
    bl _peek_char
    cmp w0, #'.'
    b.ne Lnum_lit_int
    bl _advance_char
    mov x20, #0
    mov x3, #0
Lnum_lit_frac_loop:
    bl _peek_char
    cmp w0, #'0'
    b.lt Lnum_lit_frac_done
    cmp w0, #'9'
    b.gt Lnum_lit_frac_done
    mov x9, #10
    mul x20, x20, x9
    sub w10, w0, #'0'
    add x20, x20, x10
    bl _advance_char
    add x3, x3, #1
    b Lnum_lit_frac_loop
Lnum_lit_frac_done:
    cbz x3, Lnum_lit_invalid
    mov x0, x3
    bl _pow10_u64
    mul x19, x19, x0
    add x19, x19, x20
    mov x0, #1
    mov x1, x19
    mov x2, #6
    mov x4, #-1
    b Lnum_lit_return

Lnum_lit_int:
    mov x0, #1
    mov x1, x19
    mov x2, #0
    mov x3, #0
    mov x4, #-1
    b Lnum_lit_return

Lnum_lit_invalid:
    LOAD_ADDR x0, msg_invalid_decimal
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lnum_lit_fail

Lnum_lit_fail:
    LOAD_ADDR x9, cursor_pos
    str x21, [x9]
    LOAD_ADDR x9, current_line
    str x22, [x9]
    mov x0, #0

Lnum_lit_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_identifier:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lident_fail

    cmp w0, #'A'
    b.lt Lident_lower
    cmp w0, #'Z'
    b.le Lident_start_ok

Lident_lower:
    cmp w0, #'a'
    b.lt Lident_underscore
    cmp w0, #'z'
    b.le Lident_start_ok

Lident_underscore:
    cmp w0, #'_'
    b.ne Lident_fail

Lident_start_ok:
    bl _get_cursor_ptr
    mov x19, x0
    mov x20, #0

Lident_loop:
    bl _peek_char
    cbz w0, Lident_done
    cmp w0, #'A'
    b.lt Lident_check_lower
    cmp w0, #'Z'
    b.le Lident_take

Lident_check_lower:
    cmp w0, #'a'
    b.lt Lident_check_underscore
    cmp w0, #'z'
    b.le Lident_take

Lident_check_underscore:
    cmp w0, #'_'
    b.eq Lident_take
    cmp w0, #'0'
    b.lt Lident_done
    cmp w0, #'9'
    b.gt Lident_done

Lident_take:
    bl _advance_char
    add x20, x20, #1
    b Lident_loop

Lident_done:
    mov x0, x19
    mov x1, x20
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lident_fail:
    mov x0, #0
    mov x1, #0
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_number:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    bl _skip_whitespace
    mov x19, #0
    mov x20, #0

Lnum_loop:
    bl _peek_char
    cmp w0, #'0'
    b.lt Lnum_done
    cmp w0, #'9'
    b.gt Lnum_done
    mov x9, #10
    mul x19, x19, x9
    sub w10, w0, #'0'
    add x19, x19, x10
    bl _advance_char
    add x20, x20, #1
    b Lnum_loop

Lnum_done:
    cbz x20, Lnum_fail
    mov x0, #1
    mov x1, x19
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lnum_fail:
    mov x0, #0
    mov x1, #0
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_expect_char:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov w19, w0
    bl _skip_whitespace
    bl _peek_char
    cmp w0, w19
    b.ne Lexpect_fail
    bl _advance_char
    mov x0, #1
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lexpect_fail:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, single_char
    strb w19, [x0]
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #0
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_consume_optional_semicolon:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #';'
    b.ne Lconsume_semicolon_done
    bl _advance_char

Lconsume_semicolon_done:
    ldp x29, x30, [sp], #16
    ret

_consume_optional_else:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lconsume_else_restore

    mov x21, x0
    mov x22, x1
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_else
    bl _match_cstr_span
    cbz x0, Lconsume_else_restore

    mov x0, #1
    b Lconsume_else_return

Lconsume_else_restore:
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    mov x0, #0

Lconsume_else_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_consume_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x21, x0
    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lconsume_keyword_restore

    mov x22, x0
    mov x23, x1
    mov x0, x22
    mov x1, x23
    mov x2, x21
    bl _match_cstr_span
    cbz x0, Lconsume_keyword_restore

    mov x0, #1
    b Lconsume_keyword_return

Lconsume_keyword_restore:
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    mov x0, #0

Lconsume_keyword_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_skip_block_contents:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, #1

Lskip_block_loop:
    bl _peek_char
    cbz w0, Lskip_block_fail
    cmp w0, #'{'
    b.eq Lskip_block_open
    cmp w0, #'}'
    b.eq Lskip_block_close
    bl _advance_char
    b Lskip_block_loop

Lskip_block_open:
    bl _advance_char
    add x19, x19, #1
    b Lskip_block_loop

Lskip_block_close:
    bl _advance_char
    sub x19, x19, #1
    cbnz x19, Lskip_block_loop
    mov x0, #0
    b Lskip_block_return

Lskip_block_fail:
    LOAD_ADDR x0, msg_expected_char
    bl _report_error_prefix
    LOAD_ADDR x0, close_brace_char
    mov x1, #1
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #1

Lskip_block_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_try_parse_input_call:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Ltry_input_restore
    mov x21, x0
    mov x22, x1

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_input
    bl _match_cstr_span
    cbz x0, Ltry_input_restore

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Ltry_input_restore

    bl _parse_string_literal
    cbz x0, Ltry_input_restore
    mov x23, x1
    mov x24, x2

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Ltry_input_restore

    mov x0, #1
    mov x1, x23
    mov x2, x24
    b Ltry_input_return

Ltry_input_restore:
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    mov x0, #0

Ltry_input_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_string_literal:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'"'
    b.ne Lstr_lit_fail

    bl _advance_char
    bl _get_cursor_ptr
    mov x19, x0
    mov x20, #0
    mov x21, #0

Lstr_lit_loop:
    bl _peek_char
    cbz w0, Lstr_lit_fail
    cmp w0, #'"'
    b.eq Lstr_lit_done
    cmp w0, #'{'          // Check for interpolation start
    b.ne Lstr_lit_advance
    mov x21, #1           // Mark interpolation found

Lstr_lit_advance:
    bl _advance_char
    add x20, x20, #1
    b Lstr_lit_loop

Lstr_lit_done:
    bl _advance_char
    // x0 = success flag (bit 0)
    // x1 = string pointer
    // x2 = string length
    // x3 = interpolation flag (bit 0)
    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x3, x21
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lstr_lit_fail:
    mov x0, #0
    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_string_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl _parse_string_literal
    cbz x0, Lstr_val_fail
    mov x0, #1 // x1=ptr, x2=len already set
    ldp x29, x30, [sp], #16
    ret

Lstr_val_fail:
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

// ========================================================
// _parse_fn_definition
// Parses:  fn name(type param, type param, ...) -> retType { body }
// Stores the definition; skips the body.
// ========================================================
.global _parse_fn_definition
.global _call_function
.global _lookup_function
.global _parse_identifier
.global _skip_whitespace
.global _is_eof
.global _peek_char
.global _advance_char
.global _get_cursor_ptr

_skip_fn_definition:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // We are right after 'fn'. Skip to '{'
Lskip_fn_find_body:
    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lskip_fn_fail
    cmp w0, #'{'
    b.eq Lskip_fn_found_body
    bl _advance_char
    b Lskip_fn_find_body

Lskip_fn_found_body:
    bl _advance_char // consume '{'
    bl _skip_block_contents
    
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

Lskip_fn_fail:
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret

_parse_fn_definition:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    // Parse function name
    bl _parse_identifier
    cbz x0, Lfn_def_fail
    mov x19, x0   // name ptr
    mov x20, x1   // name len

    LOAD_ADDR x9, fn_name_override_ptr
    ldr x10, [x9]
    cbz x10, Lfn_def_name_ready
    mov x19, x10
    LOAD_ADDR x9, fn_name_override_len
    ldr x20, [x9]
Lfn_def_name_ready:

    mov x0, x19
    mov x1, x20
    bl _lookup_function
    cbz x0, Lfn_def_new
    mov x21, x1
    mov x26, #1
    b Lfn_def_after_name

Lfn_def_new:
    // Grow the malloc-backed fn tables on demand.
    LOAD_ADDR x9, fn_count
    ldr x21, [x9]
    LOAD_ADDR x10, fn_capacity
    ldr x10, [x10]
    cmp x21, x10
    b.lt Lfn_def_have_space
    bl _snc_grow_fns
Lfn_def_have_space:
    mov x26, #0

    // Store name
    LOAD_TBL x9, fn_name_ptrs
    str x19, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_name_lens
    str x20, [x9, x21, lsl #3]

Lfn_def_after_name:

    // Parse parameter list
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_def_fail

    mov x22, #0  // param count

Lfn_def_param_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.eq Lfn_def_params_done

    // If not first param, expect comma
    cbz x22, Lfn_def_parse_param
    mov w0, #','
    bl _expect_char
    cbz x0, Lfn_def_fail
    bl _skip_whitespace

Lfn_def_parse_param:
    cmp x22, #4
    b.ge Lfn_def_too_many_params

    // Disambiguate the default `type name` form from the colon dialect
    // `name: type` (e.g. `xs: [int]`, `target: int`). Save the cursor, read an
    // identifier, and peek for ':'. A ':' means the identifier is the NAME
    // (colon form); anything else (`<`, whitespace+ident, etc.) means it was a
    // TYPE, so restore the cursor and parse the normal `type name` form. This is
    // unambiguous because `list<int> xs` has `<` after `list`, never ':'.
    LOAD_ADDR x9, cursor_pos
    ldr x9, [x9]
    LOAD_ADDR x10, current_line
    ldr x10, [x10]
    stp x9, x10, [sp, #-16]!      // save cursor + line
    bl _parse_identifier
    cbz x0, Lfn_def_param_colon_restore
    stp x0, x1, [sp, #-16]!      // save candidate name ptr/len
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #':'
    b.ne Lfn_def_param_colon_pop_restore

    // --- colon form confirmed: `name: type` ---
    ldp x23, x24, [sp], #16     // x23=name ptr, x24=name len
    add sp, sp, #16             // discard saved cursor
    // store the name now (regs fresh, before parsing the type)
    mov x9, x21
    lsl x9, x9, #2
    add x9, x9, x22
    LOAD_TBL x10, fn_param_name_ptrs
    str x23, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_name_lens
    str x24, [x10, x9, lsl #3]
    bl _advance_char            // consume ':'
    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lfn_def_fail
    mov x25, x1                 // type
    mov x24, x2                 // type meta
    mov x9, x21
    lsl x9, x9, #2
    add x9, x9, x22
    LOAD_TBL x10, fn_param_types
    str x25, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_lengths
    str x24, [x10, x9, lsl #3]
    b Lfn_def_param_done

Lfn_def_param_colon_pop_restore:
    add sp, sp, #16             // discard saved name ptr/len
Lfn_def_param_colon_restore:
    ldp x9, x10, [sp], #16      // restore cursor + line
    LOAD_ADDR x11, cursor_pos
    str x9, [x11]
    LOAD_ADDR x11, current_line
    str x10, [x11]
    bl _parse_type_spec
    cbz x0, Lfn_def_fail
    mov x25, x1
    mov x24, x2

Lfn_def_param_store_type:
    // Store param type: fn_param_types[fn_idx * 4 + param_idx]
    mov x9, x21
    lsl x9, x9, #2         // fn_idx * 4
    add x9, x9, x22        // + param_idx
    LOAD_TBL x10, fn_param_types
    str x25, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_lengths
    str x24, [x10, x9, lsl #3]

    // Parse param name
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lfn_def_fail

    // Store param name
    mov x23, x0
    mov x24, x1
    mov x9, x21
    lsl x9, x9, #2
    add x9, x9, x22
    LOAD_TBL x10, fn_param_name_ptrs
    str x23, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_name_lens
    str x24, [x10, x9, lsl #3]
Lfn_def_param_done:
    // Optional default value: type name = expr
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'='
    b.ne Lfn_def_param_next
    bl _advance_char
    bl _parse_expr_value
    cbz x0, Lfn_def_fail
    mov x11, x1 // default value
    mov x12, x2 // default type
    mov x13, x3 // default length
    mov x9, x21
    lsl x9, x9, #2
    add x9, x9, x22
    LOAD_TBL x10, fn_param_lengths
    ldr x14, [x10, x9, lsl #3]
    cmp x25, #16
    b.ge Lfn_def_param_default_nullable
    cmp x12, x25
    b.eq Lfn_def_param_default_type_ok
    cmp x25, #3
    b.ne Lfn_def_fail
    cmp x12, #0
    b.ne Lfn_def_fail
    b Lfn_def_param_default_type_ok
Lfn_def_param_default_nullable:
    cmp x12, #7
    b.eq Lfn_def_param_default_type_ok
    cmp x12, x25
    b.eq Lfn_def_param_default_type_ok
    sub x15, x25, #16
    cmp x15, #3
    b.ne Lfn_def_param_default_nullable_exact
    cmp x12, #0
    b.eq Lfn_def_param_default_type_ok
Lfn_def_param_default_nullable_exact:
    cmp x12, x15
    b.ne Lfn_def_fail
Lfn_def_param_default_type_ok:
    cmp x25, #6
    b.eq Lfn_def_param_default_check_scale
    cmp x25, #22
    b.ne Lfn_def_param_default_store
    cmp x12, #7
    b.eq Lfn_def_param_default_store
Lfn_def_param_default_check_scale:
    cmp x13, x14
    b.ne Lfn_def_fail
Lfn_def_param_default_store:
    LOAD_TBL x10, fn_param_default_flags
    mov x14, #1
    str x14, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_default_values
    str x11, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_default_types
    str x12, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_default_lengths
    str x13, [x10, x9, lsl #3]

Lfn_def_param_next:

    add x22, x22, #1
    b Lfn_def_param_loop

Lfn_def_params_done:
    bl _advance_char // consume ')'

    // Store param count
    LOAD_TBL x9, fn_param_counts
    str x22, [x9, x21, lsl #3]
Lfn_def_count_done:

    // Check for optional -> return type
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'-'
    b.ne Lfn_def_no_return_type

    bl _advance_char
    bl _peek_char
    cmp w0, #'>'
    b.ne Lfn_def_fail
    bl _advance_char

    // Parse return type
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.eq Lfn_def_tuple_return
    bl _parse_type_spec
    cbz x0, Lfn_def_fail
    mov x25, x1
    mov x24, x2
    mov x11, #-1
    mov x12, #0
    b Lfn_def_store_ret

Lfn_def_tuple_return:
    bl _advance_char
    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lfn_def_fail
    mov x11, x1
    mov x12, x2
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lfn_def_fail
    bl _skip_whitespace
    bl _parse_type_spec
    cbz x0, Lfn_def_fail
    mov x13, x1
    mov x14, x2
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_def_fail
    mov x25, x11
    mov x24, x12
    mov x11, x13
    mov x12, x14
Lfn_def_store_ret:
    LOAD_TBL x9, fn_return_types
    str x25, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_return_decl_lengths
    str x24, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_return_extra_types
    str x11, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_return_extra_decl_lengths
    str x12, [x9, x21, lsl #3]
    b Lfn_def_expect_body

Lfn_def_no_return_type:
    // No return type, store -1
    mov x25, #-1
    LOAD_TBL x9, fn_return_types
    str x25, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_return_decl_lengths
    str xzr, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_return_extra_types
    str x25, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_return_extra_decl_lengths
    str xzr, [x9, x21, lsl #3]

Lfn_def_expect_body:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lfn_def_fail

    // Store cursor position of body start (also when refining preparse stubs)
    LOAD_ADDR x9, cursor_pos
    ldr x23, [x9]
    LOAD_ADDR x9, current_line
    ldr x24, [x9]
    LOAD_TBL x9, fn_body_cursors
    str x23, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_body_lines
    str x24, [x9, x21, lsl #3]
    LOAD_ADDR x9, source_ptr
    ldr x10, [x9]
    LOAD_TBL x9, fn_source_ptrs
    str x10, [x9, x21, lsl #3]
    LOAD_ADDR x9, source_len
    ldr x10, [x9]
    LOAD_TBL x9, fn_source_lens
    str x10, [x9, x21, lsl #3]

    // Record the actual fn table index of the fn just defined (x21 is the
    // fn's own index here, valid whether we reused a preparse stub or added a
    // new entry). Callers (e.g. blueprint method registration) must use this
    // instead of fn_count-1, which is wrong when a stub was reused.
    LOAD_ADDR x9, last_fn_def_index
    str x21, [x9]

    cbnz x26, Lfn_def_skip_count
    LOAD_ADDR x9, fn_count
    add x21, x21, #1
    str x21, [x9]
Lfn_def_skip_count:

    // Skip the body
    bl _skip_block_contents
    cbnz x0, Lfn_def_fail

    mov x0, #0
    b Lfn_def_return

Lfn_def_full:
    LOAD_ADDR x0, msg_too_many_fns
    mov x1, #2
    bl _write_cstr_fd
    b Lfn_def_fail

Lfn_def_too_many_params:
    LOAD_ADDR x0, msg_too_many_params
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    b Lfn_def_fail

Lfn_def_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #1

Lfn_def_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// ========================================================
// _lookup_function
// x0=name ptr, x1=name len
// Returns: x0=1 if found, x1=fn index
// ========================================================
_lookup_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, #0
    LOAD_ADDR x22, fn_count
    ldr x22, [x22]

Lfn_lookup_loop:
    cmp x21, x22
    b.ge Lfn_lookup_fail
    LOAD_TBL x9, fn_name_lens
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x20
    b.ne Lfn_lookup_next
    LOAD_TBL x9, fn_name_ptrs
    ldr x11, [x9, x21, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbnz x0, Lfn_lookup_found
Lfn_lookup_next:
    add x21, x21, #1
    b Lfn_lookup_loop

Lfn_lookup_found:
    mov x0, #1
    mov x1, x21
    b Lfn_lookup_return

Lfn_lookup_fail:
    mov x0, x19
    mov x1, x20
    bl _is_imported_function
    cbz x0, Lfn_lookup_not_imported
    mov x21, x1
    b Lfn_lookup_found
Lfn_lookup_not_imported:
    mov x0, #0

Lfn_lookup_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// Call-site lookup: local/same-module functions first, then only imports that
// are currently unqualified-visible. Definition and method lookup retain the
// broader historical _lookup_function behavior above.
_lookup_callable_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    mov x19, x0
    mov x20, x1
    mov x23, #-1
    LOAD_ADDR x9, current_parse_fn_id
    ldr x10, [x9]
    cmp x10, #0
    b.lt Lcallable_owner_ready
    LOAD_TBL x9, fn_module_ids
    ldr x23, [x9, x10, lsl #3]
Lcallable_owner_ready:
    LOAD_ADDR x9, fn_count
    ldr x22, [x9]
    mov x21, #0
Lcallable_lookup_loop:
    cmp x21, x22
    b.ge Lcallable_lookup_imported
    LOAD_TBL x9, fn_module_ids
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x23
    b.ne Lcallable_lookup_next
    LOAD_TBL x9, fn_name_lens
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x20
    b.ne Lcallable_lookup_next
    LOAD_TBL x9, fn_name_ptrs
    ldr x2, [x9, x21, lsl #3]
    mov x0, x19
    mov x1, x20
    bl _match_span_span
    cbnz x0, Lcallable_lookup_found
Lcallable_lookup_next:
    add x21, x21, #1
    b Lcallable_lookup_loop
Lcallable_lookup_imported:
    mov x0, x19
    mov x1, x20
    bl _is_imported_function
    cbz x0, Lcallable_lookup_fail
    mov x21, x1
Lcallable_lookup_found:
    mov x0, #1
    mov x1, x21
    b Lcallable_lookup_return
Lcallable_lookup_fail:
    mov x0, #0
    mov x1, #-1
Lcallable_lookup_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// ========================================================
// _call_function
// x0=name ptr, x1=name len
// Cursor should be right before '('
// Returns: x0=0 on success
// ========================================================
_call_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    sub sp, sp, #96

    mov x19, x0   // name ptr
    mov x20, x1   // name len
    LOAD_ADDR x9, cursor_pos
    ldr x25, [x9]
    LOAD_ADDR x9, current_line
    ldr x26, [x9]
    LOAD_ADDR x9, source_ptr
    ldr x10, [x9]
    str x10, [sp, #16]
    LOAD_ADDR x9, source_len
    ldr x10, [x9]
    str x10, [sp, #24]

    // Built-in: file_read(path)
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_file_read
    bl _match_cstr_span
    cbnz x0, Lfn_call_file_read

    // Built-in: file_write(path, content)
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_file_write
    bl _match_cstr_span
    cbnz x0, Lfn_call_file_write

    // Built-in: system(cmd) / exec(cmd) — run an external command; returns int status
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_system
    bl _match_cstr_span
    cbnz x0, Lfn_call_system
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_exec
    bl _match_cstr_span
    cbnz x0, Lfn_call_system

    // Built-in: argc() — number of command-line arguments (int)
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_argc
    bl _match_cstr_span
    cbnz x0, Lfn_call_argc

    // Built-in: argv(i) — the i-th command-line argument as a str
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_argv
    bl _match_cstr_span
    cbnz x0, Lfn_call_argv

    // Built-in: wait() — join all outstanding spawned threads (returns count)
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_wait
    bl _match_cstr_span
    cbnz x0, Lfn_call_wait

    // Built-in: await(task) — join one typed task and return its result.
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_await
    bl _match_cstr_span
    cbnz x0, Lfn_call_await

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_task_state
    bl _match_cstr_span
    cbnz x0, Lfn_call_task_state

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_task_error
    bl _match_cstr_span
    cbnz x0, Lfn_call_task_error

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_task_wait
    bl _match_cstr_span
    cbnz x0, Lfn_call_task_wait

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_cancel
    bl _match_cstr_span
    cbnz x0, Lfn_call_task_cancel

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_cancel_requested
    bl _match_cstr_span
    cbnz x0, Lfn_call_cancel_requested

    // Built-in: str(x) — convert an int/bool/str value to its string form
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_str
    bl _match_cstr_span
    cbnz x0, Lfn_call_str_builtin

    // Built-in: int(x) — convert a str/bool/int value to its integer form
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_int
    bl _match_cstr_span
    cbnz x0, Lfn_call_int_builtin

    // Built-in: len(x) — element count of a list / character count of a string
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_len
    bl _match_cstr_span
    cbnz x0, Lfn_call_len_builtin

    // Built-in: ord(s) — ASCII code (int) of the first character of a string.
    // A self-hosting prerequisite: SNlang char indexing s[i] yields a 1-char
    // string, and there was no way to get its numeric code for classification
    // (digit/letter/whitespace) — ord() provides it. Returns 0 for "".
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_ord
    bl _match_cstr_span
    cbnz x0, Lfn_call_ord

    // Managed runtime memory and growable StringBuilder built-ins.
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_mem_live
    bl _match_cstr_span
    cbnz x0, Lfn_call_mem_live
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_mem_bytes
    bl _match_cstr_span
    cbnz x0, Lfn_call_mem_bytes
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_mem_collect
    bl _match_cstr_span
    cbnz x0, Lfn_call_mem_collect
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_builder_new
    bl _match_cstr_span
    cbnz x0, Lfn_call_builder_new
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_builder_append
    bl _match_cstr_span
    cbnz x0, Lfn_call_builder_append
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_builder_append_int
    bl _match_cstr_span
    cbnz x0, Lfn_call_builder_append_int
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_builder_string
    bl _match_cstr_span
    cbnz x0, Lfn_call_builder_string
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_builder_clear
    bl _match_cstr_span
    cbnz x0, Lfn_call_builder_clear
    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_builder_length
    bl _match_cstr_span
    cbnz x0, Lfn_call_builder_length

    LOAD_ADDR x9, var_scope_base
    ldr x10, [x9]
    str x10, [sp]
    LOAD_ADDR x9, var_count
    ldr x22, [x9]

    // A qualified module call resolves an exact function before entering this
    // routine. Consume that one-shot override; normal calls honor selective
    // import visibility through _lookup_callable_function.
    LOAD_ADDR x9, forced_call_fn_id_plus1
    ldr x10, [x9]
    cbz x10, Lfn_call_lookup_name
    str xzr, [x9]
    sub x21, x10, #1
    b Lfn_call_lookup_done
Lfn_call_lookup_name:
    mov x0, x19
    mov x1, x20
    bl _lookup_callable_function
    cbz x0, Lfn_call_unknown
    mov x21, x1   // fn index
Lfn_call_lookup_done:

    // Save the current variable floor so locals can shadow globals.
    LOAD_ADDR x9, var_scope_base
    str x22, [x9]

    // Get param count
    LOAD_TBL x9, fn_param_counts
    ldr x23, [x9, x21, lsl #3]  // expected param count

    // Parse '(' and arguments
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail

    mov x24, #0  // parsed arg count

Lfn_call_arg_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.eq Lfn_call_args_done

    // If not first arg, expect comma
    cbz x24, Lfn_call_parse_arg
    mov w0, #','
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _skip_whitespace

Lfn_call_parse_arg:
    cmp x24, x23
    b.ge Lfn_call_wrong_args
    cmp x24, #4
    b.ge Lfn_call_wrong_args
    // Get the param type and name for this argument
    mov x9, x21
    lsl x9, x9, #2         // fn_idx * 4
    add x9, x9, x24        // + param_idx

    // Save param name info for defining variable
    LOAD_TBL x10, fn_param_name_ptrs
    ldr x25, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_name_lens
    ldr x26, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_types
    ldr x27, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_lengths
    ldr x5, [x10, x9, lsl #3]

    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    mov x28, x1  // arg value
    mov x6, x2   // arg type
    mov x7, x3   // arg length
    str x4, [sp, #8] // arg source slot id, -1 means immediate/non-slot value

    cmp x27, #16
    b.ge Lfn_call_check_nullable_arg
    cmp x6, x27
    b.ne Lfn_call_non_object_arg
    cmp x27, #10
    b.eq Lfn_call_check_object_arg_meta
    cmp x27, #11
    b.eq Lfn_call_check_object_arg_meta
    b Lfn_call_define_arg
Lfn_call_check_object_arg_meta:
    cmp x7, x5
    b.eq Lfn_call_define_arg
    b Lfn_call_fail
Lfn_call_non_object_arg:
    cmp x27, #3
    b.ne Lfn_call_fail
    cmp x6, #0
    b.ne Lfn_call_fail
    b Lfn_call_define_arg

Lfn_call_check_nullable_arg:
    cmp x6, #7
    b.eq Lfn_call_define_arg
    cmp x6, x27
    b.eq Lfn_call_define_arg
    sub x9, x27, #16
    cmp x9, #3
    b.ne Lfn_call_check_nullable_exact
    cmp x6, #0
    b.eq Lfn_call_define_arg
Lfn_call_check_nullable_exact:
    cmp x6, x9
    b.ne Lfn_call_fail

Lfn_call_define_arg:
    cmp x27, #6
    b.eq Lfn_call_check_decimal_arg_len
    cmp x27, #22
    b.ne Lfn_call_define_arg_len_ok
    cmp x6, #7
    b.eq Lfn_call_define_arg_use_decl_len
Lfn_call_check_decimal_arg_len:
    cmp x7, x5
    b.ne Lfn_call_fail
Lfn_call_define_arg_use_decl_len:
    mov x7, x5
Lfn_call_define_arg_len_ok:
    str x6, [sp, #64]  // actual argument type across helper calls
    str x7, [sp, #72]  // actual argument length across helper calls
    mov x0, x25
    mov x1, x26
    mov x2, x28
    mov x3, #0   // not const
    mov x4, x27  // type
    mov x5, x7
    bl _define_variable
    cbnz x0, Lfn_call_fail

    // In compilation mode, strip this parameter variable's NAME right after
    // defining it. The callee reads its arguments from registers at runtime,
    // so the caller-side parameter name is never needed here -- but if left
    // in place it becomes a live, higher-index variable in the caller's
    // scope bearing the callee's parameter name. When a function recurses
    // (e.g. `f(n-1)+f(n-2)`, callee param also named `n`), that staged `n`
    // shadowed the caller's real `n` in `_lookup_variable` (high->low scan),
    // so the second `n` read a leftover arg slot instead of the parameter
    // (produced wrong/zero results). Zeroing the name makes it a nameless
    // temp that can never shadow a real variable. Interpret mode still keeps
    // the name because the re-parsed body looks the parameter up by name.
    LOAD_ADDR x9, compilation_mode
    ldr x9, [x9]
    cbz x9, Lfn_call_param_name_kept
    LOAD_ADDR x9, var_count
    ldr x10, [x9]
    sub x10, x10, #1
    LOAD_TBL x11, var_name_lens
    str xzr, [x11, x10, lsl #3]
    LOAD_TBL x11, var_name_ptrs
    str xzr, [x11, x10, lsl #3]
Lfn_call_param_name_kept:

    // Also emit runtime store for the parameter
    // x22 was var_count before defines. Each param is at x22 + x24.
    LOAD_ADDR x9, var_count
    ldr x0, [x9]
    sub x1, x0, #1 // target var index (the one we just defined)
    str x1, [sp, #80]

    // Remember this argument's slot for op13 register marshalling
    add x9, sp, #32
    str x1, [x9, x24, lsl #3]

    ldr x9, [sp, #8]
    cmn x9, #1
    b.eq Lfn_call_emit_imm
    ldr x10, [sp, #64]
    cmp x10, #4
    b.eq Lfn_call_emit_list_base_imm
    // emit op 45 (store_var_var)
    mov x0, #45
    mov x2, x9 // source var_id
    // x1 is already target var index
    bl _record_operation
    b Lfn_call_emit_done
Lfn_call_emit_list_base_imm:
    mov x0, #1
    mov x2, x28 // list pool start index
    // x1 is already target var index
    bl _record_operation
    b Lfn_call_emit_done
Lfn_call_emit_imm:
    ldr x9, [sp, #64]
    cmp x9, #2
    b.eq Lfn_call_emit_str_imm
    // emit op 1 (store_var_imm)
    mov x0, #1
    mov x2, x28 // imm value
    // x1 is already target var index
    bl _record_operation
    b Lfn_call_emit_done
Lfn_call_emit_str_imm:
    mov x0, x28
    mov x1, #2
    ldr x2, [sp, #72]
    bl _record_data_value
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x2, x0
    ldr x1, [sp, #80]
    mov x0, #72
    bl _record_operation
Lfn_call_emit_done:
    cbnz x0, Lfn_call_fail

Lfn_call_arg_next:
    add x24, x24, #1
    b Lfn_call_arg_loop

Lfn_call_args_done:
    bl _advance_char // consume ')'

    // Fill missing arguments from defaults.
Lfn_call_fill_defaults:
    cmp x24, x23
    b.ge Lfn_call_args_ready
    cmp x24, #4
    b.ge Lfn_call_wrong_args
    mov x9, x21
    lsl x9, x9, #2
    add x9, x9, x24
    LOAD_TBL x10, fn_param_default_flags
    ldr x11, [x10, x9, lsl #3]
    cbz x11, Lfn_call_wrong_args
    LOAD_TBL x10, fn_param_name_ptrs
    ldr x25, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_name_lens
    ldr x26, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_types
    ldr x27, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_lengths
    ldr x6, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_default_values
    ldr x28, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_default_types
    ldr x7, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_default_lengths
    ldr x5, [x10, x9, lsl #3]
    cmp x27, #6
    b.eq Lfn_call_default_use_decl_len
    cmp x27, #22
    b.ne Lfn_call_default_len_ready
    cmp x7, #7
    b.ne Lfn_call_default_use_decl_len
Lfn_call_default_use_decl_len:
    mov x5, x6
Lfn_call_default_len_ready:
    str x7, [sp, #64]
    str x5, [sp, #72]
    mov x0, x25
    mov x1, x26
    mov x2, x28
    mov x3, #0
    mov x4, x27
    bl _define_variable
    cbnz x0, Lfn_call_fail
    LOAD_ADDR x9, var_count
    ldr x0, [x9]
    sub x1, x0, #1
    str x1, [sp, #80]

    // Remember this default argument's slot for op13 register marshalling
    add x9, sp, #32
    str x1, [x9, x24, lsl #3]

    ldr x9, [sp, #64]
    cmp x9, #2
    b.eq Lfn_call_default_emit_str
    mov x0, #1
    mov x2, x28
    bl _record_operation
    b Lfn_call_default_emit_done
Lfn_call_default_emit_str:
    mov x0, x28
    mov x1, #2
    ldr x2, [sp, #72]
    bl _record_data_value
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x2, x0
    ldr x1, [sp, #80]
    mov x0, #72
    bl _record_operation
Lfn_call_default_emit_done:
    cbnz x0, Lfn_call_fail
    add x24, x24, #1
    b Lfn_call_fill_defaults

Lfn_call_args_ready:
    // Save declared return type for missing-return validation.
    LOAD_TBL x9, fn_return_types
    ldr x11, [x9, x21, lsl #3]
    str x11, [sp, #8]

    // Refresh saved call-site location after parsing the arguments.
    LOAD_ADDR x9, cursor_pos
    ldr x25, [x9]
    LOAD_ADDR x9, current_line
    ldr x26, [x9]
    LOAD_ADDR x9, source_ptr
    ldr x10, [x9]
    str x10, [sp, #16]
    LOAD_ADDR x9, source_len
    ldr x10, [x9]
    str x10, [sp, #24]

    // Check if we are in compilation mode
    LOAD_ADDR x9, compilation_mode
    ldr x10, [x9]
    cbz x10, Lfn_call_interpret
    
    // Refresh saved call-site location
    ldr x10, [sp, #16]
    LOAD_ADDR x9, source_ptr
    str x10, [x9]
    ldr x10, [sp, #24]
    LOAD_ADDR x9, source_len
    str x10, [x9]
    LOAD_ADDR x9, cursor_pos
    str x25, [x9]
    LOAD_ADDR x9, current_line
    str x26, [x9]

    // COMPILATION MODE: stage the argument values into a contiguous block
    // of fresh slots (the callee reads them from x0..x3 at runtime), then
    // record op 13 as (fn, arg block base, arg count, result slot).
    mov x24, #0
    mov x28, #-1              // arg block base (-1 = none yet)
Lfn_call_comp_stage_loop:
    cmp x24, x23
    b.ge Lfn_call_comp_stage_done
    bl _allocate_temp_var     // x0 = fresh staging slot
    cmn x28, #1
    csel x28, x0, x28, eq     // remember the first staged slot
    mov x1, x0                // target: staging slot
    add x9, sp, #32
    ldr x2, [x9, x24, lsl #3] // source: this arg's slot
    mov x0, #45               // op45: store var -> var
    bl _record_operation
    cbnz x0, Lfn_call_fail
    add x24, x24, #1
    b Lfn_call_comp_stage_loop
Lfn_call_comp_stage_done:
    // Allocate the result slot and publish it for expression contexts.
    bl _allocate_temp_var
    mov x27, x0
    LOAD_ADDR x9, last_call_result_slot
    str x27, [x9]
    mov x0, #13
    mov x1, x21               // fn index
    mov x2, x28               // arg block base slot (-1 if no args)
    mov x3, x23               // arg count
    mov x4, x27               // result slot
    bl _record_operation4
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0                // value placeholder; actual value is in result slot
    ldr x2, [sp, #8]          // declared return type
    LOAD_TBL x9, fn_return_decl_lengths
    ldr x3, [x9, x21, lsl #3] // declared return length/subtype
    mov x4, x27
    b Lfn_call_return

Lfn_call_interpret:
    // Clear return flag
    LOAD_ADDR x9, fn_return_flag

    str xzr, [x9]
    LOAD_ADDR x9, fn_return_length
    str xzr, [x9]

    // Jump cursor to function body
    LOAD_TBL x9, fn_body_cursors
    ldr x27, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_body_lines
    ldr x28, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_source_ptrs
    ldr x10, [x9, x21, lsl #3]
    LOAD_ADDR x9, source_ptr
    str x10, [x9]
    LOAD_TBL x9, fn_source_lens
    ldr x10, [x9, x21, lsl #3]
    LOAD_ADDR x9, source_len
    str x10, [x9]
    LOAD_ADDR x9, cursor_pos
    str x27, [x9]
    LOAD_ADDR x9, current_line
    str x28, [x9]

    LOAD_ADDR x9, fn_exec_depth
    ldr x10, [x9]
    add x10, x10, #1
    str x10, [x9]

    // Execute function body
Lfn_call_body_loop:
    // Check return flag
    LOAD_ADDR x9, fn_return_flag
    ldr x10, [x9]
    cbnz x10, Lfn_call_body_returned

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lfn_call_body_done
    cbz w0, Lfn_call_fail

    bl _parse_statement
    cbz x0, Lfn_call_body_loop
    cmp x0, #4  // return
    b.eq Lfn_call_body_returned
    b Lfn_call_fail

Lfn_call_body_returned:
    // Skip rest of body
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lfn_call_body_done
    cbz w0, Lfn_call_fail
    cmp w0, #'{'
    b.eq Lfn_call_skip_nested
    bl _advance_char
    b Lfn_call_body_returned

Lfn_call_skip_nested:
    bl _advance_char
    bl _skip_block_contents
    b Lfn_call_body_returned

Lfn_call_body_done:
    // Typed functions must set a return value before closing body.
    ldr x11, [sp, #8]
    cmp x11, #-1
    b.eq Lfn_call_body_done_ok
    LOAD_ADDR x9, fn_return_flag
    ldr x10, [x9]
    cbnz x10, Lfn_call_body_done_ok
    LOAD_ADDR x0, msg_missing_return
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lfn_call_fail
Lfn_call_body_done_ok:
    bl _advance_char // consume '}'

    LOAD_ADDR x9, fn_exec_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]

    // Restore cursor to call site
    LOAD_ADDR x9, source_ptr
    ldr x10, [sp, #16]
    str x10, [x9]
    LOAD_ADDR x9, source_len
    ldr x10, [sp, #24]
    str x10, [x9]
    LOAD_ADDR x9, cursor_pos
    str x25, [x9]
    LOAD_ADDR x9, current_line
    str x26, [x9]

    // Remove param variables (restore var count)
    LOAD_ADDR x9, var_count
    str x22, [x9]
    LOAD_ADDR x9, var_scope_base
    ldr x10, [sp]
    str x10, [x9]

    // Clear return flag
    LOAD_ADDR x9, fn_return_flag
    str xzr, [x9]

    mov x0, #0
    LOAD_TBL x9, fn_return_types
    ldr x1, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_return_decl_lengths
    ldr x2, [x9, x21, lsl #3]
    b Lfn_call_return

Lfn_call_file_read:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #2 // str
    b.ne Lstmt_type_mismatch
    
    mov x19, x1 // path val
    mov x20, x4 // path var_id
    mov x21, x3 // path len
    
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    
    bl _allocate_temp_var
    mov x22, x0 // dest var id
    
    // Record op 70
    mov x25, #0
    cmp x20, #-1
    b.ne Lfile_read_emit
    // path is imm
    mov x0, x19
    mov x1, #2
    mov x2, x21
    bl _record_data_value
    mov x19, x0 // print id
    mov x25, #1 // is_imm
    
Lfile_read_emit:
    mov x0, #70
    mov x1, x22
    mov x2, x19
    mov x3, #0
    mov x4, x25
    bl _record_operation4
    
    // Return convention: compilation-mode expression path reads the value's
    // TYPE from x2 (see the normal-fn return at ~10480: `ldr x2,[sp,#8]` =
    // declared return type), while the interpreter path reads it from x1.
    // file_read yields a str whose value lives in the temp var (x4), so report
    // str(2) in BOTH x1 and x2 — otherwise `str c = file_read(...)` fails the
    // `cmp x2,#2` check in Lstmt_str.
    mov x0, #0
    mov x1, #2 // str (interpreter-path type)
    mov x2, #2 // str (compilation-path type)
    mov x3, #0 // length unknown at compile time
    mov x4, x22
    b Lfn_call_return

// --------------------------------------------------------------------------
// Built-in: system(cmd) / exec(cmd) — run an external shell command.
// Mirrors file_read's single-string-argument shape, but yields an INT (the
// command's exit status; 0 == success) rather than a str. Op 114.
// --------------------------------------------------------------------------
Lfn_call_system:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #2 // str
    b.ne Lstmt_type_mismatch

    mov x19, x1 // cmd val
    mov x20, x4 // cmd var_id
    mov x21, x3 // cmd len

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    bl _allocate_temp_var
    mov x22, x0 // dest var id (int exit status)

    // Record op 114. arg1 must be the DATA-VALUE id (immediate) or the source
    // SLOT / var_id (runtime variable) — NOT the parsed value in x1. This is the
    // same convention str_concat uses (see Lexpr_add_str_left_var: `mov x19,x24`);
    // file_read/file_write got this wrong for the variable path.
    mov x25, #0
    cmp x20, #-1
    b.ne Lsystem_cmd_var
    // cmd is an immediate string literal -> record it as a data value
    mov x0, x19
    mov x1, #2
    mov x2, x21
    bl _record_data_value
    mov x19, x0 // data value id
    mov x25, #1 // is_imm
    b Lsystem_emit
Lsystem_cmd_var:
    mov x19, x20 // arg1 = runtime source slot (var_id)

Lsystem_emit:
    mov x0, #114
    mov x1, x22
    mov x2, x19
    mov x3, #0
    mov x4, x25
    bl _record_operation4

    // Returns an int (the command exit status) that lives in the temp var.
    mov x0, #0
    mov x1, #0 // int (interpreter-path type)
    mov x2, #0 // int (compilation-path type)
    mov x3, #0
    mov x4, x22
    b Lfn_call_return

// --------------------------------------------------------------------------
// Built-in: argc() — number of command-line arguments (argv[0] included).
// Returns an int. Op 115.
// --------------------------------------------------------------------------
Lfn_call_argc:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    bl _allocate_temp_var
    mov x22, x0 // dest var id
    mov x0, #115
    mov x1, x22
    mov x2, #0
    bl _record_operation
    cbnz x0, Lfn_call_fail

    mov x0, #0
    mov x1, #0 // int
    mov x2, #0 // int
    mov x3, #0
    mov x4, x22
    b Lfn_call_return

// --------------------------------------------------------------------------
// Built-in: wait() — block until every outstanding spawned thread finishes.
// Threads are recorded (not detached) at spawn time; this joins them all in
// order, so their output is no longer lost when main would otherwise exit
// first. Returns an int: the number of threads joined. Op 117.
// --------------------------------------------------------------------------
Lfn_call_wait:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    // Flag wait() usage so codegen always emits the _snc_spawn_wait runtime,
    // even if the program contains no spawn (then it just joins zero threads).
    LOAD_ADDR x9, spawn_wait_used
    mov x10, #1
    str x10, [x9]

    bl _allocate_temp_var
    mov x22, x0 // dest var id (int: count of threads joined)
    mov x0, #117
    mov x1, x22
    mov x2, #0
    bl _record_operation
    cbnz x0, Lfn_call_fail

    mov x0, #0
    mov x1, #0 // int
    mov x2, #0 // int
    mov x3, #0
    mov x4, x22
    b Lfn_call_return

// await(task<T>) -> T. Op 133 stores the selected task's cached result.
Lfn_call_await:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #13
    b.ne Lfn_call_task_type_mismatch
    mov x19, x3                 // result type metadata
    mov x20, x4                 // task handle source slot
    cmn x20, #1
    b.eq Lfn_call_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _allocate_temp_var
    mov x22, x0
    mov x0, #133
    mov x1, x22
    mov x2, x20
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, x19
    mov x3, #0
    mov x4, x22
    b Lfn_call_return

// task_state(task<T>) -> int, task_error(task<T>) -> str, and
// cancel(task<T>) -> bool share the same typed one-argument parser.
Lfn_call_task_state:
    mov x23, #134
    mov x24, #0
    b Lfn_call_task_unary
Lfn_call_task_error:
    mov x23, #135
    mov x24, #2
    b Lfn_call_task_unary
Lfn_call_task_cancel:
    mov x23, #137
    mov x24, #1
Lfn_call_task_unary:
    LOAD_ADDR x9, task_runtime_used
    mov x10, #1
    str x10, [x9]
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #13
    b.ne Lfn_call_task_type_mismatch
    mov x21, x4
    cmn x21, #1
    b.eq Lfn_call_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _allocate_temp_var
    mov x22, x0
    mov x0, x23
    mov x1, x22
    mov x2, x21
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, x24
    mov x3, #0
    mov x4, x22
    b Lfn_call_return

// task_wait(task<T>, milliseconds) -> bool. A false result is a timeout; the
// task remains valid and can later be cancelled or awaited.
Lfn_call_task_wait:
    LOAD_ADDR x9, task_runtime_used
    mov x10, #1
    str x10, [x9]
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #13
    b.ne Lfn_call_task_type_mismatch
    mov x21, x4
    cmn x21, #1
    b.eq Lfn_call_fail
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #0
    b.ne Lfn_call_task_type_mismatch
    mov x22, x1
    mov x23, x4
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    cmn x23, #1
    b.ne Lfn_call_task_wait_have_slot
    mov x0, x22
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x23, x0
Lfn_call_task_wait_have_slot:
    bl _allocate_temp_var
    mov x24, x0
    mov x0, #136
    mov x1, x24
    mov x2, x21
    mov x3, x23
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, #1
    mov x3, #0
    mov x4, x24
    b Lfn_call_return

// cancel_requested() -> bool, true only inside a task whose handle has received
// a cooperative cancellation request.
Lfn_call_cancel_requested:
    LOAD_ADDR x9, task_runtime_used
    mov x10, #1
    str x10, [x9]
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _allocate_temp_var
    mov x22, x0
    mov x0, #138
    mov x1, x22
    mov x2, #0
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, #1
    mov x3, #0
    mov x4, x22
    b Lfn_call_return

Lfn_call_task_type_mismatch:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lfn_call_fail

// --------------------------------------------------------------------------
// Built-in: argv(i) — the i-th command-line argument as a str (0-based;
// argv(0) is the program name). Returns a str. Op 116.
// --------------------------------------------------------------------------
Lfn_call_argv:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #0 // int index
    b.ne Lstmt_type_mismatch
    mov x19, x1 // index val
    mov x20, x4 // index var_id (-1 if immediate)

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    // Ensure the index lives in a runtime slot (materialize an immediate).
    cmn x20, #1
    b.ne Largv_idx_slot
    mov x0, x19
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x20, x0
Largv_idx_slot:
    mov x23, x20 // index slot

    bl _allocate_temp_var
    mov x22, x0 // dest var id
    mov x0, #116
    mov x1, x22
    mov x2, x23
    bl _record_operation
    cbnz x0, Lfn_call_fail

    mov x0, #0
    mov x1, #2 // str
    mov x2, #2 // str
    mov x3, #0
    mov x4, x22
    b Lfn_call_return

Lfn_call_file_write:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    
    // arg1: path
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #2
    b.ne Lstmt_type_mismatch
    stp x1, x3, [sp, #-32]!
    str x4, [sp, #16]
    
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lfn_call_fail
    
    // arg2: content
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #2
    b.ne Lstmt_type_mismatch
    
    mov x21, x1 // content val
    mov x22, x4 // content var_id
    mov x23, x3 // content len
    
    ldr x20, [sp, #16] // path var_id
    ldp x19, x24, [sp], #32 // path val, path len
    
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    
    bl _allocate_temp_var
    mov x28, x0 // dest var id
    
    // Record op 71
    mov x25, #0
    cmp x20, #-1
    b.ne Lfile_write_check_data
    // path is imm
    stp x21, x22, [sp, #-32]!
    str x23, [sp, #16]
    mov x0, x19
    mov x1, #2
    mov x2, x24
    bl _record_data_value
    mov x19, x0 // path print id
    ldr x23, [sp, #16]
    ldp x21, x22, [sp], #32
    orr x25, x25, #1
    
Lfile_write_check_data:
    cmp x22, #-1
    b.ne Lfile_write_emit
    // data is imm
    stp x19, x20, [sp, #-16]!
    mov x0, x21
    mov x1, #2
    mov x2, x23
    bl _record_data_value
    mov x21, x0 // data print id
    ldp x19, x20, [sp], #16
    orr x25, x25, #2
    
Lfile_write_emit:
    mov x0, #71
    mov x1, x28
    mov x2, x19
    mov x3, x21
    mov x4, x25
    bl _record_operation4
    
    mov x0, #0
    mov x1, #0 // returns int
    mov x2, #0
    mov x4, x28
    b Lfn_call_return

// --------------------------------------------------------------------------
// _str_list_to_data — compile-time formatter for a CONSTANT int list literal.
//   x0 = pool base index, x1 = element count.
// Renders "[e0, e1, ...]" into the persistent list_str_arena (bump-allocated so
// the bytes outlive parsing — _record_data_value stores the pointer, not a copy)
// and registers it as a str data value. Returns x0 = data id (-1 on overflow),
// x1 = string length. Valid only for a compile-time-constant int list (values
// read from list_pool_values); callers must exclude runtime-mutated lists.
// --------------------------------------------------------------------------
_str_list_to_data:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x19, x0                     // base
    mov x20, x1                     // count

    LOAD_ADDR x26, list_str_arena_pos
    ldr x25, [x26]                  // current arena offset
    LOAD_ADDR x21, list_str_arena
    add x21, x21, x25               // dest pointer
    // overflow guard: need at most count*24 + 8 bytes
    mov x9, #24
    mul x9, x20, x9
    add x9, x9, #8
    add x9, x9, x25
    mov x10, #65536
    cmp x9, x10
    b.gt Lsltd_overflow

    mov x22, #0                     // write offset within dest
    LOAD_TBL x23, list_pool_values

    mov w9, #'['
    strb w9, [x21, x22]
    add x22, x22, #1

    mov x24, #0                     // i
Lsltd_loop:
    cmp x24, x20
    b.ge Lsltd_close
    cbz x24, Lsltd_no_sep
    mov w9, #','
    strb w9, [x21, x22]
    add x22, x22, #1
    mov w9, #' '
    strb w9, [x21, x22]
    add x22, x22, #1
Lsltd_no_sep:
    add x9, x19, x24
    ldr x10, [x23, x9, lsl #3]      // element value (signed)
    cmp x10, #0
    b.ge Lsltd_pos
    mov w9, #'-'
    strb w9, [x21, x22]
    add x22, x22, #1
    neg x10, x10
Lsltd_pos:
    // itoa(x10) into number_buffer, written back-to-front
    LOAD_ADDR x9, number_buffer
    add x11, x9, #31
    mov x12, #0                     // digit count
    mov x13, #10
    cbnz x10, Lsltd_digits
    mov w14, #'0'
    strb w14, [x11]
    mov x12, #1
    b Lsltd_copy
Lsltd_digits:
    mov x15, x10
Lsltd_digit_loop:
    udiv x14, x15, x13
    msub x16, x14, x13, x15
    add w16, w16, #'0'
    strb w16, [x11]
    sub x11, x11, #1
    add x12, x12, #1
    mov x15, x14
    cbnz x15, Lsltd_digit_loop
    add x11, x11, #1               // -> first digit
Lsltd_copy:
    mov x13, #0
Lsltd_copy_loop:
    cmp x13, x12
    b.ge Lsltd_copy_done
    ldrb w14, [x11, x13]
    strb w14, [x21, x22]
    add x22, x22, #1
    add x13, x13, #1
    b Lsltd_copy_loop
Lsltd_copy_done:
    add x24, x24, #1
    b Lsltd_loop

Lsltd_close:
    mov w9, #']'
    strb w9, [x21, x22]
    add x22, x22, #1
    strb wzr, [x21, x22]           // null-terminate (not counted in length)

    // advance the arena past this string (len + 1 for the terminator)
    add x9, x25, x22
    add x9, x9, #1
    str x9, [x26]

    mov x0, x21                     // ptr
    mov x1, #2                      // str type
    mov x2, x22                     // length
    bl _record_data_value
    mov x1, x22                     // return length (x0 = data id)
    b Lsltd_return

Lsltd_overflow:
    mov x0, #-1
    mov x1, #0
Lsltd_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// --------------------------------------------------------------------------
// Built-in: str(x) — convert a value to its string form.
//   int / bool  -> reuse the interpolation int->str path (op 73 via
//                  _emit_cast_op); the result string lives in a temp slot.
//   str         -> returned unchanged (pass-through).
//   list<int>   -> constant list rendered "[e0, e1, ...]" at compile time
//                  (materialized into a temp slot via op 72).
// Returns like file_read: x2 = str type, x4 = result slot (-1 for a literal
// pass-through, in which case x1 = the literal value).
// --------------------------------------------------------------------------
Lfn_call_str_builtin:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    mov x19, x1                 // value (data id / ptr for a str literal)
    mov x20, x2                 // type
    mov x21, x3                 // length / meta
    mov x22, x4                 // source slot (-1 = immediate / literal)
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    cmp x20, #2                 // already a string?
    b.eq Lfn_call_str_passthrough
    cmp x20, #0                 // int
    b.eq Lfn_call_str_from_num
    cmp x20, #1                 // bool (rendered as its 0/1 integer value)
    b.eq Lfn_call_str_from_num
    cmp x20, #4                 // list
    b.eq Lfn_call_str_from_list
    b Lstmt_type_mismatch

Lfn_call_str_from_list:
    // str(list) — render a CONSTANT int list as "[e0, e1, ...]" at compile time.
    // Requires an int element type and a list that has NOT been runtime-mutated
    // (so list_pool_values still holds the true values). x19 = pool base, the
    // authoritative element count is list_base_counts[base].
    lsr x9, x21, #32            // element type (from the list's metadata)
    cbnz x9, Lstmt_type_mismatch // only int-element lists supported
    LOAD_TBL x9, list_base_is_runtime
    ldrb w10, [x9, x19]
    cbnz w10, Lstmt_type_mismatch // runtime-mutated -> not constant-foldable
    LOAD_TBL x9, list_base_counts
    ldr x1, [x9, x19, lsl #3]   // count
    mov x0, x19                 // base
    bl _str_list_to_data
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x23, x0                 // data id
    mov x24, x1                 // length
    bl _allocate_temp_var
    mov x25, x0                 // temp slot for the runtime str pointer
    mov x0, #72                 // op 72: store_str_lit (data id -> slot)
    mov x1, x25
    mov x2, x23
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #2                  // interp-path type: str
    mov x2, #2                  // compile-path type: str
    mov x3, #0                  // length unknown at compile time (matches str(int);
                                // a nonzero length routes callers down a literal path)
    mov x4, x25                 // result slot (runtime str pointer)
    b Lfn_call_return

Lfn_call_str_from_num:
    // _emit_cast_op reads the source from a VAR SLOT, so materialize an
    // immediate into a slot first.
    cmn x22, #1
    b.ne Lfn_call_str_have_slot
    mov x0, x19
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x22, x0
Lfn_call_str_have_slot:
    mov x0, #0                  // src_type int (bool 0/1 also renders via op 73)
    mov x1, #2                  // dst str
    mov x2, #0                  // src_val (unused; the op reads the slot)
    mov x3, x22                 // src var slot
    bl _emit_cast_op
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x4, x0                  // result string lives in this temp slot
    mov x0, #0
    mov x1, #2                  // interpreter-path type: str
    mov x2, #2                  // compilation-path type: str
    mov x3, #0                  // length unknown at compile time
    b Lfn_call_return

Lfn_call_str_passthrough:
    mov x0, #0
    mov x1, x19                 // literal value / ptr (used when slot == -1)
    mov x2, #2                  // str
    mov x3, x21                 // length
    mov x4, x22                 // source slot
    b Lfn_call_return

// --------------------------------------------------------------------------
// Built-in: int(x) — convert a value to its integer form.
//   int / bool  -> returned unchanged as int (bool is 0/1).
//   str         -> parsed at runtime via op 78 (cast_str_to_int / _cstr_to_int),
//                  with the source materialized into a plain var slot first.
// Returns like str(): x2 = int type (0), x4 = result slot (-1 with x1 = value
// for an int/bool literal pass-through).
// --------------------------------------------------------------------------
Lfn_call_int_builtin:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    mov x19, x1                 // value (data id / ptr for a str literal)
    mov x20, x2                 // type
    mov x21, x3                 // length / meta
    mov x22, x4                 // source slot (-1 = immediate / literal)
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    cmp x20, #0                 // already int?
    b.eq Lfn_call_int_passthrough
    cmp x20, #1                 // bool (0/1) -> int
    b.eq Lfn_call_int_passthrough
    cmp x20, #2                 // str -> parse
    b.eq Lfn_call_int_from_str
    b Lstmt_type_mismatch

Lfn_call_int_passthrough:
    mov x0, #0
    mov x1, x19                 // literal value (used when slot == -1)
    mov x2, #0                  // int
    mov x3, #0
    mov x4, x22                 // source slot
    b Lfn_call_return

Lfn_call_int_from_str:
    // Materialize the source string into a plain (untagged) var slot; op 78
    // reads arg1 as a straight stack slot holding the char* (not bit63-tagged).
    mov x0, x19
    mov x1, x21
    mov x2, x22
    bl _str_method_materialize_arg   // returns (var | bit63)
    mov x9, #1
    lsl x9, x9, #63
    bic x23, x0, x9             // strip tag -> plain source var slot
    bl _allocate_temp_var
    mov x24, x0                 // dest slot
    mov x0, #78                 // op cast_str_to_int
    mov x1, x24
    mov x2, x23
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, #0                  // int
    mov x3, #0
    mov x4, x24                 // result slot
    b Lfn_call_return

// --------------------------------------------------------------------------
// Built-in: ord(s) — ASCII code (int) of the first byte of string s.
// Enables character classification in SNlang (a self-hosting prerequisite):
// e.g. `int c = ord(line[i])` then compare c to 48..57 for digits, etc. For a
// runtime string (slot) it emits op 118 (reads the first byte at runtime); for
// a string literal it folds to the first byte at compile time. "" -> 0.
// Returns an int: x2 = 0 (int), x4 = result slot (or -1 with x1 = value).
// --------------------------------------------------------------------------
Lfn_call_ord:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    mov x19, x1                 // value (data ptr for a str literal)
    mov x20, x2                 // type
    mov x21, x3                 // length
    mov x22, x4                 // source slot (-1 = literal)
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    cmp x20, #2                 // must be a string
    b.ne Lstmt_type_mismatch

    cmn x22, #1
    b.eq Lfn_call_ord_fold

    // Runtime string in slot x22 -> op 118 reads its first byte at runtime.
    mov x23, x22
    bl _allocate_temp_var
    mov x24, x0                 // dest
    mov x0, #118                // op ord
    mov x1, x24
    mov x2, x23
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, #0                  // int
    mov x3, #0
    mov x4, x24
    b Lfn_call_return

Lfn_call_ord_fold:
    // String literal: fold to the first byte at compile time (0 if empty).
    cbz x21, Lfn_call_ord_fold_zero
    ldrb w0, [x19]              // first byte of the literal's data
    mov x1, x0
    mov x0, #0
    mov x2, #0                  // int
    mov x3, #0
    mov x4, #-1
    b Lfn_call_return
Lfn_call_ord_fold_zero:
    mov x0, #0
    mov x1, #0
    mov x2, #0                  // int
    mov x3, #0
    mov x4, #-1
    b Lfn_call_return

// --------------------------------------------------------------------------
// Managed runtime memory controls and StringBuilder.
// mem_live()/mem_bytes()/mem_collect() return int; builder_new() returns an
// opaque ref<byte>. The remaining builder calls validate a reference argument
// and record runtime operations 127..131.
// --------------------------------------------------------------------------
Lfn_call_mem_live:
    mov x23, #123
    mov x24, #0                 // int
    mov x25, #0
    b Lfn_call_managed_noarg
Lfn_call_mem_bytes:
    mov x23, #124
    mov x24, #0                 // int
    mov x25, #0
    b Lfn_call_managed_noarg
Lfn_call_mem_collect:
    mov x23, #125
    mov x24, #0                 // int
    mov x25, #0
    b Lfn_call_managed_noarg
Lfn_call_builder_new:
    mov x23, #126
    mov x24, #9                 // ref<T>
    mov x25, #3                 // byte metadata
Lfn_call_managed_noarg:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _allocate_temp_var
    mov x22, x0
    mov x0, x23
    mov x1, x22
    mov x2, #0
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, x24
    mov x2, x24
    mov x3, x25
    mov x4, x22
    b Lfn_call_return

Lfn_call_builder_string:
    mov x23, #129
    mov x24, #2                 // str
    mov x25, #0
    b Lfn_call_builder_unary
Lfn_call_builder_clear:
    mov x23, #130
    mov x24, #1                 // bool
    mov x25, #0
    b Lfn_call_builder_unary
Lfn_call_builder_length:
    mov x23, #131
    mov x24, #0                 // int
    mov x25, #0
Lfn_call_builder_unary:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #9                  // ref<T>
    b.ne Lstmt_type_mismatch
    cmn x4, #1
    b.eq Lstmt_type_mismatch
    mov x21, x4                 // builder slot
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _allocate_temp_var
    mov x22, x0
    mov x0, x23
    mov x1, x22
    mov x2, x21
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, x24
    mov x2, x24
    mov x3, x25
    mov x4, x22
    b Lfn_call_return

Lfn_call_builder_append:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #9                  // builder ref
    b.ne Lstmt_type_mismatch
    cmn x4, #1
    b.eq Lstmt_type_mismatch
    mov x21, x4
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #2                  // appended str
    b.ne Lstmt_type_mismatch
    mov x22, x1                 // literal pointer/value
    mov x23, x3                 // literal length
    mov x24, x4                 // source slot or -1
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    mov x25, #0                 // runtime-slot source
    cmn x24, #1
    b.ne Lfn_call_builder_append_have_source
    mov x0, x22
    mov x1, #2
    mov x2, x23
    bl _record_data_value
    mov x24, x0                 // data-value id
    mov x25, #1                 // immediate source
Lfn_call_builder_append_have_source:
    bl _allocate_temp_var
    mov x26, x0
    mov x0, #127
    mov x1, x26
    mov x2, x21
    mov x3, x24
    mov x4, x25
    bl _record_operation4
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #1
    mov x2, #1                  // bool
    mov x3, #0
    mov x4, x26
    b Lfn_call_return

Lfn_call_builder_append_int:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #9                  // builder ref
    b.ne Lstmt_type_mismatch
    cmn x4, #1
    b.eq Lstmt_type_mismatch
    mov x21, x4
    bl _skip_whitespace
    mov w0, #','
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    cmp x2, #0                  // appended int
    b.ne Lstmt_type_mismatch
    mov x22, x1
    mov x23, x4
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail
    cmn x23, #1
    b.ne Lfn_call_builder_append_int_have_slot
    mov x0, x22
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x23, x0
Lfn_call_builder_append_int_have_slot:
    bl _allocate_temp_var
    mov x24, x0
    mov x0, #128
    mov x1, x24
    mov x2, x21
    mov x3, x23
    bl _record_operation3
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #1
    mov x2, #1                  // bool
    mov x3, #0
    mov x4, x24
    b Lfn_call_return

// --------------------------------------------------------------------------
// Built-in: len(x) — number of elements in a list / characters in a string.
// Mirrors the `.length` member exactly: op 103 for a runtime string, op 81
// for a runtime list (split result or list PARAMETER), and a compile-time
// count for a string literal / list literal / local list.
// Returns an int: x2 = 0 (int), x4 = result slot (or -1 with x1 = count).
// --------------------------------------------------------------------------
Lfn_call_len_builtin:
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfn_call_fail
    bl _parse_expr_value
    cbz x0, Lfn_call_fail
    mov x19, x1                 // value (list base index for lists)
    mov x20, x2                 // type
    mov x21, x3                 // length / packed count
    mov x22, x4                 // source slot (-1 = literal / local fold)
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfn_call_fail

    cmp x20, #2                 // str
    b.eq Lfn_call_len_str
    cmp x20, #4                 // list
    b.eq Lfn_call_len_list
    cmp x20, #20                // list?
    b.eq Lfn_call_len_list
    b Lstmt_type_mismatch

Lfn_call_len_str:
    cmn x22, #1
    b.eq Lfn_call_len_str_fold
    mov x23, x22                // source string slot
    bl _allocate_temp_var
    mov x24, x0                 // dest
    mov x0, #103                // op str_length_runtime
    mov x1, x24
    mov x2, x23
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, #0                  // int
    mov x3, #0
    mov x4, x24
    b Lfn_call_return
Lfn_call_len_str_fold:
    mov x0, #0
    mov x1, x21                 // literal length known at compile time
    mov x2, #0
    mov x3, #0
    mov x4, #-1
    b Lfn_call_return

Lfn_call_len_list:
    // A runtime-count list (e.g. a str.split result) is identified by its BASE
    // index in list_base_is_runtime[base], regardless of whether the value also
    // lives in a slot. Check that first, exactly like the `.length` member does,
    // otherwise a split result assigned to a local var reports its reserved
    // capacity instead of its real element count.
    LOAD_TBL x9, list_base_is_runtime
    ldrb w9, [x9, x19]          // x19 = compile-time base index
    cbnz w9, Lfn_call_len_list_runtime_base
    cmn x22, #1
    b.ne Lfn_call_len_list_slot
    b Lfn_call_len_list_fold

Lfn_call_len_list_runtime_base:
    mov x0, x19
    bl _expr_materialize_ct_int
    cmn x0, #1
    b.eq Lfn_call_fail
    mov x23, x0                 // base slot
    bl _allocate_temp_var
    mov x24, x0                 // dest
    mov x0, #81                 // op list_length_runtime
    mov x1, x24
    mov x2, x23
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, #0
    mov x3, #0
    mov x4, x24
    b Lfn_call_return

Lfn_call_len_list_slot:
    // A slot in the current fn's PARAMETER range is a list parameter whose
    // count is only known at runtime -> op 81. Any other slot (a local list)
    // keeps its compile-time count.
    LOAD_ADDR x9, current_parse_fn_id
    ldr x9, [x9]
    cmn x9, #1
    b.eq Lfn_call_len_list_fold
    LOAD_TBL x10, fn_scope_bases
    ldr x10, [x10, x9, lsl #3]
    cmp x22, x10
    b.lt Lfn_call_len_list_fold
    LOAD_TBL x11, fn_param_counts
    ldr x11, [x11, x9, lsl #3]
    add x11, x10, x11
    cmp x22, x11
    b.ge Lfn_call_len_list_fold
    mov x23, x22                // list parameter slot (carries base at runtime)
    bl _allocate_temp_var
    mov x24, x0                 // dest
    mov x0, #81                 // op list_length_runtime
    mov x1, x24
    mov x2, x23
    bl _record_operation
    cbnz x0, Lfn_call_fail
    mov x0, #0
    mov x1, #0
    mov x2, #0
    mov x3, #0
    mov x4, x24
    b Lfn_call_return
Lfn_call_len_list_fold:
    and x1, x21, #0xFFFFFFFF     // count packed in the low 32 bits
    mov x0, #0
    mov x2, #0
    mov x3, #0
    mov x4, #-1
    b Lfn_call_return

Lfn_call_unknown:
    LOAD_ADDR x0, msg_unknown_fn
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    b Lfn_call_fail

Lfn_call_wrong_args:
    LOAD_ADDR x0, msg_wrong_arg_count
    bl _report_error_prefix
    b Lfn_call_fail

Lfn_call_fail:
    LOAD_ADDR x9, fn_exec_depth
    ldr x10, [x9]
    cbz x10, Lfn_call_fail_restore_vars
    sub x10, x10, #1
    str x10, [x9]
Lfn_call_fail_restore_vars:
    LOAD_ADDR x9, source_ptr
    ldr x10, [sp, #16]
    str x10, [x9]
    LOAD_ADDR x9, source_len
    ldr x10, [sp, #24]
    str x10, [x9]
    LOAD_ADDR x9, cursor_pos
    str x25, [x9]
    LOAD_ADDR x9, current_line
    str x26, [x9]
    // Restore var count on failure too
    LOAD_ADDR x9, var_count
    str x22, [x9]
    LOAD_ADDR x9, var_scope_base
    ldr x10, [sp]
    str x10, [x9]
    mov x0, #1

Lfn_call_return:
    add sp, sp, #96
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _preparse_blueprint_methods: register blueprint + all its methods with
// synthesized names (Blueprint_method) so forward calls resolve correctly.
// Called during preparse pass. Leaves cursor after the closing '}'.
_preparse_blueprint_methods:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    // Save cursor — restore at end so main pass re-parses fully
    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lpreparse_bp_fail
    mov x23, x0  // bp name ptr
    mov x24, x1  // bp name len
    bl _skip_generic_suffix

    // Register blueprint (name only, counts stay 0)
    LOAD_ADDR x9, blueprint_count
    ldr x21, [x9]  // bp id
    cmp x21, #64
    b.ge Lpreparse_bp_fail
    LOAD_ADDR x10, blueprint_name_ptrs
    str x23, [x10, x21, lsl #3]
    LOAD_ADDR x10, blueprint_name_lens
    str x24, [x10, x21, lsl #3]
    LOAD_ADDR x10, blueprint_parent_ids
    mov x11, #-1
    str x11, [x10, x21, lsl #3]
    LOAD_ADDR x10, blueprint_field_counts
    str xzr, [x10, x21, lsl #3]
    LOAD_ADDR x10, blueprint_method_counts
    str xzr, [x10, x21, lsl #3]
    add x22, x21, #1
    str x22, [x9]

    // Skip to '{'
Lpreparse_bp_skip_to_brace:
    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lpreparse_bp_fail
    cmp w0, #'{'
    b.eq Lpreparse_bp_body
    bl _advance_char
    b Lpreparse_bp_skip_to_brace

Lpreparse_bp_body:
    bl _advance_char  // consume '{'
    mov x22, #0  // brace depth for nested blocks

Lpreparse_bp_scan_loop:
    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lpreparse_bp_fail
    cmp w0, #'}'
    b.eq Lpreparse_bp_body_done

    // Look for 'fn' keyword to find method names
    bl _parse_identifier
    cbz x0, Lpreparse_bp_scan_advance
    mov x25, x0  // token ptr
    mov x26, x1  // token len

    // Skip access modifiers
    mov x0, x25
    mov x1, x26
    LOAD_ADDR x2, kw_open
    bl _match_cstr_span
    cbnz x0, Lpreparse_bp_after_mod
    mov x0, x25
    mov x1, x26
    LOAD_ADDR x2, kw_closed
    bl _match_cstr_span
    cbnz x0, Lpreparse_bp_after_mod
    mov x0, x25
    mov x1, x26
    LOAD_ADDR x2, kw_guarded
    bl _match_cstr_span
    cbnz x0, Lpreparse_bp_after_mod
    b Lpreparse_bp_check_fn_kw

Lpreparse_bp_after_mod:
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lpreparse_bp_scan_loop
    mov x25, x0
    mov x26, x1

Lpreparse_bp_check_fn_kw:
    mov x0, x25
    mov x1, x26
    LOAD_ADDR x2, kw_fn
    bl _match_cstr_span
    cbz x0, Lpreparse_bp_scan_loop  // not fn — skip to next line

    // Found 'fn' — read method name
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lpreparse_bp_fail
    mov x25, x0  // method name ptr
    mov x26, x1  // method name len

    // Get current method count for this blueprint
    LOAD_ADDR x9, blueprint_method_counts
    ldr x22, [x9, x21, lsl #3]
    cmp x22, #8
    b.ge Lpreparse_bp_scan_loop

    // Compute flat slot index: bp_id*8 + method_idx
    mov x10, x21
    lsl x10, x10, #3
    add x10, x10, x22

    // Build Blueprint__methodname synth name
    mov x0, x21   // blueprint id
    mov x1, x25   // method name ptr
    mov x2, x26   // method name len
    mov x3, x22   // slot index (for storage)
    bl _build_method_synth_name
    // x0=synth ptr, x1=synth len

    // Register a stub fn entry with the synth name
    // so _call_function can resolve it during main parse
    LOAD_ADDR x9, fn_count
    ldr x11, [x9]
    LOAD_ADDR x12, fn_capacity
    ldr x12, [x12]
    cmp x11, x12
    b.lt Lpreparse_bp_have_space
    stp x0, x1, [sp, #-16]!
    bl _snc_grow_fns
    ldp x0, x1, [sp], #16
    LOAD_ADDR x9, fn_count
    ldr x11, [x9]
Lpreparse_bp_have_space:
    LOAD_TBL x12, fn_name_ptrs
    str x0, [x12, x11, lsl #3]
    LOAD_TBL x12, fn_name_lens
    str x1, [x12, x11, lsl #3]
    // Zero out param count for stub
    LOAD_TBL x12, fn_param_counts
    str xzr, [x12, x11, lsl #3]
    add x11, x11, #1
    str x11, [x9]
    sub x11, x11, #1  // fn id = fn_count - 1

    // Store method name and fn id in blueprint tables
    LOAD_ADDR x9, blueprint_method_names
    str x25, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_method_name_lens
    str x26, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_method_fn_ids
    str x11, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_method_counts
    add x22, x22, #1
    str x22, [x9, x21, lsl #3]

    // Skip rest of this line (past the fn signature)
    b Lpreparse_bp_scan_loop

Lpreparse_bp_scan_advance:
    bl _advance_char
    b Lpreparse_bp_scan_loop

Lpreparse_bp_body_done:
    bl _advance_char  // consume '}'

    // Restore cursor so main pass re-parses the blueprint fully
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    mov x0, #0
    b Lpreparse_bp_return

Lpreparse_bp_fail:
    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    mov x0, #1

Lpreparse_bp_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_blueprint:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lblueprint_fail_name
    mov x19, x0 // name ptr
    mov x20, x1 // name len
    bl _skip_generic_suffix

    // Check if already registered by preparse
    mov x0, x19
    mov x1, x20
    bl _lookup_blueprint_id
    cbnz x0, Lblueprint_already_registered

    // Register blueprint name
    LOAD_ADDR x9, blueprint_count
    ldr x10, [x9]
    cmp x10, #64
    b.ge Lblueprint_fail_too_many
    mov x23, x10

    LOAD_ADDR x11, blueprint_name_ptrs
    str x19, [x11, x10, lsl #3]
    LOAD_ADDR x11, blueprint_name_lens
    str x20, [x11, x10, lsl #3]
    LOAD_ADDR x11, blueprint_parent_ids
    mov x12, #-1
    str x12, [x11, x10, lsl #3]
    LOAD_ADDR x11, blueprint_field_counts
    str xzr, [x11, x10, lsl #3]
    LOAD_ADDR x11, blueprint_method_counts
    str xzr, [x11, x10, lsl #3]

    add x10, x10, #1
    str x10, [x9]

    LOAD_ADDR x9, current_blueprint_parse
    str x23, [x9]
    b Lblueprint_register_done

Lblueprint_already_registered:
    // Blueprint was pre-registered; get its id and reset field/method counts
    // so the main parse can re-populate them correctly
    mov x23, x1  // blueprint id from lookup
    LOAD_ADDR x11, blueprint_field_counts
    str xzr, [x11, x23, lsl #3]
    LOAD_ADDR x11, blueprint_method_counts
    str xzr, [x11, x23, lsl #3]

    // Store current blueprint id for member parsing
    LOAD_ADDR x9, current_blueprint_parse
    str x23, [x9]

Lblueprint_register_done:

    bl _skip_whitespace
    LOAD_ADDR x0, kw_from
    bl _consume_keyword
    cbz x0, Lblueprint_no_parent
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lblueprint_fail_name
    mov x24, x0
    mov x25, x1
    bl _skip_generic_suffix
    mov x0, x24
    mov x1, x25
    bl _lookup_blueprint_id
    cbz x0, Lblueprint_no_parent
    LOAD_ADDR x9, blueprint_parent_ids
    str x1, [x9, x23, lsl #3]

Lblueprint_no_parent:
    // Reset followed-contract list for this blueprint.
    LOAD_ADDR x9, blueprint_contract_counts
    str xzr, [x9, x23, lsl #3]
    bl _skip_whitespace
    LOAD_ADDR x0, kw_follows
    bl _consume_keyword
    cbz x0, Lblueprint_expect_body
Lblueprint_skip_follows_loop:
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lblueprint_fail_name
    mov x24, x0
    mov x25, x1
    bl _skip_generic_suffix
    mov x0, x24
    mov x1, x25
    bl _lookup_contract_id
    cbz x0, Lblueprint_fail_unknown_contract
    mov x26, x1
    LOAD_ADDR x9, blueprint_contract_counts
    ldr x10, [x9, x23, lsl #3]
    cmp x10, #8
    b.ge Lblueprint_fail_too_many
    mov x11, x23
    lsl x11, x11, #3
    add x11, x11, x10
    LOAD_ADDR x12, blueprint_contract_ids
    str x26, [x12, x11, lsl #3]
    add x10, x10, #1
    str x10, [x9, x23, lsl #3]
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #','
    b.ne Lblueprint_expect_body
    bl _advance_char
    b Lblueprint_skip_follows_loop

Lblueprint_expect_body:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lblueprint_fail_name

Lblueprint_parse_body:
Lblueprint_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lblueprint_done
    cmp w0, #'}'
    b.eq Lblueprint_body_done
    bl _parse_blueprint_member
    cbnz x0, Lblueprint_fail_name
    b Lblueprint_body_loop

Lblueprint_body_done:
    bl _advance_char // consume '}'

    // Create a DEFINITION-TIME template instance for this blueprint so its
    // method bodies (emitted standalone as dead-but-must-assemble code) can
    // resolve `self.field` to valid var slots. Real method calls inline the
    // body against the caller's actual instance, so this template only needs
    // to make the standalone emission valid. x23 = blueprint id.
    mov x0, x23
    bl _reserve_object_instance
    cbz x0, Lblueprint_template_skip
    mov x24, x1                 // template instance id
    mov x0, x24
    mov x1, x23
    bl _instantiate_object_fields
    cbz x0, Lblueprint_template_skip
    LOAD_ADDR x9, blueprint_template_instances
    add x10, x24, #1            // store id+1 (0 = none)
    str x10, [x9, x23, lsl #3]
Lblueprint_template_skip:

    // Enforce followed contracts: each required method must exist in blueprint.
    LOAD_ADDR x9, blueprint_contract_counts
    ldr x10, [x9, x23, lsl #3]
    mov x24, #0
Lblueprint_contract_loop:
    cmp x24, x10
    b.ge Lblueprint_done
    mov x11, x23
    lsl x11, x11, #3
    add x11, x11, x24
    LOAD_ADDR x12, blueprint_contract_ids
    ldr x25, [x12, x11, lsl #3]
    LOAD_ADDR x12, contract_method_counts
    ldr x26, [x12, x25, lsl #3]
    mov x27, #0
Lblueprint_contract_method_loop:
    cmp x27, x26
    b.ge Lblueprint_contract_next
    mov x13, x25
    lsl x13, x13, #3
    add x13, x13, x27
    LOAD_ADDR x14, contract_method_names
    ldr x0, [x14, x13, lsl #3]
    LOAD_ADDR x14, contract_method_name_lens
    ldr x1, [x14, x13, lsl #3]
    mov x2, x1
    mov x1, x0
    mov x0, x23
    bl _lookup_blueprint_method
    cbz x0, Lblueprint_fail_contract_method
    add x27, x27, #1
    b Lblueprint_contract_method_loop
Lblueprint_contract_next:
    add x24, x24, #1
    b Lblueprint_contract_loop

Lblueprint_done:
    LOAD_ADDR x9, current_blueprint_parse
    str xzr, [x9]
    mov x0, #0
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lblueprint_fail_unknown_contract:
    LOAD_ADDR x9, current_blueprint_parse
    str xzr, [x9]
    LOAD_ADDR x0, msg_contract_not_found
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lblueprint_fail_contract_method:
    LOAD_ADDR x9, current_blueprint_parse
    str xzr, [x9]
    LOAD_ADDR x0, msg_contract_method_missing
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lblueprint_fail_name:
    LOAD_ADDR x9, current_blueprint_parse
    str xzr, [x9]
    LOAD_ADDR x0, msg_expected_name
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lblueprint_fail_too_many:
    LOAD_ADDR x9, current_blueprint_parse
    str xzr, [x9]
    mov x0, #5
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_contract:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lcontract_fail
    mov x19, x0
    mov x20, x1
    bl _skip_generic_suffix
    // Register contract name if needed.
    mov x0, x19
    mov x1, x20
    bl _lookup_contract_id
    cbnz x0, Lcontract_have_id
    LOAD_ADDR x9, contract_count
    ldr x10, [x9]
    cmp x10, #64
    b.ge Lcontract_fail
    LOAD_ADDR x11, contract_name_ptrs
    str x19, [x11, x10, lsl #3]
    LOAD_ADDR x11, contract_name_lens
    str x20, [x11, x10, lsl #3]
    LOAD_ADDR x11, contract_method_counts
    str xzr, [x11, x10, lsl #3]
    mov x19, x10
    add x10, x10, #1
    str x10, [x9]
    b Lcontract_id_ready
Lcontract_have_id:
    mov x19, x1
    LOAD_ADDR x11, contract_method_counts
    str xzr, [x11, x19, lsl #3]
Lcontract_id_ready:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lcontract_fail
Lcontract_loop:
    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lcontract_done
    cmp w0, #'}'
    b.eq Lcontract_done_close
    mov x0, x19
    bl _parse_contract_member
    cbnz x0, Lcontract_fail
    b Lcontract_loop
Lcontract_done_close:
    bl _advance_char
Lcontract_done:
    mov x0, #0
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lcontract_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_new_object:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    bl _skip_object_decl_type
    cbz x0, Lnew_object_fail
    mov x21, x1

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lnew_object_fail
    mov x19, x0
    mov x20, x1

    mov x0, x21
    bl _reserve_object_instance
    cbz x0, Lnew_object_fail
    mov x22, x1
    mov x0, x22
    mov x1, x21
    bl _instantiate_object_fields
    cbz x0, Lnew_object_fail

    mov x0, x19
    mov x1, x20
    mov x2, x22
    mov x3, #0
    mov x4, #11
    mov x5, x21
    bl _define_variable
    cbnz x0, Lnew_object_fail

    LOAD_ADDR x9, cursor_pos
    ldr x23, [x9]
    LOAD_ADDR x9, current_line
    ldr x24, [x9]
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lnew_object_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.eq Lnew_object_done_args
    LOAD_ADDR x9, cursor_pos
    ldr x25, [x9]
    LOAD_ADDR x9, current_line
    ldr x26, [x9]
    bl _parse_identifier
    cbz x0, Lnew_object_call_create
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #':'
    b.ne Lnew_object_call_create
    LOAD_ADDR x9, cursor_pos
    str x25, [x9]
    LOAD_ADDR x9, current_line
    str x26, [x9]
Lnew_object_named_loop:
    bl _parse_identifier
    cbz x0, Lnew_object_fail
    mov x25, x0
    mov x26, x1
    bl _skip_whitespace
    mov w0, #':'
    bl _expect_char
    cbz x0, Lnew_object_fail
    bl _parse_expr_value
    cbz x0, Lnew_object_fail
    stp x1, x2, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    mov x0, x21
    mov x1, x25
    mov x2, x26
    bl _lookup_blueprint_field
    cbz x0, Lnew_object_field_lookup_fail
    ldp x11, x12, [sp], #16
    ldp x9, x10, [sp], #16
    mov x13, x1
    mov x14, x2
    mov x15, x3
    cmp x10, x14
    b.eq Lnew_object_field_store
    cmp x14, #27
    b.ne Lnew_object_fail
    cmp x10, #7
    b.ne Lnew_object_fail
Lnew_object_field_store:
    mov x16, x22
    lsl x16, x16, #3
    add x16, x16, x13
    LOAD_ADDR x17, object_field_var_idxs
    ldr x16, [x17, x16, lsl #3]
    LOAD_TBL x17, var_values
    str x9, [x17, x16, lsl #3]
    LOAD_TBL x17, var_types
    str x10, [x17, x16, lsl #3]
    LOAD_TBL x17, var_lengths
    str x11, [x17, x16, lsl #3]
    cmn x12, #1
    b.eq Lnew_object_field_record_imm
    mov x0, #45
    mov x1, x16
    mov x2, x12
    bl _record_operation
    cbnz x0, Lnew_object_fail
    b Lnew_object_field_record_done
Lnew_object_field_record_imm:
    mov x0, x16
    mov x1, x9
    bl _record_store_variable
    cbnz x0, Lnew_object_fail
Lnew_object_field_record_done:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #','
    b.ne Lnew_object_done_named
    bl _advance_char
    bl _skip_whitespace
    b Lnew_object_named_loop
Lnew_object_done_named:
    mov w0, #')'
    bl _expect_char
    cbz x0, Lnew_object_fail
    b Lnew_object_done_args
Lnew_object_field_lookup_fail:
    add sp, sp, #32
    b Lnew_object_fail
Lnew_object_call_create:
    LOAD_ADDR x9, cursor_pos
    str x23, [x9]
    LOAD_ADDR x9, current_line
    str x24, [x9]
    mov x0, x22
    mov x1, #11
    mov x2, x21
    LOAD_ADDR x3, kw_create
    mov x4, #6
    bl _call_object_method
    cbnz x0, Lnew_object_fail
    b Lnew_object_args_ready
Lnew_object_done_args:
    bl _advance_char
Lnew_object_args_ready:
    bl _consume_optional_semicolon
    mov x0, #0
    b Lnew_object_return

Lnew_object_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5

Lnew_object_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_stack_object:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x0, x19
    mov x1, x20
    bl _lookup_blueprint_id
    cbz x0, Lstack_object_fail
    mov x21, x1
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lstack_object_fail
    mov x19, x0
    mov x20, x1

    mov x0, x21
    bl _reserve_object_instance
    cbz x0, Lstack_object_fail
    mov x22, x1
    mov x0, x22
    mov x1, x21
    bl _instantiate_object_fields
    cbz x0, Lstack_object_fail

    mov x0, x19
    mov x1, x20
    mov x2, x22
    mov x3, #0
    mov x4, #10
    mov x5, x21
    bl _define_variable
    cbnz x0, Lstack_object_fail

    LOAD_ADDR x9, cursor_pos
    ldr x23, [x9]
    LOAD_ADDR x9, current_line
    ldr x24, [x9]
    LOAD_ADDR x9, cursor_pos
    str x23, [x9]
    LOAD_ADDR x9, current_line
    str x24, [x9]
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lstack_object_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.eq Lstack_object_done_args
    LOAD_ADDR x9, cursor_pos
    ldr x25, [x9]
    LOAD_ADDR x9, current_line
    ldr x26, [x9]
    bl _parse_identifier
    cbz x0, Lstack_object_call_create
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #':'
    b.ne Lstack_object_call_create
    LOAD_ADDR x9, cursor_pos
    str x25, [x9]
    LOAD_ADDR x9, current_line
    str x26, [x9]
Lstack_object_named_loop:
    bl _parse_identifier
    cbz x0, Lstack_object_fail
    mov x25, x0
    mov x26, x1
    bl _skip_whitespace
    mov w0, #':'
    bl _expect_char
    cbz x0, Lstack_object_fail
    bl _parse_expr_value
    cbz x0, Lstack_object_fail
    stp x1, x2, [sp, #-16]!
    stp x3, xzr, [sp, #-16]!
    mov x0, x21
    mov x1, x25
    mov x2, x26
    bl _lookup_blueprint_field
    cbz x0, Lstack_object_field_lookup_fail
    ldp x11, xzr, [sp], #16
    ldp x9, x10, [sp], #16
    mov x13, x1
    mov x14, x2
    cmp x10, x14
    b.eq Lstack_object_field_store
    cmp x14, #27
    b.ne Lstack_object_fail
    cmp x10, #7
    b.ne Lstack_object_fail
Lstack_object_field_store:
    mov x16, x22
    lsl x16, x16, #3
    add x16, x16, x13
    LOAD_ADDR x17, object_field_var_idxs
    ldr x16, [x17, x16, lsl #3]
    LOAD_TBL x17, var_values
    str x9, [x17, x16, lsl #3]
    LOAD_TBL x17, var_types
    str x10, [x17, x16, lsl #3]
    LOAD_TBL x17, var_lengths
    str x11, [x17, x16, lsl #3]
    mov x0, x16
    mov x1, x9
    bl _record_store_variable
    cbnz x0, Lstack_object_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #','
    b.ne Lstack_object_done_named
    bl _advance_char
    bl _skip_whitespace
    b Lstack_object_named_loop
Lstack_object_done_named:
    mov w0, #')'
    bl _expect_char
    cbz x0, Lstack_object_fail
    b Lstack_object_args_ready
Lstack_object_field_lookup_fail:
    add sp, sp, #32
    b Lstack_object_fail
Lstack_object_call_create:
    LOAD_ADDR x9, cursor_pos
    str x23, [x9]
    LOAD_ADDR x9, current_line
    str x24, [x9]
    mov x0, x22
    mov x1, #10
    mov x2, x21
    LOAD_ADDR x3, kw_create
    mov x4, #6
    bl _call_object_method
    cbnz x0, Lstack_object_fail
    b Lstack_object_args_ready
Lstack_object_done_args:
    bl _advance_char
Lstack_object_args_ready:
    bl _consume_optional_semicolon
    mov x0, #0
    b Lstack_object_return

Lstack_object_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #5

Lstack_object_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_lookup_blueprint_id:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, #0
    LOAD_ADDR x22, blueprint_count
    ldr x22, [x22]

Lbp_lookup_loop:
    cmp x21, x22
    b.ge Lbp_lookup_fail
    LOAD_ADDR x9, blueprint_name_lens
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x20
    b.ne Lbp_lookup_next
    LOAD_ADDR x9, blueprint_name_ptrs
    ldr x11, [x9, x21, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbnz x0, Lbp_lookup_found
Lbp_lookup_next:
    add x21, x21, #1
    b Lbp_lookup_loop

Lbp_lookup_found:
    mov x0, #1
    mov x1, x21
    b Lbp_lookup_return

Lbp_lookup_fail:
    mov x0, #0
    mov x1, #-1

Lbp_lookup_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_lookup_contract_id:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, #0
    LOAD_ADDR x22, contract_count
    ldr x22, [x22]

Lcontract_lookup_loop:
    cmp x21, x22
    b.ge Lcontract_lookup_fail
    LOAD_ADDR x9, contract_name_lens
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x20
    b.ne Lcontract_lookup_next
    LOAD_ADDR x9, contract_name_ptrs
    ldr x11, [x9, x21, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbnz x0, Lcontract_lookup_found
Lcontract_lookup_next:
    add x21, x21, #1
    b Lcontract_lookup_loop

Lcontract_lookup_found:
    mov x0, #1
    mov x1, x21
    b Lcontract_lookup_return

Lcontract_lookup_fail:
    mov x0, #0
    mov x1, #-1

Lcontract_lookup_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_skip_angle_group:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, #1

Lskip_angle_loop:
    bl _peek_char
    cbz w0, Lskip_angle_fail
    cmp w0, #'<'
    b.eq Lskip_angle_open
    cmp w0, #'>'
    b.eq Lskip_angle_close
    bl _advance_char
    b Lskip_angle_loop

Lskip_angle_open:
    bl _advance_char
    add x19, x19, #1
    b Lskip_angle_loop

Lskip_angle_close:
    bl _advance_char
    sub x19, x19, #1
    cbnz x19, Lskip_angle_loop
    mov x0, #0
    b Lskip_angle_return

Lskip_angle_fail:
    mov x0, #1

Lskip_angle_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_skip_generic_suffix:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'<'
    b.ne Lskip_generic_done
    bl _advance_char
    bl _skip_angle_group
    cbnz x0, Lskip_generic_fail

Lskip_generic_done:
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret

Lskip_generic_fail:
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

_skip_type_surface:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lskip_type_surface_fail
    bl _skip_generic_suffix
    cbz x0, Lskip_type_surface_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'?'
    b.ne Lskip_type_surface_ok
    bl _advance_char

Lskip_type_surface_ok:
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret

Lskip_type_surface_fail:
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

_skip_object_decl_type:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lskip_object_decl_type_fail
    mov x9, x0
    mov x10, x1
    mov x0, x9
    mov x1, x10
    bl _lookup_blueprint_id
    cbz x0, Lskip_object_decl_type_fail
    mov x11, x1
    bl _skip_generic_suffix
    cbz x0, Lskip_object_decl_type_fail
    mov x0, #1
    mov x1, x11
    ldp x29, x30, [sp], #16
    ret

Lskip_object_decl_type_fail:
    mov x0, #0
    mov x1, #-1
    ldp x29, x30, [sp], #16
    ret

_skip_decl_block:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

Lskip_decl_block_seek:
    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lskip_decl_block_fail
    cmp w0, #'{'
    b.eq Lskip_decl_block_body
    bl _advance_char
    b Lskip_decl_block_seek

Lskip_decl_block_body:
    bl _advance_char
    bl _skip_block_contents
    ldp x29, x30, [sp], #16
    ret

Lskip_decl_block_fail:
    mov x0, #1
    ldp x29, x30, [sp], #16
    ret

_parse_blueprint_member:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]

    bl _parse_identifier
    cbz x0, Lblueprint_member_fail
    mov x21, x0
    mov x22, x1

    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_open
    bl _match_cstr_span
    cbnz x0, Lblueprint_member_after_modifier
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_closed
    bl _match_cstr_span
    cbnz x0, Lblueprint_member_after_modifier
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_guarded
    bl _match_cstr_span
    cbnz x0, Lblueprint_member_after_modifier
    b Lblueprint_member_dispatch

Lblueprint_member_after_modifier:
    LOAD_ADDR x9, cursor_pos
    ldr x19, [x9]
    LOAD_ADDR x9, current_line
    ldr x20, [x9]
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lblueprint_member_fail
    mov x21, x0
    mov x22, x1

Lblueprint_member_dispatch:
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_fn
    bl _match_cstr_span
    cbnz x0, Lblueprint_member_method

    LOAD_ADDR x9, cursor_pos
    str x19, [x9]
    LOAD_ADDR x9, current_line
    str x20, [x9]
    bl _parse_type_spec
    cbz x0, Lblueprint_member_fail
    mov x23, x1
    mov x24, x2
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lblueprint_member_fail
    mov x25, x0
    mov x26, x1

    LOAD_ADDR x9, current_blueprint_parse
    ldr x21, [x9]
    LOAD_ADDR x9, blueprint_field_counts
    ldr x22, [x9, x21, lsl #3]
    cmp x22, #8
    b.ge Lblueprint_member_fail
    mov x10, x21
    lsl x10, x10, #3
    add x10, x10, x22
    LOAD_ADDR x9, blueprint_field_names
    str x25, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_field_name_lens
    str x26, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_field_types
    str x23, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_field_metas
    str x24, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_field_default_flags
    str xzr, [x9, x10, lsl #3]

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'='
    b.ne Lblueprint_member_field_done
    bl _advance_char
    bl _parse_expr_value
    cbz x0, Lblueprint_member_fail
    LOAD_ADDR x9, blueprint_field_default_flags
    mov x11, #1
    str x11, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_field_default_values
    str x1, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_field_default_types
    str x2, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_field_default_metas
    str x3, [x9, x10, lsl #3]
Lblueprint_member_field_done:
    LOAD_ADDR x9, blueprint_field_counts
    add x22, x22, #1
    str x22, [x9, x21, lsl #3]
    bl _consume_optional_semicolon
    mov x0, #0
    b Lblueprint_member_return

Lblueprint_member_method:
    LOAD_ADDR x9, cursor_pos
    ldr x23, [x9]
    LOAD_ADDR x9, current_line
    ldr x24, [x9]
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lblueprint_member_fail
    mov x25, x0
    mov x26, x1
    LOAD_ADDR x9, current_blueprint_parse
    ldr x21, [x9]
    LOAD_ADDR x9, blueprint_method_counts
    ldr x22, [x9, x21, lsl #3]
    cmp x22, #8
    b.ge Lblueprint_member_fail
    mov x10, x21
    lsl x10, x10, #3
    add x10, x10, x22
    LOAD_ADDR x9, blueprint_method_names
    str x25, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_method_name_lens
    str x26, [x9, x10, lsl #3]
    sub sp, sp, #16
    str x10, [sp]

    // Build Blueprint__methodname and set fn_name_override
    mov x0, x21   // blueprint id
    mov x1, x25   // method name ptr
    mov x2, x26   // method name len
    mov x3, x22   // method slot index (for storage offset)
    bl _build_method_synth_name
    // x0=synth name ptr, x1=synth name len
    LOAD_ADDR x9, fn_name_override_ptr
    str x0, [x9]
    LOAD_ADDR x9, fn_name_override_len
    str x1, [x9]

    LOAD_ADDR x9, cursor_pos
    str x23, [x9]
    LOAD_ADDR x9, current_line
    str x24, [x9]
    bl _parse_fn_definition

    // Clear fn_name_override
    LOAD_ADDR x9, fn_name_override_ptr
    str xzr, [x9]
    LOAD_ADDR x9, fn_name_override_len
    str xzr, [x9]

    ldr x10, [sp]
    add sp, sp, #16
    cbnz x0, Lblueprint_member_fail
    // Use the ACTUAL fn index just defined, not fn_count-1: _parse_fn_definition
    // reuses the preparse stub without bumping fn_count, so fn_count-1 points at
    // the wrong fn whenever this method isn't the last-registered one.
    LOAD_ADDR x9, last_fn_def_index
    ldr x23, [x9]
    
    // Save blueprint ID for this function
    LOAD_TBL x9, fn_blueprint_ids
    str x21, [x9, x23, lsl #3]

    // The general fn preparse also registers a PLAIN-named stub for this
    // method (it doesn't know the `fn` sits inside a blueprint), leaving it
    // with blueprint id -1. That stub's body cursor points at this method's
    // body, so _parse_function_body would later re-parse `return self.field`
    // as an ordinary function with no `self` bound and fail (aborting before
    // `main`). Tag that stub with this blueprint id too, so `self` binds and
    // its dead-but-must-assemble body resolves self.field correctly.
    mov x0, x25   // plain method name ptr
    mov x1, x26   // plain method name len
    bl _lookup_function
    cbz x0, Lblueprint_member_stub_done
    LOAD_TBL x9, fn_blueprint_ids
    str x21, [x9, x1, lsl #3]
Lblueprint_member_stub_done:

    LOAD_ADDR x9, blueprint_method_fn_ids
    str x23, [x9, x10, lsl #3]
    LOAD_ADDR x9, blueprint_method_counts
    add x22, x22, #1
    str x22, [x9, x21, lsl #3]
    mov x0, #0
    b Lblueprint_member_return

Lblueprint_member_fail:
    mov x0, #1

Lblueprint_member_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_contract_member:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // contract id

    bl _parse_identifier
    cbz x0, Lcontract_member_fail
    mov x9, x0
    mov x10, x1
    mov x0, x9
    mov x1, x10
    LOAD_ADDR x2, kw_fn
    bl _match_cstr_span
    cbz x0, Lcontract_member_fail
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lcontract_member_fail
    mov x21, x0
    mov x22, x1
    // Persist required method name in contract table.
    LOAD_ADDR x9, contract_method_counts
    ldr x10, [x9, x19, lsl #3]
    cmp x10, #8
    b.ge Lcontract_member_fail
    mov x11, x19
    lsl x11, x11, #3
    add x11, x11, x10
    LOAD_ADDR x12, contract_method_names
    str x21, [x12, x11, lsl #3]
    LOAD_ADDR x12, contract_method_name_lens
    str x22, [x12, x11, lsl #3]
    add x10, x10, #1
    str x10, [x9, x19, lsl #3]
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lcontract_member_fail
    bl _skip_paren_group
    cbnz x0, Lcontract_member_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'-'
    b.ne Lcontract_member_done
    bl _advance_char
    mov w0, #'>'
    bl _expect_char
    cbz x0, Lcontract_member_fail
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lcontract_member_ret_single
    bl _advance_char
    bl _skip_paren_group
    cbnz x0, Lcontract_member_fail
    b Lcontract_member_done
Lcontract_member_ret_single:
    bl _skip_type_surface
    cbz x0, Lcontract_member_fail

Lcontract_member_done:
    bl _consume_optional_semicolon
    mov x0, #0
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lcontract_member_fail:
    mov x0, #1
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_define_hidden_var:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    LOAD_ADDR x23, var_count
    ldr x24, [x23]
    // Grow the malloc-backed variable tables (incl. hidden_var_name_storage) on
    // demand instead of failing at a fixed cap. x23 (&var_count), x24 (index)
    // and x19/x21/x22 (the values) are callee-saved and survive the grow.
    LOAD_ADDR x9, var_capacity
    ldr x9, [x9]
    cmp x24, x9
    b.lt Lhidden_var_have_space
    bl _snc_grow_vars
Lhidden_var_have_space:

    LOAD_TBL x9, hidden_var_name_storage
    add x9, x9, x24, lsl #5
    str x24, [x9]
    LOAD_TBL x10, var_name_ptrs
    str x9, [x10, x24, lsl #3]
    LOAD_TBL x10, var_name_lens
    mov x11, #8
    str x11, [x10, x24, lsl #3]
    LOAD_TBL x10, var_values
    str x19, [x10, x24, lsl #3]
    LOAD_TBL x10, var_const_flags
    str xzr, [x10, x24, lsl #3]
    LOAD_TBL x10, var_types
    str x21, [x10, x24, lsl #3]
    LOAD_TBL x10, var_lengths
    str x22, [x10, x24, lsl #3]
    add x24, x24, #1
    str x24, [x23]
    LOAD_ADDR x10, max_var_count
    ldr x11, [x10]
    cmp x24, x11
    b.le Lhidden_var_ok
    str x24, [x10]
Lhidden_var_ok:
    mov x0, #1
    sub x1, x24, #1
    b Lhidden_var_return
Lhidden_var_fail:
    mov x0, #0
    mov x1, #-1
Lhidden_var_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_reserve_object_instance:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    mov x19, x0
    LOAD_ADDR x9, object_instance_count
    ldr x20, [x9]
    cmp x20, #128
    b.ge Lreserve_object_fail
    LOAD_ADDR x10, object_blueprint_ids
    str x19, [x10, x20, lsl #3]
    mov x11, #0
Lreserve_object_init_loop:
    cmp x11, #8
    b.ge Lreserve_object_done_init
    mov x12, x20
    lsl x12, x12, #3
    add x12, x12, x11
    LOAD_ADDR x13, object_field_var_idxs
    mov x14, #-1
    str x14, [x13, x12, lsl #3]
    add x11, x11, #1
    b Lreserve_object_init_loop
Lreserve_object_done_init:
    add x11, x20, #1
    str x11, [x9]
    mov x0, #1
    mov x1, x20
    b Lreserve_object_return
Lreserve_object_fail:
    mov x0, #0
    mov x1, #-1
Lreserve_object_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_lookup_blueprint_field:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
Lbp_field_bp_loop:
    cmp x19, #-1
    b.eq Lbp_field_fail
    LOAD_ADDR x9, blueprint_field_counts
    ldr x22, [x9, x19, lsl #3]
    mov x23, #0
Lbp_field_loop:
    cmp x23, x22
    b.ge Lbp_field_parent
    mov x24, x19
    lsl x24, x24, #3
    add x24, x24, x23
    LOAD_ADDR x9, blueprint_field_name_lens
    ldr x10, [x9, x24, lsl #3]
    cmp x10, x21
    b.ne Lbp_field_next
    LOAD_ADDR x9, blueprint_field_names
    ldr x11, [x9, x24, lsl #3]
    mov x0, x20
    mov x1, x21
    mov x2, x11
    bl _match_span_span
    cbnz x0, Lbp_field_found
Lbp_field_next:
    add x23, x23, #1
    b Lbp_field_loop
Lbp_field_parent:
    LOAD_ADDR x9, blueprint_parent_ids
    ldr x19, [x9, x19, lsl #3]
    b Lbp_field_bp_loop
Lbp_field_found:
    LOAD_ADDR x9, blueprint_field_types
    ldr x2, [x9, x24, lsl #3]
    LOAD_ADDR x9, blueprint_field_metas
    ldr x3, [x9, x24, lsl #3]
    mov x0, #1
    mov x1, x23
    b Lbp_field_return
Lbp_field_fail:
    mov x0, #0
    mov x1, #-1
Lbp_field_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_lookup_blueprint_method:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
Lbp_method_bp_loop:
    cmp x19, #-1
    b.eq Lbp_method_fail
    LOAD_ADDR x9, blueprint_method_counts
    ldr x22, [x9, x19, lsl #3]
    mov x23, #0
Lbp_method_loop:
    cmp x23, x22
    b.ge Lbp_method_parent
    mov x24, x19
    lsl x24, x24, #3
    add x24, x24, x23
    LOAD_ADDR x9, blueprint_method_name_lens
    ldr x10, [x9, x24, lsl #3]
    cmp x10, x21
    b.ne Lbp_method_next
    LOAD_ADDR x9, blueprint_method_names
    ldr x11, [x9, x24, lsl #3]
    mov x0, x20
    mov x1, x21
    mov x2, x11
    bl _match_span_span
    cbnz x0, Lbp_method_found
Lbp_method_next:
    add x23, x23, #1
    b Lbp_method_loop
Lbp_method_parent:
    LOAD_ADDR x9, blueprint_parent_ids
    ldr x19, [x9, x19, lsl #3]
    b Lbp_method_bp_loop
Lbp_method_found:
    LOAD_ADDR x9, blueprint_method_fn_ids
    ldr x1, [x9, x24, lsl #3]
    mov x0, #1
    b Lbp_method_return
Lbp_method_fail:
    mov x0, #0
    mov x1, #-1
Lbp_method_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_build_method_synth_name:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    LOAD_TBL x23, method_name_storage
    add x23, x23, x22, lsl #6
    mov x24, x23
    LOAD_ADDR x9, blueprint_name_ptrs
    ldr x25, [x9, x19, lsl #3]
    LOAD_ADDR x9, blueprint_name_lens
    ldr x26, [x9, x19, lsl #3]
    mov x10, #0
Lbuild_method_copy_bp:
    cmp x10, x26
    b.ge Lbuild_method_sep1
    ldrb w11, [x25, x10]
    strb w11, [x24], #1
    add x10, x10, #1
    b Lbuild_method_copy_bp
Lbuild_method_sep1:
    mov w11, #'_'
    strb w11, [x24], #1
    mov x10, #0
Lbuild_method_copy_name:
    cmp x10, x21
    b.ge Lbuild_method_done
    ldrb w11, [x20, x10]
    strb w11, [x24], #1
    add x10, x10, #1
    b Lbuild_method_copy_name
Lbuild_method_done:
    strb wzr, [x24]
    sub x1, x24, x23
    mov x0, x23
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_resolve_object_field_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x0, x20
    mov x1, x21
    mov x2, x22
    bl _lookup_blueprint_field
    cbz x0, Lresolve_object_field_fail
    mov x23, x1
    mov x24, x19
    lsl x24, x24, #3
    add x24, x24, x23
    LOAD_ADDR x9, object_field_var_idxs
    ldr x24, [x9, x24, lsl #3]
    cmp x24, #-1
    b.eq Lresolve_object_field_fail
    LOAD_TBL x9, var_values
    ldr x1, [x9, x24, lsl #3]
    LOAD_TBL x9, var_types
    ldr x2, [x9, x24, lsl #3]
    LOAD_TBL x9, var_lengths
    ldr x3, [x9, x24, lsl #3]
    mov x4, x24
    mov x0, #1
    b Lresolve_object_field_return
Lresolve_object_field_fail:
    mov x0, #0
Lresolve_object_field_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_call_object_method:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    sub sp, sp, #32

    mov x19, x0  // instance id
    mov x20, x1  // obj type (10=stack, 11=heap)
    mov x21, x2  // blueprint id
    mov x22, x3  // method name ptr
    mov x23, x4  // method name len

    // Save current self
    LOAD_ADDR x9, current_self_instance
    ldr x25, [x9]
    str x25, [sp]
    LOAD_ADDR x9, current_self_type
    ldr x26, [x9]
    str x26, [sp, #8]
    LOAD_ADDR x9, current_self_meta
    ldr x10, [x9]
    str x10, [sp, #16]

    // Set self to this object
    LOAD_ADDR x9, current_self_instance
    str x19, [x9]
    LOAD_ADDR x9, current_self_type
    str x20, [x9]
    LOAD_ADDR x9, current_self_meta
    str x21, [x9]

    // ---- Try per-instance INLINE dispatch (real methods only) ----
    // Inline the method body here with `self` bound to THIS instance so
    // `self.field` resolves to the instance's own field slots (per-instance).
    // The constructor "create" and any un-inlinable case (recursion / nesting
    // too deep) fall back to the shared template-self body via `bl` below.
    mov x0, x22
    mov x1, x23
    LOAD_ADDR x2, kw_create
    bl _match_cstr_span
    cbnz x0, Lcom_use_bl
    mov x0, x21
    mov x1, x22
    mov x2, x23
    mov x3, #62                 // scratch synth-name slot (distinct from 63)
    bl _build_method_synth_name
    bl _lookup_function
    cbz x0, Lcom_use_bl          // unknown method -> old path (errors there)
    mov x0, x1                   // mfid
    bl _inline_object_method
    cmp x0, #2
    b.eq Lcom_use_bl             // cannot inline -> shared template-self fallback
    cbnz x0, Lcall_object_method_fail_restore
    mov x1, #0                   // value placeholder (result is in x4 slot)
    b Lcom_after_call

Lcom_use_bl:
    // Build Blueprint__methodname for dispatch
    mov x0, x21   // blueprint id
    mov x1, x22   // method name ptr
    mov x2, x23   // method name len
    mov x3, #63   // use dedicated call-time slot (slot 63)
    bl _build_method_synth_name
    // x0=synth name ptr, x1=synth name len

    bl _call_function
    cbnz x0, Lcall_object_method_fail_restore

Lcom_after_call:
    // Restore self
    LOAD_ADDR x9, current_self_instance
    ldr x10, [sp]
    str x10, [x9]
    LOAD_ADDR x9, current_self_type
    ldr x10, [sp, #8]
    str x10, [x9]
    LOAD_ADDR x9, current_self_meta
    ldr x10, [sp, #16]
    str x10, [x9]
    b Lcall_object_method_return

Lcall_object_method_fail_restore:
    LOAD_ADDR x9, current_self_instance
    ldr x10, [sp]
    str x10, [x9]
    LOAD_ADDR x9, current_self_type
    ldr x10, [sp, #8]
    str x10, [x9]
    LOAD_ADDR x9, current_self_meta
    ldr x10, [sp, #16]
    str x10, [x9]
    mov x0, #1
    b Lcall_object_method_return

Lcall_object_method_return:
    add sp, sp, #32
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_instantiate_object_fields:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    LOAD_ADDR x9, blueprint_field_counts
    ldr x21, [x9, x20, lsl #3]
    mov x22, #0
Linst_object_field_loop:
    cmp x22, x21
    b.ge Linst_object_field_done
    mov x23, x20
    lsl x23, x23, #3
    add x23, x23, x22
    LOAD_ADDR x9, blueprint_field_types
    ldr x10, [x9, x23, lsl #3]
    LOAD_ADDR x9, blueprint_field_metas
    ldr x11, [x9, x23, lsl #3]
    LOAD_ADDR x9, blueprint_field_default_flags
    ldr x12, [x9, x23, lsl #3]
    cbz x12, Linst_object_field_no_default
    LOAD_ADDR x9, blueprint_field_default_values
    ldr x0, [x9, x23, lsl #3]
    LOAD_ADDR x9, blueprint_field_default_types
    ldr x13, [x9, x23, lsl #3]
    LOAD_ADDR x9, blueprint_field_default_metas
    ldr x14, [x9, x23, lsl #3]
    mov x1, #0
    mov x2, x13
    mov x3, x14
    bl _define_hidden_var
    cbz x0, Linst_object_field_fail
    b Linst_object_field_store_idx
Linst_object_field_no_default:
    mov x0, #0
    mov x1, #0
    cmp x10, #27
    b.eq Linst_object_field_default_none
    mov x2, x10
    mov x3, x11
    bl _define_hidden_var
    cbz x0, Linst_object_field_fail
    b Linst_object_field_store_idx
Linst_object_field_default_none:
    mov x2, #7
    mov x3, #0
    bl _define_hidden_var
    cbz x0, Linst_object_field_fail
Linst_object_field_store_idx:
    mov x15, x1
    LOAD_ADDR x9, blueprint_field_types
    ldr x10, [x9, x23, lsl #3]
    mov x24, x19
    lsl x24, x24, #3
    add x24, x24, x22
    LOAD_ADDR x9, object_field_var_idxs
    str x15, [x9, x24, lsl #3]
    cmp x10, #2
    b.eq Linst_object_field_next
    cmp x10, #4
    b.eq Linst_object_field_next
    cmp x10, #6
    b.eq Linst_object_field_next
    mov x0, x15
    LOAD_TBL x9, var_values
    ldr x1, [x9, x15, lsl #3]
    bl _record_store_variable
    cbnz x0, Linst_object_field_fail
Linst_object_field_next:
    add x22, x22, #1
    b Linst_object_field_loop
Linst_object_field_done:
    mov x0, #1
    b Linst_object_field_return
Linst_object_field_fail:
    mov x0, #0
Linst_object_field_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_function_body:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0 // fn index
    mov x24, #0 // parse status

    LOAD_ADDR x9, current_parse_fn_id
    str x19, [x9]

    // Save scope base and set new scope base
    LOAD_ADDR x9, var_count
    ldr x21, [x9] // x21 = saved var_count
    
    // Set variable scope base to current count (new scope starts here)
    LOAD_ADDR x9, var_scope_base
    str x21, [x9]

    // Record this function's slot base for scope-relative codegen
    LOAD_TBL x9, fn_scope_bases
    str x21, [x9, x19, lsl #3]
    
    // Check if it is a method
    LOAD_TBL x9, fn_blueprint_ids
    ldr x20, [x9, x19, lsl #3]
    cmn x20, #1
    b.eq Lparse_fn_body_not_method
    
    // Define 'self'
    LOAD_ADDR x0, kw_self
    mov x1, #4
    mov x2, #10 // type object
    mov x3, x20 // blueprint id
    mov x4, #0
    mov x5, #1 // const
    bl _define_variable
    cbnz x0, Lparse_fn_body_error

    // Bind `self` for this method's standalone (dead-but-must-assemble) body:
    // meta = blueprint id, type = 10 (object), instance = the blueprint's
    // definition-time template (id stored as id+1). Real calls re-bind self to
    // the caller's actual instance during inline reparse (not via this path).
    LOAD_ADDR x9, current_self_meta
    str x20, [x9]
    LOAD_ADDR x9, current_self_type
    mov x10, #10
    str x10, [x9]
    LOAD_ADDR x9, blueprint_template_instances
    ldr x10, [x9, x20, lsl #3]
    sub x10, x10, #1            // stored id+1 -> real id (or -1 if none)
    LOAD_ADDR x9, current_self_instance
    str x10, [x9]
    b Lparse_fn_body_params

Lparse_fn_body_not_method:
    // Ordinary function: make sure no stale `self` binding leaks in from a
    // previously-compiled method body.
    LOAD_ADDR x9, current_self_type
    str xzr, [x9]

Lparse_fn_body_params:
    // Define parameters
    LOAD_TBL x9, fn_param_counts
    ldr x22, [x9, x19, lsl #3]
    mov x23, #0
Lparse_fn_body_param_loop:
    cmp x23, x22
    b.ge Lparse_fn_body_start
    
    mov x9, x19
    lsl x9, x9, #2
    add x9, x9, x23
    
    LOAD_TBL x10, fn_param_name_ptrs
    ldr x0, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_name_lens
    ldr x1, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_types
    ldr x2, [x10, x9, lsl #3]
    LOAD_TBL x10, fn_param_lengths
    ldr x3, [x10, x9, lsl #3]
    mov x5, x3  // metadata/length
    mov x4, x2  // declared type
    mov x3, #0  // not const
    mov x2, #0  // runtime value arrives in x0..x3 and is stored by codegen
    bl _define_variable
    cbnz x0, Lparse_fn_body_error
    
    add x23, x23, #1
    b Lparse_fn_body_param_loop

Lparse_fn_body_start:
    // Record start op
    LOAD_ADDR x9, op_count
    ldr x10, [x9]
    LOAD_TBL x9, fn_op_starts
    str x10, [x9, x19, lsl #3]

    // Set cursor
    LOAD_TBL x9, fn_body_cursors
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, cursor_pos
    str x10, [x9]
    LOAD_TBL x9, fn_body_lines
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, current_line
    str x10, [x9]
    
    // Set source (needed for module functions which have different source buffer)
    LOAD_TBL x9, fn_source_ptrs
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, source_ptr
    str x10, [x9]
    LOAD_TBL x9, fn_source_lens
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, source_len
    str x10, [x9]
    
    // Debug: print cursor position
    // stp x10, x19, [sp, #-16]!
    // LOAD_ADDR x0, msg_debug_fn
    // mov x1, #2
    // bl _write_cstr_fd
    // mov x0, x19
    // mov x1, #2
    // bl _write_i64_fd
    // LOAD_ADDR x0, msg_colon_space
    // mov x1, #2
    // bl _write_cstr_fd
    // mov x0, x10
    // mov x1, #2
    // bl _write_i64_fd
    // bl _write_newline_stdout
    // ldp x10, x19, [sp], #16

    // Parse body loop
Lparse_fn_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lparse_fn_body_done
    cbz w0, Lparse_fn_body_done
    
    bl _parse_statement
    cbz x0, Lparse_fn_body_loop
    cmp x0, #4
    b.eq Lparse_fn_body_loop // return recorded as an op; keep compiling the rest
    b Lparse_fn_body_error // EXIT ON ERROR


Lparse_fn_body_error:
    mov x24, #1
    b Lparse_fn_body_done

Lparse_fn_body_done:
    // Record count
    LOAD_ADDR x9, op_count
    ldr x11, [x9]
    LOAD_TBL x9, fn_op_starts
    ldr x10, [x9, x19, lsl #3]
    sub x11, x11, x10
    LOAD_TBL x9, fn_op_counts
    str x11, [x9, x19, lsl #3]

    // Record runtime frame size: locals+params+TEMPS used by this body.
    // Use max_var_count (the monotonic PEAK), NOT the end-of-body var_count:
    // temp slots are recycled during parsing (var_count shrinks back), so the
    // end value badly undercounts the real peak. The generated code addresses
    // slot S at [x29,-(S-scope_base+1)*8], and the deepest slot reached equals
    // (peak-1); an undersized frame lets a callee/recursion overwrite the
    // caller's live locals (e.g. a recursive solver's helper call clobbered its
    // loop counters). max_var_count is >= this function's true peak, so the
    // frame always covers every slot it can address (may slightly over-allocate,
    // which is harmless). (peak - scope base + slack) * 8, 16-aligned, min 128.
    LOAD_ADDR x9, max_var_count
    ldr x10, [x9]
    sub x10, x10, x21
    add x10, x10, #6          // slack slots
    lsl x10, x10, #3          // * 8 bytes
    add x10, x10, #15
    and x10, x10, #0xFFFFFFFFFFFFFFF0
    mov x11, #128
    cmp x10, x11
    csel x10, x11, x10, lt    // min 128
    LOAD_TBL x9, fn_frame_sizes
    str x10, [x9, x19, lsl #3]

    // Restore scope
    LOAD_ADDR x9, var_count
    str x21, [x9]
    
    // Restore variable scope base
    LOAD_ADDR x9, var_scope_base
    str x21, [x9]

    LOAD_ADDR x9, current_parse_fn_id
    mov x10, #-1
    str x10, [x9]

    mov x0, x24
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


// ============================================================
// _record_return_op
//   Gated recorder for the `return` statement.
//   x1 = the op-4 argument (runtime result slot when available, else value/-1)
//   x2 = the TRUE runtime result slot (-1 if the return has none / is void)
//   Returns x0=0 on success.
//
//   When NOT inlining (inline_active == 0) this is byte-identical to the old
//   `mov x0,#4 ... _record_operation4`, so every normal function/recursion path
//   is unchanged. When inlining a method body at a call site, a `return <v>`
//   must NOT emit a function epilogue+ret (that would tear down / return from the
//   ENCLOSING function). Instead it copies its value into the inline result slot
//   (op 45) and jumps to the inline end label (op 41).
// ============================================================
.global _record_return_op
_record_return_op:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x1    // op-4 arg (slot/value/-1)
    mov x20, x2    // true runtime slot (-1 if none)

    LOAD_ADDR x9, inline_active
    ldr x9, [x9]
    cbz x9, Lrro_normal

    // INLINE: deposit value into inline_result_slot (if any), then jump to end.
    cmn x20, #1
    b.eq Lrro_inline_jump          // void / no runtime slot: skip the value copy
    LOAD_ADDR x9, inline_result_slot
    ldr x1, [x9]                   // target = inline result slot
    mov x2, x20                    // source = the return value's runtime slot
    mov x0, #45                    // op 45: store var -> var (runtime copy)
    bl _record_operation
    cbnz x0, Lrro_fail
Lrro_inline_jump:
    LOAD_ADDR x9, inline_end_label
    ldr x1, [x9]                   // label id
    mov x0, #41                    // op 41: unconditional branch
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lrro_fail
    b Lrro_ok

Lrro_normal:
    // Unchanged normal `return` op.
    mov x0, #4
    mov x1, x19
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4
    cbnz x0, Lrro_fail

Lrro_ok:
    mov x0, #0
Lrro_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
Lrro_fail:
    mov x0, #1
    b Lrro_return

// ============================================================
// _inline_object_method
//   x0 = method fn index (mfid). Precondition: `self` is already bound to the
//   ACTUAL caller instance (current_self_*), and the cursor sits at the call's
//   '(' . Consumes the '(...)' argument list, then re-parses the method body
//   INLINE into the current op stream so that `self.field` resolves to THIS
//   instance's field slots (per-instance).
//
//   Returns:
//     x0 = 0  success. x2 = return type, x3 = return decl length, x4 = result
//              slot; last_call_result_slot is set to the result slot.
//     x0 = 1  hard parse failure.
//     x0 = 2  cannot inline (recursion or nesting too deep) -> caller uses the
//              shared template-self `bl` fallback.
//
//   Local stack frame (96 bytes):
//     [sp,#0]  saved cursor_pos (call site)   [sp,#8]  saved current_line
//     [sp,#16] saved source_ptr               [sp,#24] saved source_len
//     [sp,#32] saved inline_result_slot        [sp,#40] saved inline_end_label
//     [sp,#48] param name ptr (per arg)        [sp,#56] param name len (per arg)
//     [sp,#64] arg value (per arg)             [sp,#72] arg runtime slot (per arg)
//     [sp,#80] param declared type (per arg)
// ============================================================
.global _inline_object_method
_inline_object_method:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    sub sp, sp, #96

    mov x19, x0                    // mfid

    // ---- recursion / depth guard ----
    LOAD_ADDR x9, inline_active
    ldr x26, [x9]                  // current depth
    cmp x26, #16
    b.ge Linline_cannot
    mov x27, #0
Linline_guard_loop:
    cmp x27, x26
    b.ge Linline_guard_ok
    LOAD_ADDR x9, inline_fn_stack
    ldr x28, [x9, x27, lsl #3]
    cmp x28, x19
    b.eq Linline_cannot            // this method is already inlining -> recursion
    add x27, x27, #1
    b Linline_guard_loop
Linline_guard_ok:

    // ---- save call-site cursor/source/line ----
    LOAD_ADDR x9, cursor_pos
    ldr x10, [x9]
    str x10, [sp, #0]
    LOAD_ADDR x9, current_line
    ldr x10, [x9]
    str x10, [sp, #8]
    LOAD_ADDR x9, source_ptr
    ldr x10, [x9]
    str x10, [sp, #16]
    LOAD_ADDR x9, source_len
    ldr x10, [x9]
    str x10, [sp, #24]

    // ---- save var scope ----
    LOAD_ADDR x9, var_count
    ldr x24, [x9]                  // Vsave
    LOAD_ADDR x9, var_scope_base
    ldr x25, [x9]                  // Bsave

    // ---- allocate result slot FIRST (lowest; survives reclamation) ----
    bl _allocate_temp_var
    mov x20, x0                    // Rslot

    // ---- open a fresh block scope for params/body locals ----
    LOAD_ADDR x9, var_count
    ldr x10, [x9]
    LOAD_ADDR x9, var_scope_base
    str x10, [x9]                  // scope_base = current var_count

    // Define `self` as a variable in the inline scope. The primary parser only
    // treats `ident.member` as MEMBER access when `ident` is a known variable
    // (otherwise it attempts module-qualified access `module.func` and fails).
    // The standalone method body defines `self` the same way; the inline path
    // must too, or `self.field` is misparsed as module access on `self`.
    LOAD_ADDR x0, kw_self
    mov x1, #4
    mov x2, #10
    LOAD_TBL x9, fn_blueprint_ids
    ldr x3, [x9, x19, lsl #3]      // blueprint id of this method
    mov x4, #0
    mov x5, #1
    bl _define_variable
    cbnz x0, Linline_fail

    // ---- parse '(' args ')' and bind each param ----
    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Linline_fail
    LOAD_TBL x9, fn_param_counts
    ldr x22, [x9, x19, lsl #3]     // paramCount
    mov x23, #0                    // arg index
Linline_arg_loop:
    cmp x23, x22
    b.ge Linline_args_done
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #')'
    b.eq Linline_args_done
    cbz x23, Linline_arg_parse
    mov w0, #','
    bl _expect_char
    cbz x0, Linline_fail
    bl _skip_whitespace
Linline_arg_parse:
    mov x9, x19
    lsl x9, x9, #2
    add x9, x9, x23
    LOAD_TBL x10, fn_param_name_ptrs
    ldr x11, [x10, x9, lsl #3]
    str x11, [sp, #48]
    LOAD_TBL x10, fn_param_name_lens
    ldr x11, [x10, x9, lsl #3]
    str x11, [sp, #56]
    LOAD_TBL x10, fn_param_types
    ldr x11, [x10, x9, lsl #3]
    str x11, [sp, #80]
    bl _parse_expr_value
    cbz x0, Linline_fail
    str x1, [sp, #64]              // arg value
    str x4, [sp, #72]              // arg runtime slot (-1 if immediate)
    // define the param variable in the inner scope
    ldr x0, [sp, #48]
    ldr x1, [sp, #56]
    ldr x2, [sp, #64]
    mov x3, #0
    ldr x4, [sp, #80]
    bl _define_variable
    cbnz x0, Linline_fail
    LOAD_ADDR x9, var_count
    ldr x10, [x9]
    sub x10, x10, #1              // new param slot
    ldr x11, [sp, #72]
    cmn x11, #1
    b.eq Linline_arg_imm
    mov x1, x10                  // target = param slot
    mov x2, x11                  // source = arg slot
    mov x0, #45
    bl _record_operation
    cbnz x0, Linline_fail
    b Linline_arg_next
Linline_arg_imm:
    mov x1, x10                  // target = param slot
    ldr x2, [sp, #64]            // immediate value
    mov x0, #1
    bl _record_operation
    cbnz x0, Linline_fail
Linline_arg_next:
    add x23, x23, #1
    b Linline_arg_loop

Linline_args_done:
    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Linline_fail

    // ---- save the RESUME point: cursor/line AFTER the call's ')'. The
    // entry-time save pointed at '(' -- restoring to it would re-parse the arg
    // list. source_ptr/len were saved at entry and are unchanged here.
    LOAD_ADDR x9, cursor_pos
    ldr x10, [x9]
    str x10, [sp, #0]
    LOAD_ADDR x9, current_line
    ldr x10, [x9]
    str x10, [sp, #8]

    // ---- save outer inline state, install ours ----
    LOAD_ADDR x9, inline_result_slot
    ldr x10, [x9]
    str x10, [sp, #32]
    LOAD_ADDR x9, inline_end_label
    ldr x10, [x9]
    str x10, [sp, #40]

    bl _get_next_label
    mov x21, x0                   // end label
    LOAD_ADDR x9, inline_result_slot
    str x20, [x9]
    LOAD_ADDR x9, inline_end_label
    str x21, [x9]

    LOAD_ADDR x9, inline_fn_stack
    str x19, [x9, x26, lsl #3]    // push mfid
    add x27, x26, #1
    LOAD_ADDR x9, inline_active
    str x27, [x9]                 // depth++

    // ---- seek to the method body ----
    LOAD_TBL x9, fn_body_cursors
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, cursor_pos
    str x10, [x9]
    LOAD_TBL x9, fn_body_lines
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, current_line
    str x10, [x9]
    LOAD_TBL x9, fn_source_ptrs
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, source_ptr
    str x10, [x9]
    LOAD_TBL x9, fn_source_lens
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, source_len
    str x10, [x9]

    // ---- parse body statements ----
Linline_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Linline_body_done
    cbz w0, Linline_body_done
    bl _parse_statement
    cbz x0, Linline_body_loop
    cmp x0, #4
    b.eq Linline_body_loop         // return recorded (gated) -> keep parsing
    b Linline_body_fail

Linline_body_done:
    // place the inline end label
    mov x0, #35
    mov x1, x21
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4

    // ---- pop inline state ----
    LOAD_ADDR x9, inline_active
    str x26, [x9]
    LOAD_ADDR x9, inline_result_slot
    ldr x10, [sp, #32]
    str x10, [x9]
    LOAD_ADDR x9, inline_end_label
    ldr x10, [sp, #40]
    str x10, [x9]

    // ---- restore cursor/source/line to the call site ----
    LOAD_ADDR x9, source_ptr
    ldr x10, [sp, #16]
    str x10, [x9]
    LOAD_ADDR x9, source_len
    ldr x10, [sp, #24]
    str x10, [x9]
    LOAD_ADDR x9, cursor_pos
    ldr x10, [sp, #0]
    str x10, [x9]
    LOAD_ADDR x9, current_line
    ldr x10, [sp, #8]
    str x10, [x9]

    // ---- restore scope: keep the result slot, reclaim params/body locals ----
    add x10, x20, #1
    LOAD_ADDR x9, var_count
    str x10, [x9]
    LOAD_ADDR x9, var_scope_base
    str x25, [x9]

    // ---- publish result (same convention as _call_function) ----
    LOAD_ADDR x9, last_call_result_slot
    str x20, [x9]
    LOAD_TBL x9, fn_return_types
    ldr x2, [x9, x19, lsl #3]
    LOAD_TBL x9, fn_return_decl_lengths
    ldr x3, [x9, x19, lsl #3]
    mov x4, x20
    mov x1, #0
    mov x0, #0
    b Linline_return

Linline_body_fail:
    LOAD_ADDR x9, inline_active
    str x26, [x9]
    LOAD_ADDR x9, inline_result_slot
    ldr x10, [sp, #32]
    str x10, [x9]
    LOAD_ADDR x9, inline_end_label
    ldr x10, [sp, #40]
    str x10, [x9]
    LOAD_ADDR x9, source_ptr
    ldr x10, [sp, #16]
    str x10, [x9]
    LOAD_ADDR x9, source_len
    ldr x10, [sp, #24]
    str x10, [x9]
    LOAD_ADDR x9, cursor_pos
    ldr x10, [sp, #0]
    str x10, [x9]
    LOAD_ADDR x9, current_line
    ldr x10, [sp, #8]
    str x10, [x9]
    LOAD_ADDR x9, var_scope_base
    str x25, [x9]
Linline_fail:
    LOAD_ADDR x9, var_scope_base
    str x25, [x9]
    mov x0, #1
    b Linline_return

Linline_cannot:
    mov x0, #2

Linline_return:
    add sp, sp, #96
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
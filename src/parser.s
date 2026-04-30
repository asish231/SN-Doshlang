#include "platform.inc"
 .text
 .align 4
 .global _parse_program
 .global _parse_statement
 .global _pow10_u64

_parse_program:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

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
    cbnz x0, Lprogram_fail
    b Lprogram_loop

Lprogram_ok:
    mov x0, #0
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
    cbnz x0, Lpreparse_skip_decl_block
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
    b Lstmt_return

Lstmt_contract:
    bl _parse_contract
    b Lstmt_return

Lstmt_new:
    bl _parse_new_object
    b Lstmt_return

Lstmt_stack_object:
    bl _parse_stack_object
    b Lstmt_return

    LOAD_ADDR x0, msg_unknown_stmt
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    b Lstmt_fail

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

    cmp x22, #2
    b.eq Lstmt_let_done
    cmp x22, #4
    b.eq Lstmt_let_done
    cmp x22, #5
    b.eq Lstmt_let_done

    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_fail
    mov x0, x4
    mov x1, x21
    bl _record_store_variable
    cbnz x0, Lstmt_fail

Lstmt_let_done:
    mov x0, #0
    b Lstmt_return

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
    b Lstmt_fail

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
    b Lstmt_fail

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
    b Lstmt_fail

Lstmt_skip:
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
    b Lstmt_fail

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
    // Store return value
    LOAD_ADDR x9, fn_return_value
    str x1, [x9]
    LOAD_ADDR x9, fn_return_length
    str x3, [x9]
    LOAD_ADDR x9, fn_return_flag
    mov x10, #1
    str x10, [x9]
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
    // Store return value
    LOAD_ADDR x9, fn_return_value
    str x1, [x9]
    LOAD_ADDR x9, fn_return_length
    str x3, [x9]
    LOAD_ADDR x9, fn_return_flag
    mov x10, #1
    str x10, [x9]
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
    b.eq Lstmt_assign_add
    cmp w0, #'-'
    b.eq Lstmt_assign_subtract
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
    b Lstmt_method_call

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
    mov x25, x3
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
    LOAD_ADDR x17, var_values
    str x9, [x17, x16, lsl #3]
    LOAD_ADDR x17, var_types
    str x10, [x17, x16, lsl #3]
    LOAD_ADDR x17, var_lengths
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

Lstmt_index_assign:
    // Parse target index/key: name[expr] = expr
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

    bl _parse_expr_value
    cbz x0, Lstmt_fail
    mov x25, x1 // rhs value
    mov x26, x2 // rhs type
    mov x27, x3 // rhs length
    mov x28, x4 // rhs var id

    // Resolve target variable
    mov x0, x19
    mov x1, x20
    bl _lookup_variable
    cbz x0, Lstmt_unknown_var_assign
    mov x9, x1  // target start index in pool
    mov x10, x2 // target type
    mov x11, x3 // target metadata

    // If rhs comes from var/temp, load concrete value+len now.
    cmn x28, #1
    b.eq Lstmt_index_rhs_ready
    LOAD_ADDR x12, var_values
    ldr x25, [x12, x28, lsl #3]
    LOAD_ADDR x12, var_lengths
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

    // If index came from a variable, read actual index value.
    cmn x24, #1
    b.eq Lstmt_index_list_idx_ready
    LOAD_ADDR x12, var_values
    ldr x21, [x12, x24, lsl #3]
Lstmt_index_list_idx_ready:

    and x12, x11, #0xFFFFFFFF // count
    cmp x21, x12
    b.ge Lstmt_fail

    lsr x13, x11, #32 // element type
    cmp x26, x13
    b.ne Lstmt_type_mismatch

    add x14, x9, x21
    LOAD_ADDR x15, list_pool_values
    str x25, [x15, x14, lsl #3]
    LOAD_ADDR x15, list_pool_lengths
    str x27, [x15, x14, lsl #3]

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

    // If key came from a variable, read actual key value+len.
    cmn x24, #1
    b.eq Lstmt_index_map_key_ready
    LOAD_ADDR x15, var_values
    ldr x21, [x15, x24, lsl #3]
    LOAD_ADDR x15, var_lengths
    ldr x23, [x15, x24, lsl #3]
Lstmt_index_map_key_ready:

    // Update existing key only.
    mov x15, #0
Lstmt_index_map_loop:
    cmp x15, x14
    b.ge Lstmt_index_map_insert_new
    add x16, x9, x15
    LOAD_ADDR x17, map_pool_keys
    ldr x18, [x17, x16, lsl #3]

    cmp x12, #2 // string key?
    b.eq Lstmt_index_map_cmp_str
    cmp x18, x21
    b.eq Lstmt_index_map_store
    b Lstmt_index_map_next

Lstmt_index_map_insert_new:
    // Key not found - insert new key
    LOAD_ADDR x17, map_pool_count
    ldr x18, [x17]
    cmp x18, #4096
    b.ge Lstmt_fail
    mov x16, x18 // Use current global count for the new entry

    LOAD_ADDR x17, map_pool_keys
    str x21, [x17, x16, lsl #3]
    LOAD_ADDR x17, map_pool_key_lengths
    str x23, [x17, x16, lsl #3]

    // Store key pointer for string keys
    cmp x12, #2
    b.ne Lstmt_index_map_insert_skip_ptr
    LOAD_ADDR x17, map_pool_key_ptrs
    str x21, [x17, x16, lsl #3]
Lstmt_index_map_insert_skip_ptr:
    LOAD_ADDR x17, map_pool_values
    str x25, [x17, x16, lsl #3]
    LOAD_ADDR x17, map_pool_lengths
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
    LOAD_ADDR x17, map_pool_key_lengths
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
    LOAD_ADDR x17, map_pool_values
    str x25, [x17, x16, lsl #3]
    LOAD_ADDR x17, map_pool_lengths
    str x27, [x17, x16, lsl #3]
Lstmt_index_map_store_done:
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
    LOAD_ADDR x13, list_pool_values
    LOAD_ADDR x14, list_pool_lengths
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
    LOAD_ADDR x13, list_pool_values
    ldr x23, [x13, x12, lsl #3]
    LOAD_ADDR x14, list_pool_lengths
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
    b Lstmt_fail

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

    LOAD_ADDR x9, var_values
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
    cbz x26, Lstmt_assign_divide_zero
    udiv x28, x25, x26
    b Lstmt_assign_runtime_update
Lstmt_assign_runtime_eval_mod:
    cbz x26, Lstmt_assign_divide_zero
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
    LOAD_ADDR x9, var_values
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
    LOAD_ADDR x9, var_values
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
    b Lstmt_fail

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
    mov x3, #2     // type str
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
    b Lstmt_fail

Lstmt_unknown:
    LOAD_ADDR x0, msg_unknown_stmt
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    b Lstmt_fail

Lstmt_type_mismatch:
    LOAD_ADDR x0, msg_type_mismatch
    bl _report_error_prefix
    // Debug: print types
    // mov x0, x22
    // bl _print_int_debug
    // mov x0, x24
    // bl _print_int_debug
    bl _write_newline_stderr
    b Lstmt_fail

Lstmt_decimal_scale_error:
    LOAD_ADDR x0, msg_decimal_scale
    bl _report_error_prefix
    bl _write_newline_stderr
    b Lstmt_fail

Lstmt_need_keyword:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    b Lstmt_fail

Lstmt_need_name:
    LOAD_ADDR x0, msg_expected_name
    bl _report_error_prefix

Lstmt_fail:
    LOAD_ADDR x0, msg_on_line
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #1

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

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lif_fail

    bl _parse_condition_value
    cbz x0, Lif_fail
    mov x19, x1 // temp_var_id

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lif_fail

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
    LOAD_ADDR x9, var_values
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
    b.eq Lif_return_propagate
    b Lif_fail

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
    b.eq Lif_return_propagate
    b Lif_fail

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

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lwhile_fail

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
    mov w0, #')'
    bl _expect_char
    cbz x0, Lwhile_fail

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
    b.eq Lwhile_return_propagate
    b Lwhile_fail

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
    sub sp, sp, #32

    LOAD_ADDR x9, current_loop_start
    ldr x10, [x9]
    LOAD_ADDR x9, current_loop_end
    ldr x11, [x9]
    stp x10, x11, [sp]
    str xzr, [sp, #16]

    bl _skip_whitespace
    mov w0, #'('
    bl _expect_char
    cbz x0, Lfor_fail

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
    bl _advance_char
    b Lfor_skip_update_text

Lfor_update_end:
    bl _advance_char

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
    b.eq Lfor_counted_return_propagate
    b Lfor_counted_fail

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
    add sp, sp, #32
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
    mov x19, x1 // list start index
    mov x20, x2 // list count
    mov x21, x3 // element type

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lfor_fail

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

    LOAD_ADDR x9, cursor_pos
    ldr x22, [x9]
    LOAD_ADDR x9, current_line
    ldr x23, [x9]

    cbz x20, Lfor_skip_block_done

    bl _get_next_label
    LOAD_ADDR x9, current_loop_end
    str x0, [x9]

    mov x26, #0

Lfor_in_iteration:
    cmp x26, x20
    b.ge Lfor_in_done

    bl _get_next_label
    LOAD_ADDR x9, current_loop_start
    str x0, [x9]

    add x9, x19, x26
    LOAD_ADDR x10, list_pool_values
    ldr x27, [x10, x9, lsl #3]
    LOAD_ADDR x10, list_pool_lengths
    ldr x28, [x10, x9, lsl #3]

    mov x0, x24
    mov x1, x25
    bl _lookup_variable
    cbz x0, Lfor_in_define

    mov x0, x24
    mov x1, x25
    mov x2, x27
    mov x3, x21
    mov x4, x28
    bl _set_variable_full
    cbnz x0, Lfor_fail
    b Lfor_in_store_runtime

Lfor_in_define:
    mov x0, x24
    mov x1, x25
    mov x2, x27
    mov x3, #0
    mov x4, x21
    mov x5, x28
    bl _define_variable
    cbnz x0, Lfor_fail

Lfor_in_store_runtime:
    cmp x21, #2
    b.eq Lfor_in_body_reset
    mov x0, x24
    mov x1, x25
    bl _lookup_variable
    cbz x0, Lfor_fail
    mov x0, x4
    mov x1, x27
    bl _record_store_variable
    cbnz x0, Lfor_fail

Lfor_in_body_reset:
    LOAD_ADDR x9, cursor_pos
    str x22, [x9]
    LOAD_ADDR x9, current_line
    str x23, [x9]

Lfor_in_body_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lfor_in_body_done
    cbz w0, Lwhile_unclosed
    bl _parse_statement
    cbz x0, Lfor_in_body_loop
    cmp x0, #2
    b.eq Lfor_in_stop
    cmp x0, #3
    b.eq Lfor_in_skip_rest
    b Lfor_fail

Lfor_in_body_done:
    bl _advance_char

    mov x0, #35
    LOAD_ADDR x9, current_loop_start
    ldr x1, [x9]
    mov x2, #0
    mov x3, #0
    mov x4, #0
    bl _record_operation4

    add x26, x26, #1
    b Lfor_in_iteration

Lfor_in_skip_rest:
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
    b Lfor_in_iteration

Lfor_in_stop:
    bl _skip_block_contents
    cbnz x0, Lfor_fail
    ldr x12, [sp, #16]
    cbz x12, Lfor_in_stop_no_depth
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    str xzr, [sp, #16]
Lfor_in_stop_no_depth:
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
    ldr x12, [sp, #16]
    cbz x12, Lfor_in_done_no_depth
    LOAD_ADDR x9, loop_context_depth
    ldr x10, [x9]
    sub x10, x10, #1
    str x10, [x9]
    str xzr, [sp, #16]
Lfor_in_done_no_depth:
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
    b Lfor_iterable_return
    b Lfor_iterable_return

Lfor_iterable_fail:
    LOAD_ADDR x0, msg_expected_list
    bl _report_error_prefix
    mov x0, #0

Lfor_iterable_return:
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
    LOAD_ADDR x9, list_pool_count
    ldr x10, [x9]
    LOAD_ADDR x11, list_pool_values
    str x23, [x11, x10, lsl #3]
    LOAD_ADDR x11, list_pool_lengths
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
    LOAD_ADDR x9, map_pool_count
    ldr x10, [x9]
    LOAD_ADDR x11, map_pool_keys
    str x23, [x11, x10, lsl #3]
    LOAD_ADDR x11, map_pool_key_lengths
    str x25, [x11, x10, lsl #3]
    LOAD_ADDR x11, map_pool_values
    str x26, [x11, x10, lsl #3]
    LOAD_ADDR x11, map_pool_lengths
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

_parse_use_statement_after_keyword:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Luse_fail
    
    mov x19, x0  // module name start
    mov x20, x1  // initial module name len
    mov x21, x0  // track current end position
    add x21, x21, x1

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
    b Luse_loop

Luse_done:
    bl _consume_optional_semicolon
    
    // Actually load the module
    mov x0, x19  // module name ptr
    mov x1, x20  // module name len
    bl _load_module
    cbnz x0, Luse_load_error
    
    mov x0, #0
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Luse_load_error:
    LOAD_ADDR x0, msg_module_load_error
    bl _report_error_prefix
    mov x0, #1
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Luse_fail:
    LOAD_ADDR x0, msg_expected_name
    bl _report_error_prefix
    mov x0, #1
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

_parse_expr_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

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
    b.eq Lexpr_type_mismatch
    cmp x20, #6
    b.eq Lexpr_add_dec
    cmp x2, #6
    b.eq Lexpr_type_mismatch
    add x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lexpr_loop

Lexpr_add_str:
    cmp x2, #2
    b.ne Lexpr_type_mismatch
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
    sub x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
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
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
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
    cmp x1, #0
    cset x1, eq
    mov x0, #1
    b Lcond_return

Lcond_parse_first:
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

    mov x0, #1
    mov x1, x19
    mov x2, #0 // int
    mov x3, #0 // length 0
    b Lcond_return

Lcond_logic_and:
    bl _parse_condition_value
    cbz x0, Lcond_fail
    and x19, x19, x1
    b Lcond_logic_loop

Lcond_logic_or:
    bl _parse_condition_value
    cbz x0, Lcond_fail
    orr x19, x19, x1
    cmp x19, #0
    cset x19, ne
    b Lcond_logic_loop

Lcond_fail:
    mov x0, #0
    mov x1, #0

Lcond_return:
    ldp x21, x22, [sp], #16
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

    bl _parse_expr_value
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
    bl _parse_expr_value
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
    LOAD_ADDR x9, var_values
    ldr x25, [x9, x19, lsl #3]
Lcond_left_ready:
    mov x26, x23
    cmn x22, #1
    b.eq Lcond_right_ready
    LOAD_ADDR x9, var_values
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
    LOAD_ADDR x9, var_values
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
    mul x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lterm_loop

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
    cbz x1, Lterm_divide_zero
    cmp x20, #6
    b.eq Lterm_div_dec
    cmp x2, #6
    b.eq Lterm_type_mismatch
    udiv x19, x19, x1
    mov x20, #0
    mov x21, #0
    mov x24, #-1
    b Lterm_loop

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
    cbz x1, Lterm_divide_zero
    cmp x20, #6
    b.eq Lterm_unsupported_decimal
    cmp x2, #6
    b.eq Lterm_unsupported_decimal
    udiv x9, x19, x1
    msub x19, x9, x1, x19
    mov x20, #0
    mov x21, #0
    mov x24, #-1
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
    b Lprimary_identifier

Lprimary_unary_plus:
    bl _advance_char
    bl _skip_whitespace
    bl _parse_numeric_literal
    cbz x0, Lprimary_fail
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_unary_minus:
    bl _advance_char
    bl _skip_whitespace
    bl _parse_numeric_literal
    cbz x0, Lprimary_fail
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
    
    mov x1, x25
    mov x2, x26
    mov x3, x27
    mov x4, x28
    b Lprimary_return

Lprimary_member_access:
    bl _advance_char
    bl _parse_identifier
    cbz x0, Lprimary_fail
    mov x21, x0 // name ptr
    mov x22, x1 // name len

    cmp x26, #10
    b.eq Lprimary_member_object
    cmp x26, #11
    b.eq Lprimary_member_object
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_length
    bl _match_cstr_span
    cbnz x0, Lprimary_member_length
    
    b Lprimary_fail

Lprimary_member_object:
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
    mov x26, x1
    mov x27, x2
    LOAD_ADDR x9, fn_return_value
    ldr x25, [x9]
    cmp x26, #2
    b.eq Lprimary_member_method_len
    cmp x26, #6
    b.eq Lprimary_member_method_len
    cmp x26, #10
    b.eq Lprimary_member_method_len
    cmp x26, #11
    b.eq Lprimary_member_method_len
    mov x27, #0
    b Lprimary_member_method_done
Lprimary_member_method_len:
    LOAD_ADDR x9, fn_return_length
    ldr x27, [x9]
Lprimary_member_method_done:
    mov x28, #-1
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
    and x25, x27, #0xFFFFFFFF
    mov x26, #0
    mov x27, #0
    mov x28, #-1
    b Lprimary_suffix_loop_start

Lprimary_str_length_val:
    mov x25, x27
    mov x26, #0
    mov x27, #0
    mov x28, #-1
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
    LOAD_ADDR x10, list_pool_values
    LOAD_ADDR x11, list_pool_lengths
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
    LOAD_ADDR x10, list_pool_values
    ldr x25, [x10, x9, lsl #3]
    LOAD_ADDR x11, list_pool_lengths
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
    LOAD_ADDR x10, list_pool_values
    LOAD_ADDR x11, list_pool_lengths
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
    LOAD_ADDR x10, map_pool_keys
    ldr x28, [x10, x24, lsl #3]
    LOAD_ADDR x11, map_pool_key_lengths
    ldr x25, [x11, x24, lsl #3]
    cmp x23, x20
    b.ne Lmap_contains_next
    cbz x20, Lmap_contains_int_cmp
    cmp x25, x21
    b.ne Lmap_contains_next
    LOAD_ADDR x10, map_pool_key_ptrs
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
    LOAD_ADDR x10, map_pool_keys
    ldr x28, [x10, x24, lsl #3]
    LOAD_ADDR x11, map_pool_key_lengths
    ldr x25, [x11, x24, lsl #3]
    cmp x23, x20
    b.ne Lmap_has_next
    cbz x20, Lmap_has_int_cmp
    cmp x25, x21
    b.ne Lmap_has_next
    LOAD_ADDR x10, map_pool_key_ptrs
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
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    mov x23, x1 // index
    mov x24, x2 // index type
    mov x21, x3 // index metadata/length
    mov x22, x4 // index source var slot
    
    bl _skip_whitespace
    mov w0, #']'
    bl _expect_char
    cbz x0, Lprimary_fail
    
    cmp x26, #8 // map
    b.eq Lprimary_map_lookup_val
    cmp x26, #4 // list
    b.ne Lprimary_fail
    
    // If it's a list, index must be an int
    cmp x24, #0
    b.ne Lprimary_fail

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

    // op 80: list_load(dest, index_var, base_idx, load_len)
    mov x0, #80
    mov x1, x19 // dest
    mov x2, x23 // use index VALUE (which is the slot id for runtime vars)
    mov x3, x25 // base pool index

    lsr x9, x27, #32 // element type
    cmp x9, #2 // str
    cset x4, eq
    bl _record_operation4
    cbnz x0, Lprimary_fail

    mov x25, #0 // runtime value unknown
    lsr x26, x27, #32 // element type
    mov x27, #0 // runtime length unknown
    mov x28, x19 // var index
    b Lprimary_suffix_loop_start

    Lprimary_list_index_load_pool:
    LOAD_ADDR x11, list_pool_values
    ldr x25, [x11, x10, lsl #3]
    LOAD_ADDR x11, list_pool_lengths
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
    cbz x20, Lprimary_fail

    // If key came from a variable/temp slot, emit runtime load.
    cmn x22, #1
    b.ne Lprimary_map_lookup_runtime

    mov x22, #0 // loop counter
Lmap_lookup_loop_val:
    add x10, x25, x22
    LOAD_ADDR x11, map_pool_keys
    ldr x12, [x11, x10, lsl #3]

    // If it's a string, we need to compare using _match_span_span
    cmp x24, #2
    b.eq Lmap_lookup_str_val

    // Not a string, normal compare
    cmp x12, x23
    b.eq Lmap_lookup_found_val
    b Lmap_lookup_next_val

Lmap_lookup_str_val:
    LOAD_ADDR x11, map_pool_key_lengths
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

    // op 82: map_load(dest, key_var, base_idx, count | flags)
    mov x0, #82
    mov x1, x19 // dest
    mov x2, x23 // key var id
    mov x3, x25 // base pool index
    and x4, x27, #0xFFFFFFFF // count
    lsr x9, x27, #40 // key type
    lsl x9, x9, #56
    orr x4, x4, x9
    ubfx x9, x27, #32, #8 // val type
    cmp x9, #2 // str
    orr x4, x4, x9, lsl #48
    bl _record_operation4
    cbnz x0, Lprimary_fail

    mov x25, #0
    ubfx x26, x27, #32, #8 // val type
    mov x27, #0
    mov x28, x19
    b Lprimary_suffix_loop_start

Lmap_lookup_found_val:

    add x10, x25, x22 // restore x10 just in case
    LOAD_ADDR x11, map_pool_values
    ldr x25, [x11, x10, lsl #3]
    LOAD_ADDR x11, map_pool_lengths
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
    cbnz x0, Lprimary_cast

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_address
    bl _match_cstr_span
    cbnz x0, Lprimary_address

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_value
    bl _match_cstr_span
    cbnz x0, Lprimary_value

    mov x0, x19
    mov x1, x20
    LOAD_ADDR x2, kw_alloc
    bl _match_cstr_span
    cbnz x0, Lprimary_alloc

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
    LOAD_ADDR x9, buffer
    mov x10, x9
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
    // cursor_pos is an offset from source_ptr (= buffer base).
    // x19 is an absolute pointer into buffer.
    // x21 must be the new offset relative to x19 (the string content start).
    LOAD_ADDR x9, cursor_pos
    ldr x11, [x9]              // x11 = current cursor offset from buffer base
    LOAD_ADDR x9, buffer
    sub x10, x19, x9           // x10 = offset of string content start from buffer base
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
    LOAD_ADDR x9, buffer
    mov x10, x9
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
    mov x2, x19 // store element type in length field
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
    mov x0, #73
    mov x1, x25
    mov x2, x24
    bl _record_operation
    cbnz x0, Lcast_fail
    mov x0, #1
    mov x1, #0
    mov x2, #2
    mov x3, #0
    mov x4, x25
    b Lcast_return

Lcast_bool_to_str:
    // Convert bool to "true"/"false" string literals.
    cmp x24, #-1
    b.eq Lcast_bool_value_ready
    LOAD_ADDR x9, var_values
    ldr x19, [x9, x24, lsl #3]
Lcast_bool_value_ready:
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
    // Check fn table not full
    LOAD_ADDR x9, fn_count
    ldr x21, [x9]
    cmp x21, #32
    b.ge Lfn_def_full
    mov x26, #0

    // Store name
    LOAD_ADDR x9, fn_name_ptrs
    str x19, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_name_lens
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
    bl _parse_type_spec
    cbz x0, Lfn_def_fail
    mov x25, x1
    mov x24, x2

Lfn_def_param_store_type:
    // Store param type: fn_param_types[fn_idx * 4 + param_idx]
    cbnz x26, Lfn_def_param_skip_store
    mov x9, x21
    lsl x9, x9, #2         // fn_idx * 4
    add x9, x9, x22        // + param_idx
    LOAD_ADDR x10, fn_param_types
    str x25, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_lengths
    str x24, [x10, x9, lsl #3]
Lfn_def_param_skip_store:

    // Parse param name
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lfn_def_fail

    // Store param name
    mov x23, x0
    mov x24, x1
    cbnz x26, Lfn_def_param_done
    mov x9, x21
    lsl x9, x9, #2
    add x9, x9, x22
    LOAD_ADDR x10, fn_param_name_ptrs
    str x23, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_name_lens
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
    LOAD_ADDR x10, fn_param_lengths
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
    cbnz x26, Lfn_def_param_next
    LOAD_ADDR x10, fn_param_default_flags
    mov x14, #1
    str x14, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_default_values
    str x11, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_default_types
    str x12, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_default_lengths
    str x13, [x10, x9, lsl #3]

Lfn_def_param_next:

    add x22, x22, #1
    b Lfn_def_param_loop

Lfn_def_params_done:
    bl _advance_char // consume ')'

    // Store param count
    cbnz x26, Lfn_def_count_done
    LOAD_ADDR x9, fn_param_counts
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
    cbnz x26, Lfn_def_expect_body
    LOAD_ADDR x9, fn_return_types
    str x25, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_return_decl_lengths
    str x24, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_return_extra_types
    str x11, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_return_extra_decl_lengths
    str x12, [x9, x21, lsl #3]
    b Lfn_def_expect_body

Lfn_def_no_return_type:
    // No return type, store -1
    mov x25, #-1
    cbnz x26, Lfn_def_expect_body
    LOAD_ADDR x9, fn_return_types
    str x25, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_return_decl_lengths
    str xzr, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_return_extra_types
    str x25, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_return_extra_decl_lengths
    str xzr, [x9, x21, lsl #3]

Lfn_def_expect_body:
    bl _skip_whitespace
    mov w0, #'{'
    bl _expect_char
    cbz x0, Lfn_def_fail

    // Store cursor position of body start
    LOAD_ADDR x9, cursor_pos
    ldr x23, [x9]
    LOAD_ADDR x9, current_line
    ldr x24, [x9]
    cbnz x26, Lfn_def_skip_count
    LOAD_ADDR x9, fn_body_cursors
    str x23, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_body_lines
    str x24, [x9, x21, lsl #3]
    LOAD_ADDR x9, source_ptr
    ldr x10, [x9]
    LOAD_ADDR x9, fn_source_ptrs
    str x10, [x9, x21, lsl #3]
    LOAD_ADDR x9, source_len
    ldr x10, [x9]
    LOAD_ADDR x9, fn_source_lens
    str x10, [x9, x21, lsl #3]

    // Increment fn count
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
    LOAD_ADDR x9, fn_name_lens
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x20
    b.ne Lfn_lookup_next
    LOAD_ADDR x9, fn_name_ptrs
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
    sub sp, sp, #32

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

    LOAD_ADDR x9, var_scope_base
    ldr x10, [x9]
    str x10, [sp]
    LOAD_ADDR x9, var_count
    ldr x22, [x9]

    // Look up the function
    mov x0, x19
    mov x1, x20
    bl _lookup_function
    cbz x0, Lfn_call_unknown
    mov x21, x1   // fn index

    // Save the current variable floor so locals can shadow globals.
    LOAD_ADDR x9, var_scope_base
    str x22, [x9]

    // Get param count
    LOAD_ADDR x9, fn_param_counts
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
    LOAD_ADDR x10, fn_param_name_ptrs
    ldr x25, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_name_lens
    ldr x26, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_types
    ldr x27, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_lengths
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
    mov x0, x25
    mov x1, x26
    mov x2, x28
    mov x3, #0   // not const
    mov x4, x27  // type
    mov x5, x7
    bl _define_variable
    cbnz x0, Lfn_call_fail

    // Also emit runtime store for the parameter
    // x22 was var_count before defines. Each param is at x22 + x24.
    LOAD_ADDR x9, var_count
    ldr x0, [x9]
    sub x1, x0, #1 // target var index (the one we just defined)
    
    ldr x9, [sp, #8]
    cmn x9, #1
    b.eq Lfn_call_emit_imm
    // emit op 45 (store_var_var)
    mov x0, #45
    mov x2, x28 // source var_id
    // x1 is already target var index
    bl _record_operation
    b Lfn_call_emit_done
Lfn_call_emit_imm:
    // emit op 1 (store_var_imm)
    mov x0, #1
    mov x2, x28 // imm value
    // x1 is already target var index
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
    LOAD_ADDR x10, fn_param_default_flags
    ldr x11, [x10, x9, lsl #3]
    cbz x11, Lfn_call_wrong_args
    LOAD_ADDR x10, fn_param_name_ptrs
    ldr x25, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_name_lens
    ldr x26, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_types
    ldr x27, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_lengths
    ldr x6, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_default_values
    ldr x28, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_default_types
    ldr x7, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_param_default_lengths
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
    mov x0, #1
    mov x2, x28
    bl _record_operation
    cbnz x0, Lfn_call_fail
    add x24, x24, #1
    b Lfn_call_fill_defaults

Lfn_call_args_ready:
    // Save declared return type for missing-return validation.
    LOAD_ADDR x9, fn_return_types
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

    // Clear return flag
    LOAD_ADDR x9, fn_return_flag
    str xzr, [x9]
    LOAD_ADDR x9, fn_return_length
    str xzr, [x9]

    // Jump cursor to function body
    LOAD_ADDR x9, fn_body_cursors
    ldr x27, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_body_lines
    ldr x28, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_source_ptrs
    ldr x10, [x9, x21, lsl #3]
    LOAD_ADDR x9, source_ptr
    str x10, [x9]
    LOAD_ADDR x9, fn_source_lens
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
    LOAD_ADDR x9, fn_return_types
    ldr x1, [x9, x21, lsl #3]
    LOAD_ADDR x9, fn_return_decl_lengths
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
    
    mov x0, #0
    mov x1, #2 // returns str
    mov x2, #0
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
    add sp, sp, #32
    ldp x27, x28, [sp], #16
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
    bl _skip_whitespace
    LOAD_ADDR x0, kw_follows
    bl _consume_keyword
    cbz x0, Lblueprint_expect_body
Lblueprint_skip_follows_loop:
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lblueprint_fail_name
    bl _skip_generic_suffix
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

Lblueprint_fail_name:
    LOAD_ADDR x9, current_blueprint_parse
    str xzr, [x9]
    LOAD_ADDR x0, msg_expected_name
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #1
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lblueprint_fail_too_many:
    LOAD_ADDR x9, current_blueprint_parse
    str xzr, [x9]
    mov x0, #1
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_parse_contract:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl _skip_whitespace
    bl _parse_identifier
    cbz x0, Lcontract_fail
    bl _skip_generic_suffix
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
    bl _parse_contract_member
    cbnz x0, Lcontract_fail
    b Lcontract_loop
Lcontract_done_close:
    bl _advance_char
Lcontract_done:
    mov x0, #0
    ldp x29, x30, [sp], #16
    ret

Lcontract_fail:
    LOAD_ADDR x0, msg_expected_stmt
    bl _report_error_prefix
    bl _write_newline_stderr
    mov x0, #1
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
    LOAD_ADDR x17, var_values
    str x9, [x17, x16, lsl #3]
    LOAD_ADDR x17, var_types
    str x10, [x17, x16, lsl #3]
    LOAD_ADDR x17, var_lengths
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
    mov x0, #1

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
    LOAD_ADDR x17, var_values
    str x9, [x17, x16, lsl #3]
    LOAD_ADDR x17, var_types
    str x10, [x17, x16, lsl #3]
    LOAD_ADDR x17, var_lengths
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
    mov x0, #1

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
    LOAD_ADDR x9, cursor_pos
    str x23, [x9]
    LOAD_ADDR x9, current_line
    str x24, [x9]
    bl _parse_fn_definition
    ldr x10, [sp]
    add sp, sp, #16
    cbnz x0, Lblueprint_member_fail
    LOAD_ADDR x9, fn_count
    ldr x23, [x9]
    sub x23, x23, #1
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
    ldp x29, x30, [sp], #16
    ret

Lcontract_member_fail:
    mov x0, #1
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
    cmp x24, #512
    b.ge Lhidden_var_fail

    LOAD_ADDR x9, hidden_var_name_storage
    add x9, x9, x24, lsl #5
    str x24, [x9]
    LOAD_ADDR x10, var_name_ptrs
    str x9, [x10, x24, lsl #3]
    LOAD_ADDR x10, var_name_lens
    mov x11, #8
    str x11, [x10, x24, lsl #3]
    LOAD_ADDR x10, var_values
    str x19, [x10, x24, lsl #3]
    LOAD_ADDR x10, var_const_flags
    str xzr, [x10, x24, lsl #3]
    LOAD_ADDR x10, var_types
    str x21, [x10, x24, lsl #3]
    LOAD_ADDR x10, var_lengths
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
    LOAD_ADDR x23, method_name_storage
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
    LOAD_ADDR x9, var_values
    ldr x1, [x9, x24, lsl #3]
    LOAD_ADDR x9, var_types
    ldr x2, [x9, x24, lsl #3]
    LOAD_ADDR x9, var_lengths
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

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x23, x4

    LOAD_ADDR x9, current_self_instance
    ldr x25, [x9]
    str x25, [sp]
    LOAD_ADDR x9, current_self_type
    ldr x26, [x9]
    str x26, [sp, #8]
    LOAD_ADDR x9, current_self_meta
    ldr x10, [x9]
    str x10, [sp, #16]

    LOAD_ADDR x9, current_self_instance
    str x19, [x9]
    LOAD_ADDR x9, current_self_type
    str x20, [x9]
    LOAD_ADDR x9, current_self_meta
    str x21, [x9]

    mov x0, x22
    mov x1, x23
    bl _call_function

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

Lcall_object_method_fail:
    mov x0, #1
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
    LOAD_ADDR x9, var_values
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

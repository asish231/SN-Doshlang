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

    cmp w0, #'0'
    b.lt Lprimary_identifier
    cmp w0, #'9'
    b.le Lprimary_number
    b Lprimary_identifier

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
    
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_length
    bl _match_cstr_span
    cbnz x0, Lprimary_member_length
    
    b Lprimary_fail

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

Lprimary_indexing:
    bl _advance_char
    bl _parse_expr_value
    cbz x0, Lprimary_fail
    mov x23, x1 // index
    mov x24, x2 // index type
    cmp x24, #0
    b.ne Lprimary_fail
    
    bl _skip_whitespace
    mov w0, #']'
    bl _expect_char
    cbz x0, Lprimary_fail
    
    cmp x26, #8 // map
    b.eq Lprimary_map_lookup_val
    cmp x26, #4 // list
    b.ne Lprimary_fail
    
    and x9, x27, #0xFFFFFFFF // count
    cmp x23, x9
    b.ge Lprimary_fail
    
    add x10, x25, x23 // pool index
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
    
    mov x21, #0
Lmap_lookup_loop_val:
    add x10, x25, x21
    LOAD_ADDR x11, map_pool_keys
    ldr x12, [x11, x10, lsl #3]
    cmp x12, x23
    b.eq Lmap_lookup_found_val
    add x21, x21, #1
    cmp x21, x20
    b.lt Lmap_lookup_loop_val
    b Lprimary_fail

Lmap_lookup_found_val:
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
    mov x3, x2 // length
    mov x2, #2 // type str
    mov x0, #1
    mov x4, #-1
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

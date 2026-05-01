_parse_primary_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    bl _skip_whitespace
    bl _peek_char
    cbz w0, Lprimary_fail

    cmp w0, #'('
    b.eq Lprimary_group

    cmp w0, #'['
    b.eq Lprimary_list

    cmp w0, #'{'
    b.eq Lprimary_map

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
    mov x24, x4

    bl _skip_whitespace
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x24
    b Lprimary_suffix_loop

Lprimary_list:
    mov x0, #-1
    bl _parse_list_literal_value
    cbz x0, Lprimary_fail
    mov x19, x1
    mov x21, x2
    mov x20, x3
    cmp x20, #0
    b.eq Lprimary_list_int
    mov x20, #5
    b Lprimary_list_done
Lprimary_list_int:
    mov x20, #4
Lprimary_list_done:
    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, #-1
    b Lprimary_suffix_loop
    mov w0, #')'
    bl _expect_char
    cbz x0, Lprimary_fail

    mov x0, #1
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x24

    Lprimary_suffix_loop:
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'.'
    b.eq Lprimary_member_access
    cmp w0, #'['
    b.eq Lprimary_indexing
    b Lprimary_return

    Lprimary_member_access:
    stp x1, x2, [sp, #-32]!
    str x3, [sp, #16]
    bl _advance_char
    bl _parse_identifier
    cbz x0, Lprimary_fail
    mov x21, x0 // name ptr
    mov x22, x1 // name len

    // Check "length"
    mov x0, x21
    mov x1, x22
    LOAD_ADDR x2, kw_length
    bl _match_cstr_span
    cbnz x0, Lprimary_member_length

    b Lprimary_fail

    Lprimary_member_length:
    // Support .length()
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
    ldr x3, [sp, #16]
    ldp x1, x2, [sp], #32

    cmp x2, #4 // list
    b.eq Lprimary_list_length
    cmp x2, #20 // list?
    b.eq Lprimary_list_length
    cmp x2, #2 // str
    b.eq Lprimary_str_length
    b Lprimary_fail

    Lprimary_list_length:
    and x1, x3, #0xFFFFFFFF
    mov x2, #0
    mov x3, #0
    mov x4, #-1
    b Lprimary_suffix_loop

    Lprimary_str_length:
    mov x1, x3
    mov x2, #0
    mov x3, #0
    mov x4, #-1
    b Lprimary_suffix_loop

    Lprimary_indexing:
    stp x1, x2, [sp, #-32]!
    str x3, [sp, #16]
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

    ldr x3, [sp, #16]
    ldp x1, x2, [sp], #32

    // x1=start, x2=type, x3=metadata
    cmp x2, #8 // map
    b.eq Lprimary_map_lookup
    cmp x2, #4 // list
    b.ne Lprimary_fail

    and x9, x3, #0xFFFFFFFF // count
    cmp x23, x9
    b.ge Lprimary_fail // TODO: better bounds error

    add x10, x1, x23 // pool index
    LOAD_ADDR x11, list_pool_values
    ldr x1, [x11, x10, lsl #3]
    LOAD_ADDR x11, list_pool_lengths
    ldr x21, [x11, x10, lsl #3]
    lsr x2, x3, #32 // element type from metadata
    mov x3, x21 // element length/scale
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_map_lookup:
    lsr x9, x3, #40 // expected key type
    cmp x24, x9
    b.ne Lprimary_fail
    
    and x20, x3, #0xFFFFFFFF // count
    cbz x20, Lprimary_fail
    
    mov x21, #0
Lmap_lookup_loop:
    add x10, x1, x21
    LOAD_ADDR x11, map_pool_keys
    ldr x12, [x11, x10, lsl #3]
    cmp x12, x23
    b.eq Lmap_lookup_found
    add x21, x21, #1
    cmp x21, x20
    b.lt Lmap_lookup_loop
    b Lprimary_fail

Lmap_lookup_found:
    LOAD_ADDR x11, map_pool_values
    ldr x1, [x11, x10, lsl #3]
    LOAD_ADDR x11, map_pool_lengths
    ldr x21, [x11, x10, lsl #3]
    ubfx x2, x3, #32, #8 // val_type
    mov x3, x21
    mov x4, #-1
    b Lprimary_suffix_loop

Lprimary_map:
    mov x0, #-1
    bl _parse_map_literal_value
    cbz x0, Lprimary_fail
    mov x1, x1
    mov x2, #8 // unified map type ID
    mov x3, x3 // metadata
    mov x4, #-1
    mov x0, #1
    b Lprimary_suffix_loop

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
    LOAD_ADDR x2, kw_cast
    bl _match_cstr_span
    cbnz x0, Lprimary_cast

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
    bl _lookup_variable
    cbz x0, Lprimary_try_fn_call
    // x1=value, x2=type, x3=length already set by _lookup_variable
    mov x0, #1
    b Lprimary_suffix_loop

Lprimary_try_fn_call:
    // Not a variable; check if it's a function call
    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'('
    b.ne Lprimary_unknown_var
    // Try to call the function
    mov x0, x19
    mov x1, x20
    bl _call_function
    cbnz x0, Lprimary_fail
    mov x20, x1
    mov x21, x2
    // Read return value
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
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lprimary_cast:
    bl _parse_cast_expression
    b Lprimary_return

_pow10_u64:

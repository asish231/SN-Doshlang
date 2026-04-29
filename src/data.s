#include "platform.inc"
.data
.global msg_usage
.global msg_open_error
.global msg_read_error
.global msg_truncated
.global msg_on_line
.global msg_colon_space
.global msg_expected_stmt
.global msg_expected_name
.global msg_expected_expr
.global msg_expected_char
.global msg_unknown_stmt
.global msg_unknown_var
.global msg_duplicate_var
.global msg_loop_control
.global msg_divide_zero
.global msg_const_assign
.global msg_expected_type
.global msg_expected_list
.global msg_expected_map
.global msg_type_mismatch
.global msg_invalid_decimal
.global msg_decimal_scale
.global msg_unsupported_decimal
.global msg_too_many_vars
.global msg_too_many_prints
.global msg_too_many_ops
.global msg_too_many_fns
.global msg_too_many_params
.global msg_unknown_fn
.global msg_wrong_arg_count
.global msg_expected_arrow
.global msg_missing_return
.global kw_print
.global kw_let
.global kw_int
.global kw_bool
.global kw_const
.global kw_fn
.global kw_main
.global kw_if
.global kw_else
.global kw_while
.global kw_true
.global kw_false
.global kw_and
.global kw_or
.global kw_not
.global kw_str
.global kw_byte
.global kw_dec
.global kw_cast
.global kw_match
.global kw_default
.global kw_use
.global kw_list
.global kw_map
.global kw_length
.global kw_add
.global kw_for
.global kw_stop
.global kw_skip
.global kw_in
.global kw_input
.global kw_return
.global kw_none
.global kw_otherwise
.global kw_file_read
.global kw_file_write
.global kw_ref
.global kw_address
.global kw_value
.global kw_set
.global kw_alloc
.global kw_free
.global kw_push
.global kw_pop
.global kw_contains
.global kw_has
.global kw_keys
.global kw_values
.global asm_header
.global asm_runtime_helpers
.global asm_sub_sp_prefix
.global asm_close_bracket
.global asm_mov_x10_x0
.global asm_load_x0_print_val_adrp
.global asm_load_x0_print_val_add
.global asm_load_x1_print_val_adrp
.global asm_load_x1_print_val_add
.global asm_load_x0_print_val_prefix
.global asm_load_x0_print_val_middle
.global asm_load_x0_print_val_suffix
.global asm_load_x1_print_val_prefix
.global asm_load_x1_print_val_middle
.global asm_load_x1_print_val_suffix
.global asm_load_x0_var
.global asm_load_x1_var
.global asm_store_x0_var
.global asm_print_call_suffix_stack
.global asm_print_fmt_adrp
.global asm_print_val_adrp
.global asm_print_val_ldr
.global asm_print_str_val_adrp
.global asm_print_str_val_add
.global asm_print_call_suffix
.global asm_print_call_stack
.global asm_print_stack_only
.global asm_print_dec_call_stack
.global asm_data_intro
.global asm_data_value_prefix
.global asm_data_value_mid
.global asm_data_value_mid_str
.global asm_data_value_suffix
.global asm_data_value_suffix_str
.global asm_align_3
.global asm_print_fmt_int_adrp
.global asm_print_fmt_str_adrp
.global asm_store_val_adrp
.global asm_store_val_ldr
.global asm_store_var_adrp
.global asm_store_var_str
.global asm_store_var_suffix
.global asm_print_var_adrp
.global asm_print_var_ldr
.global asm_print_fmt_dec_adrp
.global asm_dec_sign_empty_adrp
.global asm_dec_sign_minus_adrp
.global asm_mov_x3_imm_prefix
.global asm_mov_x12_imm_prefix
.global asm_mov_x14_imm_prefix
.global asm_dec_abs_x11_to_x13
.global asm_dec_select_sign_x1
.global asm_dec_split_x13_x14
.global asm_dec_mul_x11_x10_x12
.global asm_dec_div_x11_x10_x12
.global asm_math_var_x11_adrp
.global asm_math_var_x11_ldr
.global asm_math_var_x1_adrp
.global asm_math_var_x1_ldr
.global asm_math_var_x10_adrp
.global asm_math_var_x10_ldr
.global asm_math_store_x11_adrp
.global asm_math_store_x11_str
.global asm_math_add_x11_x10
.global asm_math_sub_x11_x10
.global asm_math_mul_x11_x10
.global asm_math_div_x11_x10
.global asm_math_mod_x11_x10
.global asm_logic_and_x11_x10
.global asm_logic_or_x11_x10
.global asm_logic_not_x11
.global asm_math_add_x1_x10
.global asm_math_sub_x1_x10
.global asm_math_mul_x1_x10
.global asm_math_div_x1_x10
.global asm_math_mod_x1_x10
.global asm_var_slot_prefix
.global asm_store_data_prefix
.global asm_label_prefix
.global asm_label_suffix
.global asm_pageoff_suffix
.global asm_branch
.global asm_branch_zero
.global asm_branch_nonzero
.global asm_cmp_x11_x10
.global asm_cset_gt
.global asm_cset_lt
.global asm_cset_ge
.global asm_cset_le
.global asm_cset_eq
.global asm_cset_ne
.global asm_load_x11_var
.global asm_load_x10_var
.global asm_store_x11_var
.global asm_add_x11_imm
.global asm_sub_x11_imm
.global asm_call_write
.global asm_call_str_concat
.global asm_call_int_to_cstr
.global asm_call_file_read
.global asm_call_file_write
.global asm_call_read
.global asm_input_prompt_prefix
.global asm_input_buffer_prefix
.global asm_input_prompt_adr
.global asm_input_prompt_pageoff
.global asm_input_buffer_adr
.global asm_input_buffer_pageoff
.global asm_input_write_fd
.global asm_input_read_fd
.global asm_input_len_prefix
.global asm_input_read_size
.global asm_input_strip_prefix
.global asm_input_strip_pageoff
.global asm_input_b_le_store
.global asm_input_b_ne_null
.global asm_input_b_store
.global asm_input_null_label_prefix
.global asm_input_store_label_prefix
.global asm_input_null_body
.global asm_input_store_x10_str
.global asm_input_buffer_space
.global newline_char
.global zero_qword
.global single_char
.global close_brace_char
.global label_counter
.global current_loop_start
.global current_loop_end
.global loop_context_depth
.global buffer
.global number_buffer
.global source_ptr
.global source_len
.global cursor_pos
.global current_line
.global var_count
.global print_count
.global op_count
.global var_name_ptrs
.global var_name_lens
.global var_values
.global var_lengths
.global var_const_flags
.global var_types
.global list_pool_count
.global list_pool_values
.global list_pool_lengths
.global map_pool_count
.global map_pool_keys
.global map_pool_key_lengths
.global map_pool_key_ptrs
.global map_pool_values
.global map_pool_lengths
.global print_values
.global print_lengths
.global print_types
.global op_kinds
.global op_arg0
.global op_arg1
.global op_arg2
.global op_arg3
.global fn_count
.global fn_name_ptrs
.global fn_name_lens
.global fn_body_cursors
.global fn_body_lines
.global fn_param_counts
.global fn_param_types
.global fn_param_lengths
.global fn_param_name_ptrs
.global fn_param_name_lens
.global fn_param_default_flags
.global fn_param_default_values
.global fn_param_default_types
.global fn_param_default_lengths
.global fn_return_types
.global fn_return_decl_lengths
.global fn_return_extra_types
.global fn_return_extra_decl_lengths
.global fn_return_value
.global fn_return_length
.global fn_return_flag
.global fn_return_extra
.global fn_return_extra_type
.global fn_exec_depth
.global var_scope_base
.global max_var_count
.global saved_var_count

msg_usage:         .asciz "usage: ./snc <source.sn>\n"
msg_open_error:    .asciz "error: could not open "
msg_read_error:    .asciz "error: failed to read source input\n"
msg_truncated:     .asciz "warning: source truncated to 65535 bytes\n"
msg_on_line:       .asciz "line "
msg_colon_space:   .asciz ": "
msg_expected_stmt: .asciz "error: expected statement on "
msg_expected_name: .asciz "error: expected variable name on "
msg_expected_expr: .asciz "error: expected expression on "
msg_expected_char: .asciz "error: expected character on "
msg_unknown_stmt:  .asciz "error: unknown statement on "
msg_unknown_var:   .asciz "error: unknown variable on "
msg_duplicate_var: .asciz "error: duplicate variable on "
msg_loop_control:  .asciz "error: loop control outside loop on "
msg_divide_zero:   .asciz "error: division by zero on "
msg_const_assign:  .asciz "error: cannot assign to const on "
msg_expected_type: .asciz "error: expected type on "
msg_expected_list: .asciz "error: expected list on "
msg_expected_map:  .asciz "error: expected map on "
msg_type_mismatch: .asciz "error: type mismatch on "
msg_invalid_decimal: .asciz "error: invalid decimal literal on "
msg_decimal_scale: .asciz "error: decimal scale mismatch on "
msg_unsupported_decimal: .asciz "error: unsupported decimal operation on "
msg_too_many_vars: .asciz "error: too many variables\n"
msg_too_many_prints: .asciz "error: too many print statements\n"
msg_too_many_ops:  .asciz "error: too many operations\n"
msg_too_many_fns:  .asciz "error: too many functions\n"
msg_too_many_params: .asciz "error: too many parameters on "
msg_unknown_fn:    .asciz "error: unknown function on "
msg_wrong_arg_count: .asciz "error: wrong number of arguments on "
msg_expected_arrow: .asciz "error: expected -> on "
msg_missing_return: .asciz "error: missing return in typed function on "
kw_print:          .asciz "print"
kw_let:            .asciz "let"
kw_int:            .asciz "int"
kw_bool:           .asciz "bool"
kw_const:          .asciz "const"
kw_fn:             .asciz "fn"
kw_main:           .asciz "main"
kw_if:             .asciz "if"
kw_else:           .asciz "else"
kw_while:          .asciz "while"
kw_true:           .asciz "true"
kw_false:          .asciz "false"
kw_and:            .asciz "and"
kw_or:             .asciz "or"
kw_not:            .asciz "not"
kw_str:            .asciz "str"
kw_byte:           .asciz "byte"
kw_dec:            .asciz "dec"
kw_cast:           .asciz "cast"
kw_match:          .asciz "match"
kw_default:        .asciz "default"
kw_use:            .asciz "use"
kw_list:           .asciz "list"
kw_map:            .asciz "map"
kw_length:         .asciz "length"
kw_add:            .asciz "add"
kw_for:            .asciz "for"
kw_stop:           .asciz "stop"
kw_skip:           .asciz "skip"
kw_in:             .asciz "in"
kw_input:          .asciz "input"
kw_return:         .asciz "return"
kw_none:           .asciz "none"
kw_otherwise:      .asciz "otherwise"
kw_file_read:      .asciz "file_read"
kw_file_write:     .asciz "file_write"
kw_ref:            .asciz "ref"
kw_address:        .asciz "address"
kw_value:          .asciz "value"
kw_set:            .asciz "set"
kw_alloc:          .asciz "alloc"
kw_free:           .asciz "free"
kw_push:           .asciz "push"
kw_pop:            .asciz "pop"
kw_contains:      .asciz "contains"
kw_has:            .asciz "has"
kw_keys:          .asciz "keys"
kw_values:        .asciz "values"
asm_sub_sp_prefix:
    .asciz "    sub sp, sp, #"
asm_header:
#ifdef _WIN32
    .asciz ".global main\n.align 4\n.extern printf\n.extern read\n.extern write\n.extern malloc\n.extern free\n.extern open\n.extern close\n.extern lseek\n.extern str_concat\n.extern int_to_cstr\n.extern file_read\n.extern file_write\n\n.text\nmain:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n"
#else
    .asciz ".global _main\n.align 4\n.extern _printf\n.extern _read\n.extern _write\n.extern _malloc\n.extern _free\n.extern _open\n.extern _close\n.extern _lseek\n.extern _str_concat\n.extern _int_to_cstr\n.extern _file_read\n.extern _file_write\n\n.text\n_main:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n"
#endif

// Runtime helpers included in emitted programs.
asm_runtime_helpers:
#ifdef _WIN32
    .asciz "\n\n.text\n.align 4\n.global cstring_length\ncstring_length:\n    mov x1, x0\n    mov x0, #0\nL_snl_strlen_loop:\n    ldrb w9, [x1, x0]\n    cbz w9, L_snl_strlen_done\n    add x0, x0, #1\n    b L_snl_strlen_loop\nL_snl_strlen_done:\n    ret\n\n.align 4\n.global str_concat_len\nstr_concat_len:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    mov x22, x3\n\n    add x0, x20, x22\n    add x0, x0, #1\n    bl malloc\n    cbz x0, L_snl_str_concat_len_fail\n    mov x23, x0\n\n    mov x24, #0\nL_snl_str_concat_len_copy1:\n    cmp x24, x20\n    b.ge L_snl_str_concat_len_copy2_start\n    ldrb w9, [x19, x24]\n    strb w9, [x23, x24]\n    add x24, x24, #1\n    b L_snl_str_concat_len_copy1\n\nL_snl_str_concat_len_copy2_start:\n    mov x9, #0\nL_snl_str_concat_len_copy2:\n    cmp x9, x22\n    b.ge L_snl_str_concat_len_done\n    ldrb w10, [x21, x9]\n    add x11, x24, x9\n    strb w10, [x23, x11]\n    add x9, x9, #1\n    b L_snl_str_concat_len_copy2\n\nL_snl_str_concat_len_done:\n    add x11, x24, x22\n    strb wzr, [x23, x11]\n    mov x0, x23\n    b L_snl_str_concat_len_return\n\nL_snl_str_concat_len_fail:\n    mov x0, #0\n\nL_snl_str_concat_len_return:\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global str_concat\nstr_concat:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n\n    mov x0, x19\n    bl cstring_length\n    mov x2, x0\n\n    mov x0, x20\n    bl cstring_length\n    mov x3, x0\n\n    mov x0, x19\n    mov x1, x2\n    mov x2, x20\n    bl str_concat_len\n\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global int_to_cstr\nint_to_cstr:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, #32\n    bl malloc\n    cbz x0, L_snl_int_to_cstr_fail\n    mov x20, x0\n    add x21, x20, #31\n    strb wzr, [x21]\n    sub x21, x21, #1\n\n    mov x22, #0\n    cmp x19, #0\n    b.ge L_snl_int_to_cstr_abs_ready\n    mov x22, #1\n    neg x19, x19\n\nL_snl_int_to_cstr_abs_ready:\n    cbnz x19, L_snl_int_to_cstr_digits\n    mov w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    b L_snl_int_to_cstr_sign\n\nL_snl_int_to_cstr_digits:\n    mov x23, #10\nL_snl_int_to_cstr_loop:\n    udiv x24, x19, x23\n    msub x9, x24, x23, x19\n    add w9, w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    mov x19, x24\n    cbnz x19, L_snl_int_to_cstr_loop\n\nL_snl_int_to_cstr_sign:\n    cbz x22, L_snl_int_to_cstr_done\n    mov w9, #'-'\n    strb w9, [x21]\n    sub x21, x21, #1\n\nL_snl_int_to_cstr_done:\n    add x0, x21, #1\n    b L_snl_int_to_cstr_return\n\nL_snl_int_to_cstr_fail:\n    mov x0, #0\nL_snl_int_to_cstr_return:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global file_read\nfile_read:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, x19\n    mov x1, #0\n    bl open\n    cmp x0, #0\n    b.lt L_snl_file_read_fail\n    mov x20, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #2\n    bl lseek\n    cmp x0, #0\n    b.lt L_snl_file_read_fail_close\n    mov x21, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #0\n    bl lseek\n\n    add x0, x21, #1\n    bl malloc\n    cbz x0, L_snl_file_read_fail_close\n    mov x22, x0\n\n    mov x0, x20\n    mov x1, x22\n    mov x2, x21\n    bl read\n\n    add x9, x22, x21\n    strb wzr, [x9]\n\n    mov x0, x20\n    bl close\n\n    mov x0, x22\n    b L_snl_file_read_return\n\nL_snl_file_read_fail_close:\n    mov x0, x20\n    bl close\nL_snl_file_read_fail:\n    mov x0, #0\nL_snl_file_read_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global file_write\nfile_write:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n\n    mov x0, x19\n    mov x1, #0x601\n    mov x2, #0644\n    bl open\n    cmp x0, #0\n    b.lt L_snl_file_write_fail\n    mov x22, x0\n\n    mov x0, x22\n    mov x1, x20\n    mov x2, x21\n    bl write\n\n    mov x0, x22\n    bl close\n\n    mov x0, #1\n    b L_snl_file_write_return\n\nL_snl_file_write_fail:\n    mov x0, #0\nL_snl_file_write_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
#else
    .asciz "\n\n.text\n.align 4\n.global _cstring_length\n_cstring_length:\n    mov x1, x0\n    mov x0, #0\nL_snl_strlen_loop:\n    ldrb w9, [x1, x0]\n    cbz w9, L_snl_strlen_done\n    add x0, x0, #1\n    b L_snl_strlen_loop\nL_snl_strlen_done:\n    ret\n\n.align 4\n.global _str_concat_len\n_str_concat_len:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n    stp x25, x26, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n    mov x22, x3\n\n    add x0, x20, x22\n    add x0, x0, #1\n    bl _malloc\n    cbz x0, L_snl_str_concat_len_fail\n    mov x23, x0\n\n    mov x24, #0\nL_snl_str_concat_len_copy1:\n    cmp x24, x20\n    b.ge L_snl_str_concat_len_copy2_start\n    ldrb w9, [x19, x24]\n    strb w9, [x23, x24]\n    add x24, x24, #1\n    b L_snl_str_concat_len_copy1\n\nL_snl_str_concat_len_copy2_start:\n    mov x9, #0\nL_snl_str_concat_len_copy2:\n    cmp x9, x22\n    b.ge L_snl_str_concat_len_done\n    ldrb w10, [x21, x9]\n    add x11, x24, x9\n    strb w10, [x23, x11]\n    add x9, x9, #1\n    b L_snl_str_concat_len_copy2\n\nL_snl_str_concat_len_done:\n    add x11, x24, x22\n    strb wzr, [x23, x11]\n    mov x0, x23\n    b L_snl_str_concat_len_return\n\nL_snl_str_concat_len_fail:\n    mov x0, #0\n\nL_snl_str_concat_len_return:\n    ldp x25, x26, [sp], #16\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _str_concat\n_str_concat:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n\n    mov x0, x19\n    bl _cstring_length\n    mov x2, x0\n\n    mov x0, x20\n    bl _cstring_length\n    mov x3, x0\n\n    mov x0, x19\n    mov x1, x2\n    mov x2, x20\n    bl _str_concat_len\n\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _int_to_cstr\n_int_to_cstr:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n    stp x23, x24, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, #32\n    bl _malloc\n    cbz x0, L_snl_int_to_cstr_fail\n    mov x20, x0\n    add x21, x20, #31\n    strb wzr, [x21]\n    sub x21, x21, #1\n\n    mov x22, #0\n    cmp x19, #0\n    b.ge L_snl_int_to_cstr_abs_ready\n    mov x22, #1\n    neg x19, x19\n\nL_snl_int_to_cstr_abs_ready:\n    cbnz x19, L_snl_int_to_cstr_digits\n    mov w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    b L_snl_int_to_cstr_sign\n\nL_snl_int_to_cstr_digits:\n    mov x23, #10\nL_snl_int_to_cstr_loop:\n    udiv x24, x19, x23\n    msub x9, x24, x23, x19\n    add w9, w9, #'0'\n    strb w9, [x21]\n    sub x21, x21, #1\n    mov x19, x24\n    cbnz x19, L_snl_int_to_cstr_loop\n\nL_snl_int_to_cstr_sign:\n    cbz x22, L_snl_int_to_cstr_done\n    mov w9, #'-'\n    strb w9, [x21]\n    sub x21, x21, #1\n\nL_snl_int_to_cstr_done:\n    add x0, x21, #1\n    b L_snl_int_to_cstr_return\n\nL_snl_int_to_cstr_fail:\n    mov x0, #0\nL_snl_int_to_cstr_return:\n    ldp x23, x24, [sp], #16\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _file_read\n_file_read:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x0, x19\n    mov x1, #0\n    bl _open\n    cmp x0, #0\n    b.lt L_snl_file_read_fail\n    mov x20, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #2\n    bl _lseek\n    cmp x0, #0\n    b.lt L_snl_file_read_fail_close\n    mov x21, x0\n\n    mov x0, x20\n    mov x1, #0\n    mov x2, #0\n    bl _lseek\n\n    add x0, x21, #1\n    bl _malloc\n    cbz x0, L_snl_file_read_fail_close\n    mov x22, x0\n\n    mov x0, x20\n    mov x1, x22\n    mov x2, x21\n    bl _read\n\n    add x9, x22, x21\n    strb wzr, [x9]\n\n    mov x0, x20\n    bl _close\n\n    mov x0, x22\n    b L_snl_file_read_return\n\nL_snl_file_read_fail_close:\n    mov x0, x20\n    bl _close\nL_snl_file_read_fail:\n    mov x0, #0\nL_snl_file_read_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n\n.align 4\n.global _file_write\n_file_write:\n    stp x29, x30, [sp, #-16]!\n    mov x29, sp\n    stp x19, x20, [sp, #-16]!\n    stp x21, x22, [sp, #-16]!\n\n    mov x19, x0\n    mov x20, x1\n    mov x21, x2\n\n    mov x0, x19\n    mov x1, #0x601\n    mov x2, #0644\n    bl _open\n    cmp x0, #0\n    b.lt L_snl_file_write_fail\n    mov x22, x0\n\n    mov x0, x22\n    mov x1, x20\n    mov x2, x21\n    bl _write\n\n    mov x0, x22\n    bl _close\n\n    mov x0, #1\n    b L_snl_file_write_return\n\nL_snl_file_write_fail:\n    mov x0, #0\nL_snl_file_write_return:\n    ldp x21, x22, [sp], #16\n    ldp x19, x20, [sp], #16\n    ldp x29, x30, [sp], #16\n    ret\n"
#endif
asm_print_fmt_int_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_int\n    add x0, x0, :lo12:print_fmt_int\n"
#else
    .asciz "    adrp x0, print_fmt_int@PAGE\n    add x0, x0, print_fmt_int@PAGEOFF\n"
#endif
asm_print_fmt_str_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_str\n    add x0, x0, :lo12:print_fmt_str\n"
#else
    .asciz "    adrp x0, print_fmt_str@PAGE\n    add x0, x0, print_fmt_str@PAGEOFF\n"
#endif
asm_print_val_adrp:
    .asciz "    adrp x9, print_val_"
asm_print_val_ldr:
#ifdef _WIN32
    .asciz "\n    ldr x1, [x9, :lo12:print_val_"
#else
    .asciz "@PAGE\n    ldr x1, [x9, print_val_"
#endif
asm_print_str_val_adrp:
    .asciz "    adrp x1, print_val_"
asm_print_str_val_add:
#ifdef _WIN32
    .asciz "\n    add x1, x1, :lo12:print_val_"
#else
    .asciz "@PAGE\n    add x1, x1, print_val_"
#endif
asm_print_call_suffix_stack:
#ifdef _WIN32
    .asciz "]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_call_suffix:
#ifdef _WIN32
    .asciz "]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "@PAGEOFF]\n    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_call_stack:
#ifdef _WIN32
    .asciz "\n    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "@PAGEOFF\n    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_stack_only:
#ifdef _WIN32
    .asciz "    sub sp, sp, #16\n    str x1, [sp]\n    bl printf\n    add sp, sp, #16\n"
#else
    .asciz "    sub sp, sp, #16\n    str x1, [sp]\n    bl _printf\n    add sp, sp, #16\n"
#endif
asm_print_dec_call_stack:
#ifdef _WIN32
    .asciz "    sub sp, sp, #32\n    stp x1, x2, [sp]\n    stp x3, x4, [sp, #16]\n    bl printf\n    add sp, sp, #32\n"
#else
    .asciz "    sub sp, sp, #32\n    stp x1, x2, [sp]\n    stp x3, x4, [sp, #16]\n    bl _printf\n    add sp, sp, #32\n"
#endif
asm_store_val_adrp:
    .asciz "    adrp x9, store_val_"
asm_store_val_ldr:
#ifdef _WIN32
    .asciz "\n    ldr x10, [x9, :lo12:store_val_"
#else
    .asciz "@PAGE\n    ldr x10, [x9, store_val_"
#endif
asm_store_var_adrp:
#ifdef _WIN32
    .asciz "]\n    adrp x11, var_slot_"
#else
    .asciz "@PAGEOFF]\n    adrp x11, var_slot_"
#endif
asm_store_var_str:
#ifdef _WIN32
    .asciz "]\n    stur x10, [x29, #-"
#else
    .asciz "@PAGEOFF]\n    stur x10, [x29, #-"
#endif
asm_store_var_suffix:
#ifdef _WIN32
    .asciz "]\n"
#else
    .asciz "@PAGEOFF]\n"
#endif
asm_close_bracket:
    .asciz "]\n"
asm_mov_x10_x0:
    .asciz "    mov x10, x0\n"
asm_load_x0_print_val_prefix:
#ifdef _WIN32
    .asciz "    adrp x0, print_val_"
#else
    .asciz "    adrp x0, print_val_"
#endif
asm_load_x0_print_val_middle:
#ifdef _WIN32
    .asciz "\n    add x0, x0, :lo12:print_val_"
#else
    .asciz "@PAGE\n    add x0, x0, print_val_"
#endif
asm_load_x0_print_val_suffix:
#ifdef _WIN32
    .asciz "\n"
#else
    .asciz "@PAGEOFF\n"
#endif

asm_load_x1_print_val_prefix:
#ifdef _WIN32
    .asciz "    adrp x1, print_val_"
#else
    .asciz "    adrp x1, print_val_"
#endif
asm_load_x1_print_val_middle:
#ifdef _WIN32
    .asciz "\n    add x1, x1, :lo12:print_val_"
#else
    .asciz "@PAGE\n    add x1, x1, print_val_"
#endif
asm_load_x1_print_val_suffix:
#ifdef _WIN32
    .asciz "\n"
#else
    .asciz "@PAGEOFF\n"
#endif
asm_load_x0_var:
    .asciz "    ldur x0, [x29, #-"
asm_load_x1_var:
    .asciz "    ldur x1, [x29, #-"
asm_store_x0_var:
    .asciz "    stur x0, [x29, #-"
asm_print_var_adrp:
    .asciz "    adrp x9, var_slot_"
asm_print_var_ldr:
    .asciz "    ldur x1, [x29, #-"
asm_print_fmt_dec_adrp:
#ifdef _WIN32
    .asciz "    adrp x0, print_fmt_dec\n    add x0, x0, :lo12:print_fmt_dec\n"
#else
    .asciz "    adrp x0, print_fmt_dec@PAGE\n    add x0, x0, print_fmt_dec@PAGEOFF\n"
#endif
asm_dec_sign_empty_adrp:
#ifdef _WIN32
    .asciz "    adrp x1, dec_sign_empty\n    add x1, x1, :lo12:dec_sign_empty\n"
#else
    .asciz "    adrp x1, dec_sign_empty@PAGE\n    add x1, x1, dec_sign_empty@PAGEOFF\n"
#endif
asm_dec_sign_minus_adrp:
#ifdef _WIN32
    .asciz "    adrp x2, dec_sign_minus\n    add x2, x2, :lo12:dec_sign_minus\n"
#else
    .asciz "    adrp x2, dec_sign_minus@PAGE\n    add x2, x2, dec_sign_minus@PAGEOFF\n"
#endif
asm_mov_x3_imm_prefix:
    .asciz "    mov x3, #"
asm_mov_x12_imm_prefix:
    .asciz "    mov x12, #"
asm_mov_x14_imm_prefix:
    .asciz "    mov x14, #"
asm_dec_abs_x11_to_x13:
    .asciz "    cmp x11, #0\n    cneg x13, x11, lt\n"
asm_dec_select_sign_x1:
    .asciz "    cmp x11, #0\n    csel x1, x2, x1, lt\n"
asm_dec_split_x13_x14:
    .asciz "    udiv x2, x13, x14\n    msub x4, x2, x14, x13\n"
asm_dec_mul_x11_x10_x12:
    .asciz "    mul x11, x11, x10\n    sdiv x11, x11, x12\n"
asm_dec_div_x11_x10_x12:
    .asciz "    mul x11, x11, x12\n    sdiv x11, x11, x10\n"
asm_math_var_x11_adrp:
    .asciz "    adrp x11, var_slot_"
asm_math_var_x11_ldr:
    .asciz "    ldur x11, [x29, #-"
asm_math_var_x1_adrp:
    .asciz "    adrp x11, var_slot_"
asm_math_var_x1_ldr:
    .asciz "    ldur x1, [x29, #-"
asm_math_var_x10_adrp:
    .asciz "    adrp x12, var_slot_"
asm_math_var_x10_ldr:
    .asciz "    ldur x10, [x29, #-"
asm_math_store_x11_adrp:
    .asciz "    adrp x12, var_slot_"
asm_math_store_x11_str:
    .asciz "    stur x11, [x29, #-"
asm_math_add_x11_x10:
    .asciz "    add x11, x11, x10\n"
asm_math_sub_x11_x10:
    .asciz "    sub x11, x11, x10\n"
asm_math_mul_x11_x10:
    .asciz "    mul x11, x11, x10\n"
asm_math_div_x11_x10:
    .asciz "    udiv x11, x11, x10\n"
asm_math_mod_x11_x10:
    .asciz "    udiv x13, x11, x10\n    msub x11, x13, x10, x11\n"
asm_math_add_x1_x10:
    .asciz "    add x1, x1, x10\n"
asm_math_sub_x1_x10:
    .asciz "    sub x1, x1, x10\n"
asm_math_mul_x1_x10:
    .asciz "    mul x1, x1, x10\n"
asm_math_div_x1_x10:
    .asciz "    udiv x1, x1, x10\n"
asm_math_mod_x1_x10:
    .asciz "    udiv x13, x1, x10\n    msub x1, x13, x10, x1\n"
asm_logic_and_x11_x10:
    .asciz "    cmp x11, #0\n    cset x11, ne\n    cmp x10, #0\n    cset x10, ne\n    and x11, x11, x10\n"
asm_logic_or_x11_x10:
    .asciz "    orr x11, x11, x10\n    cmp x11, #0\n    cset x11, ne\n"
asm_logic_not_x11:
    .asciz "    cmp x11, #0\n    cset x11, eq\n"
asm_data_intro:
    .asciz "    mov w0, #0\n    mov sp, x29\n    ldp x29, x30, [sp], #16\n    ret\n\n.data\nprint_fmt_int:\n    .asciz \"%lld\\n\"\nprint_fmt_str:\n    .asciz \"%s\\n\"\nprint_fmt_dec:\n    .asciz \"%s%lld.%0*lld\\n\"\ndec_sign_empty:\n    .asciz \"\"\ndec_sign_minus:\n    .asciz \"-\"\n.align 3\n"
asm_data_value_prefix:
    .asciz "print_val_"
asm_data_value_mid:
    .asciz ":\n    .quad "
asm_data_value_mid_str:
    .asciz ":\n    .asciz \""
asm_data_value_suffix:
    .asciz "\n"
asm_data_value_suffix_str:
    .asciz "\"\n"
asm_align_3:
    .asciz ".align 3\n"
asm_var_slot_prefix:
    .asciz "var_slot_"
asm_store_data_prefix:
    .asciz "store_val_"
asm_label_prefix:
    .asciz "L_snl_"
asm_label_suffix:
    .asciz ":\n"
asm_pageoff_suffix:
    .asciz "@PAGEOFF\n"
asm_branch:
    .asciz "    b L_snl_"
asm_branch_zero:
    .asciz "    cbz x11, L_snl_"
asm_branch_nonzero:
    .asciz "    cbnz x11, L_snl_"
asm_cmp_x11_x10:
    .asciz "    cmp x11, x10\n"
asm_cset_gt:
    .asciz "    cset x11, gt\n"
asm_cset_lt:
    .asciz "    cset x11, lt\n"
asm_cset_ge:
    .asciz "    cset x11, ge\n"
asm_cset_le:
    .asciz "    cset x11, le\n"
asm_cset_eq:
    .asciz "    cset x11, eq\n"
asm_cset_ne:
    .asciz "    cset x11, ne\n"
asm_load_x11_var:
    .asciz "    adrp x11, var_slot_"
asm_load_x10_var:
    .asciz "    adrp x12, var_slot_"
asm_store_x11_var:
    .asciz "    str x11, [x12, var_slot_"
asm_add_x11_imm:
    .asciz "    add x11, x11, #"
asm_sub_x11_imm:
    .asciz "    sub x11, x11, #"
asm_call_write:
#ifdef _WIN32
    .asciz "    bl write\n"
#else
    .asciz "    bl _write\n"
#endif
asm_call_str_concat:
#ifdef _WIN32
    .asciz "    bl str_concat\n"
#else
    .asciz "    bl _str_concat\n"
#endif
asm_call_int_to_cstr:
#ifdef _WIN32
    .asciz "    bl int_to_cstr\n"
#else
    .asciz "    bl _int_to_cstr\n"
#endif
asm_call_file_read:
#ifdef _WIN32
    .asciz "    bl file_read\n"
#else
    .asciz "    bl _file_read\n"
#endif
asm_call_file_write:
#ifdef _WIN32
    .asciz "    bl file_write\n"
#else
    .asciz "    bl _file_write\n"
#endif
asm_call_read:
#ifdef _WIN32
    .asciz "    bl read\n"
#else
    .asciz "    bl _read\n"
#endif
asm_input_prompt_prefix:
    .asciz "input_prompt_"
asm_input_buffer_prefix:
    .asciz "input_buf_"
asm_input_prompt_adr:
    .asciz "    adrp x1, input_prompt_"
asm_input_prompt_pageoff:
    .asciz "@PAGE\n    add x1, x1, input_prompt_"
asm_input_buffer_adr:
    .asciz "    adrp x1, input_buf_"
asm_input_buffer_pageoff:
    .asciz "@PAGE\n    add x1, x1, input_buf_"
asm_input_write_fd:
    .asciz "    mov x0, #1\n"
asm_input_read_fd:
    .asciz "    mov x0, #0\n"
asm_input_len_prefix:
    .asciz "    mov x2, #"
asm_input_read_size:
    .asciz "    mov x2, #255\n"
asm_input_strip_prefix:
    .asciz "    mov x9, x0\n    adrp x10, input_buf_"
asm_input_strip_pageoff:
    .asciz "@PAGE\n    add x10, x10, input_buf_"
asm_input_b_le_store:
    .asciz "    cmp x9, #0\n    b.le L_input_store_"
asm_input_b_ne_null:
    .asciz "    sub x11, x9, #1\n    ldrb w12, [x10, x11]\n    cmp w12, #10\n    b.ne L_input_null_"
asm_input_b_store:
    .asciz "    strb wzr, [x10, x11]\n    b L_input_store_"
asm_input_null_label_prefix:
    .asciz "L_input_null_"
asm_input_store_label_prefix:
    .asciz "L_input_store_"
asm_input_null_body:
    .asciz "    add x11, x10, x9\n    strb wzr, [x11]\n"
asm_input_store_x10_str:
    .asciz "    stur x10, [x29, #-"
asm_input_buffer_space:
    .asciz ":\n    .space 256\n"
newline_char:      .byte 10
zero_qword:        .quad 0
single_char:       .byte 0
close_brace_char:  .byte 125
.align 3
label_counter:     .quad 1

.bss
.align 4
buffer:         .space 65536       // 64KB source input
number_buffer:  .space 32
source_ptr:     .space 8
source_len:     .space 8
cursor_pos:     .space 8
current_line:   .space 8
var_count:      .space 8
print_count:    .space 8
op_count:       .space 8
current_loop_start: .space 8
current_loop_end: .space 8
loop_context_depth: .space 8
var_name_ptrs:  .space 4096        // 512 variables * 8 bytes
var_name_lens:  .space 4096
var_values:     .space 4096
var_lengths:    .space 4096
var_const_flags: .space 4096
var_types:       .space 4096
list_pool_count: .space 8
list_pool_values: .space 32768     // 4096 list elements
list_pool_lengths: .space 32768
map_pool_count:  .space 8
map_pool_keys:   .space 32768
map_pool_key_lengths: .space 32768
map_pool_key_ptrs: .space 32768
map_pool_values: .space 32768
map_pool_lengths: .space 32768
print_values:   .space 16384       // 2048 prints
print_lengths:  .space 16384
print_types:    .space 16384
op_kinds:       .space 32768       // 4096 operations
op_arg0:        .space 32768
op_arg1:        .space 32768
op_arg2:        .space 32768
op_arg3:        .space 32768
fn_count:       .space 8
fn_name_ptrs:   .space 512         // 64 functions * 8 bytes
fn_name_lens:   .space 512
fn_body_cursors: .space 512
fn_body_lines:  .space 512
fn_param_counts: .space 512
fn_return_types: .space 512
fn_param_types: .space 2048        // 64 fns * 4 params * 8 bytes
fn_param_lengths: .space 2048
fn_param_name_ptrs: .space 2048
fn_param_name_lens: .space 2048
fn_param_default_flags: .space 2048
fn_param_default_values: .space 2048
fn_param_default_types: .space 2048
fn_param_default_lengths: .space 2048
fn_return_decl_lengths: .space 512
fn_return_extra_types: .space 512
fn_return_extra_decl_lengths: .space 512
fn_return_value: .space 8
fn_return_length: .space 8
fn_return_flag:  .space 8
fn_return_extra: .space 8
fn_return_extra_type: .space 8
fn_exec_depth:   .space 8
var_scope_base: .space 8
max_var_count:  .space 8
saved_var_count: .space 8

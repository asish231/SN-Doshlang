#include "platform.inc"
 .text
 .align 4
 .global _emit_program

_emit_program:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    LOAD_ADDR x0, asm_header
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x19, max_var_count
    ldr x19, [x19]
    LOAD_ADDR x20, var_count
    ldr x20, [x20]
    cmp x20, x19
    csel x19, x20, x19, hi
    mov x20, #8
    mul x19, x19, x20
    add x19, x19, #15
    and x19, x19, #0xFFFFFFFFFFFFFFF0
    cbz x19, Lemit_no_stack_alloc

    LOAD_ADDR x0, asm_sub_sp_prefix
    mov x1, #1
    bl _write_cstr_fd

    mov x0, x19
    mov x1, #1
    bl _write_i64_fd

    LOAD_ADDR x0, single_char
    mov w9, #'\n'
    strb w9, [x0]
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

Lemit_no_stack_alloc:

    LOAD_ADDR x19, op_count
    ldr x20, [x19]
    mov x21, #0

Lemit_body_loop:
    cmp x21, x20
    b.ge Lemit_body_done
    mov x0, x21
    bl _emit_operation
    add x21, x21, #1
    b Lemit_body_loop

Lemit_body_done:
    LOAD_ADDR x0, asm_data_intro
    mov x1, #1
    bl _write_cstr_fd

    mov x21, #0

Lemit_data_loop:
    LOAD_ADDR x19, print_count
    ldr x20, [x19]
    cmp x21, x20
    b.ge Lemit_store_data_begin
    mov x0, x21
    bl _emit_print_data
    add x21, x21, #1
    b Lemit_data_loop

Lemit_store_data_begin:
    LOAD_ADDR x19, op_count
    LOAD_ADDR x9, op_count
    ldr x20, [x9]
    mov x21, #0
    Lemit_store_data_loop:
    cmp x21, x20
    b.ge Lemit_pools
    mov x0, x21
    bl _emit_store_data
    add x21, x21, #1
    b Lemit_store_data_loop


Lemit_pools:
    // .align 3
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd

    // list_pool_values
    LOAD_ADDR x0, asm_list_pool_values_label
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x9, list_pool_count
    ldr x20, [x9]
    mov x21, #0
Lemit_list_pool_values_loop:
    cmp x21, x20
    b.ge Lemit_list_pool_values_done
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x10, list_pool_values
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_list_pool_values_loop
Lemit_list_pool_values_done:

    // list_pool_lengths
    LOAD_ADDR x0, asm_list_pool_lengths_label
    mov x1, #1
    bl _write_cstr_fd
    mov x21, #0
Lemit_list_pool_lengths_loop:
    cmp x21, x20
    b.ge Lemit_list_pool_lengths_done
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x10, list_pool_lengths
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_list_pool_lengths_loop
Lemit_list_pool_lengths_done:

    // map_pool_keys
    LOAD_ADDR x0, asm_map_pool_keys_label
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x9, map_pool_count
    ldr x20, [x9]
    mov x21, #0
Lemit_map_pool_keys_loop:
    cmp x21, x20
    b.ge Lemit_map_pool_keys_done
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x10, map_pool_keys
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_map_pool_keys_loop
Lemit_map_pool_keys_done:

    // map_pool_key_lengths
    LOAD_ADDR x0, asm_map_pool_key_lengths_label
    mov x1, #1
    bl _write_cstr_fd
    mov x21, #0
Lemit_map_pool_key_lens_loop:
    cmp x21, x20
    b.ge Lemit_map_pool_key_lens_done
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x10, map_pool_key_lengths
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_map_pool_key_lens_loop
Lemit_map_pool_key_lens_done:

    // map_pool_values
    LOAD_ADDR x0, asm_map_pool_values_label
    mov x1, #1
    bl _write_cstr_fd
    mov x21, #0
Lemit_map_pool_values_loop:
    cmp x21, x20
    b.ge Lemit_map_pool_values_done
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x10, map_pool_values
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_map_pool_values_loop
Lemit_map_pool_values_done:

    // map_pool_lengths
    LOAD_ADDR x0, asm_map_pool_lengths_label
    mov x1, #1
    bl _write_cstr_fd
    mov x21, #0
Lemit_map_pool_lens_loop:
    cmp x21, x20
    b.ge Lemit_map_pool_lens_done
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x10, map_pool_lengths
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_map_pool_lens_loop
Lemit_map_pool_lens_done:

Lemit_emit_runtime_helpers:
    LOAD_ADDR x0, asm_runtime_helpers
    mov x1, #1
    bl _write_cstr_fd

Lemit_program_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_operation:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    LOAD_ADDR x20, op_kinds
    ldr x21, [x20, x19, lsl #3]

    cmp x21, #0
    b.eq Lemit_op_print_value
    cmp x21, #1
    b.eq Lemit_op_store_var
    cmp x21, #2
    b.eq Lemit_op_print_var
    cmp x21, #7
    b.le Lemit_op_store_math_imm

    cmp x21, #33
    b.eq Lemit_op_if_start
    cmp x21, #34
    b.eq Lemit_op_if_else
    cmp x21, #35
    b.eq Lemit_op_if_end
    cmp x21, #36
    b.eq Lemit_op_while_start
    cmp x21, #37
    b.eq Lemit_op_while_cond
    cmp x21, #38
    b.eq Lemit_op_while_end
    cmp x21, #39
    b.eq Lemit_op_cmp_imm
    cmp x21, #40
    b.eq Lemit_op_cmp_var
    cmp x21, #41
    b.eq Lemit_op_jump
    cmp x21, #42
    b.eq Lemit_op_logic_and
    cmp x21, #43
    b.eq Lemit_op_logic_or
    cmp x21, #44
    b.eq Lemit_op_logic_not
    cmp x21, #45
    b.eq Lemit_op_store_var_var
    cmp x21, #46
    b.eq Lemit_op_update_label
    cmp x21, #47
    b.eq Lemit_op_input_str
    cmp x21, #48
    b.eq Lemit_op_store_dec_target_imm
    cmp x21, #49
    b.eq Lemit_op_store_dec_target_imm
    cmp x21, #50
    b.eq Lemit_op_store_dec_target_imm
    cmp x21, #51
    b.eq Lemit_op_store_dec_target_imm
    cmp x21, #52
    b.eq Lemit_op_store_dec_target_var
    cmp x21, #53
    b.eq Lemit_op_store_dec_target_var
    cmp x21, #54
    b.eq Lemit_op_store_dec_target_var
    cmp x21, #55
    b.eq Lemit_op_store_dec_target_var
    cmp x21, #56
    b.eq Lemit_op_print_dec_var
    cmp x21, #12
    b.le Lemit_op_print_math_imm
    cmp x21, #17
    b.le Lemit_op_store_math_var
    cmp x21, #22
    b.le Lemit_op_print_math_var
    cmp x21, #27
    b.le Lemit_op_store_math_target_imm
    cmp x21, #32
    b.le Lemit_op_store_math_target_var
    
    cmp x21, #60
    b.eq Lemit_op_str_concat
    cmp x21, #70
    b.eq Lemit_op_file_read
    cmp x21, #71
    b.eq Lemit_op_file_write
    cmp x21, #72
    b.eq Lemit_op_store_str_lit
    cmp x21, #73
    b.eq Lemit_op_cast_int_to_str
    cmp x21, #78
    b.eq Lemit_op_cast_str_to_int
    cmp x21, #80
    b.eq Lemit_op_list_load
    cmp x21, #82
    b.eq Lemit_op_map_load
    cmp x21, #83
    b.eq Lemit_op_address
    cmp x21, #84
    b.eq Lemit_op_deref
    cmp x21, #85
    b.eq Lemit_op_alloc
    cmp x21, #86
    b.eq Lemit_op_free
    cmp x21, #87
    b.eq Lemit_op_set_ptr

    b Lemit_op_done

Lemit_op_address:
    LOAD_ADDR x0, asm_sub_x10_x29_imm
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_input_store_x10_str
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_deref:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg3
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #3
    b.eq Lemit_op_deref_byte
    
    LOAD_ADDR x0, asm_ldr_x10_x11
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_deref_store
    
Lemit_op_deref_byte:
    LOAD_ADDR x0, asm_ldrb_w10_x11
    mov x1, #1
    bl _write_cstr_fd

Lemit_op_deref_store:
    LOAD_ADDR x0, asm_input_store_x10_str
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_alloc:
    LOAD_ADDR x20, op_arg2
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #-1
    b.eq Lemit_op_alloc_imm
    
    LOAD_ADDR x0, asm_load_x0_var
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_alloc_call

Lemit_op_alloc_imm:
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lemit_op_alloc_call:
    LOAD_ADDR x0, asm_call_malloc
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_store_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_free:
    LOAD_ADDR x0, asm_load_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_call_free
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_set_ptr:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg2
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #-1
    b.eq Lemit_op_set_ptr_imm
    
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_set_ptr_store
    
Lemit_op_set_ptr_imm:
    LOAD_ADDR x0, asm_store_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_val_ldr_x10
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_var_suffix
    mov x1, #1
    bl _write_cstr_fd

Lemit_op_set_ptr_store:
    LOAD_ADDR x20, op_arg3
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #3
    b.eq Lemit_op_set_ptr_byte
    
    LOAD_ADDR x0, asm_str_x10_x11
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_set_ptr_byte:
    LOAD_ADDR x0, asm_strb_w10_x11
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_value:
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    bl _emit_print_call
    b Lemit_op_done

Lemit_op_store_var:
    LOAD_ADDR x0, asm_store_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_var_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_var:
    LOAD_ADDR x20, op_arg1
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #2
    b.eq Lemit_op_print_var_str

    LOAD_ADDR x0, asm_print_fmt_int_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_print_var_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_print_call_suffix_stack
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_var_str:
    LOAD_ADDR x0, asm_print_fmt_str_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_print_var_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_print_call_suffix_stack
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_dec_var:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, op_arg1
    ldr x22, [x20, x19, lsl #3]
    mov x0, x22
    bl _pow10_u64
    mov x21, x0

    LOAD_ADDR x0, asm_print_fmt_dec_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_dec_sign_empty_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_dec_sign_minus_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_dec_select_sign_x1
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_dec_abs_x11_to_x13
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_mov_x3_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    LOAD_ADDR x0, asm_mov_x14_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    LOAD_ADDR x0, asm_dec_split_x13_x14
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_print_dec_call_stack
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_input_str:
    LOAD_ADDR x0, asm_input_write_fd
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_input_prompt_adr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_input_prompt_pageoff
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_pageoff_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_input_len_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    LOAD_ADDR x0, asm_call_write
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_input_read_fd
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_input_buffer_adr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_input_buffer_pageoff
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_pageoff_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_input_read_size
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_read
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_input_strip_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_input_strip_pageoff
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_pageoff_suffix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_input_b_le_store
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    LOAD_ADDR x0, asm_input_b_ne_null
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    LOAD_ADDR x0, asm_input_b_store
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    LOAD_ADDR x0, asm_input_null_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_input_null_body
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_input_store_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_input_store_x10_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_math_imm:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_store_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_var_suffix
    mov x1, #1
    bl _write_cstr_fd

    sub x22, x21, #2
    mov x0, x22
    bl _emit_math_opcode_x11

    LOAD_ADDR x0, asm_math_store_x11_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_math_imm:
    LOAD_ADDR x0, asm_print_fmt_int_adrp
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_math_var_x1_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_store_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_var_suffix
    mov x1, #1
    bl _write_cstr_fd

    sub x22, x21, #7
    mov x0, x22
    bl _emit_math_opcode_x1

    LOAD_ADDR x0, asm_print_stack_only
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_math_var:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    sub x22, x21, #12
    mov x0, x22
    bl _emit_math_opcode_x11

    LOAD_ADDR x0, asm_math_store_x11_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_math_var:
    LOAD_ADDR x0, asm_print_fmt_int_adrp
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_math_var_x1_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    sub x22, x21, #17
    mov x0, x22
    bl _emit_math_opcode_x1

    LOAD_ADDR x0, asm_print_stack_only
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_math_target_imm:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_store_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_var_suffix
    mov x1, #1
    bl _write_cstr_fd

    sub x22, x21, #22
    mov x0, x22
    bl _emit_math_opcode_x11

    LOAD_ADDR x0, asm_math_store_x11_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_math_target_var:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    sub x22, x21, #27
    mov x0, x22
    bl _emit_math_opcode_x11

    LOAD_ADDR x0, asm_math_store_x11_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_var_var:
    // load source var (op_arg1) into x10
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    // store x10 into dest var (op_arg0)
    LOAD_ADDR x0, asm_math_store_x11_str // "    stur x11, [x29, #-" -- wait, I need stur x10!
    // I should probably add asm_math_store_x10_str to data.s
    // Or just use asm_input_store_x10_str which is exactly what I need!
    LOAD_ADDR x0, asm_input_store_x10_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_str_lit:
    // Store address of print_val_{id} into dest var slot.
    // op_arg0: dest var idx, op_arg1: print/data id
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_mov_x10_x0
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_input_store_x10_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_dec_target_imm:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_store_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_var_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_store_dec_target_common

Lemit_op_store_dec_target_var:
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

Lemit_op_store_dec_target_common:
    LOAD_ADDR x20, op_arg1
    ldr x22, [x20, x19, lsl #3]
    mov x0, x22
    bl _pow10_u64
    mov x22, x0

    LOAD_ADDR x0, asm_mov_x12_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    cmp x21, #48
    b.eq Lemit_op_store_dec_add
    cmp x21, #52
    b.eq Lemit_op_store_dec_add
    cmp x21, #49
    b.eq Lemit_op_store_dec_sub
    cmp x21, #53
    b.eq Lemit_op_store_dec_sub
    cmp x21, #50
    b.eq Lemit_op_store_dec_mul
    cmp x21, #54
    b.eq Lemit_op_store_dec_mul
    b Lemit_op_store_dec_div

Lemit_op_store_dec_add:
    LOAD_ADDR x0, asm_math_add_x11_x10
    b Lemit_op_store_dec_math_write
Lemit_op_store_dec_sub:
    LOAD_ADDR x0, asm_math_sub_x11_x10
    b Lemit_op_store_dec_math_write
Lemit_op_store_dec_mul:
    LOAD_ADDR x0, asm_dec_mul_x11_x10_x12
    b Lemit_op_store_dec_math_write
Lemit_op_store_dec_div:
    LOAD_ADDR x0, asm_dec_div_x11_x10_x12
Lemit_op_store_dec_math_write:
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_math_store_x11_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_str_concat:
    // arg0: dest, arg1: left, arg2: right, arg3: flags
    LOAD_ADDR x20, op_arg3
    ldr x22, [x20, x19, lsl #3] // flags

    // Load left into x0
    tbz x22, #0, Lemit_str_concat_left_var
    // left is imm (print_id)
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_str_concat_right

Lemit_str_concat_left_var:
    LOAD_ADDR x0, asm_load_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

Lemit_str_concat_right:
    // Load right into x1
    tbz x22, #1, Lemit_str_concat_right_var
    // right is imm (print_id)
    LOAD_ADDR x0, asm_load_x1_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_str_concat_call

Lemit_str_concat_right_var:
    LOAD_ADDR x0, asm_load_x1_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

Lemit_str_concat_call:
    LOAD_ADDR x0, asm_call_str_concat
    mov x1, #1
    bl _write_cstr_fd
    
    // Store x0 into dest
    LOAD_ADDR x0, asm_store_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_file_read:
    // arg0: dest, arg1: path, arg3: flags
    LOAD_ADDR x20, op_arg3
    ldr x22, [x20, x19, lsl #3] // flags

    // Load path into x0
    tbz x22, #0, Lemit_file_read_path_var
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_file_read_call
Lemit_file_read_path_var:
    LOAD_ADDR x0, asm_load_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

Lemit_file_read_call:
    LOAD_ADDR x0, asm_call_file_read
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_store_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_file_write:
    // arg0: success, arg1: path, arg2: data, arg3: flags
    LOAD_ADDR x20, op_arg3
    ldr x22, [x20, x19, lsl #3]

    // Load path into x0
    tbz x22, #0, Lemit_file_write_path_var
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_file_write_data
Lemit_file_write_path_var:
    LOAD_ADDR x0, asm_load_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

Lemit_file_write_data:
    // Load data into x1
    tbz x22, #1, Lemit_file_write_data_var
    LOAD_ADDR x0, asm_load_x1_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_file_write_call
Lemit_file_write_data_var:
    LOAD_ADDR x0, asm_load_x1_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

Lemit_file_write_call:
    LOAD_ADDR x0, asm_call_file_write
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_store_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_cast_int_to_str:
    LOAD_ADDR x0, asm_load_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_call_int_to_cstr
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_store_x0_var
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_list_load:
    // arg0: dest, arg1: index_var, arg2: base_idx, arg3: load_len
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_add_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_load_list_pool_x11
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_load_pool_val_x10
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_input_store_x10_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_cast_str_to_int:
    // arg0: dest, arg1: source_var
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_mov_x0_x10
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_call_cstr_to_int
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_input_store_x0_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_map_load:
    // arg0: dest, arg1: key_var, arg2: base_idx, arg3: packed
    // packed: (key_type << 56) | (val_type << 48) | count
    
    // 1. Load key value from stack into x10
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    // mov x2, x10
    LOAD_ADDR x0, asm_mov_x2_x10
    mov x1, #1
    bl _write_cstr_fd
    
    // Unpack arg3
    LOAD_ADDR x20, op_arg3
    ldr x22, [x20, x19, lsl #3]
    and x23, x22, #0xFFFFFFFF // count
    lsr x24, x22, #56 // key type
    
    // 2. If key_type is 2 (str), get length into x4
    cmp x24, #2
    b.ne Lemit_map_load_no_str_len
    
    LOAD_ADDR x0, asm_mov_x0_x10
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_cstring_length
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_mov_x4_x0
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_load_ready

Lemit_map_load_no_str_len:
    LOAD_ADDR x0, asm_mov_x4_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, #0
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lemit_map_load_ready:
    // 3. Set up x0 (base_idx), x1 (count), x3 (key_type)
    LOAD_ADDR x0, asm_mov_x0_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_mov_x1_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x23
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_mov_x3_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x24
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    
    // 4. Call _map_lookup
    LOAD_ADDR x0, asm_call_map_lookup
    mov x1, #1
    bl _write_cstr_fd
    
    // 5. Store result x0 into dest variable slot
    LOAD_ADDR x0, asm_input_store_x0_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_math_opcode_x11:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    cmp x19, #1
    b.eq Lemit_math_x11_add
    cmp x19, #2
    b.eq Lemit_math_x11_sub
    cmp x19, #3
    b.eq Lemit_math_x11_mul
    cmp x19, #4
    b.eq Lemit_math_x11_div
    LOAD_ADDR x0, asm_math_mod_x11_x10
    b Lemit_math_x11_write
Lemit_math_x11_add:
    LOAD_ADDR x0, asm_math_add_x11_x10
    b Lemit_math_x11_write
Lemit_math_x11_sub:
    LOAD_ADDR x0, asm_math_sub_x11_x10
    b Lemit_math_x11_write
Lemit_math_x11_mul:
    LOAD_ADDR x0, asm_math_mul_x11_x10
    b Lemit_math_x11_write
Lemit_math_x11_div:
    LOAD_ADDR x0, asm_math_div_x11_x10
Lemit_math_x11_write:
    mov x1, #1
    bl _write_cstr_fd
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lemit_op_if_start:
    // load var into x11
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    // cbz x11, L_snl_ELSE
    LOAD_ADDR x0, asm_branch_zero
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    b Lemit_op_done

Lemit_op_if_else:
    // branch to END (op_arg1)
    LOAD_ADDR x0, asm_branch
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    // place ELSE label (op_arg0)
    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_if_end:
    // place END label (op_arg0)
    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_while_start:
    // place START label (op_arg0)
    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_while_cond:
    // load var into x11
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    // cbz x11, L_snl_END
    LOAD_ADDR x0, asm_branch_zero
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    b Lemit_op_done

Lemit_op_while_end:
    // branch to START (op_arg0)
    LOAD_ADDR x0, asm_branch
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    // place END label (op_arg1)
    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_jump:
    // unconditional jump to label in op_arg0
    LOAD_ADDR x0, asm_branch
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    b Lemit_op_done

Lemit_op_logic_and:
    // load LHS (op_arg0) into x11
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    // load RHS (op_arg1) into x10
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_logic_and_x11_x10
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_logic_store

Lemit_op_logic_or:
    // load LHS (op_arg0) into x11
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    // load RHS (op_arg1) into x10
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_logic_or_x11_x10
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_logic_store

Lemit_op_logic_not:
    // load LHS (op_arg0) into x11
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_logic_not_x11
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_logic_store

Lemit_op_update_label:
    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_logic_store:
    LOAD_ADDR x0, asm_math_store_x11_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg2
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_cmp_imm:
    // load left var into x11
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    // load right imm from store_val
    LOAD_ADDR x0, asm_store_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_store_var_suffix
    mov x1, #1
    bl _write_cstr_fd

    b Lemit_cmp_shared

Lemit_op_cmp_var:
    // load left var into x11
    LOAD_ADDR x0, asm_math_var_x11_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg0
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    // load right var into x10
    LOAD_ADDR x0, asm_math_var_x10_ldr
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd

Lemit_cmp_shared:
    // emit `cmp x11, x10`
    LOAD_ADDR x0, asm_cmp_x11_x10
    mov x1, #1
    bl _write_cstr_fd
    
    // emit cset depending on op_arg2
    LOAD_ADDR x20, op_arg2
    ldr x22, [x20, x19, lsl #3]
    
    cmp x22, #0
    b.eq Lemit_cmp_eq
    cmp x22, #1
    b.eq Lemit_cmp_ne
    cmp x22, #2
    b.eq Lemit_cmp_gt
    cmp x22, #3
    b.eq Lemit_cmp_lt
    cmp x22, #4
    b.eq Lemit_cmp_ge
    cmp x22, #5
    b.eq Lemit_cmp_le
    b Lemit_cmp_write_cset

Lemit_cmp_eq:
    LOAD_ADDR x0, asm_cset_eq
    b Lemit_cmp_write_cset
Lemit_cmp_ne:
    LOAD_ADDR x0, asm_cset_ne
    b Lemit_cmp_write_cset
Lemit_cmp_gt:
    LOAD_ADDR x0, asm_cset_gt
    b Lemit_cmp_write_cset
Lemit_cmp_lt:
    LOAD_ADDR x0, asm_cset_lt
    b Lemit_cmp_write_cset
Lemit_cmp_ge:
    LOAD_ADDR x0, asm_cset_ge
    b Lemit_cmp_write_cset
Lemit_cmp_le:
    LOAD_ADDR x0, asm_cset_le

Lemit_cmp_write_cset:
    mov x1, #1
    bl _write_cstr_fd
    
    // emit `stur x11, [x29, #-dest]`
    LOAD_ADDR x0, asm_math_store_x11_str
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, op_arg3
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done



_emit_math_opcode_x1:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    cmp x19, #1
    b.eq Lemit_math_x1_add
    cmp x19, #2
    b.eq Lemit_math_x1_sub
    cmp x19, #3
    b.eq Lemit_math_x1_mul
    cmp x19, #4
    b.eq Lemit_math_x1_div
    LOAD_ADDR x0, asm_math_mod_x1_x10
    b Lemit_math_x1_write
Lemit_math_x1_add:
    LOAD_ADDR x0, asm_math_add_x1_x10
    b Lemit_math_x1_write
Lemit_math_x1_sub:
    LOAD_ADDR x0, asm_math_sub_x1_x10
    b Lemit_math_x1_write
Lemit_math_x1_mul:
    LOAD_ADDR x0, asm_math_mul_x1_x10
    b Lemit_math_x1_write
Lemit_math_x1_div:
    LOAD_ADDR x0, asm_math_div_x1_x10
Lemit_math_x1_write:
    mov x1, #1
    bl _write_cstr_fd
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_print_call:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    LOAD_ADDR x20, print_types
    ldr x21, [x20, x19, lsl #3]

    // Check print_noline from array
    LOAD_ADDR x22, print_noline
    ldrb w22, [x22, x19]
    cmp w22, #1
    b.ne Lemit_print_normal

    // No-newline path
    cmp x21, #2
    b.eq Lemit_print_noline_str
    cmp x21, #6
    b.eq Lemit_print_noline_str

    // noline int - set up format string then call
    LOAD_ADDR x0, asm_print_fmt_int_noline_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_print_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_call_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_print_call_done

Lemit_print_noline_str:
    LOAD_ADDR x0, asm_print_fmt_str_noline_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_print_str_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_str_val_add
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_noline_call_stack
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_print_call_done

Lemit_print_normal:
    cmp x21, #2 // type 2 is string
    b.eq Lemit_print_str_fmt
    cmp x21, #6 // decimal prints via generated string data
    b.eq Lemit_print_str_fmt

    LOAD_ADDR x0, asm_print_fmt_int_adrp
    b Lemit_print_fmt_done

Lemit_print_str_fmt:
    LOAD_ADDR x0, asm_print_fmt_str_adrp
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_print_str_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_str_val_add
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_call_stack
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_print_call_done

Lemit_print_fmt_done:
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_print_val_adrp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_val_ldr
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_print_call_suffix
    mov x1, #1
    bl _write_cstr_fd

Lemit_print_call_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_print_data:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0 // print id
    LOAD_ADDR x20, print_types
    ldr x23, [x20, x19, lsl #3] // type

    LOAD_ADDR x20, print_values
    ldr x21, [x20, x19, lsl #3] // value (ptr for str)

    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_data_value_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd

    cmp x23, #2 // string
    b.eq Lemit_data_str
    cmp x23, #6 // decimal rendered as string literal
    b.eq Lemit_data_dec

    LOAD_ADDR x0, asm_data_value_mid
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_data_done

Lemit_data_str:
    LOAD_ADDR x0, asm_data_value_mid_str
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, print_lengths
    ldr x22, [x20, x19, lsl #3] // length

    mov x0, x21
    mov x1, x22
    mov x2, #1
    bl _write_buffer_fd

    LOAD_ADDR x0, asm_data_value_suffix_str
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_data_done

Lemit_data_dec:
    LOAD_ADDR x0, asm_data_value_mid_str
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, print_lengths
    ldr x22, [x20, x19, lsl #3] // scale

    mov x0, x21
    mov x1, x22
    mov x2, #1
    bl _write_decimal_raw_fd

    LOAD_ADDR x0, asm_data_value_suffix_str
    mov x1, #1
    bl _write_cstr_fd

Lemit_data_done:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_var_slot_data:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x20, #512
    mov x21, #0

Lemit_var_slot_loop:
    cmp x21, x20
    b.ge Lemit_var_slot_done
    LOAD_ADDR x19, var_types
    ldr x22, [x19, x21, lsl #3]
    cmp x22, #2
    b.eq Lemit_var_slot_next
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_var_slot_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_mid
    mov x1, #1
    bl _write_cstr_fd
    mov x0, #0
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_suffix
    mov x1, #1
    bl _write_cstr_fd

Lemit_var_slot_next:
    add x21, x21, #1
    b Lemit_var_slot_loop

Lemit_var_slot_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_store_data:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    LOAD_ADDR x20, op_kinds
    ldr x21, [x20, x19, lsl #3]
    cmp x21, #1
    b.eq Lemit_store_data_emit
    cmp x21, #3
    b.lt Lemit_store_data_done

    // skip runtime branch/control ops — they don't need store_val data
    // except op 39 (cmp_imm) which needs a store_val for the right-hand immediate
    cmp x21, #39
    b.eq Lemit_store_data_cmp_imm
    cmp x21, #47
    b.eq Lemit_store_data_input
    cmp x21, #33
    b.ge Lemit_store_data_check_high
    b Lemit_store_data_check_math

Lemit_store_data_check_high:
    cmp x21, #41
    b.le Lemit_store_data_done
    cmp x21, #87
    b.eq Lemit_store_data_cmp_imm
    cmp x21, #48
    b.lt Lemit_store_data_done
    cmp x21, #51
    b.gt Lemit_store_data_done
    b Lemit_store_data_cmp_imm

Lemit_store_data_check_math:
    cmp x21, #12
    b.le Lemit_store_data_emit
    cmp x21, #23
    b.lt Lemit_store_data_done
    cmp x21, #27
    b.gt Lemit_store_data_done

Lemit_store_data_cmp_imm:
    // emit store_val_{op_index} for ops that need an embedded immediate.
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_store_data_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_mid
    mov x1, #1
    bl _write_cstr_fd
    cmp x21, #87
    b.eq Lemit_store_data_cmp_imm_arg1
    cmp x21, #39
    b.eq Lemit_store_data_cmp_imm_arg1
    cmp x21, #23
    b.lt Lemit_store_data_cmp_imm_arg1
    cmp x21, #27
    b.le Lemit_store_data_cmp_imm_arg3
    cmp x21, #48
    b.lt Lemit_store_data_cmp_imm_arg1
    cmp x21, #51
    b.gt Lemit_store_data_cmp_imm_arg1
Lemit_store_data_cmp_imm_arg3:
    LOAD_ADDR x20, op_arg3
    b Lemit_store_data_cmp_imm_load
Lemit_store_data_cmp_imm_arg1:
    LOAD_ADDR x20, op_arg1
Lemit_store_data_cmp_imm_load:
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_store_data_done

Lemit_store_data_input:
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_input_prompt_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_mid_str
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, op_arg1
    ldr x0, [x20, x19, lsl #3]
    LOAD_ADDR x20, op_arg2
    ldr x1, [x20, x19, lsl #3]
    mov x2, #1
    bl _write_buffer_fd
    LOAD_ADDR x0, asm_data_value_suffix_str
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_input_buffer_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_input_buffer_space
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_store_data_done

Lemit_store_data_emit:
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_store_data_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_mid
    mov x1, #1
    bl _write_cstr_fd

    cmp x21, #39
    b.eq Lemit_store_data_arg1
    cmp x21, #23
    b.lt Lemit_store_data_arg1
    cmp x21, #27
    b.gt Lemit_store_data_arg1
    LOAD_ADDR x20, op_arg3
    b Lemit_store_data_load
Lemit_store_data_arg1:
    LOAD_ADDR x20, op_arg1
Lemit_store_data_load:
    ldr x0, [x20, x19, lsl #3]
Lemit_store_data_write:
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_data_value_suffix
    mov x1, #1
    bl _write_cstr_fd

Lemit_store_data_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_write_stack_offset_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    add x0, x0, #1
    mov x2, #8
    mul x0, x0, x2
    bl _write_u64_fd
    ldp x29, x30, [sp], #16
    ret

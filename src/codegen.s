#include "platform.inc"
 .text
 .align 4
 .global _emit_program

_emit_point_emit_tables_main:
    // op_kinds/op_arg* are now POINTERS to malloc-backed buffers (growable op
    // tables); load the buffer address (the pointer's value) into emit_tbl_*.
    LOAD_ADDR x0, op_kinds
    ldr x0, [x0]
    LOAD_ADDR x1, emit_tbl_kinds
    str x0, [x1]
    LOAD_ADDR x0, op_arg0
    ldr x0, [x0]
    LOAD_ADDR x1, emit_tbl_arg0
    str x0, [x1]
    LOAD_ADDR x0, op_arg1
    ldr x0, [x0]
    LOAD_ADDR x1, emit_tbl_arg1
    str x0, [x1]
    LOAD_ADDR x0, op_arg2
    ldr x0, [x0]
    LOAD_ADDR x1, emit_tbl_arg2
    str x0, [x1]
    LOAD_ADDR x0, op_arg3
    ldr x0, [x0]
    LOAD_ADDR x1, emit_tbl_arg3
    str x0, [x1]
    LOAD_ADDR x0, op_arg4
    ldr x0, [x0]
    LOAD_ADDR x1, emit_tbl_arg4
    str x0, [x1]
    ret

_emit_point_emit_tables_spawn:
    LOAD_ADDR x0, spawn_fn_op_kinds
    LOAD_ADDR x1, emit_tbl_kinds
    str x0, [x1]
    LOAD_ADDR x0, spawn_fn_op_arg0
    LOAD_ADDR x1, emit_tbl_arg0
    str x0, [x1]
    LOAD_ADDR x0, spawn_fn_op_arg1
    LOAD_ADDR x1, emit_tbl_arg1
    str x0, [x1]
    LOAD_ADDR x0, spawn_fn_op_arg2
    LOAD_ADDR x1, emit_tbl_arg2
    str x0, [x1]
    LOAD_ADDR x0, spawn_fn_op_arg3
    LOAD_ADDR x1, emit_tbl_arg3
    str x0, [x1]
    LOAD_ADDR x0, spawn_fn_op_arg4
    LOAD_ADDR x1, emit_tbl_arg4
    str x0, [x1]
    ret

_emit_program:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    LOAD_ADDR x0, asm_header
    mov x1, #1
    bl _write_cstr_fd

    bl _emit_point_emit_tables_main

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

    mov x0, x19
    bl _emit_stack_alloc

Lemit_no_stack_alloc:

    // Emit top-level ops (main)
    bl _emit_main_body

    // Close out _main's own frame right here, BEFORE any user function
    // labels/bodies are emitted below. Previously this epilogue was only
    // emitted once, after ALL user functions (Lemit_user_fns_done), which
    // meant _main's body fell straight through into the first user
    // function's label/prologue/body with no `ret` in between -- so any
    // call out of main (even a no-arg call that returns normally) would
    // execute main's body, then keep falling through into unrelated
    // function code instead of returning to the OS. That was the real
    // cause of "a no-arg function call hangs at runtime".
    LOAD_ADDR x0, asm_main_epilogue
    mov x1, #1
    bl _write_cstr_fd

    // Now emit all user-defined functions
    LOAD_ADDR x19, fn_count
    ldr x20, [x19]
    mov x21, #0
Lemit_user_fns_loop:
    cmp x21, x20
    b.ge Lemit_user_fns_done
    
    // Skip "main" - we already emitted it as the entry point
    LOAD_TBL x9, fn_name_ptrs
    ldr x0, [x9, x21, lsl #3]
    LOAD_TBL x9, fn_name_lens
    ldr x1, [x9, x21, lsl #3]
    LOAD_ADDR x2, kw_main
    bl _match_cstr_span
    cbnz x0, Lemit_user_fns_next

    // Emit this function
    mov x0, x21
    bl _emit_user_function

Lemit_user_fns_next:
    add x21, x21, #1
    b Lemit_user_fns_loop

Lemit_user_fns_done:
    // asm_main_epilogue is now emitted right after _emit_main_body above
    // (before any user function is written), so _main's own frame closes
    // before other function labels/code appear.
#ifndef _WIN32
    bl Lemit_spawn_worker_functions
#endif
    bl Lemit_emit_runtime_helpers
    LOAD_ADDR x0, asm_dot_data_intro
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
    b.ge Lemit_main_store_done
    mov x0, x21
    bl _emit_store_data
    add x21, x21, #1
    b Lemit_store_data_loop

Lemit_main_store_done:
#ifndef _WIN32
    bl _emit_point_emit_tables_main
    LOAD_ADDR x19, fn_count
    ldr x19, [x19]
    mov x21, #0
Lemit_spawn_store_outer:
    cmp x21, x19
    b.ge Lemit_spawn_store_done_u
    LOAD_ADDR x9, spawn_fn_op_counts
    ldr x22, [x9, x21, lsl #3]
    cbz x22, Lemit_spawn_store_fn_next_u
    bl _emit_point_emit_tables_spawn
    mov x23, #0
Lemit_spawn_store_inner_u:
    cmp x23, x22
    b.ge Lemit_spawn_store_inner_done_u
    mov x24, #256
    mul x24, x21, x24
    add x0, x24, x23
    bl _emit_store_data
    add x23, x23, #1
    b Lemit_spawn_store_inner_u
Lemit_spawn_store_inner_done_u:
    bl _emit_point_emit_tables_main
Lemit_spawn_store_fn_next_u:
    add x21, x21, #1
    b Lemit_spawn_store_outer
Lemit_spawn_store_done_u:
#endif

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
    LOAD_TBL x10, list_pool_values
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
    LOAD_TBL x10, list_pool_lengths
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_list_pool_lengths_loop
Lemit_list_pool_lengths_done:

    // list_base_counts (per-base element count for runtime .length())
    LOAD_ADDR x0, asm_list_base_counts_label
    mov x1, #1
    bl _write_cstr_fd
    mov x21, #0
Lemit_list_base_counts_loop:
    cmp x21, x20
    b.ge Lemit_list_base_counts_done
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_TBL x10, list_base_counts
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_list_base_counts_loop
Lemit_list_base_counts_done:

    // map_pool_keys
    // First pass: emit .asciz labels for string keys
    LOAD_ADDR x9, map_pool_count
    ldr x20, [x9]
    mov x21, #0
Lemit_map_key_strs_loop:
    cmp x21, x20
    b.ge Lemit_map_key_strs_done
    LOAD_TBL x10, map_pool_key_lengths
    ldr x22, [x10, x21, lsl #3]
    cbz x22, Lemit_map_key_strs_next  // int key, skip
    // emit: .align 3\nmap_key_N:\n    .asciz "..."\n
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_map_key_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_map_key_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_TBL x10, map_pool_keys
    ldr x0, [x10, x21, lsl #3]
    mov x1, x22
    mov x2, #1
    bl _write_buffer_fd
    LOAD_ADDR x0, asm_data_value_suffix_str
    mov x1, #1
    bl _write_cstr_fd
Lemit_map_key_strs_next:
    add x21, x21, #1
    b Lemit_map_key_strs_loop
Lemit_map_key_strs_done:
    // Ensure subsequent .quad table is 8-byte aligned even after odd-length
    // string-key .asciz payloads.
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_map_pool_keys_label
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x9, map_pool_count
    ldr x20, [x9]
    mov x21, #0
Lemit_map_pool_keys_loop:
    cmp x21, x20
    b.ge Lemit_map_pool_keys_done
    LOAD_TBL x10, map_pool_key_lengths
    ldr x22, [x10, x21, lsl #3]
    cbz x22, Lemit_map_pool_keys_int  // int key: emit raw value
    // string key: emit .quad map_key_N
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_map_key_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_pool_keys_next
Lemit_map_pool_keys_int:
    LOAD_ADDR x0, asm_quad_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_TBL x10, map_pool_keys
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
Lemit_map_pool_keys_next:
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
    LOAD_TBL x10, map_pool_key_lengths
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
    LOAD_TBL x10, map_pool_values
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
    LOAD_TBL x10, map_pool_lengths
    ldr x0, [x10, x21, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    add x21, x21, #1
    b Lemit_map_pool_lens_loop
Lemit_map_pool_lens_done:
    // Emit error handling variables
    LOAD_ADDR x0, asm_align_3
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_error_flag_label
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_quad_0
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_error_value_label
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_quad_0
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_program_done

#ifndef _WIN32
Lemit_maybe_spawn_thread_runtime:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    LOAD_ADDR x19, fn_count
    ldr x19, [x19]
    mov x21, #0
    mov x22, #0
Lemit_mstr_scan:
    cmp x21, x19
    b.ge Lemit_mstr_have
    LOAD_ADDR x9, spawn_fn_op_counts
    ldr x23, [x9, x21, lsl #3]
    cbz x23, Lemit_mstr_next_fn
    mov x22, #1
    b Lemit_mstr_have
Lemit_mstr_next_fn:
    add x21, x21, #1
    b Lemit_mstr_scan
Lemit_mstr_have:
    cbz x22, Lemit_mstr_done
    LOAD_ADDR x0, asm_spawn_thread_runtime
    mov x1, #1
    bl _write_cstr_fd
Lemit_mstr_done:
    ldp x29, x30, [sp], #16
    ret

// Emit the _snc_spawn_wait routine + its shared thread-id table (defined in
// asm_spawn_wait_runtime) when EITHER wait() is used OR the program contains
// any spawn -- spawn's _snc_spawn_go records tids into that same table, and
// _snc_spawn_wait joins them. Kept as its own emitted block so a program that
// only calls wait() (no spawn) still links.
Lemit_maybe_spawn_wait_runtime:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    LOAD_ADDR x9, spawn_wait_used
    ldr x9, [x9]
    cbnz x9, Lemit_mswr_emit
    LOAD_ADDR x19, fn_count
    ldr x19, [x19]
    mov x21, #0
Lemit_mswr_scan:
    cmp x21, x19
    b.ge Lemit_mswr_done
    LOAD_ADDR x9, spawn_fn_op_counts
    ldr x23, [x9, x21, lsl #3]
    cbnz x23, Lemit_mswr_emit
    add x21, x21, #1
    b Lemit_mswr_scan
Lemit_mswr_emit:
    LOAD_ADDR x0, asm_spawn_wait_runtime
    mov x1, #1
    bl _write_cstr_fd
Lemit_mswr_done:
    ldp x29, x30, [sp], #16
    ret

Lemit_spawn_worker_functions:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    LOAD_ADDR x19, fn_count
    ldr x19, [x19]
    mov x21, #0
    mov x28, #0
Lssp_any_scan_loop:
    LOAD_ADDR x19, fn_count
    ldr x19, [x19]
    add x19, x19, #1
    cmp x21, x19
    b.ge Lssp_any_scan_done
    LOAD_ADDR x9, spawn_fn_op_counts
    ldr x23, [x9, x21, lsl #3]
    cbz x23, Lssp_any_scan_next
    mov x28, #1
    b Lssp_any_scan_done
Lssp_any_scan_next:
    add x21, x21, #1
    b Lssp_any_scan_loop
Lssp_any_scan_done:
    cbz x28, Lemit_spawn_worker_functions_exit

    LOAD_ADDR x0, asm_spawn_dispatch_head
    mov x1, #1
    bl _write_cstr_fd

    mov x21, #0
Lssp_dispatch_outer:
    LOAD_ADDR x19, fn_count
    ldr x19, [x19]
    add x19, x19, #1
    cmp x21, x19
    b.ge Lssp_dispatch_emit_done
    LOAD_ADDR x9, spawn_fn_op_counts
    ldr x23, [x9, x21, lsl #3]
    cbz x23, Lssp_dispatch_outer_next

    LOAD_ADDR x0, asm_spawn_dispatch_cmp
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_spawn_dispatch_beq
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lssp_dispatch_outer_next:
    add x21, x21, #1
    b Lssp_dispatch_outer

Lssp_dispatch_emit_done:
    LOAD_ADDR x0, asm_spawn_dispatch_ret
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x25, max_var_count
    ldr x25, [x25]
    LOAD_ADDR x26, var_count
    ldr x26, [x26]
    cmp x26, x25
    csel x25, x26, x25, hi
    mov x26, #8
    mul x25, x25, x26
    add x25, x25, #15
    and x25, x25, #0xFFFFFFFFFFFFFFF0

    mov x21, #0
Lssp_thr_outer:
    LOAD_ADDR x19, fn_count
    ldr x19, [x19]
    add x19, x19, #1 // check up to index 63 if needed
    cmp x21, x19
    b.ge Lemit_spawn_worker_functions_exit
    LOAD_ADDR x9, spawn_fn_op_counts
    ldr x23, [x9, x21, lsl #3]
    cbz x23, Lssp_thr_outer_next

    LOAD_ADDR x0, current_table_id
    add x1, x21, #1
    str x1, [x0]

    LOAD_ADDR x0, asm_spawn_thr_glob
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_spawn_thr_label_mid
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_spawn_thr_enter
    mov x1, #1
    bl _write_cstr_fd
    cbz x25, Lssp_thr_stack_skip
    mov x0, x25
    bl _emit_stack_alloc
Lssp_thr_stack_skip:
    bl _emit_point_emit_tables_spawn
    mov x24, #0
Lssp_thr_emit_ops:
    cmp x24, x23
    b.ge Lssp_thr_emit_done
    mov x11, #256
    mul x11, x21, x11
    add x0, x11, x24
    bl _emit_operation
    add x24, x24, #1
    b Lssp_thr_emit_ops
Lssp_thr_emit_done:
    bl _emit_point_emit_tables_main
    LOAD_ADDR x0, asm_spawn_thr_leave
    mov x1, #1
    bl _write_cstr_fd

Lssp_thr_outer_next:
    add x21, x21, #1
    b Lssp_thr_outer

Lemit_spawn_worker_functions_exit:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
#endif

Lemit_emit_runtime_helpers:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    LOAD_ADDR x0, asm_runtime_helpers
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_map_dynamic_runtime
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_string_slice_runtime
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_string_methods_runtime
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_string_char_at_runtime
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_string_replace_runtime
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_string_split_runtime
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_string_scan_runtime
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_string_trim_runtime
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x9, channel_count
    ldr x9, [x9]
    cbz x9, Lemit_channel_runtime_done
    LOAD_ADDR x0, asm_channel_runtime
    mov x1, #1
    bl _write_cstr_fd
Lemit_channel_runtime_done:
#ifndef _WIN32
    bl Lemit_maybe_spawn_thread_runtime
    bl Lemit_maybe_spawn_wait_runtime
#endif
    ldp x29, x30, [sp], #16
    ret

Lemit_program_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_label_name:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    mov x19, x0 // index

    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, current_table_id
    ldr x0, [x0]
    mov x1, #1
    bl _write_u64_fd

    LOAD_ADDR x0, single_char
    mov w9, #'_'
    strb w9, [x0]
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    mov x0, x19
    mov x1, #1
    bl _write_u64_fd

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// Emit a stack-frame allocation of x0 bytes as:
//     mov x16, #<size>
//     sub sp, sp, x16
// The register form encodes any size 0..65535, whereas `sub sp, sp, #imm`
// only accepts 0..4095 (or a <<12 multiple) -- a large frame (many locals)
// otherwise emitted an unassemblable `sub sp, sp, #16000`. x16 (IP0) is a
// call-clobbered scratch reg, free to use in a prologue before the body runs.
_emit_stack_alloc:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    mov x19, x0
    // Frames >= 65536 bytes cannot use a single `mov x16, #imm` (16-bit imm);
    // materialize the size with movz/movk. Reachable now the var table grows.
    cmp x19, #0x10000
    b.ge Lstackalloc_big
    LOAD_ADDR x0, asm_mov_x16_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_i64_fd
    b Lstackalloc_sub
Lstackalloc_big:
    mov x0, x19
    mov x1, #0                 // reg selector 0 => x16
    bl _emit_movzk_reg
Lstackalloc_sub:
    LOAD_ADDR x0, asm_sp_sub_x16
    mov x1, #1
    bl _write_cstr_fd
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// x0 = value (0..2^32-1), x1 = reg selector (0 => x16, 1 => x28). Emits
//     movz <reg>, #<value & 0xffff>
//     movk <reg>, #<(value>>16) & 0xffff>, lsl #16
// with no trailing newline (the caller appends its own suffix). Used to
// materialize frame sizes / stack-slot offsets that exceed the 16-bit
// immediate range of `mov` (now reachable because the var table grows).
_emit_movzk_reg:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    mov x19, x0                // value
    mov x20, x1                // reg selector (0=x16, 1=x28)
    cbz x20, Lmovzk_movz_x16
    LOAD_ADDR x0, asm_movz_x28
    b Lmovzk_movz_w
Lmovzk_movz_x16:
    LOAD_ADDR x0, asm_movz_x16
Lmovzk_movz_w:
    mov x1, #1
    bl _write_cstr_fd
    and x0, x19, #0xffff
    mov x1, #1
    bl _write_u64_fd
    cbz x20, Lmovzk_movk_x16
    LOAD_ADDR x0, asm_movk_x28
    b Lmovzk_movk_w
Lmovzk_movk_x16:
    LOAD_ADDR x0, asm_movk_x16
Lmovzk_movk_w:
    mov x1, #1
    bl _write_cstr_fd
    lsr x0, x19, #16
    and x0, x0, #0xffff
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_lsl16
    mov x1, #1
    bl _write_cstr_fd
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_stack_load_reg_fd:
    // x0 = generated register number, x1 = compiler stack slot.
    // `ldur/stur [x29, #-imm]` only accepts -256..255; for larger frames
    // materialize the address in x28 and use plain ldr/str.
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x0, x20
    bl _stack_slot_to_offset
    mov x21, x0
    cmp x21, #256
    b.gt Lemit_stack_load_large

    LOAD_ADDR x0, asm_ldur_reg_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_reg_frame_mid
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x20
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_stack_load_done

Lemit_stack_load_large:
    cmp x21, #0x10000
    b.ge Lesll_bigoff
    LOAD_ADDR x0, asm_x28_offset_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    b Lesll_offdone
Lesll_bigoff:
    mov x0, x21
    mov x1, #1                 // reg selector 1 => x28
    bl _emit_movzk_reg
Lesll_offdone:
    LOAD_ADDR x0, asm_x28_sub_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_ldr_reg_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_reg_x28_mem_suffix
    mov x1, #1
    bl _write_cstr_fd

Lemit_stack_load_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_stack_store_reg_fd:
    // x0 = generated register number, x1 = compiler stack slot.
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x0, x20
    bl _stack_slot_to_offset
    mov x21, x0
    cmp x21, #256
    b.gt Lemit_stack_store_large

    LOAD_ADDR x0, asm_stur_reg_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_reg_frame_mid
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x20
    mov x1, #1
    bl _write_stack_offset_fd
    LOAD_ADDR x0, asm_close_bracket
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_stack_store_done

Lemit_stack_store_large:
    cmp x21, #0x10000
    b.ge Less_bigoff
    LOAD_ADDR x0, asm_x28_offset_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    b Less_offdone
Less_bigoff:
    mov x0, x21
    mov x1, #1                 // reg selector 1 => x28
    bl _emit_movzk_reg
Less_offdone:
    LOAD_ADDR x0, asm_x28_sub_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_str_reg_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_reg_x28_mem_suffix
    mov x1, #1
    bl _write_cstr_fd

Lemit_stack_store_done:
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
    LOAD_ADDR x20, emit_tbl_kinds
    ldr x20, [x20]
    ldr x21, [x20, x19, lsl #3]

    cmp x21, #0
    b.eq Lemit_op_print_value
    cmp x21, #1
    b.eq Lemit_op_store_var
    cmp x21, #2
    b.eq Lemit_op_print_var
    cmp x21, #4
    b.eq Lemit_op_return
    cmp x21, #7
    b.le Lemit_op_store_math_imm

    cmp x21, #33
    b.eq Lemit_op_if_start
    cmp x21, #34
    b.eq Lemit_op_if_else
    cmp x21, #35
    b.eq Lemit_op_if_end
    cmp x21, #13
    b.eq Lemit_op_fn_call

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
    cmp x21, #74
    b.eq Lemit_op_cast_bool_to_str
    cmp x21, #78
    b.eq Lemit_op_cast_str_to_int
    cmp x21, #80
    b.eq Lemit_op_list_load
    cmp x21, #81
    b.eq Lemit_op_list_len_rt
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
    cmp x21, #88
    b.eq Lemit_op_map_store
    cmp x21, #90
    b.eq Lemit_op_string_slice
#ifndef _WIN32
    cmp x21, #91
    b.eq Lemit_op_spawn
#endif
    cmp x21, #95
    b.eq Lemit_op_throw
    cmp x21, #96
    b.eq Lemit_op_try_catch
    cmp x21, #97
    b.eq Lemit_op_str_contains
    cmp x21, #98
    b.eq Lemit_op_str_replace
    cmp x21, #99
    b.eq Lemit_op_str_split
    cmp x21, #100
    b.eq Lemit_op_str_upper
    cmp x21, #101
    b.eq Lemit_op_str_lower
    cmp x21, #102
    b.eq Lemit_op_str_char_at
    cmp x21, #103
    b.eq Lemit_op_str_length_runtime
    cmp x21, #104
    b.eq Lemit_op_inc_var
    cmp x21, #105
    b.eq Lemit_op_err_clear
    cmp x21, #106
    b.eq Lemit_op_err_branch
    cmp x21, #107
    b.eq Lemit_op_err_load_value
    cmp x21, #108
    b.eq Lemit_op_throw_no_exit
    cmp x21, #109
    b.eq Lemit_op_list_store
    cmp x21, #110
    b.eq Lemit_op_str_startswith
    cmp x21, #111
    b.eq Lemit_op_str_endswith
    cmp x21, #112
    b.eq Lemit_op_str_indexof
    cmp x21, #113
    b.eq Lemit_op_str_trim
    cmp x21, #114
    b.eq Lemit_op_system
    cmp x21, #115
    b.eq Lemit_op_load_argc
    cmp x21, #116
    b.eq Lemit_op_load_argv
    cmp x21, #117
    b.eq Lemit_op_spawn_wait
    cmp x21, #118
    b.eq Lemit_op_ord
    cmp x21, #119
    b.eq Lemit_op_channel_send
    cmp x21, #120
    b.eq Lemit_op_channel_receive
    cmp x21, #121
    b.eq Lemit_op_channel_close
    cmp x21, #122
    b.eq Lemit_op_channel_init

    b Lemit_op_done

#ifndef _WIN32
Lemit_op_spawn:
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_spawn_go
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done
#endif

Lemit_op_system:
    // arg0: dest (int status), arg1: cmd (data value id if imm, else var slot),
    // arg3: is_imm. Mirrors Lemit_op_file_read but calls libc system(3).
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3] // is_imm flag

    // Load cmd string pointer into x0
    tbz x22, #0, Lemit_system_cmd_var
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_system_call
Lemit_system_cmd_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd

Lemit_system_call:
    LOAD_ADDR x0, asm_call_system
    mov x1, #1
    bl _write_cstr_fd

    // Store x0 (exit status) into dest
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_load_argc:
    // arg0: dest. Load the saved argc into x0, then store into dest.
    LOAD_ADDR x0, asm_load_argc
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_load_argv:
    // arg0: dest (str), arg1: index slot. Load the index into x11, index the
    // saved argv[] to get a char* in x0, then store into dest.
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_load_argv_index
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_spawn_wait:
    // wait(): call _snc_spawn_wait (joins every recorded spawned thread) and
    // store its return value -- the count of threads joined -- into dest.
    // On Windows asm_call_spawn_wait is a no-op that just sets x0 = 0.
    LOAD_ADDR x0, asm_call_spawn_wait
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_channel_send:
    // arg0=result slot, arg1=channel id, arg2=payload source slot.
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #1
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_call_chan_send
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_channel_store_result

Lemit_op_channel_receive:
    // arg0=payload result slot, arg1=channel id.
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_chan_receive
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_channel_store_result

Lemit_op_channel_close:
    // arg0=bool result slot, arg1=channel id.
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_chan_close
    mov x1, #1
    bl _write_cstr_fd

Lemit_op_channel_store_result:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_channel_init:
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_channel_init
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_address:
    LOAD_ADDR x0, asm_sub_x10_x29_imm
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_stack_offset_fd
    
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_deref:
    
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd
    
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
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
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_alloc:
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #-1
    b.eq Lemit_op_alloc_imm
    
    mov x0, x22
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    b Lemit_op_alloc_call

Lemit_op_alloc_imm:
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
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
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_free:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    
    LOAD_ADDR x0, asm_call_free
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_set_ptr:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd
    
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #-1
    b.eq Lemit_op_set_ptr_imm
    
    mov x0, x22
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd
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
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
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
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
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
    LOAD_ADDR x0, asm_store_var_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_print_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    cmp x22, #2
    b.eq Lemit_op_print_var_str

    LOAD_ADDR x0, asm_print_fmt_int_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #1
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_print_stack_only
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_var_str:
    LOAD_ADDR x0, asm_print_fmt_str_adrp
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #1
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_print_stack_only
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_return:
    // Return operation: load return value into x0 and jump to function epilogue
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    // Check if return value is not -1 (void return)
    cmp x0, #-1
    b.eq Lemit_op_return_void
    // Load return value into x0
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #0
    bl _emit_stack_load_reg_fd
Lemit_op_return_void:
    // Jump to function epilogue
    LOAD_ADDR x0, asm_fn_epilogue
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_print_dec_var:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
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
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
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

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_store_math_imm:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

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

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_print_math_imm:
    LOAD_ADDR x0, asm_print_fmt_int_adrp
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd

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
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #11
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_load_reg_fd

    sub x22, x21, #12
    mov x0, x22
    bl _emit_math_opcode_x11

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #11
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_print_math_var:
    LOAD_ADDR x0, asm_print_fmt_int_adrp
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

    sub x22, x21, #17
    mov x0, x22
    bl _emit_math_opcode_x1

    LOAD_ADDR x0, asm_print_stack_only
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_store_math_target_imm:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

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

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #11
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_store_math_target_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #11
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_load_reg_fd

    sub x22, x21, #27
    mov x0, x22
    bl _emit_math_opcode_x11

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #11
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_store_var_var:
    // load source var (op_arg1) into x10
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_load_reg_fd

    // store x10 into dest var (op_arg0)
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_store_str_lit:
    // Store address of print_val_{id} into dest var slot.
    // op_arg0: dest var idx, op_arg1: print/data id
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_mov_x10_x0
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_store_dec_target_imm:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

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
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

Lemit_op_store_dec_target_common:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
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

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_concat:
    // arg0: dest, arg1: left, arg2: right, arg3: flags
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3] // flags

    // Load left into x0
    tbz x22, #0, Lemit_str_concat_left_var
    // left is imm (print_id)
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_str_concat_right

Lemit_str_concat_left_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd

Lemit_str_concat_right:
    // Load right into x1
    tbz x22, #1, Lemit_str_concat_right_var
    // right is imm (print_id)
    LOAD_ADDR x0, asm_load_x1_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_str_concat_call

Lemit_str_concat_right_var:
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd

Lemit_str_concat_call:
    LOAD_ADDR x0, asm_call_str_concat
    mov x1, #1
    bl _write_cstr_fd
    
    // Store x0 into dest
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_file_read:
    // arg0: dest, arg1: path, arg3: flags
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3] // flags

    // Load path into x0
    tbz x22, #0, Lemit_file_read_path_var
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_file_read_call
Lemit_file_read_path_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd

Lemit_file_read_call:
    LOAD_ADDR x0, asm_call_file_read
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_file_write:
    // arg0: success, arg1: path, arg2: data, arg3: flags
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]

    // Load path into x0
    tbz x22, #0, Lemit_file_write_path_var
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_file_write_data
Lemit_file_write_path_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd

Lemit_file_write_data:
    // Load data into x1
    tbz x22, #1, Lemit_file_write_data_var
    LOAD_ADDR x0, asm_load_x1_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_file_write_call
Lemit_file_write_data_var:
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd

Lemit_file_write_call:
    // At this point the emitted code has path in x0 and data in x1. Emit a
    // strlen(data)->x2 preamble so _file_write writes the full string (codegen
    // never otherwise loads x2, which left the write length at 0).
    LOAD_ADDR x0, asm_file_write_len_prep
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_call_file_write
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_cast_int_to_str:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x0, asm_call_int_to_cstr
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_cast_bool_to_str:
    // arg0: dest var idx
    // arg1: source bool var idx
    // arg2: print/data id for "true"
    // arg3: print/data id for "false"
    stp x23, x24, [sp, #-16]!

    // Load source bool into x11 and branch to false label when zero.
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

    bl _get_next_label
    mov x23, x0 // false label
    bl _get_next_label
    mov x24, x0 // end label

    LOAD_ADDR x0, asm_branch_zero
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x23
    bl _emit_label_name
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // true path: x0 = &print_val_<true_id>
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd

    LOAD_ADDR x0, asm_branch
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x24
    bl _emit_label_name
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // false label
    mov x0, x23
    bl _emit_label_name
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

    // false path: x0 = &print_val_<false_id>
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd

    // end label
    mov x0, x24
    bl _emit_label_name
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

    ldp x23, x24, [sp], #16
    b Lemit_op_done

Lemit_op_list_load:
    // arg0: dest, arg1: index_var/imm, arg2: base_idx, arg3: flags
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    tbz x22, #1, Lemit_list_load_var
    
    // Immediate index
    LOAD_ADDR x0, asm_mov_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_list_load_ready

Lemit_list_load_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

Lemit_list_load_ready:
    tbz x22, #2, Lemit_list_load_base_imm

    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #12
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x0, asm_add_x10_x12
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_list_load_base_ready

Lemit_list_load_base_imm:
    LOAD_ADDR x0, asm_add_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lemit_list_load_base_ready:
    LOAD_ADDR x0, asm_load_list_pool_x11
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_load_pool_val_x10
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_list_store:
    // Runtime store of a list element: list_pool_values[base+index] = rhs.
    // arg0: rhs (slot id, or immediate value when flag bit3 set)
    // arg1: index (slot id, or immediate value when flag bit1 set)
    // arg2: base (immediate pool base, or runtime base var slot when bit2 set)
    // arg3: flags (bit1=imm index, bit2=runtime/param base, bit3=imm rhs)
    // Mirror of Lemit_op_list_load, but stores instead of loads. All stack
    // loads are done BEFORE materializing the pool address into x11 (so the
    // x28-based large-offset load helper can never clobber x11).
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]

    // --- index into x10 ---
    tbz x22, #1, Lemit_list_store_idx_var
    LOAD_ADDR x0, asm_mov_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_list_store_idx_ready
Lemit_list_store_idx_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

Lemit_list_store_idx_ready:
    // --- add base ---
    tbz x22, #2, Lemit_list_store_base_imm
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #12
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_add_x10_x12
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_list_store_base_ready
Lemit_list_store_base_imm:
    LOAD_ADDR x0, asm_add_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lemit_list_store_base_ready:
    // --- rhs value into x12 ---
    tbz x22, #3, Lemit_list_store_rhs_var
    LOAD_ADDR x0, asm_mov_x12_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_list_store_rhs_ready
Lemit_list_store_rhs_var:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #12
    bl _emit_stack_load_reg_fd

Lemit_list_store_rhs_ready:
    // --- pool address into x11, then store x12 into [x11 + x10*8] ---
    LOAD_ADDR x0, asm_load_list_pool_x11
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_store_pool_val_x12
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_list_len_rt:
    // arg0: dest slot, arg1: list-parameter base var slot.
    // The parameter's runtime value is the list's pool base index; the element
    // count lives at list_base_counts[base]. Load base -> x10, then index the
    // base-counts table and store the count into dest.
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x0, asm_load_list_base_counts_x11
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_load_pool_val_x10
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_cast_str_to_int:
    // arg0: dest, arg1: source_var
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd
    
    LOAD_ADDR x0, asm_mov_x0_x10
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_call_cstr_to_int
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_map_load:
    // arg0: dest, arg1: key_var, arg2: base_idx, arg3: packed
    // packed: (key_type << 56) | (val_type << 48) | (is_imm << 47) | count
    
    // Unpack arg3
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    and x23, x22, #0xFFFFFFFF // count
    lsr x24, x22, #56 // key type
    ubfx x25, x22, #48, #8 // value type
    
    tbz x22, #47, Lemit_map_load_var
    
    // Immediate key
    cmp x24, #2 // str
    b.eq Lemit_map_load_imm_str
    
    // Immediate int key
    LOAD_ADDR x0, asm_mov_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_load_imm_ready

Lemit_map_load_imm_str:
    // Load string pointer from print pool
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x0, asm_mov_x10_x0
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_load_imm_ready

Lemit_map_load_var:
    // 1. Load key value from stack into x10
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

Lemit_map_load_imm_ready:
    // mov x2, x10
    LOAD_ADDR x0, asm_mov_x2_x10
    mov x1, #1
    bl _write_cstr_fd
    
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
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
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

    // 5. Handle miss fallback for string values (x2 == 0 means key not found)
    bl _get_next_label
    mov x26, x0 // map miss label
    bl _get_next_label
    mov x27, x0 // map end label

    LOAD_ADDR x0, asm_mov_x11_x2
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_branch_zero
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x26
    bl _emit_label_name
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_branch
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x27
    bl _emit_label_name
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // map-miss label
    mov x0, x26
    bl _emit_label_name
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

    // for non-string values use zero; for strings use fallback id from op_arg4
    cmp x25, #2
    b.ne Lemit_map_load_miss_zero
    LOAD_ADDR x20, emit_tbl_arg4
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    cbz x22, Lemit_map_load_miss_zero
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_load_miss_done

Lemit_map_load_miss_zero:
    LOAD_ADDR x0, asm_mov_x0_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, #0
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lemit_map_load_miss_done:
    // end label
    mov x0, x27
    bl _emit_label_name
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

    // 6. Store result x0 into dest variable slot
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    
    b Lemit_op_done

Lemit_op_map_store:
    // arg0: map base index (immediate)
    // arg1: key operand (slot or immediate)
    // arg2: value operand (slot or immediate)
    // arg3: packed (key_type<<56 | val_type<<48 | key_is_imm<<47 | val_is_imm<<46)
    // arg4: immediate string key length (or 0)
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    lsr x24, x22, #56          // key type
    ubfx x25, x22, #48, #8     // value type

    // x0 = map base index
    LOAD_ADDR x0, asm_mov_x0_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // x1 key
    tbz x22, #47, Lemit_map_store_key_var
    cmp x24, #2
    b.eq Lemit_map_store_key_imm_str
    LOAD_ADDR x0, asm_mov_x1_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_key_ready
Lemit_map_store_key_imm_str:
    LOAD_ADDR x0, asm_load_x1_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_key_ready
Lemit_map_store_key_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
Lemit_map_store_key_ready:

    // x2 key type
    LOAD_ADDR x0, asm_mov_x2_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x24
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // x3 key len
    cmp x24, #2
    b.ne Lemit_map_store_key_len_zero
    tbz x22, #47, Lemit_map_store_key_len_from_var
    LOAD_ADDR x0, asm_mov_x3_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg4
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_value_prep
Lemit_map_store_key_len_from_var:
    LOAD_ADDR x0, asm_mov_x0_x1
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_cstring_length
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_mov_x3_x0
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_value_prep
Lemit_map_store_key_len_zero:
    LOAD_ADDR x0, asm_mov_x3_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, #0
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lemit_map_store_value_prep:
    // x4 value
    tbz x22, #46, Lemit_map_store_val_var
    cmp x25, #2
    b.eq Lemit_map_store_val_imm_str
    LOAD_ADDR x0, asm_mov_x4_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_val_type
Lemit_map_store_val_imm_str:
    LOAD_ADDR x0, asm_load_x4_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x4_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x4_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_val_type
Lemit_map_store_val_var:
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #4
    bl _emit_stack_load_reg_fd

Lemit_map_store_val_type:
    // x5 value type
    LOAD_ADDR x0, asm_mov_x5_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x25
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // x6 value len
    cmp x25, #2
    b.ne Lemit_map_store_val_len_zero
    tbz x22, #46, Lemit_map_store_val_len_from_var
    LOAD_ADDR x0, asm_mov_x0_x4
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_cstring_length
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_mov_x6_x0
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_call
Lemit_map_store_val_len_from_var:
    LOAD_ADDR x0, asm_mov_x0_x4
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_call_cstring_length
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_mov_x6_x0
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_call
Lemit_map_store_val_len_zero:
    LOAD_ADDR x0, asm_mov_x6_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, #0
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

Lemit_map_store_call:
    // Re-load key into x1 because helper calls for key/value lengths may clobber it.
    tbz x22, #47, Lemit_map_store_call_key_var
    cmp x24, #2
    b.eq Lemit_map_store_call_key_imm_str
    LOAD_ADDR x0, asm_mov_x1_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_call_ready
Lemit_map_store_call_key_imm_str:
    LOAD_ADDR x0, asm_load_x1_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x1_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_map_store_call_ready
Lemit_map_store_call_key_var:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
Lemit_map_store_call_ready:
    // Re-load map base index into x0 before helper call.
    LOAD_ADDR x0, asm_mov_x0_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    LOAD_ADDR x0, asm_call_map_store
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_string_slice:
    // arg0 = dest slot, arg1 = source slot
    // arg2 = start (immediate, or var-slot with bit63 set)
    // arg3 = end   (immediate, or var-slot with bit63 set)

    // x0 = source string ptr: ldur x0, [x29, #-<source_slot*8>]
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd

    // x1 = start
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    tbnz x22, #63, Lslice_emit_start_var
    LOAD_ADDR x0, asm_mov_x1_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lslice_emit_end
Lslice_emit_start_var:
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd

Lslice_emit_end:
    // x2 = end
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    tbnz x22, #63, Lslice_emit_end_var
    LOAD_ADDR x0, asm_mov_x2_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lstring_slice_call
Lslice_emit_end_var:
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #2
    bl _emit_stack_load_reg_fd

Lstring_slice_call:
    // Call _string_slice
    LOAD_ADDR x0, asm_call_string_slice
    mov x1, #1
    bl _write_cstr_fd
    
    // Store result to dest slot
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd

    b Lemit_op_done

// String method operations - emit calls to runtime functions

Lemit_op_str_contains:
    // arg0 = dest slot, arg1 = source var, arg2 = substr val, arg3 = substr var
    // Load source string
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    // Load substring
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    tbnz x22, #63, Lstr_contains_substr_var
    LOAD_ADDR x0, asm_mov_x1_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lstr_contains_call
Lstr_contains_substr_var:
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
Lstr_contains_call:
    // Call _str_contains
    LOAD_ADDR x0, asm_call_str_contains
    mov x1, #1
    bl _write_cstr_fd
    // Store result (bool in x0) to dest slot
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_replace:
    // arg0 = dest slot, arg1 = source var, arg2 = old var|bit63, arg3 = new var|bit63
    // Load source string into x0
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    // Load old substring into x1 (var slot, bit63 tag stripped)
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
    // Load new substring into x2 (var slot, bit63 tag stripped)
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #2
    bl _emit_stack_load_reg_fd
    // Call _str_replace
    LOAD_ADDR x0, asm_call_str_replace
    mov x1, #1
    bl _write_cstr_fd
    // Store result (string ptr in x0) to dest slot
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_split:
    // arg0 = reserved pool base (immediate), arg1 = source string var slot,
    // arg2 = separator var slot (bit63-tagged), arg3 = unused.
    // _str_split(x0=src, x1=sep, x2=base) fills list_pool_values[base..] with
    // malloc'd piece pointers and sets list_base_counts[base] = piece count.
    // The result "list" is the compile-time base itself (no dest slot to store).
    // Load source string -> x0.
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    // Load separator (var slot, bit63 tag stripped) -> x1.
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
    // Load reserved base (immediate) -> x2.
    LOAD_ADDR x0, asm_mov_x2_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    // Call _str_split.
    LOAD_ADDR x0, asm_call_str_split
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_str_upper:
    // arg0 = dest slot, arg1 = source var
    // Load source
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    // Call _str_upper
    LOAD_ADDR x0, asm_call_str_upper
    mov x1, #1
    bl _write_cstr_fd
    // Store result
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_lower:
    // arg0 = dest slot, arg1 = source var
    // Load source
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    // Call _str_lower
    LOAD_ADDR x0, asm_call_str_lower
    mov x1, #1
    bl _write_cstr_fd
    // Store result
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_char_at:
    // arg0 = dest slot, arg1 = source var, arg2 = index (imm or var|bit63)
    // Load source string into x0
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    // Load index into x1 (immediate or from stack slot)
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    tbnz x22, #63, Lstr_char_at_index_var
    LOAD_ADDR x0, asm_mov_x1_imm
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lstr_char_at_call
Lstr_char_at_index_var:
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
Lstr_char_at_call:
    LOAD_ADDR x0, asm_call_str_char_at
    mov x1, #1
    bl _write_cstr_fd
    // Store result (string ptr in x0) to dest slot
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_length_runtime:
    // arg0 = dest slot, arg1 = source string var.
    // Compute strlen at runtime (the compile-time length is unknown for
    // strings produced at runtime: params, concat, file_read, etc.).
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    // Call _cstring_length (x0 = char*, returns length in x0)
    LOAD_ADDR x0, asm_call_cstring_length
    mov x1, #1
    bl _write_cstr_fd
    // Store the int result to dest slot
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_ord:
    // arg0 = dest slot (int), arg1 = source string var slot.
    // Load the string pointer from the source slot into x0, read its first
    // byte via asm_ord_first_byte (0 if the pointer is null/empty), then store
    // that int into the dest slot. Mirrors op 103 (str length) but emits an
    // inline first-byte read instead of calling _cstring_length.
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_ord_first_byte
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_startswith:
    // arg0 = dest slot, arg1 = source var, arg2 = substr var (bit63-tagged)
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_call_str_startswith
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_endswith:
    // arg0 = dest slot, arg1 = source var, arg2 = substr var (bit63-tagged)
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_call_str_endswith
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_indexof:
    // arg0 = dest slot, arg1 = source var, arg2 = substr var (bit63-tagged)
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x22, [x20, x19, lsl #3]
    mov x9, #1
    lsl x9, x9, #63
    bic x0, x22, x9
    mov x1, x0
    mov x0, #1
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_call_str_indexof
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_str_trim:
    // arg0 = dest slot, arg1 = source var
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_call_str_trim
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_throw:
    // arg0 = error message pointer (string literal addr)
    // arg1 = string length
    // Emit: mov x0, #error_msg_addr
    //       bl _print_error_and_exit
    LOAD_ADDR x0, asm_mov_x0_imm_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // Store error message in error_value global
    LOAD_ADDR x0, asm_adrp_error_value
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_str_x0_error_value
    mov x1, #1
    bl _write_cstr_fd

    // Set error flag
    LOAD_ADDR x0, asm_adrp_error_flag
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_mov_x1_imm_1
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_str_x1_error_flag
    mov x1, #1
    bl _write_cstr_fd

    // Exit with error code
    LOAD_ADDR x0, asm_exit_1
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_try_catch:
    // arg0 = try expression value
    // arg1 = try expression var_idx (-1 = immediate, >=0 = var slot)
    // arg2 = fallback value
    // arg3 = fallback var_idx (-1 = immediate, >=0 = var slot)
    // Simplified: just load try value, check if error flag set
    // If error, use fallback; otherwise continue with try value

    // Save callee-saved registers
    stp x23, x24, [sp, #-16]!

    // Check if try value is immediate (var_idx == -1) or variable
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x23, [x20, x19, lsl #3]  // x23 = try var_idx
    cmp x23, #-1
    b.ne Lemit_try_catch_try_var

Lemit_try_catch_try_imm:
    // Load immediate try value into x10
    LOAD_ADDR x0, asm_mov_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]  // try value
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_try_catch_check_error

Lemit_try_catch_try_var:
    // Load try value from variable slot into x10
    mov x0, x23  // try meta = var slot
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

Lemit_try_catch_check_error:
    // Generate unique label for catch block
    LOAD_ADDR x20, current_label_id
    ldr x21, [x20]
    add x22, x21, #1
    str x22, [x20]

    // Check error flag
    LOAD_ADDR x0, asm_adrp_error_flag
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_ldr_x11_error_flag
    mov x1, #1
    bl _write_cstr_fd

    // Compare with 0
    LOAD_ADDR x0, asm_cmp_x11_imm_0
    mov x1, #1
    bl _write_cstr_fd

    // Branch to catch if error (error_flag != 0)
    LOAD_ADDR x0, asm_beq_label
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // No error - jump over catch block to continue
    LOAD_ADDR x0, asm_b_suffix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd

    // Catch block label
    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x21
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

    // Check if fallback value is immediate (var_idx == -1) or variable
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x24, [x20, x19, lsl #3]  // x24 = fallback var_idx
    cmp x24, #-1
    b.ne Lemit_try_catch_fallback_var

Lemit_try_catch_fallback_imm:
    // Load immediate fallback value into x10
    LOAD_ADDR x0, asm_mov_x10_imm
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]  // fallback value
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    // Skip over variable fallback path to continue label
    b Lemit_try_catch_continue_label

Lemit_try_catch_fallback_var:
    // Load fallback value from variable slot into x10
    mov x0, x24  // fallback meta = var slot
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

Lemit_try_catch_continue_label:
    // Continue label (after catch block)
    LOAD_ADDR x0, asm_label_prefix
    mov x1, #1
    bl _write_cstr_fd
    mov x0, x22
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd

Lemit_try_catch_clear_flag:
    // Clear error flag after handling
    LOAD_ADDR x0, asm_adrp_error_flag
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_str_xzr_error_flag
    mov x1, #1
    bl _write_cstr_fd

    // Restore callee-saved registers and return from operation
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lemit_op_inc_var:
    // arg0 = var slot. Load slot -> x10, add #1, store back. Used by the
    // runtime for-in loop to advance its counter (see _emit_for_in_runtime_loop).
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_load_reg_fd
    LOAD_ADDR x0, asm_add_x10_1
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]
    mov x0, #10
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_err_clear:
    // Clear the runtime error flag: error_flag = 0. Emitted at try entry and
    // again at catch entry (the error is handled). See _emit block try/catch.
    LOAD_ADDR x0, asm_adrp_error_flag       // x11 = &error_flag
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_str_xzr_error_flag     // str xzr, [x11]
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_err_branch:
    // arg0 = catch label id. Emit: if error_flag != 0, branch to L_snl_<id>.
    LOAD_ADDR x0, asm_adrp_error_flag       // x11 = &error_flag
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_ldr_x11_error_flag     // ldr x11, [x11]
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_cmp_x11_imm_0          // cmp x11, #0
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_bne_prefix             // "    b.ne " (label added below)
    mov x1, #1
    bl _write_cstr_fd
    // Emit the target through _emit_label_name so it gets the same
    // "L_snl_<table>_<id>" form as the placed catch label (op 36). A bare
    // number here produced "L_snl_0" which never matched "L_snl_<table>_0".
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    LOAD_ADDR x0, asm_newline
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_done

Lemit_op_err_load_value:
    // arg0 = destination var slot. Load the thrown message (error_value) into
    // that slot so the catch variable `e` holds it (as a str data-value id).
    LOAD_ADDR x0, asm_adrp_error_value       // x12 = &error_value
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_ldr_x0_error_value      // ldr x0, [x12]
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x1, [x20, x19, lsl #3]                // dest slot
    mov x0, #0                                // store x0
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_throw_no_exit:
    // arg0 = message data-value id. Set error_value + error_flag but DO NOT
    // exit (unlike op 95). The enclosing block try's op41 jump (recorded right
    // after this op) transfers control to the catch label.
    // Materialize the runtime POINTER to print_val_<id> into x0 (a str variable
    // holds a char* pointer, not the data-value id -- see Lemit_op_store_str_lit),
    // so the catch variable `e` prints the message instead of "(null)".
    LOAD_ADDR x0, asm_load_x0_print_val_prefix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_middle
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, #1
    bl _write_u64_fd
    LOAD_ADDR x0, asm_load_x0_print_val_suffix
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_adrp_error_value        // x12 = &error_value
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_str_x0_error_value       // str x0, [x12]
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_adrp_error_flag          // x11 = &error_flag
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_mov_x1_imm_1             // mov x1, #1
    mov x1, #1
    bl _write_cstr_fd
    LOAD_ADDR x0, asm_str_x1_error_flag        // str x1, [x11]
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
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd
    
    // cbz x11, L_snl_ELSE
    LOAD_ADDR x0, asm_branch_zero
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
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
    
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    // place ELSE label (op_arg0)
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_if_end:
    // place END label (op_arg0)
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_while_start:
    // place START label (op_arg0)
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_while_cond:
    // load var into x11
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd
    
    // cbz x11, L_snl_END
    LOAD_ADDR x0, asm_branch_zero
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
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
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    // place END label (op_arg1)
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_fn_call:
    // _emit_user_function's op loop keeps its start/count/counter in
    // x22/x23/x24 across _emit_operation, and this handler reuses
    // x22-x26 -- preserve them or the fn emitter stops right after the
    // first call op (everything after the call silently vanished).
    sub sp, sp, #48
    stp x22, x23, [sp]
    stp x24, x25, [sp, #16]
    str x26, [sp, #32]
    LOAD_ADDR x9, emit_tbl_arg0
    ldr x9, [x9]
    mov x22, x0                 // preserve op index
    ldr x23, [x9, x22, lsl #3] // fn index

    // Marshal staged argument slots into x0..xN before the branch.
    LOAD_ADDR x9, emit_tbl_arg1
    ldr x9, [x9]
    ldr x24, [x9, x22, lsl #3] // arg block base slot (-1 if none)
    LOAD_ADDR x9, emit_tbl_arg2
    ldr x9, [x9]
    ldr x25, [x9, x22, lsl #3] // arg count
    mov x26, #0
Lemit_op_fn_call_arg_loop:
    cmp x26, x25
    b.ge Lemit_op_fn_call_args_done
    mov x0, x26
    add x1, x24, x26
    bl _emit_stack_load_reg_fd
    add x26, x26, #1
    b Lemit_op_fn_call_arg_loop
Lemit_op_fn_call_args_done:
    
    LOAD_ADDR x0, single_char
    mov w9, #' '
    strb w9, [x0]
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    // bl _name
    LOAD_ADDR x0, asm_bl_prefix
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_TBL x9, fn_name_ptrs
    ldr x0, [x9, x23, lsl #3]
    LOAD_TBL x9, fn_name_lens
    ldr x1, [x9, x23, lsl #3]
    mov x2, #1
    bl _write_buffer_fd
    bl _write_newline_stdout

    // Capture x0 return value into the result slot recorded in op_arg3.
    LOAD_ADDR x9, emit_tbl_arg3
    ldr x9, [x9]
    ldr x24, [x9, x22, lsl #3]
    cmn x24, #1
    b.eq Lemit_op_fn_call_no_result
    mov x0, #0
    mov x1, x24
    bl _emit_stack_store_reg_fd
Lemit_op_fn_call_no_result:
    ldp x22, x23, [sp]
    ldp x24, x25, [sp, #16]
    ldr x26, [sp, #32]
    add sp, sp, #48
    b Lemit_op_done

Lemit_op_jump:
    // unconditional jump to label in op_arg0. The arg holds the raw label
    // index; emit it through _emit_label_name so it gets the proper
    // "L_snl_<table>_" prefix (matching the loop labels), instead of a bare
    // number that the assembler rejects.
    LOAD_ADDR x0, asm_branch
    mov x1, #1
    bl _write_cstr_fd
    
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    
    b Lemit_op_done

Lemit_op_logic_and:
    // load LHS (op_arg0) into x11
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

    // load RHS (op_arg1) into x10
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x0, asm_logic_and_x11_x10
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_logic_store

Lemit_op_logic_or:
    // load LHS (op_arg0) into x11
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

    // load RHS (op_arg1) into x10
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x0, asm_logic_or_x11_x10
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_logic_store

Lemit_op_logic_not:
    // load LHS (op_arg0) into x11
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd

    LOAD_ADDR x0, asm_logic_not_x11
    mov x1, #1
    bl _write_cstr_fd
    b Lemit_op_logic_store

Lemit_op_update_label:
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    bl _emit_label_name
    
    LOAD_ADDR x0, asm_label_suffix
    mov x1, #1
    bl _write_cstr_fd
    
    b Lemit_op_done

Lemit_op_logic_store:
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_store_reg_fd
    b Lemit_op_done

Lemit_op_cmp_imm:
    // load left var into x11
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd
    
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
    LOAD_ADDR x20, emit_tbl_arg0
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_load_reg_fd
    
    // load right var into x10
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #10
    bl _emit_stack_load_reg_fd

Lemit_cmp_shared:
    // emit `cmp x11, x10`
    LOAD_ADDR x0, asm_cmp_x11_x10
    mov x1, #1
    bl _write_cstr_fd
    
    // emit cset depending on op_arg2
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
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
    
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    mov x1, x0
    mov x0, #11
    bl _emit_stack_store_reg_fd
    
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
    // print_types/print_noline are now POINTERS to heap buffers: deref first.
    LOAD_ADDR x20, print_types
    ldr x20, [x20]
    ldr x21, [x20, x19, lsl #3]

    // Check print_noline from array
    LOAD_ADDR x22, print_noline
    ldr x22, [x22]
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
    // print_* are now POINTERS to heap buffers: deref before indexing.
    LOAD_ADDR x20, print_types
    ldr x20, [x20]
    ldr x23, [x20, x19, lsl #3] // type

    LOAD_ADDR x20, print_values
    ldr x20, [x20]
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
    ldr x20, [x20]
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
    ldr x20, [x20]
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
    LOAD_TBL x19, var_types
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
    LOAD_ADDR x20, emit_tbl_kinds
    ldr x20, [x20]
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
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    b Lemit_store_data_cmp_imm_load
Lemit_store_data_cmp_imm_arg1:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
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
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
    ldr x0, [x20, x19, lsl #3]
    LOAD_ADDR x20, emit_tbl_arg2
    ldr x20, [x20]
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
    LOAD_ADDR x20, emit_tbl_arg3
    ldr x20, [x20]
    b Lemit_store_data_load
Lemit_store_data_arg1:
    LOAD_ADDR x20, emit_tbl_arg1
    ldr x20, [x20]
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

_stack_slot_to_offset:
    // x0 = compiler slot id. Return byte offset from current generated frame
    // in x0. User functions are compiled with global slot ids, so subtract
    // their recorded scope base when current_table_id is 100 + function index.
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    LOAD_ADDR x9, current_table_id
    ldr x20, [x9]
    cmp x20, #100
    b.lt Lstack_slot_no_scope_base
    sub x20, x20, #100
    LOAD_TBL x21, fn_scope_bases
    ldr x21, [x21, x20, lsl #3]
    cmp x19, x21
    b.lt Lstack_slot_no_scope_base
    sub x19, x19, x21
Lstack_slot_no_scope_base:
    add x0, x19, #1
    mov x22, #8
    mul x0, x0, x22

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_write_stack_offset_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl _stack_slot_to_offset
    bl _write_u64_fd
    ldp x29, x30, [sp], #16
    ret

_emit_main_body:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    LOAD_ADDR x0, current_table_id
    mov x1, #0
    str x1, [x0]

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
    cbz x19, Lemit_main_no_stack_alloc

    mov x0, x19
    bl _emit_stack_alloc

Lemit_main_no_stack_alloc:
    LOAD_ADDR x19, global_op_count
    ldr x20, [x19]
    mov x21, #0
Lemit_main_body_loop:
    cmp x21, x20
    b.ge Lemit_main_body_check_fn_main
    mov x0, x21
    bl _emit_operation
    add x21, x21, #1
    b Lemit_main_body_loop

Lemit_main_body_check_fn_main:
    // Also emit code from user function "main" if it exists
    LOAD_ADDR x0, kw_main
    mov x1, #4
    bl _lookup_function
    cbz x0, Lemit_main_body_done
    mov x19, x1 // fn_id of "main"
    
    LOAD_ADDR x0, current_table_id
    add x1, x19, #100
    str x1, [x0]

    LOAD_TBL x9, fn_op_starts
    ldr x21, [x9, x19, lsl #3]
    LOAD_TBL x9, fn_op_counts
    ldr x22, [x9, x19, lsl #3]
    
    mov x20, #0
Lemit_main_fn_loop:
    cmp x20, x22
    b.ge Lemit_main_body_done
    add x0, x21, x20
    bl _emit_operation
    add x20, x20, #1
    b Lemit_main_fn_loop

Lemit_main_body_done:
    // main epilogue will be emitted by Lemit_user_fns_done (asm_main_epilogue)
    // Just restore registers and return
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_emit_user_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0 // fn index

    // Debug: print function index and operation count
    // LOAD_ADDR x0, debug_emit_fn
    // mov x1, #1
    // bl _write_cstr_fd
    // mov x0, x19
    // mov x1, #1
    // bl _write_i64_fd
    // bl _write_newline_stdout

    LOAD_ADDR x0, current_table_id
    add x1, x19, #100
    str x1, [x0]

    // Emit newline
    LOAD_ADDR x0, single_char
    mov w9, #'\n'
    strb w9, [x0]
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd

    // Emit global prefix
    LOAD_ADDR x0, asm_global_prefix
    mov x1, #1
    bl _write_cstr_fd

    LOAD_TBL x9, fn_name_ptrs
    ldr x20, [x9, x19, lsl #3] // ptr
    LOAD_TBL x9, fn_name_lens
    ldr x21, [x9, x19, lsl #3] // len
    
    mov x0, x20
    mov x1, x21
    mov x2, #1
    bl _write_buffer_fd
    bl _write_newline_stdout

    // Emit label
    mov x0, x20
    mov x1, x21
    mov x2, #1
    bl _write_buffer_fd
    LOAD_ADDR x0, single_char
    mov w9, #':'
    strb w9, [x0]
    mov x1, #1
    mov x2, #1
    bl _write_buffer_fd
    bl _write_newline_stdout

    // Prologue
    LOAD_ADDR x0, asm_prologue
    mov x1, #1
    bl _write_cstr_fd

    // Stack allocation for this function. Use the parser-computed per-function
    // frame size (fn_frame_sizes[fn_idx]), NOT a fixed 128. A function with more
    // than ~15 slots addresses locals below a 128-byte frame; that is harmless
    // for a leaf function, but as soon as it CALLS another function (or recurses)
    // the callee's frame overlaps those slots and silently clobbers the caller's
    // locals -- e.g. a recursive solver whose helper call corrupted its loop
    // counters. The epilogue restores via `mov sp, x29`, so any (16-aligned)
    // size is balanced.
    LOAD_TBL x9, fn_frame_sizes
    ldr x0, [x9, x19, lsl #3]
    bl _emit_stack_alloc

    // Store incoming argument registers into this function's parameter slots.
    LOAD_TBL x9, fn_scope_bases
    ldr x20, [x9, x19, lsl #3]
    LOAD_TBL x9, fn_param_counts
    ldr x21, [x9, x19, lsl #3]
    mov x22, #0
Lemit_fn_param_store_loop:
    cmp x22, x21
    b.ge Lemit_fn_param_store_done
    mov x0, x22
    add x1, x20, x22
    bl _emit_stack_store_reg_fd
    add x22, x22, #1
    b Lemit_fn_param_store_loop
Lemit_fn_param_store_done:
    
    // Emit the operations
    LOAD_TBL x9, fn_op_starts
    ldr x22, [x9, x19, lsl #3] // start index
    LOAD_TBL x9, fn_op_counts
    ldr x23, [x9, x19, lsl #3] // count
    
        
    mov x24, #0
Lemit_fn_ops_loop:
    cmp x24, x23
    b.ge Lemit_fn_ops_done
    add x0, x22, x24
    bl _emit_operation
    add x24, x24, #1
    b Lemit_fn_ops_loop

Lemit_fn_ops_done:
    // Epilogue
    LOAD_ADDR x0, asm_fn_epilogue
    mov x1, #1
    bl _write_cstr_fd

    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


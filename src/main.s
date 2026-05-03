#include "platform.inc"
.global _main
.global _read_into_buffer
.global _set_source
.align 4

.extern _open
.extern _read
.extern _write
.extern _close
.extern _exit
.extern _parse_statement
.extern _lookup_function
.extern _cstring_length

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    mov x20, x1

    cmp x19, #2
    b.ge Lmain_have_input

    LOAD_ADDR x0, msg_usage
    mov x1, #2
    bl _write_cstr_fd
    mov w0, #1
    bl _exit

Lmain_have_input:
    ldr x0, [x20, #8]
    bl _load_file
    cmp x0, #0
    b.lt Lmain_fail
    mov x19, x0

    LOAD_ADDR x0, buffer
    mov x1, x19
    bl _set_source

    LOAD_ADDR x0, zero_qword
    ldr x1, [x0]
    LOAD_ADDR x2, cursor_pos
    str x1, [x2]
    LOAD_ADDR x2, current_line
    mov x3, #1
    str x3, [x2]
    LOAD_ADDR x2, var_count
    str x1, [x2]
    LOAD_ADDR x2, print_count
    str x1, [x2]
    LOAD_ADDR x2, fn_count
    str x1, [x2]
    
    // Initialize fn_blueprint_ids to -1
    mov x3, #-1
    mov x4, #0
Linit_fn_bp_ids:
    cmp x4, #64
    b.ge Linit_fn_bp_ids_done
    LOAD_ADDR x5, fn_blueprint_ids
    str x3, [x5, x4, lsl #3]
    add x4, x4, #1
    b Linit_fn_bp_ids
Linit_fn_bp_ids_done:

    LOAD_ADDR x2, label_counter
    str x1, [x2]
    LOAD_ADDR x2, op_count
    str x1, [x2]
#ifndef _WIN32
    mov x3, #-1
    LOAD_ADDR x4, spawn_capture_fn_id
    str x3, [x4]
#endif
    LOAD_ADDR x2, current_loop_start
    str x1, [x2]
    LOAD_ADDR x2, current_loop_end
    str x1, [x2]
    LOAD_ADDR x2, loop_context_depth
    str x1, [x2]
    LOAD_ADDR x2, var_scope_base
    str x1, [x2]

    // Initialize variable system
    LOAD_ADDR x9, var_count
    str xzr, [x9]
    LOAD_ADDR x9, var_scope_base
    str xzr, [x9]
    LOAD_ADDR x9, max_var_count
    str xzr, [x9]
    
    // Initialize module system
    bl _init_default_search_paths

    bl _parse_program
    cbnz x0, Lmain_fail

    // Save global op count (ops recorded during _parse_program)
    LOAD_ADDR x0, op_count
    ldr x0, [x0]
    LOAD_ADDR x1, global_op_count
    str x0, [x1]

    // Now parse all defined functions
    LOAD_ADDR x19, fn_count
    ldr x20, [x19]
    mov x21, #0
Lmain_parse_fns_loop:
    cmp x21, x20
    b.ge Lmain_parse_fns_done
    
    mov x0, x21
    bl _parse_function_body
    add x21, x21, #1
    b Lmain_parse_fns_loop
Lmain_parse_fns_done:


    bl _emit_program

    mov w0, #0
    bl _exit

Lmain_no_main_fn:


Lmain_fail:
    mov w0, #1
    bl _exit

_load_file:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x1, #0
    bl _open
    cmp x0, #0
    b.lt Lload_open_failed

    mov x20, x0
    mov x0, x20
    bl _read_into_buffer
    mov x21, x0
    mov x0, x20
    bl _close
    mov x0, x21
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lload_open_failed:
    LOAD_ADDR x0, msg_open_error
    mov x1, #2
    bl _write_cstr_fd
    mov x0, x19
    mov x1, #2
    bl _write_cstr_fd
    bl _write_newline_stderr
    mov x0, #-1
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_read_into_buffer:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, #0
    LOAD_ADDR x21, buffer

Lread_loop:
     mov x22, #65535
     sub x22, x22, x20
     cbz x22, Lbuffer_full

     mov x0, x19
     add x1, x21, x20
     mov x2, x22
     bl _read
     cbz x0, Lread_done
     b.lt Lread_failed
     // Cap read at buffer limit (65535 content + 1 null terminator = 65536)
     cmp x0, x22
     b.gt Lbuffer_full

     add x20, x20, x0
     b Lread_loop

Lbuffer_full:
    LOAD_ADDR x0, msg_truncated
    mov x1, #2
    bl _write_cstr_fd

Lread_done:
    add x1, x21, x20
    strb wzr, [x1]
    mov x0, x20
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lread_failed:
    LOAD_ADDR x0, msg_read_error
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #-1
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_set_source:
    LOAD_ADDR x2, source_ptr
    str x0, [x2]
    LOAD_ADDR x2, source_len
    str x1, [x2]
    ret

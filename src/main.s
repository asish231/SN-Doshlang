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
    LOAD_ADDR x2, op_count
    str x1, [x2]
    LOAD_ADDR x2, current_loop_start
    str x1, [x2]
    LOAD_ADDR x2, current_loop_end
    str x1, [x2]
    LOAD_ADDR x2, loop_context_depth
    str x1, [x2]
    LOAD_ADDR x2, var_scope_base
    str x1, [x2]

    // Initialize module system
    bl _init_default_search_paths

    bl _parse_program
    cbnz x0, Lmain_fail

    // Auto-call main() if it was defined
    LOAD_ADDR x9, fn_count
    ldr x9, [x9]
    cbz x9, Lmain_no_main_fn

    // Look up "main"
    LOAD_ADDR x0, kw_main
    bl _cstring_length
    mov x1, x0
    LOAD_ADDR x0, kw_main
    bl _lookup_function
    cbz x0, Lmain_no_main_fn
    // x1 = fn index
    mov x19, x1

    // Save current cursor
    LOAD_ADDR x9, cursor_pos
    ldr x20, [x9]

    // Clear return flag
    LOAD_ADDR x9, fn_return_flag
    str xzr, [x9]

    // Jump cursor to function body
    LOAD_ADDR x9, fn_body_cursors
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, cursor_pos
    str x10, [x9]
    LOAD_ADDR x9, fn_body_lines
    ldr x10, [x9, x19, lsl #3]
    LOAD_ADDR x9, current_line
    str x10, [x9]

    // Execute function body
Lmain_fn_body_loop:
    LOAD_ADDR x9, fn_return_flag
    ldr x10, [x9]
    cbnz x10, Lmain_fn_body_done

    bl _skip_whitespace
    bl _peek_char
    cmp w0, #'}'
    b.eq Lmain_fn_body_done
    cbz w0, Lmain_fail

    bl _parse_statement
    cbz x0, Lmain_fn_body_loop
    cmp x0, #4 // return
    b.eq Lmain_fn_body_done
    b Lmain_fail

Lmain_fn_body_done:
    // Clear return flag
    LOAD_ADDR x9, fn_return_flag
    str xzr, [x9]

Lmain_no_main_fn:
    bl _emit_program

    mov w0, #0
    bl _exit

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

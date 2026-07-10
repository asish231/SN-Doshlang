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
    b Lmain_exit_failure

Lmain_have_input:
    ldr x0, [x20, #8]
    
    // Check for --version or -v flag
    mov x21, x0                    // Save filename pointer
    bl _cstring_length             // Get length of arg
    cmp x0, #9                     // Length of "--version"
    b.ne Lcheck_short_version
    
    // Check if arg is "--version"
    mov x0, x21
    LOAD_ADDR x1, version_flag
    bl _cstring_equal
    cbz x0, Lcheck_short_version
    b Lprint_version

Lcheck_short_version:
    mov x0, x21
    bl _cstring_length
    cmp x0, #2                     // Length of "-v"
    b.ne Lmain_load_file
    
    // Check if arg is "-v"
    mov x0, x21
    LOAD_ADDR x1, short_version_flag
    bl _cstring_equal
    cbz x0, Lmain_load_file

Lprint_version:
    LOAD_ADDR x0, msg_version
    mov x1, #1
    bl _write_cstr_fd
    b Lmain_exit_success

Lmain_load_file:
    mov x0, x21
    bl _load_file
    cmp x0, #0
    b.lt Lmain_fail
    mov x19, x0

    LOAD_TBL x0, buffer
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

    // Also search for modules next to the source file being compiled, so
    // `use foo` finds a sibling foo.sn regardless of the working directory.
    mov x0, x21
    bl _add_source_dir_search_path

    // Allocate the initial (growable, malloc-backed) op, print/data, variable
    // and function tables before anything is recorded/defined. Capacity starts
    // at 0, so these first grows allocate SNC_MAX_OPS / SNC_MAX_PRINTS /
    // SNC_MAX_VARS / SNC_MAX_FUNCS entries; the record/define paths grow
    // (realloc-double) further on demand.
    bl _snc_grow_ops
    bl _snc_grow_prints
    bl _snc_grow_vars
    bl _snc_grow_fns
    // Allocate the initial (SNC_MAX_LIST_ELEMS / SNC_MAX_MAP_ELEMS) list and map
    // element pools. The grow routines also ZERO the freshly-allocated buffers,
    // which the codegen relies on (the old .space pools were zero-initialized).
    bl _snc_grow_list_pool
    bl _snc_grow_map_pool

    bl _parse_program
    cbnz x0, Lmain_fail

    // Save global op count (ops recorded during _parse_program)
    LOAD_ADDR x0, op_count
    ldr x0, [x0]
    LOAD_ADDR x1, global_op_count
    str x0, [x1]

    // Now parse all defined functions. fn_count is RE-READ every iteration:
    // parsing a body can register NESTED `fn` definitions (appended to the
    // table), and those bodies must be compiled too.
    LOAD_ADDR x19, fn_count
    mov x21, #0
Lmain_parse_fns_loop:
    ldr x20, [x19]
    cmp x21, x20
    b.ge Lmain_parse_fns_done
    
    mov x0, x21
    bl _parse_function_body
    cbnz x0, Lmain_fail
    add x21, x21, #1
    b Lmain_parse_fns_loop
Lmain_parse_fns_done:


    bl _emit_program

Lmain_exit_success:
    bl _snc_free_compiler_tables
    mov w0, #0
    bl _exit

Lmain_no_main_fn:


Lmain_fail:
Lmain_exit_failure:
    bl _snc_free_compiler_tables
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

    mov x19, x0                // fd
    mov x20, #0                // bytes read so far
    // Ensure the growable source buffer is allocated (grow from 0 => initial cap).
    LOAD_TBL x21, buffer
    cbnz x21, Lread_have_buf
    bl _snc_grow_src
    LOAD_TBL x21, buffer
Lread_have_buf:

Lread_loop:
     // Remaining space = current capacity (content bytes) - bytes read so far.
     LOAD_ADDR x22, src_buffer_cap
     ldr x22, [x22]
     sub x22, x22, x20
     cbnz x22, Lread_space_ok
     // Buffer full: grow it (realloc-double) instead of truncating, then reload
     // the (possibly moved) base and recompute the remaining space.
     bl _snc_grow_src
     LOAD_TBL x21, buffer
     LOAD_ADDR x22, src_buffer_cap
     ldr x22, [x22]
     sub x22, x22, x20
Lread_space_ok:
     mov x0, x19
     add x1, x21, x20
     mov x2, x22
     bl _read
     // read() returns bytes read (>0), 0 at EOF, or <0 on error. CBZ/B.cond
     // must be driven by an explicit CMP: a bare `cbz x0` does NOT set the
     // condition flags, so a following `b.lt` would test whatever NZCV libc's
     // read() happened to leave (it sets N=1 even on success), spuriously
     // taking the failure path. Compare x0 to 0 first, then branch.
     cmp x0, #0
     b.lt Lread_failed
     b.eq Lread_done
     add x20, x20, x0
     b Lread_loop

Lread_done:
    LOAD_TBL x21, buffer       // reload base (buffer may have grown during read)
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

// Compare two null-terminated C strings
// Returns 1 if equal, 0 if not
// x0 = first string, x1 = second string
_cstring_equal:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0        // First string
    mov x20, x1        // Second string

Lcstring_eq_loop:
    ldrb w9, [x19]     // Load byte from first
    ldrb w10, [x20]    // Load byte from second
    cmp w9, w10
    b.ne Lcstring_eq_no
    cbz w9, Lcstring_eq_yes   // If both are null, strings are equal
    add x19, x19, #1
    add x20, x20, #1
    b Lcstring_eq_loop

Lcstring_eq_yes:
    mov x0, #1
    b Lcstring_eq_return

Lcstring_eq_no:
    mov x0, #0

Lcstring_eq_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

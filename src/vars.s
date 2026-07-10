#include "platform.inc"
 .text
 .align 4
 .global _define_variable
 .global _set_variable
 .global _lookup_variable
 .global _set_variable_full
 .global _record_print_value
 .global _record_data_value
.global _record_store_variable
.global _record_print_variable
.global _record_operation
.global _record_operation2
.global _record_operation3
.global _record_operation4
.global _record_operation5
.global _snc_free_compiler_tables
.global _snc_compile_alloc
.global _snc_compile_free
.global _snc_compile_collect

_define_variable:
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
    mov x25, x3
    mov x26, x4
    mov x27, x5

    LOAD_ADDR x22, var_count
    ldr x23, [x22]
    // Grow the malloc-backed variable tables on demand instead of failing at a
    // fixed cap. x22 (&var_count) and x23 (index) are callee-saved and survive
    // the grow, as do the incoming args in x19,x20,x21,x25,x26,x27.
    LOAD_ADDR x24, var_capacity
    ldr x24, [x24]
    cmp x23, x24
    b.lt Ldefine_have_space
    bl _snc_grow_vars
Ldefine_have_space:

    LOAD_ADDR x24, var_scope_base
    ldr x24, [x24]
    cmp x23, x24
    b.eq Ldefine_store
    sub x28, x23, #1

    cmp x20, #0
    b.eq Ldefine_store
    b Ldefine_dup_loop

Ldefine_dup_loop:
    cmp x28, x24
    b.lt Ldefine_store

    LOAD_TBL x9, var_name_lens
    ldr x10, [x9, x28, lsl #3]
    cmp x10, x20
    b.ne Ldefine_dup_next

    LOAD_TBL x9, var_name_ptrs
    ldr x11, [x9, x28, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbnz x0, Ldefine_duplicate

Ldefine_dup_next:
    subs x28, x28, #1
    b Ldefine_dup_loop

Ldefine_store:

    LOAD_TBL x24, var_name_ptrs
    str x19, [x24, x23, lsl #3]
    LOAD_TBL x24, var_name_lens
    str x20, [x24, x23, lsl #3]
    LOAD_TBL x24, var_values
    str x21, [x24, x23, lsl #3]
    LOAD_TBL x24, var_const_flags
    str x25, [x24, x23, lsl #3]
    LOAD_TBL x24, var_types
    str x26, [x24, x23, lsl #3]
    LOAD_TBL x24, var_lengths
    str x27, [x24, x23, lsl #3]
    add x23, x23, #1
    str x23, [x22]
    
    LOAD_ADDR x24, max_var_count
    ldr x25, [x24]
    cmp x23, x25
    b.le Ldefine_success
    str x23, [x24]
Ldefine_success:
    mov x0, #0
    sub x4, x23, #1  // return the new var's index in x4
    b Ldefine_return

Ldefine_duplicate:
    LOAD_ADDR x0, msg_duplicate_var
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #1
    b Ldefine_return

Ldefine_full:
    LOAD_ADDR x0, msg_too_many_vars
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1

Ldefine_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_set_variable:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    LOAD_ADDR x23, var_count
    ldr x23, [x23]
    cbz x23, Lset_unknown
    sub x22, x23, #1

Lset_loop:
    cmp x22, #-1
    b.eq Lset_unknown

    LOAD_TBL x9, var_name_lens
    ldr x10, [x9, x22, lsl #3]
    cmp x10, x20
    b.ne Lset_next

    LOAD_TBL x9, var_name_ptrs
    ldr x11, [x9, x22, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbz x0, Lset_next

    LOAD_TBL x9, var_const_flags
    ldr x10, [x9, x22, lsl #3]
    cbnz x10, Lset_const

    LOAD_TBL x9, var_values
    str x21, [x9, x22, lsl #3]
    mov x0, #0
    b Lset_return

Lset_next:
    sub x22, x22, #1
    b Lset_loop

Lset_unknown:
    LOAD_ADDR x0, msg_unknown_var
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #1
    b Lset_return

Lset_const:
    LOAD_ADDR x0, msg_const_assign
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #1

Lset_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global _set_variable_metadata
_set_variable_metadata:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // name ptr
    mov x20, x1 // name len
    mov x21, x2 // metadata

    LOAD_ADDR x22, var_count
    ldr x22, [x22]
    cbz x22, Lset_meta_fail
    sub x22, x22, #1
Lset_meta_loop:
    cmp x22, #-1
    b.eq Lset_meta_fail
    LOAD_TBL x9, var_name_lens
    ldr x10, [x9, x22, lsl #3]
    cmp x10, x20
    b.ne Lset_meta_next
    LOAD_TBL x9, var_name_ptrs
    ldr x11, [x9, x22, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbnz x0, Lset_meta_found
Lset_meta_next:
    sub x22, x22, #1
    b Lset_meta_loop
Lset_meta_found:
    LOAD_TBL x9, var_lengths
    str x21, [x9, x22, lsl #3]
    mov x0, #0
    b Lset_meta_ret
Lset_meta_fail:
    mov x0, #1
Lset_meta_ret:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
_lookup_variable:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    LOAD_ADDR x22, var_count
    ldr x22, [x22]
    cbz x22, Llookup_fail
    sub x21, x22, #1

Llookup_loop:
    cmp x21, #-1
    b.eq Llookup_fail

    LOAD_TBL x9, var_name_lens
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x20
    b.ne Llookup_next

    LOAD_TBL x9, var_name_ptrs
    ldr x11, [x9, x21, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbz x0, Llookup_next

    LOAD_TBL x9, var_values
    ldr x1, [x9, x21, lsl #3]
    LOAD_TBL x9, var_types
    ldr x2, [x9, x21, lsl #3]
    LOAD_TBL x9, var_lengths
    ldr x3, [x9, x21, lsl #3]
    mov x4, x21
    mov x0, #1
    b Llookup_return

Llookup_next:
    sub x21, x21, #1
    b Llookup_loop

Llookup_fail:
    mov x0, #0
    mov x1, #0
    mov x4, #-1

Llookup_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_set_variable_full:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x25, x3
    mov x26, x4
    LOAD_ADDR x23, var_count
    ldr x23, [x23]
    cbz x23, Lset_full_unknown
    sub x22, x23, #1

Lset_full_loop:
    cmp x22, #-1
    b.eq Lset_full_unknown

    LOAD_TBL x9, var_name_lens
    ldr x10, [x9, x22, lsl #3]
    cmp x10, x20
    b.ne Lset_full_next

    LOAD_TBL x9, var_name_ptrs
    ldr x11, [x9, x22, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbz x0, Lset_full_next

    LOAD_TBL x9, var_const_flags
    ldr x10, [x9, x22, lsl #3]
    cbnz x10, Lset_full_const

    LOAD_TBL x9, var_values
    str x21, [x9, x22, lsl #3]
    LOAD_TBL x9, var_types
    str x25, [x9, x22, lsl #3]
    LOAD_TBL x9, var_lengths
    str x26, [x9, x22, lsl #3]
    mov x0, #0
    b Lset_full_return

Lset_full_next:
    sub x22, x22, #1
    b Lset_full_loop

Lset_full_unknown:
    LOAD_ADDR x0, msg_unknown_var
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #1
    b Lset_full_return

Lset_full_const:
    LOAD_ADDR x0, msg_const_assign
    bl _report_error_prefix
    mov x0, x19
    mov x1, x20
    mov x2, #2
    bl _write_buffer_fd
    bl _write_newline_stderr
    mov x0, #1

Lset_full_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_record_print_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // value
    mov x21, x1 // type
    mov x22, x2 // length
    LOAD_ADDR x20, print_count
    ldr x9, [x20]
    // Grow the malloc-backed print/data tables on demand instead of failing at
    // a fixed cap. x3 (the noline flag) is caller-saved, so save it across the
    // grow call; x20 (&print_count) is callee-saved and survives.
    LOAD_ADDR x10, print_capacity
    ldr x10, [x10]
    cmp x9, x10
    b.lt Lrecord_pv_have_space
    str x3, [sp, #-16]!
    bl _snc_grow_prints
    ldr x3, [sp], #16
    ldr x9, [x20]
Lrecord_pv_have_space:

    // print_* are now POINTERS to heap buffers, so deref before indexing.
    LOAD_ADDR x10, print_values
    ldr x10, [x10]
    str x19, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_types
    ldr x10, [x10]
    str x21, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_lengths
    ldr x10, [x10]
    str x22, [x10, x9, lsl #3]
    // Store noline flag (x3) - use strb for single byte
    LOAD_ADDR x10, print_noline
    ldr x10, [x10]
    strb w3, [x10, x9]
    mov x19, x9
    add x9, x9, #1
    str x9, [x20]
    mov x0, x19
    bl _record_operation_print_value
    mov x0, #0
    b Lrecord_print_return

// Record a literal into the print/data table without emitting a print operation.
// Returns id in x0 (same id space as print_value labels in emitted .data).
_record_data_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // value
    mov x21, x1 // type
    mov x22, x2 // length
    LOAD_ADDR x20, print_count
    ldr x9, [x20]
    // Grow the malloc-backed print/data tables on demand instead of failing at
    // a fixed cap (x20 = &print_count is callee-saved and survives the grow).
    LOAD_ADDR x10, print_capacity
    ldr x10, [x10]
    cmp x9, x10
    b.lt Lrecord_dv_have_space
    bl _snc_grow_prints
    ldr x9, [x20]
Lrecord_dv_have_space:

    // print_* are now POINTERS to heap buffers, so deref before indexing.
    LOAD_ADDR x10, print_values
    ldr x10, [x10]
    str x19, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_types
    ldr x10, [x10]
    str x21, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_lengths
    ldr x10, [x10]
    str x22, [x10, x9, lsl #3]
    mov x0, x9
    add x9, x9, #1
    str x9, [x20]
    b Lrecord_data_return

Lrecord_data_full:
    LOAD_ADDR x0, msg_too_many_prints
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #-1

Lrecord_data_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lrecord_print_full:
    LOAD_ADDR x0, msg_too_many_prints
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1

Lrecord_print_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_record_store_variable:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x0, #1
    mov x1, x19
    mov x2, x20
    bl _record_operation

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_record_print_variable:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x0, #2
    mov x1, x19
    mov x2, x20
    bl _record_operation

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_record_operation_print_value:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x1, x0
    mov x0, #0
    mov x2, #0
    bl _record_operation
    ldp x29, x30, [sp], #16
    ret

_record_operation:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!   // preserve x25/x26 (x25 is op arg4 AND callers'
                                // callee-saved state, e.g. for-in loop-var name len)

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, #0
    mov x24, #0
    mov x25, #0
    b Lrecord_operation_common

_record_operation2:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    
    mov x19, x0
    mov x20, x1
    mov x21, #-1
    mov x22, #-1
    mov x24, #-1
    mov x25, #-1
    b Lrecord_operation_common

_record_operation4:
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
    mov x24, x4
    b Lrecord_operation_common

_record_operation5:
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
    mov x24, x4
    mov x25, x5
    b Lrecord_operation_common

_record_operation3:
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
    mov x24, #0

Lrecord_operation_common:
#ifndef _WIN32
    // NOTE: use a scratch register (x15) for the spawn id. This used to
    // load into x26 WITHOUT saving it, silently clobbering callers'
    // callee-saved state (e.g. the for-in unroll index) on every recorded
    // op -- which made for-in loops re-iterate forever at compile time.
    LOAD_ADDR x15, spawn_capture_fn_id
    ldr x15, [x15]
    // spawn_capture_fn_id == -1 means "not capturing" (normal recording).
    // A non-negative value means we are capturing a spawned function body,
    // so ONLY then should the op be routed to the spawn tables.
    cmn x15, #1
    b.ne Lrecord_spawn_op
#endif
    LOAD_ADDR x23, op_count
    ldr x9, [x23]
    // Grow the malloc-backed op tables on demand instead of hard-failing at a
    // fixed cap. When op_count reaches the current capacity, _snc_grow_ops
    // realloc-doubles all six parallel arrays (it preserves x19-x25 and x23,
    // the op being recorded plus &op_count), then we reload the count.
    LOAD_ADDR x10, op_capacity
    ldr x10, [x10]
    cmp x9, x10
    b.lt Lrecord_op_have_space
    bl _snc_grow_ops
    ldr x9, [x23]
Lrecord_op_have_space:

    // op_kinds/op_arg* are now POINTERS to heap buffers, so deref before index.
    LOAD_ADDR x10, op_kinds
    ldr x10, [x10]
    str x19, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg0
    ldr x10, [x10]
    str x20, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg1
    ldr x10, [x10]
    str x21, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg2
    ldr x10, [x10]
    str x22, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg3
    ldr x10, [x10]
    str x24, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg4
    ldr x10, [x10]
    str x25, [x10, x9, lsl #3]
    add x9, x9, #1
    str x9, [x23]
    mov x0, #0
    b Lrecord_op_return

Lrecord_op_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lrecord_op_full:
    LOAD_ADDR x0, msg_too_many_ops
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit
    ret

#ifndef _WIN32
Lrecord_spawn_op:
    LOAD_ADDR x8, spawn_fn_op_counts
    ldr x9, [x8, x15, lsl #3]
    cmp x9, #256
    b.ge Lrecord_spawn_op_full
    mov x11, #256
    mul x11, x15, x11
    add x11, x11, x9
    LOAD_ADDR x10, spawn_fn_op_kinds
    str x19, [x10, x11, lsl #3]
    LOAD_ADDR x10, spawn_fn_op_arg0
    str x20, [x10, x11, lsl #3]
    LOAD_ADDR x10, spawn_fn_op_arg1
    str x21, [x10, x11, lsl #3]
    LOAD_ADDR x10, spawn_fn_op_arg2
    str x22, [x10, x11, lsl #3]
    LOAD_ADDR x10, spawn_fn_op_arg3
    str x24, [x10, x11, lsl #3]
    LOAD_ADDR x10, spawn_fn_op_arg4
    str x25, [x10, x11, lsl #3]
    add x9, x9, #1
    str x9, [x8, x15, lsl #3]
    mov x0, #0
    b Lrecord_op_return

Lrecord_spawn_op_full:
    LOAD_ADDR x0, msg_spawn_ops
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit
    ret
#endif

.global _snc_grow_fns
// --------------------------------------------------------------------------
// Grow the malloc-backed function tables. All 27 parallel arrays grow together:
// eighteen 8-byte/entry tables, eight 32-byte/entry tables (4 param slots per
// function), and the 64-byte/entry synthetic method-name storage. Doubles the
// current capacity, or allocates the initial SNC_MAX_FUNCS entries when the
// capacity is 0, preserving existing contents via realloc, then updates
// fn_capacity. fn_blueprint_ids and fn_module_ids default to -1 for every new
// entry.
//
// Register contract: callers keep live function ids and parse state in
// callee-saved registers and/or reload fn_count after the call. This routine
// saves/restores any callee-saved registers it uses; libc _realloc preserves
// callee-saved registers too, so caller state survives. On allocation failure
// it prints "too many functions" and exits.
// --------------------------------------------------------------------------
_snc_grow_fns:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    LOAD_ADDR x19, fn_capacity
    ldr x20, [x19]             // old capacity (entries)
    lsl x21, x20, #1           // new capacity = old * 2
    cbnz x20, Lgrow_fns_have_cap
    mov x21, #SNC_MAX_FUNCS    // first allocation: initial capacity
Lgrow_fns_have_cap:
    lsl x22, x21, #3           // 8-byte arrays: bytes = new_cap * 8
    lsl x24, x21, #5           // 32-byte arrays: bytes = new_cap * 32
    lsl x25, x21, #6           // 64-byte arrays: bytes = new_cap * 64

    LOAD_ADDR x23, fn_name_ptrs
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_name_lens
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_body_cursors
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_body_lines
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_source_ptrs
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_source_lens
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_counts
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_return_types
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_op_starts
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_op_counts
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_return_decl_lengths
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_return_extra_types
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_return_extra_decl_lengths
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_blueprint_ids
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]
    mov x27, x0
    mov x26, x20
    mov x28, #-1
Lgrow_fns_fill_bp_loop:
    cmp x26, x21
    b.ge Lgrow_fns_fill_bp_done
    str x28, [x27, x26, lsl #3]
    add x26, x26, #1
    b Lgrow_fns_fill_bp_loop
Lgrow_fns_fill_bp_done:

    LOAD_ADDR x23, fn_module_ids
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]
    mov x27, x0
    mov x26, x20
    mov x28, #-1
Lgrow_fns_fill_module_loop:
    cmp x26, x21
    b.ge Lgrow_fns_fill_module_done
    str x28, [x27, x26, lsl #3]
    add x26, x26, #1
    b Lgrow_fns_fill_module_loop
Lgrow_fns_fill_module_done:

    LOAD_ADDR x23, fn_import_visible
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]
    mov x26, x20
Lgrow_fns_fill_visibility_loop:
    cmp x26, x21
    b.ge Lgrow_fns_fill_visibility_done
    str xzr, [x0, x26, lsl #3]
    add x26, x26, #1
    b Lgrow_fns_fill_visibility_loop
Lgrow_fns_fill_visibility_done:

    LOAD_ADDR x23, fn_scope_bases
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_frame_sizes
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_types
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_lengths
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_name_ptrs
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_name_lens
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_default_flags
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_default_values
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_default_types
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, fn_param_default_lengths
    ldr x0, [x23]
    mov x1, x24
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    LOAD_ADDR x23, method_name_storage
    ldr x0, [x23]
    mov x1, x25
    bl _realloc
    cbz x0, Lgrow_fns_fail
    str x0, [x23]

    str x21, [x19]             // fn_capacity = new_cap

    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lgrow_fns_fail:
    LOAD_ADDR x0, msg_too_many_fns
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit

.global _snc_grow_ops
// --------------------------------------------------------------------------
// Grow the malloc-backed op tables (op_kinds + op_arg0..op_arg4). Doubles the
// current capacity, or allocates the initial SNC_MAX_OPS entries when capacity
// is 0, preserving existing contents via realloc. All six parallel arrays grow
// together and op_capacity is updated. This replaces the old fixed "too many
// operations" cap so the recorded op stream grows on demand.
//
// Register contract: _record_operation calls this while holding the op being
// recorded live in x19,x20,x21,x22,x24,x25 and &op_count in x23. This routine
// saves/restores x19-x24 and never touches x25, and libc _realloc preserves
// callee-saved registers, so all of the caller's live state survives. On
// allocation failure it prints "too many operations" and exits (the same fatal
// outcome the old fixed cap had, but now only if the machine is truly out of
// memory).
// --------------------------------------------------------------------------
_snc_grow_ops:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    LOAD_ADDR x19, op_capacity
    ldr x20, [x19]              // old capacity (entries)
    lsl x21, x20, #1           // new capacity = old * 2
    cbnz x20, Lgrow_ops_have_cap
    mov x21, #SNC_MAX_OPS       // first allocation: initial capacity
Lgrow_ops_have_cap:
    lsl x22, x21, #3           // new size in bytes = new_cap * 8

    LOAD_ADDR x23, op_kinds
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_ops_fail
    str x0, [x23]

    LOAD_ADDR x23, op_arg0
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_ops_fail
    str x0, [x23]

    LOAD_ADDR x23, op_arg1
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_ops_fail
    str x0, [x23]

    LOAD_ADDR x23, op_arg2
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_ops_fail
    str x0, [x23]

    LOAD_ADDR x23, op_arg3
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_ops_fail
    str x0, [x23]

    LOAD_ADDR x23, op_arg4
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_ops_fail
    str x0, [x23]

    str x21, [x19]             // op_capacity = new_cap

    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lgrow_ops_fail:
    LOAD_ADDR x0, msg_too_many_ops
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit

.global _snc_grow_prints
// --------------------------------------------------------------------------
// Grow the malloc-backed print/data tables. print_values/print_lengths/
// print_types are 8 bytes/entry; print_noline is 1 byte/entry. Doubles the
// current capacity (or allocates the initial SNC_MAX_PRINTS entries when 0),
// preserving contents via realloc. Uses only its own saved registers (x19-x24)
// and libc _realloc preserves callee-saved registers, so callers' live values
// survive. On failure it prints "too many print statements" and exits.
// --------------------------------------------------------------------------
_snc_grow_prints:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    LOAD_ADDR x19, print_capacity
    ldr x20, [x19]             // old capacity (entries)
    lsl x21, x20, #1           // new capacity = old * 2
    cbnz x20, Lgrow_pr_have_cap
    mov x21, #SNC_MAX_PRINTS    // first allocation: initial capacity
Lgrow_pr_have_cap:
    lsl x22, x21, #3           // 8-byte arrays: bytes = new_cap * 8

    LOAD_ADDR x23, print_values
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_pr_fail
    str x0, [x23]

    LOAD_ADDR x23, print_lengths
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_pr_fail
    str x0, [x23]

    LOAD_ADDR x23, print_types
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_pr_fail
    str x0, [x23]

    // print_noline: 1 byte per entry (bytes = new_cap * 1)
    LOAD_ADDR x23, print_noline
    ldr x0, [x23]
    mov x1, x21
    bl _realloc
    cbz x0, Lgrow_pr_fail
    str x0, [x23]

    str x21, [x19]             // print_capacity = new_cap

    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lgrow_pr_fail:
    LOAD_ADDR x0, msg_too_many_prints
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit

.global _snc_grow_list_pool
// --------------------------------------------------------------------------
// Grow the malloc-backed list element pools. list_pool_values/list_pool_lengths/
// list_base_counts are 8 bytes/entry; list_base_is_runtime is 1 byte/entry.
// Doubles the current capacity, or allocates the initial SNC_MAX_LIST_ELEMS
// entries when capacity is 0, preserving existing contents via realloc, then
// updates list_pool_capacity. CRITICALLY it ZEROES every newly-added entry in
// [old_cap, new_cap) of each array: realloc does NOT zero new memory, but the
// old fixed .space pools were zero-initialized and codegen relies on that
// (reserved-but-unfilled split slots, non-base count slots, and the default
// list_base_is_runtime[base]=0 "not runtime-mutated" flag). Saves/restores
// x19-x24 only and never touches x25-x28; libc _realloc preserves callee-saved
// registers, so callers keep their live state (Llist_store holds its value/length
// in x23/x25, the split reserve holds its base in x23). On OOM it exits.
// --------------------------------------------------------------------------
_snc_grow_list_pool:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    LOAD_ADDR x19, list_pool_capacity
    ldr x20, [x19]             // old capacity (entries)
    lsl x21, x20, #1           // new capacity = old * 2
    cbnz x20, Lgrow_lp_have_cap
    mov x21, #SNC_MAX_LIST_ELEMS // first allocation: initial capacity
Lgrow_lp_have_cap:
    lsl x22, x21, #3           // 8-byte arrays: bytes = new_cap * 8

    // list_pool_values (8 bytes/entry) + zero [old_cap, new_cap)
    LOAD_ADDR x23, list_pool_values
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_lp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_lp_zv:
    cmp x24, x21
    b.ge Lgrow_lp_zv_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_lp_zv
Lgrow_lp_zv_done:

    // list_pool_lengths (8 bytes/entry) + zero [old_cap, new_cap)
    LOAD_ADDR x23, list_pool_lengths
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_lp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_lp_zl:
    cmp x24, x21
    b.ge Lgrow_lp_zl_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_lp_zl
Lgrow_lp_zl_done:

    // list_base_counts (8 bytes/entry) + zero [old_cap, new_cap)
    LOAD_ADDR x23, list_base_counts
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_lp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_lp_zc:
    cmp x24, x21
    b.ge Lgrow_lp_zc_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_lp_zc
Lgrow_lp_zc_done:

    // list_base_is_runtime (1 byte/entry) + zero [old_cap, new_cap)
    LOAD_ADDR x23, list_base_is_runtime
    ldr x0, [x23]
    mov x1, x21               // 1-byte array: bytes = new_cap
    bl _realloc
    cbz x0, Lgrow_lp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_lp_zr:
    cmp x24, x21
    b.ge Lgrow_lp_zr_done
    strb wzr, [x0, x24]
    add x24, x24, #1
    b Lgrow_lp_zr
Lgrow_lp_zr_done:

    str x21, [x19]             // list_pool_capacity = new_cap

    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lgrow_lp_fail:
    mov x0, #1
    bl _exit

.global _snc_grow_map_pool
// --------------------------------------------------------------------------
// Grow the malloc-backed map element pools (map_pool_keys/map_pool_key_lengths/
// map_pool_key_ptrs/map_pool_values/map_pool_lengths, all 8 bytes/entry).
// Doubles capacity (or allocates the initial SNC_MAX_MAP_ELEMS entries when 0),
// preserving contents via realloc, then updates map_pool_capacity. ZEROES every
// newly-added entry in [old_cap, new_cap) of each array because codegen relies
// on the pool being zero-initialized (see _snc_grow_list_pool). Saves/restores
// x19-x24 only and never touches x25-x28; libc _realloc preserves callee-saved
// registers, so callers keep their live state (Lmap_store holds key/val data in
// x23-x28). On OOM it exits.
// --------------------------------------------------------------------------
_snc_grow_map_pool:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    LOAD_ADDR x19, map_pool_capacity
    ldr x20, [x19]             // old capacity (entries)
    lsl x21, x20, #1           // new capacity = old * 2
    cbnz x20, Lgrow_mp_have_cap
    mov x21, #SNC_MAX_MAP_ELEMS  // first allocation: initial capacity
Lgrow_mp_have_cap:
    lsl x22, x21, #3           // 8-byte arrays: bytes = new_cap * 8

    // map_pool_keys + zero [old_cap, new_cap)
    LOAD_ADDR x23, map_pool_keys
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_mp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_mp_zk:
    cmp x24, x21
    b.ge Lgrow_mp_zk_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_mp_zk
Lgrow_mp_zk_done:

    // map_pool_key_lengths + zero [old_cap, new_cap)
    LOAD_ADDR x23, map_pool_key_lengths
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_mp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_mp_zkl:
    cmp x24, x21
    b.ge Lgrow_mp_zkl_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_mp_zkl
Lgrow_mp_zkl_done:

    // map_pool_key_ptrs + zero [old_cap, new_cap)
    LOAD_ADDR x23, map_pool_key_ptrs
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_mp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_mp_zkp:
    cmp x24, x21
    b.ge Lgrow_mp_zkp_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_mp_zkp
Lgrow_mp_zkp_done:

    // map_pool_values + zero [old_cap, new_cap)
    LOAD_ADDR x23, map_pool_values
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_mp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_mp_zv:
    cmp x24, x21
    b.ge Lgrow_mp_zv_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_mp_zv
Lgrow_mp_zv_done:

    // map_pool_lengths + zero [old_cap, new_cap)
    LOAD_ADDR x23, map_pool_lengths
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_mp_fail
    str x0, [x23]
    mov x24, x20
Lgrow_mp_zvl:
    cmp x24, x21
    b.ge Lgrow_mp_zvl_done
    str xzr, [x0, x24, lsl #3]
    add x24, x24, #1
    b Lgrow_mp_zvl
Lgrow_mp_zvl_done:

    str x21, [x19]             // map_pool_capacity = new_cap

    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lgrow_mp_fail:
    mov x0, #1
    bl _exit

.global _snc_grow_src
// --------------------------------------------------------------------------
// Grow (or first-allocate) the malloc-backed source input buffer. src_buffer_cap
// holds the current CONTENT-byte capacity (excluding the trailing NUL). This
// doubles it (or sets it to SNC_SRC_BYTES-1 on the first call when 0) and
// reallocs `buffer` to cap+1 bytes, preserving contents. Replaces the old fixed
// .space source buffer that truncated input beyond 1 MB; the compiler can now
// read a source file of any size. On OOM it prints msg_read_error and exits.
// Saves/restores x19,x20; libc _realloc preserves callee-saved regs, so callers
// (only _read_into_buffer, which reloads the base afterwards) are unaffected.
// --------------------------------------------------------------------------
_snc_grow_src:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    LOAD_ADDR x19, src_buffer_cap
    ldr x20, [x19]             // old content-byte capacity
    lsl x1, x20, #1           // new cap = old * 2
    cbnz x20, Lgrow_src_have
    mov x1, #SNC_SRC_BYTES
    sub x1, x1, #1            // first allocation: initial cap = SNC_SRC_BYTES - 1
Lgrow_src_have:
    str x1, [x19]             // src_buffer_cap = new cap
    mov x20, x1               // keep new cap
    LOAD_ADDR x9, buffer
    ldr x0, [x9]              // current buffer ptr (0 => realloc acts as malloc)
    add x1, x20, #1           // bytes = cap + 1 (room for the NUL terminator)
    bl _realloc
    cbz x0, Lgrow_src_fail
    LOAD_ADDR x9, buffer
    str x0, [x9]

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lgrow_src_fail:
    LOAD_ADDR x0, msg_open_error
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit

.global _snc_grow_vars
// --------------------------------------------------------------------------
// Grow the malloc-backed variable tables (var_name_ptrs/var_name_lens/
// var_values/var_lengths/var_const_flags/var_types). All six are 8 bytes/entry
// and grow together. Doubles the current capacity, or allocates the initial
// SNC_MAX_VARS entries when capacity is 0, preserving existing contents via
// realloc, then updates var_capacity. This replaces the old fixed "too many
// variables" cap so the variable table grows on demand.
//
// Register contract: callers (_define_variable, _allocate_temp_var, the hidden
// -var path) keep their live state in callee-saved registers (x19-x28) and/or
// reload from var_count after the call. This routine saves/restores x19-x24 and
// never touches x25-x28; libc _realloc preserves callee-saved registers, so all
// caller state in x19-x28 survives. On allocation failure it prints "too many
// variables" and exits (only reachable if the machine is truly out of memory).
// --------------------------------------------------------------------------
_snc_grow_vars:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    LOAD_ADDR x19, var_capacity
    ldr x20, [x19]             // old capacity (entries)
    lsl x21, x20, #1           // new capacity = old * 2
    cbnz x20, Lgrow_vars_have_cap
    mov x21, #SNC_MAX_VARS      // first allocation: initial capacity
Lgrow_vars_have_cap:
    lsl x22, x21, #3           // 8-byte arrays: bytes = new_cap * 8

    LOAD_ADDR x23, var_name_ptrs
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_vars_fail
    str x0, [x23]

    LOAD_ADDR x23, var_name_lens
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_vars_fail
    str x0, [x23]

    LOAD_ADDR x23, var_values
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_vars_fail
    str x0, [x23]

    LOAD_ADDR x23, var_lengths
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_vars_fail
    str x0, [x23]

    LOAD_ADDR x23, var_const_flags
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_vars_fail
    str x0, [x23]

    LOAD_ADDR x23, var_types
    ldr x0, [x23]
    mov x1, x22
    bl _realloc
    cbz x0, Lgrow_vars_fail
    str x0, [x23]

    // hidden_var_name_storage is 32 bytes/entry (indexed by the global var
    // index) and grows in lockstep, so any var index past the old cap has valid
    // name storage. new_cap is in x21; bytes = new_cap * 32.
    LOAD_ADDR x23, hidden_var_name_storage
    ldr x0, [x23]
    lsl x1, x21, #5
    bl _realloc
    cbz x0, Lgrow_vars_fail
    str x0, [x23]

    str x21, [x19]             // var_capacity = new_cap

    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

Lgrow_vars_fail:
    LOAD_ADDR x0, msg_too_many_vars
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit

.global _allocate_temp_var
_allocate_temp_var:
    LOAD_ADDR x9, var_count
    ldr x0, [x9]
    // Grow the malloc-backed variable tables on demand instead of failing at a
    // fixed cap. Growing needs a frame for the call; afterwards x0/x9 are
    // reloaded from var_count (realloc clobbers caller-saved x0-x18).
    LOAD_ADDR x1, var_capacity
    ldr x1, [x1]
    cmp x0, x1
    b.lt Lalloc_temp_have_space
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl _snc_grow_vars
    ldp x29, x30, [sp], #16
    LOAD_ADDR x9, var_count
    ldr x0, [x9]
Lalloc_temp_have_space:
    add x1, x0, #1
    str x1, [x9]

    LOAD_ADDR x11, max_var_count
    ldr x12, [x11]
    cmp x1, x12
    b.le Lalloc_temp_meta
    str x1, [x11]

Lalloc_temp_meta:
    
    LOAD_TBL x10, var_types
    str xzr, [x10, x0, lsl #3]
    
    LOAD_TBL x10, var_lengths
    str xzr, [x10, x0, lsl #3]

    // CRITICAL: also clear this temp's NAME length and pointer. Previously
    // only var_types/var_lengths were zeroed, leaving var_name_lens/
    // var_name_ptrs holding stale garbage for the reused slot. When
    // _lookup_variable later scans every variable, a temp whose garbage
    // name length happened to equal the query length made it call
    // _match_span_span on a garbage name pointer -> intermittent SIGSEGV
    // (the "match_span_span" crashes seen in the example sweep). Zeroing
    // the name length makes a temp never match a real (non-empty) name
    // lookup, and _match_span_span never dereferences a zero-length span.
    LOAD_TBL x10, var_name_lens
    str xzr, [x10, x0, lsl #3]
    LOAD_TBL x10, var_name_ptrs
    str xzr, [x10, x0, lsl #3]
    ret

Lalloc_temp_full:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    LOAD_ADDR x0, msg_too_many_vars
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1
    bl _exit

// Compiler-lifetime arena for non-table allocations (module source buffers,
// copied names/search paths, and compile-time generated strings). A 16-byte
// header links each allocation; individual free removes it from the list, and
// final collection releases everything that deliberately survived parsing.
_snc_compile_alloc:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    mov x19, x0
    cbnz x19, Lcompile_alloc_size_ok
    mov x19, #1
Lcompile_alloc_size_ok:
    adds x0, x19, #16
    b.cs Lcompile_alloc_fail
#ifdef _WIN32
    bl malloc
#else
    bl _malloc
#endif
    cbz x0, Lcompile_alloc_fail
    mov x20, x0
    str x19, [x20, #8]
    LOAD_ADDR x21, compiler_alloc_head
    ldr x9, [x21]
    str x9, [x20]
    str x20, [x21]
    add x0, x20, #16
    b Lcompile_alloc_done
Lcompile_alloc_fail:
    mov x0, #0
Lcompile_alloc_done:
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

_snc_compile_free:
    stp x29, x30, [sp, #-64]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    stp x21, x22, [sp, #32]
    str x23, [sp, #48]
    mov x19, x0
    cbz x19, Lcompile_free_not_found
    LOAD_ADDR x9, compiler_alloc_head
    ldr x20, [x9]
    mov x21, #0
Lcompile_free_scan:
    cbz x20, Lcompile_free_not_found
    add x22, x20, #16
    cmp x22, x19
    b.eq Lcompile_free_found
    mov x21, x20
    ldr x20, [x20]
    b Lcompile_free_scan
Lcompile_free_found:
    ldr x23, [x20]
    cbz x21, Lcompile_free_set_head
    str x23, [x21]
    b Lcompile_free_unlinked
Lcompile_free_set_head:
    str x23, [x9]
Lcompile_free_unlinked:
    mov x0, x20
#ifdef _WIN32
    bl free
#else
    bl _free
#endif
    mov x0, #1
    b Lcompile_free_done
Lcompile_free_not_found:
    mov x0, #0
Lcompile_free_done:
    ldr x23, [sp, #48]
    ldp x21, x22, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #64
    ret

_snc_compile_collect:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    str x21, [sp, #32]
    LOAD_ADDR x9, compiler_alloc_head
    ldr x19, [x9]
    str xzr, [x9]
    mov x20, #0
Lcompile_collect_loop:
    cbz x19, Lcompile_collect_done
    ldr x21, [x19]
    mov x0, x19
#ifdef _WIN32
    bl free
#else
    bl _free
#endif
    mov x19, x21
    add x20, x20, #1
    b Lcompile_collect_loop
Lcompile_collect_done:
    mov x0, x20
    ldr x21, [sp, #32]
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #48
    ret

// Release one malloc-backed table whose pointer is stored in the slot at x0.
// The slot is cleared after free, making the full cleanup routine idempotent.
Lfree_compiler_ptr_slot:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov x19, x0
    ldr x0, [x19]
    cbz x0, Lfree_compiler_ptr_done
#ifdef _WIN32
    bl free
#else
    bl _free
#endif
    str xzr, [x19]
Lfree_compiler_ptr_done:
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

// Free every growable compiler-owned table/pool and the source buffer. Module
// parser state and literal arenas are static or already released at their call
// sites. This runs on normal success and parse/codegen failure before exit.
_snc_free_compiler_tables:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    LOAD_ADDR x0, buffer
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x0, op_kinds
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, op_arg0
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, op_arg1
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, op_arg2
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, op_arg3
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, op_arg4
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x0, print_values
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, print_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, print_types
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, print_noline
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x0, var_name_ptrs
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, var_name_lens
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, var_values
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, var_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, var_const_flags
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, var_types
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, hidden_var_name_storage
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x0, fn_name_ptrs
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_name_lens
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_body_cursors
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_body_lines
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_source_ptrs
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_source_lens
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_counts
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_return_types
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_op_starts
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_op_counts
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_return_decl_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_return_extra_types
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_return_extra_decl_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_blueprint_ids
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_module_ids
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_import_visible
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_scope_bases
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_frame_sizes
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x0, fn_param_types
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_name_ptrs
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_name_lens
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_default_flags
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_default_values
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_default_types
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, fn_param_default_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, method_name_storage
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x0, list_pool_values
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, list_pool_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, list_base_counts
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, list_base_is_runtime
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x0, map_pool_keys
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, map_pool_key_lengths
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, map_pool_key_ptrs
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, map_pool_values
    bl Lfree_compiler_ptr_slot
    LOAD_ADDR x0, map_pool_lengths
    bl Lfree_compiler_ptr_slot

    LOAD_ADDR x9, src_buffer_cap
    str xzr, [x9]
    LOAD_ADDR x9, op_capacity
    str xzr, [x9]
    LOAD_ADDR x9, print_capacity
    str xzr, [x9]
    LOAD_ADDR x9, var_capacity
    str xzr, [x9]
    LOAD_ADDR x9, fn_capacity
    str xzr, [x9]
    LOAD_ADDR x9, list_pool_capacity
    str xzr, [x9]
    LOAD_ADDR x9, map_pool_capacity
    str xzr, [x9]

    bl _snc_compile_collect

    ldp x29, x30, [sp], #16
    ret

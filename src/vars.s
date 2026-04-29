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
.global _record_operation3
.global _record_operation4

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
    cmp x23, #512
    b.ge Ldefine_full

    LOAD_ADDR x24, var_scope_base
    ldr x24, [x24]
    cmp x23, x24
    b.eq Ldefine_store
    sub x28, x23, #1

Ldefine_dup_loop:
    cmp x28, x24
    b.lt Ldefine_store

    LOAD_ADDR x9, var_name_lens
    ldr x10, [x9, x28, lsl #3]
    cmp x10, x20
    b.ne Ldefine_dup_next

    LOAD_ADDR x9, var_name_ptrs
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

    LOAD_ADDR x24, var_name_ptrs
    str x19, [x24, x23, lsl #3]
    LOAD_ADDR x24, var_name_lens
    str x20, [x24, x23, lsl #3]
    LOAD_ADDR x24, var_values
    str x21, [x24, x23, lsl #3]
    LOAD_ADDR x24, var_const_flags
    str x25, [x24, x23, lsl #3]
    LOAD_ADDR x24, var_types
    str x26, [x24, x23, lsl #3]
    LOAD_ADDR x24, var_lengths
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

    LOAD_ADDR x9, var_name_lens
    ldr x10, [x9, x22, lsl #3]
    cmp x10, x20
    b.ne Lset_next

    LOAD_ADDR x9, var_name_ptrs
    ldr x11, [x9, x22, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbz x0, Lset_next

    LOAD_ADDR x9, var_const_flags
    ldr x10, [x9, x22, lsl #3]
    cbnz x10, Lset_const

    LOAD_ADDR x9, var_values
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

    LOAD_ADDR x9, var_name_lens
    ldr x10, [x9, x21, lsl #3]
    cmp x10, x20
    b.ne Llookup_next

    LOAD_ADDR x9, var_name_ptrs
    ldr x11, [x9, x21, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbz x0, Llookup_next

    LOAD_ADDR x9, var_values
    ldr x1, [x9, x21, lsl #3]
    LOAD_ADDR x9, var_types
    ldr x2, [x9, x21, lsl #3]
    LOAD_ADDR x9, var_lengths
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

    LOAD_ADDR x9, var_name_lens
    ldr x10, [x9, x22, lsl #3]
    cmp x10, x20
    b.ne Lset_full_next

    LOAD_ADDR x9, var_name_ptrs
    ldr x11, [x9, x22, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, x11
    bl _match_span_span
    cbz x0, Lset_full_next

    LOAD_ADDR x9, var_const_flags
    ldr x10, [x9, x22, lsl #3]
    cbnz x10, Lset_full_const

    LOAD_ADDR x9, var_values
    str x21, [x9, x22, lsl #3]
    LOAD_ADDR x9, var_types
    str x25, [x9, x22, lsl #3]
    LOAD_ADDR x9, var_lengths
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
    cmp x9, #2048
    b.ge Lrecord_print_full

    LOAD_ADDR x10, print_values
    str x19, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_types
    str x21, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_lengths
    str x22, [x10, x9, lsl #3]
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
    cmp x9, #2048
    b.ge Lrecord_data_full

    LOAD_ADDR x10, print_values
    str x19, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_types
    str x21, [x10, x9, lsl #3]
    LOAD_ADDR x10, print_lengths
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

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, #0
    b Lrecord_operation_common

_record_operation4:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x24, x4
    b Lrecord_operation_common

_record_operation3:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3
    mov x24, #0

Lrecord_operation_common:
    LOAD_ADDR x23, op_count
    ldr x9, [x23]
    cmp x9, #4096
    b.ge Lrecord_op_full

    LOAD_ADDR x10, op_kinds
    str x19, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg0
    str x20, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg1
    str x21, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg2
    str x22, [x10, x9, lsl #3]
    LOAD_ADDR x10, op_arg3
    str x24, [x10, x9, lsl #3]
    add x9, x9, #1
    str x9, [x23]
    mov x0, #0
    b Lrecord_op_return

Lrecord_op_full:
    LOAD_ADDR x0, msg_too_many_ops
    mov x1, #2
    bl _write_cstr_fd
    mov x0, #1

Lrecord_op_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global _allocate_temp_var
_allocate_temp_var:
    LOAD_ADDR x9, var_count
    ldr x0, [x9]
    add x1, x0, #1
    str x1, [x9]

    LOAD_ADDR x11, max_var_count
    ldr x12, [x11]
    cmp x1, x12
    b.le Lalloc_temp_meta
    str x1, [x11]

Lalloc_temp_meta:
    
    LOAD_ADDR x10, var_types
    str xzr, [x10, x0, lsl #3]
    
    LOAD_ADDR x10, var_lengths
    str xzr, [x10, x0, lsl #3]
    ret

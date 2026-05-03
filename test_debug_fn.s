.global _main
.align 4
.extern _printf
.extern _read
.extern _write
.extern _malloc
.extern _free
.extern _open
.extern _close
.extern _lseek
.extern _str_concat
.extern _int_to_cstr
.extern _file_read
.extern _file_write
.extern _pthread_create
.extern _pthread_join

.text
_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16
    sub sp, sp, #16
     bl getFive
    adrp x9, store_val_1@PAGE
    ldr x10, [x9, store_val_1@PAGEOFF]
    stur x10, [x29, #-8]

.global getFive
getFive:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov w0, #0
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret



.text
.align 4
.global _cstring_length
_cstring_length:
    mov x1, x0
    mov x0, #0
L_snl_strlen_loop:
    ldrb w9, [x1, x0]
    cbz w9, L_snl_strlen_done
    add x0, x0, #1
    b L_snl_strlen_loop
L_snl_strlen_done:
    ret

.align 4
.global _str_concat_len
_str_concat_len:
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

    add x0, x20, x22
    add x0, x0, #1
    bl _malloc
    cbz x0, L_snl_str_concat_len_fail
    mov x23, x0

    mov x24, #0
L_snl_str_concat_len_copy1:
    cmp x24, x20
    b.ge L_snl_str_concat_len_copy2_start
    ldrb w9, [x19, x24]
    strb w9, [x23, x24]
    add x24, x24, #1
    b L_snl_str_concat_len_copy1

L_snl_str_concat_len_copy2_start:
    mov x9, #0
L_snl_str_concat_len_copy2:
    cmp x9, x22
    b.ge L_snl_str_concat_len_done
    ldrb w10, [x21, x9]
    add x11, x24, x9
    strb w10, [x23, x11]
    add x9, x9, #1
    b L_snl_str_concat_len_copy2

L_snl_str_concat_len_done:
    add x11, x24, x22
    strb wzr, [x23, x11]
    mov x0, x23
    b L_snl_str_concat_len_return

L_snl_str_concat_len_fail:
    mov x0, #0

L_snl_str_concat_len_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _str_concat
_str_concat:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    mov x20, x1

    mov x0, x19
    bl _cstring_length
    mov x2, x0

    mov x0, x20
    bl _cstring_length
    mov x3, x0

    mov x0, x19
    mov x1, x2
    mov x2, x20
    bl _str_concat_len

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _int_to_cstr
_int_to_cstr:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x0, #32
    bl _malloc
    cbz x0, L_snl_int_to_cstr_fail
    mov x20, x0
    add x21, x20, #31
    strb wzr, [x21]
    sub x21, x21, #1

    mov x22, #0
    cmp x19, #0
    b.ge L_snl_int_to_cstr_abs_ready
    mov x22, #1
    neg x19, x19

L_snl_int_to_cstr_abs_ready:
    cbnz x19, L_snl_int_to_cstr_digits
    mov w9, #'0'
    strb w9, [x21]
    sub x21, x21, #1
    b L_snl_int_to_cstr_sign

L_snl_int_to_cstr_digits:
    mov x23, #10
L_snl_int_to_cstr_loop:
    udiv x24, x19, x23
    msub x9, x24, x23, x19
    add w9, w9, #'0'
    strb w9, [x21]
    sub x21, x21, #1
    mov x19, x24
    cbnz x19, L_snl_int_to_cstr_loop

L_snl_int_to_cstr_sign:
    cbz x22, L_snl_int_to_cstr_done
    mov w9, #'-'
    strb w9, [x21]
    sub x21, x21, #1

L_snl_int_to_cstr_done:
    add x0, x21, #1
    b L_snl_int_to_cstr_return

L_snl_int_to_cstr_fail:
    mov x0, #0
L_snl_int_to_cstr_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _file_read
_file_read:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x0, x19
    mov x1, #0
    bl _open
    cmp x0, #0
    b.lt L_snl_file_read_fail
    mov x20, x0

    mov x0, x20
    mov x1, #0
    mov x2, #2
    bl _lseek
    cmp x0, #0
    b.lt L_snl_file_read_fail_close
    mov x21, x0

    mov x0, x20
    mov x1, #0
    mov x2, #0
    bl _lseek

    add x0, x21, #1
    bl _malloc
    cbz x0, L_snl_file_read_fail_close
    mov x22, x0

    mov x0, x20
    mov x1, x22
    mov x2, x21
    bl _read

    add x9, x22, x21
    strb wzr, [x9]

    mov x0, x20
    bl _close

    mov x0, x22
    b L_snl_file_read_return

L_snl_file_read_fail_close:
    mov x0, x20
    bl _close
L_snl_file_read_fail:
    mov x0, #0
L_snl_file_read_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _file_write
_file_write:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2

    mov x0, x19
    mov x1, #0x601
    mov x2, #0644
    bl _open
    cmp x0, #0
    b.lt L_snl_file_write_fail
    mov x22, x0

    mov x0, x22
    mov x1, x20
    mov x2, x21
    bl _write

    mov x0, x22
    bl _close

    mov x0, #1
    b L_snl_file_write_return

L_snl_file_write_fail:
    mov x0, #0
L_snl_file_write_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _cstr_to_int
_cstr_to_int:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x1, x0
    mov x0, #0
    mov x2, #0
    ldrb w3, [x1]
    cmp w3, #'-'
    b.ne L_snl_cstr_to_int_loop
    mov x2, #1
    add x1, x1, #1
L_snl_cstr_to_int_loop:
    ldrb w3, [x1], #1
    cbz w3, L_snl_cstr_to_int_done
    sub w3, w3, #'0'
    cmp w3, #9
    b.hi L_snl_cstr_to_int_done
    mov x4, #10
    mul x0, x0, x4
    add x0, x0, x3
    b L_snl_cstr_to_int_loop
L_snl_cstr_to_int_done:
    cbz x2, L_snl_cstr_to_int_ret
    neg x0, x0
L_snl_cstr_to_int_ret:
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _runtime_match_span_span
_runtime_match_span_span:
    cbz x1, L_rmss_match
L_rmss_loop:
    ldrb w9, [x0], #1
    ldrb w10, [x2], #1
    cmp w9, w10
    b.ne L_rmss_fail
    sub x1, x1, #1
    cbnz x1, L_rmss_loop
L_rmss_match:
    mov x0, #1
    ret
L_rmss_fail:
    mov x0, #0
    ret

.align 4
.global _map_lookup
_map_lookup:
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
    mov x23, x4
    mov x24, #0
L_map_lookup_loop:
    cmp x24, x20
    b.ge L_map_lookup_fail
    add x25, x19, x24
    adrp x26, map_pool_keys@PAGE
    add x26, x26, map_pool_keys@PAGEOFF
    ldr x9, [x26, x25, lsl #3]
    cmp x22, #2
    b.eq L_map_lookup_str
    cmp x9, x21
    b.eq L_map_lookup_found
    b L_map_lookup_next
L_map_lookup_str:
    adrp x26, map_pool_key_lengths@PAGE
    add x26, x26, map_pool_key_lengths@PAGEOFF
    ldr x10, [x26, x25, lsl #3]
    cmp x10, x23
    b.ne L_map_lookup_next
    mov x0, x9
    mov x1, x10
    mov x2, x21
    bl _runtime_match_span_span
    cbnz x0, L_map_lookup_found
L_map_lookup_next:
    add x24, x24, #1
    b L_map_lookup_loop
L_map_lookup_found:
    adrp x26, map_pool_values@PAGE
    add x26, x26, map_pool_values@PAGEOFF
    ldr x19, [x26, x25, lsl #3]
    adrp x26, map_pool_lengths@PAGE
    add x26, x26, map_pool_lengths@PAGEOFF
    ldr x20, [x26, x25, lsl #3]
    mov x0, x19
    mov x1, x20
    mov x2, #1
    b L_map_lookup_ret
L_map_lookup_fail:
    mov x0, #0
    mov x1, #0
    mov x2, #0
L_map_lookup_ret:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.bss
.align 3
dyn_map_count:
    .quad 0
dyn_map_base:
    .space 8192
dyn_map_key:
    .space 8192
dyn_map_key_len:
    .space 8192
dyn_map_key_type:
    .space 8192
dyn_map_val:
    .space 8192
dyn_map_val_len:
    .space 8192
dyn_map_val_type:
    .space 8192

.text
.align 4
.global _map_lookup_ext
_map_lookup_ext:
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
    mov x22, x3
    mov x23, x4
    adrp x24, dyn_map_count@PAGE
    add x24, x24, dyn_map_count@PAGEOFF
    ldr x25, [x24]
    mov x26, #0
L_dyn_lookup_loop:
    cmp x26, x25
    b.ge L_dyn_lookup_miss
    adrp x24, dyn_map_base@PAGE
    add x24, x24, dyn_map_base@PAGEOFF
    ldr x27, [x24, x26, lsl #3]
    cmp x27, x19
    b.ne L_dyn_lookup_next
    adrp x24, dyn_map_key_type@PAGE
    add x24, x24, dyn_map_key_type@PAGEOFF
    ldr x27, [x24, x26, lsl #3]
    cmp x27, x22
    b.ne L_dyn_lookup_next
    cmp x22, #2
    b.eq L_dyn_lookup_cmp_str
    adrp x24, dyn_map_key@PAGE
    add x24, x24, dyn_map_key@PAGEOFF
    ldr x27, [x24, x26, lsl #3]
    cmp x27, x21
    b.eq L_dyn_lookup_found
    b L_dyn_lookup_next
L_dyn_lookup_cmp_str:
    adrp x24, dyn_map_key_len@PAGE
    add x24, x24, dyn_map_key_len@PAGEOFF
    ldr x27, [x24, x26, lsl #3]
    cmp x27, x23
    b.ne L_dyn_lookup_next
    adrp x24, dyn_map_key@PAGE
    add x24, x24, dyn_map_key@PAGEOFF
    ldr x0, [x24, x26, lsl #3]
    mov x1, x27
    mov x2, x21
    bl _runtime_match_span_span
    cbz x0, L_dyn_lookup_next
L_dyn_lookup_found:
    adrp x24, dyn_map_val@PAGE
    add x24, x24, dyn_map_val@PAGEOFF
    ldr x0, [x24, x26, lsl #3]
    adrp x24, dyn_map_val_len@PAGE
    add x24, x24, dyn_map_val_len@PAGEOFF
    ldr x1, [x24, x26, lsl #3]
    mov x2, #1
    b L_dyn_lookup_ret
L_dyn_lookup_next:
    add x26, x26, #1
    b L_dyn_lookup_loop
L_dyn_lookup_miss:
    mov x0, x19
    mov x1, x20
    mov x2, x21
    mov x3, x22
    mov x4, x23
    bl _map_lookup
L_dyn_lookup_ret:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _map_store
_map_store:
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
    mov x22, x3
    mov x23, x4
    mov x24, x5
    mov x25, x6
    adrp x26, dyn_map_count@PAGE
    add x26, x26, dyn_map_count@PAGEOFF
    ldr x27, [x26]
    mov x28, #0
L_dyn_store_find:
    cmp x28, x27
    b.ge L_dyn_store_append
    adrp x9, dyn_map_base@PAGE
    add x9, x9, dyn_map_base@PAGEOFF
    ldr x10, [x9, x28, lsl #3]
    cmp x10, x19
    b.ne L_dyn_store_next
    adrp x9, dyn_map_key_type@PAGE
    add x9, x9, dyn_map_key_type@PAGEOFF
    ldr x10, [x9, x28, lsl #3]
    cmp x10, x21
    b.ne L_dyn_store_next
    cmp x21, #2
    b.eq L_dyn_store_cmp_str
    adrp x9, dyn_map_key@PAGE
    add x9, x9, dyn_map_key@PAGEOFF
    ldr x10, [x9, x28, lsl #3]
    cmp x10, x20
    b.eq L_dyn_store_write
    b L_dyn_store_next
L_dyn_store_cmp_str:
    adrp x9, dyn_map_key_len@PAGE
    add x9, x9, dyn_map_key_len@PAGEOFF
    ldr x10, [x9, x28, lsl #3]
    cmp x10, x22
    b.ne L_dyn_store_next
    adrp x9, dyn_map_key@PAGE
    add x9, x9, dyn_map_key@PAGEOFF
    ldr x0, [x9, x28, lsl #3]
    mov x1, x10
    mov x2, x20
    bl _runtime_match_span_span
    cbnz x0, L_dyn_store_write
L_dyn_store_next:
    add x28, x28, #1
    b L_dyn_store_find
L_dyn_store_append:
    cmp x27, #1024
    b.ge L_dyn_store_ret
    mov x28, x27
    add x27, x27, #1
    str x27, [x26]
    adrp x9, dyn_map_base@PAGE
    add x9, x9, dyn_map_base@PAGEOFF
    str x19, [x9, x28, lsl #3]
    adrp x9, dyn_map_key@PAGE
    add x9, x9, dyn_map_key@PAGEOFF
    str x20, [x9, x28, lsl #3]
    adrp x9, dyn_map_key_len@PAGE
    add x9, x9, dyn_map_key_len@PAGEOFF
    str x22, [x9, x28, lsl #3]
    adrp x9, dyn_map_key_type@PAGE
    add x9, x9, dyn_map_key_type@PAGEOFF
    str x21, [x9, x28, lsl #3]
L_dyn_store_write:
    adrp x9, dyn_map_val@PAGE
    add x9, x9, dyn_map_val@PAGEOFF
    str x23, [x9, x28, lsl #3]
    adrp x9, dyn_map_val_len@PAGE
    add x9, x9, dyn_map_val_len@PAGEOFF
    str x25, [x9, x28, lsl #3]
    adrp x9, dyn_map_val_type@PAGE
    add x9, x9, dyn_map_val_type@PAGEOFF
    str x24, [x9, x28, lsl #3]
L_dyn_store_ret:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.align 4
.global _string_slice
_string_slice:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    mov x19, x0
    mov x20, x1
    mov x21, x2
    cbz x19, Lslice_empty
    cmp x20, #0
    b.ge Lslice_start_ok
    mov x20, #0
Lslice_start_ok:
    mov x0, x19
    bl _cstring_length
    mov x24, x0
    cmp x20, x24
    b.ge Lslice_empty
    cmp x21, x20
    b.ge Lslice_end_order_ok
    b Lslice_empty
Lslice_end_order_ok:
    cmp x21, x24
    b.le Lslice_end_clamped
    mov x21, x24
Lslice_end_clamped:
    sub x22, x21, x20
    cmp x22, #0
    b.le Lslice_empty
    add x0, x22, #1
    bl _malloc
    cbz x0, Lslice_ret
    mov x23, x0
    mov x24, #0
Lslice_copy:
    cmp x24, x22
    b.ge Lslice_done
    add x9, x19, x20
    ldrb w10, [x9, x24]
    strb w10, [x23, x24]
    add x24, x24, #1
    b Lslice_copy
Lslice_done:
    strb wzr, [x23, x22]
    mov x0, x23
    b Lslice_ret
Lslice_empty:
    mov x0, #1
    bl _malloc
    cbz x0, Lslice_ret
    strb wzr, [x0]
Lslice_ret:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
.data
print_fmt_int:
    .asciz "%lld\n"
print_fmt_str:
    .asciz "%s\n"
print_fmt_dec:
    .asciz "%s%lld.%0*lld\n"
print_fmt_int_noline:
    .asciz "%lld"
print_fmt_str_noline:
    .asciz "%s"
print_fmt_dec_noline:
    .asciz "%s%lld.%0*lld"
dec_sign_empty:
    .asciz ""
dec_sign_minus:
    .asciz "-"
.align 3
.align 3
store_val_1:
    .quad 5
.align 3
list_pool_values:
list_pool_lengths:
.align 3
map_pool_keys:
map_pool_key_lengths:
map_pool_values:
map_pool_lengths:
.align 3
error_flag:
    .quad 0
error_value:
    .quad 0

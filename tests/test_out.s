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

.text
_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #64
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_0@PAGE
    add x1, x1, print_val_0@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x9, store_val_1@PAGE
    ldr x10, [x9, store_val_1@PAGEOFF]
    stur x10, [x29, #-8]
    adrp x9, store_val_2@PAGE
    ldr x10, [x9, store_val_2@PAGEOFF]
    stur x10, [x29, #-16]
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_1@PAGE
    add x1, x1, print_val_1@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x9, store_val_4@PAGE
    ldr x10, [x9, store_val_4@PAGEOFF]
    stur x10, [x29, #-24]
    ldur x11, [x29, #-24]
    adrp x9, store_val_5@PAGE
    ldr x10, [x9, store_val_5@PAGEOFF]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-32]
    ldur x11, [x29, #-32]
    cbz x11, L_snl_1
    b L_snl_2
L_snl_1:
L_snl_2:
    adrp x0, print_fmt_int@PAGE
    add x0, x0, print_fmt_int@PAGEOFF
    adrp x9, print_val_2@PAGE
    ldr x1, [x9, print_val_2@PAGEOFF]
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_3@PAGE
    add x1, x1, print_val_3@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    ldur x10, [x29, #-48]
    stur x10, [x29, #-24]
    ldur x10, [x29, #-88]
    stur x10, [x29, #-32]
    ldur x11, [x29, #-24]
    ldur x10, [x29, #-32]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-40]
    ldur x11, [x29, #-40]
    cbz x11, L_snl_3
    b L_snl_4
L_snl_3:
L_snl_4:
    adrp x0, print_fmt_int@PAGE
    add x0, x0, print_fmt_int@PAGEOFF
    adrp x9, print_val_4@PAGE
    ldr x1, [x9, print_val_4@PAGEOFF]
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_5@PAGE
    add x1, x1, print_val_5@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    ldur x10, [x29, #-48]
    stur x10, [x29, #-24]
    ldur x10, [x29, #-88]
    stur x10, [x29, #-32]
    ldur x11, [x29, #-24]
    ldur x10, [x29, #-32]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-40]
    ldur x11, [x29, #-40]
    cbz x11, L_snl_5
    b L_snl_6
L_snl_5:
L_snl_6:
    adrp x0, print_fmt_int@PAGE
    add x0, x0, print_fmt_int@PAGEOFF
    adrp x9, print_val_6@PAGE
    ldr x1, [x9, print_val_6@PAGEOFF]
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_7@PAGE
    add x1, x1, print_val_7@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x9, store_val_27@PAGE
    ldr x10, [x9, store_val_27@PAGEOFF]
    stur x10, [x29, #-24]
    adrp x9, store_val_28@PAGE
    ldr x10, [x9, store_val_28@PAGEOFF]
    stur x10, [x29, #-32]
    adrp x9, store_val_29@PAGE
    ldr x10, [x9, store_val_29@PAGEOFF]
    stur x10, [x29, #-40]
    adrp x9, store_val_30@PAGE
    ldr x10, [x9, store_val_30@PAGEOFF]
    stur x10, [x29, #-48]
L_snl_7:
    ldur x11, [x29, #-48]
    ldur x10, [x29, #-32]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-56]
    ldur x11, [x29, #-56]
    cbz x11, L_snl_8
    ldur x11, [x29, #-40]
    ldur x10, [x29, #-24]
    mul x11, x11, x10
    stur x11, [x29, #-40]
    ldur x11, [x29, #-48]
    adrp x9, store_val_35@PAGE
    ldr x10, [x9, store_val_35@PAGEOFF]
    add x11, x11, x10
    stur x11, [x29, #-48]
    b L_snl_7
L_snl_8:
    adrp x0, print_fmt_int@PAGE
    add x0, x0, print_fmt_int@PAGEOFF
    adrp x9, print_val_8@PAGE
    ldr x1, [x9, print_val_8@PAGEOFF]
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_9@PAGE
    add x1, x1, print_val_9@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x9, store_val_39@PAGE
    ldr x10, [x9, store_val_39@PAGEOFF]
    stur x10, [x29, #-24]
    adrp x9, store_val_40@PAGE
    ldr x10, [x9, store_val_40@PAGEOFF]
    stur x10, [x29, #-32]
    adrp x9, store_val_41@PAGE
    ldr x10, [x9, store_val_41@PAGEOFF]
    stur x10, [x29, #-40]
    ldur x11, [x29, #-24]
    ldur x10, [x29, #-32]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-48]
    ldur x11, [x29, #-48]
    cbz x11, L_snl_9
    b L_snl_10
L_snl_9:
L_snl_10:
    ldur x11, [x29, #-24]
    ldur x10, [x29, #-40]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-56]
    ldur x11, [x29, #-56]
    cbz x11, L_snl_11
    b L_snl_12
L_snl_11:
L_snl_12:
    adrp x0, print_fmt_int@PAGE
    add x0, x0, print_fmt_int@PAGEOFF
    adrp x9, print_val_10@PAGE
    ldr x1, [x9, print_val_10@PAGEOFF]
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_11@PAGE
    add x1, x1, print_val_11@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x9, store_val_52@PAGE
    ldr x10, [x9, store_val_52@PAGEOFF]
    stur x10, [x29, #-24]
    ldur x11, [x29, #-24]
    adrp x9, store_val_53@PAGE
    ldr x10, [x9, store_val_53@PAGEOFF]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-32]
    ldur x11, [x29, #-32]
    cbz x11, L_snl_13
    b L_snl_14
L_snl_13:
L_snl_14:
    ldur x11, [x29, #-24]
    adrp x9, store_val_57@PAGE
    ldr x10, [x9, store_val_57@PAGEOFF]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-40]
    ldur x11, [x29, #-40]
    cbz x11, L_snl_15
    b L_snl_16
L_snl_15:
L_snl_16:
    adrp x0, print_fmt_int@PAGE
    add x0, x0, print_fmt_int@PAGEOFF
    adrp x9, print_val_12@PAGE
    ldr x1, [x9, print_val_12@PAGEOFF]
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    mov w0, #0
    mov sp, x29
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
print_val_0:
    .asciz "Testing Math Stdlib:"
.align 3
print_val_1:
    .asciz "abs(-10):"
.align 3
print_val_2:
    .quad 10
.align 3
print_val_3:
    .asciz "max(5, 10):"
.align 3
print_val_4:
    .quad 10
.align 3
print_val_5:
    .asciz "min(5, 10):"
.align 3
print_val_6:
    .quad 5
.align 3
print_val_7:
    .asciz "pow(2, 3):"
.align 3
print_val_8:
    .quad 2
.align 3
print_val_9:
    .asciz "clamp(15, 0, 10):"
.align 3
print_val_10:
    .quad 10
.align 3
print_val_11:
    .asciz "sign(-42):"
.align 3
print_val_12:
    .quad 18446744073709551615
.align 3
store_val_1:
    .quad 5
.align 3
store_val_2:
    .quad 10
.align 3
store_val_4:
    .quad 18446744073709551606
.align 3
store_val_5:
    .quad 0
.align 3
store_val_27:
    .quad 2
.align 3
store_val_28:
    .quad 3
.align 3
store_val_29:
    .quad 1
.align 3
store_val_30:
    .quad 0
.align 3
store_val_35:
    .quad 1
.align 3
store_val_39:
    .quad 15
.align 3
store_val_40:
    .quad 0
.align 3
store_val_41:
    .quad 10
.align 3
store_val_52:
    .quad 18446744073709551574
.align 3
store_val_53:
    .quad 0
.align 3
store_val_57:
    .quad 0
.align 3
list_pool_values:
list_pool_lengths:
map_pool_keys:
map_pool_key_lengths:
map_pool_values:
map_pool_lengths:


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

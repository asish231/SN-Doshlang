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
.extern _file_read
.extern _file_write

.text
_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #32
    adrp x0, print_val_0@PAGE
    add x0, x0, print_val_0@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-8]
    ldur x0, [x29, #-8]
    adrp x1, print_val_1@PAGE
    add x1, x1, print_val_1@PAGEOFF
    bl _str_concat
    stur x0, [x29, #-16]
    ldur x10, [x29, #-16]
    stur x10, [x29, #-24]
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    ldur x1, [x29, #-24]
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
dec_sign_empty:
    .asciz ""
dec_sign_minus:
    .asciz "-"
.align 3
.align 3
print_val_0:
    .asciz "Hello, "
.align 3
print_val_1:
    .asciz "SNlang"


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

#include "platform.inc"
 .text
 .align 4
 .global _match_cstr_span
 .global _match_span_span
 .global _report_error_prefix
 .global _write_cstr_fd
 .global _write_buffer_fd
 .global _write_newline_stderr
 .global _write_u64_fd
 .global _write_i64_fd
 .global _write_decimal_raw_fd
 .global _cstring_length
 .global _i64_to_cstr
 .global _dec_to_cstr

_match_cstr_span:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x0, x21
    bl _cstring_length
    cmp x0, x20
    b.ne Lmatch_cstr_fail
    mov x0, x19
    mov x1, x20
    mov x2, x21
    bl _match_span_span
    b Lmatch_cstr_return

Lmatch_cstr_fail:
    mov x0, #0

Lmatch_cstr_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_match_span_span:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, #0

Lspan_cmp_loop:
    cmp x19, x1
    b.ge Lspan_cmp_yes
    ldrb w9, [x0, x19]
    ldrb w10, [x2, x19]
    cmp w9, w10
    b.ne Lspan_cmp_no
    add x19, x19, #1
    b Lspan_cmp_loop

Lspan_cmp_yes:
    mov x0, #1
    b Lspan_cmp_return

Lspan_cmp_no:
    mov x0, #0

Lspan_cmp_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_report_error_prefix:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    mov x1, #2
    bl _write_cstr_fd
    LOAD_ADDR x0, msg_on_line
    mov x1, #2
    bl _write_cstr_fd
    LOAD_ADDR x9, current_line
    ldr x0, [x9]
    mov x1, #2
    bl _write_u64_fd
    LOAD_ADDR x0, msg_colon_space
    mov x1, #2
    bl _write_cstr_fd

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_write_cstr_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    bl _cstring_length
    mov x1, x0
    mov x0, x19
    mov x2, x20
    bl _write_buffer_fd

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_write_buffer_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    cbz x1, Lwrite_buffer_done
    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x0, x21
    mov x1, x19
    mov x2, x20
    bl _write

Lwrite_buffer_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_write_newline_stderr:
    LOAD_ADDR x0, newline_char
    mov x1, #1
    mov x2, #2
    b _write_buffer_fd

_write_u64_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    LOAD_ADDR x21, number_buffer
    add x22, x21, #31
    mov x9, #0

    cbnz x19, Lwrite_u64_digits
    mov w10, #'0'
    strb w10, [x22]
    mov x0, x22
    mov x1, #1
    mov x2, x20
    bl _write_buffer_fd
    b Lwrite_u64_done

Lwrite_u64_digits:
    mov x11, #10

Lwrite_u64_loop:
    udiv x12, x19, x11
    msub x13, x12, x11, x19
    add w13, w13, #'0'
    strb w13, [x22]
    sub x22, x22, #1
    add x9, x9, #1
    mov x19, x12
    cbnz x19, Lwrite_u64_loop

    add x22, x22, #1
    mov x0, x22
    mov x1, x9
    mov x2, x20
    bl _write_buffer_fd

Lwrite_u64_done:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_write_i64_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    cmp x19, #0
    b.ge Lwrite_i64_positive
    LOAD_ADDR x0, single_char
    mov w9, #'-'
    strb w9, [x0]
    mov x1, #1
    mov x2, x20
    bl _write_buffer_fd
    neg x19, x19

Lwrite_i64_positive:
    mov x0, x19
    mov x1, x20
    bl _write_u64_fd

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_write_decimal_raw_fd:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0 // raw value
    mov x20, x1 // scale
    mov x21, x2 // fd

    cmp x19, #0
    b.ge Lwrite_dec_abs_ready
    LOAD_ADDR x0, single_char
    mov w9, #'-'
    strb w9, [x0]
    mov x1, #1
    mov x2, x21
    bl _write_buffer_fd
    neg x19, x19

Lwrite_dec_abs_ready:
    cbz x20, Lwrite_dec_int_only

    mov x22, #1
    mov x23, x20
    mov x9, #10
Lwrite_dec_pow_loop:
    cbz x23, Lwrite_dec_pow_done
    mul x22, x22, x9
    sub x23, x23, #1
    b Lwrite_dec_pow_loop
Lwrite_dec_pow_done:
    udiv x23, x19, x22
    msub x24, x23, x22, x19

    mov x0, x23
    mov x1, x21
    bl _write_u64_fd

    LOAD_ADDR x0, single_char
    mov w9, #'.'
    strb w9, [x0]
    mov x1, #1
    mov x2, x21
    bl _write_buffer_fd

    LOAD_ADDR x9, number_buffer
    add x10, x9, #31
    mov x11, #0
    mov x12, x24
    cbnz x12, Lwrite_dec_frac_digits
    mov w13, #'0'
    strb w13, [x10]
    mov x11, #1
    b Lwrite_dec_frac_ready

Lwrite_dec_frac_digits:
    mov x13, #10
Lwrite_dec_frac_loop:
    udiv x14, x12, x13
    msub x15, x14, x13, x12
    add w15, w15, #'0'
    strb w15, [x10]
    sub x10, x10, #1
    add x11, x11, #1
    mov x12, x14
    cbnz x12, Lwrite_dec_frac_loop
    add x10, x10, #1

Lwrite_dec_frac_ready:
    cmp x11, x20
    b.ge Lwrite_dec_frac_emit
    sub x12, x20, x11
    mov w13, #'0'
Lwrite_dec_zero_pad_loop:
    cbz x12, Lwrite_dec_frac_emit
    LOAD_ADDR x0, single_char
    strb w13, [x0]
    mov x1, #1
    mov x2, x21
    bl _write_buffer_fd
    sub x12, x12, #1
    b Lwrite_dec_zero_pad_loop

Lwrite_dec_frac_emit:
    mov x0, x10
    mov x1, x11
    mov x2, x21
    bl _write_buffer_fd
    b Lwrite_dec_done

Lwrite_dec_int_only:
    mov x0, x19
    mov x1, x21
    bl _write_u64_fd

Lwrite_dec_done:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_i64_to_cstr:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0
    mov x0, #32
    bl _malloc
    cbz x0, Li64_to_cstr_fail
    mov x20, x0
    add x21, x20, #31
    strb wzr, [x21]
    sub x21, x21, #1

    mov x22, #0
    cmp x19, #0
    b.ge Li64_to_cstr_abs_ready
    mov x22, #1
    neg x19, x19

Li64_to_cstr_abs_ready:
    cbnz x19, Li64_to_cstr_digits
    mov w9, #'0'
    strb w9, [x21]
    sub x21, x21, #1
    b Li64_to_cstr_sign

Li64_to_cstr_digits:
    mov x23, #10
Li64_to_cstr_loop:
    udiv x24, x19, x23
    msub x9, x24, x23, x19
    add w9, w9, #'0'
    strb w9, [x21]
    sub x21, x21, #1
    mov x19, x24
    cbnz x19, Li64_to_cstr_loop

Li64_to_cstr_sign:
    cbz x22, Li64_to_cstr_done
    mov w9, #'-'
    strb w9, [x21]
    sub x21, x21, #1

Li64_to_cstr_done:
    add x0, x21, #1
    b Li64_to_cstr_return

Li64_to_cstr_fail:
    mov x0, #0

Li64_to_cstr_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// x0 = scaled decimal value, x1 = scale
// returns x0 = cstring pointer (heap)
_dec_to_cstr:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    mov x19, x0 // scaled value
    mov x20, x1 // scale

    mov x21, #0 // negative flag
    cmp x19, #0
    b.ge Ldec_to_cstr_abs_ready
    mov x21, #1
    neg x19, x19

Ldec_to_cstr_abs_ready:
    mov x22, #1 // denominator 10^scale
    mov x23, x20
Ldec_to_cstr_pow_loop:
    cbz x23, Ldec_to_cstr_pow_done
    mov x9, #10
    mul x22, x22, x9
    sub x23, x23, #1
    b Ldec_to_cstr_pow_loop
Ldec_to_cstr_pow_done:

    // int_part = scaled / denom
    // frac_part = scaled % denom
    udiv x23, x19, x22
    msub x24, x23, x22, x19

    mov x0, x23
    bl _i64_to_cstr
    cbz x0, Ldec_to_cstr_fail
    mov x25, x0 // int string ptr

    mov x0, x25
    bl _cstring_length
    mov x26, x0 // int length

    mov x27, x26
    cbz x21, Ldec_to_cstr_len_sign_done
    add x27, x27, #1
Ldec_to_cstr_len_sign_done:
    cbz x20, Ldec_to_cstr_len_done
    add x27, x27, #1 // dot
    add x27, x27, x20 // fractional digits
Ldec_to_cstr_len_done:

    add x0, x27, #1 // + nul
    bl _malloc
    cbz x0, Ldec_to_cstr_fail
    mov x28, x0 // out ptr

    mov x9, #0 // out idx
    cbz x21, Ldec_to_cstr_copy_int
    mov w10, #'-'
    strb w10, [x28, x9]
    add x9, x9, #1

Ldec_to_cstr_copy_int:
    mov x10, #0
Ldec_to_cstr_copy_int_loop:
    cmp x10, x26
    b.ge Ldec_to_cstr_after_int
    ldrb w11, [x25, x10]
    strb w11, [x28, x9]
    add x10, x10, #1
    add x9, x9, #1
    b Ldec_to_cstr_copy_int_loop

Ldec_to_cstr_after_int:
    cbz x20, Ldec_to_cstr_terminate

    mov w10, #'.'
    strb w10, [x28, x9]
    add x9, x9, #1

    mov x10, x20
Ldec_to_cstr_frac_loop:
    cbz x10, Ldec_to_cstr_terminate
    mov x11, #10
    udiv x12, x24, x11
    msub x13, x12, x11, x24
    add w13, w13, #'0'
    sub x14, x10, #1
    add x15, x9, x14
    strb w13, [x28, x15]
    mov x24, x12
    sub x10, x10, #1
    b Ldec_to_cstr_frac_loop

Ldec_to_cstr_terminate:
    add x9, x9, x20
    strb wzr, [x28, x9]
    mov x0, x28
    b Ldec_to_cstr_return

Ldec_to_cstr_fail:
    mov x0, #0

Ldec_to_cstr_return:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_cstring_length:
    mov x1, x0
    mov x0, #0

Lstrlen_loop:
    ldrb w2, [x1, x0]
    cbz w2, Lstrlen_done
    add x0, x0, #1
    b Lstrlen_loop

Lstrlen_done:
    ret

.global _get_next_label
_get_next_label:
    LOAD_ADDR x9, label_counter
    ldr x0, [x9]
    add x1, x0, #1
    str x1, [x9]
    ret

.extern _malloc
.extern _free
.extern _open
.extern _read
.extern _write
.extern _close
.extern _lseek

.global _file_read
_file_read:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // path
    
    // Open file
    mov x0, x19
    mov x1, #0 // O_RDONLY
    bl _open
    cmp x0, #0
    b.lt Lfile_read_fail
    mov x20, x0 // fd

    // Get size
    mov x0, x20
    mov x1, #0
    mov x2, #2 // SEEK_END
    bl _lseek
    mov x21, x0 // size

    // Seek back to start
    mov x0, x20
    mov x1, #0
    mov x2, #0 // SEEK_SET
    bl _lseek

    // Allocate size + 1
    add x0, x21, #1
    bl _malloc
    cbz x0, Lfile_read_alloc_fail
    mov x22, x0 // buffer

    // Read
    mov x0, x20
    mov x1, x22
    mov x2, x21
    bl _read
    
    // Null terminate
    strb wzr, [x22, x21]

    // Close
    mov x0, x20
    bl _close

    mov x0, x22
    b Lfile_read_return

Lfile_read_alloc_fail:
    mov x0, x20
    bl _close
Lfile_read_fail:
    mov x0, #0

Lfile_read_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global _file_write
_file_write:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // path
    mov x20, x1 // data

    // Get length of data
    mov x0, x20
    bl _cstring_length
    mov x21, x0

    // Open for write (O_WRONLY | O_CREAT | O_TRUNC)
    // Flags differ by platform, but 0x601 is often O_WRONLY|O_CREAT|O_TRUNC on macOS/Linux
    // Let's use 0x601 for now, or check platform.inc
    mov x0, x19
#ifdef _WIN32
    mov x1, #0x0301 // _O_WRONLY | _O_CREAT | _O_TRUNC
#else
    mov x1, #0x601  // O_WRONLY | O_CREAT | O_TRUNC
#endif
    mov x2, #0644 // mode
    bl _open
    cmp x0, #0
    b.lt Lfile_write_fail
    mov x22, x0 // fd

    // Write
    mov x0, x22
    mov x1, x20
    mov x2, x21
    bl _write
    
    // Close
    mov x0, x22
    bl _close
    
    mov x0, #1
    b Lfile_write_return

Lfile_write_fail:
    mov x0, #0

Lfile_write_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.global _str_concat_len
_str_concat_len:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x19, x0 // s1
    mov x20, x1 // len1
    mov x21, x2 // s2
    mov x22, x3 // len2

    // Allocate len1 + len2 + 1
    add x0, x20, x22
    add x0, x0, #1
    bl _malloc
    cbz x0, Lstr_concat_len_fail
    mov x23, x0 // result ptr

    // Copy s1
    mov x24, #0
Lstr_concat_len_copy1:
    cmp x24, x20
    b.ge Lstr_concat_len_copy2_start
    ldrb w9, [x19, x24]
    strb w9, [x23, x24]
    add x24, x24, #1
    b Lstr_concat_len_copy1

Lstr_concat_len_copy2_start:
    mov x9, #0
Lstr_concat_len_copy2:
    cmp x9, x22
    b.ge Lstr_concat_len_done
    ldrb w10, [x21, x9]
    add x11, x24, x9
    strb w10, [x23, x11]
    add x9, x9, #1
    b Lstr_concat_len_copy2

Lstr_concat_len_done:
    add x11, x24, x22
    strb wzr, [x23, x11]
    mov x0, x23
    b Lstr_concat_len_return

Lstr_concat_len_fail:
    mov x0, #0

Lstr_concat_len_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

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
    // x3 is already len2
    bl _str_concat_len

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

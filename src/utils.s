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
 .global _load_module
 .global _find_module
 .global _module_path_to_file
 .global _open_file
 .global _load_and_parse_module_file
 .global _free_module_path
 .global _save_parser_state
 .global _restore_parser_state
 .global _file_exists
 .global _add_module_search_path
 .global _init_default_search_paths
 .global _register_imported_function
 .global _resolve_function_call
 .global _is_imported_function
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

.global _compare_cstr
_compare_cstr:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x0, x19
    bl _cstring_length
    mov x22, x0
    mov x0, x21
    bl _cstring_length
    cmp x22, x0
    b.ne Lcompare_cstr_notequal
    mov x0, x19
    mov x1, x21
    mov x2, x22
    bl _compare_cstr_len
    b Lcompare_cstr_return

Lcompare_cstr_notequal:
    mov x0, #1

Lcompare_cstr_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

_compare_cstr_len:
    mov x2, x2
    mov x3, #0
_compare_cstr_len_loop:
    cmp x3, x2
    b.ge Lcompare_cstr_len_equal
    ldrb w4, [x0, x3]
    ldrb w5, [x1, x3]
    cmp w4, w5
    b.ne Lcompare_cstr_len_notequal
    add x3, x3, #1
    b _compare_cstr_len_loop

Lcompare_cstr_len_equal:
    mov x0, #0
    ret

Lcompare_cstr_len_notequal:
    mov x0, #1
    ret

// Module system functions

// _module_path_to_file: convert "math.utils" -> "./math/utils.sn"
// Tries each search path in order. Returns malloc'd path or 0.
// x0=module_path_ptr, x1=module_path_len -> x0=file_path_ptr (malloc'd), x1=len
_module_path_to_file:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    mov x19, x0  // module path ptr
    mov x20, x1  // module path len

    LOAD_ADDR x21, module_search_count
    ldr x21, [x21]  // search path count
    mov x22, #0     // search path index

Lmodule_search_loop:
    cmp x22, x21
    b.ge Lmodule_convert_fail

    // Get search path ptr
    LOAD_ADDR x23, module_search_paths
    ldr x23, [x23, x22, lsl #3]  // x23 = search path ptr

    // Calculate search path length
    mov x0, x23
    bl _cstring_length
    mov x24, x0  // x24 = search path len

    // Allocate: search_path_len + 1("/") + module_path_len + 3(".sn") + 1(null)
    add x0, x24, #1
    add x0, x0, x20
    add x0, x0, #4
    bl _malloc
    cbz x0, Lmodule_search_next
    mov x25, x0  // x25 = allocated buffer

    // Copy search path
    mov x10, #0
Lmodule_copy_sp:
    cmp x10, x24
    b.ge Lmodule_add_slash
    ldrb w11, [x23, x10]
    strb w11, [x25, x10]
    add x10, x10, #1
    b Lmodule_copy_sp

Lmodule_add_slash:
    mov w11, #'/'
    strb w11, [x25, x24]

    // Copy module path replacing '.' with '/'
    mov x10, #0
Lmodule_copy_mp:
    cmp x10, x20
    b.ge Lmodule_add_ext
    ldrb w11, [x19, x10]
    cmp w11, #'.'
    b.ne Lmodule_copy_mp_char
    mov w11, #'/'
Lmodule_copy_mp_char:
    add x12, x24, #1
    add x12, x12, x10
    strb w11, [x25, x12]
    add x10, x10, #1
    b Lmodule_copy_mp

Lmodule_add_ext:
    // Append ".sn\0"
    add x10, x24, #1
    add x10, x10, x20
    mov w11, #'.'
    strb w11, [x25, x10]
    add x10, x10, #1
    mov w11, #'s'
    strb w11, [x25, x10]
    add x10, x10, #1
    mov w11, #'n'
    strb w11, [x25, x10]
    add x10, x10, #1
    strb wzr, [x25, x10]
    sub x26, x10, #1  // length without null terminator

    // Check if file exists
    mov x0, x25
    bl _file_exists
    cbnz x0, Lmodule_found_file

    // Not found — free and try next search path
    mov x0, x25
    bl _free

Lmodule_search_next:
    add x22, x22, #1
    b Lmodule_search_loop

Lmodule_found_file:
    mov x0, x25
    mov x1, x26
    b Lmodule_convert_return

Lmodule_convert_fail:
    mov x0, #0
    mov x1, #0

Lmodule_convert_return:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _find_module: check if module already loaded
// x0=module_name_ptr, x1=module_name_len -> x0=module_index (-1 if not found)
_find_module:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0  // module name ptr
    mov x20, x1  // module name len
    
    LOAD_ADDR x21, module_count
    ldr x22, [x21]  // module count
    mov x23, #0     // loop counter

Lfind_module_loop:
    cmp x23, x22
    b.ge Lfind_module_not_found
    
    // Get module name at index x23
    LOAD_ADDR x10, module_names
    ldr x11, [x10, x23, lsl #3]  // stored module name ptr (allocated)
    
    // Compare lengths first by checking null terminator position
    mov x12, #0  // stored name length counter
Lfind_module_len_loop:
    add x13, x11, x12
    ldrb w14, [x13]
    cbz w14, Lfind_module_len_done
    add x12, x12, #1
    b Lfind_module_len_loop

Lfind_module_len_done:
    // x12 = stored name length, x20 = search name length
    cmp x12, x20
    b.ne Lfind_module_next
    
    // Lengths match, compare content
    mov x0, x19  // search name ptr
    mov x1, x20  // search name len  
    mov x2, x11  // stored name ptr
    bl _match_span_span
    cbnz x0, Lfind_module_found
    
Lfind_module_next:
    add x23, x23, #1
    b Lfind_module_loop

Lfind_module_found:
    mov x0, x23
    b Lfind_module_return

Lfind_module_not_found:
    mov x0, #-1

Lfind_module_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _load_module: load and parse a module file
// x0=module_name_ptr, x1=module_name_len -> x0=success (0=ok, 1=error)
_load_module:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0  // module name ptr
    mov x20, x1  // module name len
    
    // Check if already loaded
    bl _find_module
    cmn x0, #1
    b.ne Lload_module_already_loaded
    
    // Convert module path to file path
    mov x0, x19
    mov x1, x20
    bl _module_path_to_file
    mov x21, x0  // file path ptr
    mov x22, x1  // file path len

    // Try to load the file (x21=path ptr, 0 means not found in any search path)
    cbz x21, Lload_module_no_file
    mov x0, x21
    bl _file_exists
    cbz x0, Lload_module_no_file

    mov x0, x21
    bl _load_and_parse_module_file
    mov x23, x0  // success flag
    b Lload_module_after_parse

Lload_module_no_file:
    mov x23, #1  // treat missing file as success (module tracked, no symbols)

Lload_module_after_parse:
    // Free the file path if it was allocated
    cbz x21, Lload_module_skip_free
    mov x0, x21
    bl _free_module_path
Lload_module_skip_free:
    
    // Check if loading succeeded
    cbz x23, Lload_module_file_error
    
    // Allocate memory for module name copy
    add x0, x20, #1  // len + null terminator
#ifdef _WIN32
    bl malloc
#else
    bl _malloc
#endif
    cbz x0, Lload_module_alloc_error
    mov x21, x0  // allocated name buffer
    
    // Copy module name
    mov x9, #0
Lload_module_copy_name:
    cmp x9, x20
    b.ge Lload_module_copy_done
    add x10, x19, x9
    ldrb w11, [x10]
    add x10, x21, x9
    strb w11, [x10]
    add x9, x9, #1
    b Lload_module_copy_name

Lload_module_copy_done:
    // Null terminate
    add x10, x21, x20
    strb wzr, [x10]
    
    // Add to module list
    LOAD_ADDR x10, module_count
    ldr x11, [x10]
    
    // Check module limit (256 modules max)
    cmp x11, #256
    b.ge Lload_module_limit_error
    
    // Store module name (allocated copy)
    LOAD_ADDR x12, module_names
    str x21, [x12, x11, lsl #3]
    
    // Store module path (reuse name for now)
    LOAD_ADDR x12, module_paths
    str x21, [x12, x11, lsl #3]
    
    // Increment count
    add x11, x11, #1
    str x11, [x10]
    
    mov x0, #0  // success
    b Lload_module_return

Lload_module_already_loaded:
    mov x0, #0  // success (already loaded)
    b Lload_module_return

Lload_module_file_error:
Lload_module_alloc_error:
Lload_module_limit_error:
    mov x0, #1  // error

Lload_module_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _open_file: open file for reading
// x0=file_path_ptr -> x0=file_descriptor (-1 on error)
_open_file:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, #0      // O_RDONLY
    mov x2, #0      // mode (unused for read)
#ifdef _WIN32
    bl open
#else
    bl _open
#endif
    
    ldp x29, x30, [sp], #16
    ret
// _free_module_path: free malloc'd module path
// x0=path_ptr
_free_module_path:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    bl _free
    ldp x29, x30, [sp], #16
    ret

// Parser state structure (offsets)
// 0: source_ptr
// 8: source_len  
// 16: cursor_pos
// 24: var_count
// 32: op_count
// 40: print_count
// 48: fn_count

// _save_parser_state: save current parser state
// -> x0=state_buffer_ptr
_save_parser_state:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Allocate state buffer
    mov x0, #56  // 7 * 8 bytes
#ifdef _WIN32
    bl malloc
#else
    bl _malloc
#endif
    cbz x0, Lsave_state_fail
    
    mov x9, x0  // state buffer
    
    // Save source_ptr
    LOAD_ADDR x10, source_ptr
    ldr x11, [x10]
    str x11, [x9]
    
    // Save source_len
    LOAD_ADDR x10, source_len
    ldr x11, [x10]
    str x11, [x9, #8]
    
    // Save cursor_pos
    LOAD_ADDR x10, cursor_pos
    ldr x11, [x10]
    str x11, [x9, #16]
    
    // Save var_count
    LOAD_ADDR x10, var_count
    ldr x11, [x10]
    str x11, [x9, #24]
    
    // Save op_count
    LOAD_ADDR x10, op_count
    ldr x11, [x10]
    str x11, [x9, #32]
    
    // Save print_count
    LOAD_ADDR x10, print_count
    ldr x11, [x10]
    str x11, [x9, #40]
    
    // Save fn_count
    LOAD_ADDR x10, fn_count
    ldr x11, [x10]
    str x11, [x9, #48]
    
    mov x0, x9  // return state buffer
    b Lsave_state_return

Lsave_state_fail:
    mov x0, #0

Lsave_state_return:
    ldp x29, x30, [sp], #16
    ret

// _restore_parser_state: restore parser state
// x0=state_buffer_ptr
_restore_parser_state:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    
    mov x19, x0  // state buffer
    
    // Restore source_ptr
    ldr x20, [x19]
    LOAD_ADDR x10, source_ptr
    str x20, [x10]
    
    // Restore source_len
    ldr x20, [x19, #8]
    LOAD_ADDR x10, source_len
    str x20, [x10]
    
    // Restore cursor_pos
    ldr x20, [x19, #16]
    LOAD_ADDR x10, cursor_pos
    str x20, [x10]
    
    // Restore var_count
    ldr x20, [x19, #24]
    LOAD_ADDR x10, var_count
    str x20, [x10]
    
    // Restore op_count
    ldr x20, [x19, #32]
    LOAD_ADDR x10, op_count
    str x20, [x10]
    
    // Restore print_count
    ldr x20, [x19, #40]
    LOAD_ADDR x10, print_count
    str x20, [x10]
    
    // Restore fn_count
    ldr x20, [x19, #48]
    LOAD_ADDR x10, fn_count
    str x20, [x10]
    
    // Free state buffer
    mov x0, x19
#ifdef _WIN32
    bl free
#else
    bl _free
#endif
    
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _load_and_parse_module_file: load file and parse it
// x0=file_path_ptr -> x0=success (1=ok, 0=error)
_load_and_parse_module_file:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x0  // file path

    // Save current parser state
    bl _save_parser_state
    mov x20, x0  // saved state
    cbz x20, Lparse_module_fail

    // Read the module into its own heap buffer so we do not clobber the
    // caller's source text stored in the shared global buffer.
    mov x0, x19
    bl _file_read
    cbz x0, Lparse_module_file_error
    mov x21, x0  // module buffer

    mov x0, x21
    bl _cstring_length
    mov x22, x0  // bytes read
    cbz x22, Lparse_module_read_error

    // Set source to module buffer
    mov x0, x21
    mov x1, x22
    bl _set_source

    // Reset cursor to start
    LOAD_ADDR x9, cursor_pos
    str xzr, [x9]

    // Parse the module content
    bl _parse_module_content
    mov x22, x0  // parse result
    LOAD_ADDR x9, fn_count
    ldr x23, [x9]  // preserve functions discovered in the module

    // Restore parser state but keep imported function metadata.
    mov x0, x20
    bl _restore_parser_state
    cbz x22, Lparse_module_fail
    LOAD_ADDR x9, fn_count
    str x23, [x9]

    mov x0, x22  // return parse result
    b Lparse_module_return

Lparse_module_read_error:
    mov x0, x21
    bl _free

Lparse_module_file_error:
    mov x0, x20
    bl _restore_parser_state

Lparse_module_fail:
    mov x0, #0
    b Lparse_module_return

Lparse_module_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _parse_module_content: parse module content (functions only for now)
// -> x0=success (1=ok, 0=error)
_parse_module_content:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    // Get module index (current count - 1, since we haven't added it yet)
    LOAD_ADDR x19, module_count
    ldr x20, [x19]

Lparse_module_loop:
    bl _skip_whitespace
    bl _is_eof
    cbnz x0, Lparse_module_success

    // Try to parse an identifier
    bl _parse_identifier
    cbz x0, Lparse_module_skip_line
    mov x9, x0   // save ptr
    mov x10, x1  // save len

    // Check if it's 'fn'
    mov x0, x9
    mov x1, x10
    LOAD_ADDR x2, kw_fn
    bl _match_cstr_span
    cbz x0, Lparse_module_check_use

    LOAD_ADDR x21, fn_count
    ldr x22, [x21]  // fn_count before parsing this definition

    // Parse function definition
    bl _parse_fn_definition
    cbnz x0, Lparse_module_error

    ldr x9, [x21]  // fn_count after parsing
    cmp x9, x22
    b.le Lparse_module_loop
    sub x9, x9, #1
    LOAD_ADDR x10, fn_name_ptrs
    ldr x0, [x10, x9, lsl #3]
    LOAD_ADDR x10, fn_name_lens
    ldr x1, [x10, x9, lsl #3]
    mov x2, x9
    bl _register_imported_function
    cbz x0, Lparse_module_error

    b Lparse_module_loop

Lparse_module_check_use:
    // Check if it's 'use'
    mov x0, x9
    mov x1, x10
    LOAD_ADDR x2, kw_use
    bl _match_cstr_span
    cbz x0, Lparse_module_skip_line

    // Parse 'use' statement
    bl _parse_use_statement_after_keyword
    cbnz x0, Lparse_module_error

    b Lparse_module_loop

Lparse_module_skip_line:
    // Skip to next newline
    bl _peek_char
    cbz w0, Lparse_module_success
    cmp w0, #'\n'
    b.eq Lparse_module_skip_newline
    bl _advance_char
    b Lparse_module_skip_line

Lparse_module_skip_newline:
    bl _advance_char
    b Lparse_module_loop

Lparse_module_success:
    mov x0, #1
    b Lparse_module_content_return

Lparse_module_error:
    mov x0, #0

Lparse_module_content_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
// _file_exists: check if file exists
// x0=file_path_ptr -> x0=exists (1=yes, 0=no)
_file_exists:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!

    mov x19, x0  // save path ptr
    mov x1, #0   // O_RDONLY
    mov x2, #0
    bl _open

    cmp x0, #-1
    b.eq Lfile_exists_no

    // Close it
    bl _close
    mov x0, #1  // exists
    b Lfile_exists_return

Lfile_exists_no:
    mov x0, #0

Lfile_exists_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _add_module_search_path: add a search path
// x0=path_ptr -> x0=success (1=ok, 0=error)
_add_module_search_path:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    
    mov x19, x0  // path ptr
    
    // Get current count
    LOAD_ADDR x20, module_search_count
    ldr x9, [x20]
    
    // Check limit
    cmp x9, #128
    b.ge Ladd_search_path_limit
    
    // Calculate path length
    mov x0, x19
    bl _cstring_length
    mov x10, x0  // path length
    
    // Allocate memory for path copy
    add x0, x10, #1  // + null terminator
#ifdef _WIN32
    bl malloc
#else
    bl _malloc
#endif
    cbz x0, Ladd_search_path_alloc_error
    
    mov x11, x0  // allocated buffer
    
    // Copy path
    mov x12, #0
Ladd_search_path_copy:
    cmp x12, x10
    b.ge Ladd_search_path_copy_done
    add x13, x19, x12
    ldrb w14, [x13]
    add x13, x11, x12
    strb w14, [x13]
    add x12, x12, #1
    b Ladd_search_path_copy

Ladd_search_path_copy_done:
    // Null terminate
    add x13, x11, x10
    strb wzr, [x13]
    
    // Store in search paths array
    LOAD_ADDR x12, module_search_paths
    str x11, [x12, x9, lsl #3]
    
    // Increment count
    add x9, x9, #1
    str x9, [x20]
    
    mov x0, #1  // success
    b Ladd_search_path_return

Ladd_search_path_limit:
Ladd_search_path_alloc_error:
    mov x0, #0  // error

Ladd_search_path_return:
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _init_default_search_paths: initialize default module search paths
_init_default_search_paths:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Store "." directly (static string, no malloc needed)
    LOAD_ADDR x9, module_search_paths
    LOAD_ADDR x10, default_search_path_current
    str x10, [x9]

    // Store "stdlib" directly
    LOAD_ADDR x10, default_search_path_stdlib
    str x10, [x9, #8]

    // Set count to 2
    LOAD_ADDR x9, module_search_count
    mov x10, #2
    str x10, [x9]

    ldp x29, x30, [sp], #16
    ret
// _register_imported_function: register an imported function by fn index
// x0=function_name_ptr, x1=function_name_len, x2=fn_index -> x0=success
_register_imported_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    mov x19, x0  // function name ptr
    mov x20, x1  // function name len
    mov x21, x2  // function index
    
    // Get current imported function count
    LOAD_ADDR x22, imported_function_count
    ldr x9, [x22]
    
    // Check limit
    cmp x9, #512
    b.ge Lregister_function_limit
    
    // Preserve x9 across _malloc call (caller-saved register)
    str x9, [sp, #-16]!
    
    // Allocate memory for function name copy
    add x0, x20, #1  // + null terminator
#ifdef _WIN32
    bl malloc
#else
    bl _malloc
#endif
    cbz x0, Lregister_function_alloc_error
    
    // Restore x9 after _malloc
    ldr x9, [sp], #16
    
    mov x10, x0  // allocated buffer
    
    // Copy function name
    mov x11, #0
Lregister_function_copy:
    cmp x11, x20
    b.ge Lregister_function_copy_done
    add x12, x19, x11
    ldrb w13, [x12]
    add x12, x10, x11
    strb w13, [x12]
    add x11, x11, #1
    b Lregister_function_copy

Lregister_function_copy_done:
    // Null terminate
    add x12, x10, x20
    strb wzr, [x12]
    
    // Store function name
    LOAD_ADDR x11, imported_function_names
    str x10, [x11, x9, lsl #3]
    
    // Store function index
    LOAD_ADDR x11, imported_function_modules
    str x21, [x11, x9, lsl #3]
    
    // Increment count
    add x9, x9, #1
    str x9, [x22]
    
    mov x0, #1  // success
    b Lregister_function_return

Lregister_function_limit:
Lregister_function_alloc_error:
    mov x0, #0  // error

Lregister_function_return:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _is_imported_function: check if function is imported
// x0=function_name_ptr, x1=function_name_len -> x0=is_imported (1=yes, 0=no), x1=fn_index
_is_imported_function:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    
    mov x19, x0  // function name ptr
    mov x20, x1  // function name len
    
    // Get imported function count
    LOAD_ADDR x21, imported_function_count
    ldr x22, [x21]
    
    mov x23, #0  // loop counter

Lis_imported_loop:
    cmp x23, x22
    b.ge Lis_imported_not_found
    
    // Get function name at index x23
    LOAD_ADDR x10, imported_function_names
    ldr x11, [x10, x23, lsl #3]  // stored function name ptr
    
    // Calculate stored name length
    mov x0, x11
    bl _cstring_length
    mov x12, x0  // stored name length
    
    // Compare lengths
    cmp x12, x20
    b.ne Lis_imported_next
    
    // Compare content
    mov x0, x19  // search name
    mov x1, x20  // search name len
    mov x2, x11  // stored name
    bl _match_span_span
    cbnz x0, Lis_imported_found
    
Lis_imported_next:
    add x23, x23, #1
    b Lis_imported_loop

Lis_imported_found:
    // Get function index
    LOAD_ADDR x10, imported_function_modules
    ldr x1, [x10, x23, lsl #3]  // function index
    mov x0, #1  // found
    b Lis_imported_return

Lis_imported_not_found:
    mov x0, #0  // not found
    mov x1, #-1 // invalid module index

Lis_imported_return:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// _resolve_function_call: resolve function call (check if imported)
// x0=function_name_ptr, x1=function_name_len -> x0=call_type (0=local, 1=imported), x1=fn_index
_resolve_function_call:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // First check if it's an imported function
    bl _is_imported_function
    cbnz x0, Lresolve_call_imported
    
    // Not imported, assume local
    mov x0, #0  // local call
    mov x1, #-1 // no module
    b Lresolve_call_return

Lresolve_call_imported:
    mov x0, #1  // imported call
    // x1 already contains module index

Lresolve_call_return:
    ldp x29, x30, [sp], #16
    ret

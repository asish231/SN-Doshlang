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
    sub sp, sp, #2240
    sub sp, sp, #2240
    adrp x9, store_val_0@PAGE
    ldr x10, [x9, store_val_0@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    adrp x9, store_val_2@PAGE
    ldr x10, [x9, store_val_2@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-40]
    adrp x9, store_val_4@PAGE
    ldr x10, [x9, store_val_4@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-56]
    adrp x9, store_val_6@PAGE
    ldr x10, [x9, store_val_6@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-72]
    adrp x9, store_val_8@PAGE
    ldr x10, [x9, store_val_8@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-88]
    adrp x9, store_val_10@PAGE
    ldr x10, [x9, store_val_10@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-104]
    adrp x9, store_val_12@PAGE
    ldr x10, [x9, store_val_12@PAGEOFF]
    stur x10, [x29, #-112]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-120]
     bl avg_of5

.global max_of
max_of:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-16]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-24]
    ldur x11, [x29, #-24]
    cbz x11, L_snl_101_0
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    b L_snl_101_1
L_snl_101_0:
L_snl_101_1:
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global min_of
min_of:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-16]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-24]
    ldur x11, [x29, #-24]
    cbz x11, L_snl_102_2
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    b L_snl_102_3
L_snl_102_2:
L_snl_102_3:
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global avg_of5
avg_of5:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x9, store_val_25@PAGE
    ldr x10, [x9, store_val_25@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    adrp x9, store_val_27@PAGE
    ldr x10, [x9, store_val_27@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-40]
    ldur x11, [x29, #-40]
    cbz x11, L_snl_103_4
    adrp x9, store_val_30@PAGE
    ldr x10, [x9, store_val_30@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_5
L_snl_103_4:
L_snl_103_5:
    adrp x9, store_val_34@PAGE
    ldr x10, [x9, store_val_34@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-64]
    adrp x9, store_val_36@PAGE
    ldr x10, [x9, store_val_36@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-80]
    ldur x11, [x29, #-16]
    cbz x11, L_snl_103_6
    adrp x9, store_val_39@PAGE
    ldr x10, [x9, store_val_39@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_7
L_snl_103_6:
L_snl_103_7:
    adrp x9, store_val_43@PAGE
    ldr x10, [x9, store_val_43@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-104]
    adrp x9, store_val_45@PAGE
    ldr x10, [x9, store_val_45@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-120]
    ldur x11, [x29, #-104]
    cbz x11, L_snl_103_8
    adrp x9, store_val_48@PAGE
    ldr x10, [x9, store_val_48@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_9
L_snl_103_8:
L_snl_103_9:
    adrp x9, store_val_52@PAGE
    ldr x10, [x9, store_val_52@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-144]
    adrp x9, store_val_54@PAGE
    ldr x10, [x9, store_val_54@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-160]
    ldur x11, [x29, #-144]
    cbz x11, L_snl_103_10
    adrp x9, store_val_57@PAGE
    ldr x10, [x9, store_val_57@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_11
L_snl_103_10:
L_snl_103_11:
    adrp x9, store_val_61@PAGE
    ldr x10, [x9, store_val_61@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-184]
    adrp x9, store_val_63@PAGE
    ldr x10, [x9, store_val_63@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-200]
    ldur x11, [x29, #-136]
    cbz x11, L_snl_103_12
    adrp x9, store_val_66@PAGE
    ldr x10, [x9, store_val_66@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_13
L_snl_103_12:
L_snl_103_13:
    adrp x9, store_val_70@PAGE
    ldr x10, [x9, store_val_70@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-224]
    adrp x9, store_val_72@PAGE
    ldr x10, [x9, store_val_72@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-240]
    ldur x11, [x29, #-208]
    cbz x11, L_snl_103_14
    adrp x9, store_val_75@PAGE
    ldr x10, [x9, store_val_75@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_15
L_snl_103_14:
L_snl_103_15:
    adrp x9, store_val_79@PAGE
    ldr x10, [x9, store_val_79@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-264]
    adrp x9, store_val_81@PAGE
    ldr x10, [x9, store_val_81@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-280]
    ldur x11, [x29, #-264]
    cbz x11, L_snl_103_16
    adrp x9, store_val_84@PAGE
    ldr x10, [x9, store_val_84@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_17
L_snl_103_16:
L_snl_103_17:
    adrp x9, store_val_88@PAGE
    ldr x10, [x9, store_val_88@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-304]
    adrp x9, store_val_90@PAGE
    ldr x10, [x9, store_val_90@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-320]
    ldur x11, [x29, #-304]
    cbz x11, L_snl_103_18
    adrp x9, store_val_93@PAGE
    ldr x10, [x9, store_val_93@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_19
L_snl_103_18:
L_snl_103_19:
    adrp x9, store_val_97@PAGE
    ldr x10, [x9, store_val_97@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-344]
    adrp x9, store_val_99@PAGE
    ldr x10, [x9, store_val_99@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-360]
    ldur x11, [x29, #-328]
    cbz x11, L_snl_103_20
    adrp x9, store_val_102@PAGE
    ldr x10, [x9, store_val_102@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_21
L_snl_103_20:
L_snl_103_21:
    adrp x9, store_val_106@PAGE
    ldr x10, [x9, store_val_106@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-384]
    adrp x9, store_val_108@PAGE
    ldr x10, [x9, store_val_108@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-400]
    ldur x11, [x29, #-272]
    cbz x11, L_snl_103_22
    adrp x9, store_val_111@PAGE
    ldr x10, [x9, store_val_111@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_23
L_snl_103_22:
L_snl_103_23:
    adrp x9, store_val_115@PAGE
    ldr x10, [x9, store_val_115@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-424]
    adrp x9, store_val_117@PAGE
    ldr x10, [x9, store_val_117@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-440]
    ldur x11, [x29, #-424]
    cbz x11, L_snl_103_24
    adrp x9, store_val_120@PAGE
    ldr x10, [x9, store_val_120@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_25
L_snl_103_24:
L_snl_103_25:
    adrp x9, store_val_124@PAGE
    ldr x10, [x9, store_val_124@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-464]
    adrp x9, store_val_126@PAGE
    ldr x10, [x9, store_val_126@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-480]
    ldur x11, [x29, #-464]
    cbz x11, L_snl_103_26
    adrp x9, store_val_129@PAGE
    ldr x10, [x9, store_val_129@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_27
L_snl_103_26:
L_snl_103_27:
    adrp x9, store_val_133@PAGE
    ldr x10, [x9, store_val_133@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-504]
    adrp x9, store_val_135@PAGE
    ldr x10, [x9, store_val_135@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-520]
    ldur x11, [x29, #-8]
    cbz x11, L_snl_103_28
    adrp x9, store_val_138@PAGE
    ldr x10, [x9, store_val_138@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_29
L_snl_103_28:
L_snl_103_29:
    adrp x9, store_val_142@PAGE
    ldr x10, [x9, store_val_142@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-544]
    adrp x9, store_val_144@PAGE
    ldr x10, [x9, store_val_144@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-560]
    ldur x11, [x29, #-528]
    cbz x11, L_snl_103_30
    adrp x9, store_val_147@PAGE
    ldr x10, [x9, store_val_147@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_31
L_snl_103_30:
L_snl_103_31:
    adrp x9, store_val_151@PAGE
    ldr x10, [x9, store_val_151@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-584]
    adrp x9, store_val_153@PAGE
    ldr x10, [x9, store_val_153@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-600]
    ldur x11, [x29, #-584]
    cbz x11, L_snl_103_32
    adrp x9, store_val_156@PAGE
    ldr x10, [x9, store_val_156@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_33
L_snl_103_32:
L_snl_103_33:
    adrp x9, store_val_160@PAGE
    ldr x10, [x9, store_val_160@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-624]
    adrp x9, store_val_162@PAGE
    ldr x10, [x9, store_val_162@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-640]
    ldur x11, [x29, #-624]
    cbz x11, L_snl_103_34
    adrp x9, store_val_165@PAGE
    ldr x10, [x9, store_val_165@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_35
L_snl_103_34:
L_snl_103_35:
    adrp x9, store_val_169@PAGE
    ldr x10, [x9, store_val_169@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-664]
    adrp x9, store_val_171@PAGE
    ldr x10, [x9, store_val_171@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-680]
    ldur x11, [x29, #-648]
    cbz x11, L_snl_103_36
    adrp x9, store_val_174@PAGE
    ldr x10, [x9, store_val_174@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_37
L_snl_103_36:
L_snl_103_37:
    adrp x9, store_val_178@PAGE
    ldr x10, [x9, store_val_178@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-704]
    adrp x9, store_val_180@PAGE
    ldr x10, [x9, store_val_180@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-720]
    ldur x11, [x29, #-656]
    cbz x11, L_snl_103_38
    adrp x9, store_val_183@PAGE
    ldr x10, [x9, store_val_183@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_39
L_snl_103_38:
L_snl_103_39:
    adrp x9, store_val_187@PAGE
    ldr x10, [x9, store_val_187@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-744]
    adrp x9, store_val_189@PAGE
    ldr x10, [x9, store_val_189@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-760]
    ldur x11, [x29, #-744]
    cbz x11, L_snl_103_40
    adrp x9, store_val_192@PAGE
    ldr x10, [x9, store_val_192@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_41
L_snl_103_40:
L_snl_103_41:
    adrp x9, store_val_196@PAGE
    ldr x10, [x9, store_val_196@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-784]
    adrp x9, store_val_198@PAGE
    ldr x10, [x9, store_val_198@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-800]
    ldur x11, [x29, #-784]
    cbz x11, L_snl_103_42
    adrp x9, store_val_201@PAGE
    ldr x10, [x9, store_val_201@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_43
L_snl_103_42:
L_snl_103_43:
    adrp x9, store_val_205@PAGE
    ldr x10, [x9, store_val_205@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-824]
    adrp x9, store_val_207@PAGE
    ldr x10, [x9, store_val_207@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-840]
    ldur x11, [x29, #-776]
    cbz x11, L_snl_103_44
    adrp x9, store_val_210@PAGE
    ldr x10, [x9, store_val_210@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_45
L_snl_103_44:
L_snl_103_45:
    adrp x9, store_val_214@PAGE
    ldr x10, [x9, store_val_214@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-864]
    adrp x9, store_val_216@PAGE
    ldr x10, [x9, store_val_216@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-880]
    ldur x11, [x29, #-848]
    cbz x11, L_snl_103_46
    adrp x9, store_val_219@PAGE
    ldr x10, [x9, store_val_219@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_47
L_snl_103_46:
L_snl_103_47:
    adrp x9, store_val_223@PAGE
    ldr x10, [x9, store_val_223@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-904]
    adrp x9, store_val_225@PAGE
    ldr x10, [x9, store_val_225@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-920]
    ldur x11, [x29, #-904]
    cbz x11, L_snl_103_48
    adrp x9, store_val_228@PAGE
    ldr x10, [x9, store_val_228@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_49
L_snl_103_48:
L_snl_103_49:
    adrp x9, store_val_232@PAGE
    ldr x10, [x9, store_val_232@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-944]
    adrp x9, store_val_234@PAGE
    ldr x10, [x9, store_val_234@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-960]
    ldur x11, [x29, #-944]
    cbz x11, L_snl_103_50
    adrp x9, store_val_237@PAGE
    ldr x10, [x9, store_val_237@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_51
L_snl_103_50:
L_snl_103_51:
    adrp x9, store_val_241@PAGE
    ldr x10, [x9, store_val_241@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-984]
    adrp x9, store_val_243@PAGE
    ldr x10, [x9, store_val_243@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1000]
    ldur x11, [x29, #-968]
    cbz x11, L_snl_103_52
    adrp x9, store_val_246@PAGE
    ldr x10, [x9, store_val_246@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_53
L_snl_103_52:
L_snl_103_53:
    adrp x9, store_val_250@PAGE
    ldr x10, [x9, store_val_250@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1024]
    adrp x9, store_val_252@PAGE
    ldr x10, [x9, store_val_252@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1040]
    ldur x11, [x29, #-16]
    cbz x11, L_snl_103_54
    adrp x9, store_val_255@PAGE
    ldr x10, [x9, store_val_255@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_55
L_snl_103_54:
L_snl_103_55:
    adrp x9, store_val_259@PAGE
    ldr x10, [x9, store_val_259@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1064]
    adrp x9, store_val_261@PAGE
    ldr x10, [x9, store_val_261@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1080]
    ldur x11, [x29, #-1064]
    cbz x11, L_snl_103_56
    adrp x9, store_val_264@PAGE
    ldr x10, [x9, store_val_264@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_57
L_snl_103_56:
L_snl_103_57:
    adrp x9, store_val_268@PAGE
    ldr x10, [x9, store_val_268@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1104]
    adrp x9, store_val_270@PAGE
    ldr x10, [x9, store_val_270@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1120]
    ldur x11, [x29, #-1104]
    cbz x11, L_snl_103_58
    adrp x9, store_val_273@PAGE
    ldr x10, [x9, store_val_273@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_59
L_snl_103_58:
L_snl_103_59:
    adrp x9, store_val_277@PAGE
    ldr x10, [x9, store_val_277@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1144]
    adrp x9, store_val_279@PAGE
    ldr x10, [x9, store_val_279@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1160]
    ldur x11, [x29, #-1032]
    cbz x11, L_snl_103_60
    adrp x9, store_val_282@PAGE
    ldr x10, [x9, store_val_282@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_61
L_snl_103_60:
L_snl_103_61:
    adrp x9, store_val_286@PAGE
    ldr x10, [x9, store_val_286@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1184]
    adrp x9, store_val_288@PAGE
    ldr x10, [x9, store_val_288@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1200]
    ldur x11, [x29, #-1168]
    cbz x11, L_snl_103_62
    adrp x9, store_val_291@PAGE
    ldr x10, [x9, store_val_291@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_63
L_snl_103_62:
L_snl_103_63:
    adrp x9, store_val_295@PAGE
    ldr x10, [x9, store_val_295@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1224]
    adrp x9, store_val_297@PAGE
    ldr x10, [x9, store_val_297@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1240]
    ldur x11, [x29, #-1224]
    cbz x11, L_snl_103_64
    adrp x9, store_val_300@PAGE
    ldr x10, [x9, store_val_300@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_65
L_snl_103_64:
L_snl_103_65:
    adrp x9, store_val_304@PAGE
    ldr x10, [x9, store_val_304@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1264]
    adrp x9, store_val_306@PAGE
    ldr x10, [x9, store_val_306@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1280]
    ldur x11, [x29, #-1264]
    cbz x11, L_snl_103_66
    adrp x9, store_val_309@PAGE
    ldr x10, [x9, store_val_309@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_67
L_snl_103_66:
L_snl_103_67:
    adrp x9, store_val_313@PAGE
    ldr x10, [x9, store_val_313@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1304]
    adrp x9, store_val_315@PAGE
    ldr x10, [x9, store_val_315@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1320]
    ldur x11, [x29, #-1288]
    cbz x11, L_snl_103_68
    adrp x9, store_val_318@PAGE
    ldr x10, [x9, store_val_318@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_69
L_snl_103_68:
L_snl_103_69:
    adrp x9, store_val_322@PAGE
    ldr x10, [x9, store_val_322@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1344]
    adrp x9, store_val_324@PAGE
    ldr x10, [x9, store_val_324@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1360]
    ldur x11, [x29, #-1296]
    cbz x11, L_snl_103_70
    adrp x9, store_val_327@PAGE
    ldr x10, [x9, store_val_327@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_71
L_snl_103_70:
L_snl_103_71:
    adrp x9, store_val_331@PAGE
    ldr x10, [x9, store_val_331@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1384]
    adrp x9, store_val_333@PAGE
    ldr x10, [x9, store_val_333@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1400]
    ldur x11, [x29, #-1384]
    cbz x11, L_snl_103_72
    adrp x9, store_val_336@PAGE
    ldr x10, [x9, store_val_336@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_73
L_snl_103_72:
L_snl_103_73:
    adrp x9, store_val_340@PAGE
    ldr x10, [x9, store_val_340@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1424]
    adrp x9, store_val_342@PAGE
    ldr x10, [x9, store_val_342@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1440]
    ldur x11, [x29, #-1424]
    cbz x11, L_snl_103_74
    adrp x9, store_val_345@PAGE
    ldr x10, [x9, store_val_345@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_75
L_snl_103_74:
L_snl_103_75:
    adrp x9, store_val_349@PAGE
    ldr x10, [x9, store_val_349@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1464]
    adrp x9, store_val_351@PAGE
    ldr x10, [x9, store_val_351@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1480]
    ldur x11, [x29, #-1416]
    cbz x11, L_snl_103_76
    adrp x9, store_val_354@PAGE
    ldr x10, [x9, store_val_354@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_77
L_snl_103_76:
L_snl_103_77:
    adrp x9, store_val_358@PAGE
    ldr x10, [x9, store_val_358@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1504]
    adrp x9, store_val_360@PAGE
    ldr x10, [x9, store_val_360@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1520]
    ldur x11, [x29, #-1488]
    cbz x11, L_snl_103_78
    adrp x9, store_val_363@PAGE
    ldr x10, [x9, store_val_363@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_79
L_snl_103_78:
L_snl_103_79:
    adrp x9, store_val_367@PAGE
    ldr x10, [x9, store_val_367@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1544]
    adrp x9, store_val_369@PAGE
    ldr x10, [x9, store_val_369@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1560]
    ldur x11, [x29, #-1544]
    cbz x11, L_snl_103_80
    adrp x9, store_val_372@PAGE
    ldr x10, [x9, store_val_372@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_81
L_snl_103_80:
L_snl_103_81:
    adrp x9, store_val_376@PAGE
    ldr x10, [x9, store_val_376@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1584]
    adrp x9, store_val_378@PAGE
    ldr x10, [x9, store_val_378@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1600]
    ldur x11, [x29, #-1584]
    cbz x11, L_snl_103_82
    adrp x9, store_val_381@PAGE
    ldr x10, [x9, store_val_381@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_83
L_snl_103_82:
L_snl_103_83:
    adrp x9, store_val_385@PAGE
    ldr x10, [x9, store_val_385@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1624]
    adrp x9, store_val_387@PAGE
    ldr x10, [x9, store_val_387@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1640]
    ldur x11, [x29, #-1608]
    cbz x11, L_snl_103_84
    adrp x9, store_val_390@PAGE
    ldr x10, [x9, store_val_390@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_85
L_snl_103_84:
L_snl_103_85:
    adrp x9, store_val_394@PAGE
    ldr x10, [x9, store_val_394@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1664]
    adrp x9, store_val_396@PAGE
    ldr x10, [x9, store_val_396@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1680]
    ldur x11, [x29, #-1552]
    cbz x11, L_snl_103_86
    adrp x9, store_val_399@PAGE
    ldr x10, [x9, store_val_399@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_87
L_snl_103_86:
L_snl_103_87:
    adrp x9, store_val_403@PAGE
    ldr x10, [x9, store_val_403@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1704]
    adrp x9, store_val_405@PAGE
    ldr x10, [x9, store_val_405@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1720]
    ldur x11, [x29, #-1704]
    cbz x11, L_snl_103_88
    adrp x9, store_val_408@PAGE
    ldr x10, [x9, store_val_408@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_89
L_snl_103_88:
L_snl_103_89:
    adrp x9, store_val_412@PAGE
    ldr x10, [x9, store_val_412@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1744]
    adrp x9, store_val_414@PAGE
    ldr x10, [x9, store_val_414@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1760]
    ldur x11, [x29, #-1744]
    cbz x11, L_snl_103_90
    adrp x9, store_val_417@PAGE
    ldr x10, [x9, store_val_417@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_91
L_snl_103_90:
L_snl_103_91:
    adrp x9, store_val_421@PAGE
    ldr x10, [x9, store_val_421@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1784]
    adrp x9, store_val_423@PAGE
    ldr x10, [x9, store_val_423@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1800]
    ldur x11, [x29, #-1544]
    cbz x11, L_snl_103_92
    adrp x9, store_val_426@PAGE
    ldr x10, [x9, store_val_426@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_93
L_snl_103_92:
L_snl_103_93:
    adrp x9, store_val_430@PAGE
    ldr x10, [x9, store_val_430@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1824]
    adrp x9, store_val_432@PAGE
    ldr x10, [x9, store_val_432@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1840]
    ldur x11, [x29, #-1808]
    cbz x11, L_snl_103_94
    adrp x9, store_val_435@PAGE
    ldr x10, [x9, store_val_435@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_95
L_snl_103_94:
L_snl_103_95:
    adrp x9, store_val_439@PAGE
    ldr x10, [x9, store_val_439@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1864]
    adrp x9, store_val_441@PAGE
    ldr x10, [x9, store_val_441@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1880]
    ldur x11, [x29, #-1864]
    cbz x11, L_snl_103_96
    adrp x9, store_val_444@PAGE
    ldr x10, [x9, store_val_444@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_97
L_snl_103_96:
L_snl_103_97:
    adrp x9, store_val_448@PAGE
    ldr x10, [x9, store_val_448@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1904]
    adrp x9, store_val_450@PAGE
    ldr x10, [x9, store_val_450@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1920]
    ldur x11, [x29, #-1904]
    cbz x11, L_snl_103_98
    adrp x9, store_val_453@PAGE
    ldr x10, [x9, store_val_453@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_99
L_snl_103_98:
L_snl_103_99:
    adrp x9, store_val_457@PAGE
    ldr x10, [x9, store_val_457@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1944]
    adrp x9, store_val_459@PAGE
    ldr x10, [x9, store_val_459@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-1960]
    ldur x11, [x29, #-1928]
    cbz x11, L_snl_103_100
    adrp x9, store_val_462@PAGE
    ldr x10, [x9, store_val_462@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_101
L_snl_103_100:
L_snl_103_101:
    adrp x9, store_val_466@PAGE
    ldr x10, [x9, store_val_466@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-1984]
    adrp x9, store_val_468@PAGE
    ldr x10, [x9, store_val_468@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-2000]
    ldur x11, [x29, #-1936]
    cbz x11, L_snl_103_102
    adrp x9, store_val_471@PAGE
    ldr x10, [x9, store_val_471@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_103
L_snl_103_102:
L_snl_103_103:
    adrp x9, store_val_475@PAGE
    ldr x10, [x9, store_val_475@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-2024]
    adrp x9, store_val_477@PAGE
    ldr x10, [x9, store_val_477@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-2040]
    ldur x11, [x29, #-2024]
    cbz x11, L_snl_103_104
    adrp x9, store_val_480@PAGE
    ldr x10, [x9, store_val_480@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_105
L_snl_103_104:
L_snl_103_105:
    adrp x9, store_val_484@PAGE
    ldr x10, [x9, store_val_484@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-2064]
    adrp x9, store_val_486@PAGE
    ldr x10, [x9, store_val_486@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-2080]
    ldur x11, [x29, #-2064]
    cbz x11, L_snl_103_106
    adrp x9, store_val_489@PAGE
    ldr x10, [x9, store_val_489@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_107
L_snl_103_106:
L_snl_103_107:
    adrp x9, store_val_493@PAGE
    ldr x10, [x9, store_val_493@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-2104]
    adrp x9, store_val_495@PAGE
    ldr x10, [x9, store_val_495@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-2120]
    ldur x11, [x29, #-2056]
    cbz x11, L_snl_103_108
    adrp x9, store_val_498@PAGE
    ldr x10, [x9, store_val_498@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_109
L_snl_103_108:
L_snl_103_109:
    adrp x9, store_val_502@PAGE
    ldr x10, [x9, store_val_502@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-2144]
    adrp x9, store_val_504@PAGE
    ldr x10, [x9, store_val_504@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-2160]
    ldur x11, [x29, #-2128]
    cbz x11, L_snl_103_110
    adrp x9, store_val_507@PAGE
    ldr x10, [x9, store_val_507@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_111
L_snl_103_110:
L_snl_103_111:
    adrp x9, store_val_511@PAGE
    ldr x10, [x9, store_val_511@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-2184]
    adrp x9, store_val_513@PAGE
    ldr x10, [x9, store_val_513@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-2200]
    ldur x11, [x29, #-2184]
    cbz x11, L_snl_103_112
    adrp x9, store_val_516@PAGE
    ldr x10, [x9, store_val_516@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_113
L_snl_103_112:
L_snl_103_113:
    adrp x9, store_val_520@PAGE
    ldr x10, [x9, store_val_520@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-120]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-2224]
    ldur x11, [x29, #-2224]
    cbz x11, L_snl_103_114
    adrp x9, store_val_523@PAGE
    ldr x10, [x9, store_val_523@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_103_115
L_snl_103_114:
L_snl_103_115:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global letter_grade
letter_grade:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x9, store_val_528@PAGE
    ldr x10, [x9, store_val_528@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-24]
    ldur x11, [x29, #-24]
    cbz x11, L_snl_104_116
    adrp x0, print_val_1@PAGE
    add x0, x0, print_val_1@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-32]
    ldur x0, [x29, #-34763930056]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    b L_snl_104_117
L_snl_104_116:
L_snl_104_117:
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global is_passing
is_passing:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x9, store_val_535@PAGE
    ldr x10, [x9, store_val_535@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    adrp x9, store_val_537@PAGE
    ldr x10, [x9, store_val_537@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, ge
    stur x11, [x29, #-40]
    ldur x11, [x29, #-40]
    cbz x11, L_snl_105_118
    adrp x9, store_val_540@PAGE
    ldr x10, [x9, store_val_540@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_105_119
L_snl_105_118:
L_snl_105_119:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global student_highest
student_highest:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    ldur x10, [x29, #-8]
    stur x10, [x29, #-40]
    ldur x11, [x29, #-16]
    ldur x10, [x29, #-40]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-48]
    ldur x11, [x29, #-48]
    cbz x11, L_snl_106_120
    ldur x10, [x29, #-16]
    stur x10, [x29, #-40]
    b L_snl_106_121
L_snl_106_120:
L_snl_106_121:
    ldur x11, [x29, #-24]
    ldur x10, [x29, #-40]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-56]
    ldur x11, [x29, #-56]
    cbz x11, L_snl_106_122
    ldur x10, [x29, #-24]
    stur x10, [x29, #-40]
    b L_snl_106_123
L_snl_106_122:
L_snl_106_123:
    ldur x11, [x29, #-32]
    ldur x10, [x29, #-40]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-64]
    ldur x11, [x29, #-64]
    cbz x11, L_snl_106_124
    ldur x10, [x29, #-32]
    stur x10, [x29, #-40]
    b L_snl_106_125
L_snl_106_124:
L_snl_106_125:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global student_highest5
student_highest5:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    ldur x11, [x29, #-16]
    ldur x10, [x29, #-24]
    cmp x11, x10
    cset x11, gt
    stur x11, [x29, #-32]
    ldur x11, [x29, #-32]
    cbz x11, L_snl_107_126
    ldur x10, [x29, #-16]
    stur x10, [x29, #-24]
    b L_snl_107_127
L_snl_107_126:
L_snl_107_127:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global student_lowest
student_lowest:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    ldur x10, [x29, #-8]
    stur x10, [x29, #-40]
    ldur x11, [x29, #-16]
    ldur x10, [x29, #-40]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-48]
    ldur x11, [x29, #-48]
    cbz x11, L_snl_108_128
    ldur x10, [x29, #-16]
    stur x10, [x29, #-40]
    b L_snl_108_129
L_snl_108_128:
L_snl_108_129:
    ldur x11, [x29, #-24]
    ldur x10, [x29, #-40]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-56]
    ldur x11, [x29, #-56]
    cbz x11, L_snl_108_130
    ldur x10, [x29, #-24]
    stur x10, [x29, #-40]
    b L_snl_108_131
L_snl_108_130:
L_snl_108_131:
    ldur x11, [x29, #-32]
    ldur x10, [x29, #-40]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-64]
    ldur x11, [x29, #-64]
    cbz x11, L_snl_108_132
    ldur x10, [x29, #-32]
    stur x10, [x29, #-40]
    b L_snl_108_133
L_snl_108_132:
L_snl_108_133:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global student_lowest5
student_lowest5:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    ldur x11, [x29, #-16]
    ldur x10, [x29, #-24]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-32]
    ldur x11, [x29, #-32]
    cbz x11, L_snl_109_134
    ldur x10, [x29, #-16]
    stur x10, [x29, #-24]
    b L_snl_109_135
L_snl_109_134:
L_snl_109_135:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global student_passed_all
student_passed_all:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x9, store_val_593@PAGE
    ldr x10, [x9, store_val_593@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-48]
    adrp x9, store_val_595@PAGE
    ldr x10, [x9, store_val_595@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-8]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-64]
    ldur x11, [x29, #-64]
    cbz x11, L_snl_110_136
    adrp x9, store_val_598@PAGE
    ldr x10, [x9, store_val_598@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-48]
    b L_snl_110_137
L_snl_110_136:
L_snl_110_137:
    adrp x9, store_val_602@PAGE
    ldr x10, [x9, store_val_602@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-16]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-88]
    ldur x11, [x29, #-88]
    cbz x11, L_snl_110_138
    adrp x9, store_val_605@PAGE
    ldr x10, [x9, store_val_605@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-48]
    b L_snl_110_139
L_snl_110_138:
L_snl_110_139:
    adrp x9, store_val_609@PAGE
    ldr x10, [x9, store_val_609@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-24]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-112]
    ldur x11, [x29, #-112]
    cbz x11, L_snl_110_140
    adrp x9, store_val_612@PAGE
    ldr x10, [x9, store_val_612@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-48]
    b L_snl_110_141
L_snl_110_140:
L_snl_110_141:
    adrp x9, store_val_616@PAGE
    ldr x10, [x9, store_val_616@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-32]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-136]
    ldur x11, [x29, #-136]
    cbz x11, L_snl_110_142
    adrp x9, store_val_619@PAGE
    ldr x10, [x9, store_val_619@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-48]
    b L_snl_110_143
L_snl_110_142:
L_snl_110_143:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global student_passed5
student_passed5:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    adrp x9, store_val_625@PAGE
    ldr x10, [x9, store_val_625@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x11, [x29, #-16]
    ldur x10, [x29, #-8]
    cmp x11, x10
    cset x11, lt
    stur x11, [x29, #-40]
    ldur x11, [x29, #-40]
    cbz x11, L_snl_111_144
    adrp x9, store_val_628@PAGE
    ldr x10, [x9, store_val_628@PAGEOFF]
    stur x10, [x29, #-8]
    ldur x10, [x29, #-8]
    stur x10, [x29, #-24]
    b L_snl_111_145
L_snl_111_144:
L_snl_111_145:
    ldur x0, [x29, #-8]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global print_divider
print_divider:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x0, print_val_2@PAGE
    add x0, x0, print_val_2@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-8]
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_3@PAGE
    add x1, x1, print_val_3@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global print_subject_score
print_subject_score:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global print_report_header
print_report_header:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x0, print_val_4@PAGE
    add x0, x0, print_val_4@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-24]
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_5@PAGE
    add x1, x1, print_val_5@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_val_6@PAGE
    add x0, x0, print_val_6@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-32]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global print_summary
print_summary:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x0, print_val_7@PAGE
    add x0, x0, print_val_7@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-32]
    mov sp, x29
    ldp x29, x30, [sp], #16
    ret

.global print_class_summary
print_class_summary:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #128
    adrp x0, print_val_8@PAGE
    add x0, x0, print_val_8@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-32]
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_9@PAGE
    add x1, x1, print_val_9@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_val_10@PAGE
    add x0, x0, print_val_10@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-40]
    adrp x0, print_fmt_str@PAGE
    add x0, x0, print_fmt_str@PAGEOFF
    adrp x1, print_val_11@PAGE
    add x1, x1, print_val_11@PAGEOFF
    sub sp, sp, #16
    str x1, [sp]
    bl _printf
    add sp, sp, #16
    adrp x0, print_val_12@PAGE
    add x0, x0, print_val_12@PAGEOFF
    mov x10, x0
    stur x10, [x29, #-48]
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
print_val_0:
    .asciz "Asish"
.align 3
print_val_1:
    .asciz "A"
.align 3
print_val_2:
    .asciz "--------------------------------"
.align 3
print_val_3:
    .asciz "--------------------------------"
.align 3
print_val_4:
    .asciz "REPORT CARD"
.align 3
print_val_5:
    .asciz "REPORT CARD"
.align 3
print_val_6:
    .asciz "Student  : "
.align 3
print_val_7:
    .asciz "Average  : "
.align 3
print_val_8:
    .asciz "================================"
.align 3
print_val_9:
    .asciz "================================"
.align 3
print_val_10:
    .asciz "CLASS SUMMARY"
.align 3
print_val_11:
    .asciz "CLASS SUMMARY"
.align 3
print_val_12:
    .asciz "Total Students : "
.align 3
store_val_0:
    .quad 0
.align 3
store_val_2:
    .quad 0
.align 3
store_val_4:
    .quad 0
.align 3
store_val_6:
    .quad 0
.align 3
store_val_8:
    .quad 0
.align 3
store_val_10:
    .quad 0
.align 3
store_val_12:
    .quad 0
.align 3
store_val_17:
    .quad 0
.align 3
store_val_22:
    .quad 0
.align 3
store_val_25:
    .quad 0
.align 3
store_val_27:
    .quad 0
.align 3
store_val_30:
    .quad 0
.align 3
store_val_34:
    .quad 0
.align 3
store_val_36:
    .quad 0
.align 3
store_val_39:
    .quad 0
.align 3
store_val_43:
    .quad 0
.align 3
store_val_45:
    .quad 0
.align 3
store_val_48:
    .quad 0
.align 3
store_val_52:
    .quad 0
.align 3
store_val_54:
    .quad 0
.align 3
store_val_57:
    .quad 0
.align 3
store_val_61:
    .quad 0
.align 3
store_val_63:
    .quad 0
.align 3
store_val_66:
    .quad 0
.align 3
store_val_70:
    .quad 0
.align 3
store_val_72:
    .quad 0
.align 3
store_val_75:
    .quad 0
.align 3
store_val_79:
    .quad 0
.align 3
store_val_81:
    .quad 0
.align 3
store_val_84:
    .quad 0
.align 3
store_val_88:
    .quad 0
.align 3
store_val_90:
    .quad 0
.align 3
store_val_93:
    .quad 0
.align 3
store_val_97:
    .quad 0
.align 3
store_val_99:
    .quad 0
.align 3
store_val_102:
    .quad 0
.align 3
store_val_106:
    .quad 0
.align 3
store_val_108:
    .quad 0
.align 3
store_val_111:
    .quad 0
.align 3
store_val_115:
    .quad 0
.align 3
store_val_117:
    .quad 0
.align 3
store_val_120:
    .quad 0
.align 3
store_val_124:
    .quad 0
.align 3
store_val_126:
    .quad 0
.align 3
store_val_129:
    .quad 0
.align 3
store_val_133:
    .quad 0
.align 3
store_val_135:
    .quad 0
.align 3
store_val_138:
    .quad 0
.align 3
store_val_142:
    .quad 0
.align 3
store_val_144:
    .quad 0
.align 3
store_val_147:
    .quad 0
.align 3
store_val_151:
    .quad 0
.align 3
store_val_153:
    .quad 0
.align 3
store_val_156:
    .quad 0
.align 3
store_val_160:
    .quad 0
.align 3
store_val_162:
    .quad 0
.align 3
store_val_165:
    .quad 0
.align 3
store_val_169:
    .quad 0
.align 3
store_val_171:
    .quad 0
.align 3
store_val_174:
    .quad 0
.align 3
store_val_178:
    .quad 0
.align 3
store_val_180:
    .quad 0
.align 3
store_val_183:
    .quad 0
.align 3
store_val_187:
    .quad 0
.align 3
store_val_189:
    .quad 0
.align 3
store_val_192:
    .quad 0
.align 3
store_val_196:
    .quad 0
.align 3
store_val_198:
    .quad 0
.align 3
store_val_201:
    .quad 0
.align 3
store_val_205:
    .quad 0
.align 3
store_val_207:
    .quad 0
.align 3
store_val_210:
    .quad 0
.align 3
store_val_214:
    .quad 0
.align 3
store_val_216:
    .quad 0
.align 3
store_val_219:
    .quad 0
.align 3
store_val_223:
    .quad 0
.align 3
store_val_225:
    .quad 0
.align 3
store_val_228:
    .quad 0
.align 3
store_val_232:
    .quad 0
.align 3
store_val_234:
    .quad 0
.align 3
store_val_237:
    .quad 0
.align 3
store_val_241:
    .quad 0
.align 3
store_val_243:
    .quad 0
.align 3
store_val_246:
    .quad 0
.align 3
store_val_250:
    .quad 0
.align 3
store_val_252:
    .quad 0
.align 3
store_val_255:
    .quad 0
.align 3
store_val_259:
    .quad 0
.align 3
store_val_261:
    .quad 0
.align 3
store_val_264:
    .quad 0
.align 3
store_val_268:
    .quad 0
.align 3
store_val_270:
    .quad 0
.align 3
store_val_273:
    .quad 0
.align 3
store_val_277:
    .quad 0
.align 3
store_val_279:
    .quad 0
.align 3
store_val_282:
    .quad 0
.align 3
store_val_286:
    .quad 0
.align 3
store_val_288:
    .quad 0
.align 3
store_val_291:
    .quad 0
.align 3
store_val_295:
    .quad 0
.align 3
store_val_297:
    .quad 0
.align 3
store_val_300:
    .quad 0
.align 3
store_val_304:
    .quad 0
.align 3
store_val_306:
    .quad 0
.align 3
store_val_309:
    .quad 0
.align 3
store_val_313:
    .quad 0
.align 3
store_val_315:
    .quad 0
.align 3
store_val_318:
    .quad 0
.align 3
store_val_322:
    .quad 0
.align 3
store_val_324:
    .quad 0
.align 3
store_val_327:
    .quad 0
.align 3
store_val_331:
    .quad 0
.align 3
store_val_333:
    .quad 0
.align 3
store_val_336:
    .quad 0
.align 3
store_val_340:
    .quad 0
.align 3
store_val_342:
    .quad 0
.align 3
store_val_345:
    .quad 0
.align 3
store_val_349:
    .quad 0
.align 3
store_val_351:
    .quad 0
.align 3
store_val_354:
    .quad 0
.align 3
store_val_358:
    .quad 0
.align 3
store_val_360:
    .quad 0
.align 3
store_val_363:
    .quad 0
.align 3
store_val_367:
    .quad 0
.align 3
store_val_369:
    .quad 0
.align 3
store_val_372:
    .quad 0
.align 3
store_val_376:
    .quad 0
.align 3
store_val_378:
    .quad 0
.align 3
store_val_381:
    .quad 0
.align 3
store_val_385:
    .quad 0
.align 3
store_val_387:
    .quad 0
.align 3
store_val_390:
    .quad 0
.align 3
store_val_394:
    .quad 0
.align 3
store_val_396:
    .quad 0
.align 3
store_val_399:
    .quad 0
.align 3
store_val_403:
    .quad 0
.align 3
store_val_405:
    .quad 0
.align 3
store_val_408:
    .quad 0
.align 3
store_val_412:
    .quad 0
.align 3
store_val_414:
    .quad 0
.align 3
store_val_417:
    .quad 0
.align 3
store_val_421:
    .quad 0
.align 3
store_val_423:
    .quad 0
.align 3
store_val_426:
    .quad 0
.align 3
store_val_430:
    .quad 0
.align 3
store_val_432:
    .quad 0
.align 3
store_val_435:
    .quad 0
.align 3
store_val_439:
    .quad 0
.align 3
store_val_441:
    .quad 0
.align 3
store_val_444:
    .quad 0
.align 3
store_val_448:
    .quad 0
.align 3
store_val_450:
    .quad 0
.align 3
store_val_453:
    .quad 0
.align 3
store_val_457:
    .quad 0
.align 3
store_val_459:
    .quad 0
.align 3
store_val_462:
    .quad 0
.align 3
store_val_466:
    .quad 0
.align 3
store_val_468:
    .quad 0
.align 3
store_val_471:
    .quad 0
.align 3
store_val_475:
    .quad 0
.align 3
store_val_477:
    .quad 0
.align 3
store_val_480:
    .quad 0
.align 3
store_val_484:
    .quad 0
.align 3
store_val_486:
    .quad 0
.align 3
store_val_489:
    .quad 0
.align 3
store_val_493:
    .quad 0
.align 3
store_val_495:
    .quad 0
.align 3
store_val_498:
    .quad 0
.align 3
store_val_502:
    .quad 0
.align 3
store_val_504:
    .quad 0
.align 3
store_val_507:
    .quad 0
.align 3
store_val_511:
    .quad 0
.align 3
store_val_513:
    .quad 0
.align 3
store_val_516:
    .quad 0
.align 3
store_val_520:
    .quad 0
.align 3
store_val_523:
    .quad 0
.align 3
store_val_527:
    .quad 0
.align 3
store_val_528:
    .quad 0
.align 3
store_val_532:
    .quad 0
.align 3
store_val_535:
    .quad 0
.align 3
store_val_537:
    .quad 0
.align 3
store_val_540:
    .quad 0
.align 3
store_val_544:
    .quad 0
.align 3
store_val_561:
    .quad 0
.align 3
store_val_568:
    .quad 0
.align 3
store_val_585:
    .quad 0
.align 3
store_val_592:
    .quad 0
.align 3
store_val_593:
    .quad 0
.align 3
store_val_595:
    .quad 0
.align 3
store_val_598:
    .quad 0
.align 3
store_val_602:
    .quad 0
.align 3
store_val_605:
    .quad 0
.align 3
store_val_609:
    .quad 0
.align 3
store_val_612:
    .quad 0
.align 3
store_val_616:
    .quad 0
.align 3
store_val_619:
    .quad 0
.align 3
store_val_623:
    .quad 0
.align 3
store_val_625:
    .quad 0
.align 3
store_val_628:
    .quad 0
.align 3
store_val_632:
    .quad 0
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

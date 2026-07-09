#ifdef _WIN32
#define ENTRY_MAIN main
#define C_OPEN _open
#define C_READ _read
#define C_WRITE _write
#define C_CLOSE _close
#define C_EXIT exit
#define C_PRINTF printf

    .macro LOAD_ADDR reg, sym
        adrp \reg, \sym
        add \reg, \reg, :lo12:\sym
    .endm
#else
#define ENTRY_MAIN _main
#define C_OPEN _open
#define C_READ _read
#define C_WRITE _write
#define C_CLOSE _close
#define C_EXIT _exit
#define C_PRINTF _printf

    .macro LOAD_ADDR reg, sym
        adrp \reg, \sym@PAGE
        add \reg, \reg, \sym@PAGEOFF
    .endm
#endif

#define _main ENTRY_MAIN
#define _open C_OPEN
#define _read C_READ
#define _write C_WRITE
#define _close C_CLOSE
#define _exit C_EXIT
#define _printf C_PRINTF

// -------------------------------------------------------------------------
// Compiler capacity limits (formerly hard-coded fixed-size tables). Raised so
// snc can compile large programs — a prerequisite for self-hosting. Both the
// backing array storage (`.space` in data.s) and the "too many ..." cap checks
// derive from these single definitions, so a cap and its storage can never
// drift out of sync. All backing storage lives in .bss (zero on-disk cost).
#define SNC_MAX_VARS    4096
#define SNC_MAX_OPS     32768
#define SNC_MAX_PRINTS  16384
#define SNC_MAX_FUNCS   256
#define SNC_SRC_BYTES   1048576

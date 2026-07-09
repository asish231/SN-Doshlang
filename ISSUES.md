# SNlang / `snc` — Status & Known Issues (verified)

_Last verified: 2026-07-09 on macOS ARM64 (Apple Silicon), clang toolchain._

This file replaces the previous marketing/status docs (`README.md`, `SNLANG_SPEC.md`,
`SYNTAX.md`), which claimed the language was "working", "FULLY IMPLEMENTED", and
"SELF-HOSTING READY". This document reports what is **actually** true, based on building
the real compiler in this repo, compiling small `.sn` programs, running the native
binaries, and comparing their printed output to the expected values.

> **Update (2026-07-09) — self-hosting prerequisites landed.** Several items the
> status paragraph below lists as "still blocks self-hosting" are now **done**,
> verified by `make assert` = **211/211 must-pass** and the examples sweep =
> **156/163 run OK** (the other 7 are deliberate negative tests):
>
> - **`system(cmd)` / `exec(cmd)` builtin** (op 114) — runs an external command and
>   returns its exit code (`0` = success); works for literal *and* dynamically-built
>   command strings. This lets a future self-hosted compiler invoke the assembler/linker.
> - **`argc()` / `argv(i)` builtins** (ops 115/116) — command-line arguments; the emitted
>   `_main` saves the host `argc`/`argv` into `_snc_argc`/`_snc_argv`.
> - **Fixed-table caps raised** (the former "#1 blocker"), centralized as macros in
>   `src/platform.inc`: variables `512`→`4096`, operations `4096`→`32768`, print
>   statements `2048`→`16384`, functions `32`/`64`→`256`, and the source buffer
>   `64KB`→`1MB`. Large stack frames and >4095-byte slot offsets now emit a register
>   form (`mov x16,#n; sub sp,sp,x16` and `mov x28,#off; sub x28,x29,x28`), so a single
>   function can actually use the larger budget (verified: a generated program with 100
>   functions, and one with 1000 locals + 3000 prints + a 66 KB source, all compile,
>   link, and run correctly).
> - Also confirmed working (previously listed as broken): `int + str` / `str + int`
>   concatenation, the `&&` operator, and **nested `fn` definitions**.
> - **Thread join via `wait()`** (op 117) — `spawn`ed threads are now recorded and joined by
>   `wait()` (which returns the count) instead of being detached and their output lost;
>   `spawn obj.method()` now reports a clear error instead of an empty one (section 2.23).
> - **Growable op & print tables (`malloc`-backed)** (section 2.24) — the recorded-operation
>   stream (`op_kinds`/`op_arg0..4`) and the print/data literal tables now `malloc`/`realloc`-
>   grow on demand instead of the fixed `SNC_MAX_OPS` / `SNC_MAX_PRINTS` caps; a generated
>   60k-op program and a 20k-print program compile, link, and run (the caps are now the
>   *initial* size, no longer a hard ceiling).
> - **`ord(s)` builtin** (op 118, section 2.24) — the ASCII code of a string's first
>   character, so SNlang programs can classify characters (digit/letter/space) — a hard
>   self-hosting prerequisite, since `s[i]` yields a 1-char string with no numeric value.
> - **First self-hosted component** — `selfhost/lexer.sn`, a tokenizer written IN SNlang,
>   compiled by `snc` and run via `make selfhost` (roadmap milestone M3 kicked off).
>
> Still open (see `SELF_HOSTING_ROADMAP.md`): the *remaining* static tables (variables,
> functions) and the runtime `list`/`map` pools becoming `malloc`-grown too, a real standard
> library, syscalls/FFI, and the compiler-in-SNlang + bootstrap proof.

> **One-line status:** the core back-end is **fixed** and now computes correct results for
> a broad set of programs — integers, variables, arithmetic with correct precedence,
> comparisons, `if`/`else` branch selection, `while` loops, `for`-in loops over lists,
> strings and string interpolation, lists, **and functions with integer arguments, return
> values and recursion** (see sections 3–4, and run `make assert` → **211 must-pass**). An
> intermittent compiler crash was also found and fixed (section 2.1), and the former
> **±256 stack-offset limit** for verified large function frames is now fixed (section 6).
> The language now runs real multi-function programs (e.g. recursive
> `factorial`/`fibonacci`) and a verified 40-local function frame. String methods
> `.upper()`/`.lower()`/`.contains()`/`.replace()` and char indexing `s[i]` all work
> (sections 2.4–2.5), and `file_read`/`file_write` now round-trip correctly with a
> deterministic, correct file permission every time — a real variadic-ABI argument-passing
> bug that made file permissions effectively random was found and fixed this pass
> (sections 2.6–2.7). This pass also made **`for-in` a real runtime loop** for
> integer/scalar lists (section 2.8): it no longer compile-time unrolls them, so it now
> works over list **parameters** (runtime element access + iteration — previously `0`) and
> over large lists without overflowing the op table, resolving the two former `make assert`
> xfails (`huge for-in unroll`, `param list for-in sum`). (String-element `for-in` keeps the
> proven compile-time unroll, since a str element is stored as a data-value id, not a
> runtime pointer.) What still blocks self-hosting is not syntax; it is remaining
> unverified/broken feature paths, fixed-size tables, and the missing standard library /
> FFI ecosystem (sections 4.2, 6, and 9).
>
> Current examples sweep after the latest fixes: **163 examples total; 156 compile, link,
> and exit successfully (exit 0); 7 compile failures; 0 link failures; 0 runtime crashes;
> 0 timeouts**. **All 7 remaining compile failures are deliberate negative tests** — the 6
> `decimals_invalid_*` programs and `map_missing_key_diagnostic`, all *supposed* to be
> rejected. Earlier "genuine gaps" listed here (nested `fn` definitions, `int + str` concat,
> `&&`, the alternate `name: [type]` parameter syntax) are now fixed; `spawn` works for the
> direct-call form (`spawn fn()`, joinable via `wait()`), while spawning a *method* is
> rejected with a clear error (section 2.23). So the project is much healthier, but **not
> complete and not self-hostable yet**.

---

## 1. How this was verified

- Clean rebuild: `make clean && make` → builds successfully (exit 0).
- For each case: `./snc file.sn > out.s` → `clang out.s -o bin` → run `bin` → compare stdout.
- The same failures reproduce on the committed `snc` binary and on the published
  releases (`v0.1.0`, `v0.2.0`, `v0.2.1`), so these are pre-existing defects in the
  compiler itself, not a build artifact.

---

## 2. FIXED — the root cause of the wrong-output epidemic

Previously the compiler emitted code that read uninitialised stack slots, so `print(5)`
printed a garbage address and almost every computed value was wrong. The cause was **not**
a value-materialisation gap in codegen (that code is emitted correctly); it was a single
**inverted check in the instruction recorder**.

`spawn_capture_fn_id` selects "are we currently capturing a spawned function body?".
`src/main.s` initialises it to `-1` (idle); it is set to a function id (`>= 0`) only while
capturing a `spawn` body. But `Lrecord_operation_common` (`src/vars.s`) routed ops to the
spawn tables when the id was **-1** (idle) instead of when it was `>= 0`:

```asm
    cmn x26, #1
    b.eq Lrecord_spawn_op     // BUG: diverts while IDLE (-1)
```

So the **first operation of every program** was diverted into the spawn tables with index
`-1` — an out-of-bounds write that also corrupted `spawn_capture_fn_id` to `0`, after
which later ops recorded "normally". Net effect: the first recorded instruction of every
program was silently dropped. For `print(5)` that was the `store 5` op, so `print` read an
uninitialised slot.

**Fix:** invert the check to `b.ne` (route to the spawn tables only while actually
capturing a spawn body). A second bug in `Lprimary_number` (`src/parser.s`) used the
`_define_variable` error flag (`x0`, always `0` on success) as the temp slot, so every
integer literal aliased slot 0 (why `10 + 4 * 3` printed `0`); it now uses the real slot
returned in `x4` and preserves the literal's value/type on return.

### 2.1 FIXED — an intermittent compiler crash (`match_span_span` SIGSEGV)

While making functions/recursion work, temp variables became common
(`_allocate_temp_var`), and the compiler began crashing **intermittently** in
`match_span_span` (fault addresses like `0x96`/`0x0`) on some programs — a classic
uninitialised-memory-used-as-pointer signature that surfaced only in certain call
contexts (e.g. the example sweep). Two independent root causes:

- `_allocate_temp_var` (`src/vars.s`) zeroed `var_types`/`var_lengths` but **left
  `var_name_lens`/`var_name_ptrs` holding stale garbage**. When `_lookup_variable` later
  scans every variable, a temp whose garbage name length happened to equal the query
  length made it call `_match_span_span` on a garbage name pointer → SIGSEGV. Fix: also
  zero the temp's name length and pointer, so a temp never matches a real (non-empty)
  name lookup, and `_match_span_span` never dereferences a zero-length span.
- All `_record_operation*` variants set/consume `x25` (op arg4) but **only saved
  `x19..x24`**, silently clobbering the caller's `x25` on every recorded op. This
  corrupted the `for-in` loop-variable name length (and string interpolation), and
  combined with the temp garbage above. Fix: save/restore `x25`/`x26` in every variant
  and the shared epilogue.

### 2.2 FIXED — a trailing value/declaration at end-of-file was falsely rejected

Any program whose **last token before EOF was a value** (e.g. a top-level `int r = 5`
with no trailing statement, `str s = "hi"`, or `int z = 2 + 3` as the final line) was
rejected with a spurious `error: expected expression` / `error: expected statement`,
even though the same program compiled fine when a `;` or another statement followed.

Root cause was in `_parse_primary_value` (`src/parser.s`). After parsing a primary and
checking for a `.`/`[` suffix, the no-suffix exit branched to `Lprimary_return` **without
setting the success flag `x0`**:

```asm
Lprimary_suffix_loop_start:
    bl _skip_whitespace
    bl _peek_char            // x0 = next char (or 0 at EOF)
    cmp w0, #'.'  ...
    cmp w0, #'['  ...
    mov x1, x25              // returns value/type/... but NOT x0
    b Lprimary_return        // x0 is whatever _peek_char left behind
```

So the routine returned the **last peeked character as its status**. For any trailing
character (`;`, `)`, `}`, an operator, the next statement) that is non-zero → truthy →
accidental success. But at EOF `_peek_char` returns `0`, so `x0 = 0` → callers
(`_parse_power_value` → `_parse_term_value` → `_parse_expr_value`) all read it as a parse
failure and reported a bogus error. **Fix:** set `mov x0, #1` on that no-suffix exit path
so success is explicit regardless of the peeked char. Verified with three new must-pass
assertions (`trailing int/str/arith decl eof`) — programs that end in a bare declaration
now compile and produce the correct output.

### 2.3 FIXED — comparisons as values, builtin words as identifiers, variable member access

Three independent, high-impact front-end bugs were found and fixed this pass. All are in
`src/parser.s`; none change the language syntax. Together they took the example sweep from
**129 → 143** passing and added **16 must-pass** assertions.

**(a) Comparisons now work as first-class values.** The parser had two separate expression
grammars: a *value* grammar (`_parse_expr_value → _parse_term_value → _parse_power_value →
_parse_primary_value`) that only understood arithmetic, and a *condition* grammar
(`_parse_condition_value`/`_parse_condition_atom`, used only by `if`/`while`/`for`) that
understood `== != < > <= >=` and `and`/`or`. So a comparison used as a value was rejected:

```
print(n > 0)          // error: expected character )
bool b = n > 0        // error: type mismatch
fn pos(int n)->bool { return n > 0 }   // error: expected statement
```

Fix: the additive layer was renamed `_parse_addsub_value`, and a new `_parse_expr_value`
wrapper runs it and then, if a single relational operator follows, lowers `L <cmp> R` into
a runtime `0/1` boolean temp using the **exact same ops (39 cmp-imm / 40 cmp-var)** the
condition parser already emits. `==`/`!=` are recognised only via a two-char lookahead so
a lone `=` (assignment) is never consumed, and `_parse_condition_atom` now parses its
operands through `_parse_addsub_value` so conditions are byte-for-byte unchanged.

**(b) `value`/`address`/`alloc`/`cast` are usable as ordinary identifiers.** These
call-only builtins were matched as keywords in `_parse_primary_value` regardless of
context, so a program could never name a variable/parameter/loop `value` (extremely common
in DSA code) — `int value = n … while (value > 0)` failed with `expected character (`. Fix:
a non-consuming `_lookahead_is_lparen` guard makes each of these a keyword **only when
immediately applied as a call** (`value(p)`, `cast(x,str)`); otherwise it is a normal
identifier. The `value(...)`/`address(...)`/`alloc(...)`/`cast(...)` builtins still work
(verified: `tests/ptr_test.sn` → `42 42 100 5`).

**(c) Member access on a variable is no longer swallowed by module-qualified access.** In
`Lprimary_identifier`, *any* identifier followed by `.` was unconditionally parsed as
`module.func()`, so `v.length`, `v.length()`, `v.slice(a,b)`, and object `obj.field` /
`obj.method()` on a variable never reached the suffix-loop member handler — they failed
with `expected expression`. (The `.length`/`.slice` support existed but was unreachable for
variables; only literals like `"abc".slice(...)` could reach it.) Fix: on seeing `.`, first
`_lookup_variable`; if the identifier is a known variable, take the member-access path, and
only fall through to module-qualified access when it is **not** a variable. Unqualified
`use module` calls still work (`testmod_caller` → `30`); dotted `module.func()` was already
non-functional in both the committed binary and this one (not a regression).

**Update:** the `for-in` compile-time-unroll limitation described here is now **FIXED for
integer/scalar lists** — `for-in` over such lists is a real runtime loop (see section 2.8),
so it works over list **parameters** and over large lists. `for-in` over a **string** list
still uses the compile-time unroll (a str element is stored as a data-value id, not a
runtime pointer). `.length()` on a list **parameter** also works. See section 2.8 for the
full details.

### 2.4 FIXED — string methods `.upper()`/`.lower()`/`.contains()` and char indexing `s[i]`

The string surface is now much more complete. Four separate defects were found and fixed
this pass:

**(a) The runtime helpers were never emitted (link failure).** The parser recorded ops for
`.upper()` (100), `.lower()` (101), and `.contains()` (97), and codegen emitted `bl
_str_upper` / `bl _str_lower` / `bl _str_contains`, but **no runtime bodies for those
symbols existed anywhere** — so every program using them failed to *link*. Fix: added an
`asm_string_methods_runtime` blob in `src/data.s` (hand-written ARM64 for `_str_upper`,
`_str_lower`, `_str_contains`, using the existing null-terminated-`char*` string ABI and
`_cstring_length`/`_malloc`) and emit it from `Lemit_emit_runtime_helpers` in
`src/codegen.s`, right after the slice runtime.

**(b) `.upper()`/`.lower()` recorded the wrong source operand.** They called
`_record_operation2`, which hard-codes `arg1 = -1` (it only stores an op + `arg0`), so the
source var passed in `x2` was silently dropped; codegen then loaded slot `-1` (offset 0)
and the helper received frame garbage → empty output. Fix: use `_record_operation` (3-arg:
op, `arg0`=dest, `arg1`=source).

**(c) The source operand was read from a stale register.** The string-method handlers read
the source from the live `x25/x27/x28`, but those are only reliable for the
earliest-dispatched member (`.slice`, `.contains`); by the time the later
`.upper()`/`.lower()` checks in the `_match_cstr_span` dispatch chain ran, they no longer
held the source. Fix: snapshot the primary's `value/len/var` into
`member_src_val`/`member_src_len`/`member_src_var` at `Lprimary_member_access` entry
(before the dispatch chain), and a shared `_str_method_prepare_source` helper reads that
snapshot (materializing a literal source into a temp var via op 72 when needed). The
`.contains()` substring literal is likewise materialized into a temp var and passed as a
bit63-tagged var arg, instead of being emitted as an invalid `mov x1, #<huge-address>`.

**(d) String char indexing `s[i]` was rejected outright.** The indexing dispatch only
handled `map`/`list`. Added a `str` branch that lowers `s[i]` to a new op 102
(`_str_char_at`) which returns a fresh 1-char string; the index is passed as an immediate
(constant) or a bit63-tagged var slot so loop/runtime indices work, and an out-of-range
index returns an empty string (no crash).

Verified (`make assert`, MUST-PASS): `s.upper()`→`HI THERE`, `s.lower()`→`hi there`, mixed
case preserved, literal `"abc".upper()`→`ABC`, `s.contains("ell")`→`1` / `"xyz"`→`0` /
variable substring→`1`, chaining `s.upper().slice(0,3)`→`HEL`, and `s[0]`/`s[4]`/`s[i]`/
`"world"[2]` all return the correct character.

### 2.5 FIXED — string `.replace(old, new)`

`.replace()` was a stub: the parser passed the `old`/`new` operands as raw literal values
(so codegen would have emitted invalid `mov` of a huge address), codegen never loaded the
arguments into registers, and **no `_str_replace` runtime body existed anywhere** (so any
use would have link-failed). Fixed end-to-end, mirroring the `.contains()` approach:

- **Parser** (`Lprimary_str_replace`, `src/parser.s`): snapshot/materialize the source via
  `_str_method_prepare_source`, then materialize each of `old`/`new` into a temp var (a new
  shared helper `_str_method_materialize_arg` records the literal via op 72 when needed) and
  pass them as bit63-tagged var slots as `arg2`/`arg3` of op 98.
- **Codegen** (`Lemit_op_str_replace`, `src/codegen.s`): load source→`x0`, old→`x1`,
  new→`x2` from their stack slots, `bl _str_replace`, store the returned pointer to the dest.
- **Runtime** (`asm_string_replace_runtime`, `src/data.s`): a hand-written ARM64
  `_str_replace` that does a first pass counting non-overlapping matches to size the result
  buffer exactly (`src_len + matches*(new_len-old_len)`), then a second pass building the
  output; empty/absent `old` returns a copy, a null source returns an empty string.

Verified (`make assert`, MUST-PASS): `"hello world".replace("world","there")`→`hello there`,
`"aaa".replace("a","bb")`→`bbbbbb` (growing), `"a.b.c".replace(".","/")`→`a/b/c`, variable
`old`/`new` (`heLLo`), deletion `"banana".replace("an","")`→`ba`, and no-match returns the
original. `.split()` (returns a list) is now **also implemented** — see section 2.10.

### 2.6 FIXED — `file_read`/`file_write` wiring (type reporting + runtime string length)

`file_write(path, data)` and `str c = file_read(path)` were previously rejected or silently
broken:

- `file_read`'s result type was reported in the wrong register for the compilation-mode
  expression path (which reads the type from `x2`), so `str c = file_read(...)` failed the
  `cmp x2,#2` check in `Lstmt_str` and was rejected as a type mismatch. Fixed by reporting
  `str` (2) in both `x1` and `x2`.
- `file_write`'s codegen (`Lemit_op_file_write`, `src/codegen.s`) never loaded the data
  length into `x2` before calling the runtime, so every write wrote **0 bytes** regardless
  of content. Fixed by emitting a `strlen(data)->x2` preamble (`asm_file_write_len_prep`)
  that preserves `x0`/`x1` across the `_cstring_length` call.
- `.length` on a string whose length is only known at **runtime** (a `str` parameter, a
  `+` concatenation result, or a `file_read` result) returned stale compile-time metadata
  (`0`/garbage) instead of the real length. Fixed by emitting a new op 103
  (`_cstring_length` computed at runtime) whenever the string lives in a variable/temp
  slot; a bare string literal still folds `.length` at compile time.

Verified (`make assert`): `file_write`+`file_read` round-trips content correctly, and
`.length` on a `str` parameter / concatenation / `file_read` result all return the correct
runtime value (`5` / `5` / `11`) instead of `0`/garbage.

### 2.7 FIXED — `file_write` silently created files with random/broken permissions

Even after 2.6, a program that did `file_write` then `file_read` **on the same path**
was flaky: it worked in some runs and printed `(null)` in others — and `make assert`
caught this as a real, repeatable regression (not flakiness in the test harness itself).

**Root cause:** `open()`'s third parameter, `mode`, is **variadic**
(`int open(const char *, int, ...)`), and Apple's AArch64 calling convention — unlike the
generic AAPCS64 rule of using registers for the first 8 integer args — requires that
**variadic arguments always be passed on the stack, never in a register**. The `_file_write`
runtime embedded in every compiled program (`asm_runtime_helpers`, `src/data.s`) did
`mov x2, #0644` then `bl _open` directly; `open()` never reads a variadic argument from a
register, so it read whatever **garbage happened to be on the stack** at the call site as
the new file's permission bits. This was proven with a minimal isolated `open()`
reproduction: freshly created files came out with permissions like `-r--r-x---` (`0450`),
`------x---` (`0010`, **zero** owner access), or `-rwx--x---` (`0710`) — never the intended
`0644` — and the exact bits varied run to run. When the garbage happened to include
owner-read, a later `file_read` in the same run succeeded "by luck"; when it didn't (as
with `0010`), `_open(O_RDONLY)` failed with `EACCES` and `file_read` returned `NULL`,
which `print`s as `(null)`. This fully explains the intermittent pass/fail pattern.

**Fix:** push `mode` onto the stack before calling `_open`
(`sub sp,sp,#16 / str x2,[sp] / bl _open / add sp,sp,#16`), matching Apple's calling
convention for the variadic argument. Verified with the same minimal reproduction that this
changes the resulting permissions from random garbage to the correct, deterministic `0644`
on every run. Applied to the runtime actually used by compiled programs
(`asm_runtime_helpers` in `src/data.s`); the identical, previously-unused/dead `_file_write`
in the compiler's own `src/utils.s` was fixed the same way for consistency (nothing in the
compiler currently calls it, but it is the obvious place someone would wire up an `-o`-style
feature later, and it would silently reproduce the same bug).

Verified: all file-I/O assertions (write+read, read into a variable, rewrite/truncate,
`.length` of a `file_read` result) now pass **consistently** across repeated `make assert`
runs (previously 3 of them failed intermittently — 91/94 and then 91/94 again before the
fix, 94/94 after, reproduced twice). The full `examples/` sweep improved from 143→144 OK
with 0 new link or runtime failures (section 5).

### 2.8 FIXED — `for-in` is now a real runtime loop (list parameters + huge loops)

`for-in` used to be **compile-time unrolled**: the loop body was re-parsed and re-recorded
once per element, reading each element's value straight out of the compile-time
`list_pool_values` arrays at `base + i`. That had two consequences:

- **List parameters yielded `0`.** A `list<int>` parameter carries only its pool *base* as a
  runtime value (its element count is known, but the loop indexed the wrong pool slots at
  compile time), so `fn f(list<int> xs){ int s=0 for (v in xs){s=s+v} return s }` returned
  `0` instead of the sum.
- **Large loops overflowed the fixed op table.** `elements × body-ops` unrolled operations
  quickly hit the 4096-op cap ("too many operations").

**Fix (`src/parser.s`, `src/codegen.s`, `src/data.s`):** for integer/scalar element lists,
`for-in` now emits a genuine runtime loop instead of unrolling. `_parse_for_iterable_value`
additionally returns the iterable's **source variable slot** (from `_parse_expr_value`'s
`x4`), which lets the new `_emit_for_in_runtime_loop` detect a list **parameter** (slot
inside the current function's `fn_scope_bases..+fn_param_counts` range). The loop is built
from existing ops plus one new op:

- allocate a counter slot (`idx = 0`) and a count slot — a compile-time constant for a local
  list, or a **runtime** `list_length` (op 81) for a parameter;
- `op 36` start label → `op 40` `idx < cnt` → `op 37` branch-out-if-false →
  `op 80` `loop_var = list[base + idx]` (base is an immediate for a local list, or the
  parameter's runtime slot with the base-is-var flag) → **body parsed once** →
  `op 46` continue label (the `skip` target) → **new `op 104`** `idx = idx + 1` →
  `op 38` branch-back-and-place-end;
- `stop`/`skip`/`return` inside the body are handled by `_parse_statement` via the
  `current_loop_start`/`current_loop_end` globals, exactly like the counted `for` loop.

Because the body is emitted **once**, iteration count no longer affects the op table, so
arbitrarily large loops work. **String**-element `for-in` intentionally keeps the
compile-time unroll (a str element is stored as a data-value id, not a runtime pointer, so
`op 80` cannot load it as a runtime string) — this preserves the pre-existing, working
behavior (e.g. `for (fruit in ["Apple","Banana"])`).

Verified (`make assert`, MUST-PASS, promoted from the two former xfails): `for-in` over a
list **parameter** sums correctly (`10`) and prints element expressions (`50 60 70`); a
**400-element** loop sums to `80200`, and a 400-element loop with a multi-statement body
sums to `401000` — neither overflows the op table. Mixed int+str `for-in` in one program
(`examples/for_loop.sn`) prints `... 7 8 10 Apple Banana` correctly.

### 2.9 FIXED — block `try` / `catch` / `throw` (real runtime error handling)

Block `try { A } catch (e) { B }` was previously a stub that only errored out. It now
compiles to a genuine runtime error path — but landing it required fixing **three** codegen
bugs that made every `try` program either fail to link or exit early:

- **op 35 was misused as an unconditional jump.** The parser recorded `op 35` for both the
  throw's "jump to catch" and the try body's "success → skip the catch block". But `op 35`
  (`Lemit_op_if_end`) *places* a label — it does not branch. So the `Lend` label was placed
  **twice** (once by the stray `op 35`, once by the real `op 36`), producing a duplicate
  `L_snl_<table>_1` that the assembler rejected (`already defined`), and there was no actual
  branch skipping the catch on the success path. Fixed by using **`op 41`** (`Lemit_op_jump`,
  a real unconditional `b`) at both sites.
- **op 106 (error-branch) emitted a table-less label.** It wrote `b.ne L_snl_<id>` from a
  bare number (via `asm_beq_label` = `"    b.ne L_snl_"`), producing e.g. `L_snl_0`, which
  never matched the placed catch label `L_snl_<table>_0`. Fixed by emitting the target through
  `_emit_label_name` (new `asm_bne_prefix` = `"    b.ne "`), giving the proper
  `L_snl_<table>_<id>` form.
- **The catch-label sentinel collided with a real label id of 0.** `current_catch_label` is
  BSS-zeroed and `0` meant "not inside a try", but `_get_next_label` legitimately hands out id
  `0` for the first label — so a `throw` inside the very first `try` saw `current_catch_label
  == 0`, took the top-level `op 95` path, and **`_exit`ed the program** instead of jumping to
  the catch. Fixed by storing the catch label as **`id + 1`** (0 stays the clean "no try"
  sentinel; `throw` subtracts 1 to recover the true id).

Finally, the caught variable `e` printed `(null)`: `op 108` (throw-no-exit) stored the
message's **data-value id** into `error_value`, but a `str` variable holds a runtime **char\*
pointer**. `op 108` now materializes the pointer to `print_val_<id>` (same pattern as
`Lemit_op_store_str_lit`) and stores that, so `e` prints the message.

Semantics implemented: `try` clears `error_flag` on entry (`op 105`); a `throw` inside the
body sets `error_value`/`error_flag` without exiting (`op 108`) and jumps to the catch
(`op 41`); after the body a residual `error_flag` (from a built-in runtime error) also enters
the catch (`op 106`); `catch (e)` binds `e` to the message and clears the flag (`op 107` +
`op 105`); `catch { … }` without a variable is supported; nested `try` blocks save/restore
`current_catch_label` correctly.

Verified (`make assert`, 8 new MUST-PASS): `throw`+`catch(e)` printing the message then
continuing (`boom 7`), no-throw skipping the catch (`1 3`), `catch` without a var (`5`),
catch-body side effects (`2`), nested try (`1 2`), throw after successful statements
(`8 late`), `e` inside interpolation (`err=bad`), and two sequential trys (`one two`).
`make assert` is now **106/106 must-pass with 0 known-broken**, and the full `examples/`
sweep is unchanged at **144 OK / 0 link failures / 0 runtime failures**.

### 2.10 FIXED — string `.split(sep)` → a real, iterable `list<str>`

`list<str> parts = s.split(",")` was previously a **stub**: its codegen never marshalled
the separator argument and it returned a bogus list type, so a real program did not even
compile (`type mismatch` on the `list<str>` binding). The blocker was architectural — a
list was pure **compile-time** metadata (element values folded into `list_pool_values` at
compile time), but a split's pieces and their **count** are only known at run time.

**Fix (`src/parser.s`, `src/codegen.s`, `src/data.s`):** split now produces a genuine
runtime list without abandoning the existing pool model:

- **Reserved pool block.** At parse time (`Lprimary_str_split`) a fixed-capacity block of 64
  slots is reserved in `list_pool_values`; its **base** is a compile-time immediate, so
  indexing (`parts[i]`) and for-in keep using the existing base+index addressing.
- **Runtime-count flag.** A new compiler-side table `list_base_is_runtime[base]` marks that
  block's element count as runtime-only. `.length()` (`Lprimary_list_length_val`) and
  `for-in` (the count slot in `_emit_for_in_runtime_loop`) check this flag and, when set,
  emit a runtime `list_length` (op 81) that reads `list_base_counts[base]` instead of
  folding the reserved capacity.
- **`str` for-in switch.** String-element for-in normally uses the compile-time unroll (a
  str literal element is a data-value id, not a pointer); a split list instead holds real
  runtime `char*` pointers, so for-in over a runtime-count str list now takes the **runtime
  loop** (op 80's str path loads the pointer directly).
- **Runtime `_str_split` (`asm_string_split_runtime`, `src/data.s`).** A hand-written ARM64
  routine that scans the source for the separator, `malloc`s and copies each piece into
  `list_pool_values[base + k]`, and writes the piece count to `list_base_counts[base]`.
  Handles multi-char separators, no-match (one piece = the whole string), trailing/empty
  pieces, and the empty source; capped at the reserved 64 pieces.

Verified (`make assert`, 10 new MUST-PASS): `.length()` of a split (`3`), indexing
(`a`/`b`/`c`), for-in over a split (`x y z`), multi-char separators (`a::b::c`→`3`, `b`),
no-match (`nosep`→`1`), trailing separator (`x,y,`→`3`), variable source, interpolation in
the loop body (`c=red c=green`), per-element `.length()` summation (`6 3`), and chaining a
string method onto an element (`p[0].upper()`→`AB`). `make assert` is now **116/116
must-pass with 0 known-broken**, and the `examples/` compile sweep is unchanged
(**144 compile-OK**, no regressions vs the committed binary).

### 2.13 FIXED — blueprint methods that use `self.field` no longer abort the whole program

Defining a `blueprint` whose method reads or writes `self.field` (e.g.
`fn get() -> int { return self.value }`) used to make the **entire program fail to compile**
with a misleading `error: expected expression on line 3` — it aborted before `main` was
even parsed, so *any* program containing such a blueprint was rejected.

**Root cause.** Two independent registrations of each method collided:
- The blueprint-specific preparse registers the method under its **synthetic** name
  (`Blueprint__method`) and the main pass (`_parse_blueprint_member`) tags that entry with the
  blueprint id, so `self` binds when its body is compiled.
- But the **general** fn preparse *also* registers a **plain-named** stub (`get`) for the same
  `fn` (it doesn't know the `fn` sits inside a blueprint), leaving its `fn_blueprint_ids` at
  `-1`. That stub's body cursor points at the very same method body, so
  `_parse_function_body` later re-parsed `return self.field` as an **ordinary** function with
  no `self` bound — `self` failed to resolve, the primary parser reported "expected
  expression", and the whole compile aborted.

**Fix (`src/parser.s`, `src/data.s`).**
- Each blueprint now gets a **definition-time template instance** (`blueprint_template_instances`,
  created at `Lblueprint_body_done` via `_reserve_object_instance` + `_instantiate_object_fields`).
  While a method body is compiled standalone (dead-but-must-assemble code), `self` is bound to
  this template so `self.field` resolves to valid var slots.
- `_parse_function_body` binds `self` (type=object, meta=blueprint id, instance=template) for
  method bodies and explicitly clears any stale `self` for ordinary functions.
- Method registration uses the **actual** fn index just defined (`last_fn_def_index`) rather
  than `fn_count-1` (wrong when the preparse stub is reused), and now **also tags the
  plain-named stub** with the blueprint id (via `_lookup_function`) so its dead body binds
  `self` and assembles cleanly instead of aborting.

**Result.** Programs with self-using blueprint methods now compile and run.
**DIRECT per-instance field access is fully correct** and is locked in with 4 new MUST-PASS
assertions: constructor-style named init (`C c(value: 7)` → `c.value` = `7`), two independent
instances (`3`/`8`), direct reassignment (`c.value = 5` → `5`), and multiple fields
(`P p(x: 2, y: 9)` → `2 9`).

**Follow-up:** the per-instance method limitation noted here has since been resolved — see
**section 2.14**.

### 2.14 FIXED — blueprint methods using `self.field` are now PER-INSTANCE

Section 2.13 left one limitation open: method-based `self.field` access compiled and ran but
operated on the shared definition-time template's storage, so `a.bump()` changed what
`b.get()` returned and a getter never saw a constructor-initialised value. That is now fixed:
object method calls are **per-instance**.

**Fix (`src/parser.s`).** A method call `obj.method(...)` is compiled by `_call_object_method`,
which:
- Saves the current `self` (`current_self_instance`/`current_self_type`/`current_self_meta`),
  then **binds `self` to the caller's actual instance** (`x19` = the resolved instance id,
  type, blueprint id).
- Attempts a **per-instance inline dispatch** (`_inline_object_method`): the method body is
  inlined at the call site with `self` pointing at *this* instance, so every `self.field`
  read/write resolves to that instance's own field slots. The method's value is returned in a
  runtime result slot (`x4`), matching the `_call_function` convention, so
  `print(a.get())` observes this instance's computed value (previously it read the shared
  template's compile-time `fn_return_value`, i.e. the default `0`).
- Restores the previous `self` afterwards.

At the call site (`Lprimary_member_object_method`) the result is taken from the runtime slot
(`x28`) rather than the old compile-time `fn_return_value`.

**Result.** Getters see constructor values, setters mutate only their own instance, two
instances stay isolated, methods compose (a method calling another method), and methods work
inside larger expressions. Locked in with 5 new MUST-PASS assertions (see
`tests/assert_suite.sh`, "obj method …"):

| Program | Output |
|---|---|
| `C c(value: 7)  c.get()` | `7` (getter sees constructor value) |
| `Counter c(value: 10)  c.add(5)  c.add(3)  c.get()` | `18` (setter mutates instance) |
| `a(value:10) b(value:20)  a.bump()  a.get() b.get()` | `11 20` (isolation) |
| `a.sum() + b.sum()` (two instances) | `33` (method in expression) |
| `Box b(v:9)  b.doubled()` where `doubled` calls `self.get()` twice | `18` (method calling method) |

**KNOWN LIMITATION (documented, not faked).** The constructor path (`create`) and any
**un-inlinable** case — notably a method that **recurses on itself** or nests method inlining
too deeply — fall back to the shared template-self `bl` dispatch, so a self-recursive method
(e.g. `fn countdown(){ … return self.countdown() }`) still returns the template default rather
than a per-instance result (it does not crash). Ordinary (non-recursive) method calls, which
are the common case, are fully per-instance. `make assert` is now **134/134 must-pass with 0
known-broken**; the `examples/` compile+link sweep is **152/162 OK, 0 link failures** (no
regressions).

### 2.15 FIXED — `str(x)` builtin converts a value to its string form

`str(...)` used to fail with `error: unknown function: str` — there was no int/bool→string
conversion function, even though string **interpolation** (`"{x}"`) already converted values
to text internally.

**Fix (`src/parser.s`, `src/data.s`).** Added `str` as a built-in call in `_call_function`
(checked alongside `file_read`/`file_write`, before user-function lookup). It parses the
single argument and:
- **int / bool** → reuses the interpolation conversion path (`_emit_cast_op`, op 73
  `int_to_str`), producing a string in a fresh temp slot. An immediate operand is first
  materialised into a slot (the op reads its source from a variable slot). A `bool` renders
  as its `0`/`1` integer value, consistent with `print(bool)`.
- **str** → returned unchanged (pass-through).

Locked in with 7 MUST-PASS assertions (`str of int lit/var/expr/negative`, `str of bool`,
`str passthrough`, `str in concat`). Examples: `str(42)`→`42`, `str(a+b)`→`7`,
`str(0-9)`→`-9`, `str(true) str(false)`→`1 0`, `"n=" + str(n)`→`n=5`.

### 2.16 FIXED — `len(x)` builtin returns a list's element count / a string's length

`len(...)` used to fail with `error: unknown function: len`. It is now a built-in that mirrors
the existing `.length` member exactly:
- **string** → op 103 (`str_length_runtime`) for a runtime string (variable, concatenation,
  `file_read`/split result), or the compile-time length for a bare literal.
- **list** → op 81 (`list_length_runtime`) for a runtime list — a **list PARAMETER** (its
  slot is in the current function's parameter range) or a **`str.split` result** (detected by
  its runtime base flag in `list_base_is_runtime`, checked *before* the slot path so a split
  result reports its real count, not its reserved capacity) — or the compile-time count for a
  list literal / local list.

Locked in with 10 MUST-PASS assertions. Examples: `len("hello")`→`5`, `len(a+b)`→`5`,
`len([1,2,3,4])`→`4`, `len(local_list)`→`3`, `len(list_param)`→`5`,
`len("a-b-c-d".split("-"))`→`4`, `len(a)+1`→`4`, and combined `"len=" + str(len(a))`→`len=2`.

### 2.17 FIXED — `x++`/`x--` and compound assignment on object fields

Two related assignment gaps are now closed. Compound assignment on **plain variables**
(`x += 1`, `x -= 1`, `x *= 2`, …) already worked, but two adjacent cases did not:

- **`x++` / `x--`** were rejected with `error: expected character: =`. At statement level the
  parser, on seeing `+`/`-` after an identifier, jumped straight into the compound-assign
  handler which consumes the operator and then *demands* `=` — so `x++` (a second `+`, not
  `=`) failed. Fixed (`src/parser.s`, `Lstmt_assign_plus`/`Lstmt_assign_minus`) by looking
  one char ahead: a doubled `++`/`--` is lowered to `x += 1` / `x -= 1` (reusing the existing,
  tested compound eval/record/set path with an immediate `1`), while a single `+`/`-` still
  falls through to the normal `+=`/`-=` path.
- **`obj.field OP= rhs`** (and `self.field OP= rhs`, `obj.field++`) were rejected the same
  way: the object-field assignment path only accepted `=`. Fixed by adding a compound branch
  (`Lstmt_object_field_op_*` → `Lstmt_object_field_compound_common`). A field is backed by a
  real variable slot, so the compound form is lowered to the **same runtime compound ops
  (23–32)** used for plain variables, computed on that backing slot. Because those ops re-run
  against the caller's actual instance during per-instance method inlining, `self.value += 1`
  inside a method mutates **only that instance** (verified isolation).

This also makes `examples/spawn_blueprint_fix.sn` (a `Counter` blueprint whose
`increment()` method does `self.value += 1`) compile and run for the first time, printing
`3`. Locked in with 13 MUST-PASS assertions (`incr op`, `decr op`, `incr in while`,
`decr countdown`, `multi incr`, `field += direct`, `field -= direct`, `field *= direct`,
`field ++ direct`, `field += var rhs`, `self.field += method`, `self.field += n`,
`field += isolation`). `make assert` is now **164/164 must-pass, 0 known-broken**; the
`examples/` sweep is **153/162 OK, 0 link failures, 0 runtime failures** (up from 152; the
9 remaining compile-rejections are the 6 deliberate `decimals_invalid_*` negative tests, the
deliberate `map_missing_key_diagnostic`, and the two alternate-dialect programs
`binary_search`/`hard_dsa_suite`).

### 2.18 FIXED — parentheses around `if`/`while`/`for` conditions are now optional

The parser used to **hard-require** `(` after `if`, `else if`, `while`, and `for`
(`if x > 3 { … }` failed with `error: expected character: (`), so only the
fully-parenthesized forms were accepted. Parentheses around the condition / loop-header
are now **optional** for all of them, matching the paren-less dialect used by programs like
`binary_search`/`hard_dsa_suite` (and generally more ergonomic):

- **`if` / `else if`** (`_parse_if_statement_after_keyword`): peek for `(`; consume it only
  if present, and require the matching `)` only when a `(` was seen. The condition still
  terminates at `{` either way (the expression parser stops at `{`).
- **`while`** (`_parse_while_statement_after_keyword`): the opening `(` and closing `)` are
  each consumed only if present (a bare `{` terminates the condition).
- **`for`** (`_parse_for_statement_after_keyword`), both shapes: the header `(` is optional;
  the for-in close `)` is consumed only if present; and the C-style update-text scan now
  stops at `{` as well as `)`, so `for i=0, i<3, i++ { … }` (no parens) parses while
  `for (i=0, i<3, i+=1) { … }` still works.

Fully-parenthesized forms are unchanged (including wrapped compound conditions like
`while (i < 3 and j > 0)` and doubled parens `if ((x > 3))`). Locked in with 12 new
MUST-PASS assertions (`if no parens`, `if no parens false`, `else if no parens`, `if parens
still`, `while no parens`, `while noparen accum`, `while parens still`, `for-in no parens`,
`for-in noparen param`, `cstyle for no parens`, `cstyle for noparen +=`, `for-in parens
still`). `make assert` is now **176/176 must-pass, 0 known-broken**; the `examples/` sweep
is unchanged at **153/162 OK, 0 link failures, 0 runtime failures**.

### 2.19 FIXED — runtime list-element writes (`list[i] = v`) + in-place mutation

Writing a list element used to only work for a **constant** index into a **local literal**,
because the index-assign path (`Lstmt_index_assign_list`, `src/parser.s`) folded the write
into the list's emitted *initial data* at compile time. A **variable/computed index** read
the index temp's compile-time value (usually `0`/garbage), and a write to a **list
parameter** did nothing. So `a[i]=v`, `a[row*9+col]=num`, filling a list in a loop, swapping
elements, and mutating a list passed into a function were all silently wrong — which is why
in-place algorithms (sorting, and the recursive Sudoku solver) failed.

Fixed with a real **runtime store** (new **op 109**, `Lemit_op_list_store` in `src/codegen.s`,
mirroring the op-80 load): it computes `list_pool_values[base + index] = rhs` at run time,
taking the index as an immediate or a slot, the base as an immediate pool base (local list)
or a runtime base var slot (list **parameter**, whose runtime value *is* the pool base), and
the rhs as an immediate or slot. The parser now:

- emits op 109 whenever the index is a variable, the target is a list **parameter**, or the
  list was already runtime-mutated (keeping the compile-time fold only for a constant index
  into a never-mutated local, so a literal's initial data still reflects the write);
- marks the local list's base **runtime-mutated** (`list_base_is_runtime`), so subsequent
  **reads** — even with a constant index — resolve against runtime memory instead of the
  stale folded literal (read path `Lprimary_list_index_source_ready`).

Because a list is a shared pool base, a write through a **parameter** correctly mutates the
caller's list. Locked in with 7 MUST-PASS assertions (`list write computed`, `list write var
idx`, `list fill in loop`, `list swap elements`, `list const after mut`, `list param write`,
`list reverse in place`).

### 2.20 FIXED — immediate-scalar `return` (`return true` / `return false`)

A function returning a **bool literal** (`fn ok()->bool{ return true }`) returned garbage.
The return op (**op 4**) treats its argument as a **stack slot to load from**, but a bool
literal has no runtime slot (`x4 == -1`), so the raw value `1`/`0` was used as a *stack
offset* and whatever lived there was returned. Int literals already avoid this because
`Lprimary_number` materializes them into a temp slot; bool/byte/int-immediate returns did
not. Fixed in the return path (`Lstmt_return_scalar_mat`, `src/parser.s`): an immediate
scalar return with no slot is now materialized into a temp slot via **op 1** (store_var),
exactly like an int literal, so op 4 loads a real slot. Locked in with 4 MUST-PASS assertions
(`bool ret true`, `bool ret false`, `bool ret in expr`, `bool ret print`).

### 2.21 FIXED — per-function stack frames sized from the real peak (recursion no longer corrupts locals)

Every user function's prologue emitted a **hard-coded `sub sp, sp, #128`** (`_emit_user_function`,
`src/codegen.s`), ignoring the per-function `fn_frame_sizes` the parser computes. A function
with more than ~15 slots addresses locals *below* a 128-byte frame; that is harmless for a
**leaf** function (it writes below `sp`, nothing else is there), but the instant it **calls
another function or recurses**, the callee's frame overlaps those slots and silently
clobbers the caller's live locals — e.g. a recursive Sudoku `solve()` whose `is_safe(...)`
call corrupted its `row`/`col`/`num` counters, so it always reported "no solution".

Two fixes:
- **codegen** now emits `sub sp, sp, #<fn_frame_sizes[fn]>` (the epilogue restores via
  `mov sp, x29`, so any 16-aligned size stays balanced);
- **the parser** now computes that size from `max_var_count` (the monotonic **peak** var
  count) instead of the end-of-body `var_count`. Temps are recycled during parsing (the end
  value badly undercounts the peak), and the generated code addresses slot `S` at
  `[x29, -(S - scope_base + 1)*8]`, so the frame must cover the *peak* slot, not the
  survivors. `max_var_count` is always ≥ the function's true peak, so the frame always covers
  every slot it can address (may slightly over-allocate, which is harmless).

Result: `solve()`'s frame grew `128 → 384` and the **full recursive backtracking Sudoku
solver in `examples/hard_dsa_suite.sn` now solves the real puzzle correctly** (and Trapping
Rain Water prints `6`), exit `0` — it was a CFAIL before. Locked in with the `backtrack fill`
MUST-PASS assertion (a distilled recursive backtracker that writes a list element, recurses,
and undoes the write on failure).

### 2.22 FIXED — alternate array-type dialect (`[int]`, `name: type` params, `str(list)`)

`examples/binary_search.sn` used a second, terser dialect the compiler didn't accept:
`fn binary_search(list: [int], target: int)` (colon-form params + `[T]` array types),
`[int] numbers = [...]` (bracket type in a declaration), and `print("Array: " + str(numbers))`
(`str` of a whole list). Four contained additions, all mapping onto the existing primary
machinery (so `type name` / `list<T>` are unchanged):

- **`[T]` array-type alias** (`_parse_type_spec`): a leading `[` parses the element type and
  emits the **same** encoding as `list<T>` (type 4, element type in the high bits). Works
  everywhere types are parsed — params, returns, and declarations — and nests (`[[int]]`).
- **Colon-form params `name: type`** (`Lfn_def_parse_param`): disambiguated by saving the
  cursor, reading an identifier, and peeking for `:`. A `:` means colon form (that identifier
  is the NAME); anything else restores the cursor and parses the normal `type name`. This is
  unambiguous because `list<int> xs` always has `<` after `list`, never `:`.
- **`[T] name = <expr>` declarations** (`_parse_statement`): a statement starting with `[`
  routes to the shared list-declaration path with the type pre-parsed.
- **`str(list)`** (`Lfn_call_str_from_list` + `_str_list_to_data`): a **constant** int list is
  rendered `"[e0, e1, ...]"` at **compile time** (genuine constant folding — the element
  values are known) into a persistent bump-arena (`list_str_arena`), registered as a string
  data value, and materialized into a temp slot via op 72 — so it works both standalone
  (`printn(str(a))`) and inside a `+` concat. Runtime-mutated lists (`list_base_is_runtime`)
  are excluded (their compile-time values would be stale).

`examples/binary_search.sn` now runs end-to-end and correctly (`Array: [1, 3, 5, …, 19]`,
`Search for 9: 4`, `Search for 4: -1`, `Search for 15: 7`) — it was the last genuine CFAIL.
Locked in with 12 MUST-PASS assertions (`bracket type decl`, `bracket decl loop`, `colon
[int] param`, `colon mixed params`, `colon int param`, `bracket param regress`, `str of
list`, `str list single`, `str list negatives`, `str list in concat`, `str two lists`, and a
full `binary search` written in the dialect).

**Combined result of 2.19–2.22:** `make assert` is now **200/200 must-pass, 0 known-broken**;
the `examples/` sweep is **155/162 OK, 0 link failures, 0 runtime failures**. **Every remaining
sweep CFAIL is a *deliberate* negative test** — the 6 `decimals_invalid_*` programs and
`map_missing_key_diagnostic`, all of which are *supposed* to be rejected. In other words,
**every real example program now compiles, links, and runs correctly.**

### 2.23 FIXED — thread join via `wait()`, and a clear `spawn obj.method()` diagnostic

`spawn fn()` runs `fn` on a background OS thread, but the runtime immediately called
`pthread_detach` on each thread. With no way to join, a worker's output was routinely **lost**
when `main` reached the end first — e.g. `examples/spawn_basic.sn` printed only `main done`,
never the worker's `hello from thread`. There was no synchronization primitive at all
(`chan`/`lock`/`async` are documented but unimplemented). Two changes:

- **`wait()` builtin (op 117)** — blocks until every outstanding spawned thread finishes and
  returns an `int`: the number of threads joined. Implementation (`src/data.s`,
  `src/parser.s`, `src/codegen.s`): `_snc_spawn_go` now **records each thread id** into a
  shared table (`_snc_spawn_tids` / `_snc_spawn_ntids`) instead of detaching (it falls back to
  `pthread_detach` only if the 256-slot table is full); the new self-contained
  `_snc_spawn_wait` runtime loops `pthread_join` over that table and resets it. `spawn` issues
  run on the calling (main) thread, so the table is written single-threaded — no race. The
  join routine is emitted whenever a program uses `spawn` **or** `wait()`, so `wait()` links
  even with no spawn (then it joins zero threads and returns `0`). POSIX-only, like `spawn`
  itself; on Windows `wait()` compiles to a no-op returning `0`.
- **`spawn obj.method()` now fails with a clear error** instead of a confusing empty
  `line N:` message. Spawning a blueprint *method* never actually worked: its capture path
  clobbered the object-name registers before `_lookup_variable` (so the lookup failed into the
  generic empty-message `Lstmt_fail`) and also used an out-of-range spawn-buffer slot (`63`,
  while the spawn tables hold only 32 entries) whose worker codegen never emitted. It now
  reports `error: spawn of a method is not yet supported (only spawn fn()) on line N:` the
  moment a `.` is seen. (A full fix — valid slot allocation + method-worker emission — is
  future work; `spawn fn()` on a zero-arg function is the supported form.)

Locked in with 5 new MUST-PASS assertions (`spawn wait output`, `spawn wait count`,
`spawn wait multi`, `wait no spawn`, and the `spawn method rejected` compile-fail) and the new
`examples/spawn_wait.sn`. **`make assert` is now 205/205 must-pass, 0 known-broken**; the
`examples/` sweep is **156/163 OK** (the same 7 deliberate negative tests remain).

### 2.24 DONE — growable (`malloc`-backed) op & print tables, an `ord()` builtin, and the first self-hosted component

Three self-hosting-focused changes landed together this pass:

**1. The operation and print/data tables now grow on demand.** Previously the recorded-op
stream (`op_kinds` + `op_arg0..4`) and the print/data literal tables (`print_values`,
`print_lengths`, `print_types`, `print_noline`) were fixed `.space` arrays that hard-failed
with `error: too many operations` / `error: too many print statements` once the
`SNC_MAX_OPS` (32768) / `SNC_MAX_PRINTS` (16384) caps were hit. Those symbols are now
**pointers to `malloc`-backed buffers** (`src/data.s`); `_snc_grow_ops` / `_snc_grow_prints`
(`src/vars.s`) `realloc`-double the buffers when full (preserving contents and the caller's
live registers), `src/main.s` allocates the initial buffers, and `src/codegen.s` dereferences
the pointers at emit time. `SNC_MAX_OPS`/`SNC_MAX_PRINTS` are now merely the *initial*
capacity. Verified: a generated program with **20000 statements (~60000 ops)** and one with
**20000 print statements** each compile, link, and run correctly (both previously hit the
fixed cap). `make assert` includes a `many ops grow path` guard.

**2. `ord(s)` builtin (op 118).** Returns the ASCII code (int) of the first byte of a string,
`0` for `""`. This was a genuine self-hosting blocker: SNlang char indexing `s[i]` yields a
one-character *string* and there was no way to obtain its numeric value, so a program could
not classify characters (digit / letter / whitespace). A string literal folds at compile
time; a runtime char (`s[i]`) reads the byte at run time. Verified: `ord("A")`=65,
`ord("0")`=48, `ord("")`=0, and `ord(s[i])` over `"Xyz"` = 88/121/122.

**3. First self-hosted component — `selfhost/lexer.sn`.** A tokenizer **written in SNlang**,
compiled by the assembly `snc` and run via `make selfhost`. Given a `.sn` path (`argv(1)` +
`file_read`), it scans with `s[i]` / `s.length()` / `s.slice()` / `ord()` and prints one
token per line (NUM / ID / STR / OP, including two-char operators like `->`, `>=`, `!=`),
plus a token count. This is the roadmap's milestone **M3 ("port the lexer", token-dump
mode)** — the first concrete step of writing the compiler in SNlang. (Parser/codegen and the
stage1≡stage2 bootstrap proof remain; see `SELF_HOSTING_ROADMAP.md`.)

Locked in with 6 new MUST-PASS assertions (5 `ord` + a growable-op-table smoke test).
**`make assert` is now 211/211 must-pass, 0 known-broken**; the `examples/` sweep is
**156/163 OK** (the same 7 deliberate negative tests). Still static (future work): the
variable/function tables and the emitted runtime `list`/`map` pools.

---

## 3. Now verified WORKING (real stdout — run `make assert`)

| Program | Output |
|---|---|
| `print(5)` | `5` |
| `int x = 7  print(x)` | `7` |
| `print(2 + 3)` | `5` |
| `print(10 + 4 * 3)` | `22` (correct precedence) |
| `print((2 + 3) * 4)` | `20` |
| `print(20 / 4)` / `print(17 % 5)` | `5` / `2` |
| `int x = 0 - 5  print(x)` | `-5` |
| `bool b = true  print(b)` | `1` |
| `if (1 < 2) {111} else {222}` | `111` (correct branch) |
| `if (5 < 2) {111} else {222}` | `222` |
| `if (3 == 3) …` / `1<2 and 3<4` | `1` |
| `int i=0  while(i<3){print(i) i=i+1}` | `0 1 2` |
| accumulate `1..5` in a `while` | `15` |
| `str s="hi"  printn(s)` | `hi` |
| `printn("a") printn("b")` | `ab` (both — first no longer dropped) |
| `list<int> n=[7,8,9]  print(n[0]) print(n[2])` | `7 9` |
| `for (v in [1,2,3]) print(v)` | `1 2 3` |
| `for (v in [1,2,3]) print(v%2)` | `1 0 1` |
| `for (v in xs)` over a list **parameter** | correct (runtime loop; sum `10`, prints `50 60 70`) |
| 400-element `for (v in n)` accumulate | `80200` (no op-table overflow) |
| mixed int+str `for-in` (`for_loop.sn`) | `… 7 8 10 Apple Banana` |
| `int x=42  printn("v={x}")` | `v=42` (string interpolation) |
| `int a=3 int b=7  printn("a={a} b={b}")` | `a=3 b=7` |
| `str s="hi there"  s.upper()` | `HI THERE` |
| `str s="HI THERE"  s.lower()` | `hi there` |
| `s.contains("ell")` / `s.contains("xyz")` | `1` / `0` |
| `s.upper().slice(0,3)` (chaining) | `HEL` |
| `str s="hello"  s[0]` / `s[4]` / `s[i]` | `h` / `o` / char at i |
| `fn add(int a,int b)->int{return a+b}  add(3,4)` | `7` |
| `fn f(int n)->int{if(n<=1){return 1} return n*f(n-1)}  f(5)` | `120` (recursion) |
| `fn fib … fib(n-1)+fib(n-2)  fib(10)` | `55` (two self-calls + add) |
| function with 40 locals and `return v0+v39` | `39` (large frame proof) |
| `str s="hello world"  s.replace("world","there")` | `hello there` |
| `str s="banana"  s.replace("an","")` | `ba` (deletion) |
| `file_write(p,"abc123") str c=file_read(p) print(c)` | `abc123` |
| rewrite same path then `file_read` | truncates correctly (no leftover bytes) |
| `file_read` result `.length` | correct runtime length (e.g. `11`) |
| `str(42)` / `str(a+b)` / `str(0-9)` | `42` / `7` / `-9` (int→string builtin) |
| `str(true) str(false)` / `"n=" + str(n)` | `1 0` / `n=5` |
| `len("hello")` / `len([1,2,3,4])` / `len(local)` | `5` / `4` / `3` (length builtin) |
| `len(list_param)` / `len("a-b-c-d".split("-"))` | `5` / `4` (runtime count) |
| `int x=5  x++` / `x--` | `6` / `4` (increment/decrement) |
| `c.value += 3` / `c.value++` (object field) | `8` / `6` (field compound assign) |
| `self.value += 1` in a method (per-instance) | isolated per instance (`12` vs `20`) |
| `if x > 3 { … }` / `while i < 3 { … }` (no parens) | correct (optional condition parens) |
| `for x in [1,2,3] { … }` / `for i=0, i<3, i++ { … }` | `1 2 3` / `0 1 2` (paren-less loops) |
| `a[i]=v` / `a[row*9+col]=num` (runtime element write) | in-place list mutation (swap/fill/reverse) |
| recursive backtracking Sudoku solver (`hard_dsa_suite.sn`) | solves the real puzzle correctly |
| `fn ok()->bool{ return true }` | `1` (immediate-scalar return) |
| `[int] a = [1,2,3]` / `fn f(xs: [int])` | bracket array types + colon params |
| `str([1,3,5])` | `[1, 3, 5]` (list-to-string) |
| full binary search (`binary_search.sn`) | `4` / `-1` / `7` (correct) |

All **200 must-pass** assertions in `tests/assert_suite.sh` pass, including the
trailing-declaration-at-EOF regression (2.2), the section-2.3 additions
(comparisons-as-values, `value` as an ordinary identifier, variable member access), the
section-2.4 string methods (`.upper()`/`.lower()`/`.contains()`) and char indexing `s[i]`,
the section-2.5 `.replace(old,new)` cases, the section-2.6/2.7 `file_read`/`file_write`
cases (now passing **consistently**, not intermittently), and the section-2.15/2.16
`str(x)` / `len(x)` builtins.
Also verified working: string-returning functions (`fn get()->str{ return "a" }`, string
return assigned to a var, used in `print`, and conditional string returns).

---

## 4. FIXED — no-argument function calls used to hang

A no-arg call like `fn hi(){ print(42) } fn main(){ hi() }` used to **hang at runtime**
(observed as `137`/killed by the assert harness's watchdog). Root cause was purely a
**code-emission ordering bug** in `_emit_program` (`src/codegen.s`), unrelated to calling
conventions: `asm_main_epilogue` (the `mov sp, x29 / ldp x29,x30 / ret` that closes `_main`)
was written **after all user functions** instead of right after `_emit_main_body`. So the
generated `_main:` had no `ret` before the next label — it fell straight through into the
first user function's prologue/body and executed it a second time unconditionally, on top
of whatever `bl` had already done, corrupting the stack. Fix: emit `asm_main_epilogue`
immediately after `_emit_main_body`, before any user-function label is written. Verified:
`fn hi(){ print(42) } fn main(){ hi() }` now prints `42` and exits `0` (was a hang);
promoted to the MUST-PASS group in `tests/assert_suite.sh`.

### 4.1 FIXED — functions with arguments, return values, and recursion

Functions **with parameters, return values, and recursion now work at runtime.** The
calling convention is implemented, and the bugs that made it produce wrong answers (or
crash) were found and fixed:

- **Calling convention (implemented).** The caller (`Lemit_op_fn_call`, `src/codegen.s`)
  marshals the staged argument slots into `x0..xN`, `bl`s the function, and captures the
  returned `x0` into the call's result slot; the callee (`_emit_user_function`) stores the
  incoming `x0..xN` into its parameter slots on entry. Scope-relative offsets
  (`fn_scope_bases`) keep each function's frame self-consistent, and `main` (scope base 0)
  is unaffected.
- **Bug fixed this pass — recursion param-name shadow.** During argument parsing,
  `_call_function` called `_define_variable` with the *callee's* parameter name, leaving a
  live variable of that name in the *caller's* scope. When a function recurses
  (`f(n-1)+f(n-2)`, callee param also `n`), that staged `n` got a higher var index and
  **shadowed the caller's real `n`** in `_lookup_variable` (which scans high→low), so the
  second `n` read a leftover arg slot → wrong/zero results. Fix: in compilation mode, zero
  that parameter variable's name (`var_name_lens`/`var_name_ptrs`) right after defining it,
  so it becomes a nameless temp that cannot shadow (interpret mode keeps the name for its
  by-name body lookup). `src/parser.s`, `Lfn_call_define_arg_len_ok`.
- **Bug fixed this pass — the intermittent compiler crash** (section 2.1) also affected
  these programs, because functions/recursion allocate many temps.

Verified (`make assert`): `add(3,4)` → `7`; `factorial(5)` → `120`;
`fibonacci(10)` → `55` (two self-calls whose results are added); nested calls, a call used
in an expression, and a statement after a call all produce correct output.

### 4.2 FIXED — for-in loops and string interpolation; remaining gaps

- ~~**String interpolation**~~ **now works** — `printn("v={x}")` → `v=42`,
  `printn("a={a} b={b}")` → `a=3 b=7`, and expression interpolation (`{x*x}`) too. It had
  been corrupted by the same `x25` clobber as `for-in` (section 2.1).
- ~~**`for in` over a list**~~ **now works, including as a real runtime loop** — `for (v in
  n)` iterates correctly and updates the loop variable each pass. Root cause of the old
  "prints the first element forever" was the `x25` clobber in `_record_operation*`
  (section 2.1) corrupting the loop-variable name length. For integer/scalar lists it is now
  a genuine **runtime** loop (section 2.8), so it also works over list **parameters** and
  over large lists without overflowing the op table — the former `huge for-in unroll` and
  `param list for-in sum` xfails are resolved and promoted to must-pass. String-element
  `for-in` keeps the compile-time unroll (a str element is a data-value id, not a runtime
  pointer).
- ~~**String returns are still broken**~~ **string returns now work** — `fn get_a()->str
  { return "a" }`, a string return assigned to a variable, used directly in `print`, and
  conditional string returns (`if(n<0){return "neg"} return "pos"`) all produce correct
  output. Covered by `make assert` (`string return lit`).
- ~~**Duplicate-variable check is disabled**~~ **now enforced** — redeclaring a name in the
  same scope (`int x=1 int x=2`) is rejected with `error: duplicate variable` (guarded by
  the `duplicate var` compile-fail assertion in `make assert`).
- **Branch/label codegen** — the current 162-example sweep has **0 link failures and 0
  runtime crashes**, so the previously-seen invalid-assembly / undefined-label emissions
  are not reproducing here. This is not an exhaustive proof, but the examples are clean.
- ~~`file_read`/`file_write`~~ **now work** (sections 2.6–2.7) — type reporting, write
  length, runtime `.length`, and a real, previously-random file-permission bug are all
  fixed.
- ~~**Block `try`/`catch` is a stub**~~ **now works** (section 2.9) — `try`/`catch`/`throw`
  compile to a real runtime error path: throws jump to the catch, the caught `e` holds the
  message, `catch` with/without a variable and nested trys all behave correctly.
- **Still open:** **selective/exclusion imports**
  (`use module only …` / `except …`) load the whole module instead of the named subset.
  Also unsupported: nested function *definitions* (`fn` inside `fn`), `int + str`
  concatenation, `spawn`+`blueprint`, and dotted `module.func()` access.

---

## 5. The test suite gave a false "green" — now addressed

`make test` compiles/links/runs the examples but **never asserts stdout** (only the
deliberately-invalid decimal cases check anything, and only via exit code). That is why
wrong numeric output went unnoticed for so long.

This change adds `tests/assert_suite.sh` (run it with **`make assert`**): it captures each
program's stdout and diffs it against an expected value. It has a MUST-PASS group
(**106 assertions**, covering arithmetic/precedence, comparisons-as-values,
functions/arguments/recursion, for-in (including over list **parameters** and large
loops), string interpolation, string methods, string returns, variable member access, and
file I/O) that fails the build on any regression. The KNOWN-BROKEN group is now **empty**:
the former `huge for-in unroll` (op-table overflow) and `param list for-in sum` xfails were
resolved this pass (section 2.8) and promoted to must-pass. One assertion guards a function
with 40 locals, proving the old `ldur/stur` ±256 frame-immediate failure is gone for the
verified core value path. This harness is also what caught the section 2.7 file-permission
bug as a real, repeatable regression rather than dismissing it as flakiness.

Latest examples sweep: `162` example files total; `144` compile, link, and exit
successfully (exit 0); `18` fail at compiler/parse time — of which `6` are the deliberate
invalid-decimal negative tests; `0` fail at `clang` assembly/link time; `0` crash at
runtime; `0` time out. The remaining genuine parse failures are nested function
*definitions*, the `debug_*` programs' `int + str` concatenation,
`spawn`+`blueprint`, an alternate `name: [type]` parameter syntax, and module load-path
resolution. This broader sweep is why the project is still **not** marked complete even
though `make assert` is green.

---

## 6. Hard fixed-size limits

The compiler stores program state in fixed-size static tables (see `src/data.s`), with
hard-cap error messages including:

- `error: too many variables`
- `error: too many operations`
- `error: too many print statements`
- `error: spawned function body too large (max 256 ops)`

Previously, `src/codegen.s` addressed locals with `ldur/stur [x29, #-N]`, whose signed
immediate range (−256..255) capped verified generated frames at roughly 31 8-byte locals.
This is now fixed for the core value/call/return paths: large offsets emit
`sub x28, x29, #off` followed by `ldr/str [x28]`, and user-function slots are normalized
relative to their recorded function scope base. `make assert` includes a function with 40
locals that compiles, links, runs, and prints `39`.

**Update (2026-07-09):** these caps are now **much larger** and centralized as macros in
`src/platform.inc` — variables `512`→`4096`, operations `4096`→`32768`, print statements
`2048`→`16384`, functions `32`/`64`→`256`, and the source buffer `64KB`→`1MB`. The frame
allocation and large slot offsets are no longer emitted as a single `sub #imm` (which caps
at 4095); they now materialize the value in a scratch register first, so the larger budgets
are actually usable inside one function. A generated 1000-local / 3000-print / 66 KB-source
program compiles, links, and runs correctly.

**Update (2026-07-09, cont.):** the **operation and print/data tables are now truly
`malloc`-backed and grow on demand** (realloc-doubling from the initial cap; see section
2.24) — a generated 60k-op program and a 20k-print program compile, link, and run.
**Still needed:** the *remaining* static tables (variables, functions) and the emitted
runtime `list`/`map` pools becoming `malloc`-grown too. The examples sweep
also shows unverified paths that still pass invalid non-slot values into stack emission
(notably string returns), and those need feature-specific fixes rather than more
stack-offset widening.

---

## 7. Documentation was misleading (now removed)

Deleted in this change because they misrepresented the project's state:

- `README.md` — "working core", benchmark and originality claims.
- `SNLANG_SPEC.md` — spec presenting unimplemented/broken features as complete.
- `SYNTAX.md` — syntax reference presenting broken features as working.

**Update (2026-07-09) — DONE:** `LICENSE.md` has been truthed-up. The
"✅ SELF-HOSTING READY" / "Self-Hosting Status" sections, the "829ms / 100M iterations"
benchmark, the comparative marketing claims, and the phantom `build.ps1` reference were
removed; the actual license terms were preserved, and the concurrency section now
describes only the detached `spawn` that really exists (channels/`lock`/`async` are marked
planned).

---

## 8. What actually works

- The pipeline itself: `.sn` → ARM64 `.s` → `clang` → a native executable that runs.
- The parser accepts a broad surface of syntax without crashing.
- **The value back-end for straight-line and looping code is correct**: integer literals
  and variables, `+ - * / %` with correct precedence and parentheses, negative values,
  booleans, comparisons and `and`/`or`, `if`/`else` branch selection, `while` loops
  (including accumulation), string printing, string interpolation, sequential statements,
  list indexing, and `for`-in loops over lists. See section 3 / `make assert`.
- **Functions now work end to end**: no-arg calls, calls with arguments, return values,
  calls used in expressions, nested calls, and **recursion** (e.g. `factorial`, and
  `fibonacci` which adds the results of two self-calls). See section 4.

So this is a real, ambitious hand-written ARM64 compiler whose front-end and back-end now
work for a substantial multi-function subset of the language; the immediate remaining
limits are the still-broken/unverified feature paths (some branch/label generation and
import subsets), fixed-size tables, and the missing standard-library / FFI ecosystem on top.

---

## 9. Distance from self-hosting / HTTP / games

Self-hosting a compiler requires correct integers, variables, arithmetic, comparisons,
control flow, arrays, **function calls, and recursion** — the verified integer/core subset
of these now works (sections 3–4), and the old verified large-frame immediate blocker is
fixed (section 6). Self-hosting is still blocked because a compiler also needs reliable
strings (including string returns), robust branch/label generation, larger/growable
tables, file/string/collection libraries, diagnostics, and a lexer/parser/codegen written
in SNlang with a repeatable bootstrap proof.

Beyond that, the language still has no sockets/FFI, no `net`/`http`/`json`/`tls` stack,
and no graphics/audio/input bindings, and the standard library is tiny (`io.sn` wraps
`printn`; `math.sn` has integer `abs/max/min/pow/clamp/sign`; `string.sn` has only
`isEmpty`). So HTTP libraries and graphical games remain far off: the immediate gates are
the remaining compiler correctness gaps, fixed table limits, then a real standard library,
then syscalls/FFI.

---

## 10. Updated fix order

1. ~~Fix operand/value materialization~~ **DONE** — the inverted spawn-recorder check and
   the literal-slot bug are fixed; integers, variables, arithmetic, comparisons, control
   flow and list indexing now produce correct output (section 2–3).
2. ~~Add an assertion-based test harness that diffs stdout~~ **DONE** —
   `tests/assert_suite.sh` / `make assert`.
3. ~~Fix the no-arg function call hang~~ **DONE** — `asm_main_epilogue` now emits right
   after `_emit_main_body`, so `_main` no longer falls through into user-function code
   (section 4).
4. ~~Implement the runtime calling convention for arguments/returns~~ **DONE** — scope-
   relative offsets (`fn_scope_bases`), callee param-loads from `x0..xN`, caller arg-
   marshalling + return capture, plus the recursion param-name-shadow fix (section 4.1).
   Functions with arguments and recursion now work.
5. ~~Fix the intermittent compiler crash~~ **DONE** — temp vars now clear their name; all
   `_record_operation*` variants preserve `x25`/`x26` (section 2.1).
6. ~~Fix string interpolation~~ **DONE** and ~~make `for in` work~~ **DONE**
   (sections 4.2, 2.8). `for in` over integer/scalar lists is now a real **runtime** loop, so
   large loops and list *parameters* work; string-element `for in` still unrolls.
7. ~~Lift the ±256 stack-offset limit~~ **DONE** (section 6) — large offsets now emit
   `sub x28, x29, #off` + `ldr/str [x28]`; a verified 40-local function frame compiles,
   links, and runs correctly.
8. ~~Fix string methods, `.replace()`, char indexing, and `file_read`/`file_write`~~
   **DONE** (sections 2.4–2.7) — including a real variadic-ABI bug that made file
   permissions effectively random.
9. ~~re-enable/verify the duplicate-variable check~~ **DONE** (section 4.2) and ~~make
   `for-in`/element access over a list *parameter* work~~ **DONE** (section 2.8 — `for-in`
   over integer/scalar lists is a real runtime loop that reads the parameter's runtime base
   and length).
10. ~~Replace the fixed-size op/var/print/function tables (the former **#1 blocker**)~~
    **DONE (2026-07-09)** — caps centralized as `src/platform.inc` macros: variables
    `512`→`4096`, operations `4096`→`32768`, print statements `2048`→`16384`, functions
    `32`/`64`→`256`, and the source buffer `64KB`→`1MB`; large frames and >4095-byte slot
    offsets now emit a register form. (Truly *dynamic* `malloc`-growth and the emitted
    runtime `list`/`map` pools remain future work.)
11. ~~Add a `system`/`exec` builtin and `argc`/`argv`~~ **DONE (2026-07-09)** — the two
    self-hosting *driver* prerequisites: invoke an external assembler/linker, and receive
    `snc file.sn` on the command line.
12. ~~Give `spawn` a join/sync primitive~~ **DONE (2026-07-09)** — threads are recorded (not
    detached) and the new `wait()` builtin joins them all, returning how many were joined, so
    worker output is no longer lost (section 2.23). `spawn obj.method()` now reports a clear
    error instead of an empty one. (Still no channels / `lock` / `async`-`await`.)
13. ~~Make the op/print tables truly `malloc`-grown, add `ord()`, and start the self-hosted
    compiler~~ **DONE (2026-07-09)** — the operation and print/data tables now `malloc`/
    `realloc`-grow on demand (no more `too many operations` / `too many print statements`); a
    new `ord(s)` builtin exposes character codes; and `selfhost/lexer.sn` is the first
    self-hosting component — a tokenizer written in SNlang, run via `make selfhost` (roadmap
    M3). See section 2.24. (Remaining static: the variable/function tables and the runtime
    `list`/`map` pools.)
14. Only then: build out `stdlib`, add syscalls/FFI, then `net` → `http`, and continue the
    self-hosting components (parser → codegen in SNlang) toward the stage1≡stage2 bootstrap
    proof. See `SELF_HOSTING_ROADMAP.md` for the staged plan.

# Antigravity Issue — Module Loading Crash

## Status
RESOLVED

## Short Answer

Yes, the issue and its remaining follow-up work are fixed.

What is fixed:
- The compiler no longer segfaults when a `use` statement is present.
- Missing modules no longer crash the compiler.
- Duplicate `use` statements no longer crash the compiler.
- Module file parsing no longer corrupts the main source buffer.
- Imported functions are now callable from the importing file.
- Imported functions keep the correct source buffer when executed.

---

## Summary

The original crash described in this issue is fixed. The root problem was not a
single fault inside `_load_module`, but a combination of module parser and
helper bugs:

- `_parse_use_statement_after_keyword` passed the wrong registers as the module
  span to `_load_module`
- `_module_path_to_file` kept heap pointers in caller-saved registers across
  helper calls
- `_find_module` also used an unsafe caller-saved loop register
- `_parse_module_content` treated `_parse_fn_definition` success/error backwards
- `_load_and_parse_module_file` reused the shared global source buffer, which
  corrupted the original file after parsing an imported module

Those crashes and corruption issues are fixed now, and imported functions are
resolved and callable end-to-end.

---

## Current Behavior

## Works

- `use module.path` syntax parses correctly
- `use` with missing modules does not segfault
- repeated `use` of the same module does not segfault
- module files can be loaded and parsed without overwriting the main source
- the original antigravity repro now exits cleanly

## Also Works Now

- functions discovered during module parsing are retained in function metadata
- imported functions resolve through function lookup
- imported function calls execute against the correct module source buffer
- end-to-end imported calls run successfully

---

## Root Cause Fixed

The crash was caused by multiple low-level bugs rather than the original single
suspected clobber alone.

### Fixed causes

1. `use` parsing bug

`_parse_use_statement_after_keyword` was reading `_parse_identifier` results as
if they were in `x1/x2`, but `_parse_identifier` returns pointer/length in
`x0/x1`.

2. Caller-saved register misuse in module helpers

`_module_path_to_file` and `_find_module` both relied on caller-saved registers
across `bl` calls, which made module lookup unstable and could lead to invalid
pointer use.

3. Main source corruption during module load

Imported module contents were loaded into the shared global `buffer`, then
parsed, and only parser state was restored. That restored the old pointer/len
metadata, but the original source bytes had already been overwritten.

4. Reversed success check in module parsing

`_parse_module_content` treated a successful `_parse_fn_definition` as failure.

---

## Files Changed

| File | Change |
|------|--------|
| `src/parser.s` | fixed `use` module span handling and function call source switching |
| `src/utils.s` | fixed module helper register safety, module parse flow, module file buffer ownership, and imported function registration |
| `src/data.s` | added per-function source metadata storage |
| `tests/compile_test.sh` | added import regression coverage |
| `tests/runtime_test.sh` | added end-to-end imported function call coverage |

---

## Agent Verification

Agents can verify the current state directly with the commands below.

### 1. Verify the original crash is fixed

```sh
cat >/tmp/antigravity_repro.sn <<'EOF'
use math

fn main() {
    print("hello")
}
EOF

./snc /tmp/antigravity_repro.sn >/tmp/antigravity_repro.out 2>/tmp/antigravity_repro.err
echo "exit=$?"
cat /tmp/antigravity_repro.err
```

Expected now:
- exit code `0`
- no segfault
- stderr empty

### 2. Verify a real module import no longer corrupts the main file

```sh
cat >__agent_verify_math.sn <<'EOF'
fn helper() -> int {
    return 42
}
EOF

cat >/tmp/agent_verify_import.sn <<'EOF'
use __agent_verify_math

fn main() {
    print("hello")
}
EOF

./snc /tmp/agent_verify_import.sn >/tmp/agent_verify_import.out 2>/tmp/agent_verify_import.err
echo "exit=$?"
cat /tmp/agent_verify_import.err
rm -f __agent_verify_math.sn
```

Expected now:
- exit code `0`
- no parse corruption errors after the import

### 3. Verify duplicate `use` is stable

```sh
cat >__agent_verify_math.sn <<'EOF'
fn helper() -> int {
    return 42
}
EOF

cat >/tmp/agent_verify_duplicate.sn <<'EOF'
use __agent_verify_math
use __agent_verify_math

fn main() {
    print("hello")
}
EOF

./snc /tmp/agent_verify_duplicate.sn >/tmp/agent_verify_duplicate.out 2>/tmp/agent_verify_duplicate.err
echo "exit=$?"
cat /tmp/agent_verify_duplicate.err
rm -f __agent_verify_math.sn
```

Expected now:
- exit code `0`
- no segfault
- no module-load failure

### 4. Verify imported function calls end-to-end

```sh
cat >__agent_verify_math.sn <<'EOF'
fn helper() -> int {
    return 42
}
EOF

cat >/tmp/agent_verify_call.sn <<'EOF'
use __agent_verify_math

fn main() {
    print(helper())
}
EOF

./snc /tmp/agent_verify_call.sn >/tmp/agent_verify_call.s 2>/tmp/agent_verify_call.err
echo "compile_exit=$?"
cat /tmp/agent_verify_call.err
cc /tmp/agent_verify_call.s -o /tmp/agent_verify_call_bin
/tmp/agent_verify_call_bin
rm -f __agent_verify_math.sn
```

Expected now:
- compile exit code `0`
- stderr empty
- program output `42`

---

## Regression Check

Quick automated check:

```sh
bash tests/compile_test.sh
bash tests/runtime_test.sh
```

Expected now:
- all compile regression tests pass
- runtime regression tests pass, including imported function call

---

## Conclusion

The original antigravity crash is fixed, and the remaining import-resolution
follow-up work is fixed too. Imported functions now compile and execute
successfully.

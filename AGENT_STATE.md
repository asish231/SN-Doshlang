# Agent Shared State

This file is the shared blackboard for all coding agents working on this repo.

**Every agent must:**
1. Read this file at the start of every session
2. Update the relevant section when finishing work
3. Never overwrite another agent's section — only update your own

---

## Active Work Zones

Tracks who is working on what right now. Update this before starting work to avoid conflicts.

| Zone | File(s) | Agent | Status | Last Updated |
|---|---|---|---|---|
| codegen | `src/codegen.s` | Agent B | in progress | 2026-05-01 |
| parser | `src/parser.s` | Agent B | in progress | 2026-05-01 |
| vars | `src/vars.s` | — | idle | — |
| utils | `src/utils.s` | — | idle | — |
| data | `src/data.s` | Agent B | in progress | 2026-05-01 |
| lexer | `src/lexer.s` | — | idle | — |
| main | `src/main.s` | — | idle | — |

---

## Last Completed Work

### Antigravity (most recent first)
- Standardized the math standard library (`stdlib/std/math.sn`) with `abs`, `max`, `min`, `pow`, `clamp`, and `sign`.
- Implemented a comprehensive test suite in `tests/test_math.sn` and an automated test runner `tests/test_math.sh`.
- Fixed a parser limitation in `math.sn` where unary minus was only supported for literals; refactored `abs` to use `0 - x`.
- Finalized native `string.slice(start, end)` (Op 90). Handled both literal and variable arguments for start/end indices. Corrected literal string source interning to prevent segmentation faults. Verified with full suite of tests.
- Optimized `_string_slice` runtime helper to correctly handle length boundaries.

### Agent A (most recent first)
- Restored the empty collection literal parsing logic (`[]` and `{}`) that was accidentally reverted. Verified that `map<str, int> m = {}` along with map key insertion (`m["first"] = 100`) compiles and runs correctly.
- Re-applied the runtime map index immediate flag propagation logic in the parser (`Lprimary_map_lookup_runtime`), ensuring `print(m["first"])` loads correctly natively instead of using broken stack offsets.
- Fixed map (`m[k]`) and list (`l[i]`) runtime lookups for constant/immediate keys by passing `is_imm` flag natively to codegen and emitting `mov x10, #imm` or string pool pointers instead of broken `ldur` instructions.

### Agent B (most recent first)
_Nothing yet._

---

## Known Broken Things Right Now

Things that are currently broken or mid-fix. If you touch something and break it, add it here so the other agent doesn't build on top of broken code.

_None currently. (Agent A has taken over Kiro's module fix)._

---

## Interfaces Between Zones

This is the critical section. When one agent changes a function signature, label name, register contract, or data layout that another zone depends on, it MUST be documented here immediately.

### Function / Label Contracts

| Label | Defined in | Called from | Contract (args → return) | Last changed |
|---|---|---|---|---|
| `emit_var_decl` | `codegen.s` | `parser.s` | x0=type_id, x1=name_ptr, x2=expr_slot → void | — |
| `parse_statement` | `parser.s` | `parser.s` | x0=cursor_ptr → x0=new_cursor_ptr | — |
| `find_var` | `vars.s` | `parser.s`, `codegen.s` | x0=name_ptr, x1=len → x0=slot or -1 | — |
| `write_str` | `utils.s` | `codegen.s`, `parser.s` | x0=str_ptr, x1=len → void | — |
| `match_keyword` | `utils.s` | `parser.s` | x0=cursor, x1=keyword_ptr, x2=len → x0=1/0 | — |

Add new rows here whenever you add or change a cross-file interface.

### Shared Data / Buffers

| Symbol | Defined in | Used by | Purpose | Notes |
|---|---|---|---|---|
| `output_buf` | `data.s` | `codegen.s` | assembly output buffer | 1MB, do not exceed |
| `var_table` | `data.s` | `vars.s`, `codegen.s` | variable name/slot table | max 256 entries |
| `fn_table` | `data.s` | `parser.s`, `codegen.s` | function name/arity table | max 128 entries |
| `src_buf` | `data.s` | `main.s`, `parser.s` | loaded source file | read-only after load |
| `cur_fn_slot` | `data.s` | `vars.s`, `codegen.s` | current function's next free stack slot | reset on fn entry |

---

## Recent Decisions

Architectural decisions made during sessions. Read these before making changes that touch the same areas.

_Format: `[date] [who] decision`_

---

## Pending Handoffs

Work that one agent started but needs the other agent to finish or unblock.

_None currently._

---

## How to Use This File

**At session start:**
```
1. Read this entire file
2. Check "Active Work Zones" — claim your zone by writing your agent name and "in progress"
3. Check "Known Broken Things" — don't build on top of broken code
4. Check "Interfaces Between Zones" — know what the other agent changed
```

**During work:**
```
- If you change a cross-file interface, update "Interfaces Between Zones" immediately
- If you break something, add it to "Known Broken Things" immediately
```

**At session end:**
```
1. Update "Active Work Zones" — set your zone back to idle
2. Add a summary to "Last Completed Work" under your agent section
3. If you need the other agent to do something, add it to "Pending Handoffs"
4. If you made an architectural decision, add it to "Recent Decisions"
```

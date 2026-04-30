# SNlang Compiler Completion Checklist

This document converts the full-system checklist into a concrete status board for this repository.

## Status Legend

- DONE: Implemented and validated end-to-end on ARM64 macOS.
- IN_PROGRESS: Partially implemented and/or unstable.
- MISSING: Not implemented yet.

---

## 1) Compilation Stack

- Lexer:                              DONE
- Parser:                             DONE
- AST formalization layer:            MISSING
- Semantic analysis pass (separate):  MISSING
- IR layer:                           MISSING
- Optimization layer:                 MISSING
- ARM64 codegen:                      IN_PROGRESS (direct, no IR)
- Assembler/linker integration:       DONE (via `cc`)

---

## 2) Runtime Core

- Runtime control flow (`if/else`, loops, match):  DONE
- Runtime while loop:                              DONE
- Runtime for / for-in loop:                       DONE
- stop / skip (break/continue):                    DONE
- Function calls / returns / locals:               DONE
- Forward function calls:                          DONE
- Nested function calls (top-level):               DONE
- Nested fn inside fn (multiple calls):            IN_PROGRESS (workaround only)
- Calling convention compliance:                   IN_PROGRESS
- Stack frame contract documentation:              IN_PROGRESS
- Runtime data model for advanced aggregates:      IN_PROGRESS

---

## 3) Type and Semantics

- `int`, `bool`, `byte`, `str`:        DONE
- `dec(X)` decimal type:               DONE
- `const` types:                       DONE
- Typed assignment validation:         DONE
- Type mismatch errors:                DONE
- Missing return enforcement:          DONE
- Null model (`none`, `?`, `otherwise`): IN_PROGRESS
- `list<T>` core (literal/for-in/mutation): DONE
- `list<T>` indexing in expressions:   IN_PROGRESS
- `list<T>` bounds checking:           MISSING
- `map<K,V>` core (literal/read/update): DONE
- `map<K,V>` key insertion:            MISSING
- `map<K,V>` nested types:             MISSING
- Multi-return values:                 IN_PROGRESS (syntax not parsed)
- Default parameters:                  DONE

---

## 4) Language Feature Completeness

- Strings (literal/print/concat):      DONE
- `cast(x, str)` in concat:            DONE
- `cast(bool, str)`:                   DONE
- `cast(dec, str)`:                    DONE
- String interpolation `{name}`:       MISSING
- String methods (.length .slice etc): MISSING
- `print()` with newline:              DONE
- `printn()` without newline:          DONE
- File I/O (`file_read`, `file_write`): DONE
- `input("prompt")`:                   DONE
- `use module.path` (syntax):          DONE
- `use module.path` (runtime loading): MISSING
- Modules / multi-file compilation:    MISSING
- Object model (`blueprint`, `object`, contracts): MISSING
- Pointers / allocation / concurrency: DONE (Pointers, alloc, free implemented; concurrency missing)

---

## 5) Tooling and Errors

- Basic error reporting (line number):  DONE
- Rich diagnostics (column, recovery):  MISSING
- `make clean && make` build:           DONE
- `make test` full suite (34 tests):    DONE
- Single command build driver:          MISSING
- Package manager:                      MISSING
- Debugger integration:                 MISSING

---

## 6) Portability / ABI

- macOS ARM64:                          DONE
- `platform.inc` macro layer:           DONE
- Linux ARM64:                          MISSING
- Windows ARM64:                        MISSING
- x86_64:                               MISSING

---

## 7) Security / Safety

- Division by zero checks:              DONE
- Const assignment enforcement:         DONE
- Type mismatch enforcement:            DONE
- Bounds checks for collections:        MISSING
- Memory model for heap-based data:     DONE

---

## Current Test Status

- Total tests in `make test`:  34
- Passing:                     34
- Failing:                     0

---

## Execution Order (Critical Path)

1. Phase A (now): list indexing in expressions, map key insertion, string interpolation
2. Phase B: multi-return syntax, nested fn slot fix
3. Phase C: string methods, stdlib basics
4. Phase D: formal semantic pass boundary
5. Phase E: AST formalization
6. Phase F: minimal IR + IR->ARM64 lowering
7. Phase G: modules and multi-file compilation
8. Phase H: blueprints / OOP
9. Phase I: pointers, allocation, concurrency
10. Phase J: Linux/Windows platform support

---

## Acceptance Criteria for "Complete v1"

SNlang v1 is considered complete when all are true:

- AST + semantic analysis + IR exist as explicit layers
- Core language (`int/bool/byte/str/dec/list/map/none/nullable`) is stable
- Function system supports multi-return and default params
- Runtime data representations are documented and enforced
- `use` works across files with symbol resolution
- Diagnostics and tests cover compiler stages and runtime regressions
- Runs on macOS ARM64 and Linux ARM64

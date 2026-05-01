# Self-Hosting Needs

This document tracks everything SNlang needs before `snc` can be rewritten in SNlang and compile itself.

Self-hosting means: write the compiler in `.sn`, run it through the current `snc`, and have the output compile the next version of itself.

---

## What Self-Hosting Demands

The compiler does these things internally:

1. Read a source file from disk
2. Lex it into tokens (scan characters, match keywords, handle strings)
3. Parse tokens into an AST (recursive descent, nested structures)
4. Walk the AST and emit ARM64 assembly text
5. Report errors with line numbers
6. Handle multiple source files (modules)

Every one of those steps requires language features that are not fully done yet.

---

## Blockers — Critical (Must Have)

### 1. Module System — Symbol Resolution
**Status:** MISSING

`use module.path` syntax parses, but imported functions are not callable across files. The compiler is split across 7 source files (`main.s`, `lexer.s`, `parser.s`, `vars.s`, `codegen.s`, `utils.s`, `data.s`). A SNlang rewrite would need the same split. Without real cross-file symbol resolution, the entire rewrite must live in one file — which is impractical at compiler scale.

**What is done:**
- `use module.path` syntax parses
- Single and multiple imports parse
- Dotted paths parse
- Duplicate `use` handled safely
- Module file loading and parsing works
- Imported functions callable from importing file (single level)

**What is missing:**
- Symbol resolution across chained modules (transitive imports fail)
- Standard library namespace (`std.io`, `std.math`, etc.)

---

### 2. String Methods
**Status:** MISSING (all of them)

A lexer written in SNlang needs to walk characters, slice substrings, check prefixes, and split on delimiters. None of the string methods exist yet.

| Method | Status |
|---|---|
| `.length` | MISSING |
| `.slice(start, end)` | MISSING |
| `.contains(x)` | MISSING |
| `.replace(a, b)` | MISSING |
| `.split(sep)` | MISSING |
| `.upper()` / `.lower()` | MISSING |

Without at least `.length` and `.slice`, you cannot write a lexer in SNlang. String concat and interpolation are done, but they are not enough.

---

### 3. Map Key Insertion
**Status:** MISSING

The compiler needs symbol tables — maps from identifier names to their types, stack slots, and scopes. The current `map<K,V>` only supports updating existing keys. Inserting a new key at runtime is not implemented.

**What is done:**
- `map<str, int>` literal `{"key": val}`
- `map[key]` read
- `map[key] = val` update (existing keys only)

**What is missing:**
- `map[key] = val` insert (new key)
- `map<K, list<T>>` nested types
- Missing-key diagnostics

---

### 4. Multi-Return Values
**Status:** IN_PROGRESS — syntax not parsed yet

Compiler functions naturally return a value plus a success/error flag. Example: a parse function returns the parsed node and whether it succeeded. Without multi-return, every such function needs awkward workarounds (globals, out-params).

**What is done:**
- Single return values work fully

**What is missing:**
- `-> (int, bool)` return type syntax not parsed
- Tuple unpacking on the call side not implemented
- Codegen for multiple return registers not done

---

### 5. Blueprints — Full OOP
**Status:** PARTIAL

AST nodes, tokens, and symbol table entries are naturally modeled as structs/objects. Blueprints exist but are not production-ready.

**What is done:**
- Field metadata, instances, field access
- Basic method calls
- `self.field` access works in supported cases
- Parent names recorded for inheritance

**What is missing:**
- `contract` enforcement (parser-only right now)
- `follows` enforcement (parser-only)
- Access control (`open`/`closed`/`guarded`) enforcement (parser-only)
- `create()` path still limited
- Inherited field/method lookup not fully reliable

---

### 6. Error Handling
**Status:** MISSING

A compiler must report errors and recover. SNlang has no `error` type, no `panic`, and no structured error propagation.

**What is missing:**
- `error` type
- `panic("msg")` builtin
- `fn f() -> (T, error)` pattern
- Try/catch or equivalent

---

## Blockers — Important (Needed for Practical Self-Hosting)

### 7. List Bounds Checking
**Status:** MISSING

Any list-heavy code (token arrays, AST node lists) will silently corrupt memory on out-of-bounds access. A self-hosted compiler would be impossible to debug without this.

---

### 8. List Indexing in Expressions
**Status:** IN_PROGRESS

`list[i]` read in expressions is only partially working. A compiler walking a token list needs reliable indexed reads everywhere.

---

### 9. Nested Function Calls — Slot Reuse Bug
**Status:** IN_PROGRESS (workaround only)

Multiple calls to nested functions reuse stack slots incorrectly. The root cause (absolute vs relative slot indices per call frame) is known but not fixed. A self-hosted compiler would hit this constantly.

---

### 10. Calling Convention Compliance
**Status:** IN_PROGRESS

The ARM64 ABI calling convention is not fully enforced. Functions with more than 4 parameters, or functions that call other functions with arguments, can corrupt registers. A compiler written in SNlang would be a deeply nested call graph — this would be a constant source of crashes.

---

### 11. Rich Diagnostics
**Status:** MISSING

The current compiler reports basic line-number errors. A self-hosted compiler needs column numbers, error recovery (continue parsing after an error), and structured error messages. Without this, debugging the self-hosted compiler is nearly impossible.

---

### 12. `any` Type
**Status:** MISSING

Useful for generic AST node storage. Not critical but becomes painful without it when modeling heterogeneous node types.

---

## What Is Already Done (and Would Work in a Self-Hosted Compiler)

These features are solid and would carry over directly:

- `int`, `bool`, `str`, `byte`, `dec(X)` — full runtime support
- `const` types — immutability enforced
- `if / else if / else` — full runtime branching
- `while`, counted `for`, `for in` — full runtime loops
- `stop` / `skip` — break/continue work
- `match` with `default` — pattern matching works
- Function definitions, parameters, single return values
- Forward function calls
- Default parameters
- String literals, print, concat, interpolation
- `cast(x, type)` — int↔dec, int→str, bool→str, dec→str
- `list<T>` literal, `for in`, mutation
- `map<K,V>` literal, read, update existing keys
- `none`, nullable `?`, `otherwise`
- `ref<T>`, `alloc()`, `free()`, `value()`, `set()` — pointer ops
- `input("prompt")` — string input
- `file_read(path)` / `file_write(path, data)` — file I/O
- `use module.path` — single-level imports work
- `print()` / `printn()` — output
- `and`, `or`, `not` — logical ops
- `+=`, `-=`, `*=`, `/=`, `%=` — compound assignment
- `**` — exponentiation
- Line and block comments
- 34/34 tests passing

---

## Roadmap to Self-Hosting

Based on the existing batch roadmap, self-hosting becomes realistic after:

| Phase | What unlocks |
|---|---|
| Batch 3 (Strings) | String methods → lexer possible in SNlang |
| Batch 4 (Modules) | Cross-file symbol resolution → multi-file compiler possible |
| Batch 2 remainder | Multi-return, map insert → symbol tables and parse results |
| Batch 5 (Blueprints) | Full OOP → AST node modeling |
| Error handling | Compiler can report its own errors |

**Earliest realistic self-hosting attempt:** after Batch 3 + Batch 4 are complete.

At that point, a minimal single-pass self-hosted lexer + parser could be attempted as a proof of concept, even before full OOP and error handling land.

---

## Current Score

```
Critical blockers:       6  (modules, string methods, map insert, multi-return, blueprints, error handling)
Important blockers:      6  (bounds checking, list indexing, nested fn bug, calling convention, diagnostics, any type)
Already working:        ~35 features

Estimated completion:   ~40-50% of features needed for self-hosting
```

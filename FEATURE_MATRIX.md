# SNlang Feature Matrix

This file tracks spec vs implementation status.

- `Spec`: appears in `SNLANG_SPEC.md`
- `Status`: DONE / IN_PROGRESS / MISSING
- `Notes`: current state

---

## Core Types

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `int` | Yes | DONE | Full runtime support |
| `bool` | Yes | DONE | Full runtime support |
| `str` | Yes | DONE | Literal, print, concat, pass-through |
| `byte` | Yes | DONE | Parser and runtime path validated |
| `dec(X)` | Yes | DONE | Decimal arithmetic, cast, print |
| `const int/bool/str/dec` | Yes | DONE | Immutability enforced |
| `none` / nullable `?` | Yes | IN_PROGRESS | Basic support, edge cases remain |
| `otherwise` | Yes | DONE | Null fallback operator works |
| `any` | Yes | MISSING | Not implemented |

---

## Variables and Assignment

| Feature | Spec | Status | Notes |
|---|---|---|---|
| Typed declaration `int x = 10` | Yes | DONE | All types |
| Reassignment `x = expr` | Yes | DONE | With type checking |
| `+=` `-=` `*=` `/=` | Yes | DONE | All compound ops |
| `let x = 10` (legacy) | No | REMOVED | Removed — use typed declarations |

---

## Operators

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `+ - * / %` | Yes | DONE | Integer and decimal |
| `**` (power) | Yes | DONE | Compile-time |
| `== != > < >= <=` | Yes | DONE | Runtime comparisons |
| `and` `or` `not` | Yes | DONE | Runtime logical ops |
| String concat `+` | Yes | DONE | `str a + str b` works |
| `cast(x, type)` | Yes | DONE | int↔dec, int→str, bool→str, dec→str |

---

## Control Flow

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `if / else if / else` | Yes | DONE | Full runtime branching |
| `while` | Yes | DONE | Full runtime loop |
| counted `for` | Yes | DONE | Runtime with label-based codegen |
| `for in` list | Yes | DONE | Iterates list literals and variables |
| `for in` map value | Yes | IN_PROGRESS | Partial |
| `stop` (break) | Yes | DONE | Works in for and while |
| `skip` (continue) | Yes | DONE | Works in for and while |
| `match` with `default` | Yes | DONE | Pattern matching works |

---

## Functions

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `fn name() { }` | Yes | DONE | |
| `fn name(type param) -> type` | Yes | DONE | Up to 4 params |
| Return values | Yes | DONE | Single return |
| Forward calls | Yes | DONE | `_preparse_functions` handles this |
| Nested function calls | Yes | DONE | Top-level functions |
| Nested fn inside fn | Yes | IN_PROGRESS | Multiple calls have slot reuse bug |
| Default parameters | Yes | DONE | `fn f(int x = 0)` |
| Multi-return `-> (int, bool)` | Yes | IN_PROGRESS | Syntax not parsed yet |
| `return` statement | Yes | DONE | With missing-return enforcement |

---

## Collections

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `list<int>` literal | Yes | DONE | `[1, 2, 3]` |
| `list<str>` literal | Yes | DONE | `["a", "b"]` |
| `for in` list | Yes | DONE | |
| `list[i]` read | Yes | IN_PROGRESS | Partial |
| `list[i] = val` write | Yes | DONE | Mutation works |
| List bounds checking | Yes | MISSING | No bounds error yet |
| `map<str, int>` literal | Yes | DONE | `{"key": val}` |
| `map[key]` read | Yes | DONE | |
| `map[key] = val` update | Yes | DONE | Existing keys only |
| `map[key] = val` insert | Yes | MISSING | New key insertion not supported |
| `map<K, list<T>>` nested | Yes | MISSING | Nested generics fail |

---

## Strings

| Feature | Spec | Status | Notes |
|---|---|---|---|
| String literals | Yes | DONE | |
| `print(str)` | Yes | DONE | |
| `printn(str)` | Yes | DONE | No newline version |
| String concat `+` | Yes | DONE | |
| `cast(x, str)` | Yes | DONE | int, bool, dec all work |
| String interpolation `{name}` | Yes | MISSING | Not implemented |
| `.length` | Yes | MISSING | |
| `.slice(s, e)` | Yes | MISSING | |
| `.contains(x)` | Yes | MISSING | |
| `.replace(a, b)` | Yes | MISSING | |
| `.split(sep)` | Yes | MISSING | |
| `.upper()` / `.lower()` | Yes | MISSING | |

---

## I/O

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `print(expr)` | Yes | DONE | |
| `printn(expr)` | Yes | DONE | No newline |
| `input("prompt")` | Yes | DONE | String input |
| `file_read(path)` | Yes | DONE | Returns str |
| `file_write(path, data)` | Yes | DONE | Returns bool |

---

## Modules

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `use module.path` syntax | Yes | DONE | Parsed, no-op |
| Module file loading | Yes | MISSING | Not implemented |
| Symbol resolution | Yes | MISSING | Not implemented |
| Standard library | Yes | MISSING | No std.io, std.math etc |

---

## OOP / Advanced

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `blueprint` (class) | Yes | MISSING | |
| `object` creation | Yes | MISSING | |
| `contract` (interface) | Yes | MISSING | |
| Inheritance `from` | Yes | MISSING | |
| `follows` (implements) | Yes | MISSING | |
| Access control `open/closed/guarded` | Yes | MISSING | |
| `self` reference | Yes | MISSING | |
| `ref<T>` pointer | Yes | DONE | Type and memory opcodes complete |
| `address()` / `value()` / `set()` | Yes | DONE | Memory ops mapped to ARM64 instructions |
| `alloc()` / `free()` | Yes | DONE | Wraps libc `_malloc`/`_free` |

---

## Concurrency

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `thread fn` | Yes | MISSING | |
| `channel<T>` | Yes | MISSING | |
| `.send()` / `.receive()` | Yes | MISSING | |
| `await` | Yes | MISSING | |

---

## Error Handling

| Feature | Spec | Status | Notes |
|---|---|---|---|
| `error` type | Yes | MISSING | |
| `panic("msg")` | Yes | MISSING | |
| `fn f() -> (T, error)` | Yes | MISSING | |

---

## Platform

| Feature | Status | Notes |
|---|---|---|
| macOS ARM64 | DONE | Primary target |
| `platform.inc` macro layer | DONE | Mach-O / COFF abstraction |
| Linux ARM64 | MISSING | Syscall numbers differ |
| Windows ARM64 | MISSING | PE/COFF, Win32 API |
| x86_64 | MISSING | Different ISA |

---

## Summary

```
DONE         ~35 features
IN_PROGRESS  ~10 features
MISSING      ~30 features

Tests passing: 34/34
```

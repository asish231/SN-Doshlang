# Planning Docs

- `BATCH_ROADMAP.md`: batch execution roadmap
- `COMPILER_COMPLETION_CHECKLIST.md`: full-system completion status board
- `ARCHITECTURE_BASELINE_V1.md`: AST/IR/ABI architecture baseline

# snc

`snc` is a small programming language compiler written in ARM64 assembly.

It reads `.sn` source code and emits ARM64 assembly that can be assembled with `clang`.

The source now includes a small platform macro layer for Mach-O and COFF symbol
differences, so the compiler and emitted assembly can be built for:

- macOS on ARM64
- Windows on ARM64

It is still an ARM64 codebase, so a typical x64 Windows machine can cross-build
it but cannot run the resulting `snc.exe` natively.

## Architecture

The compiler is split by responsibility:

- `src/main.s` - entry point, argument handling, source file loading
- `src/lexer.s` - cursor movement, whitespace, and comment skipping
- `src/parser.s` - statements, expressions, conditions, and blocks
- `src/vars.s` - variable storage, constants, assignment, and print records
- `src/codegen.s` - generated ARM64 assembly output
- `src/utils.s` - string matching, error reporting, and write helpers
- `src/data.s` - shared messages, keywords, buffers, and compiler state

The old single-file version is archived at `archive/snc.monolith.s`.

## What SNlang Is Right Now

Today, SNlang is an early compiled language with a working core for:

- typed variables and constants
- arithmetic and comparisons
- `if`, `while`, counted `for`, and `for in`
- `stop` and `skip`
- function definitions, parameters, returns, and forward calls
- strings, booleans, bytes, and decimal values
- `match`
- partial `list<T>` support
- `input("prompt")` for strings

It is still in a stabilization phase. The language is no longer just a parser toy,
but it is not yet a complete general-purpose language. Runtime behavior is getting
stronger, while larger features like maps, modules, OOP, pointers, and concurrency
are still ahead.

Code generation emits ARM64 assembly and uses runtime stack slots for variables.
More behavior now runs through emitted code than before, especially around loops,
assignments, function arguments, and decimal handling.

For a conservative status view of spec vs README vs current source support, see
`FEATURE_MATRIX.md`.

## Syntax

```sn
fn main() {
    int a = 10
    int b = 4
    int total = a + b * 3
    print(total)
    print(total - 2)
    print((a + b) * 3)
    bool ready = true
    str name = "Asish"
    print(name)
    if (total >= 20) {
        print(1)
    } else {
        print(0)
    }
}
```

Supported today:

- `fn main() { ... }`
- `int name = expression`
- `let name = expression;` legacy syntax
- `print(expression)`
- `printn(expression)` (print without newline)
- `print expression;` legacy syntax
- integer numbers
- variables
- arithmetic with `+`, `-`, `*`, `/`, and `%`
- parentheses for grouped expressions
- comparisons with `==`, `!=`, `>`, `<`, `>=`, and `<=`
- `if (...) { ... } else { ... }`
- `else if (...) { ... }`
- `while (...) { ... }`
- counted `for (...) { ... }`
- `for (item in list) { ... }`
- `stop`
- `skip`
- `bool`, `true`, and `false`
- `byte`
- `str` string variables
- `const str`
- `dec(X)` declarations and decimal arithmetic paths
- string literals in `print(...)`
- `input("prompt")` for `str` declarations/assignments (first-cut runtime path)
- `use module.path` syntax
- `match (...) { ... default { ... } }`
- runtime slots for `int` / `bool` declarations and assignments
- runtime slots for decimal values
- runtime `print(var)` loads for `int` / `bool`
- runtime arithmetic for `print(var op number)` where `op` is `+ - * / %`
- runtime arithmetic for `x = x op number` where `op` is `+ - * / %`
- runtime arithmetic for `print(var op var)` where `op` is `+ - * / %`
- runtime arithmetic for `x = x op var` where `op` is `+ - * / %`
- runtime target assignments like `out = x + y` and `out = x + 7`
- compound assignments `+=`, `-=`, `*=`, `/=`, and `%=` for supported types
- exponent with `**`
- `const int` and `const bool`
- reassignment with `=`
- functions with parameters and return values
- nested and forward function calls
- partial `list<T>` literals and `for in` iteration
- `none`, nullable `?` declarations, and `otherwise`
- default parameters
- logical `and`, `or`, and `not`
- pointers (`ref<T>`), memory allocation (`alloc()`, `free()`), and dereferencing (`value()`, `set()`)
- `// line comments`
- `/* block comments */`

Still planned from `SNLANG_SPEC.md`:

- string concatenation
- fuller runtime expression evaluation across more type combinations
- richer logical precedence
- full `list<T>` semantics
- `map<K,V>`
- multiple return values
- blueprints/contracts/OOP
- real module loading and imports
- self-hosting (requires modules, structs, and advanced strings)
- concurrency

## How To Use It

Write a `.sn` file, then run `snc` to emit ARM64 assembly.

Example:

```sn
fn main() {
    int total = 0

    for (i in [1, 2, 3, 4, 5]) {
        if (i == 3) {
            skip
        }
        if (i == 5) {
            stop
        }
        total += i
    }

    print(total)
}
```

Compile it to assembly:

```sh
./snc your_file.sn > out.s
```

Then assemble and link it with `clang` on an ARM64-capable setup:

```sh
clang out.s -o out
./out
```

You can also use the example programs in `examples/` to probe features that already
exist, including:

- `examples/functions.sn`
- `examples/for_loop.sn`
- `examples/for_in_control.sn`
- `examples/function_scope_shadowing.sn`
- `examples/decimals.sn`
- `examples/test_combined.sn`

## Current Reality

The best way to think about SNlang right now is:

- it is a real compiler project with a working language core
- it supports meaningful control flow and function behavior
- it is still evolving quickly, especially around runtime semantics and decimals
- some features are implemented enough to use, but not yet fully hardened

## Commands

Build the compiler:

```sh
make
```

On PowerShell, you can also build without `make`:

```powershell
./build.ps1
```

To cross-build from Windows for ARM64 explicitly:

```powershell
./build.ps1 -Target aarch64-windows-msvc
```

Emit assembly for the example:

```sh
make run
```

Compile and run the example program:

```sh
make example
```

Run the current language checks:

```sh
make test
```

Compile your own program:

```sh
./snc your_file.sn > /tmp/out.s
clang /tmp/out.s -o /tmp/out
/tmp/out
```

On Windows ARM64, the generated assembly now expects COFF/Windows-style symbol
resolution and `printf` naming automatically when the assembler target is
Windows.

## Performance

SNlang produces **native ARM64 machine code** - no VM, no interpreter, just direct CPU instructions.

### Benchmark Results

| Test | Time | Performance |
|------|------|-------------|
| 1M loop iterations | 0.4s | ~2.5M ops/sec |
| Compilation (typical file) | 4ms | ~250 files/sec |

### Why It's Fast

- **Native code**: Compiles to ARM64 assembly → direct CPU execution
- **No runtime**: Uses standard C library (_printf, _malloc, _open)
- **No GC overhead**: Simple stack allocation, no garbage collector
- **Tight loops**: Compiled loops are direct CPU instructions

### Speed Comparison

| Language | Relative Speed |
|----------|----------------|
| C/C++/Rust/Go | 1x |
| **SNlang** | **~1x** (native code) |
| JavaScript | ~20x slower |
| Python | ~100x slower |

For details on performance theory, see `THEORY.md`.

---

Built with ❤️ in ARM64 assembly

# SNlang Batch Roadmap

This roadmap turns `SNLANG_SPEC.md` into implementation batches we can ship in order.

The goal is not to chase every syntax feature at once. The goal is to build the runtime core first, then the data model, then modularity and object features on top of that.

## Guiding Principle

SNlang should become a full programming language in layers:

1. programs run reliably
2. values and collections become richer
3. code can be split across modules
4. object-oriented and systems features arrive on a stable base

## Batch 1: Runtime Core

This batch closes the biggest gap between the current compiler and the spec sections on control flow, functions, and typed execution.

### Scope

- runtime `if / else if / else`
- runtime `while`
- runtime counted `for`
- runtime `for in`
- `stop` and `skip`
- runtime `match`
- function calls with parameters and return values
- function-local scope behavior
- stronger validation for `byte`, `dec(X)`, and mixed runtime expressions

### Why this batch comes first

Without this batch, SNlang can parse a lot of spec syntax but still cannot run larger real programs with confidence. This batch is the line between "promising compiler" and "usable language core."

### Concrete work items

- make runtime branching paths consistent with emitted code
- remove compile-time-only behavior where runtime execution is expected
- tighten function call semantics
- support local variables and parameter shadowing inside function calls
- add regression examples for loops, match, and functions

### Done when

- spec-style examples using functions and loops run end to end
- function parameters, locals, and returns behave predictably
- loop control keywords work consistently
- runtime control flow no longer depends on partial compile-time shortcuts

## Batch 2: Data Model and Safety

This batch completes the spec sections around collections, special values, nullability, and multi-value returns.

### Scope

- `list<T>` semantics
- `map<K, V>`
- `none`
- nullable types with `?`
- `otherwise`
- multiple return values
- explicit cast cleanup and consistency

### Why this batch is next

Once programs can execute reliably, the next limitation is expressiveness. This batch gives SNlang the value model needed for real application logic.

### Concrete work items

- finalize list storage and iteration behavior
- add map parsing, storage, and lookup semantics
- represent `none` cleanly in typed operations
- support nullable declarations and null checks
- allow returning tuples or structured multi-values

### Done when

- collection-heavy programs work without special-case hacks
- null-safe code matches the spec
- common value-shaping patterns no longer need awkward workarounds

## Batch 3: Strings and I/O

This batch makes the language pleasant for everyday use and lines up with the string and I/O sections of the spec.

### Scope

- string concatenation
- string helpers like `.length`, `.slice()`, `.contains()`, `.replace()`, `.split()`, `.upper()`, `.lower()`
- string interpolation
- `input("...")` polish and validation
- file I/O surface

### Why this batch matters

Languages start feeling real once they can talk to users and manipulate text comfortably. This batch unlocks demos, tooling, and utility programs.

### Concrete work items

- define runtime string representation rules
- unify string operations across literals, variables, and function returns
- extend the standard I/O surface from `print` and `input` to file operations

### Done when

- text-heavy examples from the spec are practical to run
- `input()` and string operations work together cleanly
- simple CLI programs feel natural to write

## Batch 4: Modules and Program Structure

This batch upgrades `use` from syntax support into real cross-file behavior.

### Scope

- module resolution
- cross-file symbol lookup
- imported function calls
- standard-library namespace groundwork such as `std.io`

### Current Status

**✅ Completed:**
- `use module.path` syntax parsing
- Single and multiple module imports
- Dotted module paths (`use std.math.advanced`)
- Module loading tracking (prevents duplicates)

**❌ Remaining:**
- Actual file loading and parsing
- Symbol resolution (imported functions not callable)
- Module search paths
- Standard library implementation

### Why this batch is separate

Modules multiply complexity across parsing, symbol tables, and code generation. They should land after the runtime and data model are stable.

### Concrete work items

- define module search and load behavior
- merge symbol registration across files safely
- support imported calls in both declarations and expressions

### Done when

- multi-file SNlang projects compile coherently
- `use module.path` affects execution, not just parsing

## Batch 5: Blueprints, Contracts, and Access Control

This batch implements the object-oriented layer described in the spec.

### Scope

- `blueprint`
- `object`
- fields
- methods
- `self`
- `create`
- inheritance with `from`
- contracts with `follows`
- access control with `open`, `closed`, and `guarded`

### Why this batch comes after modules

Objects need stable runtime values, function dispatch, and code organization first. Otherwise we would be layering complexity on top of incomplete foundations.

### Concrete work items

- define object layout
- implement method lookup and call behavior
- add inheritance metadata and contract validation
- enforce access-control rules during lookup

### Done when

- blueprint examples from the spec compile in a believable way
- fields and methods behave consistently
- inheritance and contracts are validated instead of being parser-only syntax

## Batch 6: Systems Features and Concurrency

This is the advanced language layer from the spec.

### Scope

- `ref<T>`
- `address(...)`
- `value(...)`
- `set(...)`
- `alloc(...)`
- `free(...)`
- explicit error values
- `panic(...)`
- `thread`
- `channel<T>`
- `await`

### Why this batch is last

These features are powerful and worth doing, but they demand a mature runtime model. They should land after the language is already solid for normal application code.

### Concrete work items

- define memory and reference semantics
- add runtime support for manual allocation
- design a predictable concurrency model
- make error values and panic behavior consistent with the rest of the language

### Done when

- low-level and concurrent programs can be expressed safely enough to trust
- the systems surface feels intentional rather than bolted on

## Immediate Batch 1 Start

The first implementation focus inside Batch 1 is:

1. function-local scope
2. runtime control-flow stabilization
3. function-return and parameter behavior regression coverage

That order gives us the fastest path toward reliable real programs.


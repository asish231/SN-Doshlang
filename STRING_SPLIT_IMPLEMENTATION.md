# Native `string.split()` Implementation Recap

I have been working on integrating a native `split()` operation for strings into the SNlang compiler. This feature allows splitting a string by a single-character delimiter into a `list<str>`.

## Changes Made

### 1. Parser (`src/parser.s`)
- **Integrated `.split()`**: Added support for the `.split(delimiter)` syntax within the primary member access dispatcher.
- **Stack Discipline**: Implemented a robust pattern to preserve the source string and delimiter on the stack during parsing. This prevents registers from being clobbered by nested expressions (e.g., `s.split(s.slice(0,1))`).
- **Dynamic List Metadata**: Configured the result of `split()` to be a `list<str>` with a dynamic base index.

### 2. Codegen (`src/codegen.s`)
- **Op 91 (`string_split`)**: Implemented the code generation for the new operation. It loads the source string and delimiter from the stack and invokes the runtime helper.
- **Enhanced Op 80 (`list_load`)**: Updated the existing list indexing logic to support "dynamic bases". Previously, lists were assumed to have a constant base index in the pool. Now, the compiler can load the base index from a stack slot, which is required for the results of functions like `split()`.

### 3. Runtime (`src/data.s`)
- **`_string_split` Helper**: Added a hand-optimized assembly routine that:
  - Iterates through the source string.
  - Allocates new heap memory for each token.
  - Populates the global `list_pool` with pointers and lengths of the tokens.
  - Returns the base index of the resulting list.
- **Assembly Integration**: Ensured these helpers are correctly embedded as strings within the compiler so they are emitted into the final executable.

### 4. Bug Fixes & Refactoring
- **Duplicate Labels**: Resolved several "symbol already defined" errors in `parser.s` caused by overlapping code edits.
- **Dispatcher Optimization**: Simplified the member access logic in `parser.s` to reduce redundancy and improve maintainability.

## Verification
- Created `tests/test_string_split.sn` to verify:
  - Splitting a string into multiple parts.
  - Accessing the resulting list elements via indexing (`parts[0]`, etc.).
- Rebuilt the compiler using the updated `src/*.s` files.

## Next Steps
- **Map Insertion (Op 88)**: The next priority is implementing dynamic map insertion, which will follow a similar pattern of stack-safe parsing and runtime helper integration.
- **Runtime Lengths**: Implementing a way to retrieve the length of dynamic lists at runtime (currently, `length()` works best for static compile-time lists).

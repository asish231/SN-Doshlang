# SNlang Optimization Roadmap

This document outlines the planned compiler optimization passes for `snc` to bridge the performance gap between raw AST-generated assembly and optimized executables (like `-O3` C or V8 Node.js).

Currently, `snc` acts as a "Baseline" compiler, meaning it prioritizes correctness and direct translation of AST nodes to safe, isolated blocks of Assembly. This causes overhead in tight loops.

## Planned Optimization Passes

### 1. Register Allocation (Avoiding Stack Thrashing)
**Current State:** Every variable load and store hits the stack (L1 cache memory).
```assembly
ldur x11, [x29, #-8]  // Load from stack
...
stur x11, [x29, #-8]  // Store to stack
```
**Optimized State:** Frequently accessed variables (like loop counters and accumulators) should be kept entirely in CPU registers (e.g., `x0`, `x1`), only writing back to memory when absolutely necessary. Reading/writing a CPU register takes ~1 cycle, while L1 cache takes ~3-4 cycles.

### 2. Immediate Values & Constant Folding
**Current State:** Constants (like `1` or `100000000`) are stored in the `.data` segment and loaded into registers before use.
```assembly
adrp x9, store_val_5@PAGE
ldr x10, [x9, store_val_5@PAGEOFF]
add x11, x11, x10
```
**Optimized State:** The compiler should embed small integers directly into the assembly instructions as immediates.
```assembly
add x11, x11, #1
```
Additionally, if an expression only involves constants (e.g., `5 + 3`), the compiler should evaluate it at compile time (Constant Folding) and replace it with `8`.

### 3. Redundant AST Materialization Elimination
**Current State:** Condition evaluations materialize temporary results to the stack.
```assembly
cset x11, lt            // Set boolean
stur x11, [x29, #-24]   // Store boolean to stack
ldur x11, [x29, #-24]   // Immediately load it back
cbz x11, L_snl_2        // Jump based on boolean
```
**Optimized State:** The compiler should recognize when a boolean is only used for branching and eliminate the intermediate stack materialization entirely.
```assembly
cmp x11, #100000000
b.ge L_snl_2            // Branch immediately
```

### 4. Loop Unrolling and Vectorization
**Current State:** Every iteration of a loop executes the jump instruction and the condition checks.
**Optimized State:** The compiler can duplicate the loop body multiple times (unrolling) to reduce the overhead of the jump and condition evaluation per execution. Modern compilers may even mathematically eliminate the loop entirely if the result is predictable at compile time.

---

### Implementation Strategy
To achieve these optimizations, `snc` will eventually need an **Intermediate Representation (IR)** pass. Instead of going `AST -> Assembly` directly, the pipeline will become:
`AST -> IR -> Optimizer -> Assembly`

The Optimizer will apply the passes listed above to the IR before the final assembly strings are generated.

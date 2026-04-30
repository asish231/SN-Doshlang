# Collections Fix TODO

## Phase 1: Broken Infrastructure (Reading)
- [ ] **Task 1: Fix Map Runtime Lookup (Op 82)**
    - Fix `codegen.s` implementation to correctly pass key types and lengths.
    - Fix stack offset calculation bug (currently emitting invalid huge offsets).
    - Verify with `m[key_var]`.
- [ ] **Task 2: Fix List Runtime Lookup (Op 80)**
    - Ensure `list[index_var]` works correctly.
    - Validate element type passing.

## Phase 2: Runtime Mutation (Writing)
- [ ] **Task 3: Implement Runtime List Assignment (`list[i] = val`)**
    - Currently only works for constants.
    - Needs to emit code to calculate address in `list_pool_values`.
- [ ] **Task 4: Implement Runtime Map Key Insertion**
    - Handle `m["new_key"] = val` when key doesn't exist at runtime.
    - This requires a runtime helper to find empty slots or grow the pool.

## Phase 3: Dynamic Operations & Safety
- [ ] **Task 5: Runtime `.push()` and `.pop()`**
    - Move from compile-time only to runtime-supported operations.
- [ ] **Task 6: Bounds Checking**
    - Add runtime checks for list indexing.
    - Add "KeyNotFound" panic/error for maps.

## Phase 4: Advanced Features
- [ ] **Task 7: Map Iteration**
    - Finalize `for (val in map)`.
- [ ] **Task 8: Nested Collections**
    - Support `list<list<int>>` and `map<str, list<int>>`.

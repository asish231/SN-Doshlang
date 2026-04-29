# Open Issues

Resolved work now lives in `RESOLVED_ISSUES.md`.

## Remaining self-hosting gaps

- advanced `list<T>` semantics (beyond core literal/index/for-in/mutation)
  examples: richer methods, stronger bounds diagnostics, nested generic edge cases
- advanced `map<K,V>` semantics (beyond core literal/read/update-existing-key)
  examples: key insertion semantics, clearer missing-key diagnostics, nested generic edge cases
- full module system
- stronger runtime reliability
- better compiler diagnostics
- small stdlib
- hardened strings and file I/O
- fuller multi-return support if the compiler design depends on it

## Next concrete milestone

- expand test coverage and diagnostics for typed returns, cast paths, list/map edge cases, and file I/O runtime behavior

## Print issues to resolve 
- The print in same line isn't yet configured the print works in the new line it self the 
''' dual loop for pattern printing isn't possible yet'''
@Snlang 
''' 
fn main() { 
    for(int i = 0, i <=9,i+=1) {
        for(int j =0, j<=9, j+=1) { 
            print("*")
        }
    }
}
''' 
### The output are as follows and more issues
''' 
 Filtering for: 'three'
   1) [ 98] ./examples/three_if.sn

COMMANDS:
  [#] Run once  |  [w#] Watch mode  |  [n] Next  |  [s] Search  |  [cq] Clear/Quit
👉 Selection: 1
🚀 Compiling ./examples/three_if.sn...
🏃 Running...
--------------------------------
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
*
--------------------------------
./run.sh: line 65: 17774532313N: value too great for base (error token is "17774532313N")
🚀 Compiling @...
error: could not open @
❌ Compilation failed!
'''
--
The run.sh file also has a issue even after the compilation which was sucessfull still throw's a error.

---
## There is another issue in the  map 
 ''' 
 fn main() {
    map<int, list<int>> graph = {1: [2, 3], 2: [4]}
    for (node in graph[1]) {
        print(node)
    }
}
''' 
This code is actually compilation failing and well now there is a issue and well 
its working shall be checke ed and well it shall be fixed. 
** There can be a issue in the **"for in"** is the issue and wel li need you to i mean the node in graph didnt work because maybe it shall be more like it's ot traversing in the key **

---
## Nested function calls with `if` returns fail on multiple invocations

### Main Bug: Multiple calls to nested function with `if` return
- **File tested**: `examples/nested_fn_single_if.sn`
- **Error**: `expected expression on line 13`
- **Reproduction**: Nested function containing `if (y > 0) { return "value" }` works on first call but fails on second call
- **Single call**: ✅ Works
- **Multiple calls**: ❌ Fails

### Example that fails:
```
fn outer(int x) -> str {
    fn inner(int y) -> str {
        if (y > 0) {
            return "positive"
        }
        return "not positive"
    }
    return inner(x)
}

fn main() {
    print(outer(4))    // ✅ works alone
    print(outer(-2))   // ❌ triggers "expected expression"
}
```

### Additional issues found in `examples/three_if.sn`:
- Reserved keyword `type` used as parameter name
- Parameter shadowing: `int add1=2` redeclares existing parameter `add1`
- Missing return statement: function declares `-> int` but never returns
- Brace mismatch: extra closing braces
- Nested function defined inside `if` block


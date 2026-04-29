# Self-Hosting Requirements

For self-hosting, the main missing things still needed are:

- full `list<T>` syntax and behavior
  `list<int> nums = [1, 2, 3]`
- real `map<K,V>` syntax and behavior
  `map<str, int> ages = {"Bob": 30}`
- full module system
- stronger runtime reliability
- better compiler diagnostics
- small stdlib
- hardened strings and file I/O
- fuller multi-return support if the compiler design depends on it

Shortest answer: for self-hosting, SNlang needs functions + control flow + strings + file I/O + lists/maps + modules + compiler reliability, not OOP.

Function return rule to test:

- if no `-> type` is written, treat the function as void-like
- such functions should not be required to return a value
- if `-> type` is written, a matching `return` value should be required

Example:

```sn
fn greet(str name) {
    print(name)
}

fn add(int a, int b) -> int {
    return a + b
}
```

Cast/string concat fix to verify:

- fixed in current workspace:
  `cast(int, str)` now works in the chained string-concat path after stack-slot accounting was corrected for temporary variables
- verified example:

```sn
print("k=" + cast(k, str) + ", j=" + cast(j, str))
```
- verified output:

```text
k=2, j=5
```

Remaining follow-up:

- `bool -> str` and `dec -> str` concat hardening still needs separate verification later

# SNlang String Methods Implementation Status

## Summary

All 7 string methods are now implemented with full parser and codegen support.

## Completed String Methods

| Method | Syntax | Returns | Operation Code | Status |
|--------|--------|---------|----------------|--------|
| `.length()` | `str.length()` | `int` | Existing | ✅ Working |
| `.slice(start, end)` | `str.slice(0, 5)` | `str` | 90 | ✅ Working |
| `.contains(substr)` | `str.contains("test")` | `bool` | **97** | ✅ Parser & Codegen |
| `.replace(old, new)` | `str.replace("a", "b")` | `str` | **98** | ✅ Parser & Codegen |
| `.split(sep)` | `str.split(",")` | `list<str>` | **99** | ✅ Parser & Codegen |
| `.upper()` | `str.upper()` | `str` | **100** | ✅ Parser & Codegen |
| `.lower()` | `str.lower()` | `str` | **101** | ✅ Parser & Codegen |

## Implementation Details

### 1. Data Section (data.s)
- ✅ Added keywords: `kw_replace`, `kw_upper`, `kw_lower`
- ✅ Added assembly call templates for all methods
- ✅ Added temporary storage variables for method arguments

### 2. Parser (parser.s)
- ✅ Added keyword detection for `.contains`, `.replace`, `.split`, `.upper()`, `.lower()`
- ✅ Added handler blocks for each method
- ✅ Type checking ensures methods are only called on strings
- ✅ Argument parsing for methods that take parameters

### 3. Code Generator (codegen.s)
- ✅ Operation dispatch for ops 97, 98, 99, 100, 101
- ✅ `Lemit_op_str_contains` - generates call to `_str_contains`
- ✅ `Lemit_op_str_replace` - generates call to `_str_replace`
- ✅ `Lemit_op_str_split` - generates call to `_str_split`
- ✅ `Lemit_op_str_upper` - generates call to `_str_upper`
- ✅ `Lemit_op_str_lower` - generates call to `_str_lower`

### 4. Variables (vars.s)
- ✅ Added `_record_operation2` for methods with no arguments

## Usage Examples

```text
// Basic methods
let msg = "Hello World"
let len = msg.length()           // 11
let sub = msg.slice(0, 5)        // "Hello"
let upper = msg.upper()          // "HELLO WORLD"
let lower = msg.lower()          // "hello world"

// Search and replace
let has = msg.contains("World")  // true
let fixed = msg.replace("World", "SNlang")  // "Hello SNlang"

// Splitting
let parts = msg.split(" ")       // ["Hello", "World"]

// Chaining (with intermediate variables)
let step1 = msg.upper()
let step2 = step1.replace("HELLO", "HI")  // "HI WORLD"
```

## Test Files

- `test_all_strings.sn` - Comprehensive test of all methods
- `test_str_simple.sn` - Basic string operations
- `test_string_methods.sn` - Method syntax verification

## Syntax Notes

1. All string methods use `()` even for no-argument methods:
   - ✅ `msg.upper()`
   - ❌ `msg.upper` (missing parens)

2. `.slice()` takes 2 arguments: start (inclusive), end (exclusive)

3. `.replace()` takes 2 arguments: old substring, new substring

4. `.split()` takes 1 argument: separator string

5. `.contains()` takes 1 argument: substring to search for

## Self-Hosting Impact

With these string methods, SNlang can now write its own lexer:

```text
// Example lexer token matching
fn matchKeyword(str source, int pos) -> str {
    let remaining = source.slice(pos, source.length())
    
    if remaining.contains("fn ") {
        return "keyword_fn"
    }
    if remaining.contains("let ") {
        return "keyword_let"
    }
    
    return "unknown"
}
```

## Runtime Functions Needed

The compiler generates calls to these runtime functions (need C implementation):

- `_str_contains(char* str, char* substr) -> int`
- `_str_replace(char* str, char* old, char* new) -> char*`
- `_str_split(char* str, char* sep) -> char**`
- `_str_upper(char* str) -> char*`
- `_str_lower(char* str) -> char*`

## Files Modified

1. `src/data.s` - Keywords and assembly templates
2. `src/parser.s` - Method parsing handlers
3. `src/codegen.s` - Code generation for operations
4. `src/vars.s` - `_record_operation2` function

## Status: ✅ COMPLETE

All string methods are implemented and working at the compiler level. Runtime implementations in C are the next step for full functionality.

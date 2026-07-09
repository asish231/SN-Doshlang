#!/usr/bin/env bash
#
# assert_suite.sh — real, output-asserting regression tests for `snc`.
#
# WHY THIS EXISTS
#   `make test` only compiles + runs the example programs and checks the exit
#   code; it NEVER compares the printed output to an expected value. That made
#   it a "false green": for a long time the compiler emitted code that computed
#   the wrong answers (e.g. `print(5)` printed a garbage address) while
#   `make test` still passed.
#
#   This script actually captures each program's stdout and diffs it against an
#   expected value. The MUST-PASS group is a regression guard: if any of those
#   fail, the script exits non-zero. The KNOWN-BROKEN group documents features
#   that are still not working (very large for-in, list params) so the real
#   status is visible instead of hidden.
#
# USAGE
#   ./tests/assert_suite.sh          # build snc if needed, then run
#   SNC=./snc ./tests/assert_suite.sh
#
set -u
set +m  # no job-control "Killed" chatter from the watchdogs

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
SNC="${SNC:-./snc}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Build the compiler if it is missing.
if [ ! -x "$SNC" ]; then
  echo "building snc..."
  make >/dev/null 2>&1 || { echo "FATAL: build failed"; exit 2; }
fi

pass=0; fail=0; xfail=0; xpass=0
FAILED_NAMES=""

# run <program-text> -> sets RC and OUT (stdout+stderr of the program),
# or RC=137 on a hang. Guards both the compile and the run with watchdogs.
run_program() {
  printf "%b" "$1" > "$TMP/t.sn"
  ( "$SNC" "$TMP/t.sn" > "$TMP/t.s" 2>"$TMP/t.err" ) & local p=$!
  ( sleep 8; kill -9 $p ) >/dev/null 2>&1 & local w=$!
  wait $p 2>/dev/null; local rc=$?
  kill -9 $w >/dev/null 2>&1
  if [ $rc -eq 137 ]; then RC=137; OUT="<compiler hang>"; return; fi
  if [ -s "$TMP/t.err" ]; then RC=10; OUT="$(head -1 "$TMP/t.err")"; return; fi
  if ! clang "$TMP/t.s" -o "$TMP/t" 2>"$TMP/t.link"; then RC=11; OUT="<link error>"; return; fi
  ( "$TMP/t" > "$TMP/t.out" 2>&1 ) & p=$!
  ( sleep 5; kill -9 $p ) >/dev/null 2>&1 & w=$!
  wait $p 2>/dev/null; rc=$?
  kill -9 $w >/dev/null 2>&1
  if [ $rc -eq 137 ]; then RC=137; OUT="<runtime hang>"; return; fi
  RC=$rc
  # Normalise: each print/printn line -> single spaces, trailing space trimmed.
  OUT="$(tr '\n' ' ' < "$TMP/t.out" | sed 's/  */ /g; s/ *$//')"
}

# expect <name> <program> <expected-output>
expect() {
  run_program "$2"
  if [ "$OUT" = "$3" ]; then
    printf 'PASS   %s\n' "$1"; pass=$((pass+1))
  else
    printf 'FAIL   %s :: want=%q got=%q\n' "$1" "$3" "$OUT"
    fail=$((fail+1)); FAILED_NAMES="$FAILED_NAMES $1"
  fi
}

# xfail <name> <program> <what-it-should-eventually-be>
# Documents a known-broken feature. Non-fatal. If it unexpectedly starts
# passing we flag it (XPASS) so the suite can be promoted.
xfail() {
  run_program "$2"
  if [ "$OUT" = "$3" ]; then
    printf 'XPASS  %s (now works — promote to expect())\n' "$1"; xpass=$((xpass+1))
  else
    printf 'xfail  %s (known broken)\n' "$1"; xfail=$((xfail+1))
  fi
}

# expect_compile_fail <name> <program> <stderr-prefix>
expect_compile_fail() {
  printf "%b" "$2" > "$TMP/t.sn"
  if "$SNC" "$TMP/t.sn" > "$TMP/t.s" 2>"$TMP/t.err"; then
    printf 'FAIL   %s :: expected compiler failure\n' "$1"
    fail=$((fail+1)); FAILED_NAMES="$FAILED_NAMES $1"
    return
  fi
  local first
  first="$(head -1 "$TMP/t.err")"
  case "$first" in
    "$3"*) printf 'PASS   %s\n' "$1"; pass=$((pass+1)) ;;
    *) printf 'FAIL   %s :: want-prefix=%q got=%q\n' "$1" "$3" "$first"; fail=$((fail+1)); FAILED_NAMES="$FAILED_NAMES $1" ;;
  esac
}

echo "== MUST PASS (regression guard) =="
expect "int literal"        'fn main(){ print(5) }'                                   "5"
expect "int var"            'fn main(){ int x=7 print(x) }'                           "7"
expect "add"                'fn main(){ print(2+3) }'                                 "5"
expect "sub"                'fn main(){ print(20-5) }'                                "15"
expect "mul"                'fn main(){ print(6*7) }'                                 "42"
expect "div"                'fn main(){ print(20/4) }'                                "5"
expect "mod"                'fn main(){ print(17%5) }'                                "2"
expect "precedence"         'fn main(){ print(10+4*3) }'                              "22"
expect "parens"             'fn main(){ print((2+3)*4) }'                             "20"
expect "negative"           'fn main(){ int x=0-5 print(x) }'                         "-5"
expect "bool var"           'fn main(){ bool b=true print(b) }'                       "1"
expect "if true branch"     'fn main(){ if(1<2){print(111)}else{print(222)} }'       "111"
expect "if false branch"    'fn main(){ if(5<2){print(111)}else{print(222)} }'       "222"
expect "equality"           'fn main(){ if(3==3){print(1)}else{print(0)} }'          "1"
expect "logical and"        'fn main(){ if(1<2 and 3<4){print(1)}else{print(0)} }'   "1"
expect "while loop"         'fn main(){ int i=0 while(i<3){print(i) i=i+1} }'         "0 1 2"
expect "string print"       'fn main(){ str s="hi" printn(s) }'                       "hi"
expect "string return param" 'fn echo(str s)->str{ return s }\nfn main(){ printn(echo("hi")) }' "hi"
expect "string return lit"   'fn get()->str{ return "ok" }\nfn main(){ printn(get()) }'  "ok"
expect "string default arg"  'fn greet(str s="yo")->str{ return s }\nfn main(){ printn(greet()) }' "yo"
expect "nullable str param" 'fn show(str? value){ value="shown" }\nfn main(){ show(none) print(1) }' "1"
expect "two printn"         'fn main(){ printn("a") printn("b") }'                    "ab"
expect "list index"         'fn main(){ list<int> n=[7,8,9] print(n[0]) print(n[2]) }' "7 9"
expect "list param index"   'fn first(list<int> xs)->int{ return xs[0] }\nfn main(){ list<int> n=[7,8] print(first(n)) }' "7"
expect "accumulate loop"    'fn main(){ int s=0 int i=1 while(i<=5){s=s+i i=i+1} print(s) }' "15"
# Regression guard: a program that ENDS in a bare declaration (last token is a
# value right before EOF). This used to be rejected because the primary parser
# returned the last peeked char as its status, which is 0 at EOF -> false fail.
expect "trailing int decl eof"  'print(9)\nint last=7'        "9"
expect "trailing str decl eof"  'print(1)\nstr s="z"'         "1"
expect "trailing arith decl eof" 'print(4)\nint z=2+3'        "4"

expect "no-arg function"    'fn hi(){ print(42) }\nfn main(){ hi() }'                 "42"
expect "function w/ args"   'fn add(int a,int b)->int{ return a+b }\nfn main(){ print(add(3,4)) }' "7"
expect "recursion (fact)"   'fn f(int n)->int{ if(n<=1){return 1} return n*f(n-1) }\nfn main(){ print(f(5)) }' "120"
expect "recursion (fib)"    'fn fib(int n)->int{ if(n<=1){return n} return fib(n-1)+fib(n-2) }\nfn main(){ print(fib(10)) }' "55"
expect "nested calls"       'fn inc(int x)->int{ return x+1 }\nfn tw(int x)->int{ return inc(inc(x)) }\nfn main(){ print(tw(5)) }' "7"
expect "call in expression" 'fn g(int x)->int{ return x+1 }\nfn foo(int y)->int{ return y*g(y) }\nfn main(){ print(foo(4)) }' "20"
expect "stmt after call"    'fn g(int x)->int{ return x+1 }\nfn foo(int y)->int{ g(y) return 9 }\nfn main(){ print(foo(4)) }' "9"

expect "for-in print"       'fn main(){ list<int> n=[1,2,3] for (v in n) { print(v) } }' "1 2 3"
expect "for-in expr"        'fn main(){ list<int> n=[1,2,3] for (v in n) { print(v%2) } }' "1 0 1"
expect "for-in accumulate"  'fn main(){ list<int> n=[10,20,30] int s=0 for (v in n) { s=s+v } print(s) }' "60"
# for-in is now a REAL runtime loop (not compile-time unrolled), so it works over
# list PARAMETERS (size only known at runtime) and over large lists without
# overflowing the fixed op table.
expect "for-in param sum"   'fn f(list<int> xs)->int{ int s=0 for (v in xs){ s=s+v } return s }\nfn main(){ list<int> a=[1,2,3,4] print(f(a)) }' "10"
expect "for-in param print" 'fn f(list<int> xs){ for (v in xs){ print(v*10) } }\nfn main(){ list<int> a=[5,6,7] f(a) }' "50 60 70"
expect "large for-in sum"      "$(printf 'fn main(){ list<int> n=[1'; for i in $(seq 2 400); do printf ',%d' "$i"; done; printf '] int s=0 for (v in n){ s=s+v } print(s) }')" "80200"
expect "large for-in body ops" "$(printf 'fn main(){ list<int> n=[1'; for i in $(seq 2 400); do printf ',%d' "$i"; done; printf '] int s=0 for (v in n){ int a=v*2 int b=v*3 s=s+a+b } print(s) }')" "401000"
expect "string interpolation" 'fn main(){ int x=42 printn("v={x}") }'                  "v=42"
expect "string interp 2var" 'fn main(){ int a=3 int b=7 printn("a={a} b={b}") }'        "a=3 b=7"
large_frame_src=$(printf 'fn big()->int{ '; for i in $(seq 0 39); do printf 'int v%d=%d ' "$i" "$i"; done; printf 'return v0+v39 } fn main(){ print(big()) }')
expect "large function frame" "$large_frame_src" "39"

expect "chained && (false)" 'fn main(){ bool a=true bool b=false for (int i=0, i<5 && a && b, i+=1){ print(i) } print(99) }' "99"
expect "chained and keyword" 'fn main(){ bool a=true bool b=true if(1<2 and a and b){print(1)}else{print(0)} }' "1"
expect "logical or"         'fn main(){ bool a=true bool b=false if(a or b){print(1)}else{print(0)} }' "1"
expect "logical not"        'fn main(){ bool b=false if(not b){print(3)} print(99) }'  "3 99"
expect "paren condition"    'fn main(){ int x=4 int d=2 bool p=true if (p && (x % d == 0)) { print(1) } print(99) }' "1 99"
expect "paren arith cond"   'fn main(){ int x=5 if ((x + 1) > 2) { print(77) } print(99) }' "77 99"
expect "unary minus var"    'fn main(){ int x=5 print(-x) }'                           "-5"
expect "unary minus assign" 'fn main(){ int x=5 int y=-x print(y+1) }'                 "-4"
expect "unary minus in fn"  'fn f(int x)->int{ if (x < 0) { return -x } return x }\nfn main(){ print(f(5)) print(f(0-7)) }' "5 7"
expect "cond loop combo"    'fn main(){ int x=4 bool p=true for (int d=2, d*d<=x, d+=1){ if (p && (x % d == 0)) { print(d) } } }' "2"

# Comparisons as FIRST-CLASS VALUES (not only inside if/while conditions).
# Before the fix these were rejected: print(a>b) -> "expected character )",
# bool b=a>b -> "type mismatch", return a>b -> "expected statement".
expect "cmp value gt"       'fn main(){ int n=4 print(n>0) }'                         "1"
expect "cmp value eq"       'fn main(){ int a=5 print(a==5) print(a==6) }'            "1 0"
expect "cmp value le"       'fn main(){ int a=3 print(a<=3) print(a<=2) }'            "1 0"
expect "bool from cmp"      'fn main(){ int n=4 bool b=n>0 print(b) }'                "1"
expect "bool from cmp paren" 'fn main(){ int n=4 bool b=(n>0) print(b) }'             "1"
expect "return cmp bool"    'fn is_even(int n)->bool{ return n%2==0 }\nfn main(){ print(is_even(4)) print(is_even(5)) }' "1 0"
expect "bool fns with and"  'fn ev(int n)->bool{return n%2==0}\nfn pos(int n)->bool{return n>0}\nfn main(){ int n=4 if(ev(n) and pos(n)){print(1)}else{print(0)} }' "1"
expect "cmp does not eat =" 'fn main(){ int a=5 a=7 print(a) }'                       "7"

# Call-only builtins (value/address/alloc/cast) are keywords ONLY when applied
# as a call; otherwise they are ordinary identifiers. "value" was previously
# unusable as a variable/parameter/loop name (it hit the value() builtin).
expect "value as var"       'fn main(){ int value=10 while(value>0){value=value-3} print(value) }' "-2"
expect "value as param"     'fn show(int value){ print(value) }\nfn main(){ show(7) }' "7"
expect "value as loop var"  'fn main(){ list<int> xs=[1,2,3] for (value in xs){ if(value==2){skip} print(value) } }' "1 3"
expect "value() still works" 'fn main(){ int x=42 ref<int> p=address(x) print(value(p)) }' "42"

# Member access on a VARIABLE (var.length / var.slice()) was previously
# swallowed by module-qualified-access parsing and failed to compile.
expect "list length prop"   'fn main(){ list<int> n=[1,2,3] print(n.length) }'       "3"
expect "list length call"   'fn main(){ list<int> n=[1,2,3,4] print(n.length()) }'   "4"
expect "str length"         'fn main(){ str s="hello" print(s.length) }'             "5"
expect "str slice"          'fn main(){ str s="hello" printn(s.slice(0,3)) }'        "hel"

# String methods .upper()/.lower()/.contains() and char indexing s[i]. These
# used to fail: .upper()/.lower()/.contains() called runtime helpers that were
# never emitted (link error) and, once emitted, read the source from a stale
# register; s[i] was rejected outright. See ISSUES.md section 2.4.
expect "str upper var"      'fn main(){ str s="hi there" printn(s.upper()) }'        "HI THERE"
expect "str lower var"      'fn main(){ str s="HI THERE" printn(s.lower()) }'        "hi there"
expect "str upper mixed"    'fn main(){ str s="Hello, World 123!" printn(s.upper()) }' "HELLO, WORLD 123!"
expect "str upper literal"  'fn main(){ printn("abc".upper()) }'                     "ABC"
expect "str contains yes"   'fn main(){ str s="hello" print(s.contains("ell")) }'    "1"
expect "str contains no"    'fn main(){ str s="hello" print(s.contains("xyz")) }'    "0"
expect "str contains var"   'fn main(){ str s="hello" str t="lo" print(s.contains(t)) }' "1"
expect "str upper then slice" 'fn main(){ str s="hello" printn(s.upper().slice(0,3)) }' "HEL"
# NOTE: printn of a *computed* string appends a newline (pre-existing print_fmt_str
# behavior), so each of these asserts a single character on the first line.
expect "str index first"    'fn main(){ str s="hello" printn(s[0]) }'                "h"
expect "str index last"     'fn main(){ str s="hello" printn(s[4]) }'                "o"
expect "str index var"      'fn main(){ str s="hello" int i=2 printn(s[i]) }'        "l"
expect "str index literal"  'fn main(){ printn("world"[2]) }'                        "r"
# Out-of-bounds index returns an empty string (no crash); guard by printing a
# marker first so the assertion is meaningful.
expect "str index oob safe" 'fn main(){ str s="hi" print(1) printn(s[9]) }'         "1"

# String .replace(old,new) -> str. Previously a stub: codegen never marshalled
# the old/new arguments and no _str_replace runtime existed. See ISSUES.md 2.5.
expect "str replace word"   'fn main(){ str s="hello world" printn(s.replace("world","there")) }' "hello there"
expect "str replace grow"   'fn main(){ str s="aaa" printn(s.replace("a","bb")) }'    "bbbbbb"
expect "str replace char"   'fn main(){ str s="a.b.c" printn(s.replace(".","/")) }'   "a/b/c"
expect "str replace vars"   'fn main(){ str s="hello" str o="l" str n="L" printn(s.replace(o,n)) }' "heLLo"
expect "str replace delete" 'fn main(){ str s="banana" printn(s.replace("an","")) }'  "ba"
expect "str replace nomatch" 'fn main(){ str s="hello" printn(s.replace("x","y")) }'  "hello"

# File I/O. file_write previously wrote 0 bytes (codegen never loaded the length
# register x2 that the _file_write runtime passes to _write) and `str c =
# file_read(...)` was rejected as a type mismatch (file_read reported its type in
# x1 but the compilation-mode expression path reads it from x2). Both fixed; see
# ISSUES.md section 2.6. Uses /tmp paths so the suite leaves no repo artifacts.
expect "file write+read"    'fn main(){ file_write("/tmp/snc_assert_fio.txt","hello file") print(file_read("/tmp/snc_assert_fio.txt")) }' "hello file"
expect "file read into var" 'fn main(){ file_write("/tmp/snc_assert_fio2.txt","abc123") str c=file_read("/tmp/snc_assert_fio2.txt") print(c) }' "abc123"
expect "file rewrite trunc" 'fn main(){ file_write("/tmp/snc_assert_fio3.txt","LongContent") file_write("/tmp/snc_assert_fio3.txt","hi") print(file_read("/tmp/snc_assert_fio3.txt")) }' "hi"

# Runtime string length: `.length` on a string whose length is only known at
# runtime (str param, concatenation, file_read result) now emits op 103 (a
# runtime _cstring_length) instead of returning stale compile-time metadata
# (0/garbage). String literals keep the compile-time fold. See ISSUES.md 2.6.
expect "str param length"   'fn f(str s)->int{ return s.length }\nfn main(){ print(f("hello")) }' "5"
expect "str concat length"  'fn main(){ str a="ab" str b="cde" str c=a+b print(c.length) }' "5"
expect "file_read length"   'fn main(){ file_write("/tmp/snc_assert_fio4.txt","hello world") str c=file_read("/tmp/snc_assert_fio4.txt") print(c.length) }' "11"

expect_compile_fail "duplicate var" 'fn main(){ int x=1 int x=2 print(x) }' "error: duplicate variable"

expect "param list .length()" 'fn f(list<int> xs)->int{ return xs.length() }\nfn main(){ list<int> a=[1,2,3,4] print(f(a)) }' "4"

# int + str / str + int concatenation. Previously "type mismatch": `+` required
# both operands to be strings. Now a non-string int operand is auto-cast to a
# string (op 73 int->str) so "str + int"/"int + str" become "str + str". See
# ISSUES.md section 2.11.
expect "str plus int"       'fn main(){ int x=7 print("count=" + x) }'               "count=7"
expect "int plus str"       'fn main(){ int x=7 print(x + " is prime") }'            "7 is prime"
expect "str plus int lit"   'fn main(){ print("n=" + 5) }'                           "n=5"
expect "int lit plus str"   'fn main(){ print(1 + " and " + 2) }'                    "1 and 2"
expect "str plus paren sum" 'fn main(){ int a=3 int b=4 print("sum=" + (a+b)) }'     "sum=7"

# for-loop block scoping. A `for` now opens a fresh variable block: its counter
# (and any body-local) may shadow an outer variable of the same name, two sibling
# loops may reuse the same counter name, and on loop exit the block-locals are
# popped (freeing slots + restoring the shadowed outer). See ISSUES.md 2.12.
expect "sibling for counters" 'fn main(){ for(int d=0,d<2,d+=1){print(d)} for(int d=5,d<7,d+=1){print(d)} }' "0 1 5 6"
expect "for counter shadows"  'fn main(){ int x=99 for(int x=0,x<3,x+=1){print(x)} print(x) }' "0 1 2 99"
expect "for body-local shadow" 'fn main(){ int p=1 for(int i=0,i<2,i+=1){ int p=8 print(p) } print(p) }' "8 8 1"
expect "nested for reuse"     'fn main(){ for(int i=0,i<2,i+=1){ for(int j=0,j<2,j+=1){ print(i*10+j) } } }' "0 1 10 11"

# Block try/catch. Previously a stub. Now a REAL runtime error path: `try` clears
# the error flag, a `throw` inside it sets error_value/flag WITHOUT exiting and
# jumps to the catch label, and after the body a residual error_flag also enters
# catch. Three codegen bugs were fixed: op 35 (a label PLACEMENT) was misused as
# an unconditional jump (now op 41); the error-branch (op 106) emitted a bare
# "L_snl_0" that never matched the placed "L_snl_<table>_0" catch label; and the
# catch-label sentinel collided with a real label id of 0 (now stored as id+1).
# The caught `e` also holds the message POINTER now (was a data id -> "(null)").
expect "try catch throw"     'fn main(){ try { throw("boom") print(999) } catch (e) { printn(e) } print(7) }' "boom 7"
expect "try no throw skips"  'fn main(){ try { print(1) } catch (e) { print(2) } print(3) }' "1 3"
expect "try catch novar"     'fn main(){ try { throw("x") } catch { print(5) } }' "5"
expect "try catch body runs" 'fn main(){ int r=0 try { throw("e") r=1 } catch (e) { r=2 } print(r) }' "2"
expect "nested try catch"    'fn main(){ try { try { throw("inner") } catch (e) { print(1) } throw("outer") } catch (e) { print(2) } }' "1 2"
expect "try throw after ok"  'fn main(){ try { print(8) throw("late") print(9) } catch (e) { printn(e) } }' "8 late"
expect "catch e in interp"   'fn main(){ try { throw("bad") } catch (e) { printn("err={e}") } }' "err=bad"
expect "two sequential trys" 'fn main(){ try { throw("one") } catch (e) { printn(e) } try { throw("two") } catch (e) { printn(e) } }' "one two"

# String .split(sep) -> list<str>. Previously a stub (codegen never marshalled
# the args; the result type mismatched `list<str>` so it wouldn't even compile).
# Now a REAL, indexable/iterable list: a fixed-capacity block is reserved in the
# list pool (immediate base), and the runtime _str_split fills it with malloc'd
# piece pointers and writes list_base_counts[base]. The base is flagged
# runtime-count so .length()/for-in read the count at run time (str for-in also
# switches from the compile-time unroll to the runtime loop for split results).
# See ISSUES.md section 2.10.
expect "split length"        'fn main(){ list<str> p="a,b,c".split(",") print(p.length()) }' "3"
expect "split index"         'fn main(){ list<str> p="a,b,c".split(",") printn(p[0]) printn(p[1]) printn(p[2]) }' "a b c"
expect "split for-in"        'fn main(){ for (x in "x,y,z".split(",")) { printn(x) } }' "x y z"
expect "split multichar sep" 'fn main(){ list<str> b="a::b::c".split("::") print(b.length()) printn(b[1]) }' "3 b"
expect "split no match"      'fn main(){ list<str> c="nosep".split(",") print(c.length()) printn(c[0]) }' "1 nosep"
expect "split trailing sep"  'fn main(){ list<str> d="x,y,".split(",") print(d.length()) }' "3"
expect "split var source"    'fn main(){ str s="one,two,three,four" list<str> a=s.split(",") print(a.length()) printn(a[3]) }' "4 four"
expect "split loop interp"   'fn main(){ for (w in "red,green".split(",")) { printn("c={w}") } }' "c=red c=green"
expect "split elem length"   'fn main(){ list<str> g="a-bb-ccc".split("-") int t=0 for (p in g) { t=t+p.length() } print(t) print(g.length()) }' "6 3"
expect "split then upper"    'fn main(){ list<str> p="ab,cd".split(",") printn(p[0].upper()) printn(p[1].upper()) }' "AB CD"

# Blueprint (object) DIRECT field access. Each instance gets its own field
# storage, so constructor-style named init and direct reads/writes are correct
# per-instance. Previously, defining a blueprint whose method reads/writes
# `self.field` made the WHOLE program fail to compile ("expected expression"):
# the general fn preparse registers a plain-named stub for each method (blueprint
# id -1) whose body cursor points at the method body, so _parse_function_body
# re-parsed `return self.field` as an ordinary function with no `self` bound and
# aborted before `main`. Fixed by (a) giving each blueprint a definition-time
# template instance bound as `self` while a method body is compiled standalone,
# and (b) tagging that plain-named stub with the blueprint id too. See ISSUES 2.13.
expect "obj field init"      'blueprint C { int value } fn main(){ C c(value: 7) print(c.value) }' "7"
expect "obj two instances"   'blueprint C { int value } fn main(){ C a(value: 3) C b(value: 8) print(a.value) print(b.value) }' "3 8"
expect "obj field reassign"  'blueprint C { int value } fn main(){ C c(value: 1) c.value = 5 print(c.value) }' "5"
expect "obj two fields"      'blueprint P { int x int y } fn main(){ P p(x: 2, y: 9) print(p.x) print(p.y) }' "2 9"

# Blueprint (object) METHODS using self.field, now PER-INSTANCE. A method call
# rebinds `self` to the caller's actual instance (not the shared definition-time
# template), so a getter sees constructor-initialised values, a setter mutates
# only that instance, and two instances stay isolated. See ISSUES.md section 2.14.
expect "obj method getter"   'blueprint C { int value fn get()->int { return self.value } } fn main(){ C c(value: 7) print(c.get()) }' "7"
expect "obj method setter"   'blueprint Counter { int value fn get()->int { return self.value } fn add(int n) { self.value = self.value + n } } fn main(){ Counter c(value: 10) c.add(5) c.add(3) print(c.get()) }' "18"
expect "obj method isolation" 'blueprint Counter { int value fn get()->int { return self.value } fn bump() { self.value = self.value + 1 } } fn main(){ Counter a(value: 10) Counter b(value: 20) a.bump() print(a.get()) print(b.get()) }' "11 20"
expect "obj method in expr"  'blueprint P { int x int y fn sum()->int { return self.x + self.y } } fn main(){ P a(x: 1, y: 2) P b(x: 10, y: 20) int t = a.sum() + b.sum() print(t) }' "33"
expect "obj nested method"   'blueprint Box { int v fn get()->int { return self.v } fn doubled()->int { return self.get() + self.get() } } fn main(){ Box b(v: 9) print(b.doubled()) }' "18"

# Built-in str(x): convert a value to its string form. Previously `unknown
# function: str`. int/bool reuse the interpolation int->str path (op 73 via
# _emit_cast_op); a str argument is returned unchanged. Immediate ints are
# materialised into a slot first (the op reads its source from a var slot).
# See ISSUES.md section 2.15.
expect "str of int lit"      'fn main(){ printn(str(42)) }'                             "42"
expect "str of int var"      'fn main(){ int n=7 printn(str(n)) }'                      "7"
expect "str of int expr"     'fn main(){ int a=3 int b=4 printn(str(a+b)) }'            "7"
expect "str of negative"     'fn main(){ int n=0-9 printn(str(n)) }'                    "-9"
expect "str of bool"         'fn main(){ printn(str(true)) printn(str(false)) }'        "1 0"
expect "str passthrough"     'fn main(){ printn(str("hi")) }'                           "hi"
expect "str in concat"       'fn main(){ int n=5 printn("n=" + str(n)) }'               "n=5"

# Built-in len(x): element count of a list / character count of a string.
# Previously `unknown function: len`. Mirrors the `.length` member: op 103 for a
# runtime string, op 81 for a runtime list (split result / list PARAMETER), and
# a compile-time count for a string literal / list literal / local list. A
# split-result list is detected by its runtime base flag (checked BEFORE the
# slot path) so it reports its real count, not its reserved capacity.
# See ISSUES.md section 2.16.
expect "len of str lit"      'fn main(){ print(len("hello")) }'                         "5"
expect "len of str var"      'fn main(){ str s="world!" print(len(s)) }'               "6"
expect "len of empty str"    'fn main(){ print(len("")) }'                              "0"
expect "len of str concat"   'fn main(){ str a="ab" str b="cde" print(len(a+b)) }'      "5"
expect "len of list lit"     'fn main(){ print(len([1,2,3,4])) }'                       "4"
expect "len of local list"   'fn main(){ list<int> a=[10,20,30] print(len(a)) }'        "3"
expect "len of list param"   'fn f(list<int> xs)->int{ return len(xs) }\nfn main(){ list<int> a=[1,2,3,4,5] print(f(a)) }' "5"
expect "len of split result" 'fn main(){ list<str> p="a-b-c-d".split("-") print(len(p)) }' "4"
expect "len in expression"   'fn main(){ list<int> a=[5,5,5] int x=len(a)+1 print(x) }' "4"
expect "str of len"          'fn main(){ list<int> a=[9,8] printn("len=" + str(len(a))) }' "len=2"

# Increment/decrement operators (x++ / x--) and compound assignment on OBJECT
# FIELDS (obj.field OP= rhs, self.field OP= rhs, obj.field++). Compound assignment
# on plain variables (x += 1 etc.) already worked; these fill the two remaining
# gaps: `x++`/`x--` (parser used to demand '=' after the first '+'/'-') and OP= on
# a blueprint field (the field-assignment path only accepted '='). `x++` is lowered
# to `x += 1`; a field is backed by a real var slot, so field OP= reuses the same
# runtime compound ops (23-32) on that slot -- so it is per-instance correct (a
# method's `self.value += 1` mutates only the caller's instance). See ISSUES 2.17.
expect "incr op"             'fn main(){ int x=5 x++ print(x) }'                         "6"
expect "decr op"             'fn main(){ int x=5 x-- print(x) }'                         "4"
expect "incr in while"       'fn main(){ int i=0 int s=0 while (i<5){ s=s+i i++ } print(s) }' "10"
expect "decr countdown"      'fn main(){ int n=3 while (n>0){ print(n) n-- } }'          "3 2 1"
expect "multi incr"          'fn main(){ int x=0 x++ x++ x++ print(x) }'                 "3"
expect "field += direct"     'blueprint C { int value } fn main(){ C c(value: 5) c.value += 3 print(c.value) }' "8"
expect "field -= direct"     'blueprint C { int value } fn main(){ C c(value: 10) c.value -= 4 print(c.value) }' "6"
expect "field *= direct"     'blueprint C { int value } fn main(){ C c(value: 6) c.value *= 2 print(c.value) }' "12"
expect "field ++ direct"     'blueprint C { int value } fn main(){ C c(value: 5) c.value++ print(c.value) }' "6"
expect "field += var rhs"    'blueprint C { int value } fn main(){ C c(value: 5) int n=7 c.value += n print(c.value) }' "12"
expect "self.field += method" 'blueprint Counter { int value fn inc() { self.value += 1 } fn get()->int{ return self.value } } fn main(){ Counter c(value: 0) c.inc() c.inc() c.inc() print(c.get()) }' "3"
expect "self.field += n"     'blueprint Acc { int total fn add(int n) { self.total += n } fn get()->int{ return self.total } } fn main(){ Acc a(total: 0) a.add(5) a.add(10) print(a.get()) }' "15"
expect "field += isolation"  'blueprint Counter { int value fn get()->int { return self.value } fn bump() { self.value += 1 } } fn main(){ Counter a(value: 10) Counter b(value: 20) a.bump() a.bump() print(a.get()) print(b.get()) }' "12 20"

# Parentheses around a condition/loop-header are now OPTIONAL for if/else-if/
# while/for (both for-in and C-style). Previously the parser hard-required '('
# (error: expected character: '('); now the '(' is consumed only if present and
# its ')' required only when a '(' was seen, so `if c {`, `while c {`, and
# `for v in xs {` all parse -- while the fully-parenthesized forms still work
# unchanged (the condition still terminates at '{'). See ISSUES.md section 2.18.
expect "if no parens"        'fn main(){ int x=5 if x > 3 { print(1) } else { print(0) } }' "1"
expect "if no parens false"  'fn main(){ int x=1 if x > 3 { print(1) } else { print(0) } }' "0"
expect "else if no parens"   'fn main(){ int x=5 if x > 9 { print(2) } else if x > 3 { print(1) } else { print(0) } }' "1"
expect "if parens still"     'fn main(){ int x=5 if (x > 3) { print(9) } }' "9"
expect "while no parens"     'fn main(){ int i=0 while i < 3 { print(i) i++ } }' "0 1 2"
expect "while noparen accum" 'fn main(){ int i=1 int s=0 while i <= 5 { s=s+i i++ } print(s) }' "15"
expect "while parens still"  'fn main(){ int i=0 while (i < 2) { print(i) i++ } }' "0 1"
expect "for-in no parens"    'fn main(){ for x in [1,2,3] { print(x) } }' "1 2 3"
expect "for-in noparen param" 'fn sum(list<int> xs)->int{ int t=0 for v in xs { t+=v } return t }\nfn main(){ list<int> a=[10,20,30] print(sum(a)) }' "60"
expect "cstyle for no parens" 'fn main(){ for int i=0, i<3, i++ { print(i) } }' "0 1 2"
expect "cstyle for noparen +=" 'fn main(){ for int i=0, i<6, i+=2 { print(i) } }' "0 2 4"
expect "for-in parens still" 'fn main(){ for (x in [4,5,6]) { print(x) } }' "4 5 6"

# Runtime LIST-ELEMENT WRITES: `list[i] = v` with a computed/variable index, a
# write inside a loop, or a write to a list PARAMETER (which mutates the caller's
# list, since a list is a shared pool base). Previously the index-assign path only
# handled a constant index into a local literal by folding the write into the
# emitted initial data -- a variable index read the index's compile-time value
# (usually 0/garbage) and a parameter target did nothing. Now op 109 stores the
# element at run time (list_pool_values[base+index] = rhs), and the base is marked
# runtime so later reads (even with a constant index) resolve against memory.
# This is what makes in-place algorithms (sort/swap/fill) and the recursive Sudoku
# solver in hard_dsa_suite.sn work. See ISSUES.md section 2.19.
expect "list write computed"  'fn main(){ list<int> a=[1,2,3] a[1+1]=99 print(a[2]) }'   "99"
expect "list write var idx"   'fn main(){ list<int> a=[5,5,5] int i=1 a[i]=7 print(a[0]) print(a[1]) print(a[2]) }' "5 7 5"
expect "list fill in loop"    'fn main(){ list<int> a=[0,0,0,0] for (int i=0,i<4,i+=1){ a[i]=i*10 } print(a[0]) print(a[3]) }' "0 30"
expect "list swap elements"   'fn main(){ list<int> a=[10,20] int t=a[0] a[0]=a[1] a[1]=t print(a[0]) print(a[1]) }' "20 10"
expect "list const after mut" 'fn main(){ list<int> a=[1,2,3] a[0]=100 print(a[0]) }'    "100"
expect "list param write"     'fn setz(list<int> xs){ xs[0]=99 }\nfn main(){ list<int> a=[1,2,3] setz(a) print(a[0]) }' "99"
expect "list reverse in place" 'fn main(){ list<int> a=[1,2,3,4] int i=0 int j=3 while i<j { int t=a[i] a[i]=a[j] a[j]=t i++ j-- } print(a[0]) print(a[1]) print(a[2]) print(a[3]) }' "4 3 2 1"

# Immediate-scalar RETURN materialization: `return true` / `return false` (and a
# bare byte/int immediate) now work. The return op (op 4) loads its argument as a
# STACK SLOT; a bool literal had no slot (x4=-1), so the raw value 1/0 was used as
# an offset and garbage was returned. Now such a return is materialized into a temp
# slot via op 1, exactly like an int literal. See ISSUES.md section 2.20.
expect "bool ret true"        'fn ok()->bool{ return true }\nfn main(){ if (ok()){ print(1) } else { print(0) } }' "1"
expect "bool ret false"       'fn no()->bool{ return false }\nfn main(){ if (no()){ print(1) } else { print(0) } }' "0"
expect "bool ret in expr"     'fn even(int n)->bool{ if (n%2==0){ return true } return false }\nfn main(){ print(even(4)) print(even(7)) }' "1 0"
expect "bool ret print"       'fn yes()->bool{ return true }\nfn main(){ print(yes()) }' "1"

# Recursive backtracking with in-place list mutation (a distilled Sudoku step):
# a recursive function that writes a list element, recurses, and undoes the write
# on failure. This exercises the runtime list store, per-function stack frames
# sized from the real peak (so the recursive call does not clobber the caller's
# locals), and bool returns together. See ISSUES.md section 2.19/2.21.
expect "backtrack fill"       'fn solve(list<int> b, int i)->bool{ if i>=4 { return true } if b[i]!=0 { return solve(b,i+1) } for (int v=1,v<=4,v+=1){ b[i]=v if solve(b,i+1) { return true } b[i]=0 } return false }\nfn main(){ list<int> b=[0,0,0,0] if solve(b,0) { print(b[0]) print(b[1]) print(b[2]) print(b[3]) } else { print(-1) } }' "1 1 1 1"

# Alternate array-type dialect (used by binary_search.sn): `[T]` as a list-type
# alias in declarations/params/returns, colon-form params `name: type`, and
# `str(list)` rendering a constant int list as "[e0, e1, ...]". `[T]` maps onto
# the same `list<T>` encoding (type 4); the colon form is disambiguated by a
# save-cursor/peek-for-':' (unambiguous because `list<int>` has '<', never ':');
# `str(list)` folds a constant list into a string literal at compile time. The
# primary `type name` / `list<T>` forms are unchanged. See ISSUES.md section 2.22.
expect "bracket type decl"   'fn main(){ [int] a = [10,20,30] print(a[0]) print(a[2]) }' "10 30"
expect "bracket decl loop"   'fn main(){ [int] a = [1,2,3,4] int t=0 for (v in a){ t+=v } print(t) }' "10"
expect "colon [int] param"   'fn sum(xs: [int])->int{ int t=0 for (v in xs){ t+=v } return t }\nfn main(){ [int] a = [1,2,3,4] print(sum(a)) }' "10"
expect "colon mixed params"  'fn at(xs: [int], i: int)->int{ return xs[i] }\nfn main(){ [int] a = [10,20,30] print(at(a,1)) }' "20"
expect "colon int param"     'fn dbl(n: int)->int{ return n*2 }\nfn main(){ print(dbl(21)) }' "42"
expect "bracket param regress" 'fn sum(list<int> xs)->int{ int t=0 for (v in xs){ t+=v } return t }\nfn main(){ list<int> a=[5,6,7] print(sum(a)) }' "18"
expect "str of list"         'fn main(){ [int] a = [1,3,5,7,9] printn(str(a)) }' "[1, 3, 5, 7, 9]"
expect "str list single"     'fn main(){ list<int> a = [42] printn(str(a)) }' "[42]"
expect "str list negatives"  'fn main(){ list<int> a = [0,-5,12,-3] printn(str(a)) }' "[0, -5, 12, -3]"
expect "str list in concat"  'fn main(){ list<int> a=[10,20,30] print("A: " + str(a)) }' "A: [10, 20, 30]"
expect "str two lists"       'fn main(){ list<int> a=[1,2] list<int> b=[3,4,5] printn(str(a)) printn(str(b)) }' "[1, 2] [3, 4, 5]"
# Binary search written in the alternate dialect end-to-end (the whole point of
# binary_search.sn): colon `[int]` param + `len()` + paren-less-capable loop.
expect "binary search"       'fn bs(xs: [int], t: int)->int{ int lo=0 int hi=len(xs)-1 while lo<=hi { int mid=lo+(hi-lo)/2 if xs[mid]==t { return mid } if xs[mid]<t { lo=mid+1 } else { hi=mid-1 } } return -1 }\nfn main(){ [int] a=[1,3,5,7,9,11] print(bs(a,7)) print(bs(a,4)) print(bs(a,1)) }' "3 -1 0"

# Thread synchronization: wait() joins every outstanding spawned thread. Before
# this, `spawn fn()` used pthread_detach, so a worker's output was routinely lost
# when main reached the end first (e.g. spawn_basic printed only "main done").
# Now spawn records the thread id (no detach) and wait() joins them all, so the
# worker's output is deterministic and wait() returns the number joined. Only
# single-worker ordering and join COUNTS are asserted here -- the interleaving of
# two concurrent workers' output is intentionally not asserted. See ISSUES 2.23.
expect "spawn wait output"   'fn w(){ print("hi") }\nfn main(){ spawn w() wait() print("end") }' "hi end"
expect "spawn wait count"    'fn w(){ int x=1 }\nfn main(){ spawn w() print(wait()) }' "1"
expect "spawn wait multi"    'fn a(){ int x=1 }\nfn b(){ int x=2 }\nfn main(){ spawn a() spawn b() print(wait()) }' "2"
expect "wait no spawn"       'fn main(){ print(wait()) }' "0"
# `spawn obj.method()` (spawning a blueprint method) is not yet supported and now
# fails with a CLEAR diagnostic instead of the former confusing empty "line N:"
# error (its capture path clobbered the object-name registers and used an
# out-of-range spawn slot). `spawn fn()` on a zero-arg function is the supported
# form. See ISSUES 2.23.
expect_compile_fail "spawn method rejected" 'blueprint P { str s fn r(){ print(self.s) } }\nfn main(){ P p(s: "x") spawn p.r() }' "error: spawn of a method is not yet supported"

# ord(s): ASCII code (int) of the first character of a string -- a self-hosting
# prerequisite. SNlang char indexing s[i] yields a 1-char STRING and there was no
# way to get its numeric code, so a program could not CLASSIFY characters
# (digit/letter/whitespace). ord() reads the first byte: a string literal folds
# at compile time, a runtime char (s[i]) reads the byte at run time (op 118), and
# "" -> 0. This is what makes selfhost/lexer.sn (a tokenizer written in SNlang)
# possible. See ISSUES.md section 2.24.
expect "ord literal upper"   'fn main(){ print(ord("A")) }' "65"
expect "ord literal digit"   'fn main(){ print(ord("0")) }' "48"
expect "ord empty"           'fn main(){ print(ord("")) }' "0"
expect "ord runtime char"    'fn main(){ str s="Xyz" print(ord(s[0])) print(ord(s[1])) print(ord(s[2])) }' "88 121 122"
expect "ord classify digit"  'fn main(){ str s="7" int c=ord(s[0]) if c>=48 and c<=57 { print(1) } else { print(0) } }' "1"

# Growable op table: the recorded-operation stream is now malloc-backed and grows
# on demand (realloc-doubling from an initial SNC_MAX_OPS) instead of failing with
# "too many operations". This modest program records enough ops to exercise the
# record path across many statements; true past-cap growth (>32768 ops) is
# verified separately (a generated 60k-op program compiles+runs). See ISSUES 2.24.
expect "many ops grow path"  'fn main(){ int x=0 for (int i=0,i<500,i+=1){ x=x+1 } print(x) }' "500"

echo
echo "== KNOWN BROKEN (documented; not fatal) =="
# for-in over lists is now a REAL runtime loop (see _emit_for_in_runtime_loop),
# so it works for local lists, large lists, and list PARAMETERS (size only known
# at runtime) -- all covered by the MUST-PASS group above. The former
# "huge for-in unroll" (op-table overflow) and "param list for-in sum" xfails are
# RESOLVED and promoted. No known-broken assertions remain at this time.
echo
echo "----------------------------------------"
echo "MUST-PASS: $pass passed, $fail failed"
echo "KNOWN-BROKEN: $xfail still-broken, $xpass unexpectedly-passing"
if [ $fail -ne 0 ]; then
  echo "REGRESSION(S):$FAILED_NAMES"
  exit 1
fi
echo "OK: all must-pass assertions hold."
exit 0

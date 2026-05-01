#!/bin/bash
PASS=0
FAIL=0

run_test() {
    name="$1"
    expected="$2"
    shift 2
    if ! ./snc "$@" > /tmp/out.s 2>&1; then
        echo "FAIL: $name"
        echo "  Compile failed:"
        sed 's/^/    /' /tmp/out.s
        ((FAIL++))
        return 0
    fi
    if ! cc -o /tmp/out /tmp/out.s 2>&1; then
        echo "FAIL: $name"
        echo "  Link failed"
        ((FAIL++))
        return 0
    fi
    result=$(/tmp/out 2>&1)
    if [ "$result" = "$expected" ]; then
        echo "PASS: $name"
        ((PASS++))
    else
        echo "FAIL: $name"
        echo "  Expected: '$expected'"
        echo "  Got: '$result'"
        ((FAIL++))
    fi
}

echo "=== Literal String Concatenation ==="
echo 'fn main() { str s = "AB" + "CD"; print(s) }' > /tmp/t1.sn
run_test "Two literals concat" "ABCD" /tmp/t1.sn

echo 'fn main() { str s = "Hello" + " " + "World"; print(s) }' > /tmp/t2.sn
run_test "Three literals concat" "Hello World" /tmp/t2.sn

echo "=== Variable String Concatenation ==="
cat > /tmp/t3.sn << 'SN'
fn main() {
    str a = "Hello"
    str b = "World"
    str c = a + b
    print(c)
}
SN
run_test "Var + var concat" "HelloWorld" /tmp/t3.sn

echo "=== Mixed String Concatenation ==="
cat > /tmp/t4.sn << 'SN'
fn main() {
    str a = "X"
    str c = a + "Y"
    print(c)
}
SN
run_test "Var + literal concat" "XY" /tmp/t4.sn

cat > /tmp/t5.sn << 'SN'
fn main() {
    str a = "Y"
    str c = "X" + a
    print(c)
}
SN
run_test "Literal + var concat" "XY" /tmp/t5.sn

echo "=== Imported Function Calls ==="
cat > ./__runtime_import_math.sn << 'SN'
fn helper() -> int {
    return 42
}
SN

cat > /tmp/t6.sn << 'SN'
use __runtime_import_math

fn main() {
    print(helper())
}
SN
run_test "Imported function call" "42" /tmp/t6.sn
rm -f ./__runtime_import_math.sn

echo "=== Blueprint Runtime ==="
cat > /tmp/t_oop_fields.sn << 'SN'
blueprint Point {
    int x
    int y
}

Point p(x: 2, y: 3)
print(p.x)
print(p.y)
SN
run_test "Blueprint field access" $'2\n3' /tmp/t_oop_fields.sn

echo "=== Dynamic map store and decimal cast ==="
cat > /tmp/t_map_dynamic_store.sn << 'SN'
fn main() {
    map<str, int> m = {"seed": 1}
    str kbase = "new"
    str k = kbase + ""
    int v = 7
    m[k] = v
    print(m[k])
}
SN
run_test "Runtime map key/value store via vars" "7" /tmp/t_map_dynamic_store.sn

cat > /tmp/t_cast_dec_runtime.sn << 'SN'
fn main() {
    dec(2) d = 10.50
    dec(2) e = d + 1.25
    print("e=" + cast(e, str))
}
SN
run_test "Runtime decimal cast in concat" "e=11.75" /tmp/t_cast_dec_runtime.sn

cat > /tmp/t_nested_fn_multi_call.sn << 'SN'
fn caller(int n) -> int {
    fn inc(int x) -> int {
        if (x > 0) {
            return x + 1
        }
        return 1
    }
    return inc(n)
}

fn main() {
    print(caller(1))
    print(caller(2))
}
SN
run_test "Nested fn multiple calls with if-return" $'2\n3' /tmp/t_nested_fn_multi_call.sn

echo ""
echo "Summary: PASS=$PASS FAIL=$FAIL"

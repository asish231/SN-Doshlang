#!/bin/bash
PASS=0
FAIL=0

run_test() {
    name="$1"
    expected="$2"
    shift 2
    ./snc "$@" > /tmp/out.s 2>&1 || return 1
    cc -o /tmp/out /tmp/out.s 2>&1 || return 1
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

cat > /tmp/t_oop_method.sn << 'SN'
blueprint Point {
    int x
    int y

    fn sum() -> int {
        return self.x + self.y
    }
}

Point p(x: 2, y: 3)
print(p.sum())
SN
run_test "Blueprint method with self" "5" /tmp/t_oop_method.sn

cat > /tmp/t_oop_void_method.sn << 'SN'
blueprint Greeter {
    fn ping() {
        print("hi")
    }
}

Greeter g()
g.ping()
print("ok")
SN
run_test "Blueprint void method call" $'hi\nok' /tmp/t_oop_void_method.sn

echo ""
echo "Summary: PASS=$PASS FAIL=$FAIL"

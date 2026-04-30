#!/bin/bash
PASS=0
FAIL=0

run_test() {
    name="$1"
    expected="$2"
    shift 2
    result=$(./snc "$@" 2>&1)
    if echo "$result" | grep -q "$expected"; then
        echo "PASS: $name"
        ((PASS++))
    else
        echo "FAIL: $name"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ((FAIL++))
    fi
}

echo "=== String Literal Concatenation Tests ==="
echo 'fn main() { str s = "A" + "B"; print(s) }' > /tmp/t1.sn
run_test "String concat compile" "print_val_" /tmp/t1.sn

echo "=== String Var Concat Tests ==="
cat > /tmp/t2.sn << 'SN'
fn main() {
    str a = "X"
    str b = "Y"
    str c = a + b
    print(c)
}
SN
run_test "String var concat" "str_concat" /tmp/t2.sn

echo "=== Module Import Regression Tests ==="
cat > ./__module_test_math.sn << 'SN'
fn helper() -> int {
    return 42
}
SN

cat > /tmp/t_module_missing.sn << 'SN'
use does_not_exist

fn main() {
    print("ok")
}
SN
run_test "Missing module import compiles without crashing" "print_val_" /tmp/t_module_missing.sn

cat > /tmp/t_module_duplicate.sn << 'SN'
use __module_test_math
use __module_test_math

fn main() {
    print("ok")
}
SN
run_test "Duplicate module import compiles without crashing" "print_val_" /tmp/t_module_duplicate.sn

rm -f ./__module_test_math.sn

echo "=== OOP Syntax Parsing ==="
cat > /tmp/t_blueprint_decl.sn << 'SN'
blueprint Point {
    open int x
    closed int y = 2

    fn reset() {
        print("noop")
    }
}

contract Drawable {
    fn draw()
}

fn main() {
    new Point p(x: 10, y: 20)
    Point q(x: 1, y: 2)
    print("ok")
}
SN
run_test "Blueprint, contract, and object declarations parse" "print_val_" /tmp/t_blueprint_decl.sn

echo ""
echo "PASS: $PASS  FAIL: $FAIL"

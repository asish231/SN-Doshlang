#!/usr/bin/env bash

# Module system one-shot test suite
# All test .sn files live in tests/modules/
# Run from repo root: ./test_modules.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SNC="$REPO_ROOT/snc"
TESTS_DIR="tests/modules"
BUILD_DIR=".build/mod_tests"
OS=$(uname -s)
COMPILER=$(which clang 2>/dev/null || which gcc)
SDK_PATH=""
[ "$OS" = "Darwin" ] && SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null)

PASS=0
FAIL=0
SKIP=0

mkdir -p "$BUILD_DIR"

skip_test() {
    local name="$1"
    local reason="$2"
    echo -e "  ${YELLOW}SKIP${NC}  $name  ($reason)"
    ((SKIP++))
}

# --- compile and run, compare output ---
run_test() {
    local name="$1"       # test name
    local file="$2"       # main .sn file (relative to TESTS_DIR)
    local expected="$3"   # expected stdout (newline-separated)

    local src="$TESTS_DIR/$file"
    local asm="$BUILD_DIR/${name}.s"
    local bin="$BUILD_DIR/${name}"

    if [ ! -f "$src" ]; then
        echo -e "  ${YELLOW}SKIP${NC}  $name  (missing $src)"
        ((SKIP++)); return
    fi

    # compile — run snc from TESTS_DIR so relative module paths resolve
    local compile_out
    # Run from the test's own directory so relative `use` paths resolve correctly.
    # stdlib/ is a symlink in tests/modules/ so std.math etc resolve from any subdir.
    compile_out=$(cd "$REPO_ROOT/$TESTS_DIR/$(dirname "$file")" && "$REPO_ROOT/snc" "$(basename "$file")" 2>&1)
    local compile_status=$?

    # if expected is "COMPILE_ERROR" we just check it failed
    if [ "$expected" = "COMPILE_ERROR" ]; then
        if [ $compile_status -ne 0 ]; then
            echo -e "  ${GREEN}PASS${NC}  $name  (correctly rejected)"
            ((PASS++))
        else
            echo -e "  ${RED}FAIL${NC}  $name  (should have failed to compile)"
            ((FAIL++))
        fi
        return
    fi

    if [ $compile_status -ne 0 ]; then
        echo -e "  ${RED}FAIL${NC}  $name  (compile error)"
        echo "$compile_out" | sed 's/^/        /'
        ((FAIL++)); return
    fi

    echo "$compile_out" > "$asm"

    # link
    if [ "$OS" = "Darwin" ]; then
        $COMPILER -isysroot "$SDK_PATH" "$asm" -o "$bin" 2>/dev/null
    else
        $COMPILER "$asm" -o "$bin" 2>/dev/null
    fi

    if [ $? -ne 0 ]; then
        echo -e "  ${RED}FAIL${NC}  $name  (link error)"
        ((FAIL++)); return
    fi

    local actual
    actual=$("$bin" 2>&1)

    if [ "$actual" = "$expected" ]; then
        echo -e "  ${GREEN}PASS${NC}  $name"
        ((PASS++))
    else
        echo -e "  ${RED}FAIL${NC}  $name"
        echo -e "        expected: $(echo "$expected" | head -5)"
        echo -e "        actual:   $(echo "$actual"   | head -5)"
        ((FAIL++))
    fi
}

# -------------------------------------------------------
echo -e "${BOLD}${CYAN}Module System Tests${NC}"
echo -e "${CYAN}-------------------${NC}"

# 1. No use — baseline, no modules at all
run_test "no_use" \
    "no_use/main.sn" \
    "no use"

# 2. Single use — import one local file, call its function
run_test "single_use" \
    "single_use/main.sn" \
    "from main
from lib"

# 3. stdlib use — use std.math, call abs()
run_test "stdlib_math" \
    "stdlib_math/main.sn" \
    "5"

# 4. stdlib multi-use — use std.math + std.io
run_test "stdlib_multi" \
    "stdlib_multi/main.sn" \
    "50
20
hello from stdlib"

# 5. local module — use a local file by dotted path
run_test "local_module" \
    "local_module/main.sn" \
    "10"

# 6. chained modules — main uses mod2, mod2 uses mod1
run_test "chained" \
    "chained/main.sn" \
    "333"

# 7. package module — use mylib.calc which itself uses mylib.utils
run_test "package" \
    "package/main.sn" \
    "333"

# 8. duplicate use — same module imported twice, should not double-register
run_test "duplicate_use" \
    "duplicate_use/main.sn" \
    "42"

# 9. multiple functions from one module
run_test "multi_fn" \
    "multi_fn/main.sn" \
    "5
10
5"

# -------------------------------------------------------
echo ""
echo -e "${CYAN}-------------------${NC}"
TOTAL=$((PASS + FAIL + SKIP))
echo -e "${BOLD}Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}, ${YELLOW}$SKIP skipped${NC} / $TOTAL total"
echo ""
[ $FAIL -gt 0 ] && exit 1 || exit 0

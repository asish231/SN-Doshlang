#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building compiler...${NC}"
make clean && make

echo -e "${GREEN}Compiling tests/test_math.sn...${NC}"
./snc tests/test_math.sn > out.s

echo -e "${GREEN}Linking out.s...${NC}"
clang out.s -o out

if [ -f "out" ]; then
    echo -e "${GREEN}Running tests/test_math...${NC}"
    ACTUAL="$(./out)"
    EXPECTED="$(cat <<'EOF'
Testing Math Stdlib:
abs(-10):
10
max(5, 10):
10
min(5, 10):
5
pow(2, 3):
8
clamp(15, 0, 10):
10
sign(-42):
-1
EOF
)"
    if [ "$ACTUAL" != "$EXPECTED" ]; then
        echo -e "${RED}test_math output mismatch${NC}"
        echo "----- expected -----"
        echo "$EXPECTED"
        echo "----- actual -----"
        echo "$ACTUAL"
        exit 1
    fi
    echo -e "${GREEN}test_math passed${NC}"
else
    echo -e "${RED}Compilation failed, no output binary found.${NC}"
    exit 1
fi

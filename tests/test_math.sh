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
    ./out
else
    echo -e "${RED}Compilation failed, no output binary found.${NC}"
    exit 1
fi

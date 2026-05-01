#!/bin/bash
set -e

echo "Building compiler..."
make clean && make

echo "Compiling tests/test_string_lib.sn..."
./snc tests/test_string_lib.sn > out.s

echo "Linking out.s..."
clang out.s -o tests/test_string_lib

echo "Running tests/test_string_lib..."
./tests/test_string_lib

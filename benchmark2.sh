#!/usr/bin/env bash

echo "========================================"
echo "    SNLANG COMPREHENSIVE BENCHMARK"
echo "========================================"
echo ""

mkdir -p .build

echo "[1/6] Simple Loop (100M iterations)"
echo "     SNlang:"
./snc bench.sn > .build/bench_sn.s
clang .build/bench_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_sn
time ./.build/bench_sn
echo "     C -O0:"
gcc -O0 bench.c -o .build/bench_c_o0
time ./.build/bench_c_o0

echo ""
echo "[2/6] Array Sum (10M iterations)"
echo "     SNlang:"
./snc bench_array.sn > .build/bench_array_sn.s
clang .build/bench_array_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_array_sn
time ./.build/bench_array_sn
echo "     C -O0:"
gcc -O0 bench_array.c -o .build/bench_array_c
time ./.build/bench_array_c

echo ""
echo "[3/6] Nested Loop (1000x1000x100 = 100M)"
echo "     SNlang:"
./snc bench_nested.sn > .build/bench_nested_sn.s
clang .build/bench_nested_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_nested_sn
time ./.build/bench_nested_sn
echo "     C -O0:"
gcc -O0 bench_nested.c -o .build/bench_nested_c
time ./.build/bench_nested_c

echo ""
echo "[4/6] Python (nested loop)"
python3 bench_nested.py

echo ""
echo "[5/6] Node.js (nested loop)"
node bench.js

echo ""
echo "[6/6] Java (simple loop)"
javac Bench.java 2>/dev/null || echo "Java file not found"
time java Bench 2>/dev/null || echo "Java not available"

echo ""
echo "Done!"
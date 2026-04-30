#!/usr/bin/env bash

echo "========================================"
echo "   WORKING BENCHMARKS (SNlang OK)"
echo "========================================"
echo ""

mkdir -p .build

echo "[1] Simple Loop 100M iterations"
./snc bench.sn > .build/bench_sn.s
clang .build/bench_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_sn
echo "  SNlang:"
time ./.build/bench_sn
echo "  C -O0:"
gcc -O0 bench.c -o .build/bench_c_o0
time ./.build/bench_c_o0

echo ""
echo "[2] Array Sum 10M iterations"
./snc bench_array.sn > .build/bench_array_sn.s
clang .build/bench_array_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_array_sn
echo "  SNlang:"
time ./.build/bench_array_sn
echo "  C -O0:"
gcc -O0 bench_array.c -o .build/bench_array_c
time ./.build/bench_array_c

echo ""
echo "[3] Nested Loop 100M iterations (1Kx1Kx100)"
./snc bench_nested.sn > .build/bench_nested_sn.s
clang .build/bench_nested.sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_nested_sn
echo "  SNlang:"
time ./.build/bench_nested_sn
echo "  C -O0:"
gcc -O0 bench_nested.c -o .build/bench_nested_c
time ./.build/bench_nested_c

echo ""
echo "[4] Python equivalents (for reference)"
echo "  Simple Loop:"
time python3 -c "sum=0;i=0;exec('while i<100000000:sum+=1;i+=1');print(sum)" 2>/dev/null || echo "  (skipped - too slow)"
echo "  Nested Loop:"
time python3 bench_nested.py 2>/dev/null || echo "  (skipped - error)"

echo ""
echo "[5] Node.js equivalents"
echo "  Simple Loop:"
time node bench_simple.js 2>/dev/null || echo "  (no file)"
echo "  Nested Loop:"
time node bench_nested.js 2>/dev/null || echo "  (no file)"

echo ""
echo "Done!"
#!/usr/bin/env bash

echo "========================================="
echo "    FINAL SNLANG PERFORMANCE REPORT"
echo "========================================="
echo ""

mkdir -p .build

echo "1. Simple Loop: sum=sum+1; i++ (100M iterations)"
./snc bench.sn > .build/bench_sn.s
clang .build/bench_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_sn
echo "  SNlang:"
{ time ./.build/bench_sn; } 2>&1 | grep real
echo "  C -O0:"
gcc -O0 bench.c -o .build/bench_c_o0
{ time ./.build/bench_c_o0; } 2>&1 | grep real
echo "  C -O3:"
gcc -O3 bench.c -o .build/bench_c_o3
{ time ./.build/bench_c_o3; } 2>&1 | grep real
echo "  Java:"
javac Bench.java 2>/dev/null && { time java Bench; } 2>&1 | grep real || echo "  (failed)"
echo ""

echo "2. Array Sum: sum=sum+i; i++ (10M iterations)"
./snc bench_array.sn > .build/bench_array_sn.s
clang .build/bench_array_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_array_sn
echo "  SNlang:"
{ time ./.build/bench_array_sn; } 2>&1 | grep real
echo "  C -O0:"
gcc -O0 bench_array.c -o .build/bench_array_c
{ time ./.build/bench_array_c; } 2>&1 | grep real
echo "  C -O3:"
gcc -O3 bench_array.c -o .build/bench_array_c_o3
{ time ./.build/bench_array_c_o3; } 2>&1 | grep real
echo "  Java:"
javac BenchArraySum.java 2>/dev/null && { time java BenchArraySum; } 2>&1 | grep real || echo "  (failed)"
echo ""

echo "3. Nested Loop: 1000x1000x100 (100M total ops)"
./snc bench_nested.sn > .build/bench_nested_sn.s
clang .build/bench_nested_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_nested_sn
echo "  SNlang:"
{ time ./.build/bench_nested_sn; } 2>&1 | grep real
echo "  C -O0:"
gcc -O0 bench_nested.c -o .build/bench_nested_c
{ time ./.build/bench_nested_c; } 2>&1 | grep real
echo "  C -O3:"
gcc -O3 bench_nested.c -o .build/bench_nested_c_o3
{ time ./.build/bench_nested_c_o3; } 2>&1 | grep real
echo ""

echo "4. Iterative Fibonacci n=40"
./snc fib_iter.sn > .build/fib_iter_sn.s
clang .build/fib_iter_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/fib_iter_sn
echo "  SNlang:"
{ time ./.build/fib_iter_sn; } 2>&1 | grep real
echo "  C -O0:"
gcc -O0 fib_iter.c -o .build/fib_iter_c
{ time ./.build/fib_iter_c; } 2>&1 | grep real
echo "  C -O3:"
gcc -O3 fib_iter.c -o .build/fib_iter_c_o3
{ time ./.build/fib_iter_c_o3; } 2>&1 | grep real
echo ""

# Correctness checks
echo "===== CORRECTNESS CHECKS ====="
echo ""
echo "Array Sum 10M (expected: 49999995000000)"
./.build/bench_array_sn
./.build/bench_array_c
./.build/bench_array_c_o3 2>/dev/null || echo "  C -O3: (failed)"
java BenchArraySum 2>/dev/null || echo "  Java: (failed)"
echo ""
echo "Nested Loop 100M (expected: 100000000)"
./.build/bench_nested_sn
./.build/bench_nested_c
./.build/bench_nested_c_o3 2>/dev/null || echo "  C -O3: (failed)"
echo ""
echo "Fibonacci n=40 (expected: 102334155)"
./.build/fib_iter_sn
./.build/fib_iter_c
./.build/fib_iter_c_o3 2>/dev/null || echo "  C -O3: (failed)"
echo ""
echo "========================================="
echo "    REPORT COMPLETE"
echo "========================================="
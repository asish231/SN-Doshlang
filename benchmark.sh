#!/usr/bin/env bash

echo "======================"
echo " SPEED BENCHMARK TEST"
echo "======================"
echo "  Loop: 100,000,000 iterations (each language)"
echo "======================"

mkdir -p .build

echo ""
echo "[1/5] Node.js"
time node bench.js

echo ""
echo "[2/5] C (Optimized -O3)"
gcc -O3 bench.c -o bench_c
time ./bench_c

echo ""
echo "[3/5] C (Unoptimized)"
gcc bench.c -o bench_c_unopt
time ./bench_c_unopt

echo ""
echo "[4/5] Java"
javac Bench.java
time java Bench

echo ""
echo "[5/5] SNlang (compile then run)"
echo "  Compiling bench.sn..."
./snc bench.sn > .build/bench_sn.s
clang .build/bench_sn.s -isysroot $(xcrun --show-sdk-path) -o .build/bench_sn
echo "  Running..."
time ./.build/bench_sn

echo ""
echo "Done!"

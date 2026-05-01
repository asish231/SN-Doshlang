#!/usr/bin/env bash
set -e
make 2>&1
echo "=== BUILD OK ==="
./test_modules.sh

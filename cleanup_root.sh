#!/usr/bin/env bash
# Move all test/scratch files from repo root into tests/
# Safe: skips files already in tests/, skips src/, examples/, stdlib/, etc.
# Run from repo root: ./cleanup_root.sh

set -e
REPO="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO"

moved=0
skipped=0

move() {
    local f="$1"
    local dest="tests/$(basename "$f")"
    if [ -e "$dest" ]; then
        echo "  SKIP (exists) $f"
        skipped=$((skipped+1))
    else
        mv "$f" "tests/"
        echo "  MOVE $f -> tests/"
        moved=$((moved+1))
    fi
}

echo "Moving test .sn files..."
for f in test_*.sn fib_iter.sn hard_dsa_suite.sn trap_rain_water.sn type_mismatch.sn math_local.sn math.sn a.sn b.sn c.sn test.sn; do
    [ -f "$f" ] && move "$f"
done

echo "Moving stray .s files..."
for f in *.s; do
    [ -f "$f" ] || continue
    # keep math.s (it's a hand-written asm file, not a test artifact)
    [[ "$f" == "math.s" ]] && continue
    move "$f"
done

echo "Moving compiled test binaries..."
for f in test_* ptr1_bin ptr2_bin basic_bin hello concat out; do
    [ -f "$f" ] && [ -x "$f" ] && move "$f"
done

echo "Moving misc scratch files..."
for f in err.txt stderr.txt stdout.txt snc_file_io.txt test_out.s out.s; do
    [ -f "$f" ] && move "$f"
done

echo ""
echo "Done. Moved: $moved  Skipped (already exist): $skipped"

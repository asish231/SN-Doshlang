#!/usr/bin/env python3

import sys


def main() -> int:
    count = 300
    if len(sys.argv) > 1:
        count = int(sys.argv[1])

    for idx in range(count):
        print(f"fn f{idx}() -> int {{")
        print(f"    return {idx}")
        print("}")
        print()

    print("fn main() {")
    print("    int s = 0")
    for idx in range(count):
        print(f"    s = s + f{idx}()")
    print('    print("{s}")')
    print("}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
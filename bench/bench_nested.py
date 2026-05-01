#!/usr/bin/env python3

def main():
    sum_val = 0
    i = 0
    while i < 1000:
        j = 0
        while j < 1000:
            k = 0
            while k < 100:
                sum_val = sum_val + 1
                k = k + 1
            j = j + 1
        i = i + 1
    print(sum_val)

if __name__ == "__main__":
    main()
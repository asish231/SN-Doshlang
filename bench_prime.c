#include <stdio.h>

int is_prime(int n) {
    if (n <= 1) return 0;
    if (n <= 3) return 1;
    int i = 2;
    while (i * i <= n) {
        if (n % i == 0) return 0;
        i = i + 1;
    }
    return 1;
}

int main() {
    int count = 0;
    int i = 2;
    while (i <= 10000) {
        if (is_prime(i)) {
            count = count + 1;
        }
        i = i + 1;
    }
    printf("%d\n", count);
    return 0;
}
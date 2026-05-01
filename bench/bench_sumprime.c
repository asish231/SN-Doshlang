#include <stdio.h>

int sum_primes(int limit) {
    int sum = 0;
    int i = 2;
    while (i <= limit) {
        int is_prime = 1;
        int j = 2;
        while (j * j <= i) {
            if (i % j == 0) {
                is_prime = 0;
            }
            j = j + 1;
        }
        if (is_prime) {
            sum = sum + i;
        }
        i = i + 1;
    }
    return sum;
}

int main() {
    int result = sum_primes(5000);
    printf("%d\n", result);
    return 0;
}
#include <stdio.h>

int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

int main() {
    int result = 0;
    int i = 1;
    while (i <= 10) {
        result = result + factorial(i);
        i = i + 1;
    }
    printf("%d\n", result);
    return 0;
}
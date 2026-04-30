#include <stdio.h>

int sum_squares(int limit) {
    int sum = 0;
    int i = 0;
    while (i <= limit) {
        sum = sum + (i * i);
        i = i + 1;
    }
    return sum;
}

int main() {
    int result = sum_squares(10000);
    printf("%d\n", result);
    return 0;
}
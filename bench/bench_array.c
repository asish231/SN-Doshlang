#include <stdio.h>

int main() {
    int sum = 0;
    int i = 0;
    while (i < 10000000) {
        sum = sum + i;
        i = i + 1;
    }
    printf("%d\n", sum);
    return 0;
}
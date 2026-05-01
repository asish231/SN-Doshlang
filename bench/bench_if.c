#include <stdio.h>

int main() {
    int sum = 0;
    int i = 0;
    while (i <= 10000) {
        if (i <= 3) {
            sum = sum + i;
        }
        if (i == 4) {
            sum = sum + i;
        }
        if (i == 5) {
            sum = sum + i;
        }
        i = i + 1;
    }
    printf("%d\n", sum);
    return 0;
}
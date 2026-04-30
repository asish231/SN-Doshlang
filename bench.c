#include <stdio.h>

int main() {
    int sum = 0;
    int i = 0;
    while (i < 100000000) {
        sum = sum + 1;
        i++;
    }
    printf("%d\n", sum);
    return 0;
}

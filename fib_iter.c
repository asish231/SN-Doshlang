#include <stdio.h>

int main() {
    int n = 40;
    int a = 0;
    int b = 1;
    int i = 0;
    while (i < n) {
        int temp = a + b;
        a = b;
        b = temp;
        i = i + 1;
    }
    printf("%d\n", a);
    return 0;
}
#include <stdio.h>

int main() {
    int sum = 0;
    int i = 0;
    while (i < 1000) {
        int j = 0;
        while (j < 1000) {
            int k = 0;
            while (k < 100) {
                sum = sum + 1;
                k = k + 1;
            }
            j = j + 1;
        }
        i = i + 1;
    }
    printf("%d\n", sum);
    return 0;
}
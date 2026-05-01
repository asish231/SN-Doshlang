#include <stdio.h>

int main() {
    double pi = 0.0;
    int iterations = 100000000;
    int sign = 1;
    int i = 0;
    while (i < iterations) {
        pi = pi + (sign * (1.0 / (2 * i + 1)));
        sign = sign * -1;
        i = i + 1;
    }
    pi = pi * 4.0;
    printf("%.10f\n", pi);
    return 0;
}
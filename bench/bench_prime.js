let is_prime = (n) => {
    if (n <= 1) return false;
    if (n <= 3) return true;
    let i = 2;
    while (i * i <= n) {
        if (n % i === 0) return false;
        i = i + 1;
    }
    return true;
};

let count = 0;
let i = 2;
while (i <= 10000) {
    if (is_prime(i)) {
        count = count + 1;
    }
    i = i + 1;
}
console.log(count);
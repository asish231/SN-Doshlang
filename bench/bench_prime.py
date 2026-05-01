def is_prime(n):
    if n <= 1: return False
    if n <= 3: return True
    i = 2
    while i * i <= n:
        if n % i == 0: return False
        i = i + 1
    return True

count = 0
i = 2
while i <= 10000:
    if is_prime(i):
        count = count + 1
    i = i + 1
print(count)
---
id: exam_l3_add_prime_sum
module: exam
phase: phase4
title: "add_prime_sum"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "math", "primes"]
norminette: true
man_pages: []
multi_day: false
order: 250
level: 3
time_limit_minutes: 30
---

# add_prime_sum

## Assignment

Напиши програму, яка приймає один аргумент `argv[1]` -- додатне ціле число N, і виводить суму всіх простих чисел (prime numbers), менших або рівних N, за якою слідує newline.

Якщо аргумент не переданий, або N менше 0, або аргумент не є коректним числом, програма виводить `0`, за яким слідує newline.

### Expected files

- `add_prime_sum.c`

### Allowed functions

- `write`

### Example

```
$> ./add_prime_sum 5
10
$> ./add_prime_sum 100
1060
$> ./add_prime_sum 2
2
$> ./add_prime_sum 1
0
$> ./add_prime_sum 0
0
$> ./add_prime_sum
0
$>
```

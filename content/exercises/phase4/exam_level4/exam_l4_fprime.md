---
id: exam_l4_fprime
module: exam
phase: phase4
title: "fprime"
difficulty: 5
xp: 80
estimated_minutes: 45
prerequisites: []
tags: ["exam", "math", "primes"]
norminette: true
man_pages: []
multi_day: false
order: 271
level: 4
time_limit_minutes: 45
---

# fprime

## Assignment

Напиши програму, яка виводить розкладання числа на простi множники (prime factorization).

Програма отримує одне число як аргумент. Множники виводяться у порядку зростання, роздiленi ` * `. Пiсля останнього множника -- перехiд на новий рядок.

Якщо аргументiв не передано -- вивести лише новий рядок.
Якщо число дорiвнює 1 -- вивести `1` та новий рядок.

### Expected files

- `fprime.c`

### Allowed functions

- `write`
- `atoi`

### Example

```
$> ./fprime "225"
3 * 3 * 5 * 5
$> ./fprime "42"
2 * 3 * 7
$> ./fprime "1"
1
$> ./fprime "2"
2
$> ./fprime "11"
11
$> ./fprime
$>
```

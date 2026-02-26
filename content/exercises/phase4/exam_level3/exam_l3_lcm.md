---
id: exam_l3_lcm
module: exam
phase: phase4
title: "lcm"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "math"]
norminette: true
man_pages: []
multi_day: false
order: 257
level: 3
time_limit_minutes: 30
---

# lcm

## Assignment

Напиши функцію `lcm`, яка повертає найменше спільне кратне (Least Common Multiple) двох беззнакових цілих чисел.

Якщо хоча б один аргумент дорівнює 0, функція повертає 0.

Використовуй формулу: `lcm(a, b) = a / gcd(a, b) * b`.

### Prototype

```c
unsigned int	lcm(unsigned int a, unsigned int b);
```

### Expected files

- `lcm.c`

### Allowed functions

- None

### Example

```c
lcm(6, 4);   /* returns 12 */
lcm(3, 5);   /* returns 15 */
lcm(0, 5);   /* returns 0 */
lcm(12, 18); /* returns 36 */
lcm(1, 1);   /* returns 1 */
```

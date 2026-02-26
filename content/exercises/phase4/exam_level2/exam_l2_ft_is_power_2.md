---
id: exam_l2_ft_is_power_2
module: exam
phase: phase4
title: "ft_is_power_2"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "bits"]
norminette: true
man_pages: []
multi_day: false
order: 241
level: 2
time_limit_minutes: 20
---

# ft_is_power_2

## Assignment

Напиши функцію `ft_is_power_2`, яка перевіряє, чи є число степенем двійки.

Повертає `1`, якщо `n` є степенем 2 (включаючи 1 = 2^0), або `0` в іншому випадку.

### Прототип

```c
int	ft_is_power_2(unsigned int n);
```

### Expected files

- `ft_is_power_2.c`

### Allowed functions

- None

### Example

```c
ft_is_power_2(1);   // returns 1 (2^0)
ft_is_power_2(2);   // returns 1 (2^1)
ft_is_power_2(4);   // returns 1 (2^2)
ft_is_power_2(3);   // returns 0
ft_is_power_2(0);   // returns 0
```

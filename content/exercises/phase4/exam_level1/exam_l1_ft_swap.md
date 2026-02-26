---
id: exam_l1_ft_swap
module: exam
phase: phase4
title: "ft_swap"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: []
tags: ["exam", "pointers"]
norminette: true
man_pages: []
multi_day: false
order: 215
level: 1
time_limit_minutes: 10
---

# ft_swap

## Assignment

Напиши функцію `ft_swap`, яка міняє місцями значення двох цілих чисел (int), адреси яких передані як параметри.

### Прототип

```c
void	ft_swap(int *a, int *b);
```

### Expected files

- `ft_swap.c`

### Allowed functions

- None

### Example

```c
int a = 42;
int b = 21;
ft_swap(&a, &b);
/* a == 21, b == 42 */
```

---
id: exam_l3_ft_range
module: exam
phase: phase4
title: "ft_range"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "malloc", "arrays"]
norminette: true
man_pages: []
multi_day: false
order: 255
level: 3
time_limit_minutes: 30
---

# ft_range

## Assignment

Напиши функцію `ft_range`, яка повертає масив цілих чисел (int), виділений через `malloc`. Масив містить всі значення від `start` до `end` (не включаючи `end`).

Якщо `start < end`, масив зростає: `[start, start+1, ..., end-1]`.
Якщо `start > end`, масив спадає: `[start, start-1, ..., end+1]`.
Якщо `start == end`, повертається `NULL`.

### Prototype

```c
int	*ft_range(int start, int end);
```

### Expected files

- `ft_range.c`

### Allowed functions

- `malloc`

### Example

```c
int *r;

r = ft_range(0, 5);    // [0, 1, 2, 3, 4]
r = ft_range(5, 0);    // [5, 4, 3, 2, 1]
r = ft_range(-2, 2);   // [-2, -1, 0, 1]
r = ft_range(3, 3);    // NULL
```

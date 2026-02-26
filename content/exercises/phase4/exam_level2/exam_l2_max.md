---
id: exam_l2_max
module: exam
phase: phase4
title: "max"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "arrays"]
norminette: true
man_pages: []
multi_day: false
order: 242
level: 2
time_limit_minutes: 20
---

# max

## Assignment

Напиши функцію `max`, яка знаходить максимальне значення в масиві цілих чисел.

Якщо `len` дорівнює 0, повертає 0.

### Прототип

```c
int	max(int *tab, unsigned int len);
```

### Expected files

- `max.c`

### Allowed functions

- None

### Example

```c
int arr[] = {1, 5, 3, 9, 2};
max(arr, 5);      /* returns 9 */
max(arr, 0);      /* returns 0 */

int neg[] = {-5, -1, -3};
max(neg, 3);      /* returns -1 */
```

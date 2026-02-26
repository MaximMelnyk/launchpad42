---
id: exam_l1_ft_strcpy
module: exam
phase: phase4
title: "ft_strcpy"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: []
tags: ["exam", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 213
level: 1
time_limit_minutes: 10
---

# ft_strcpy

## Assignment

Напиши функцію `ft_strcpy`, яка відтворює поведінку стандартної функції `strcpy` (man 3 strcpy).

Копіює рядок `src` у буфер `dest`, включаючи термінальний `'\0'`.

### Прототип

```c
char	*ft_strcpy(char *dest, char *src);
```

### Expected files

- `ft_strcpy.c`

### Allowed functions

- None

### Example

```c
char src[] = "Hello";
char dest[10];
ft_strcpy(dest, src);
// dest now contains "Hello"
```

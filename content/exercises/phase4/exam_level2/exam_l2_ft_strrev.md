---
id: exam_l2_ft_strrev
module: exam
phase: phase4
title: "ft_strrev"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 238
level: 2
time_limit_minutes: 20
---

# ft_strrev

## Assignment

Напиши функцію `ft_strrev`, яка розвертає рядок in-place (на місці).

Функція модифікує вхідний рядок, розвертаючи порядок символів, та повертає вказівник на нього.

### Прототип

```c
char	*ft_strrev(char *str);
```

### Expected files

- `ft_strrev.c`

### Allowed functions

- None

### Example

```c
char s[] = "Hello";
ft_strrev(s);   // s is now "olleH", returns s
char e[] = "";
ft_strrev(e);   // e is still "", returns e
```

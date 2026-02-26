---
id: exam_l2_ft_strdup
module: exam
phase: phase4
title: "ft_strdup"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "malloc", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 236
level: 2
time_limit_minutes: 20
---

# ft_strdup

## Assignment

Напиши функцію `ft_strdup`, яка відтворює поведінку стандартної функції `strdup` (man 3 strdup).

Функція виділяє пам'ять за допомогою `malloc` та копіює вхідний рядок `src` у нову область пам'яті. Повертає вказівник на копію або `NULL` у разі помилки.

### Прототип

```c
char	*ft_strdup(char *src);
```

### Expected files

- `ft_strdup.c`

### Allowed functions

- `malloc`

### Example

```c
char *copy = ft_strdup("hello");
/* copy points to new memory containing "hello\0" */
```

---
id: exam_l1_ft_strlen
module: exam
phase: phase4
title: "ft_strlen"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: []
tags: ["exam", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 214
level: 1
time_limit_minutes: 10
---

# ft_strlen

## Assignment

Напиши функцію `ft_strlen`, яка відтворює поведінку стандартної функції `strlen` (man 3 strlen).

Повертає довжину рядка (кількість символів до термінального `'\0'`).

### Прототип

```c
int	ft_strlen(char *str);
```

### Expected files

- `ft_strlen.c`

### Allowed functions

- None

### Example

```c
ft_strlen("Hello");  /* returns 5 */
ft_strlen("");       /* returns 0 */
ft_strlen("42");     /* returns 2 */
```

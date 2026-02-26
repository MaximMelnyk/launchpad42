---
id: exam_l2_ft_strcmp
module: exam
phase: phase4
title: "ft_strcmp"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 234
level: 2
time_limit_minutes: 20
---

# ft_strcmp

## Assignment

Напиши функцію `ft_strcmp`, яка відтворює поведінку стандартної функції `strcmp` (man 3 strcmp).

Порівнює два рядки посимвольно. Повертає різницю між першими символами, які не збігаються, або 0, якщо рядки ідентичні.

### Прототип

```c
int	ft_strcmp(char *s1, char *s2);
```

### Expected files

- `ft_strcmp.c`

### Allowed functions

- None

### Example

```c
ft_strcmp("abc", "abc");  /* returns 0 */
ft_strcmp("abc", "abd");  /* returns negative value */
ft_strcmp("abd", "abc");  /* returns positive value */
ft_strcmp("", "");        /* returns 0 */
ft_strcmp("a", "");       /* returns positive value */
```

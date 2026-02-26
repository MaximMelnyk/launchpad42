---
id: exam_l2_ft_strcspn
module: exam
phase: phase4
title: "ft_strcspn"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: []
tags: ["exam", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 235
level: 2
time_limit_minutes: 25
---

# ft_strcspn

## Assignment

Напиши функцію `ft_strcspn`, яка відтворює поведінку стандартної функції `strcspn` (man 3 strcspn).

Повертає довжину початкового сегмента рядка `s`, який НЕ містить жодного символу з рядка `reject`.

### Прототип

```c
size_t	ft_strcspn(const char *s, const char *reject);
```

### Expected files

- `ft_strcspn.c`

### Allowed functions

- None

### Example

```c
ft_strcspn("hello", "ol");    /* returns 2 ('h','e' before 'l') */
ft_strcspn("abcdef", "dc");   /* returns 2 ('a','b' before 'c') */
ft_strcspn("hello", "xyz");   /* returns 5 (no reject chars found) */
ft_strcspn("hello", "h");     /* returns 0 (first char is in reject) */
ft_strcspn("", "abc");        /* returns 0 */
```

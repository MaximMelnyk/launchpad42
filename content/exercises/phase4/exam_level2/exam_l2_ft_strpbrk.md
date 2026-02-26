---
id: exam_l2_ft_strpbrk
module: exam
phase: phase4
title: "ft_strpbrk"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: []
tags: ["exam", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 237
level: 2
time_limit_minutes: 25
---

# ft_strpbrk

## Assignment

Напиши функцію `ft_strpbrk`, яка відтворює поведінку стандартної функції `strpbrk` (man 3 strpbrk).

Знаходить перший символ у рядку `s1`, який збігається з будь-яким символом з рядка `s2`. Повертає вказівник на цей символ або `NULL`, якщо збіг не знайдено.

### Прототип

```c
char	*ft_strpbrk(const char *s1, const char *s2);
```

### Expected files

- `ft_strpbrk.c`

### Allowed functions

- None

### Example

```c
ft_strpbrk("hello", "ol");   /* returns pointer to 'l' in "hello" (index 2) */
ft_strpbrk("hello", "xyz");  /* returns NULL */
ft_strpbrk("hello", "h");    /* returns pointer to 'h' (index 0) */
ft_strpbrk("", "abc");       /* returns NULL */
```

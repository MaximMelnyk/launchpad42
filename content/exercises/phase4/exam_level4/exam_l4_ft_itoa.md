---
id: exam_l4_ft_itoa
module: exam
phase: phase4
title: "ft_itoa"
difficulty: 5
xp: 80
estimated_minutes: 60
prerequisites: []
tags: ["exam", "malloc", "conversion"]
norminette: true
man_pages: []
multi_day: false
order: 272
level: 4
time_limit_minutes: 60
---

# ft_itoa

## Assignment

Напиши функцiю `ft_itoa`, яка перетворює цiле число (int) у рядок (string), видiляючи пам'ять за допомогою `malloc`.

Функцiя повинна коректно обробляти:
- Додатнi числа
- Вiд'ємнi числа (з символом `'-'`)
- Нуль
- `INT_MIN` (-2147483648)
- `INT_MAX` (2147483647)

Повертає вказiвник на новий рядок або `NULL` у разi помилки malloc.

### Прототип

```c
char  *ft_itoa(int nbr);
```

### Expected files

- `ft_itoa.c`

### Allowed functions

- `malloc`

### Example

```c
ft_itoa(42);          // "42"
ft_itoa(-42);         // "-42"
ft_itoa(0);           // "0"
ft_itoa(-2147483648); // "-2147483648"
ft_itoa(2147483647);  // "2147483647"
```

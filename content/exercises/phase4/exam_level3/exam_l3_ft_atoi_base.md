---
id: exam_l3_ft_atoi_base
module: exam
phase: phase4
title: "ft_atoi_base"
difficulty: 4
xp: 60
estimated_minutes: 45
prerequisites: []
tags: ["exam", "conversion", "base"]
norminette: true
man_pages: []
multi_day: false
order: 253
level: 3
time_limit_minutes: 45
---

# ft_atoi_base

## Assignment

Напиши функцію `ft_atoi_base`, яка перетворює рядок `str` у число (int) відповідно до вказаної системи числення `base`.

Функція повинна:
- Пропускати початкові пробіли та табуляції (whitespace)
- Обробляти один або кілька знаків `'+'` та `'-'`
- Зчитувати символи з рядка, поки вони є валідними символами бази
- Повертати 0, якщо base невалідна

Base вважається невалідною, якщо:
- Довжина base менше 2
- base містить дублікати символів
- base містить `'+'` або `'-'`

### Prototype

```c
int	ft_atoi_base(char *str, char *base);
```

### Expected files

- `ft_atoi_base.c`

### Allowed functions

- None

### Example

```c
ft_atoi_base("2a", "0123456789abcdef");  // returns 42
ft_atoi_base("101010", "01");             // returns 42
ft_atoi_base("  -2a", "0123456789abcdef"); // returns -42
ft_atoi_base("42", "0123456789");          // returns 42
```

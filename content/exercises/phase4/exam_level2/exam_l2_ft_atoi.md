---
id: exam_l2_ft_atoi
module: exam
phase: phase4
title: "ft_atoi"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: []
tags: ["exam", "conversion"]
norminette: true
man_pages: []
multi_day: false
order: 233
level: 2
time_limit_minutes: 25
---

# ft_atoi

## Assignment

Напиши функцію `ft_atoi`, яка перетворює рядок у ціле число (int), відтворюючи поведінку стандартної функції `atoi`.

Функція повинна:
- Пропускати початкові пробіли та табуляції (whitespace: `' '`, `'\t'`, `'\n'`, `'\v'`, `'\f'`, `'\r'`)
- Обробляти один необов'язковий знак `'+'` або `'-'`
- Зчитувати послідовність цифр `'0'`-`'9'`

### Прототип

```c
int	ft_atoi(char *str);
```

### Expected files

- `ft_atoi.c`

### Allowed functions

- None

### Example

```c
ft_atoi("42");         // returns 42
ft_atoi("   -42");     // returns -42
ft_atoi("  +123abc");  // returns 123
ft_atoi("abc");        // returns 0
ft_atoi("  \t  567");  // returns 567
```

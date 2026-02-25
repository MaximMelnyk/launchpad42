---
id: p0_d04_char_codes
module: p0
phase: phase0
title: "Char Codes"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["p0_d03_ft_putnbr"]
tags: ["c", "ascii", "char", "types"]
norminette: true
man_pages: ["write", "ascii"]
multi_day: false
order: 8
---

# Char Codes

## Завдання

Зрозумій зв'язок між символами та числами в C.

Кожний символ у C -- це число (ASCII код). Наприклад, `'A'` = 65, `'a'` = 97, `'0'` = 48.

Напиши програму, яка виводить ASCII коди чотирьох символів, розділені пробілами:

- `'A'`
- `'a'`
- `'0'`
- `' '` (пробіл)

### Вимоги

- Використовуй `ft_putnbr` для виводу числових кодів
- Використовуй `ft_putchar` для виводу пробілів та нового рядка
- НЕ записуй числа напряму -- нехай програма обчислює їх через символи
- Файли: `main.c` + `ft_putchar.c` + `ft_putnbr.c`
- Norminette: так

### Очікуваний результат

```
65 97 48 32
```

## Підказки

<details>
<summary>Підказка 1</summary>

У C тип `char` -- це насправді маленьке ціле число (зазвичай 1 байт). Коли ти пишеш `'A'`, компілятор підставляє число 65.

Тому можна робити так:
```c
int	code;

code = 'A';
ft_putnbr(code);
```

</details>

<details>
<summary>Підказка 2</summary>

Можна передати `char` напряму в `ft_putnbr`, тому що C автоматично перетворює `char` на `int`:
```c
ft_putnbr('A');
ft_putchar(' ');
ft_putnbr('a');
```

</details>

## Man сторінки

- `man 2 write`
- `man ascii`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| код символу | code ASCII | "Le code ASCII de 'A' est 65" |
| таблиця | tableau | "Le tableau ASCII" |

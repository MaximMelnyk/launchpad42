---
id: p0_d03_variables
module: p0
phase: phase0
title: "Variables"
difficulty: 1
xp: 15
estimated_minutes: 20
prerequisites: ["p0_d02_ft_putstr"]
tags: ["c", "variables", "types", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 5
---

# Variables

## Завдання

Розберись з базовими типами даних у C та навчись виводити їх значення.

Створи програму, яка:
1. Оголошує змінну типу `int` зі значенням `42`
2. Оголошує змінну типу `char` зі значенням `'Z'`
3. Виводить обидва значення без пробілів: `42Z`

### Вимоги

- Змінні оголошуються на початку функції (C89 стиль, вимога Norminette)
- Для виводу числа використовуй `ft_putchar` -- виводь кожну цифру окремо
- Для виводу символу використовуй `ft_putchar`
- НЕ використовуй `printf`
- Файли: `main.c` + `ft_putchar.c`
- Norminette: так

### Очікуваний результат

```
42Z
```

(без переходу на новий рядок)

## Підказки

<details>
<summary>Підказка 1</summary>

Змінні у C оголошуються так:
```c
int		nb;
char	c;

nb = 42;
c = 'Z';
```

Зверни увагу: у Norminette оголошення та присвоєння можна робити в одному рядку: `int nb = 42;`, але всі оголошення повинні бути на початку функції.

</details>

<details>
<summary>Підказка 2</summary>

Число `42` складається з двох цифр: `4` і `2`. Щоб вивести цифру як символ, додай `'0'` (ASCII код 48):
```c
ft_putchar('4');
ft_putchar('2');
ft_putchar(c);
```

Або обчисли:
```c
ft_putchar(nb / 10 + '0');
ft_putchar(nb % 10 + '0');
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| змінна | variable | "Déclarer une variable" |
| тип | type | "Le type int pour les entiers" |
| ціле число | entier | "Un entier de 32 bits" |

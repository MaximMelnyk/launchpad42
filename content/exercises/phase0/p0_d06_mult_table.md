---
id: p0_d06_mult_table
module: p0
phase: phase0
title: "Multiplication Table"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["p0_d06_counter"]
tags: ["c", "while", "loops", "format"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 16
---

# Multiplication Table

## Завдання

Виведи таблицю множення для числа 9.

Це завдання навчить тебе працювати з вкладеними циклами та форматованим виводом.

### Вимоги

- Виводь таблицю множення для числа 9 (від 9 x 1 до 9 x 9)
- Формат: `9 x {i} = {result}`
- Кожний рядок на новій строці
- Використовуй `ft_putnbr` для чисел, `ft_putstr` для тексту
- Тільки цикл `while` (НЕ `for`)
- Файли: `main.c` + `ft_putchar.c` + `ft_putstr.c` + `ft_putnbr.c`
- Norminette: так

### Очікуваний результат

```
9 x 1 = 9
9 x 2 = 18
9 x 3 = 27
9 x 4 = 36
9 x 5 = 45
9 x 6 = 54
9 x 7 = 63
9 x 8 = 72
9 x 9 = 81
```

## Підказки

<details>
<summary>Підказка 1</summary>

Тобі потрібен лише один цикл (не вкладений), тому що множник фіксований (9):
```c
int	i;

i = 1;
while (i <= 9)
{
	/* print line */
	i++;
}
```

</details>

<details>
<summary>Підказка 2</summary>

Для виводу одного рядка:
```c
ft_putnbr(9);
ft_putstr(" x ");
ft_putnbr(i);
ft_putstr(" = ");
ft_putnbr(9 * i);
ft_putchar('\n');
```

</details>

<details>
<summary>Бонус: повна таблиця множення</summary>

Якщо хочеш додатковий виклик -- виведи повну таблицю множення (від 1 x 1 до 9 x 9). Для цього знадобляться два вкладені цикли `while`.

```c
int	i;
int	j;

i = 1;
while (i <= 9)
{
	j = 1;
	while (j <= 9)
	{
		/* print i x j = result */
		j++;
	}
	i++;
}
```

</details>

## Man сторінки

- `man 2 write`

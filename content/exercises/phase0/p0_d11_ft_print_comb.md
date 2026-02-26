---
id: p0_d11_ft_print_comb
module: p0
phase: phase0
title: "ft_print_comb"
difficulty: 4
xp: 60
estimated_minutes: 45
prerequisites: ["p0_d09_review_combo_2"]
tags: ["c", "while", "combinations", "c00"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 23
---

# ft_print_comb

## Завдання

Напиши функцію `ft_print_comb`, яка виводить усі різні комбінації трьох цифр у порядку зростання.

Це вправа **C00 ex05** з Piscine — одна з обов'язкових. Вона тестує вміння працювати з вкладеними циклами та форматованим виводом.

### Прототип

```c
void	ft_print_comb(void);
```

### Вимоги

- Виводь усі комбінації трьох **різних** цифр (0-9) у порядку зростання
- Цифри всередині комбінації також у порядку зростання: `012`, а не `021`
- Комбінації розділяються `, ` (кома + пробіл)
- Після останньої комбінації (`789`) — нічого (ні кома, ні `\n`)
- Використовуй тільки `ft_putchar`
- Тільки цикл `while` (НЕ `for`)
- Файли: `ft_print_comb.c` + `ft_putchar.c`
- Norminette: так

### Очікуваний результат (скорочено)

```
012, 013, 014, 015, 016, 017, 018, 019, 023, 024, ..., 789
```

Повний вивід: 120 комбінацій.

### Тестування

```c
void	ft_print_comb(void);

int	main(void)
{
	ft_print_comb();
	return (0);
}
```

## Підказки

<details>
<summary>Підказка 1 — структура</summary>

Тобі потрібні три вкладених цикли `while`. Зовнішній для першої цифри (0-7), середній для другої (від першої+1 до 8), внутрішній для третьої (від другої+1 до 9).

```c
int	a;
int	b;
int	c;

a = 0;
while (a <= 7)
{
	b = a + 1;
	while (b <= 8)
	{
		c = b + 1;
		while (c <= 9)
		{
			/* print a, b, c */
			c++;
		}
		b++;
	}
	a++;
}
```

</details>

<details>
<summary>Підказка 2 — вивід та роздільник</summary>

Для кожної комбінації виводь три цифри через `ft_putchar`:
```c
ft_putchar(a + '0');
ft_putchar(b + '0');
ft_putchar(c + '0');
```

Кому з пробілом виводь **після кожної комбінації, крім останньої** (`789`):
```c
if (a != 7 || b != 8 || c != 9)
{
	ft_putchar(',');
	ft_putchar(' ');
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| комбінація | combinaison | "Afficher toutes les combinaisons" |
| цифра | chiffre | "Trois chiffres différents" |
| зростаючий | croissant | "Dans l'ordre croissant" |

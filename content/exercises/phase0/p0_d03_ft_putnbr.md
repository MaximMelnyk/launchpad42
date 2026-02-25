---
id: p0_d03_ft_putnbr
module: p0
phase: phase0
title: "ft_putnbr"
difficulty: 2
xp: 25
estimated_minutes: 30
prerequisites: ["p0_d03_variables"]
tags: ["c", "recursion", "numbers", "int"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 6
---

# ft_putnbr

## Завдання

Напиши функцію `ft_putnbr`, яка виводить ціле число на стандартний вивід.

Це одна з найважливіших функцій на Piscine -- ти будеш використовувати її постійно. Вона повинна коректно обробляти:
- Додатні числа
- Від'ємні числа (з мінусом)
- Нуль
- `INT_MIN` (-2147483648) -- особливий випадок!

### Прототип

```c
void	ft_putnbr(int nb);
```

### Вимоги

- Використовуй `ft_putchar` для виводу кожної цифри
- НЕ використовуй `printf`, `itoa`, або інші бібліотечні функції
- Обробляй `INT_MIN` (-2147483648) коректно
- Файли: `ft_putnbr.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_putnbr(int nb);

int	main(void)
{
	ft_putnbr(42);
	ft_putchar('\n');
	ft_putnbr(-42);
	ft_putchar('\n');
	ft_putnbr(0);
	ft_putchar('\n');
	ft_putnbr(-2147483648);
	ft_putchar('\n');
	ft_putnbr(2147483647);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
42
-42
0
-2147483648
2147483647
```

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм:
1. Якщо число від'ємне -- виведи `'-'` і працюй з абсолютним значенням
2. Якщо число >= 10 -- рекурсивно виклич `ft_putnbr(nb / 10)` для старших цифр
3. Виведи останню цифру: `ft_putchar(nb % 10 + '0')`

</details>

<details>
<summary>Підказка 2</summary>

Проблема з `INT_MIN`: значення `-2147483648` не можна просто помножити на `-1`, тому що `2147483648` не вміщується в `int` (максимум `2147483647`).

Рішення: обробляй `INT_MIN` окремо, наприклад:
```c
if (nb == -2147483648)
{
	write(1, "-2147483648", 11);
	return ;
}
```

</details>

<details>
<summary>Підказка 3 (повний алгоритм)</summary>

```c
void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| число | nombre | "Afficher un nombre" |
| від'ємний | négatif | "Un nombre négatif" |
| рекурсія | récursion | "Utiliser la récursion" |

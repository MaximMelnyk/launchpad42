---
id: p0_d05_ft_is_negative
module: p0
phase: phase0
title: "ft_is_negative"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["p0_d03_ft_putnbr"]
tags: ["c", "conditions", "if-else"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 11
---

# ft_is_negative

## Завдання

Напиши функцію `ft_is_negative`, яка перевіряє знак числа.

Функція виводить:
- `'N'` -- якщо число від'ємне
- `'P'` -- якщо число додатне або дорівнює нулю

### Прототип

```c
void	ft_is_negative(int n);
```

### Вимоги

- Використовуй `ft_putchar` для виводу
- Використовуй `if`/`else`
- НЕ використовуй тернарний оператор `?:` (заборонено Norminette)
- Файли: `ft_is_negative.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_is_negative(int n);
void	ft_putchar(char c);

int	main(void)
{
	ft_is_negative(-5);
	ft_is_negative(0);
	ft_is_negative(42);
	ft_is_negative(-2147483648);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
NPPN
```

## Підказки

<details>
<summary>Підказка 1</summary>

Умовний оператор `if`/`else` в C:
```c
if (n < 0)
	ft_putchar('N');
else
	ft_putchar('P');
```

</details>

## Man сторінки

- `man 2 write`

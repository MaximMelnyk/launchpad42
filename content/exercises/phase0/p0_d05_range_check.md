---
id: p0_d05_range_check
module: p0
phase: phase0
title: "Range Check"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["p0_d05_sign_checker"]
tags: ["c", "conditions", "return", "functions"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 13
---

# Range Check

## Завдання

Напиши функцію `ft_is_in_range`, яка перевіряє, чи знаходиться число у заданому діапазоні.

### Прототип

```c
int	ft_is_in_range(int value, int min, int max);
```

### Поведінка

- Повертає `1`, якщо `value >= min` **та** `value <= max`
- Повертає `0` в іншому випадку

### Вимоги

- Функція ПОВЕРТАЄ значення (return), а не виводить його
- Файли: `ft_is_in_range.c` + `ft_putchar.c` + `ft_putnbr.c`
- В `main.c` протестуй функцію та виведи результати
- Norminette: так

### Тестування

```c
int		ft_is_in_range(int value, int min, int max);
void	ft_putnbr(int nb);
void	ft_putchar(char c);

int	main(void)
{
	ft_putnbr(ft_is_in_range(5, 1, 10));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(0, 1, 10));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(10, 1, 10));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(-5, -10, -1));
	ft_putchar('\n');
	ft_putnbr(ft_is_in_range(100, 1, 10));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1
0
1
1
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Функція з поверненням значення використовує `return`:
```c
int	ft_is_in_range(int value, int min, int max)
{
	if (value >= min && value <= max)
		return (1);
	return (0);
}
```

</details>

<details>
<summary>Підказка 2</summary>

Логічний оператор `&&` (AND) означає "обидва повинні бути істинними". Вираз `value >= min && value <= max` перевіряє, що значення не менше мінімуму І не більше максимуму.

</details>

## Man сторінки

- `man 2 write`

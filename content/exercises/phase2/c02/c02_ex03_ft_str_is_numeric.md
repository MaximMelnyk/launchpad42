---
id: c02_ex03_ft_str_is_numeric
module: c02
phase: phase2
title: "ft_str_is_numeric"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: ["c02_ex02_ft_str_is_alpha"]
tags: ["c", "strings", "check"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 49
---

# ft_str_is_numeric

## Завдання

Напиши функцію `ft_str_is_numeric`, яка перевіряє, чи рядок складається тільки з цифр (0-9).

- Повертає `1`, якщо рядок містить тільки цифри
- Повертає `0`, якщо рядок містить хоча б один не-цифровий символ
- Порожній рядок (`""`) повертає `1`

Ця вправа дуже схожа на попередню -- просто зміни діапазон символів для перевірки.

### Прототип

```c
int	ft_str_is_numeric(char *str);
```

### Вимоги

- Дозволені функції: немає
- Повернути `1` або `0`
- Порожній рядок = `1`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_str_is_numeric.c`
- Norminette: так
- 42 Header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = n % 10 + '0';
	ft_putchar(c);
}

int	ft_str_is_numeric(char *str);

int	main(void)
{
	ft_putnbr(ft_str_is_numeric("12345"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_numeric("123a5"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_numeric(""));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_numeric("0"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_numeric("12 34"));
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

Символ є цифрою, якщо він знаходиться в діапазоні `'0'`-`'9'`. Це простіше, ніж літери -- тільки один діапазон!

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (str[i] < '0' || str[i] > '9')
		return (0);
	i++;
}
return (1);
```

</details>

## Man сторінки

- `man 3 isdigit`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| цифра | chiffre | "Vérifier si c'est un chiffre" |
| числовий | numérique | "Une chaîne numérique" |

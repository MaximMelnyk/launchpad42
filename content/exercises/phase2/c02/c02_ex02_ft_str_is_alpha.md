---
id: c02_ex02_ft_str_is_alpha
module: c02
phase: phase2
title: "ft_str_is_alpha"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c01_ex06_ft_strlen"]
tags: ["c", "strings", "check"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 48
---

# ft_str_is_alpha

## Завдання

Напиши функцію `ft_str_is_alpha`, яка перевіряє, чи рядок складається тільки з літер (a-z, A-Z).

- Повертає `1`, якщо рядок містить тільки літери
- Повертає `0`, якщо рядок містить хоча б один не-літерний символ
- Порожній рядок (`""`) повертає `1`

### Прототип

```c
int	ft_str_is_alpha(char *str);
```

### Вимоги

- Дозволені функції: немає
- Повернути `1` або `0`
- Порожній рядок = `1`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_str_is_alpha.c`
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

int	ft_str_is_alpha(char *str);

int	main(void)
{
	ft_putnbr(ft_str_is_alpha("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_alpha("Hello42"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_alpha(""));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_alpha("abc def"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_alpha("abcDEFghi"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1
0
1
0
1
```

## Підказки

<details>
<summary>Підказка 1</summary>

Символ є літерою, якщо він знаходиться в діапазоні `'a'`-`'z'` АБО `'A'`-`'Z'`. Перевір кожен символ рядка. Якщо хоча б один не є літерою -- повертай `0`.

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (!((str[i] >= 'a' && str[i] <= 'z')
			|| (str[i] >= 'A' && str[i] <= 'Z')))
		return (0);
	i++;
}
return (1);
```

</details>

## Man сторінки

- `man 3 isalpha`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| літера | lettre | "Vérifier si c'est une lettre" |
| перевірка | vérification | "La vérification du string" |

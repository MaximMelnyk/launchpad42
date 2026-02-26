---
id: c02_ex01_ft_strncpy
module: c02
phase: phase2
title: "ft_strncpy"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c02_ex00_ft_strcpy"]
tags: ["c", "strings", "copy"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 47
---

# ft_strncpy

## Завдання

Напиши функцію `ft_strncpy`, яка копіює щонайбільше `n` символів з рядка `src` у буфер `dest`.

Правила (як у стандартній `strncpy`):

- Якщо довжина `src` менша за `n`, решта `dest` заповнюється символами `'\0'`
- Якщо довжина `src` дорівнює або перевищує `n`, `dest` НЕ буде завершений `'\0'`

Функція повертає вказівник на `dest`.

### Прототип

```c
char	*ft_strncpy(char *dest, char *src, unsigned int n);
```

### Вимоги

- Дозволені функції: немає
- Скопіювати щонайбільше `n` символів із `src` у `dest`
- Якщо `src` коротший за `n` -- доповнити `'\0'` до `n` символів
- Повернути вказівник на `dest`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_strncpy.c`
- Norminette: так
- 42 Header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
	{
		ft_putchar(str[i]);
		i++;
	}
}

void	ft_putnbr(int n)
{
	char	c;

	if (n < 0)
	{
		ft_putchar('-');
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	c = n % 10 + '0';
	ft_putchar(c);
}

char	*ft_strncpy(char *dest, char *src, unsigned int n);

int	main(void)
{
	char	dest[20];
	int		i;

	ft_strncpy(dest, "Hello", 10);
	ft_putstr(dest);
	ft_putchar('\n');
	i = 5;
	while (i < 10)
	{
		ft_putnbr(dest[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	ft_strncpy(dest, "Hello, World!", 5);
	i = 0;
	while (i < 5)
	{
		ft_putchar(dest[i]);
		i++;
	}
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hello
0 0 0 0 0
Hello
```

## Підказки

<details>
<summary>Підказка 1</summary>

Тобі потрібні два цикли `while`: перший копіює символи з `src` (поки не зустрінеш `'\0'` або `i >= n`), другий доповнює решту `'\0'` (поки `i < n`).

</details>

<details>
<summary>Підказка 2</summary>

```c
unsigned int	i;

i = 0;
while (src[i] != '\0' && i < n)
{
	dest[i] = src[i];
	i++;
}
while (i < n)
{
	dest[i] = '\0';
	i++;
}
return (dest);
```

</details>

## Man сторінки

- `man 3 strncpy`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| доповнити | remplir / compléter | "Remplir avec des zéros" |
| довжина | longueur | "La longueur de la chaîne" |

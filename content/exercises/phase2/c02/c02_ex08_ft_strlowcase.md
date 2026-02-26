---
id: c02_ex08_ft_strlowcase
module: c02
phase: phase2
title: "ft_strlowcase"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: ["c02_ex07_ft_strupcase"]
tags: ["c", "strings", "case"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 54
---

# ft_strlowcase

## Завдання

Напиши функцію `ft_strlowcase`, яка перетворює всі великі літери (A-Z) рядка на малі (a-z) прямо на місці (in-place).

Символи, що не є великими літерами, залишаються без змін.

Функція повертає вказівник на `str`.

### Прототип

```c
char	*ft_strlowcase(char *str);
```

### Вимоги

- Дозволені функції: немає
- Перетворити тільки великі літери (A-Z) на малі (a-z)
- Інші символи не змінювати
- Модифікувати рядок на місці (in-place)
- Повернути вказівник на `str`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_strlowcase.c`
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

char	*ft_strlowcase(char *str);

int	main(void)
{
	char	s1[] = "Hello, World!";
	char	s2[] = "ABC123DEF";
	char	s3[] = "already low";
	char	s4[] = "";

	ft_putstr(ft_strlowcase(s1));
	ft_putchar('\n');
	ft_putstr(ft_strlowcase(s2));
	ft_putchar('\n');
	ft_putstr(ft_strlowcase(s3));
	ft_putchar('\n');
	ft_putstr(ft_strlowcase(s4));
	ft_putstr("END\n");
	return (0);
}
```

### Очікуваний результат

```
hello, world!
abc123def
already low
END
```

## Підказки

<details>
<summary>Підказка 1</summary>

Дзеркальна логіка до `ft_strupcase`: якщо символ є великою літерою (`'A'-'Z'`), додавай 32 (або `'a' - 'A'`).

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (str[i] >= 'A' && str[i] <= 'Z')
		str[i] = str[i] + 32;
	i++;
}
return (str);
```

</details>

## Man сторінки

- `man 3 tolower`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| малі літери | minuscules | "Convertir en minuscules" |
| протилежний | opposé / inverse | "L'opération inverse de strupcase" |

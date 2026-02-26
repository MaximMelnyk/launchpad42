---
id: c02_ex07_ft_strupcase
module: c02
phase: phase2
title: "ft_strupcase"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c02_ex02_ft_str_is_alpha"]
tags: ["c", "strings", "case"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 53
---

# ft_strupcase

## Завдання

Напиши функцію `ft_strupcase`, яка перетворює всі малі літери (a-z) рядка на великі (A-Z) прямо на місці (in-place).

Символи, що не є малими літерами, залишаються без змін.

Функція повертає вказівник на `str`.

### Прототип

```c
char	*ft_strupcase(char *str);
```

### Вимоги

- Дозволені функції: немає
- Перетворити тільки малі літери (a-z) на великі (A-Z)
- Інші символи не змінювати
- Модифікувати рядок на місці (in-place)
- Повернути вказівник на `str`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_strupcase.c`
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

char	*ft_strupcase(char *str);

int	main(void)
{
	char	s1[] = "Hello, World!";
	char	s2[] = "abc123def";
	char	s3[] = "ALREADY UP";
	char	s4[] = "";

	ft_putstr(ft_strupcase(s1));
	ft_putchar('\n');
	ft_putstr(ft_strupcase(s2));
	ft_putchar('\n');
	ft_putstr(ft_strupcase(s3));
	ft_putchar('\n');
	ft_putstr(ft_strupcase(s4));
	ft_putstr("END\n");
	return (0);
}
```

### Очікуваний результат

```
HELLO, WORLD!
ABC123DEF
ALREADY UP
END
```

## Підказки

<details>
<summary>Підказка 1</summary>

В ASCII різниця між великою і малою літерою завжди `32`. Наприклад: `'a'` = 97, `'A'` = 65. Тому `'a' - 32 == 'A'`. Якщо символ є малою літерою, віднімай 32.

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (str[i] >= 'a' && str[i] <= 'z')
		str[i] = str[i] - 32;
	i++;
}
return (str);
```

Замість `- 32` можна писати `- ('a' - 'A')` -- це читабельніше.

</details>

## Man сторінки

- `man 3 toupper`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| великі літери | majuscules | "Convertir en majuscules" |
| на місці | sur place / in-place | "Modifier la chaîne sur place" |

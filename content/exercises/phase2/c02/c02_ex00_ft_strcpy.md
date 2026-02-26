---
id: c02_ex00_ft_strcpy
module: c02
phase: phase2
title: "ft_strcpy"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c01_ex05_ft_putstr"]
tags: ["c", "strings", "copy"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 46
---

# ft_strcpy

## Завдання

Напиши функцію `ft_strcpy`, яка копіює рядок `src` у буфер `dest`, включаючи термінальний символ `'\0'`.

Ця функція повторює поведінку стандартної функції `strcpy`. Рядок у C завжди закінчується нульовим символом. Твоя функція повинна скопіювати кожен символ з `src` у `dest`, поки не зустрінеш `'\0'`, і додати `'\0'` в кінці.

Функція повертає вказівник на `dest`.

### Прототип

```c
char	*ft_strcpy(char *dest, char *src);
```

### Вимоги

- Дозволені функції: немає (жодна стандартна функція не потрібна)
- Скопіювати весь рядок `src` у `dest`, включаючи `'\0'`
- Повернути вказівник на `dest`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_strcpy.c`
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

char	*ft_strcpy(char *dest, char *src);

int	main(void)
{
	char	src[] = "Hello, Piscine!";
	char	dest[50];
	char	empty_src[] = "";
	char	empty_dest[10];

	ft_strcpy(dest, src);
	ft_putstr(dest);
	ft_putchar('\n');
	ft_strcpy(empty_dest, empty_src);
	ft_putstr(empty_dest);
	ft_putstr("END\n");
	return (0);
}
```

### Очікуваний результат

```
Hello, Piscine!
END
```

## Підказки

<details>
<summary>Підказка 1</summary>

Починай з індексу `i = 0` і копіюй символи по одному: `dest[i] = src[i]`. Зупинись, коли `src[i]` стане `'\0'`. Не забудь скопіювати сам `'\0'` теж!

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (src[i] != '\0')
{
	dest[i] = src[i];
	i++;
}
dest[i] = '\0';
return (dest);
```

</details>

## Man сторінки

- `man 3 strcpy`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| копіювати | copier | "Copier une chaîne dans un buffer" |
| буфер | tampon / buffer | "Le buffer de destination" |

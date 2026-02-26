---
id: c07_ex00_ft_strdup
module: c07
phase: phase2
title: "ft_strdup"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c01_ex06_ft_strlen", "c02_ex00_ft_strcpy"]
tags: ["c", "malloc", "strings"]
norminette: true
man_pages: ["malloc", "strdup"]
multi_day: false
order: 85
---

# ft_strdup

## Завдання

Напиши функцію `ft_strdup`, яка дублює рядок у новій області пам'яті, виділеній за допомогою `malloc`.

**Ласкаво просимо в модуль C07 -- динамічна пам'ять!** До цього моменту ти працював тільки з масивами фіксованого розміру (стек). Тепер ти навчишся виділяти пам'ять під час виконання програми за допомогою `malloc`. Це фундаментальна навичка для Piscine та всього програмування на C.

`ft_strdup` -- класична точка входу в `malloc`: визнач довжину рядка, виділи пам'ять, скопіюй вміст. Поведінка повинна бути ідентичною стандартній `strdup` з libc.

### Прототип

```c
char	*ft_strdup(char *src);
```

### Вимоги

- Відтвори поведінку стандартної функції `strdup` (man 3 strdup)
- Виділи пам'ять за допомогою `malloc` для нового рядка (довжина + 1 для `'\0'`)
- Скопіюй вміст `src` у нову пам'ять
- Поверни вказівник на новий рядок
- Якщо `malloc` повертає `NULL` -- поверни `NULL`
- Дозволені функції: `malloc`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strdup`, `strncpy`, `strlcpy`
- Файл: `ft_strdup.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>
#include <stdlib.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);
char	*ft_strdup(char *src);

int	main(void)
{
	char	*dup1;
	char	*dup2;
	char	*dup3;

	dup1 = ft_strdup("Hello");
	ft_putstr(dup1);
	ft_putchar('\n');
	free(dup1);
	dup2 = ft_strdup("");
	ft_putstr(dup2);
	ft_putchar('\n');
	free(dup2);
	dup3 = ft_strdup("42 Piscine");
	ft_putstr(dup3);
	ft_putchar('\n');
	free(dup3);
	return (0);
}
```

### Очікуваний результат

```
Hello

42 Piscine
```

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм складається з трьох кроків:
1. Визнач довжину `src` (твоя `ft_strlen`)
2. Виділи `len + 1` байт за допомогою `malloc`
3. Скопіюй символи з `src` у нову пам'ять (твоя `ft_strcpy`)

</details>

<details>
<summary>Підказка 2</summary>

`malloc` повертає `void *` -- ти можеш привести його до `char *`:
```c
char	*dup;

dup = (char *)malloc(sizeof(char) * (len + 1));
if (!dup)
	return (NULL);
```

Не забудь скопіювати фінальний `'\0'`!

</details>

<details>
<summary>Підказка 3</summary>

Повна схема:
```c
char	*ft_strdup(char *src)
{
	char	*dup;
	int		len;
	int		i;

	len = 0;
	while (src[len])
		len++;
	dup = (char *)malloc(sizeof(char) * (len + 1));
	if (!dup)
		return (NULL);
	i = 0;
	while (src[i])
	{
		dup[i] = src[i];
		i++;
	}
	dup[i] = '\0';
	return (dup);
}
```

</details>

## Man сторінки

- `man 3 malloc`
- `man 3 strdup`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| виділити пам'ять | allouer de la mémoire | "Allouer de la mémoire avec malloc" |
| дублювати | dupliquer | "Dupliquer une chaine" |
| купа (heap) | tas | "La mémoire est allouee sur le tas" |
| звільнити | libérer | "Liberer la mémoire avec free" |

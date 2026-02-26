---
id: c08_ex04_ft_strs_to_tab
module: c08
phase: phase2
title: "ft_strs_to_tab"
difficulty: 3
xp: 40
estimated_minutes: 45
prerequisites: ["c08_ex03_ft_point_h", "c07_ex00_ft_strdup"]
tags: ["c", "struct", "malloc", "strings"]
norminette: true
man_pages: ["malloc", "write"]
multi_day: false
order: 101
---

# ft_strs_to_tab

## Завдання

Напиши функцію `ft_strs_to_tab`, яка перетворює масив рядків у масив структур `s_stock_str`, виділений за допомогою `malloc`.

**Тепер ти комбінуєш все, що вивчив:** структури (C08 ex03), динамічну пам'ять (C07), рядки (C02-C04). Функція отримує `ac` рядків і для кожного створює структуру з трьома полями: довжина рядка, вказівник на оригінал, та копія рядка через `malloc`.

Це типова задача Piscine -- працювати зі складними структурами даних, де кожен елемент містить і метадані (розмір), і дані (рядки).

### Прототип

```c
struct s_stock_str
{
	int		size;
	char	*str;
	char	*copy;
};

struct s_stock_str	*ft_strs_to_tab(int ac, char **av);
```

### Вимоги

- Функція виділяє масив з `ac + 1` структур типу `struct s_stock_str` (останній елемент -- sentinel з `str = NULL`)
- Для кожного рядка `av[i]`:
  - `size` = довжина рядка (без `'\0'`)
  - `str` = вказівник на оригінальний рядок `av[i]` (НЕ копія)
  - `copy` = дублікат рядка, виділений через `malloc` (аналог `ft_strdup`)
- Якщо будь-який `malloc` повертає `NULL` -- поверни `NULL`
- Дозволені функції: `malloc`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strdup`, `strlen`, `strcpy`
- Файли: `ft_strs_to_tab.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>
#include <stdlib.h>

struct s_stock_str
{
	int		size;
	char	*str;
	char	*copy;
};

struct s_stock_str	*ft_strs_to_tab(int ac, char **av);

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

void	ft_putnbr(int nb)
{
	char	c;

	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	struct s_stock_str	*tab;
	char				*args[] = {"Hello", "42", "Piscine"};
	int					i;

	tab = ft_strs_to_tab(3, args);
	if (!tab)
	{
		ft_putstr("malloc failed\n");
		return (1);
	}
	i = 0;
	while (i < 3)
	{
		ft_putstr(tab[i].str);
		ft_putchar(' ');
		ft_putnbr(tab[i].size);
		ft_putchar(' ');
		ft_putstr(tab[i].copy);
		ft_putchar('\n');
		free(tab[i].copy);
		i++;
	}
	free(tab);
	return (0);
}
```

```bash
gcc -Wall -Wextra -Werror -o test_strs main.c ft_strs_to_tab.c
./test_strs
```

### Очікуваний результат

```
Hello 5 Hello
42 2 42
Piscine 7 Piscine
```

## Підказки

<details>
<summary>Підказка 1</summary>

Почни з виділення масиву структур:

```c
struct s_stock_str	*tab;

tab = (struct s_stock_str *)malloc(sizeof(struct s_stock_str) * (ac + 1));
if (!tab)
    return (NULL);
/* ... fill ac elements ... */
tab[ac].str = 0;   /* sentinel: marks end of array */
```

`sizeof(struct s_stock_str)` повертає розмір однієї структури в байтах. Множиш на `ac + 1` -- виділяєш місце для всіх елементів + sentinel (маркер кінця). `tab[ac].str = 0` дозволяє `ft_show_tab` ітерувати `while (par[i].str)`.

</details>

<details>
<summary>Підказка 2</summary>

Для кожного рядка заповни три поля:

```c
i = 0;
while (i < ac)
{
    tab[i].size = ft_strlen(av[i]);    /* your own strlen */
    tab[i].str = av[i];                /* just pointer, NOT copy! */
    tab[i].copy = ft_strdup(av[i]);    /* your own strdup (malloc + copy) */
    if (!tab[i].copy)
        return (NULL);                 /* malloc failed */
    i++;
}
```

`tab[i].str = av[i]` -- це просто копіювання вказівника (8 байт). Обидва вказують на ТОЙ САМИЙ рядок. А `tab[i].copy` -- це НОВА пам'ять з копією вмісту.

</details>

<details>
<summary>Підказка 3</summary>

Допоміжні функції (напиши або скопіюй з попередніх вправ):

```c
int	ft_strlen(char *str)
{
    int	i;

    i = 0;
    while (str[i])
        i++;
    return (i);
}

char	*ft_strdup(char *src)
{
    char	*dup;
    int		len;
    int		i;

    len = ft_strlen(src);
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

Ці функції можуть бути в тому ж файлі `ft_strs_to_tab.c` (Norminette дозволяє до 5 функцій на файл).

</details>

## Man сторінки

- `man 3 malloc`
- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| масив структур | tableau de structures | "Allouer un tableau de structures" |
| розмір | taille | "La taille de la structure" |
| перетворити | convertir | "Convertir les arguments en structures" |
| виділити | allouer | "Allouer de la memoire pour chaque copie" |

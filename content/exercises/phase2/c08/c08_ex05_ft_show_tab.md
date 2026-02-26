---
id: c08_ex05_ft_show_tab
module: c08
phase: phase2
title: "ft_show_tab"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c08_ex04_ft_strs_to_tab"]
tags: ["c", "struct", "output"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 102
---

# ft_show_tab

## Завдання

Напиши функцію `ft_show_tab`, яка виводить вміст масиву структур `s_stock_str`, створеного функцією `ft_strs_to_tab`.

Це завершальна вправа модуля C08. Ти вже вмієш: створювати заголовні файли, писати макроси, визначати структури, виділяти масиви структур. Тепер -- вивести результат на екран. Для кожного елементу масиву виведи три рядки: оригінальний рядок (`str`), його довжину (`size`) як число, та копію (`copy`).

### Прототип

```c
struct s_stock_str
{
	int		size;
	char	*str;
	char	*copy;
};

void	ft_show_tab(struct s_stock_str *par);
```

### Вимоги

- Для кожного елементу масиву виведи (кожне на окремому рядку):
  1. `str` (оригінальний рядок) + `'\n'`
  2. `size` (довжина як число) + `'\n'`
  3. `copy` (копія рядка) + `'\n'`
- Кількість елементів визначається параметром -- функція повинна знати коли зупинитися. Для цього `ft_strs_to_tab` (ex04) повинна повертати масив, де кількість передається окремо, АБО ти використовуєш `ac` як глобальний розмір. У тестах ми передаємо `ac` через `main`.
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_show_tab.c`
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
void				ft_show_tab(struct s_stock_str *par);

int	main(int argc, char **argv)
{
	struct s_stock_str	*tab;

	tab = ft_strs_to_tab(argc, argv);
	if (tab)
		ft_show_tab(tab);
	return (0);
}
```

```bash
gcc -Wall -Wextra -Werror -o test_show main.c ft_strs_to_tab.c ft_show_tab.c
./test_show Hello 42 Piscine
```

### Очікуваний результат

```
./test_show
11
./test_show
Hello
5
Hello
42
2
42
Piscine
7
Piscine
```

Перший елемент -- це `argv[0]` (ім'я програми `./test_show`), потім аргументи.

## Підказки

<details>
<summary>Підказка 1</summary>

Тобі потрібні дві допоміжні функції: `ft_putstr` для рядків і `ft_putnbr` для числа.

```c
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
```

</details>

<details>
<summary>Підказка 2</summary>

`ft_putnbr` для виведення числа (тобі знадобиться для `size`):

```c
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
```

Потім основна функція:
```c
void	ft_show_tab(struct s_stock_str *par)
{
	int	i;

	i = 0;
	while (par[i].str)   // stop when str is NULL
	{
		ft_putstr(par[i].str);
		ft_putchar('\n');
		ft_putnbr(par[i].size);
		ft_putchar('\n');
		ft_putstr(par[i].copy);
		ft_putchar('\n');
		i++;
	}
}
```

</details>

<details>
<summary>Підказка 3</summary>

**Як дізнатися кількість елементів?** У Piscine subject оригінальна `ft_strs_to_tab` повертає масив з `ac + 1` елементами, де останній має `str = NULL` (sentinel value). Це як `'\0'` в кінці рядка -- маркер кінця.

Для цього зміни `ft_strs_to_tab`:
```c
// allocate ac + 1 structs (last one is sentinel)
tab = (struct s_stock_str *)malloc(sizeof(struct s_stock_str) * (ac + 1));
// ... fill ac elements ...
tab[ac].str = 0;   // sentinel: marks end of array
```

Тоді `ft_show_tab` ітерує `while (par[i].str)` -- поки `str` не NULL.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| вивести | afficher | "Afficher le contenu du tableau" |
| масив | tableau | "Parcourir le tableau de structures" |
| маркер кінця | sentinelle | "Le dernier element sert de sentinelle" |
| обходити | parcourir | "Parcourir avec une boucle while" |

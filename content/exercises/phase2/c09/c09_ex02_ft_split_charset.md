---
id: c09_ex02_ft_split_charset
module: c09
phase: phase2
title: "ft_split (charset)"
difficulty: 4
xp: 60
estimated_minutes: 120
prerequisites: ["c07_ex05_ft_split"]
tags: ["c", "malloc", "strings", "split"]
norminette: true
man_pages: ["malloc", "free"]
multi_day: true
order: 105
---

# ft_split (charset)

## Завдання

Напиши функцію `ft_split`, яка розбиває рядок на масив слів, де роздільником є **будь-який символ з набору charset**.

**Контекст Piscine:** Це C09 ex02 -- фінальна версія `ft_split`. У C07 ex05 ти вже писав `ft_split` з одним символом-роздільником (`char c`). Тут -- набір символів: кожен символ з `charset` вважається роздільником. Наприклад, `charset = " ,."` означає, що пробіл, кома та крапка -- всі роздільники.

**Різниця від C07 ft_split:**
- C07: `char **ft_split(char *str, char c)` -- один роздільник
- C09: `char **ft_split(char *str, char *charset)` -- набір роздільників

Якщо ти добре зробив C07 ft_split, тут потрібно лише замінити `c == delimiter` на перевірку "чи є `c` у `charset`".

**Рекомендовано:** 2 дні. День 1 -- адаптація з C07 + базові тести. День 2 -- edge cases + leak check.

### Прототип

```c
char	**ft_split(char *str, char *charset);
```

### Вимоги

- Розбий рядок `str` на масив слів, де роздільниками є БУДЬ-ЯКИЙ символ з `charset`
- Повертай `NULL`-terminated масив `char **`
- Кожне слово -- окремий `malloc`'ований рядок
- Множинні роздільники підряд -- пропускаються (не створюють порожніх слів)
- Порожній рядок або рядок лише з роздільників -- масив з одним `NULL`: `result[0] = NULL`
- Якщо `charset` порожній -- весь `str` це одне "слово" (немає роздільників)
- При помилці `malloc` -- звільни всю раніше виділену пам'ять, поверни `NULL`
- Дозволені функції: `write`, `malloc`, `free`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strtok`, `strsep`, `strstr`
- Файли: `ft_split.c`
- Norminette: так (max 25 рядків на функцію -- розбий на допоміжні!)
- 42 header: обов'язковий

### Алгоритм

Ключова відмінність -- функція `ft_is_in_charset`:

```c
int	ft_is_in_charset(char c, char *charset)
{
	int	i;

	i = 0;
	while (charset[i])
	{
		if (c == charset[i])
			return (1);
		i++;
	}
	return (0);
}
```

Решта алгоритму ідентична C07 ft_split:
1. `ft_count_words(str, charset)` -- порахувати слова
2. `malloc` масив `char **` на `(words + 1)` елементів
3. Для кожного слова: пропустити роздільники, знайти довжину, `malloc` + скопіювати
4. `result[words] = NULL`

### Тестування

```c
#include <unistd.h>
#include <stdlib.h>

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
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

char	**ft_split(char *str, char *charset);

void	print_split(char **result)
{
	int	i;

	i = 0;
	if (!result)
	{
		ft_putstr("NULL");
		ft_putchar('\n');
		return ;
	}
	while (result[i])
	{
		ft_putchar('[');
		ft_putstr(result[i]);
		ft_putchar(']');
		i++;
	}
	ft_putchar('\n');
	ft_putnbr(i);
	ft_putchar('\n');
}

void	free_split(char **result)
{
	int	i;

	if (!result)
		return ;
	i = 0;
	while (result[i])
	{
		free(result[i]);
		i++;
	}
	free(result);
}

int	main(void)
{
	char	**r;

	r = ft_split("hello world test", " ");
	print_split(r);
	free_split(r);
	r = ft_split("hello,world;test.done", ",;.");
	print_split(r);
	free_split(r);
	r = ft_split("***a**b***c**", "*");
	print_split(r);
	free_split(r);
	r = ft_split("  hello\tworld\nnew  ", " \t\n");
	print_split(r);
	free_split(r);
	r = ft_split("", "abc");
	print_split(r);
	free_split(r);
	r = ft_split("abcabc", "abc");
	print_split(r);
	free_split(r);
	r = ft_split("no-delimiters-here", "");
	print_split(r);
	free_split(r);
	return (0);
}
```

### Очікуваний результат

```
[hello][world][test]
3
[hello][world][test][done]
4
[a][b][c]
3
[hello][world][new]
3

0

0
[no-delimiters-here]
1
```

## Підказки

<details>
<summary>Підказка 1: Адаптація з C07</summary>

Якщо у тебе є працюючий `ft_split` з C07, заміни **всі** порівняння символів:

**C07 (один роздільник):**
```c
if (str[i] == c)
```

**C09 (набір роздільників):**
```c
if (ft_is_in_charset(str[i], charset))
```

Це єдина суттєва різниця. Всі допоміжні функції (`ft_count_words`, `ft_word_len`, `ft_extract_word`) залишаються тими самими за структурою -- тільки міняється тип перевірки.

</details>

<details>
<summary>Підказка 2: Edge case -- порожній charset</summary>

Якщо `charset` порожній (`charset[0] == '\0'`), жоден символ не є роздільником. Це означає, що весь рядок -- одне слово (якщо `str` не порожній).

Функція `ft_is_in_charset` автоматично це обробляє: цикл `while (charset[i])` не виконається жодного разу, і повернеться `0` (не є роздільником).

</details>

<details>
<summary>Підказка 3: Norminette та розбиття на функції</summary>

Зразковий розподіл на функції (кожна до 25 рядків):

1. `ft_is_in_charset` -- 8 рядків
2. `ft_count_words` -- 15 рядків
3. `ft_word_len` -- 8 рядків
4. `ft_get_word` -- 15 рядків (malloc + copy)
5. `ft_split` -- 20 рядків (main logic + cleanup)

Допоміжна для cleanup при malloc fail:
```c
static void	ft_free_all(char **arr, int count)
{
	int	i;

	i = 0;
	while (i < count)
	{
		free(arr[i]);
		i++;
	}
	free(arr);
}
```

</details>

## Man сторінки

- `man 3 malloc`
- `man 3 free`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| набір | ensemble / charset | "Le charset contient les caracteres séparateurs" |
| роздільник | séparateur / délimiteur | "Chaque caractere du charset est un séparateur" |
| розбити | decouper | "Decouper la chaine selon un ensemble de séparateurs" |
| масив | tableau | "Retourner un tableau de chaines" |
| витік пам'яті | fuite mémoire | "Pas de fuite mémoire en cas d'erreur malloc" |

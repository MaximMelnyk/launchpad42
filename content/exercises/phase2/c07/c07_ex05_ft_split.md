---
id: c07_ex05_ft_split
module: c07
phase: phase2
title: "ft_split"
difficulty: 5
xp: 80
estimated_minutes: 180
prerequisites: ["split_prep_03_word_array"]
tags: ["c", "strings", "malloc", "split"]
norminette: true
man_pages: ["malloc", "free"]
multi_day: true
order: 93
---

# ft_split

## Завдання

Напиши функцію `ft_split`, яка розбиває рядок на масив слів за набором символів-роздільників (charset).

**Це одна з найскладніших функцій Piscine.** На реальній Piscine `ft_split` -- "великий фільтр" (le grand filtre). Багато студентів застрягають саме тут. Якщо ти пройшов три scaffolding вправи (count_words, extract_word, word_array) -- у тебе вже є всі будівельні блоки.

**Різниця від scaffolding:** у попередніх вправах роздільником був один символ `char c`. Тут -- **набір символів** `char *charset`. Символ вважається роздільником, якщо він присутній будь-де у `charset`.

**Рекомендовано:** 2 дні. День 1 -- структура + базові тести. День 2 -- edge cases + leak-free.

### Прототип

```c
char	**ft_split(char *str, char *charset);
```

### Вимоги

- Розбий рядок `str` на масив слів, де роздільниками є БУДЬ-ЯКИЙ символ з `charset`
- Повертай `NULL`-terminated масив `char **`
- Кожне слово -- окремий `malloc`'ований рядок
- Множинні роздільники підряд -- пропускаються (не створюють порожніх слів)
- Порожній рядок або рядок з одних роздільників -- повертай масив з одним елементом `[NULL]` (тобто `malloc(sizeof(char *) * 1)` з `result[0] = NULL`)
- При помилці `malloc` -- звільни ВСЮ вже виділену пам'ять, поверни `NULL`
- Дозволені функції: `write`, `malloc`, `free`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strtok`, `strsep`
- Файли: `ft_split.c` (можна додати допоміжні функції у тому ж файлі)
- Norminette: так (max 25 рядків на функцію -- розбий на допоміжні!)
- 42 header: обов'язковий

### Алгоритм (рекомендований)

Розбий задачу на допоміжні функції:

1. **`ft_is_charset(char c, char *charset)`** -- перевіряє, чи є символ `c` роздільником
2. **`ft_count_words(char *str, char *charset)`** -- рахує кількість слів (ти вже це робив!)
3. **`ft_word_len(char *str, char *charset)`** -- довжина слова від поточної позиції
4. **`ft_extract_word(char *str, char *charset)`** -- витягує одне слово (malloc)
5. **`ft_split(char *str, char *charset)`** -- збирає все разом

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
	r = ft_split("***hello**world***test**", "*");
	print_split(r);
	free_split(r);
	r = ft_split("hello world\ttab", " \t");
	print_split(r);
	free_split(r);
	r = ft_split("", " ");
	print_split(r);
	free_split(r);
	r = ft_split("   ", " ");
	print_split(r);
	free_split(r);
	r = ft_split("one", " ");
	print_split(r);
	free_split(r);
	r = ft_split("a,b;c.d", ",;.");
	print_split(r);
	free_split(r);
	return (0);
}
```

### Очікуваний результат

```
[hello][world][test]
3
[hello][world][test]
3
[hello][world][tab]
3

0

0
[one]
1
[a][b][c][d]
4
```

## Підказки

<details>
<summary>Підказка 1: Загальна структура</summary>

Функція `ft_split` складається з трьох кроків:

1. **Порахувати слова** -- щоб знати, скільки пам'яті виділити під масив
2. **Виділити масив** -- `malloc(sizeof(char *) * (word_count + 1))` (+1 для `NULL`)
3. **Заповнити масив** -- для кожного слова: знайти початок, визначити довжину, `malloc` + скопіювати

```c
char	**ft_split(char *str, char *charset)
{
    char	**result;
    int		words;
    int		i;

    words = ft_count_words(str, charset);
    result = malloc(sizeof(char *) * (words + 1));
    if (!result)
        return (NULL);
    i = 0;
    while (i < words)
    {
        /* skip delimiters, extract word, store in result[i] */
        i++;
    }
    result[i] = NULL;
    return (result);
}
```

</details>

<details>
<summary>Підказка 2: Допоміжна ft_is_charset</summary>

Ця проста функція перевіряє, чи є символ у наборі роздільників:

```c
int	ft_is_charset(char c, char *charset)
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

Використовуй її скрізь замість `str[i] == c` -- це єдина різниця від scaffolding вправ.

</details>

<details>
<summary>Підказка 3: Заповнення масиву</summary>

Основний цикл у `ft_split`:

```c
i = 0;
while (i < words)
{
    while (*str && ft_is_charset(*str, charset))
        str++;
    result[i] = ft_extract_word(str, charset);
    if (!result[i])
    {
        /* malloc failed -- free everything */
        while (i > 0)
            free(result[--i]);
        free(result);
        return (NULL);
    }
    while (*str && !ft_is_charset(*str, charset))
        str++;
    i++;
}
```

Зверни увагу на **обробку помилки malloc**: якщо `ft_extract_word` поверне `NULL`, потрібно звільнити всі попередні слова та сам масив. Це важливий паттерн, який Moulinette перевіряє на Piscine.

</details>

<details>
<summary>Підказка 4: Norminette -- розбий на функції</summary>

Norminette дозволяє максимум 25 рядків у тілі функції. Якщо `ft_split` стає занадто великою -- виноси логіку:

- `ft_is_charset` -- перевірка символу
- `ft_count_words` -- підрахунок слів
- `ft_word_len` -- довжина слова
- `ft_get_word` -- malloc + copy одного слова
- `ft_free_all` -- звільнення всього масиву при помилці
- `ft_split` -- збирає все разом

Всі функції можуть бути в одному файлі `ft_split.c`. Норминетт дозволяє до 5 функцій на файл.

</details>

## Man сторінки

- `man 3 malloc`
- `man 3 free`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| розбити | decouper / splitter | "Decouper la chaine en mots" |
| великий фільтр | le grand filtre | "ft_split, c'est le grand filtre de la Piscine" |
| витік пам'яті | fuite memoire / memory leak | "Attention aux fuites memoire!" |
| виділити | allouer | "Allouer un tableau de pointeurs" |
| звільнити | liberer | "Liberer toute la memoire en cas d'erreur" |

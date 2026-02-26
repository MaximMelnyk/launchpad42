---
id: split_prep_01_count_words
module: c07
phase: phase2
title: "ft_count_words"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c07_ex00_ft_strdup"]
tags: ["c", "strings", "split_prep"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 90
---

# ft_count_words

## Завдання

Напиши функцію `ft_count_words`, яка рахує кількість "слів" у рядку, розділених одним конкретним символом-роздільником (delimiter).

Ця вправа -- перший крок до написання `ft_split`, однієї з найскладніших функцій Piscine. Замість того, щоб одразу розбивати рядок на масив, ти спочатку навчишся правильно рахувати слова. Це саме те, що тобі потрібно буде зробити в `ft_split` як перший крок (щоб знати, скільки пам'яті виділити під масив).

**Визначення "слова":** послідовність символів, що НЕ є роздільником. Декілька роздільників підряд не створюють порожніх слів -- вони просто пропускаються.

### Прототип

```c
int	ft_count_words(char *str, char c);
```

### Вимоги

- Поверни кількість слів у рядку `str`, де `c` -- символ-роздільник
- Порожній рядок (`""`) -- повертає `0`
- Рядок з одних роздільників (`"   "` при `c = ' '`) -- повертає `0`
- Множинні роздільники підряд -- не створюють порожніх слів
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_count_words.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
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

int	ft_count_words(char *str, char c);

int	main(void)
{
	ft_putnbr(ft_count_words("hello world test", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("   ", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("  hello  world  ", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("one", ' '));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("a,b,,c,,,d", ','));
	ft_putchar('\n');
	ft_putnbr(ft_count_words("no-delimiters-here", ' '));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
3
0
0
2
1
4
1
```

## Підказки

<details>
<summary>Підказка 1</summary>

Основна ідея: ти проходиш по рядку символ за символом. Кожного разу, коли ти переходиш з роздільника на не-роздільник -- це початок нового слова, і ти збільшуєш лічильник.

Подумай про це як про "стан": ти або всередині слова, або зовні. Коли переходиш із "зовні" в "всередині" -- лічильник `++`.

</details>

<details>
<summary>Підказка 2</summary>

Один з підходів -- використати змінну `in_word` (0 або 1):

```c
count = 0;
i = 0;
while (str[i])
{
    if (str[i] != c && (i == 0 || str[i - 1] == c))
        count++;
    i++;
}
```

Тут ми рахуємо слово тільки коли поточний символ НЕ роздільник, а попередній -- роздільник (або це початок рядка).

</details>

<details>
<summary>Підказка 3</summary>

Альтернативний підхід з двома вкладеними `while`:

```c
count = 0;
i = 0;
while (str[i])
{
    while (str[i] && str[i] == c)
        i++;
    if (str[i])
        count++;
    while (str[i] && str[i] != c)
        i++;
}
```

Перший внутрішній `while` пропускає роздільники, другий -- пропускає символи слова. Цей підхід ближче до того, що тобі знадобиться у `ft_split`.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| рахувати | compter | "Compter les mots dans la chaine" |
| слово | mot | "Combien de mots dans cette phrase?" |
| роздільник | delimiteur / separateur | "Le delimiteur est un espace" |
| рядок | chaine | "Parcourir la chaine caractere par caractere" |

---
id: split_prep_02_extract_word
module: c07
phase: phase2
title: "ft_extract_word"
difficulty: 3
xp: 40
estimated_minutes: 40
prerequisites: ["split_prep_01_count_words"]
tags: ["c", "strings", "malloc", "split_prep"]
norminette: true
man_pages: ["malloc", "write"]
multi_day: false
order: 91
---

# ft_extract_word

## Завдання

Напиши функцію `ft_extract_word`, яка витягує перше слово з рядка (пропускаючи початкові роздільники) та повертає його як новий рядок, виділений через `malloc`.

Це другий крок підготовки до `ft_split`. Тут ти вчишся виділяти пам'ять під одне слово та копіювати його. У `ft_split` тобі потрібно буде робити це в циклі для кожного слова.

**Визначення:** слово -- послідовність символів, що НЕ є роздільником `c`. Роздільники на початку рядка пропускаються.

### Прототип

```c
char	*ft_extract_word(char *str, char c);
```

### Вимоги

- Пропусти всі початкові роздільники (`c`) на початку рядка
- Знайди перше слово (послідовність символів, що не є `c`)
- Виділи пам'ять (`malloc`) під це слово + `'\0'`
- Скопіюй символи слова в новий рядок
- Поверни вказівник на новий рядок
- Якщо `malloc` не вдалося -- поверни `NULL`
- Якщо рядок порожній або містить тільки роздільники -- поверни порожній рядок `""` (malloc 1 байт для `'\0'`)
- Дозволені функції: `write`, `malloc`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strncpy`, `strdup`
- Файл: `ft_extract_word.c`
- Norminette: так
- 42 header: обов'язковий

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

char	*ft_extract_word(char *str, char c);

int	main(void)
{
	char	*word;

	word = ft_extract_word("hello world", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("  hello world", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word(",,first,,second", ',');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("oneword", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("   ", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	word = ft_extract_word("", ' ');
	ft_putstr(word);
	ft_putchar('\n');
	free(word);
	return (0);
}
```

### Очікуваний результат

```
hello
hello
first
oneword


```

Зверни увагу: останні два рядки -- порожні рядки (порожній вивід + `'\n'`).

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм складається з 4 кроків:

1. **Пропусти роздільники:** `while (*str && *str == c) str++;`
2. **Визнач довжину слова:** рахуй символи до наступного роздільника або кінця рядка
3. **Виділи пам'ять:** `malloc(word_len + 1)` (не забудь `+1` для `'\0'`!)
4. **Скопіюй символи:** простий цикл `while` для копіювання

</details>

<details>
<summary>Підказка 2</summary>

Для визначення довжини слова:

```c
len = 0;
while (str[len] && str[len] != c)
    len++;
```

Для копіювання:

```c
word = malloc(len + 1);
if (!word)
    return (NULL);
i = 0;
while (i < len)
{
    word[i] = str[i];
    i++;
}
word[i] = '\0';
```

</details>

<details>
<summary>Підказка 3</summary>

Для випадку, коли слів немає (порожній рядок або тільки роздільники):

```c
/* After skipping delimiters, if we're at '\0', no word found */
if (*str == '\0')
{
    word = malloc(1);
    if (!word)
        return (NULL);
    word[0] = '\0';
    return (word);
}
```

Це важливий edge case -- завжди повертай валідний `malloc`'ований рядок, навіть якщо він порожній.

</details>

## Man сторінки

- `man 3 malloc`
- `man 3 free`
- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| витягнути | extraire | "Extraire le premier mot de la chaine" |
| виділити пам'ять | allouer de la mémoire | "Allouer de la mémoire avec malloc" |
| копіювати | copier | "Copier les caracteres un par un" |
| звільнити | libérer | "Liberer la mémoire avec free" |

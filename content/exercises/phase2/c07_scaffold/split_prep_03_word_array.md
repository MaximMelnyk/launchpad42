---
id: split_prep_03_word_array
module: c07
phase: phase2
title: "ft_word_array"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["split_prep_02_extract_word"]
tags: ["c", "strings", "malloc", "split_prep"]
norminette: true
man_pages: ["malloc", "write"]
multi_day: false
order: 92
---

# ft_word_array

## Завдання

Напиши функцію `ft_word_array`, яка розбиває рядок на масив з **рівно двох** слів за першим роздільником. Повертає `char **` з `[word1, word2, NULL]`.

Це фінальний підготовчий крок перед `ft_split`. Тут ти вчишся працювати з **подвійним вказівником** (`char **`) -- масивом рядків. Ти виділяєш пам'ять під масив вказівників, потім під кожне слово окремо. Саме цю структуру використовує `ft_split`, тільки для довільної кількості слів.

**Спрощення:** ця функція обробляє тільки випадок з двома словами. Якщо слово одне -- `word2` буде порожнім рядком. Якщо слів немає -- повертай `NULL`.

### Прототип

```c
char	**ft_word_array(char *str, char c);
```

### Вимоги

- Знайди перше слово (до першого роздільника `c`) та друге слово (після роздільника)
- Виділи масив `char **` на 3 елементи: `[word1, word2, NULL]`
- Кожне слово -- окремий `malloc`'ований рядок
- Пропускай початкові та проміжні роздільники
- Якщо є тільки одне слово -- `word2 = ""` (malloc 1 байт)
- Якщо рядок порожній або тільки роздільники -- поверни `NULL`
- При помилці `malloc` -- звільни вже виділену пам'ять, поверни `NULL`
- Дозволені функції: `write`, `malloc`, `free`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_word_array.c`
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

char	**ft_word_array(char *str, char c);

int	main(void)
{
	char	**result;

	result = ft_word_array("hello world", ' ');
	if (result)
	{
		ft_putstr(result[0]);
		ft_putchar('|');
		ft_putstr(result[1]);
		ft_putchar('\n');
		free(result[0]);
		free(result[1]);
		free(result);
	}
	result = ft_word_array("  first  second  third", ' ');
	if (result)
	{
		ft_putstr(result[0]);
		ft_putchar('|');
		ft_putstr(result[1]);
		ft_putchar('\n');
		free(result[0]);
		free(result[1]);
		free(result);
	}
	result = ft_word_array("only", ' ');
	if (result)
	{
		ft_putstr(result[0]);
		ft_putchar('|');
		ft_putstr(result[1]);
		ft_putchar('\n');
		free(result[0]);
		free(result[1]);
		free(result);
	}
	result = ft_word_array("   ", ' ');
	if (result)
		ft_putstr("ERROR: should be NULL\n");
	else
		ft_putstr("NULL\n");
	return (0);
}
```

### Очікуваний результат

```
hello|world
first|second
only|
NULL
```

## Підказки

<details>
<summary>Підказка 1</summary>

Структура масиву `char **`:

```
result[0] --> "hello\0"   (malloc'd string)
result[1] --> "world\0"   (malloc'd string)
result[2] --> NULL         (sentinel, marks end of array)
```

Виділення масиву:
```c
result = malloc(sizeof(char *) * 3);
```

Це виділяє пам'ять під 3 вказівники (`char *`): два слова + `NULL`-термінатор.

</details>

<details>
<summary>Підказка 2</summary>

Алгоритм:

1. Пропусти початкові роздільники
2. Якщо `*str == '\0'` -- рядок порожній, поверни `NULL`
3. Знайди кінець першого слова (символи до `c` або `'\0'`)
4. Скопіюй перше слово в `result[0]` (malloc + copy)
5. Пропусти роздільники після першого слова
6. Скопіюй друге слово (або порожній рядок) в `result[1]`
7. `result[2] = NULL`

</details>

<details>
<summary>Підказка 3</summary>

Безпечний `malloc` з очищенням при помилці:

```c
result[0] = malloc(len1 + 1);
if (!result[0])
{
    free(result);
    return (NULL);
}
/* ... copy word1 ... */
result[1] = malloc(len2 + 1);
if (!result[1])
{
    free(result[0]);
    free(result);
    return (NULL);
}
```

Цей паттерн "free при помилці" потрібно буде узагальнити в `ft_split` -- якщо будь-який `malloc` провалиться, звільнити ВСЕ, що вже виділено.

</details>

## Man сторінки

- `man 3 malloc`
- `man 3 free`
- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| масив | tableau | "Un tableau de chaines de caracteres" |
| подвійний вказівник | double pointeur | "char ** est un double pointeur" |
| звільнити | liberer | "N'oublie pas de liberer la memoire" |
| порожній | vide | "Si la chaine est vide, retourne NULL" |

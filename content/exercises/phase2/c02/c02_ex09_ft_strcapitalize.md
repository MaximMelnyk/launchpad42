---
id: c02_ex09_ft_strcapitalize
module: c02
phase: phase2
title: "ft_strcapitalize"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c02_ex07_ft_strupcase"]
tags: ["c", "strings", "case"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 55
---

# ft_strcapitalize

## Завдання

Напиши функцію `ft_strcapitalize`, яка перетворює першу літеру кожного слова на велику, а решту -- на малі. Модифікація відбувається на місці (in-place).

**Правила визначення слова:**

- Слово -- це послідовність алфавітно-цифрових символів (a-z, A-Z, 0-9)
- Все, що не є алфавітно-цифровим, є роздільником слів (пробіл, кома, крапка, дефіс тощо)
- Перша **літера** (не цифра!) кожного слова стає великою
- Решта літер у слові стають малими
- Цифри не змінюються

Функція повертає вказівник на `str`.

### Прототип

```c
char	*ft_strcapitalize(char *str);
```

### Вимоги

- Дозволені функції: немає
- Слово = послідовність алфавітно-цифрових символів
- Перша літера слова -- велика, решта -- малі
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_strcapitalize.c`
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

char	*ft_strcapitalize(char *str);

int	main(void)
{
	char	s1[] = "salut, comment tu vas ? 42mots quarante-deux; cinquante+et+un";
	char	s2[] = "HELLO WORLD";
	char	s3[] = "a";
	char	s4[] = "";
	char	s5[] = "123abc 456DEF";

	ft_putstr(ft_strcapitalize(s1));
	ft_putchar('\n');
	ft_putstr(ft_strcapitalize(s2));
	ft_putchar('\n');
	ft_putstr(ft_strcapitalize(s3));
	ft_putchar('\n');
	ft_putstr(ft_strcapitalize(s4));
	ft_putstr(ft_strcapitalize(s5));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Salut, Comment Tu Vas ? 42mots Quarante-Deux; Cinquante+Et+Un
Hello World
A
123abc 456def
```

## Підказки

<details>
<summary>Підказка 1</summary>

Тобі потрібна допоміжна змінна (прапорець), яка показує, чи ти на початку нового слова. На початку рядка ти завжди "на початку слова". Після кожного не-алфавітно-цифрового символу наступний символ буде початком нового слова.

</details>

<details>
<summary>Підказка 2</summary>

Розбий задачу на частини:
1. Спочатку переведи весь рядок у малі літери (як `ft_strlowcase`)
2. Потім пройдись по рядку ще раз: якщо символ -- літера і попередній символ не є алфавітно-цифровим -- переведи цю літеру у велику

</details>

<details>
<summary>Підказка 3</summary>

Напиши допоміжну функцію (або використай прапорець):

```c
/* Check if character is alphanumeric */
int	ft_is_alnum(char c)
{
	return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
		|| (c >= '0' && c <= '9'));
}
```

Тоді в основній функції: якщо поточний символ -- літера і `i == 0` або попередній символ не алфавітно-цифровий, переведи в upper.

</details>

## Man сторінки

- `man 3 toupper`
- `man 3 tolower`
- `man 3 isalnum`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| слово | mot | "Le premier caractère de chaque mot" |
| прапорець | drapeau / flag | "Un flag pour le début du mot" |
| заголовна | majuscule | "Première lettre en majuscule" |

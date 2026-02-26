---
id: c03_ex00_ft_strcmp
module: c03
phase: phase2
title: "ft_strcmp"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c01_ex06_ft_strlen"]
tags: ["c", "strings", "compare"]
norminette: true
man_pages: ["strcmp"]
multi_day: false
order: 59
---

# ft_strcmp

## Завдання

Напиши функцію `ft_strcmp`, яка порівнює два рядки посимвольно.

Порівняння рядків -- одна з базових операцій на Piscine. Функція повертає різницю між першими символами, що не збігаються. Якщо рядки ідентичні -- повертає `0`.

Поведінка повинна бути ідентичною стандартній `strcmp` з libc.

### Прототип

```c
int	ft_strcmp(char *s1, char *s2);
```

### Вимоги

- Відтвори поведінку стандартної функції `strcmp` (man 3 strcmp)
- Повертай різницю значень перших символів, що відрізняються (як `unsigned char`)
- Якщо рядки ідентичні -- повертай `0`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strcmp`
- Файл: `ft_strcmp.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_strcmp(char *s1, char *s2);

int	main(void)
{
	ft_putnbr(ft_strcmp("abc", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", "abd"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abd", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("", ""));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", ""));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", "abcd"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
0
-1
1
0
97
-97
-100
```

## Підказки

<details>
<summary>Підказка 1</summary>

Ітеруй по обох рядках одночасно за допомогою одного індексу `i`. Зупиняйся, коли символи відрізняються АБО коли один із рядків закінчився (`'\0'`).

</details>

<details>
<summary>Підказка 2</summary>

Умова циклу:
```c
while (s1[i] && s1[i] == s2[i])
    i++;
```
Після циклу повертай різницю: `return (s1[i] - s2[i]);`

Важливо: порівняння йде як `unsigned char`, але для базової реалізації `s1[i] - s2[i]` працює коректно з ASCII.

</details>

## Man сторінки

- `man 3 strcmp`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| порівняти | comparer | "Comparer deux chaines" |
| рядок | chaine de caracteres | "Les chaines sont identiques" |
| різниця | difference | "Retourner la difference" |

---
id: c03_ex04_ft_strstr
module: c03
phase: phase2
title: "ft_strstr"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c03_ex00_ft_strcmp"]
tags: ["c", "strings", "search"]
norminette: true
man_pages: ["strstr"]
multi_day: false
order: 63
---

# ft_strstr

## Завдання

Напиши функцію `ft_strstr`, яка знаходить перше входження підрядка `to_find` в рядку `str`.

Пошук підрядка -- класична задача, яка тестує вміння працювати з вкладеними циклами та вказівниками. На Piscine ця вправа часто потрапляє на екзамени.

### Прототип

```c
char	*ft_strstr(char *str, char *to_find);
```

### Вимоги

- Відтвори поведінку стандартної функції `strstr` (man 3 strstr)
- Повертай вказівник на початок першого входження `to_find` в `str`
- Якщо `to_find` порожній (`""`) -- повертай `str`
- Якщо `to_find` не знайдено -- повертай `NULL` (значення `0`)
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strstr`, `strncmp`
- Файл: `ft_strstr.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);
char	*ft_strstr(char *str, char *to_find);

int	main(void)
{
	char	*result;

	result = ft_strstr("Hello World", "World");
	if (result)
		ft_putstr(result);
	else
		ft_putstr("(null)");
	ft_putchar('\n');
	result = ft_strstr("Hello World", "lo W");
	if (result)
		ft_putstr(result);
	else
		ft_putstr("(null)");
	ft_putchar('\n');
	result = ft_strstr("Hello World", "xyz");
	if (result)
		ft_putstr(result);
	else
		ft_putstr("(null)");
	ft_putchar('\n');
	result = ft_strstr("Hello World", "");
	if (result)
		ft_putstr(result);
	else
		ft_putstr("(null)");
	ft_putchar('\n');
	result = ft_strstr("aaabaaab", "aaab");
	if (result)
		ft_putstr(result);
	else
		ft_putstr("(null)");
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
World
lo World
(null)
Hello World
aaabaaab
```

## Підказки

<details>
<summary>Підказка 1</summary>

Використовуй два вкладені цикли:
- Зовнішній: ітерується по `str` (позиція `i`)
- Внутрішній: порівнює `str[i + j]` з `to_find[j]`

Якщо внутрішній цикл дійшов до кінця `to_find` -- знайшли!

</details>

<details>
<summary>Підказка 2</summary>

Не забудь перевірити `to_find[0] == '\0'` на початку -- порожній рядок завжди знаходиться.

Структура:
```c
i = 0;
while (str[i])
{
    j = 0;
    while (str[i + j] && to_find[j] && str[i + j] == to_find[j])
        j++;
    if (to_find[j] == '\0')
        return (str + i);
    i++;
}
```

</details>

<details>
<summary>Підказка 3</summary>

Часта помилка: забувають перевірити `str[i + j]` у внутрішньому циклі. Без цього можна вийти за межі рядка `str`. Також: повертай `str + i`, а не `&str[i]` -- обидва варіанти працюють, але перший чистіший.

</details>

## Man сторінки

- `man 3 strstr`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| підрядок | sous-chaine | "Chercher une sous-chaine" |
| входження | occurrence | "La premiere occurrence" |
| вкладений цикл | boucle imbriquee | "Utiliser des boucles imbriquees" |

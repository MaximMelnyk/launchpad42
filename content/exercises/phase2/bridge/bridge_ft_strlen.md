---
id: bridge_ft_strlen
module: bridge
phase: phase2
title: "ft_strlen"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["p0_d02_ft_putstr"]
tags: ["c", "strings", "basics"]
norminette: true
man_pages: ["write", "strlen"]
multi_day: false
order: 35
---

# ft_strlen

## Завдання

`ft_strlen` -- одна з найчастіше використовуваних функцій на Piscine. Вона потрібна для C02 (ft_strcpy, ft_strncpy), C03 (ft_strcat), і практично кожного проекту. Тому вивчи її зараз, до початку роботи з рядками.

Напиши функцію `ft_strlen`, яка повертає довжину рядка (без урахування термінуючого нуля `\0`).

### Прототип

```c
int	ft_strlen(char *str);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- НЕ використовуй стандартну `strlen` -- пиши свою
- Тільки цикл `while` (НЕ `for`)
- Повертай `int` (кількість символів до `\0`)
- Заголовок 42 header у кожному файлі
- Файли: `ft_strlen.c`, `main.c`, `ft_putchar.c`, `ft_putnbr.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_strlen(char *str);

int	main(void)
{
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("42 Paris Piscine"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("A"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
5
0
16
1
```

## Підказки

<details>
<summary>Підказка 1</summary>

Рядок у C -- це масив символів, що закінчується символом `\0` (нуль-термінатор). Наприклад, `"Hello"` у пам'яті = `{'H', 'e', 'l', 'l', 'o', '\0'}`. Довжина = 5, не 6.

</details>

<details>
<summary>Підказка 2</summary>

Пройди по рядку, поки не зустрінеш `\0`:
```c
int	ft_strlen(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
		i++;
	return (i);
}
```
Можна також написати через вказівник: `while (*str)`, але для початку індексний варіант простіший.

</details>

## Man сторінки

- `man 2 write`
- `man 3 strlen`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| довжина | longueur | "La longueur de la chaine" |
| рядок | chaine | "Une chaine de caracteres" |
| нуль-термінатор | terminateur nul | "Le caractere nul termine la chaine" |

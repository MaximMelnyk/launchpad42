---
id: c01_ex06_ft_strlen
module: c01
phase: phase2
title: "ft_strlen"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["bridge_ft_strlen"]
tags: ["c", "pointers", "strings"]
norminette: true
man_pages: ["write", "strlen"]
multi_day: false
order: 43
---

# ft_strlen

## Завдання

Це офіційна версія `ft_strlen` з модуля C01 Piscine. Ти вже реалізував цю функцію у bridge-вправі. Тепер зроби чисту submission-ready версію, яка пройде Moulinette.

Напиши функцію `ft_strlen`, яка повертає довжину рядка.

### Прототип

```c
int	ft_strlen(char *str);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- НЕ використовуй стандартну `strlen`
- Тільки цикл `while` (НЕ `for`)
- Рахуй символи до `\0` (нуль-термінатор не входить у довжину)
- Заголовок 42 header у кожному файлі
- Файл: `ft_strlen.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_strlen(char *str);

int	main(void)
{
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("42"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("abcdefghij"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("Piscine 42 Paris 2026"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
0
5
2
10
21
```

## Підказки

<details>
<summary>Підказка 1</summary>

Ти вже знаєш цю функцію з bridge_ft_strlen. Тут ключове -- зробити чисту версію для submission. Переконайся:
- Заголовок 42 header є
- Tabs для відступів (не пробіли)
- `return (i);` з дужками (Norminette)
- Не більше 25 рядків у тілі функції

</details>

<details>
<summary>Підказка 2</summary>

Два варіанти реалізації:

**Через індекс:**
```c
int	ft_strlen(char *str)
{
	int	i;

	i = 0;
	while (str[i])
		i++;
	return (i);
}
```

**Через вказівник:**
```c
int	ft_strlen(char *str)
{
	char	*start;

	start = str;
	while (*str)
		str++;
	return (str - start);
}
```

</details>

## Man сторінки

- `man 2 write`
- `man 3 strlen`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| довжина | longueur | "Retourner la longueur" |
| нуль-термінатор | caractère nul | "Compter jusqu'au caractère nul" |
| submission | rendu | "Preparer le rendu pour la Moulinette" |

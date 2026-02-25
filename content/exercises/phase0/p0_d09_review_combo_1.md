---
id: p0_d09_review_combo_1
module: p0
phase: phase0
title: "Review Combo 1"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["p0_d07_ft_print_reverse_alphabet"]
tags: ["c", "review", "functions", "format"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 20
---

# Review Combo 1

## Завдання

Об'єднай знання з Днів 1-7 в одну програму.

Напиши програму, яка виводить картку учня у такому форматі:

```
=== Student Card ===
Name: Maksym
Age: 17
Favorite letter: M
Status: READY
====================
```

### Вимоги

- Дані захардкожені (hardcoded) в `main`
- Використовуй ТІЛЬКИ свої функції: `ft_putchar`, `ft_putstr`, `ft_putnbr`
- НЕ використовуй `printf`
- Ім'я та літера -- через `ft_putstr` / `ft_putchar`
- Вік -- через `ft_putnbr`
- Статус `"READY"` -- через `ft_putstr`
- Файли: `main.c` + `ft_putchar.c` + `ft_putstr.c` + `ft_putnbr.c`
- Norminette: так
- Для лінії `=` використовуй функцію (або цикл) -- не рядковий літерал з 20 символів

### Бонусне завдання

Створи функцію `ft_print_line(char c, int len)`, яка виводить символ `c` повторений `len` разів. Використай її для ліній `===...===`.

### Очікуваний результат

```
=== Student Card ===
Name: Maksym
Age: 17
Favorite letter: M
Status: READY
====================
```

## Підказки

<details>
<summary>Підказка 1</summary>

Структура `main`:
```c
int	main(void)
{
	ft_putstr("=== Student Card ===\n");
	ft_putstr("Name: Maksym\n");
	ft_putstr("Age: ");
	ft_putnbr(17);
	ft_putchar('\n');
	ft_putstr("Favorite letter: ");
	ft_putchar('M');
	ft_putchar('\n');
	ft_putstr("Status: READY\n");
	ft_putstr("====================\n");
	return (0);
}
```

</details>

<details>
<summary>Підказка 2: бонусна функція</summary>

```c
void	ft_print_line(char c, int len)
{
	int	i;

	i = 0;
	while (i < len)
	{
		ft_putchar(c);
		i++;
	}
}
```

</details>

## Man сторінки

- `man 2 write`

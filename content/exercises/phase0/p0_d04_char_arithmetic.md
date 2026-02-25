---
id: p0_d04_char_arithmetic
module: p0
phase: phase0
title: "Char Arithmetic"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["p0_d04_char_codes"]
tags: ["c", "ascii", "char", "conditions"]
norminette: true
man_pages: ["write", "ascii"]
multi_day: false
order: 9
---

# Char Arithmetic

## Завдання

Навчися маніпулювати символами через арифметику ASCII кодів.

Напиши функцію `ft_to_upper`, яка перетворює малу літеру на велику. Якщо символ не є малою літерою, він повертається без змін.

### Прототип

```c
char	ft_to_upper(char c);
```

### Вимоги

- Перевіряй діапазон: `c >= 'a' && c <= 'z'`
- Перетворення: відніми 32 від ASCII коду (різниця між `'a'`(97) та `'A'`(65))
- Якщо символ не є малою літерою -- поверни його без змін
- НЕ використовуй `toupper` з бібліотеки
- Файли: `ft_to_upper.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
char	ft_to_upper(char c);
void	ft_putchar(char c);

int	main(void)
{
	char	*str;
	int		i;

	str = "Hello World 42!";
	i = 0;
	while (str[i] != '\0')
	{
		ft_putchar(ft_to_upper(str[i]));
		i++;
	}
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
HELLO WORLD 42!
```

## Підказки

<details>
<summary>Підказка 1</summary>

Малі літери в ASCII: `'a'` = 97, `'z'` = 122.
Великі літери: `'A'` = 65, `'Z'` = 90.
Різниця: 97 - 65 = 32.

Тому: `'a' - 32 == 'A'`, `'b' - 32 == 'B'`, і так далі.

</details>

<details>
<summary>Підказка 2</summary>

```c
char	ft_to_upper(char c)
{
	if (c >= 'a' && c <= 'z')
		return (c - 32);
	return (c);
}
```

Замість магічного числа `32` можна написати `c - ('a' - 'A')` -- це зрозуміліше.

</details>

## Man сторінки

- `man 2 write`
- `man ascii`

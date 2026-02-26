---
id: p0_d06_digit_printer
module: p0
phase: phase0
title: "ft_print_numbers"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["p0_d06_counter"]
tags: ["c", "while", "functions"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 17
---

# ft_print_numbers

## Завдання

Напиши функцію `ft_print_numbers`, яка виводить усі цифри від `0` до `9` у порядку зростання.

Це окрема функція (не `main`) -- вона знадобиться тобі на екзамені.

### Прототип

```c
void	ft_print_numbers(void);
```

### Вимоги

- Функція не приймає параметрів і нічого не повертає
- Виводить `"0123456789"` за допомогою `ft_putchar`
- Використовуй цикл `while`
- НЕ додавай `'\n'` в кінці (виклик без побічних ефектів)
- Файли: `ft_print_numbers.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_print_numbers(void);
void	ft_putchar(char c);

int	main(void)
{
	ft_print_numbers();
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
0123456789
```

## Підказки

<details>
<summary>Підказка 1</summary>

Цифри у ASCII розташовані послідовно: `'0'` = 48, `'1'` = 49, ..., `'9'` = 57.

Тому можна ітерувати символами:
```c
char	c;

c = '0';
while (c <= '9')
{
	ft_putchar(c);
	c++;
}
```

</details>

## Man сторінки

- `man 2 write`

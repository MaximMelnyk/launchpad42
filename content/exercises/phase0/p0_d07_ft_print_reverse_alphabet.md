---
id: p0_d07_ft_print_reverse_alphabet
module: p0
phase: phase0
title: "ft_print_reverse_alphabet"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["p0_d07_ft_print_alphabet"]
tags: ["c", "while", "alphabet", "functions"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 19
---

# ft_print_reverse_alphabet

## Завдання

Напиши функцію `ft_print_reverse_alphabet`, яка виводить алфавіт малими літерами у зворотному порядку.

### Прототип

```c
void	ft_print_reverse_alphabet(void);
```

### Вимоги

- Виводить `"zyxwvutsrqponmlkjihgfedcba"` за допомогою `ft_putchar`
- Використовуй цикл `while`
- НЕ використовуй цикл `for`
- НЕ додавай `'\n'` в кінці
- Файли: `ft_print_reverse_alphabet.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_print_reverse_alphabet(void);
void	ft_putchar(char c);

int	main(void)
{
	ft_print_reverse_alphabet();
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
zyxwvutsrqponmlkjihgfedcba
```

## Підказки

<details>
<summary>Підказка 1</summary>

Працюй у зворотному напрямку -- починай з `'z'` та зменшуй до `'a'`:

```c
char	c;

c = 'z';
while (c >= 'a')
{
	ft_putchar(c);
	c--;
}
```

Оператор `--` зменшує значення на 1.

</details>

## Man сторінки

- `man 2 write`

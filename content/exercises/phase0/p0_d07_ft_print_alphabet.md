---
id: p0_d07_ft_print_alphabet
module: p0
phase: phase0
title: "ft_print_alphabet"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["p0_d06_digit_printer"]
tags: ["c", "while", "alphabet", "functions"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 18
---

# ft_print_alphabet

## Завдання

Напиши функцію `ft_print_alphabet`, яка виводить алфавіт малими літерами у порядку зростання.

Ця функція -- класика першого тижня Piscine. Вона також часто з'являється на екзамені.

### Прототип

```c
void	ft_print_alphabet(void);
```

### Вимоги

- Виводить `"abcdefghijklmnopqrstuvwxyz"` за допомогою `ft_putchar`
- Використовуй цикл `while`
- НЕ використовуй цикл `for`
- НЕ додавай `'\n'` в кінці
- Файли: `ft_print_alphabet.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_print_alphabet(void);
void	ft_putchar(char c);

int	main(void)
{
	ft_print_alphabet();
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
abcdefghijklmnopqrstuvwxyz
```

## Підказки

<details>
<summary>Підказка 1</summary>

Малі літери в ASCII розташовані послідовно: `'a'` = 97, `'b'` = 98, ..., `'z'` = 122.

```c
char	c;

c = 'a';
while (c <= 'z')
{
	ft_putchar(c);
	c++;
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| алфавіт | alphabet | "Afficher l'alphabet" |
| мала літера | lettre minuscule | "Les lettres minuscules de a à z" |

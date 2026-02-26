---
id: c02_ex05_ft_str_is_uppercase
module: c02
phase: phase2
title: "ft_str_is_uppercase"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: ["c02_ex02_ft_str_is_alpha"]
tags: ["c", "strings", "check"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 51
---

# ft_str_is_uppercase

## Завдання

Напиши функцію `ft_str_is_uppercase`, яка перевіряє, чи рядок складається тільки з великих (uppercase) літер (A-Z).

- Повертає `1`, якщо рядок містить тільки великі літери
- Повертає `0`, якщо рядок містить хоча б один символ, що не є великою літерою
- Порожній рядок (`""`) повертає `1`

### Прототип

```c
int	ft_str_is_uppercase(char *str);
```

### Вимоги

- Дозволені функції: немає
- Повернути `1` або `0`
- Порожній рядок = `1`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_str_is_uppercase.c`
- Norminette: так
- 42 Header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int n)
{
	char	c;

	if (n >= 10)
		ft_putnbr(n / 10);
	c = n % 10 + '0';
	ft_putchar(c);
}

int	ft_str_is_uppercase(char *str);

int	main(void)
{
	ft_putnbr(ft_str_is_uppercase("HELLO"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_uppercase("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_uppercase(""));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_uppercase("ABC123"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_uppercase("ABCDEF"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1
0
1
0
1
```

## Підказки

<details>
<summary>Підказка 1</summary>

Ідентично до `ft_str_is_lowercase`, але перевіряй діапазон `'A'-'Z'` замість `'a'-'z'`.

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (str[i] < 'A' || str[i] > 'Z')
		return (0);
	i++;
}
return (1);
```

</details>

## Man сторінки

- `man 3 isupper`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| великі літери | majuscules | "Que des majuscules" |
| регістр | casse | "Changer la casse" |

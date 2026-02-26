---
id: c02_ex04_ft_str_is_lowercase
module: c02
phase: phase2
title: "ft_str_is_lowercase"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: ["c02_ex02_ft_str_is_alpha"]
tags: ["c", "strings", "check"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 50
---

# ft_str_is_lowercase

## Завдання

Напиши функцію `ft_str_is_lowercase`, яка перевіряє, чи рядок складається тільки з малих (lowercase) літер (a-z).

- Повертає `1`, якщо рядок містить тільки малі літери
- Повертає `0`, якщо рядок містить хоча б один символ, що не є малою літерою
- Порожній рядок (`""`) повертає `1`

### Прототип

```c
int	ft_str_is_lowercase(char *str);
```

### Вимоги

- Дозволені функції: немає
- Повернути `1` або `0`
- Порожній рядок = `1`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_str_is_lowercase.c`
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

int	ft_str_is_lowercase(char *str);

int	main(void)
{
	ft_putnbr(ft_str_is_lowercase("hello"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_lowercase("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_lowercase(""));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_lowercase("abc123"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_lowercase("abcdef"));
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

Якщо ти вже написав `ft_str_is_alpha`, тут тобі потрібно змінити тільки діапазон: замість `'a'-'z' || 'A'-'Z'` перевіряй тільки `'a'-'z'`.

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (str[i] < 'a' || str[i] > 'z')
		return (0);
	i++;
}
return (1);
```

</details>

## Man сторінки

- `man 3 islower`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| малі літери | minuscules | "Que des minuscules" |
| перевірити | vérifier | "Vérifier les caractères" |

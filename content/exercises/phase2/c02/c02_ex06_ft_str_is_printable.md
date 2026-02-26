---
id: c02_ex06_ft_str_is_printable
module: c02
phase: phase2
title: "ft_str_is_printable"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: ["c02_ex02_ft_str_is_alpha"]
tags: ["c", "strings", "check"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 52
---

# ft_str_is_printable

## Завдання

Напиши функцію `ft_str_is_printable`, яка перевіряє, чи рядок складається тільки з символів, що друкуються (printable characters).

Друковані символи -- це символи з ASCII-кодами від 32 (пробіл) до 126 (тильда `~`) включно.

- Повертає `1`, якщо всі символи друковані
- Повертає `0`, якщо хоча б один символ не друкований (наприклад, табуляція `'\t'` або символ нового рядка `'\n'`)
- Порожній рядок (`""`) повертає `1`

### Прототип

```c
int	ft_str_is_printable(char *str);
```

### Вимоги

- Дозволені функції: немає
- Друковані символи: ASCII 32-126 включно
- Повернути `1` або `0`
- Порожній рядок = `1`
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_str_is_printable.c`
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

int	ft_str_is_printable(char *str);

int	main(void)
{
	ft_putnbr(ft_str_is_printable("Hello World!"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_printable("Hello\tWorld"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_printable(""));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_printable("abc 123 !@#"));
	ft_putchar('\n');
	ft_putnbr(ft_str_is_printable("line\nbreak"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1
0
1
1
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Ключ -- знати, що друковані символи в ASCII мають коди від 32 до 126. Пробіл (код 32) -- друкований! А от `'\t'` (код 9) та `'\n'` (код 10) -- ні.

</details>

<details>
<summary>Підказка 2</summary>

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (str[i] < 32 || str[i] > 126)
		return (0);
	i++;
}
return (1);
```

</details>

## Man сторінки

- `man 3 isprint`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| друкований | imprimable | "Caractère imprimable" |
| символ | caractère | "Chaque caractère du string" |

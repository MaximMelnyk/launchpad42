---
id: c02_ex10_ft_strlcpy
module: c02
phase: phase2
title: "ft_strlcpy"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c02_ex01_ft_strncpy"]
tags: ["c", "strings", "safe"]
norminette: true
man_pages: ["strlcpy"]
multi_day: false
order: 56
---

# ft_strlcpy

## Завдання

Напиши функцію `ft_strlcpy`, яка копіює рядок `src` у `dest` безпечним способом (як BSD `strlcpy`).

**Правила:**

- Копіює щонайбільше `size - 1` символів із `src` у `dest`
- Завжди додає `'\0'` в кінці `dest` (якщо `size > 0`)
- Якщо `size == 0`, нічого не копіювати (але довжину `src` все одно повернути)
- Повертає довжину `src` (повну, не обрізану)

Це безпечніша альтернатива `strncpy`, тому що:
1. `dest` завжди буде NUL-terminated (якщо `size > 0`)
2. Повертає довжину `src`, щоб можна було перевірити, чи було усічення

### Прототип

```c
unsigned int	ft_strlcpy(char *dest, char *src, unsigned int size);
```

### Вимоги

- Дозволені функції: немає
- Завжди NUL-terminate `dest` (якщо `size > 0`)
- Повернути довжину `src`
- Якщо `size == 0`, нічого не копіювати
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_strlcpy.c`
- Norminette: так
- 42 Header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
	{
		ft_putchar(str[i]);
		i++;
	}
}

void	ft_putnbr(int n)
{
	char	c;

	if (n < 0)
	{
		ft_putchar('-');
		n = -n;
	}
	if (n >= 10)
		ft_putnbr(n / 10);
	c = n % 10 + '0';
	ft_putchar(c);
}

unsigned int	ft_strlcpy(char *dest, char *src, unsigned int size);

int	main(void)
{
	char			dest[20];
	unsigned int	ret;

	ret = ft_strlcpy(dest, "Hello", 20);
	ft_putstr(dest);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	ret = ft_strlcpy(dest, "Hello, World!", 6);
	ft_putstr(dest);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	ret = ft_strlcpy(dest, "Hello", 0);
	ft_putnbr(ret);
	ft_putchar('\n');
	ret = ft_strlcpy(dest, "", 5);
	ft_putstr(dest);
	ft_putstr("EMPTY ");
	ft_putnbr(ret);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hello 5
Hello 13
5
EMPTY 0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Спочатку порахуй довжину `src` (знадобиться для повернення). Потім копіюй символи, але не більше `size - 1`. В кінці постав `'\0'`. Не забудь обробити випадок `size == 0` окремо!

</details>

<details>
<summary>Підказка 2</summary>

```c
unsigned int	i;
unsigned int	src_len;

src_len = 0;
while (src[src_len] != '\0')
	src_len++;
if (size == 0)
	return (src_len);
i = 0;
while (src[i] != '\0' && i < size - 1)
{
	dest[i] = src[i];
	i++;
}
dest[i] = '\0';
return (src_len);
```

</details>

<details>
<summary>Підказка 3</summary>

Різниця між `strncpy` і `strlcpy`:
- `strncpy` може не поставити `'\0'` (якщо `src` довший за `n`)
- `strlcpy` завжди ставить `'\0'` (якщо `size > 0`)
- `strncpy` заповнює залишок нулями, `strlcpy` -- ні
- `strlcpy` повертає довжину `src`, `strncpy` повертає `dest`

</details>

## Man сторінки

- `man 3 strlcpy`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| безпечний | sécurisé / sûr | "Copie sécurisée de chaîne" |
| усічення | troncature | "Détecter la troncature avec la valeur de retour" |

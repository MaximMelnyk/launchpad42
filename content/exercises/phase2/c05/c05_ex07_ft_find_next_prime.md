---
id: c05_ex07_ft_find_next_prime
module: c05
phase: phase2
title: "ft_find_next_prime"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: ["c05_ex06_ft_is_prime"]
tags: ["c", "math", "prime"]
norminette: true
man_pages: []
multi_day: false
order: 78
---

# ft_find_next_prime

## Завдання

Напиши функцію `ft_find_next_prime`, яка повертає найменше просте число, яке більше або рівне `nb`.

Правила:
- Якщо `nb` вже просте -- поверни `nb`
- Якщо `nb <= 1` -- поверни `2` (найменше просте число)
- Інакше шукай наступне просте число, перевіряючи `nb`, `nb+1`, `nb+2`, ...

Ця вправа об'єднує попередню (`ft_is_prime`) з пошуком. Ти можеш використати свою функцію `ft_is_prime` (або переписати логіку заново).

### Прототип

```c
int	ft_find_next_prime(int nb);
```

### Вимоги

- Поверни найменше просте число `>= nb`
- Якщо `nb <= 1`, поверни `2`
- Дозволено використовувати свою функцію `ft_is_prime` (в тому ж файлі)
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `math.h`
- Файл: `ft_find_next_prime.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	ft_find_next_prime(int nb);

int	main(void)
{
	ft_putnbr(ft_find_next_prime(0));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(1));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(2));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(4));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(13));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(14));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(42));
	ft_putchar('\n');
	ft_putnbr(ft_find_next_prime(-10));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
2
2
2
5
13
17
43
2
```

## Підказки

<details>
<summary>Підказка 1</summary>

Якщо у тебе є функція `ft_is_prime`, рішення дуже просте:

```c
while (!ft_is_prime(nb))
    nb++;
return (nb);
```

Але не забудь обробити `nb <= 1` перед циклом.

</details>

<details>
<summary>Підказка 2</summary>

Можна написати обидві функції в одному файлі:

```c
int	ft_is_prime(int nb)
{
    /* ... (твоя реалізація з попередньої вправи) */
}

int	ft_find_next_prime(int nb)
{
    if (nb <= 2)
        return (2);
    while (!ft_is_prime(nb))
        nb++;
    return (nb);
}
```

</details>

<details>
<summary>Підказка 3</summary>

Оптимізація: після перевірки `2` можна перевіряти тільки непарні числа (`nb += 2`), бо парні числа (крім 2) не можуть бути простими. Але для цієї вправи лінійний перебір достатній.

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| наступне просте | prochain premier | "Trouver le prochain nombre premier" |
| більше або рівне | supérieur ou egal | "Le premier nombre premier supérieur ou egal a nb" |

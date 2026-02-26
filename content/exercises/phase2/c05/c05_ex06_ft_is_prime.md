---
id: c05_ex06_ft_is_prime
module: c05
phase: phase2
title: "ft_is_prime"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: ["c05_ex05_ft_sqrt"]
tags: ["c", "math", "prime"]
norminette: true
man_pages: []
multi_day: false
order: 77
---

# ft_is_prime

## Завдання

Напиши функцію `ft_is_prime`, яка перевіряє, чи є число простим (nombre premier).

**Просте число** -- це натуральне число більше за 1, яке ділиться тільки на 1 та на себе.

Правила:
- `0` та `1` -- НЕ прості
- Від'ємні числа -- НЕ прості
- `2` -- найменше просте число (і єдине парне)
- Для перевірки достатньо перебирати дільники від `2` до `sqrt(nb)` -- якщо жоден не ділить `nb` без остачі, число просте

**Оптимізація:** якщо жоден `i` від 2 до `i * i <= nb` не ділить `nb`, то `nb` просте. Це працює тому що якщо `nb = a * b`, то один з множників не перевищує `sqrt(nb)`.

### Прототип

```c
int	ft_is_prime(int nb);
```

### Вимоги

- Поверни `1` якщо `nb` просте, `0` інакше
- `0` та `1` -- не прості, від'ємні -- не прості
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `sqrt`, `math.h`
- Файл: `ft_is_prime.c`
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

int	ft_is_prime(int nb);

int	main(void)
{
	ft_putnbr(ft_is_prime(0));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(1));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(2));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(3));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(4));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(5));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(13));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(42));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(2147483647));
	ft_putchar('\n');
	ft_putnbr(ft_is_prime(-7));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
0
0
1
1
0
1
1
0
1
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм перевірки простоти:
1. Якщо `nb <= 1`, поверни `0`
2. Перебирай `i` від `2` поки `i * i <= nb`
3. Якщо `nb % i == 0` -- число не просте (поверни `0`)
4. Якщо цикл завершився -- число просте (поверни `1`)

</details>

<details>
<summary>Підказка 2</summary>

```c
int	ft_is_prime(int nb)
{
    int	i;

    if (nb <= 1)
        return (0);
    i = 2;
    while (i * i <= nb)
    {
        if (nb % i == 0)
            return (0);
        i++;
    }
    return (1);
}
```

**Чому `i * i <= nb`?** Тому що якщо `nb = a * b`, то менший множник `<= sqrt(nb)`.

</details>

<details>
<summary>Підказка 3</summary>

Для дуже великих чисел (наприклад, `2147483647` -- це просте число Мерсенна) `i * i` може переповнити `int`. Безпечніше використовувати `(long)i * i <= nb` або `i <= nb / i`.

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| просте число | nombre premier | "2 est le plus petit nombre premier" |
| дільник | diviseur | "Chercher un diviseur de nb" |
| подільність | divisibilité | "Test de divisibilité par i" |

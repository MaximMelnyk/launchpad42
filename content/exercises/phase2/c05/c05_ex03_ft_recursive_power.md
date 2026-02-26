---
id: c05_ex03_ft_recursive_power
module: c05
phase: phase2
title: "ft_recursive_power"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c05_ex02_ft_iterative_power"]
tags: ["c", "math", "recursion"]
norminette: true
man_pages: []
multi_day: false
order: 74
---

# ft_recursive_power

## Завдання

Напиши функцію `ft_recursive_power`, яка обчислює `nb` у степені `power` **рекурсивно**.

Рекурсивне визначення степеня:
- Базовий випадок: `nb^0 = 1`
- Рекурсивний крок: `nb^power = nb * nb^(power-1)`

Наприклад: `2^4 = 2 * 2^3 = 2 * 2 * 2^2 = 2 * 2 * 2 * 2^1 = 2 * 2 * 2 * 2 * 2^0 = 16`

### Прототип

```c
int	ft_recursive_power(int nb, int power);
```

### Вимоги

- Обчисли `nb^power` рекурсивно (без циклів)
- Якщо `power < 0`, поверни `0`
- Якщо `power == 0`, поверни `1` (включно з `0^0 = 1`)
- Цикли НЕ потрібні -- використай рекурсію
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_recursive_power.c`
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

int	ft_recursive_power(int nb, int power);

int	main(void)
{
	ft_putnbr(ft_recursive_power(2, 0));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_power(0, 0));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_power(2, 10));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_power(3, 5));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_power(0, 5));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_power(2, -1));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_power(1, 100));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1
1
1024
243
0
0
1
```

## Підказки

<details>
<summary>Підказка 1</summary>

Структура рекурсивної функції степеня дуже схожа на рекурсивний факторіал:
1. Базовий випадок: `power == 0` -- поверни `1`
2. Рекурсивний крок: поверни `nb * ft_recursive_power(nb, power - 1)`

</details>

<details>
<summary>Підказка 2</summary>

Повна функція:

```c
int	ft_recursive_power(int nb, int power)
{
    if (power < 0)
        return (0);
    if (power == 0)
        return (1);
    return (nb * ft_recursive_power(nb, power - 1));
}
```

Зверни увагу: тут `nb` не змінюється -- зменшується лише `power`.

</details>

<details>
<summary>Підказка 3</summary>

Простежимо `ft_recursive_power(3, 3)`:
- `3 * ft_recursive_power(3, 2)`
- `3 * 3 * ft_recursive_power(3, 1)`
- `3 * 3 * 3 * ft_recursive_power(3, 0)`
- `3 * 3 * 3 * 1 = 27`

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| степінь | puissance | "Calculer la puissance recursivement" |
| рекурсія | recursion | "La recursion reduit le probleme" |

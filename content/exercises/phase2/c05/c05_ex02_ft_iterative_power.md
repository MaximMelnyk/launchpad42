---
id: c05_ex02_ft_iterative_power
module: c05
phase: phase2
title: "ft_iterative_power"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c05_ex00_ft_iterative_factorial"]
tags: ["c", "math", "iterative"]
norminette: true
man_pages: []
multi_day: false
order: 73
---

# ft_iterative_power

## Завдання

Напиши функцію `ft_iterative_power`, яка обчислює `nb` у степені `power` ітеративно.

Піднесення до степеня:
- `nb^power = nb * nb * ... * nb` (power разів)
- `nb^0 = 1` для будь-якого `nb` (включно з `0^0 = 1`)
- Від'ємний степінь -- повертай `0` (результат дробовий, не можна зберігти в `int`)

### Прототип

```c
int	ft_iterative_power(int nb, int power);
```

### Вимоги

- Обчисли `nb` у степені `power` за допомогою циклу `while`
- Якщо `power < 0`, поверни `0`
- Якщо `power == 0`, поверни `1`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_iterative_power.c`
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

int	ft_iterative_power(int nb, int power);

int	main(void)
{
	ft_putnbr(ft_iterative_power(2, 0));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(0, 0));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(2, 10));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(3, 5));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(0, 5));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(2, -1));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_power(1, 100));
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

Алгоритм аналогічний до ітеративного факторіалу:

```c
result = 1;
i = 0;
while (i < power)
{
    result = result * nb;
    i++;
}
```

Множимо `result` на `nb` рівно `power` разів.

</details>

<details>
<summary>Підказка 2</summary>

Крайові випадки:
- `power < 0` -- одразу `return (0);`
- `power == 0` -- одразу `return (1);` (навіть для `0^0`)
- Ці перевірки ставляться ДО циклу

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| степінь | puissance | "2 puissance 10 egale 1024" |
| піднесення | elevation | "Elevation a la puissance" |

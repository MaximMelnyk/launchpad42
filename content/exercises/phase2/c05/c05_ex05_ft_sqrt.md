---
id: c05_ex05_ft_sqrt
module: c05
phase: phase2
title: "ft_sqrt"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c05_ex02_ft_iterative_power"]
tags: ["c", "math", "search"]
norminette: true
man_pages: []
multi_day: false
order: 76
---

# ft_sqrt

## Завдання

Напиши функцію `ft_sqrt`, яка повертає цілий квадратний корінь числа.

Квадратний корінь (racine carrée) -- це число `r`, таке що `r * r == nb`.

Правила:
- Якщо `nb` -- точний квадрат (perfect square), поверни його корінь
- Якщо `nb` НЕ є точним квадратом, поверни `0`
- Якщо `nb <= 0`, поверни `0` (квадратний корінь з від'ємного числа та нуля)

**Підхід:** перебирай числа від `1` і перевіряй, чи `i * i == nb`. Зупинись, коли `i * i > nb`.

**Увага щодо переповнення (overflow):** при великих значеннях `nb` обчислення `i * i` може переповнити `int`. Використовуй `long` для перевірки, або порівнюй `i <= nb / i`.

### Прототип

```c
int	ft_sqrt(int nb);
```

### Вимоги

- Поверни точний квадратний корінь, або `0` якщо його немає
- Якщо `nb <= 0`, поверни `0`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `sqrt`, `pow`, `math.h`
- Файл: `ft_sqrt.c`
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

int	ft_sqrt(int nb);

int	main(void)
{
	ft_putnbr(ft_sqrt(0));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(1));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(4));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(25));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(100));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(2147395600));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(3));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(42));
	ft_putchar('\n');
	ft_putnbr(ft_sqrt(-4));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
0
1
2
5
10
46340
0
0
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Найпростіший підхід -- лінійний перебір:

```c
i = 1;
while (i * i < nb)
    i++;
if (i * i == nb)
    return (i);
return (0);
```

Але для великих чисел `i * i` може переповнити `int`.

</details>

<details>
<summary>Підказка 2</summary>

Щоб уникнути переповнення, замість `i * i <= nb` використай `i <= nb / i`:

```c
i = 1;
while (i <= nb / i)
{
    if (i * i == nb)
        return (i);
    i++;
}
return (0);
```

Або оголоси `long` для проміжного обчислення.

</details>

<details>
<summary>Підказка 3</summary>

Максимальний точний квадрат що вміщується в `int` (2147483647): `46340 * 46340 = 2147395600`. Тому `i` ніколи не перевищить `46340`.

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| квадратний корінь | racine carrée | "La racine carrée de 25 est 5" |
| точний квадрат | carré parfait | "25 est un carré parfait" |
| переповнення | dépassement | "Attention au dépassement d'entier" |

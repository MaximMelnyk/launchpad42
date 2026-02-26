---
id: c05_ex04_ft_fibonacci
module: c05
phase: phase2
title: "ft_fibonacci"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c05_ex01_ft_recursive_factorial"]
tags: ["c", "math", "recursion"]
norminette: true
man_pages: []
multi_day: false
order: 75
---

# ft_fibonacci

## Завдання

Напиши функцію `ft_fibonacci`, яка повертає `n`-те число послідовності Фібоначчі.

**Послідовність Фібоначчі** (suite de Fibonacci) -- одна з найвідоміших рекурсивних послідовностей у математиці:
- `fib(0) = 0`
- `fib(1) = 1`
- `fib(n) = fib(n-1) + fib(n-2)` для `n >= 2`

Перші числа: `0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...`

Ця задача -- класичний приклад рекурсії з **двома рекурсивними викликами**. На відміну від факторіалу (один виклик), тут функція викликає себе двічі на кожному кроці.

**Увага:** рекурсивне рішення повільне для великих `n` (подвійна рекурсія), але для цієї вправи це нормально.

### Прототип

```c
int	ft_fibonacci(int index);
```

### Вимоги

- Поверни число Фібоначчі з індексом `index`
- Якщо `index < 0`, поверни `-1`
- `fib(0) = 0`, `fib(1) = 1`
- Використовуй рекурсію
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_fibonacci.c`
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

int	ft_fibonacci(int index);

int	main(void)
{
	ft_putnbr(ft_fibonacci(0));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(1));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(2));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(7));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(10));
	ft_putchar('\n');
	ft_putnbr(ft_fibonacci(-3));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
0
1
1
13
55
-1
```

## Підказки

<details>
<summary>Підказка 1</summary>

У цій функції є **два базових випадки**:
1. `index == 0` -- поверни `0`
2. `index == 1` -- поверни `1`

І один рекурсивний крок:
- `return (ft_fibonacci(index - 1) + ft_fibonacci(index - 2));`

</details>

<details>
<summary>Підказка 2</summary>

Повна структура:

```c
int	ft_fibonacci(int index)
{
    if (index < 0)
        return (-1);
    if (index == 0)
        return (0);
    if (index == 1)
        return (1);
    return (ft_fibonacci(index - 1) + ft_fibonacci(index - 2));
}
```

</details>

<details>
<summary>Підказка 3</summary>

Розглянемо `ft_fibonacci(4)`:
```
fib(4) = fib(3) + fib(2)
fib(3) = fib(2) + fib(1) = (fib(1) + fib(0)) + 1 = (1 + 0) + 1 = 2
fib(2) = fib(1) + fib(0) = 1 + 0 = 1
fib(4) = 2 + 1 = 3
```

Зверни увагу: `fib(2)` обчислюється двічі. Для великих `n` це стає дуже повільним, але для цієї вправи це прийнятно.

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| послідовність | suite | "La suite de Fibonacci" |
| рекурсія | récursion | "Double récursion dans Fibonacci" |
| індекс | indice | "L'indice du nombre de Fibonacci" |

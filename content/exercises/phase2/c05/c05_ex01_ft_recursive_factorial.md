---
id: c05_ex01_ft_recursive_factorial
module: c05
phase: phase2
title: "ft_recursive_factorial"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c05_ex00_ft_iterative_factorial"]
tags: ["c", "math", "recursion"]
norminette: true
man_pages: []
multi_day: false
order: 72
---

# ft_recursive_factorial

## Завдання

Напиши функцію `ft_recursive_factorial`, яка обчислює факторіал числа **рекурсивно**.

**Рекурсія** (recursion) -- це коли функція викликає сама себе. Кожна рекурсивна функція має:
1. **Базовий випадок** (base case) -- умова зупинки, без якої рекурсія буде нескінченною
2. **Рекурсивний крок** -- виклик самої себе з "меншою" задачею

Для факторіалу:
- Базовий випадок: `0! = 1` (або `1! = 1`)
- Рекурсивний крок: `n! = n * (n-1)!`

Тобто `5! = 5 * 4!`, `4! = 4 * 3!`, ..., `1! = 1 * 0!`, `0! = 1`.

### Прототип

```c
int	ft_recursive_factorial(int nb);
```

### Вимоги

- Обчисли факторіал числа `nb` рекурсивно (без циклів)
- Якщо `nb < 0`, поверни `0`
- Якщо `nb == 0`, поверни `1`
- Цикли `while`/`for` НЕ потрібні -- використай рекурсію
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_recursive_factorial.c`
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

int	ft_recursive_factorial(int nb);

int	main(void)
{
	ft_putnbr(ft_recursive_factorial(0));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(1));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(5));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(10));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(-3));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1
1
120
3628800
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Рекурсивний факторіал -- це дуже короткий код. Подумай про два випадки:
1. Якщо `nb <= 0` -- поверни відповідне значення
2. Інакше -- поверни `nb * ft_recursive_factorial(nb - 1)`

</details>

<details>
<summary>Підказка 2</summary>

Структура функції:

```c
int	ft_recursive_factorial(int nb)
{
    if (nb < 0)
        return (0);
    if (nb == 0)
        return (1);
    return (nb * ft_recursive_factorial(nb - 1));
}
```

Зверни увагу: кожен виклик "зменшує" задачу на 1, поки не дійде до базового випадку `nb == 0`.

</details>

<details>
<summary>Підказка 3</summary>

Простежимо виконання для `ft_recursive_factorial(4)`:
- `4 * ft_recursive_factorial(3)`
- `4 * 3 * ft_recursive_factorial(2)`
- `4 * 3 * 2 * ft_recursive_factorial(1)`
- `4 * 3 * 2 * 1 * ft_recursive_factorial(0)`
- `4 * 3 * 2 * 1 * 1 = 24`

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| рекурсія | recursion / recursivite | "Une fonction recursive s'appelle elle-meme" |
| базовий випадок | cas de base | "Le cas de base arrete la recursion" |
| факторіал | factorielle | "La factorielle recursive de n" |

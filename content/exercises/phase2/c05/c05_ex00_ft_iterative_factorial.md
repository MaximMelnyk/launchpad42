---
id: c05_ex00_ft_iterative_factorial
module: c05
phase: phase2
title: "ft_iterative_factorial"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c04_ex03_ft_atoi"]
tags: ["c", "math", "iterative"]
norminette: true
man_pages: []
multi_day: false
order: 71
---

# ft_iterative_factorial

## Завдання

Напиши функцію `ft_iterative_factorial`, яка обчислює факторіал числа **ітеративно** (за допомогою циклу `while`).

Факторіал (factorial) числа `n` визначається як:
- `n! = 1 * 2 * 3 * ... * n`
- `0! = 1` (за визначенням)
- Факторіал від'ємного числа не визначений -- повертай `0`

Це перша вправа модуля C05, яка готує тебе до рекурсії. Спочатку розв'яжи задачу циклом -- потім у наступній вправі перепишеш її рекурсивно.

### Прототип

```c
int	ft_iterative_factorial(int nb);
```

### Вимоги

- Обчисли факторіал числа `nb` ітеративно (цикл `while`)
- Якщо `nb < 0`, поверни `0`
- Якщо `nb == 0`, поверни `1`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_iterative_factorial.c`
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

int	ft_iterative_factorial(int nb);

int	main(void)
{
	ft_putnbr(ft_iterative_factorial(0));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_factorial(1));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_factorial(5));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_factorial(10));
	ft_putchar('\n');
	ft_putnbr(ft_iterative_factorial(-3));
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

Почни зі змінної `result = 1`. У циклі множ `result` на лічильник, який збільшується від `1` до `nb`:

```c
result = 1;
i = 1;
while (i <= nb)
{
    result = result * i;
    i++;
}
```

</details>

<details>
<summary>Підказка 2</summary>

Не забудь обробити крайові випадки ДО циклу:
- `nb < 0` -- поверни `0` одразу
- `nb == 0` або `nb == 1` -- поверни `1` (але цикл і так дасть `1` для цих випадків, якщо `result` починається з `1`)

</details>

## Man сторінки

- Немає специфічних man сторінок для цієї вправи

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| факторіал | factorielle | "La factorielle de 5 est 120" |
| ітеративний | itératif | "Une solution iterative avec une boucle" |
| цикл | boucle | "Utilise une boucle while" |

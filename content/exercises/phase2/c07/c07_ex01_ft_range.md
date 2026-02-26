---
id: c07_ex01_ft_range
module: c07
phase: phase2
title: "ft_range"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["c07_ex00_ft_strdup"]
tags: ["c", "malloc", "arrays"]
norminette: true
man_pages: ["malloc"]
multi_day: false
order: 86
---

# ft_range

## Завдання

Напиши функцію `ft_range`, яка повертає масив цілих чисел від `min` до `max` (не включаючи `max`).

Тепер ти знаєш як виділяти пам'ять для рядків. Час навчитися виділяти масиви цілих чисел. Принцип той самий: визнач розмір, виклич `malloc`, заповни масив.

### Прототип

```c
int	*ft_range(int min, int max);
```

### Вимоги

- Поверни масив цілих чисел від `min` до `max - 1` (включно)
- Якщо `min >= max` -- поверни `NULL`
- Виділи пам'ять за допомогою `malloc`
- Якщо `malloc` повертає `NULL` -- поверни `NULL`
- Дозволені функції: `malloc`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_range.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>
#include <stdlib.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int		*ft_range(int min, int max);

int	main(void)
{
	int	*range;
	int	i;

	range = ft_range(0, 5);
	i = 0;
	while (i < 5)
	{
		ft_putnbr(range[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	free(range);
	range = ft_range(-3, 3);
	i = 0;
	while (i < 6)
	{
		ft_putnbr(range[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	free(range);
	range = ft_range(5, 5);
	if (range == NULL)
		write(1, "NULL\n", 5);
	range = ft_range(10, 3);
	if (range == NULL)
		write(1, "NULL\n", 5);
	return (0);
}
```

### Очікуваний результат

```
0 1 2 3 4
-3 -2 -1 0 1 2
NULL
NULL
```

## Підказки

<details>
<summary>Підказка 1</summary>

Розмір масиву: `max - min`. Виділяй `sizeof(int) * (max - min)` байтів.

</details>

<details>
<summary>Підказка 2</summary>

Заповнюй масив від `min`, збільшуючи на 1:
```c
i = 0;
while (i < max - min)
{
	range[i] = min + i;
	i++;
}
```

</details>

## Man сторінки

- `man 3 malloc`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| діапазон | plage / intervalle | "Creer un intervalle d'entiers" |
| масив | tableau | "Allouer un tableau dynamique" |
| розмір | taille | "La taille du tableau" |

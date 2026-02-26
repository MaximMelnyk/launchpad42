---
id: c07_ex02_ft_ultimate_range
module: c07
phase: phase2
title: "ft_ultimate_range"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c07_ex01_ft_range"]
tags: ["c", "malloc", "arrays", "pointers"]
norminette: true
man_pages: ["malloc"]
multi_day: false
order: 87
---

# ft_ultimate_range

## Завдання

Напиши функцію `ft_ultimate_range`, яка виділяє масив цілих чисел від `min` до `max` (не включаючи `max`) та повертає розмір масиву.

Ця вправа -- ускладнення `ft_range`. Різниця: масив передається через подвійний вказівник `int **range`, а функція повертає кількість елементів. Це типовий патерн на Piscine: повертай розмір через `return`, а дані -- через вказівник.

### Прототип

```c
int	ft_ultimate_range(int **range, int min, int max);
```

### Вимоги

- Виділи масив цілих чисел від `min` до `max - 1` (включно)
- Збережи вказівник на масив у `*range`
- Поверни кількість елементів (`max - min`)
- Якщо `min >= max` -- встанови `*range = NULL` та поверни `0`
- Якщо `malloc` повертає `NULL` -- встанови `*range = NULL` та поверни `-1`
- Дозволені функції: `malloc`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_ultimate_range.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>
#include <stdlib.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int		ft_ultimate_range(int **range, int min, int max);

int	main(void)
{
	int	*range;
	int	size;
	int	i;

	size = ft_ultimate_range(&range, 0, 10);
	ft_putnbr(size);
	ft_putchar('\n');
	i = 0;
	while (i < size)
	{
		ft_putnbr(range[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	free(range);
	size = ft_ultimate_range(&range, -3, 3);
	ft_putnbr(size);
	ft_putchar('\n');
	free(range);
	size = ft_ultimate_range(&range, 5, 5);
	ft_putnbr(size);
	ft_putchar('\n');
	size = ft_ultimate_range(&range, 10, 3);
	ft_putnbr(size);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
10
0 1 2 3 4 5 6 7 8 9
6
0
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Подвійний вказівник `int **range` дозволяє змінити значення `*range` всередині функції. Коли ти пишеш `*range = malloc(...)`, викликач отримує доступ до виділеної пам'яті через свій локальний `int *range`.

</details>

<details>
<summary>Підказка 2</summary>

Не забудь обробити три випадки:
1. `min >= max` -- `*range = NULL`, повертай `0`
2. `malloc` повернув `NULL` -- `*range = NULL`, повертай `-1`
3. Успіх -- заповни масив, повертай `max - min`

</details>

<details>
<summary>Підказка 3</summary>

Заповнення масиву ідентичне `ft_range`:
```c
size = max - min;
*range = (int *)malloc(sizeof(int) * size);
if (!(*range))
	return (-1);
i = 0;
while (i < size)
{
	(*range)[i] = min + i;
	i++;
}
return (size);
```

Зверни увагу на дужки: `(*range)[i]`, а НЕ `*range[i]`.

</details>

## Man сторінки

- `man 3 malloc`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| подвійний вказівник | double pointeur | "Passer un double pointeur" |
| виділення | allocation | "L'allocation a echoue" |
| розмір | taille | "Retourner la taille du tableau" |

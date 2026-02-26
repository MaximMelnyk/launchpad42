---
id: c01_ex07_ft_rev_int_tab
module: c01
phase: phase2
title: "ft_rev_int_tab"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c01_ex02_ft_swap", "bridge_arrays_int"]
tags: ["c", "pointers", "arrays"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 44
---

# ft_rev_int_tab

## Завдання

Напиши функцію `ft_rev_int_tab`, яка розвертає масив цілих чисел на місці (in-place). Це означає, що ти маєш змінити оригінальний масив, а не створювати новий.

Ця вправа комбінує знання масивів (bridge) та swap (C01 ex02). На Piscine це типова задача середньої складності, яка також з'являється на екзаменах.

### Прототип

```c
void	ft_rev_int_tab(int *tab, int size);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`)
- Розвертай масив НА МІСЦІ (in-place), без додаткового масиву
- Використай swap-логіку для обміну елементів
- Заголовок 42 header у кожному файлі
- Файл: `ft_rev_int_tab.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_rev_int_tab(int *tab, int size);

void	ft_print_tab(int *tab, int size)
{
	int	i;

	i = 0;
	while (i < size)
	{
		ft_putnbr(tab[i]);
		if (i < size - 1)
			ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
}

int	main(void)
{
	int	arr1[5];
	int	arr2[4];
	int	arr3[1];

	arr1[0] = 1;
	arr1[1] = 2;
	arr1[2] = 3;
	arr1[3] = 4;
	arr1[4] = 5;
	ft_print_tab(arr1, 5);
	ft_rev_int_tab(arr1, 5);
	ft_print_tab(arr1, 5);
	arr2[0] = 42;
	arr2[1] = 21;
	arr2[2] = 0;
	arr2[3] = -1;
	ft_print_tab(arr2, 4);
	ft_rev_int_tab(arr2, 4);
	ft_print_tab(arr2, 4);
	arr3[0] = 7;
	ft_rev_int_tab(arr3, 1);
	ft_print_tab(arr3, 1);
	return (0);
}
```

### Очікуваний результат

```
1 2 3 4 5
5 4 3 2 1
42 21 0 -1
-1 0 21 42
7
```

## Підказки

<details>
<summary>Підказка 1</summary>

Для розвороту масиву використай два індекси: один з початку (`i = 0`), інший з кінця (`j = size - 1`). Обмінюй елементи, поки `i < j`:
```
[1, 2, 3, 4, 5]
 ^           ^   swap(1, 5)
[5, 2, 3, 4, 1]
    ^     ^      swap(2, 4)
[5, 4, 3, 2, 1]
       ^         i >= j, stop
```

</details>

<details>
<summary>Підказка 2</summary>

Для swap використай тимчасову змінну:
```c
int	tmp;

tmp = tab[i];
tab[i] = tab[j];
tab[j] = tmp;
```
Або використай свою функцію `ft_swap` з попередньої вправи: `ft_swap(&tab[i], &tab[j]);`

</details>

<details>
<summary>Підказка 3</summary>

Повна структура:
```c
void	ft_rev_int_tab(int *tab, int size)
{
	int	i;
	int	j;
	int	tmp;

	i = 0;
	j = size - 1;
	while (i < j)
	{
		tmp = tab[i];
		tab[i] = tab[j];
		tab[j] = tmp;
		i++;
		j--;
	}
}
```
5 рядків у тілі while + 5 рядків ініціалізації = добре в межах 25-рядкового ліміту Norminette.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| розвернути | inverser | "Inverser le tableau" |
| на місці | en place | "Modifier le tableau en place" |
| обмін | echange | "Echanger les elements" |

---
id: c01_ex08_ft_sort_int_tab
module: c01
phase: phase2
title: "ft_sort_int_tab"
difficulty: 3
xp: 40
estimated_minutes: 45
prerequisites: ["c01_ex07_ft_rev_int_tab"]
tags: ["c", "pointers", "arrays", "sorting"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 45
---

# ft_sort_int_tab

## Завдання

Напиши функцію `ft_sort_int_tab`, яка сортує масив цілих чисел за зростанням (ascending order). Сортування має відбуватись на місці (in-place).

Це найскладніша вправа модуля C01. Вона вимагає розуміння циклів, масивів та swap-логіки. На Piscine сортування з'являється в екзаменах рівня 2+.

Рекомендований алгоритм: bubble sort (бульбашкове сортування) -- найпростіший для реалізації в рамках Norminette.

### Прототип

```c
void	ft_sort_int_tab(int *tab, int size);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`)
- Сортуй за зростанням (від найменшого до найбільшого)
- Сортуй НА МІСЦІ (in-place)
- Алгоритм: bubble sort або selection sort
- Заголовок 42 header у кожному файлі
- Файл: `ft_sort_int_tab.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_sort_int_tab(int *tab, int size);

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
	int	a[5];
	int	b[3];
	int	c[1];
	int	d[6];

	a[0] = 5;
	a[1] = 3;
	a[2] = 1;
	a[3] = 4;
	a[4] = 2;
	ft_sort_int_tab(a, 5);
	ft_print_tab(a, 5);
	b[0] = 42;
	b[1] = -1;
	b[2] = 0;
	ft_sort_int_tab(b, 3);
	ft_print_tab(b, 3);
	c[0] = 7;
	ft_sort_int_tab(c, 1);
	ft_print_tab(c, 1);
	d[0] = 3;
	d[1] = 3;
	d[2] = 1;
	d[3] = 1;
	d[4] = 2;
	d[5] = 2;
	ft_sort_int_tab(d, 6);
	ft_print_tab(d, 6);
	return (0);
}
```

### Очікуваний результат

```
1 2 3 4 5
-1 0 42
7
1 1 2 2 3 3
```

## Підказки

<details>
<summary>Підказка 1</summary>

**Bubble sort** працює так: проходимо по масиву і порівнюємо сусідні елементи. Якщо лівий більший за правий -- обмінюємо. Повторюємо, поки масив не відсортований.

Візуалізація для [5, 3, 1]:
```
Прохід 1: [5,3,1] -> [3,5,1] -> [3,1,5]
Прохід 2: [3,1,5] -> [1,3,5] -> [1,3,5]
Прохід 3: [1,3,5] (без обмінів = готово)
```

</details>

<details>
<summary>Підказка 2</summary>

Для bubble sort потрібні вкладені цикли `while`. Зовнішній відповідає за кількість проходів, внутрішній -- за порівняння пар:

```c
void	ft_sort_int_tab(int *tab, int size)
{
	int	i;
	int	j;
	int	tmp;

	i = 0;
	while (i < size - 1)
	{
		j = 0;
		while (j < size - 1 - i)
		{
			if (tab[j] > tab[j + 1])
			{
				tmp = tab[j];
				tab[j] = tab[j + 1];
				tab[j + 1] = tmp;
			}
			j++;
		}
		i++;
	}
}
```

</details>

<details>
<summary>Підказка 3</summary>

Оптимізація: `size - 1 - i` у внутрішньому циклі. Після кожного проходу найбільший елемент "спливає" на своє місце. Тому з кожним проходом потрібно перевіряти на один елемент менше.

Norminette: функція має 3 змінних (i, j, tmp) + 2 параметри (tab, size) = 5 -- саме ліміт. Код тіла -- близько 15 рядків, в межах 25.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| сортування | tri | "Trier un tableau par ordre croissant" |
| за зростанням | ordre croissant | "Du plus petit au plus grand" |
| бульбашкове сортування | tri a bulles | "L'algorithme du tri a bulles" |

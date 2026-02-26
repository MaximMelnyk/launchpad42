---
id: bridge_arrays_func
module: bridge
phase: phase2
title: "Arrays as Parameters"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["bridge_arrays_int"]
tags: ["c", "arrays", "functions", "pointers"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 34
---

# Arrays as Parameters

## Завдання

Коли ти передаєш масив у функцію в C, передається НЕ копія масиву, а вказівник на перший елемент. Це означає, що функція може змінити оригінальний масив. Це також означає, що `sizeof(arr)` всередині функції дасть розмір вказівника, а не масиву.

Напиши дві функції:
1. `ft_print_array` -- виводить масив `int` із зазначеною кількістю елементів, розділених комою і пробілом
2. `ft_multiply_array` -- множить кожен елемент масиву на 2 (модифікує оригінальний масив)

### Прототип

```c
void	ft_print_array(int *arr, int size);
void	ft_multiply_array(int *arr, int size);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`)
- Другий параметр `size` обов'язковий -- масив не знає свій розмір
- Заголовок 42 header у кожному файлі
- Файли: `ft_print_array.c`, `ft_multiply_array.c`, `ft_putchar.c`, `ft_putnbr.c`, `main.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_print_array(int *arr, int size);
void	ft_multiply_array(int *arr, int size);

int	main(void)
{
	int	arr[4];

	arr[0] = 1;
	arr[1] = 2;
	arr[2] = 3;
	arr[3] = 4;
	ft_print_array(arr, 4);
	ft_putchar('\n');
	ft_multiply_array(arr, 4);
	ft_print_array(arr, 4);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1, 2, 3, 4
2, 4, 6, 8
```

## Підказки

<details>
<summary>Підказка 1</summary>

Коли масив передається у функцію, він "деградує" до вказівника. Тому `sizeof(arr)` в функції дасть 4 або 8 (розмір вказівника), а не розмір масиву. Ось чому потрібен параметр `size`:
```c
void	ft_print_array(int *arr, int size)
{
	int	i;

	i = 0;
	while (i < size)
	{
		/* ... print arr[i] */
		i++;
	}
}
```

</details>

<details>
<summary>Підказка 2</summary>

Оскільки масив передається за вказівником, зміна `arr[i]` всередині функції змінює оригінальний масив. Саме тому `ft_multiply_array` працює:
```c
void	ft_multiply_array(int *arr, int size)
{
	int	i;

	i = 0;
	while (i < size)
	{
		arr[i] = arr[i] * 2;
		i++;
	}
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| параметр | parametre | "Passer un tableau en parametre" |
| вказівник | pointeur | "Un tableau se degrade en pointeur" |
| розмір | taille | "La taille du tableau" |

---
id: bridge_arrays_int
module: bridge
phase: phase2
title: "Int Arrays"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["p0_d03_variables"]
tags: ["c", "arrays", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 32
---

# Int Arrays

## Завдання

Масиви -- одна з найважливіших структур даних у C. На Piscine ти будеш працювати з масивами починаючи від C01 (ft_rev_int_tab, ft_sort_int_tab) і аж до BSQ (2D масиви). Тому важливо розібратися з основами зараз.

Напиши програму, яка:
1. Оголошує масив з 5 елементів типу `int`
2. Заповнює його значеннями 1, 2, 3, 4, 5 за допомогою циклу `while`
3. Виводить усі елементи через кому: `1, 2, 3, 4, 5`
4. Виводить символ нового рядка `\n` в кінці

Для виводу чисел використай допоміжну функцію `ft_putnbr`.

### Прототип

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`)
- Змінні оголошуються на початку функції (Norminette)
- Заголовок 42 header у кожному файлі
- Файли: `main.c`, `ft_putchar.c`, `ft_putnbr.c`
- Norminette: так

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);

int	main(void)
{
	int	arr[5];
	int	i;

	i = 0;
	while (i < 5)
	{
		arr[i] = i + 1;
		i++;
	}
	i = 0;
	while (i < 5)
	{
		ft_putnbr(arr[i]);
		if (i < 4)
		{
			ft_putchar(',');
			ft_putchar(' ');
		}
		i++;
	}
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
1, 2, 3, 4, 5
```

## Підказки

<details>
<summary>Підказка 1</summary>

Масив оголошується так:
```c
int	arr[5];
```
Це створює 5 послідовних комірок пам'яті типу `int`. Доступ до елемента: `arr[0]`, `arr[1]`, ..., `arr[4]`. Індексація починається з 0!

</details>

<details>
<summary>Підказка 2</summary>

Для заповнення масиву використай лічильник:
```c
int	i;

i = 0;
while (i < 5)
{
	arr[i] = i + 1;
	i++;
}
```
Після цього циклу `arr` = {1, 2, 3, 4, 5}.

</details>

<details>
<summary>Підказка 3</summary>

Щоб вивести кому і пробіл між елементами, але НЕ після останнього:
```c
if (i < 4)
{
	ft_putchar(',');
	ft_putchar(' ');
}
```
Перевіряємо `i < 4`, бо останній елемент має індекс 4 (при 5 елементах).

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| масив | tableau | "Declarer un tableau d'entiers" |
| індекс | indice | "L'indice commence a zero" |
| цикл | boucle | "Une boucle while" |

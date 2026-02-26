---
id: bridge_arrays_2d
module: bridge
phase: phase2
title: "2D Arrays"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["bridge_arrays_int"]
tags: ["c", "arrays", "2d"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 33
---

# 2D Arrays

## Завдання

Двовимірні масиви потрібні для BSQ (найбільший квадрат) та інших задач на Piscine. Навчись працювати з ними зараз.

Напиши програму, яка:
1. Оголошує масив `int grid[3][3]`
2. Заповнює його за допомогою вкладених циклів `while` -- значення = `row * 3 + col + 1` (числа від 1 до 9)
3. Виводить масив у форматі матриці 3x3, елементи розділені пробілом

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
- Не більше 5 змінних у функції (Norminette)
- Заголовок 42 header у кожному файлі
- Файли: `main.c`, `ft_putchar.c`, `ft_putnbr.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);

int	main(void)
{
	int	grid[3][3];
	int	row;
	int	col;

	row = 0;
	while (row < 3)
	{
		col = 0;
		while (col < 3)
		{
			grid[row][col] = row * 3 + col + 1;
			col++;
		}
		row++;
	}
	row = 0;
	while (row < 3)
	{
		col = 0;
		while (col < 3)
		{
			ft_putnbr(grid[row][col]);
			if (col < 2)
				ft_putchar(' ');
			col++;
		}
		ft_putchar('\n');
		row++;
	}
	return (0);
}
```

### Очікуваний результат

```
1 2 3
4 5 6
7 8 9
```

## Підказки

<details>
<summary>Підказка 1</summary>

2D масив оголошується так:
```c
int	grid[3][3];
```
`grid[row][col]` -- доступ до елемента. Перший індекс -- рядок (row), другий -- стовпець (col). У пам'яті елементи зберігаються рядок за рядком (row-major order).

</details>

<details>
<summary>Підказка 2</summary>

Для заповнення використовуй вкладені `while` цикли. Зовнішній -- по рядках, внутрішній -- по стовпцях:
```c
row = 0;
while (row < 3)
{
	col = 0;
	while (col < 3)
	{
		grid[row][col] = row * 3 + col + 1;
		col++;
	}
	row++;
}
```
Не забудь скинути `col = 0` на початку кожного зовнішнього циклу!

</details>

<details>
<summary>Підказка 3</summary>

Щоб вивести пробіл між числами, але не після останнього у рядку:
```c
if (col < 2)
	ft_putchar(' ');
```
А `\n` виводиться після кожного рядка матриці.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| матриця | matrice | "Une matrice 3 par 3" |
| рядок | ligne | "La premiere ligne du tableau" |
| стовпець | colonne | "Parcourir chaque colonne" |

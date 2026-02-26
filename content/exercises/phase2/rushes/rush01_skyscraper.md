---
id: rush01_skyscraper
module: rush
phase: phase2
title: "Rush01: Skyscraper 4x4"
difficulty: 4
xp: 80
estimated_minutes: 360
prerequisites: ["c05_ex08_ft_ten_queens_puzzle"]
tags: ["c", "rush", "backtracking"]
norminette: true
man_pages: ["write"]
multi_day: true
order: 95
---

# Rush01: Skyscraper 4x4

## Завдання

Розв'яжи головоломку **Skyscraper 4x4** за допомогою алгоритму backtracking.

**Контекст Piscine:** Rush01 -- один з найвідоміших rushes на Piscine. На реальній Piscine його роблять у команді з 2-3 осіб протягом вихідних. Це класична задача на constraint satisfaction: ти маєш заповнити сітку 4x4 числами 1-4 так, щоб виконувались обмеження видимості з кожного боку. Якщо ти зробив `ft_ten_queens_puzzle` (C05 ex08), backtracking вже знайомий.

**Рекомендовано:** один повний вихідний день (4-6 годин). Розбий на етапи: парсинг вводу, перевірка обмежень, backtracking.

### Правила головоломки

Уяви, що у кожній клітинці сітки 4x4 стоїть будинок висотою від 1 до 4 поверхів:

```
    col1 col2 col3 col4
   +----+----+----+----+
r1 |    |    |    |    |
   +----+----+----+----+
r2 |    |    |    |    |
   +----+----+----+----+
r3 |    |    |    |    |
   +----+----+----+----+
r4 |    |    |    |    |
   +----+----+----+----+
```

Правила:
1. Кожний рядок містить числа 1, 2, 3, 4 (кожне рівно один раз)
2. Кожний стовпець містить числа 1, 2, 3, 4 (кожне рівно один раз)
3. Обмеження видимості: з кожного боку сітки задано скільки "будинків видно"

**Видимість:** стоячи з одного боку, ти бачиш тільки ті будинки, які не закриті вищими. Наприклад, ряд `[2, 1, 4, 3]`:
- Зліва видно: 2, 4 = **2 будинки** (1 закритий за 2, 3 закритий за 4)
- Справа видно: 3, 4 = **2 будинки** (1 закритий за 3)

### Формат вводу

Програма отримує через `argv[1]` один рядок з 16 числами, розділеними пробілами:

```
"col1_top col2_top col3_top col4_top col1_bot col2_bot col3_bot col4_bot col1_left col2_left col3_left col4_left col1_right col2_right col3_right col4_right"
```

Порядок обмежень:
1. **Зверху** (top): 4 числа -- скільки видно дивлячись вниз по кожному стовпцю
2. **Знизу** (bottom): 4 числа -- скільки видно дивлячись вгору по кожному стовпцю
3. **Зліва** (left): 4 числа -- скільки видно дивлячись вправо по кожному рядку
4. **Справа** (right): 4 числа -- скільки видно дивлячись вліво по кожному рядку

### Прототип

Немає єдиного прототипу -- програма запускається через `main(int argc, char **argv)`.

### Вимоги

- Вхід: один аргумент (`argv[1]`) з 16 числами
- Кожне число -- від 1 до 4
- Якщо рішення існує -- вивести сітку 4x4 (числа розділені пробілами, кожен рядок закінчується `'\n'`)
- Якщо рішення не існує або вхід некоректний -- вивести `"Error\n"`
- Алгоритм: backtracking (як ft_ten_queens_puzzle)
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `exit`
- Файли: можна розділити на кілька `.c` файлів
- Norminette: так
- 42 header: обов'язковий

### Приклад

```bash
$ ./rush01 "4 3 2 1 1 2 2 2 4 3 2 1 1 2 2 2"
1 2 3 4
2 3 4 1
3 4 1 2
4 1 2 3
```

Перевірка:
```
        4  3  2  1    <- top constraints (look down)
       +--+--+--+--+
  4 <- | 1| 2| 3| 4| -> 1
       +--+--+--+--+
  3 <- | 2| 3| 4| 1| -> 2
       +--+--+--+--+
  2 <- | 3| 4| 1| 2| -> 2
       +--+--+--+--+
  1 <- | 4| 1| 2| 3| -> 2
       +--+--+--+--+
        1  2  2  2    <- bottom constraints (look up)
```

- Top col1 = 4: зверху видно 1,2,3,4 = 4 будинки (кожен вищий за попередній)
- Top col2 = 3: зверху видно 2,3,4 = 3 (1 закритий за 4)
- Left row1 = 4: зліва видно 1,2,3,4 = 4
- Right row1 = 1: справа видно тільки 4 = 1

### Тестування

```bash
# Valid input
./rush01 "4 3 2 1 1 2 2 2 4 3 2 1 1 2 2 2"

# Another valid input
./rush01 "1 2 2 2 2 2 2 1 1 2 2 2 2 2 2 1"

# Invalid input (no solution)
./rush01 "1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"

# Wrong number of arguments
./rush01

# Wrong format
./rush01 "1 2 3"
```

### Очікуваний результат

```bash
# "4 3 2 1 1 2 2 2 4 3 2 1 1 2 2 2"
1 2 3 4
2 3 4 1
3 4 1 2
4 1 2 3

# "1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1" — no solution
Error

# Wrong args
Error
```

### Структура файлів (рекомендована)

```
rush01/
  main.c         — main(), parse argv, call solver
  parse.c        — parsing + validation of input
  solve.c        — backtracking solver
  check.c        — constraint checking (visibility)
  display.c      — print grid
  ft_putchar.c   — ft_putchar
```

## Підказки

<details>
<summary>Підказка 1: Парсинг вводу</summary>

Парсинг `argv[1]` -- перетворення рядка "4 3 2 1 1 2 2 2 ..." в масив з 16 чисел.

```c
int	parse_input(char *str, int *constraints)
{
	int	i;
	int	count;

	i = 0;
	count = 0;
	while (str[i] && count < 16)
	{
		while (str[i] == ' ')
			i++;
		if (str[i] >= '1' && str[i] <= '4')
		{
			constraints[count] = str[i] - '0';
			count++;
			i++;
		}
		else if (str[i] != '\0')
			return (0);
	}
	return (count == 16);
}
```

Обмеження зберігай у масиві `int constraints[16]`:
- `[0-3]` = top (col 0-3)
- `[4-7]` = bottom (col 0-3)
- `[8-11]` = left (row 0-3)
- `[12-15]` = right (row 0-3)

</details>

<details>
<summary>Підказка 2: Перевірка видимості</summary>

Функція, яка рахує видимі будинки з одного боку:

```c
int	count_visible(int *line, int size)
{
	int	count;
	int	max;
	int	i;

	count = 0;
	max = 0;
	i = 0;
	while (i < size)
	{
		if (line[i] > max)
		{
			max = line[i];
			count++;
		}
		i++;
	}
	return (count);
}
```

Для перевірки правого боку -- рахуй з кінця (або передавай reversed масив).

</details>

<details>
<summary>Підказка 3: Backtracking -- аналогія з 10 ферзями</summary>

Backtracking для skyscraper дуже схожий на `ft_ten_queens_puzzle`:

```c
/* Pseudocode */
int	solve(int grid[4][4], int *constraints, int pos)
{
	int	row;
	int	col;
	int	val;

	if (pos == 16)
		return (check_all_constraints(grid, constraints));
	row = pos / 4;
	col = pos % 4;
	val = 1;
	while (val <= 4)
	{
		if (is_valid(grid, row, col, val))
		{
			grid[row][col] = val;
			if (solve(grid, constraints, pos + 1))
				return (1);
			grid[row][col] = 0;
		}
		val++;
	}
	return (0);
}
```

`is_valid` перевіряє:
1. `val` не повторюється у рядку `row`
2. `val` не повторюється у стовпці `col`
3. Часткові обмеження видимості не порушені (опціонально для оптимізації)

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| головоломка | casse-tete / puzzle | "Le rush01 c'est un casse-tete de grilles" |
| обмеження | contrainte | "Les contraintes de visibilité" |
| видимість | visibilité | "Compter les bâtiments visibles" |
| повернення назад | retour arriere (backtracking) | "L'algorithme de retour arriere explore toutes les possibilités" |
| сітка | grille | "Remplir la grille 4x4" |
| команда | equipe | "On fait le rush en equipe de 2-3" |

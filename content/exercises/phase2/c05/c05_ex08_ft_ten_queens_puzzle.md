---
id: c05_ex08_ft_ten_queens_puzzle
module: c05
phase: phase2
title: "ft_ten_queens_puzzle"
difficulty: 5
xp: 80
estimated_minutes: 120
prerequisites: ["c05_ex04_ft_fibonacci"]
tags: ["c", "recursion", "backtracking"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 79
---

# ft_ten_queens_puzzle

## Завдання

Напиши функцію `ft_ten_queens_puzzle`, яка знаходить та друкує всі розв'язки задачі десяти ферзів (dix reines).

**Задача N ферзів** -- класична задача з інформатики та шахів. Потрібно розмістити 10 ферзів на шахівниці 10x10 так, щоб жоден ферзь не атакував іншого. Ферзь атакує по горизонталі, вертикалі та обох діагоналях.

**Формат виводу:** кожен розв'язок -- рядок з 10 цифр, де `i`-та цифра -- номер стовпця (0-9) ферзя у рядку `i`. Після кожного розв'язку -- символ нового рядка `\n`.

Наприклад: `0257948136\n` означає:
- Ферзь у рядку 0 стоїть у стовпці 0
- Ферзь у рядку 1 стоїть у стовпці 2
- Ферзь у рядку 2 стоїть у стовпці 5
- і так далі...

Функція повертає загальну кількість знайдених розв'язків.

**Алгоритм: бектрекінг (backtracking)**

Бектрекінг -- це рекурсивний алгоритм, який:
1. Намагається поставити ферзя у поточний рядок (перебирає стовпці 0-9)
2. Перевіряє, чи не конфліктує нова позиція з уже поставленими ферзями
3. Якщо конфлікту немає -- переходить до наступного рядка (рекурсивний виклик)
4. Якщо конфлікт є -- пробує наступний стовпець
5. Якщо всі 10 рядків заповнені -- друкує розв'язок та збільшує лічильник
6. Повертається назад (backtrack) для пошуку інших розв'язків

### Прототип

```c
int	ft_ten_queens_puzzle(void);
```

### Вимоги

- Виведи всі розв'язки на стандартний вивід (один рядок = один розв'язок, 10 цифр + `\n`)
- Поверни загальну кількість розв'язків (відповідь: **724**)
- Для виводу використовуй тільки `write(1, ...)` (через допоміжну `ft_putchar`)
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `malloc`
- Файл: `ft_ten_queens_puzzle.c`
- Norminette: так (увага: max 5 функцій на файл, max 25 рядків на функцію)
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
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	ft_ten_queens_puzzle(void);

int	main(void)
{
	int	count;

	count = ft_ten_queens_puzzle();
	ft_putchar('\n');
	ft_putnbr(count);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

Функція виводить 724 рядки (всі розв'язки), а потім:

```
(724 рядків з розв'язками)

724
```

Перші кілька рядків виводу:

```
0257948136
0258693147
0358497261
...
```

Останній рядок перед пустим рядком та числом `724` -- це останній розв'язок.

## Підказки

<details>
<summary>Підказка 1: Структура даних</summary>

Використовуй масив `int board[10]`, де `board[row] = col` -- стовпець ферзя у рядку `row`.

Для перевірки конфлікту нового ферзя (row, col) з уже поставленими:
- **Стовпець:** `board[i] == col` (ферзь у тому ж стовпці)
- **Діагональ:** `abs(board[i] - col) == abs(i - row)` (різниця стовпців == різниця рядків)

Замість `abs()` можеш написати перевірку вручну або використати два порівняння.

</details>

<details>
<summary>Підказка 2: Рекурсивна функція</summary>

Потрібні дві функції:
1. `ft_check` -- перевіряє, чи можна поставити ферзя
2. `ft_solve` -- рекурсивно шукає розв'язки

```c
// Перевірка: чи можна поставити ферзя в (row, col)?
int	ft_check(int *board, int row, int col)
{
    int	i;

    i = 0;
    while (i < row)
    {
        if (board[i] == col)
            return (0);
        if (board[i] - col == i - row)
            return (0);
        if (board[i] - col == row - i)
            return (0);
        i++;
    }
    return (1);
}
```

</details>

<details>
<summary>Підказка 3: Основний алгоритм бектрекінгу</summary>

```c
void	ft_print_solution(int *board)
{
    int	i;

    i = 0;
    while (i < 10)
    {
        ft_putchar(board[i] + '0');
        i++;
    }
    ft_putchar('\n');
}

void	ft_solve(int *board, int row, int *count)
{
    int	col;

    if (row == 10)
    {
        ft_print_solution(board);
        (*count)++;
        return ;
    }
    col = 0;
    while (col < 10)
    {
        if (ft_check(board, row, col))
        {
            board[row] = col;
            ft_solve(board, row + 1, count);
        }
        col++;
    }
}

int	ft_ten_queens_puzzle(void)
{
    int	board[10];
    int	count;

    count = 0;
    ft_solve(board, 0, &count);
    return (count);
}
```

**Увага Norminette:** у файлі максимум 5 функцій. Тобі потрібно: `ft_putchar`, `ft_check`, `ft_print_solution`, `ft_solve`, `ft_ten_queens_puzzle` -- рівно 5. Слідкуй за кількістю рядків у кожній функції (max 25).

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| ферзь | reine | "Placer dix reines sur l'echiquier" |
| шахівниця | echiquier | "Un echiquier de 10 par 10" |
| бектрекінг | retour sur trace | "L'algorithme de retour sur trace" |
| розв'язок | solution | "Il y a 724 solutions" |

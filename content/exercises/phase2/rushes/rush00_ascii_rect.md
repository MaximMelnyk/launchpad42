---
id: rush00_ascii_rect
module: rush
phase: phase2
title: "Rush00: ASCII Rectangle"
difficulty: 3
xp: 60
estimated_minutes: 180
prerequisites: ["c05_ex01_ft_recursive_factorial"]
tags: ["c", "rush", "output"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 94
---

# Rush00: ASCII Rectangle

## Завдання

Напиши функцію `rush`, яка виводить прямокутник розміром `x` на `y`, побудований зі спеціальних символів.

**Контекст Piscine:** Rush00 -- це перший "rush" (командний проект вихідного дня). На реальній Piscine тебе випадково об'єднують у команду з 2-3 людьми, і ви маєте 2 дні (субота-неділя) щоб реалізувати rush. Тут ти робиш solo-версію для підготовки.

На Piscine існує кілька варіантів Rush00 (rush00 - rush04), які відрізняються символами кутів. Ми починаємо з базового варіанту (rush00).

### Символи rush00

| Позиція | Символ |
|---------|--------|
| Верхній лівий кут | `o` |
| Верхній правий кут | `o` |
| Нижній лівий кут | `o` |
| Нижній правий кут | `o` |
| Горизонтальна лінія (верх/низ) | `-` |
| Вертикальна лінія (ліво/право) | `\|` |
| Внутрішній простір | ` ` (пробіл) |

### Прототип

```c
void	rush(int x, int y);
```

### Вимоги

- Виведи прямокутник шириною `x` та висотою `y`
- Кожен рядок закінчується символом `'\n'`
- Якщо `x <= 0` або `y <= 0` -- нічого не виводь
- Якщо `x == 1` -- тільки вертикальна лінія (кути + `|`)
- Якщо `y == 1` -- тільки горизонтальна лінія (кути + `-`)
- Якщо `x == 1` та `y == 1` -- виведи тільки `o`
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файли: `rush00.c`, `ft_putchar.c`, `main.c`
- Norminette: так
- 42 header: обов'язковий

### Структура файлів

На Piscine Rush00 зазвичай вимагає розділення на файли:

- **`ft_putchar.c`** -- функція `ft_putchar(char c)`
- **`rush00.c`** -- функція `rush(int x, int y)` + допоміжні
- **`main.c`** -- тестовий main (який викликає rush)

### Тестування

```c
/* main.c */
void	rush(int x, int y);

int	main(void)
{
	rush(5, 3);
	return (0);
}
```

### Очікуваний результат

`rush(5, 3)`:
```
o---o
|   |
o---o
```

`rush(5, 1)`:
```
o---o
```

`rush(1, 5)`:
```
o
|
|
|
o
```

`rush(1, 1)`:
```
o
```

`rush(3, 3)`:
```
o-o
| |
o-o
```

`rush(0, 5)`:
```
```
(порожній вивід)

## Підказки

<details>
<summary>Підказка 1: Розбий на функції</summary>

Створи допоміжну функцію, яка виводить один рядок прямокутника:

```c
void	print_line(int x, char left, char mid, char right)
```

Тоді `rush` виглядатиме так:
- Перший рядок: `print_line(x, 'o', '-', 'o')`
- Середні рядки: `print_line(x, '|', ' ', '|')` (в циклі `y - 2` разів)
- Останній рядок: `print_line(x, 'o', '-', 'o')`

Але увага: якщо `y == 1`, друга та третя лінії не потрібні!

</details>

<details>
<summary>Підказка 2: Функція print_line</summary>

```c
void	print_line(int x, char left, char mid, char right)
{
    int	i;

    if (x <= 0)
        return ;
    ft_putchar(left);
    i = 1;
    while (i < x - 1)
    {
        ft_putchar(mid);
        i++;
    }
    if (x > 1)
        ft_putchar(right);
    ft_putchar('\n');
}
```

Зверни увагу на edge case: якщо `x == 1`, виводимо тільки `left` без `mid` та `right`. Якщо `x == 2`, виводимо `left` та `right` без `mid`.

</details>

<details>
<summary>Підказка 3: Edge cases</summary>

Головна функція `rush`:

```c
void	rush(int x, int y)
{
    int	row;

    if (x <= 0 || y <= 0)
        return ;
    print_line(x, 'o', '-', 'o');
    row = 1;
    while (row < y - 1)
    {
        print_line(x, '|', ' ', '|');
        row++;
    }
    if (y > 1)
        print_line(x, 'o', '-', 'o');
}
```

Тести для перевірки edge cases:
- `rush(1, 1)` = `o\n`
- `rush(2, 2)` = `oo\noo\n`
- `rush(2, 1)` = `oo\n`

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| rush | rush | "Le rush c'est un projet de week-end" |
| прямокутник | rectangle | "Afficher un rectangle de caracteres" |
| кут | coin | "Les coins du rectangle" |
| команда | equipe | "On fait le rush en equipe" |
| вихідні | week-end | "Le rush c'est le week-end" |

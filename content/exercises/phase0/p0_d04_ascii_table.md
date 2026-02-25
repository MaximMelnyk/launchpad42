---
id: p0_d04_ascii_table
module: p0
phase: phase0
title: "ASCII Table"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["p0_d04_char_arithmetic"]
tags: ["c", "ascii", "while", "format"]
norminette: true
man_pages: ["write", "ascii"]
multi_day: false
order: 10
---

# ASCII Table

## Завдання

Виведи таблицю друкованих ASCII символів (коди від 32 до 126).

Кожний рядок повинен містити код символу, двокрапку, пробіл та сам символ.

### Вимоги

- Виводь символи з кодами від 32 до 126 включно
- Формат кожного рядка: `{код}: {символ}`
- Кожний запис на новому рядку
- Використовуй `while` цикл (НЕ `for`)
- Використовуй `ft_putnbr` для виводу коду, `ft_putchar` для символу
- Файли: `main.c` + `ft_putchar.c` + `ft_putnbr.c` + `ft_putstr.c`
- Norminette: так

### Очікуваний результат (перші та останні рядки)

```
32:
33: !
34: "
35: #
...
125: }
126: ~
```

Зверни увагу: рядок `32:  ` має пробіл після `: ` -- це і є символ з кодом 32 (пробіл).

## Підказки

<details>
<summary>Підказка 1</summary>

Використовуй лічильник типу `int`, який йде від 32 до 126:
```c
int	i;

i = 32;
while (i <= 126)
{
	// print code and character
	i++;
}
```

</details>

<details>
<summary>Підказка 2</summary>

Для виводу одного рядка:
```c
ft_putnbr(i);
ft_putstr(": ");
ft_putchar((char)i);
ft_putchar('\n');
```

Зведи (cast) `int` до `char` при виклику `ft_putchar`.

</details>

## Man сторінки

- `man 2 write`
- `man ascii`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| таблиця | tableau | "Le tableau ASCII" |
| друкований символ | caractère imprimable | "Les caractères imprimables de 32 à 126" |

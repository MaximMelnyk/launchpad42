---
id: c01_ex02_ft_swap
module: c01
phase: phase2
title: "ft_swap"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c01_ex00_ft_ft"]
tags: ["c", "pointers", "swap"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 39
---

# ft_swap

## Завдання

`ft_swap` -- класична вправа на вказівники. Обмін значень двох змінних через вказівники -- це паттерн, який ти будеш використовувати у сортуванні масивів (ft_sort_int_tab) та інших алгоритмах.

Напиши функцію `ft_swap`, яка обмінює значення двох цілих чисел через вказівники.

### Прототип

```c
void	ft_swap(int *a, int *b);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`), якщо потрібен цикл
- Використай тимчасову змінну для обміну (tmp)
- Заголовок 42 header у кожному файлі
- Файл: `ft_swap.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_swap(int *a, int *b);

int	main(void)
{
	int	x;
	int	y;

	x = 42;
	y = 21;
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	ft_swap(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
42 21
21 42
```

## Підказки

<details>
<summary>Підказка 1</summary>

Для обміну двох значень потрібна тимчасова змінна. Уяви, що ти маєш дві склянки з водою: щоб переливити, потрібна третя порожня склянка.
```c
int	tmp;

tmp = *a;
*a = *b;
*b = tmp;
```

</details>

<details>
<summary>Підказка 2</summary>

Без вказівників неможливо змінити змінні у `main` з іншої функції. Якби `ft_swap` приймала `int a, int b`, вона б працювала з копіями і нічого не змінила б. Саме вказівники дозволяють функції "бачити" оригінальні змінні.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| обмін | echange | "Echanger deux valeurs" |
| тимчасова змінна | variable temporaire | "Utiliser une variable temporaire" |
| передача за адресою | passage par adresse | "Passer les variables par adresse" |

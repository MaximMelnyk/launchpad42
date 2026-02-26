---
id: c01_ex03_ft_div_mod
module: c01
phase: phase2
title: "ft_div_mod"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c01_ex00_ft_ft"]
tags: ["c", "pointers", "math"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 40
---

# ft_div_mod

## Завдання

Напиши функцію `ft_div_mod`, яка обчислює результат цілочисельного ділення та остачу і записує їх через вказівники.

Ця функція демонструє важливий паттерн C: повернення декількох значень з функції через вказівники (оскільки `return` може повернути лише одне значення).

### Прототип

```c
void	ft_div_mod(int a, int b, int *div, int *mod);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- `a` та `b` передаються за значенням (копії)
- `div` та `mod` передаються за вказівником (результати записуються за адресою)
- `*div` = `a / b`
- `*mod` = `a % b`
- Заголовок 42 header у кожному файлі
- Файл: `ft_div_mod.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_div_mod(int a, int b, int *div, int *mod);

int	main(void)
{
	int	d;
	int	m;

	ft_div_mod(10, 3, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	ft_div_mod(42, 10, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	ft_div_mod(7, 7, &d, &m);
	ft_putnbr(d);
	ft_putchar(' ');
	ft_putnbr(m);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
3 1
4 2
1 0
```

## Підказки

<details>
<summary>Підказка 1</summary>

У C оператор `/` для цілих чисел дає цілу частину від ділення (відкидає дробову): `10 / 3 = 3`. Оператор `%` дає остачу: `10 % 3 = 1`.

</details>

<details>
<summary>Підказка 2</summary>

Результати потрібно записати за адресами, переданими через вказівники:
```c
*div = a / b;
*mod = a % b;
```
Зверни увагу: `a` і `b` -- це просто `int` (копії), а `div` і `mod` -- це `int *` (вказівники на змінні в `main`).

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| ділення | division | "La division entiere" |
| остача | modulo / reste | "Le reste de la division" |
| результат | resultat | "Stocker le resultat via pointeur" |

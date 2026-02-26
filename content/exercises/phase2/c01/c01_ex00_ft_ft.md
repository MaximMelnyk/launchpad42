---
id: c01_ex00_ft_ft
module: c01
phase: phase2
title: "ft_ft"
difficulty: 1
xp: 15
estimated_minutes: 15
prerequisites: ["bridge_arrays_func"]
tags: ["c", "pointers", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 37
---

# ft_ft

## Завдання

Ласкаво просимо до C01 -- модулю вказівників (pointers). Вказівники -- це серце мови C, і на Piscine вони з'являються у кожному проекті починаючи з C01.

Напиши функцію `ft_ft`, яка приймає вказівник на `int` і присвоює значення `42` через цей вказівник.

### Прототип

```c
void	ft_ft(int *nbr);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Функція приймає вказівник `int *nbr` і записує `42` за адресою
- Заголовок 42 header у кожному файлі
- Файл: `ft_ft.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_ft(int *nbr);

int	main(void)
{
	int	n;

	n = 0;
	ft_putnbr(n);
	ft_putchar('\n');
	ft_ft(&n);
	ft_putnbr(n);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
0
42
```

## Підказки

<details>
<summary>Підказка 1</summary>

Вказівник -- це змінна, яка зберігає адресу іншої змінної. Коли ти пишеш `int *nbr`, `nbr` зберігає адресу якогось `int`. Щоб записати значення за цією адресою, використай оператор розіменування `*`:
```c
*nbr = 42;
```

</details>

<details>
<summary>Підказка 2</summary>

У `main` ми передаємо `&n` -- адресу змінної `n`. Всередині `ft_ft` параметр `nbr` отримує цю адресу. Коли ми пишемо `*nbr = 42`, ми записуємо 42 за адресою `nbr`, тобто змінюємо оригінальне `n`.

Повна функція -- один рядок:
```c
void	ft_ft(int *nbr)
{
	*nbr = 42;
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| вказівник | pointeur | "Un pointeur sur un entier" |
| адреса | adresse | "L'adresse mémoire de la variable" |
| розіменування | déréférencement | "Dereferencer un pointeur" |

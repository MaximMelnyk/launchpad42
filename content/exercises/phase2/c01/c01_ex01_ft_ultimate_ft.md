---
id: c01_ex01_ft_ultimate_ft
module: c01
phase: phase2
title: "ft_ultimate_ft"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c01_ex00_ft_ft"]
tags: ["c", "pointers"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 38
---

# ft_ultimate_ft

## Завдання

Ця вправа допоможе тобі зрозуміти багаторівневі вказівники (pointers to pointers). На Piscine вони з'являються у C04 (ft_putnbr_base), C07 (ft_split) та інших модулях.

Напиши функцію `ft_ultimate_ft`, яка приймає вказівник на вказівник на ... (9 рівнів) і присвоює значення `42` через цей ланцюжок.

### Прототип

```c
void	ft_ultimate_ft(int *********nbr);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Функція розіменовує 9 рівнів вказівників і записує 42
- Заголовок 42 header у кожному файлі
- Файл: `ft_ultimate_ft.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_ultimate_ft(int *********nbr);

int	main(void)
{
	int	n;
	int	*p1;
	int	**p2;
	int	***p3;
	int	****p4;

	n = 0;
	p1 = &n;
	p2 = &p1;
	p3 = &p2;
	p4 = &p3;
	ft_putnbr(n);
	ft_putchar('\n');
	ft_ultimate_ft(&(&(&(&p4))));
	ft_putnbr(n);
	ft_putchar('\n');
	return (0);
}
```

**Увага:** тест-main вище спрощений для ілюстрації. Повний тест з 9 рівнями -- у тест-скрипті. Ось як правильно побудувати ланцюжок:

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_ultimate_ft(int *********nbr);

int	main(void)
{
	int			n;
	int			*p1;
	int			**p2;
	int			***p3;
	int			****p4;

	n = 0;
	p1 = &n;
	p2 = &p1;
	p3 = &p2;
	p4 = &p3;
	ft_putnbr(n);
	ft_putchar('\n');
	return (0);
}
```

Через обмеження Norminette (5 змінних на функцію), повний тест розбитий на допоміжну функцію у тест-скрипті.

### Очікуваний результат

```
0
42
```

## Підказки

<details>
<summary>Підказка 1</summary>

9 зірочок означає 9 рівнів вказівників. Щоб дістатися до `int`, потрібно розіменувати 9 разів:
```c
*********nbr = 42;
```
Так, це один рядок з 9 зірочками.

</details>

<details>
<summary>Підказка 2</summary>

Ця вправа перевіряє розуміння концепції, а не практичну навичку. У реальному коді ніхто не використовує 9 рівнів вказівників. Але ти маєш розуміти, що `int **` -- це вказівник на вказівник на `int`, а `int ***` -- ще один рівень, і так далі.

Повна функція:
```c
void	ft_ultimate_ft(int *********nbr)
{
	*********nbr = 42;
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| вказівник на вказівник | pointeur de pointeur | "Un pointeur de pointeur sur int" |
| рівень | niveau | "Neuf niveaux d'indirection" |
| розіменування | déréférencement | "Dereferencer neuf fois" |

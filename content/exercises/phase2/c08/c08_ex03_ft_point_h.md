---
id: c08_ex03_ft_point_h
module: c08
phase: phase2
title: "ft_point.h"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c08_ex00_ft_h"]
tags: ["c", "headers", "struct"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 100
---

# ft_point.h

## Завдання

Створи заголовний файл `ft_point.h`, який містить визначення структури `t_point`.

**Твоя перша структура!** До цього ти працював з окремими змінними: `int x`, `int y`. Але що, якщо точка на площині -- це ОДНА сутність з двома координатами? Структура (`struct`) об'єднує кілька змінних в один складений тип. Замість двох окремих `int` ти отримуєш один `t_point`, який містить і `x`, і `y`.

**`typedef` для зручності.** Без `typedef` тобі довелось би писати `struct s_point p;` кожного разу. З `typedef struct s_point { ... } t_point;` ти можеш писати просто `t_point p;`. У Piscine 42 конвенція: ім'я структури починається з `s_`, а typedef-ім'я -- з `t_`.

### Вміст файлу

```c
#ifndef FT_POINT_H
# define FT_POINT_H

typedef struct s_point
{
	int	x;
	int	y;
}	t_point;

#endif
```

### Вимоги

- Файл: `ft_point.h`
- Include guard: `#ifndef FT_POINT_H` / `# define FT_POINT_H` / `#endif`
- Структура `s_point` з полями `int x` та `int y`
- `typedef` на `t_point`
- Форматування: фігурна дужка `{` на окремому рядку (Norminette стиль для struct)
- 42 header: обов'язковий
- Norminette: так
- Заборонено: `printf`, `scanf`, `puts`

### Тестування

```c
#include <unistd.h>
#include "ft_point.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

void	set_point(t_point *point, int x, int y)
{
	point->x = x;
	point->y = y;
}

int	main(void)
{
	t_point	a;
	t_point	b;

	set_point(&a, 1, 2);
	set_point(&b, -3, 7);
	ft_putnbr(a.x);
	write(1, " ", 1);
	ft_putnbr(a.y);
	write(1, "\n", 1);
	ft_putnbr(b.x);
	write(1, " ", 1);
	ft_putnbr(b.y);
	write(1, "\n", 1);
	return (0);
}
```

```bash
gcc -Wall -Wextra -Werror -o test_point main.c
./test_point
```

### Очікуваний результат

```
1 2
-3 7
```

## Підказки

<details>
<summary>Підказка 1</summary>

Структура -- це "контейнер" для кількох змінних різних (або однакових) типів:

```c
struct s_point   // "s_" prefix = struct (42 convention)
{
    int x;       // first member (field)
    int y;       // second member (field)
};
```

Доступ до полів:
- Через змінну: `point.x`, `point.y`
- Через вказівник: `ptr->x`, `ptr->y` (скорочення для `(*ptr).x`)

</details>

<details>
<summary>Підказка 2</summary>

`typedef` об'єднується з `struct` в одному оголошенні:

```c
typedef struct s_point
{
    int x;
    int y;
}   t_point;       // "t_" prefix = typedef (42 convention)
```

Після цього:
```c
t_point a;          // замість "struct s_point a;"
a.x = 10;
a.y = 20;
```

Конвенція іменування 42: `s_name` для struct, `t_name` для typedef.

</details>

<details>
<summary>Підказка 3</summary>

Структури передаються за значенням (копія). Щоб модифікувати оригінал, передавай вказівник:

```c
void set_point(t_point *point, int x, int y)
{
    point->x = x;   // -> means "dereference and access"
    point->y = y;
}

t_point a;
set_point(&a, 5, 10);  // pass address
```

Це аналогічно `ft_swap`: щоб змінити значення ззовні функції, потрібен вказівник.

</details>

## Man сторінки

- `man gcc`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| структура | structure | "Une structure regroupe plusieurs variables" |
| поле | champ | "Le champ x contient la coordonnee" |
| визначення типу | definition de type | "typedef cree un alias de type" |
| вказівник | pointeur | "Un pointeur vers la structure" |

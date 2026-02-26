---
id: c08_ex01_ft_boolean_h
module: c08
phase: phase2
title: "ft_boolean.h"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c08_ex00_ft_h"]
tags: ["c", "headers", "macros", "typedef"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 98
---

# ft_boolean.h

## Завдання

Створи заголовний файл `ft_boolean.h`, який визначає макроси, тип `t_bool` та повідомлення для перевірки парності аргументів.

**Макроси** -- це інструкції для препроцесора: перед компіляцією він замінює кожне входження макросу на його значення. `#define TRUE 1` означає: "скрізь, де зустрінеш `TRUE`, підстав `1`". Це не змінна -- це текстова заміна на етапі препроцесингу.

**`typedef`** створює альтернативне ім'я для існуючого типу. `typedef int t_bool;` означає: "тепер `t_bool` -- це синонім `int`". Це покращує читабельність: `t_bool is_even;` зрозуміліше ніж `int is_even;`.

### Вміст файлу

```c
#ifndef FT_BOOLEAN_H
# define FT_BOOLEAN_H

# include <unistd.h>

typedef int		t_bool;

# define TRUE 1
# define FALSE 0

# define EVEN(nbr) ((nbr) % 2 == 0)
# define EVEN_MSG "I have an even number of arguments.\n"
# define ODD_MSG "I have an odd number of arguments.\n"

#endif
```

### Вимоги

- Файл: `ft_boolean.h`
- Include guard: `#ifndef FT_BOOLEAN_H` / `# define FT_BOOLEAN_H` / `#endif`
- `# include <unistd.h>`
- `typedef int t_bool;`
- Макроси: `TRUE` (1), `FALSE` (0), `EVEN(nbr)`, `EVEN_MSG`, `ODD_MSG`
- Макрос `EVEN(nbr)` ОБОВ'ЯЗКОВО з дужками навколо `nbr`: `((nbr) % 2 == 0)`
- 42 header: обов'язковий
- Norminette: так
- Заборонено: `printf`, `scanf`, `puts`

### Тестування

Наступний `main.c` повинен скомпілюватися і працювати коректно з твоїм `ft_boolean.h`:

```c
#include "ft_boolean.h"

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

int	main(int argc, char **argv)
{
	(void)argv;
	if (EVEN(argc - 1))
		ft_putstr(EVEN_MSG);
	else
		ft_putstr(ODD_MSG);
	return (0);
}
```

```bash
gcc -Wall -Wextra -Werror -o test_boolean main.c
./test_boolean one two       # 2 arguments (even)
./test_boolean one           # 1 argument (odd)
./test_boolean               # 0 arguments (even)
```

### Очікуваний результат

```
$ ./test_boolean one two
I have an even number of arguments.
$ ./test_boolean one
I have an odd number of arguments.
$ ./test_boolean
I have an even number of arguments.
```

## Підказки

<details>
<summary>Підказка 1</summary>

Чому дужки навколо аргументу макросу КРИТИЧНІ? Розглянь без дужок:

```c
#define EVEN(nbr) nbr % 2 == 0
```

Якщо викликати `EVEN(argc - 1)`, препроцесор підставить:
```c
argc - 1 % 2 == 0
```

Оператор `%` має вищий пріоритет ніж `-`, тому це читається як:
```c
argc - (1 % 2) == 0   →   argc - 1 == 0   →   WRONG!
```

З дужками `((nbr) % 2 == 0)` підстановка дає:
```c
((argc - 1) % 2 == 0)   →   CORRECT!
```

**Правило: ЗАВЖДИ обгортай аргументи макросу в дужки, і весь вираз теж.**

</details>

<details>
<summary>Підказка 2</summary>

`typedef` -- це НЕ макрос. Різниця:
- `#define t_bool int` -- текстова заміна (препроцесор)
- `typedef int t_bool;` -- створення типу-синоніма (компілятор)

У Piscine використовують `typedef` для структур і простих типів. `typedef int t_bool;` дозволяє писати:

```c
t_bool	is_valid;

is_valid = TRUE;
```

Це зрозуміліше ніж просто `int is_valid = 1;`.

</details>

<details>
<summary>Підказка 3</summary>

Зверни увагу на `argc`:
- `./program` -- argc = 1 (тільки ім'я програми), 0 аргументів
- `./program one` -- argc = 2, 1 аргумент
- `./program one two` -- argc = 3, 2 аргументи

Тому перевіряємо `EVEN(argc - 1)` -- парність кількості аргументів (без імені програми).

</details>

## Man сторінки

- `man gcc` (прапорець `-E` показує результат препроцесингу)

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| макрос | macro | "Une macro est une substitution textuelle" |
| парний | pair | "Un nombre pair est divisible par 2" |
| непарний | impair | "Un nombre impair" |
| визначити | definir | "Definir une macro avec #define" |

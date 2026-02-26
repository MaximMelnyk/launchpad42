---
id: c08_ex00_ft_h
module: c08
phase: phase2
title: "ft.h"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c04_ex01_ft_putstr"]
tags: ["c", "headers", "prototypes"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 97
---

# ft.h

## Завдання

Створи заголовний файл (header file) `ft.h`, який містить прототипи п'яти функцій.

**Ласкаво просимо в модуль C08 -- заголовні файли та макроси!** До цього моменту ти писав прототипи функцій прямо у файлах `.c`. Це працює, але коли проєкт росте до десятків файлів -- стає хаосом. Заголовний файл (`.h`) -- це "каталог" твоїх функцій. Ти пишеш прототипи один раз у `.h`, а потім підключаєш їх через `#include "ft.h"` у будь-якому `.c` файлі.

**Навіщо include guard?** Якщо один `.h` файл випадково підключається двічі (наприклад, `a.h` включає `ft.h`, і `b.h` теж включає `ft.h`), компілятор побачить подвійне оголошення і видасть помилку. `#ifndef`/`#define`/`#endif` захищають від цього: при першому включенні `FT_H` визначається, при другому -- весь вміст пропускається.

### Вміст файлу

```c
/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft.h                                               :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: <login> <login>@student.42.fr              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/01 00:00:00 by <login>          #+#    #+#             */
/*   Updated: 2026/01/01 00:00:00 by <login>         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_H
# define FT_H

void	ft_putchar(char c);
void	ft_putstr(char *str);
int		ft_strcmp(char *s1, char *s2);
int		ft_strlen(char *str);
void	ft_swap(int *a, int *b);

#endif
```

### Вимоги

- Файл: `ft.h`
- Include guard: `#ifndef FT_H` / `# define FT_H` / `#endif`
- Прототипи рівно 5 функцій: `ft_putchar`, `ft_putstr`, `ft_strcmp`, `ft_strlen`, `ft_swap`
- 42 header: обов'язковий
- Norminette: так (у `.h` файлах теж перевіряється!)
- Відступи: табуляція (не пробіли)
- `# define` -- пробіл після `#` (Norminette вимагає цього всередині `#ifndef` блоку)
- Заборонено: `printf`, `scanf`, `puts`

### Тестування

```c
#include "ft.h"

int	main(void)
{
	int	a;
	int	b;

	ft_putchar('O');
	ft_putchar('K');
	ft_putchar('\n');
	ft_putstr("Header works!\n");
	a = 1;
	b = 2;
	ft_swap(&a, &b);
	if (a == 2 && b == 1)
		ft_putstr("Swap OK\n");
	return (0);
}
```

Скомпілюй разом з реалізаціями функцій:

```bash
gcc -Wall -Wextra -Werror -o test_ft_h main.c ft_putchar.c ft_putstr.c ft_strcmp.c ft_strlen.c ft_swap.c
```

### Очікуваний результат

```
OK
Header works!
Swap OK
```

## Підказки

<details>
<summary>Підказка 1</summary>

Заголовний файл -- це звичайний текстовий файл з розширенням `.h`. Він містить тільки прототипи (оголошення) функцій, НЕ їх реалізацію. Прототип -- це "підпис" функції: тип повернення, ім'я, параметри, крапка з комою.

```c
void	ft_putchar(char c);  /* prototype (declaration) */
```

Реалізація (definition) залишається у `.c` файлі.

</details>

<details>
<summary>Підказка 2</summary>

Include guard -- це патерн із трьох рядків. Ім'я макросу зазвичай -- назва файлу ВЕЛИКИМИ літерами, де `.` замінюється на `_`:

```c
#ifndef FT_H       /* if FT_H is NOT defined yet... */
# define FT_H      /* ...define it (mark as "already included") */

/* ... prototypes here ... */

#endif             /* end of the guard */
```

Зверни увагу: Norminette вимагає `# define` (з пробілом після `#`) всередині `#ifndef` блоку. Це відрізняється від `#define` на верхньому рівні.

</details>

<details>
<summary>Підказка 3</summary>

Коли ти пишеш `#include "ft.h"` у `.c` файлі, препроцесор (перший етап компіляції) буквально вставляє вміст `ft.h` замість рядка `#include`. Це як copy-paste, але автоматичний. Лапки `"ft.h"` означають "шукай у поточній директорії", а кутові дужки `<unistd.h>` -- "шукай у системних директоріях".

</details>

## Man сторінки

- `man gcc` (прапорці компіляції)

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| заголовний файл | fichier d'en-tête | "Inclure le fichier d'en-tête" |
| прототип | prototype | "Le prototype declare la signature" |
| препроцесор | préprocesseur | "Le préprocesseur traite les #include" |
| включити | inclure | "Inclure ft.h dans ton fichier" |

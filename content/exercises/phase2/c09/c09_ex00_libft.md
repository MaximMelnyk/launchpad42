---
id: c09_ex00_libft
module: c09
phase: phase2
title: "libft"
difficulty: 3
xp: 40
estimated_minutes: 60
prerequisites: ["c08_ex00_ft_h"]
tags: ["c", "library", "ar"]
norminette: true
man_pages: ["ar"]
multi_day: false
order: 103
---

# libft

## Завдання

Створи свою першу **статичну бібліотеку** `libft.a`, яка об'єднує всі твої базові функції в один файл.

**Контекст Piscine:** На реальній Piscine C09 ex00 -- це саме створення `libft.a`. Ідея проста: замість того щоб кожен раз копіювати `ft_putchar.c`, `ft_strlen.c` та інші файли у кожен проект, ти компілюєш їх один раз у бібліотеку і лінкуєш при компіляції. Це як зібрати свій "інструментарій" (toolbox) в один архів.

**Що таке статична бібліотека?** Файл `.a` (archive) -- це архів скомпільованих об'єктних файлів (`.o`). Утиліта `ar` (archiver) створює такий архів. При лінкуванні компілятор витягує з архіву тільки ті `.o`, які потрібні.

### Файли

```
libft/
  ft_putchar.c
  ft_putstr.c
  ft_putnbr.c
  ft_strlen.c
  ft_strcmp.c
  ft_swap.c
  ft.h
```

### Вимоги

- Створи директорію `libft/` з 6 вихідними файлами та заголовком `ft.h`
- `ft.h` повинен містити прототипи всіх 6 функцій + header guards (`#ifndef FT_H`)
- Скомпілюй кожен `.c` файл в `.o`:
  ```bash
  cc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
  ```
- Створи архів:
  ```bash
  ar rcs libft.a ft_putchar.o ft_putstr.o ft_putnbr.o ft_strlen.o ft_strcmp.o ft_swap.o
  ```
- Перевір вміст: `ar -t libft.a` повинен показати всі `.o` файли
- Кожна функція -- саме та версія, яку ти писав у попередніх модулях (C00-C03)
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Norminette: так
- 42 header: обов'язковий

### Функції у бібліотеці

| Функція | Прототип | Модуль |
|---------|----------|--------|
| ft_putchar | `void ft_putchar(char c);` | C00 ex00 |
| ft_putstr | `void ft_putstr(char *str);` | C01 ex05 |
| ft_putnbr | `void ft_putnbr(int nb);` | C00 ex07 |
| ft_strlen | `int ft_strlen(char *str);` | C01 ex06 |
| ft_strcmp | `int ft_strcmp(char *s1, char *s2);` | C03 ex00 |
| ft_swap | `void ft_swap(int *a, int *b);` | C01 ex02 |

### Заголовний файл ft.h

```c
/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft.h                                               :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mmelnyk <mmelnyk@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/01 00:00:00 by mmelnyk           #+#    #+#             */
/*   Updated: 2026/01/01 00:00:00 by mmelnyk          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_H
# define FT_H

void	ft_putchar(char c);
void	ft_putstr(char *str);
void	ft_putnbr(int nb);
int		ft_strlen(char *str);
int		ft_strcmp(char *s1, char *s2);
void	ft_swap(int *a, int *b);

#endif
```

### Тестування

```c
/* main.c — test program (compile: cc main.c -L. -lft -o test) */
#include "ft.h"

int	main(void)
{
	int	a;
	int	b;

	ft_putstr("Hello from libft!\n");
	ft_putnbr(ft_strlen("test"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", "abd"));
	ft_putchar('\n');
	a = 10;
	b = 20;
	ft_swap(&a, &b);
	ft_putnbr(a);
	ft_putchar(' ');
	ft_putnbr(b);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hello from libft!
4
-1
20 10
```

### Покрокова інструкція збірки

```bash
# 1. Compile each .c to .o
cc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
cc -Wall -Wextra -Werror -c ft_putstr.c -o ft_putstr.o
cc -Wall -Wextra -Werror -c ft_putnbr.c -o ft_putnbr.o
cc -Wall -Wextra -Werror -c ft_strlen.c -o ft_strlen.o
cc -Wall -Wextra -Werror -c ft_strcmp.c -o ft_strcmp.o
cc -Wall -Wextra -Werror -c ft_swap.c -o ft_swap.o

# 2. Create archive
ar rcs libft.a ft_putchar.o ft_putstr.o ft_putnbr.o ft_strlen.o ft_strcmp.o ft_swap.o

# 3. Verify contents
ar -t libft.a

# 4. Compile test program and link with library
cc -Wall -Wextra -Werror main.c -L. -lft -o test
./test
```

## Підказки

<details>
<summary>Підказка 1: Що робить ar rcs?</summary>

Команда `ar` -- це archiver (архіватор):

- `r` -- replace: додати/замінити файли в архіві
- `c` -- create: створити архів, якщо не існує (без попередження)
- `s` -- index: створити індекс символів (аналог `ranlib`)

Без `s` лінкер може не знайти функції в бібліотеці. Завжди використовуй `rcs`.

Перевірити вміст:
```bash
ar -t libft.a        # list files
nm libft.a           # list symbols (functions)
```

</details>

<details>
<summary>Підказка 2: Як лінкувати з бібліотекою</summary>

При компіляції з бібліотекою:

```bash
cc main.c -L. -lft -o test
```

- `-L.` -- шукати бібліотеки у поточній директорії
- `-lft` -- лінкувати з `libft.a` (префікс `lib` та суфікс `.a` додаються автоматично)

Або напряму:
```bash
cc main.c libft.a -o test
```

Обидва способи працюють. На Piscine зазвичай використовують `-L. -lft`.

</details>

<details>
<summary>Підказка 3: Типові помилки</summary>

1. **"undefined reference to ft_putchar"** -- забув додати `.o` в архів або забув `-L. -lft`
2. **"No such file or directory: ft.h"** -- `#include "ft.h"` шукає файл в поточній директорії. Використай `-I.` при компіляції якщо потрібно
3. **Header guards** -- без `#ifndef FT_H` / `#define FT_H` / `#endif` заголовок може включатися двічі
4. **Порядок аргументів** -- `cc main.c -L. -lft` (не `cc -lft main.c`!) -- бібліотека після вихідних файлів

</details>

## Man сторінки

- `man ar`
- `man ranlib`
- `man nm`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| бібліотека | bibliotheque | "Creer une bibliotheque statique" |
| архів | archive | "L'archive contient les fichiers objets" |
| лінкувати | linker / lier | "Linker le programme avec la bibliotheque" |
| компілювати | compiler | "Compiler chaque fichier source en objet" |
| заголовок | en-tete (header) | "Le fichier en-tete contient les prototypes" |

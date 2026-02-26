---
id: c09_ex01_makefile
module: c09
phase: phase2
title: "Makefile"
difficulty: 3
xp: 40
estimated_minutes: 90
prerequisites: ["c09_ex00_libft", "make_ex02_full"]
tags: ["c", "makefile", "library"]
norminette: false
man_pages: ["make"]
multi_day: false
order: 104
---

# Makefile

## Завдання

Створи **Makefile** для збірки бібліотеки `libft.a`. Це фінальна вправа з Makefile на Piscine -- автоматизація всього процесу компіляції бібліотеки.

**Контекст Piscine:** На реальній Piscine C09 ex01 -- це Makefile для libft. Moulinette перевіряє: `make` збирає бібліотеку, `make clean` видаляє `.o` файли, `make fclean` видаляє все, `make re` перезбирає, а **два рази `make`** не повинні перекомпілювати (no relinking).

**No relinking** -- це критична вимога. Якщо запустити `make` двічі підряд, другий раз повинен вивести "make: Nothing to be done for 'all'." (або аналогічне). Це означає, що Makefile правильно відстежує залежності.

### Структура файлів

```
libft/
  Makefile
  ft_putchar.c
  ft_putstr.c
  ft_putnbr.c
  ft_strlen.c
  ft_strcmp.c
  ft_swap.c
  ft.h
```

### Вимоги

Makefile повинен містити:

| Змінна/правило | Значення/опис |
|---------------|---------------|
| `NAME` | `libft.a` |
| `SRC` | Список всіх `.c` файлів |
| `OBJ` | Список `.o` файлів (через заміну `.c` на `.o`) |
| `CC` | `cc` |
| `CFLAGS` | `-Wall -Wextra -Werror` |
| `all` | Збирає `$(NAME)` |
| `clean` | Видаляє `.o` файли |
| `fclean` | Видаляє `.o` файли + `$(NAME)` |
| `re` | `fclean` + `all` |

Додаткові вимоги:

- Використовуй `.PHONY` для `all`, `clean`, `fclean`, `re`
- `all` повинен залежати від `$(NAME)`, а `$(NAME)` -- від `$(OBJ)`
- Кожен `.o` створюється з відповідного `.c` через pattern rule або явне правило
- **NO RELINKING:** `make` двічі = друга команда нічого не робить
- `ar rcs` для створення бібліотеки (НЕ `ar rc` + окремий `ranlib`)
- **УВАГА:** Makefile використовує TAB для відступів, не пробіли!

### Тестування

```bash
# Build library
make

# Verify library exists
ls -la libft.a

# Check no relinking (second make should do nothing)
make

# Verify contents
ar -t libft.a

# Test compilation with library
cc -Wall -Wextra -Werror main.c -L. -lft -o test
./test

# Clean .o files
make clean
ls *.o  # should not exist

# Library should still exist after clean
ls libft.a  # should exist

# Full clean
make fclean
ls libft.a  # should not exist

# Rebuild from scratch
make re
ls libft.a  # should exist again
```

### Очікуваний результат

```bash
$ make
cc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
cc -Wall -Wextra -Werror -c ft_putstr.c -o ft_putstr.o
cc -Wall -Wextra -Werror -c ft_putnbr.c -o ft_putnbr.o
cc -Wall -Wextra -Werror -c ft_strlen.c -o ft_strlen.o
cc -Wall -Wextra -Werror -c ft_strcmp.c -o ft_strcmp.o
cc -Wall -Wextra -Werror -c ft_swap.c -o ft_swap.o
ar rcs libft.a ft_putchar.o ft_putstr.o ft_putnbr.o ft_strlen.o ft_strcmp.o ft_swap.o

$ make
make: Nothing to be done for 'all'.

$ make clean
rm -f ft_putchar.o ft_putstr.o ft_putnbr.o ft_strlen.o ft_strcmp.o ft_swap.o

$ make fclean
rm -f ft_putchar.o ft_putstr.o ft_putnbr.o ft_strlen.o ft_strcmp.o ft_swap.o
rm -f libft.a

$ make re
rm -f ft_putchar.o ft_putstr.o ft_putnbr.o ft_strlen.o ft_strcmp.o ft_swap.o
rm -f libft.a
cc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
...
ar rcs libft.a ...
```

## Підказки

<details>
<summary>Підказка 1: Базова структура Makefile</summary>

```makefile
NAME = libft.a

SRC = ft_putchar.c ft_putstr.c ft_putnbr.c ft_strlen.c ft_strcmp.c ft_swap.c

OBJ = $(SRC:.c=.o)

CC = cc
CFLAGS = -Wall -Wextra -Werror

all: $(NAME)

# ... rules ...

.PHONY: all clean fclean re
```

Зверни увагу на `$(SRC:.c=.o)` -- це заміна розширення. Якщо `SRC = ft_putchar.c`, то `OBJ = ft_putchar.o`.

`.PHONY` каже make, що `all`, `clean` тощо -- це НЕ файли, а команди. Без цього make може заплутатись, якщо існує файл з такою назвою.

</details>

<details>
<summary>Підказка 2: Правило для $(NAME)</summary>

```makefile
$(NAME): $(OBJ)
	ar rcs $(NAME) $(OBJ)
```

Це правило каже: "щоб створити `libft.a`, потрібні всі `.o` файли. Після їх створення -- запусти `ar rcs`."

Make автоматично знає, як створити `.o` з `.c` (implicit rule). Але якщо хочеш бути явним:

```makefile
%.o: %.c ft.h
	$(CC) $(CFLAGS) -c $< -o $@
```

- `$<` -- перший prerequisite (`.c` файл)
- `$@` -- target (`.o` файл)

Залежність від `ft.h` означає: якщо header змінився, всі `.o` перекомпілюються.

</details>

<details>
<summary>Підказка 3: No relinking -- як це працює</summary>

Make перевіряє **timestamp** файлів. Якщо `libft.a` новіший за всі `.o`, а всі `.o` новіші за `.c` -- нічого робити не треба.

Помилка, яку часто роблять:
```makefile
# WRONG — relinking every time!
all:
	$(CC) $(CFLAGS) -c $(SRC)
	ar rcs $(NAME) $(OBJ)
```

Правильно -- через залежності:
```makefile
# RIGHT — check timestamps
all: $(NAME)

$(NAME): $(OBJ)
	ar rcs $(NAME) $(OBJ)
```

Тепер `make` двічі -- друга команда каже "Nothing to be done", бо `$(NAME)` вже існує і новіший за `$(OBJ)`.

</details>

## Man сторінки

- `man make`
- `man ar`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| збірка | compilation | "La compilation du projet" |
| правило | regle | "Chaque regle du Makefile a une cible et des dependances" |
| залежність | dependance | "Les .o dependent des .c" |
| перекомпіляція | recompilation | "Pas de recompilation inutile" |
| очищення | nettoyage | "make clean pour le nettoyage" |

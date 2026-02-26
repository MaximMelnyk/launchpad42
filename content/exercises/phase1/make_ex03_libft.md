---
id: make_ex03_libft
module: makefile
phase: phase1
title: "libft Makefile"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["make_ex02_full"]
tags: ["makefile", "build", "c", "static-library", "ar"]
norminette: true
man_pages: ["make", "ar"]
multi_day: false
order: 26
---

# libft Makefile

## Завдання

Напиши Makefile, який створює статичну бібліотеку (`.a` файл) за допомогою утиліти `ar`. Це підготовка до модулів C09 та libft (перший проєкт після Piscine).

Статична бібліотека -- це архів об'єктних файлів (`.o`). Замість того щоб компілювати всі `.c` файли кожного разу, ти створюєш бібліотеку один раз та лінкуєш її.

### Підготовка

Створи директорію з кількома функціями:

**ft_putchar.c:**
```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}
```

**ft_putstr.c:**
```c
void	ft_putchar(char c);

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		ft_putchar(str[i]);
		i++;
	}
}
```

**ft_strlen.c:**
```c
int	ft_strlen(char *str)
{
	int	len;

	len = 0;
	while (str[len])
		len++;
	return (len);
}
```

**ft_swap.c:**
```c
void	ft_swap(int *a, int *b)
{
	int	tmp;

	tmp = *a;
	*a = *b;
	*b = tmp;
}
```

### Що потрібно зробити

Створи `Makefile` який:

1. Компілює всі `.c` у `.o`
2. Створює статичну бібліотеку `libft.a` за допомогою `ar rcs`
3. Має всі стандартні targets: `all`, `clean`, `fclean`, `re`
4. Не робить relinking

### Приклад Makefile

```makefile
NAME = libft.a

CC = gcc
CFLAGS = -Wall -Wextra -Werror
AR = ar rcs

SRC = ft_putchar.c \
      ft_putstr.c \
      ft_strlen.c \
      ft_swap.c

OBJ = $(SRC:.c=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(AR) $(NAME) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
```

### Перевірка

Після `make`, протестуй бібліотеку:

**test_main.c** (НЕ включати у Makefile):
```c
void	ft_putstr(char *str);
int		ft_strlen(char *str);

int	main(void)
{
	char	*msg;

	msg = "libft works!\n";
	ft_putstr(msg);
	return (0);
}
```

```bash
make
gcc -Wall -Wextra -Werror test_main.c -L. -lft -o test_program
./test_program
```

### Вимоги

- `NAME = libft.a` (статична бібліотека)
- `ar rcs` для створення бібліотеки (НЕ `gcc`)
- `make` створює `libft.a`
- `make` повторно -- `make: 'libft.a' is up to date.` (no relinking!)
- `make clean` видаляє `.o` файли
- `make fclean` видаляє `.o` та `libft.a`
- `make re` перезбирає все
- Бібліотека лінкується коректно (`-L. -lft`)
- Всі `.c` файли проходять Norminette
- Мультирядковий `SRC` з `\` для зручності читання

### Очікуваний результат

```bash
$ make
gcc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
gcc -Wall -Wextra -Werror -c ft_putstr.c -o ft_putstr.o
gcc -Wall -Wextra -Werror -c ft_strlen.c -o ft_strlen.o
gcc -Wall -Wextra -Werror -c ft_swap.c -o ft_swap.o
ar rcs libft.a ft_putchar.o ft_putstr.o ft_strlen.o ft_swap.o
$ make
make: 'libft.a' is up to date.
$ ar -t libft.a
ft_putchar.o
ft_putstr.o
ft_strlen.o
ft_swap.o
$ gcc -Wall -Wextra -Werror test_main.c -L. -lft -o test_program
$ ./test_program
libft works!
```

## Контекст Piscine

У Piscine модуль **C09** вимагає створити Makefile для бібліотеки `libft.a`. Після Piscine, **libft** -- це перший повноцінний проєкт 42, де ти збираєш бібліотеку з 30+ функцій.

Прапорці `ar rcs`:
- `r` -- replace (замінити файл у архіві, якщо існує)
- `c` -- create (створити архів, якщо не існує)
- `s` -- index (створити індекс для швидкого лінковки)

Лінковка з бібліотекою:
- `-L.` -- шукати бібліотеки у поточній директорії
- `-lft` -- лінкувати `libft.a` (префікс `lib` та суфікс `.a` додаються автоматично)

## Підказки

<details>
<summary>Підказка 1</summary>

`ar rcs` -- це НЕ компілятор. Це архіватор. Він бере готові `.o` файли та пакує їх у `.a` файл:

```bash
ar rcs libft.a ft_putchar.o ft_putstr.o ft_strlen.o
```

Тому процес збірки бібліотеки завжди двоетапний:
1. Компіляція `.c` --> `.o` (через `gcc -c`)
2. Архівація `.o` --> `.a` (через `ar rcs`)

</details>

<details>
<summary>Підказка 2</summary>

Мультирядковий список файлів з `\`:

```makefile
SRC = ft_putchar.c \
      ft_putstr.c \
      ft_strlen.c \
      ft_swap.c
```

Символ `\` в кінці рядка означає "продовження на наступному рядку". Це зручніше для читання та для git diff (додавання файлу = 1 рядок у diff).

**ВАЖЛИВО:** після `\` НЕ повинно бути пробілів! Інакше `make` не розпізнає продовження.

</details>

<details>
<summary>Підказка 3</summary>

No relinking перевірка для бібліотеки:

1. `make` -- створює `libft.a`
2. `make` ще раз -- `make: 'libft.a' is up to date.`
3. `touch ft_strlen.c` -- імітуємо зміну файлу
4. `make` -- перекомпілює ТІЛЬКИ `ft_strlen.o` та перезбирає `libft.a`

Якщо `make` перекомпілює ВСІ файли на кроці 4 -- у тебе проблема з relinking. Перевір, що правило `%.o: %.c` працює коректно.

</details>

## Man сторінки

- `man make`
- `man ar`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| бібліотека | bibliothèque | "Cree une bibliothèque statique" |
| статична | statique | "La bibliothèque statique libft.a" |
| архів | archive | "ar crée une archive de fichiers .o" |
| лінковка | edition de liens / linkage | "L'edition de liens avec -lft" |
| індекс | index | "Le flag 's' crée un index" |

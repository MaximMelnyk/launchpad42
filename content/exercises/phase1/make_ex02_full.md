---
id: make_ex02_full
module: makefile
phase: phase1
title: "Full Makefile"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["make_ex01_basic"]
tags: ["makefile", "build", "c", "clean", "fclean"]
norminette: true
man_pages: ["make", "rm"]
multi_day: false
order: 25
---

# Full Makefile

## Завдання

Напиши повний Makefile з усіма стандартними цілями (targets), які вимагає Piscine 42: `all`, `clean`, `fclean`, `re`. Також навчися працювати з об'єктними файлами (`.o`) та уникати relinking.

### Підготовка

Використовуй ті ж C-файли з попередньої вправи або створи нові:

**ft_putchar.c:**
```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
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

**main.c:**
```c
void	ft_putstr(char *str);
int		ft_strlen(char *str);
void	ft_putchar(char c);

int	main(void)
{
	char	*msg;

	msg = "Makefile works!\n";
	ft_putstr(msg);
	return (0);
}
```

### Що потрібно зробити

Створи `Makefile` з наступними цілями:

| Ціль | Дія |
|------|-----|
| `all` | Компілює програму `$(NAME)` |
| `clean` | Видаляє об'єктні файли (`.o`) |
| `fclean` | Виконує `clean` + видаляє `$(NAME)` |
| `re` | Виконує `fclean` + `all` (повна перекомпіляція) |

### Приклад Makefile

```makefile
NAME = megaphone

CC = gcc
CFLAGS = -Wall -Wextra -Werror

SRC = ft_putchar.c ft_strlen.c ft_putstr.c main.c
OBJ = $(SRC:.c=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
```

### Вимоги

- `make` компілює через об'єктні файли (`.c` --> `.o` --> binary)
- `make clean` видаляє тільки `.o` файли
- `make fclean` видаляє `.o` файли ТА виконуваний файл
- `make re` повністю перекомпілює (fclean + all)
- **No relinking:** повторний `make` НЕ перекомпілює, якщо нічого не змінилося
- Всі targets у `.PHONY`
- Використовується `rm -f` (не `rm` без `-f`, щоб не було помилки якщо файлів немає)
- C-файли проходять Norminette

### Очікуваний результат

```bash
$ make
gcc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
gcc -Wall -Wextra -Werror -c ft_strlen.c -o ft_strlen.o
gcc -Wall -Wextra -Werror -c ft_putstr.c -o ft_putstr.o
gcc -Wall -Wextra -Werror -c main.c -o main.o
gcc -Wall -Wextra -Werror -o megaphone ft_putchar.o ft_strlen.o ft_putstr.o main.o
$ ./megaphone
Makefile works!
$ make
make: 'megaphone' is up to date.
$ make clean
rm -f ft_putchar.o ft_strlen.o ft_putstr.o main.o
$ ls *.o 2>/dev/null
$ make fclean
rm -f ft_putchar.o ft_strlen.o ft_putstr.o main.o
rm -f megaphone
$ ls megaphone 2>/dev/null
$ make re
gcc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
...
gcc -Wall -Wextra -Werror -o megaphone ft_putchar.o ft_strlen.o ft_putstr.o main.o
```

## Контекст Piscine

Moulinette перевіряє кожний target окремо:

1. `make` -- має скомпілювати
2. `make` ще раз -- **НЕ** має перекомпілювати (no relinking!)
3. `make clean` -- `.o` зникають
4. `make fclean` -- binary теж зникає
5. `make re` -- все перекомпілюється з нуля

**No relinking** -- найчастіша помилка. Якщо ти не використовуєш `.o` файли, а компілюєш прямо з `.c`, то `make` буде перекомпілювати кожного разу. Це = 0 балів за Makefile.

## Підказки

<details>
<summary>Підказка 1</summary>

Ключ до no relinking -- це **об'єктні файли** та правило `%.o: %.c`:

```makefile
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
```

- `%` -- wildcard (будь-яке ім'я)
- `$<` -- перша залежність (`.c` файл)
- `$@` -- target (`.o` файл)
- `-c` -- компілювати без лінковки (створити `.o`)

Як це працює: `make` перевіряє дату модифікації `.o` vs `.c`. Якщо `.c` не змінився -- `.o` не перекомпілюється.

</details>

<details>
<summary>Підказка 2</summary>

Трансформація змінних:

```makefile
SRC = ft_putchar.c ft_strlen.c main.c
OBJ = $(SRC:.c=.o)
```

`$(SRC:.c=.o)` замінює `.c` на `.o` у кожному елементі. Тобто `OBJ` стає `ft_putchar.o ft_strlen.o main.o`.

Це дуже зручно: ти додаєш файл тільки в `SRC`, а `OBJ` оновлюється автоматично.

</details>

<details>
<summary>Підказка 3</summary>

`fclean: clean` означає, що перед виконанням `fclean`, спочатку виконається `clean`. Це залежність target від target:

```makefile
fclean: clean          # спочатку clean, потім fclean
	rm -f $(NAME)

re: fclean all         # спочатку fclean, потім all
```

Порядок залежностей має значення: `re: fclean all` означає "спочатку fclean, потім all".

</details>

## Man сторінки

- `man make`
- `man rm`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| об'єктний файл | fichier objet | "Compile en fichier objet (.o)" |
| очистити | nettoyer | "make clean nettoie les .o" |
| перекомпілювати | recompiler | "make re recompile tout" |
| зв'язування | liaison / linkage | "Pas de relinkage inutile" |
| ціль | cible | "Les cibles all, clean, fclean, re" |

---
id: make_ex01_basic
module: makefile
phase: phase1
title: "Basic Makefile"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["git_ex06_gitignore"]
tags: ["makefile", "build", "c"]
norminette: true
man_pages: ["make"]
multi_day: false
order: 24
---

# Basic Makefile

## Завдання

Напиши свій перший Makefile, який компілює просту C-програму. Makefile -- це файл-інструкція для утиліти `make`, яка автоматизує компіляцію. На Piscine кожний C-модуль починаючи з C09 вимагає Makefile.

### Підготовка

Створи директорію з C-файлами, які будеш компілювати:

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

**main.c:**
```c
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello from Makefile!\n");
	return (0);
}
```

### Що потрібно зробити

Створи файл `Makefile` з наступними вимогами:

1. **Target `all`** -- компілює програму
2. **Змінна `NAME`** = `hello` (ім'я виконуваного файлу)
3. **Змінна `CC`** = `gcc`
4. **Змінна `CFLAGS`** = `-Wall -Wextra -Werror`
5. **Змінна `SRC`** = список `.c` файлів
6. Команда `make` (або `make all`) повинна створити виконуваний файл `hello`

### Приклад Makefile

```makefile
NAME = hello

CC = gcc
CFLAGS = -Wall -Wextra -Werror

SRC = ft_putchar.c ft_putstr.c main.c

all: $(NAME)

$(NAME): $(SRC)
	$(CC) $(CFLAGS) -o $(NAME) $(SRC)

.PHONY: all
```

### Вимоги

- Файл називається рівно `Makefile` (з великої літери)
- `make` або `make all` компілює та створює файл `hello`
- Компіляція використовує прапорці `-Wall -Wextra -Werror`
- Змінні `NAME`, `CC`, `CFLAGS`, `SRC` визначені
- `.PHONY: all` оголошено
- **ОБОВ'ЯЗКОВО:** відступи у правилах (recipes) -- це TAB, не пробіли!
- C-файли проходять Norminette

### Очікуваний результат

```bash
$ make
gcc -Wall -Wextra -Werror -o hello ft_putchar.c ft_putstr.c main.c
$ ./hello
Hello from Makefile!
$ make
make: 'hello' is up to date.
```

## Контекст Piscine

Починаючи з C09, кожний модуль Piscine вимагає Makefile. Moulinette перевіряє:

- Чи існує файл `Makefile`
- Чи `make` компілює проєкт
- Чи використовуються правильні прапорці (`-Wall -Wextra -Werror`)
- Чи `make` не перекомпілює, якщо нічого не змінилося (no relinking)

**Критична помилка:** якщо у Makefile пробіли замість TAB -- `make` видасть помилку `*** missing separator. Stop.`

## Підказки

<details>
<summary>Підказка 1</summary>

Структура правила (rule) у Makefile:

```makefile
target: dependencies
	command
```

- **target** -- що створити (наприклад, `hello`)
- **dependencies** -- від чого залежить (наприклад, `.c` файли)
- **command** -- як створити (ОБОВ'ЯЗКОВО починається з TAB!)

Перевірити TAB vs пробіли у Vim: `:set list` (TAB показується як `^I`).

</details>

<details>
<summary>Підказка 2</summary>

Змінні у Makefile:

```makefile
NAME = hello          # визначити
$(NAME)               # використати

CC = gcc              # компілятор
CFLAGS = -Wall -Wextra -Werror  # прапорці
```

`$(VARIABLE)` -- це синтаксис підстановки змінної. `make` замінить `$(NAME)` на `hello` перед виконанням.

</details>

<details>
<summary>Підказка 3</summary>

`.PHONY` повідомляє `make`, що target -- це не файл, а команда. Без `.PHONY`, якщо існує файл з ім'ям `all`, `make all` скаже "up to date" і нічого не зробить.

```makefile
.PHONY: all
```

</details>

## Man сторінки

- `man make`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| компілювати | compiler | "Le Makefile compile le programme" |
| прапорець | drapeau / flag | "Les flags de compilation" |
| ціль | cible / target | "La cible 'all' compile tout" |
| залежність | dependance | "Les fichiers .c sont des dependances" |
| збірка | construction / build | "Lance le build avec make" |

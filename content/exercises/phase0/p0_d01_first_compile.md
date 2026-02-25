---
id: p0_d01_first_compile
module: p0
phase: phase0
title: "First Compile"
difficulty: 1
xp: 15
estimated_minutes: 20
prerequisites: ["p0_d01_hello_world"]
tags: ["c", "write", "functions", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 2
---

# First Compile

## Завдання

Навчися працювати з кількома файлами та створи свою першу функцію.

Створи два файли:

1. **`ft_putchar.c`** -- містить функцію `ft_putchar`, яка виводить один символ на стандартний вивід
2. **`main.c`** -- містить функцію `main`, яка викликає `ft_putchar` з символом `'A'`

### Прототип

```c
void	ft_putchar(char c);
```

### Вимоги

- Функція `ft_putchar` використовує `write(1, &c, 1)`
- Компілюй обидва файли разом: `gcc -Wall -Wextra -Werror ft_putchar.c main.c -o first_compile`
- Norminette: так
- В `main.c` додай прототип функції `ft_putchar` перед `main`

### Очікуваний результат

```
A
```

(символ `A`, без переходу на новий рядок)

## Підказки

<details>
<summary>Підказка 1</summary>

Оператор `&` повертає адресу змінної. Для `write` потрібна адреса буфера, тому передаємо `&c` -- адресу символу.

</details>

<details>
<summary>Підказка 2</summary>

Файл `ft_putchar.c`:
```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}
```

Файл `main.c`:
```c
void	ft_putchar(char c);

int	main(void)
{
	ft_putchar('A');
	return (0);
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| функція | fonction | "Écrire une fonction" |
| символ | caractère | "Afficher un caractère" |

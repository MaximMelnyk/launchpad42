---
id: p0_d02_ft_putchar
module: p0
phase: phase0
title: "ft_putchar"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["p0_d01_first_compile"]
tags: ["c", "write", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 4
---

# ft_putchar

## Завдання

Напиши повноцінну функцію `ft_putchar`, яка виводить один символ на стандартний вивід.

Ця функція стане твоїм основним інструментом виводу -- ти будеш використовувати її у кожному наступному завданні замість `printf`.

### Прототип

```c
void	ft_putchar(char c);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (man 2 write)
- Файловий дескриптор: `1` (stdout)
- Функція повинна працювати з будь-яким символом (літери, цифри, спецсимволи, `\n`)
- Файл: `ft_putchar.c`
- Norminette: так

### Тестування

Для перевірки створи `main.c`:

```c
void	ft_putchar(char c);

int	main(void)
{
	ft_putchar('H');
	ft_putchar('i');
	ft_putchar('!');
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hi!
```

## Підказки

<details>
<summary>Підказка 1</summary>

Функція `write` знаходиться в `<unistd.h>`. Вона приймає три аргументи:
1. Файловий дескриптор (1 = stdout)
2. Вказівник на буфер (адреса символу)
3. Кількість байтів для запису

</details>

<details>
<summary>Підказка 2</summary>

Щоб передати адресу символу `c`, використай оператор адреси: `&c`.
Повний виклик: `write(1, &c, 1);`

</details>

## Man сторінки

- `man 2 write`

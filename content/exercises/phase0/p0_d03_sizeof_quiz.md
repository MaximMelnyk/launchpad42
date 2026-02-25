---
id: p0_d03_sizeof_quiz
module: p0
phase: phase0
title: "Sizeof Quiz"
difficulty: 1
xp: 15
estimated_minutes: 15
prerequisites: ["p0_d03_variables"]
tags: ["c", "sizeof", "types", "memory"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 7
---

# Sizeof Quiz

## Завдання

Дізнайся, скільки байтів займає кожний базовий тип даних у C.

Напиши програму, яка виводить розмір кожного типу у форматі:

```
char: X
int: X
float: X
double: X
```

де `X` -- розмір типу в байтах.

### Вимоги

- Використовуй оператор `sizeof` для визначення розміру
- Для виводу числа використовуй `ft_putnbr`
- Для виводу рядків використовуй `ft_putstr`
- НЕ використовуй `printf`
- Файли: `main.c` + `ft_putchar.c` + `ft_putstr.c` + `ft_putnbr.c`
- Norminette: так

### Очікуваний результат (на більшості 64-бітних систем)

```
char: 1
int: 4
float: 4
double: 8
```

**Увага:** на деяких системах значення можуть відрізнятися. Це нормально -- в цьому і суть вправи.

## Підказки

<details>
<summary>Підказка 1</summary>

Оператор `sizeof` повертає розмір типу або змінної в байтах. Його можна використовувати так:
```c
sizeof(char)
sizeof(int)
```

Результат `sizeof` має тип `size_t`, але для невеликих значень його можна безпечно привести до `int`.

</details>

<details>
<summary>Підказка 2</summary>

```c
ft_putstr("char: ");
ft_putnbr((int)sizeof(char));
ft_putchar('\n');
```

Повтори для кожного типу.

</details>

## Man сторінки

- `man 2 write`

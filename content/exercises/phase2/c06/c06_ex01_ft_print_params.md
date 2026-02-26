---
id: c06_ex01_ft_print_params
module: c06
phase: phase2
title: "ft_print_params"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c06_ex00_ft_print_program_name"]
tags: ["c", "argv"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 82
---

# ft_print_params

## Завдання

Напиши програму, яка виводить усі аргументи командного рядка, по одному на рядок.

Тепер, коли ти знаєш як працює `argv[0]`, час обробити решту аргументів. `argv[1]` -- перший аргумент користувача, `argv[2]` -- другий, і так далі до `argv[argc - 1]`. Після останнього аргументу `argv[argc]` завжди дорівнює `NULL`.

Ця вправа вчить тебе ітерувати по масиву рядків -- навичка, яка буде критично важливою для складніших завдань (наприклад, `ft_sort_params`).

### Прототип

```c
int	main(int argc, char **argv);
```

### Вимоги

- Виведи аргументи `argv[1]` до `argv[argc - 1]`, кожен з наступним `'\n'`
- НЕ виводь `argv[0]` (ім'я програми)
- Якщо аргументів немає -- нічого не виводь
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_print_params.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```bash
gcc -Wall -Wextra -Werror -o ft_print_params ft_print_params.c
./ft_print_params hello world 42
```

### Очікуваний результат

```
hello
world
42
```

Без аргументів:

```bash
./ft_print_params
```

Нічого не виводить (порожній вивід).

## Підказки

<details>
<summary>Підказка 1</summary>

Використай змінну-лічильник `i`, яка починається з `1` (пропускаємо `argv[0]`). У циклі `while (i < argc)` виводь кожен `argv[i]` та `'\n'`.

</details>

<details>
<summary>Підказка 2</summary>

Альтернативний підхід: не використовуй `argc` взагалі. Масив `argv` завжди закінчується `NULL`:
```c
i = 1;
while (argv[i])
{
	ft_putstr(argv[i]);
	ft_putchar('\n');
	i++;
}
```

Обидва підходи коректні.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| параметр | parametre | "Afficher les parametres" |
| масив | tableau | "Un tableau de chaines" |
| ітерувати | iterer / parcourir | "Parcourir le tableau" |

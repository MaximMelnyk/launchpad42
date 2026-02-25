---
id: p0_d01_hello_world
module: p0
phase: phase0
title: "Hello World"
difficulty: 1
xp: 15
estimated_minutes: 20
prerequisites: []
tags: ["c", "write", "basics", "setup"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 1
---

# Hello World

## Завдання

Налаштуй робоче середовище та напиши свою першу програму на C.

Створи файл `hello.c`, який виводить рядок `Hello, 42!` з переходом на новий рядок, використовуючи **тільки** системний виклик `write()`.

### Прототип main

```c
int	main(void)
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (man 2 write)
- Жодного `printf` або `puts` -- тільки `write`
- Файловий дескриптор: `1` (stdout)
- Компілюй з прапорцями: `gcc -Wall -Wextra -Werror hello.c -o hello`
- Norminette: так

### Очікуваний результат

```
Hello, 42!
```

(з переходом на новий рядок в кінці)

### Кроки для виконання

1. Встанови `gcc`, якщо ще не встановлений: `sudo apt install gcc`
2. Створи файл `hello.c`
3. Підключи заголовковий файл `<unistd.h>` (там знаходиться `write`)
4. Напиши функцію `main`, яка викликає `write` один раз
5. Скомпілюй: `gcc -Wall -Wextra -Werror hello.c -o hello`
6. Запусти: `./hello`

## Підказки

<details>
<summary>Підказка 1</summary>

Функція `write` має три параметри:
- `fd` -- файловий дескриптор (1 = stdout)
- `buf` -- вказівник на дані для запису
- `count` -- кількість байтів

Виклик: `write(1, "Hello, 42!\n", 11);`

</details>

<details>
<summary>Підказка 2</summary>

Порахуй символи уважно: `H-e-l-l-o-,- -4-2-!-\n` = 11 байтів. Символ `\n` -- це один байт (перехід на новий рядок).

</details>

<details>
<summary>Підказка 3 (повне рішення)</summary>

```c
#include <unistd.h>

int	main(void)
{
	write(1, "Hello, 42!\n", 11);
	return (0);
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| програма | programme | "Écrire un programme en C" |
| компілювати | compiler | "Il faut compiler le code" |
| виконати | exécuter | "Exécuter le programme" |

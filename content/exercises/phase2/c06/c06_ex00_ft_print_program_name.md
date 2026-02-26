---
id: c06_ex00_ft_print_program_name
module: c06
phase: phase2
title: "ft_print_program_name"
difficulty: 1
xp: 15
estimated_minutes: 10
prerequisites: ["c04_ex01_ft_putstr"]
tags: ["c", "argv", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 81
---

# ft_print_program_name

## Завдання

Напиши програму, яка виводить своє власне ім'я (назву виконуваного файлу) з наступним символом нового рядка.

Модуль C06 присвячений роботі з **аргументами командного рядка** (`argc` / `argv`). Коли ти запускаєш програму в терміналі, оболонка (shell) розбиває введений рядок на слова та передає їх програмі через масив `argv`. Перший елемент `argv[0]` -- це завжди ім'я самої програми.

На Piscine ти побачиш завдання де потрібно обробляти вхідні дані без `scanf` -- тільки через аргументи.

### Прототип

```c
int	main(int argc, char **argv);
```

### Вимоги

- Виведи `argv[0]` з наступним `'\n'`
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_print_program_name.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```bash
gcc -Wall -Wextra -Werror -o ft_print_program_name ft_print_program_name.c
./ft_print_program_name
```

### Очікуваний результат

```
./ft_print_program_name
```

Якщо перейменувати файл:

```bash
cp ft_print_program_name my_prog
./my_prog
```

Виведе:

```
./my_prog
```

## Підказки

<details>
<summary>Підказка 1</summary>

`argv[0]` -- це рядок (`char *`), який містить ім'я програми. Тобі потрібно вивести кожен символ цього рядка за допомогою `write`, а потім додати `'\n'`.

</details>

<details>
<summary>Підказка 2</summary>

Можна написати допоміжну функцію `ft_putstr`, яка виводить рядок посимвольно:
```c
void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}
```

Тоді у `main` просто виклич `ft_putstr(argv[0])` та виведи `'\n'`.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| аргумент | argument | "Les arguments de la ligne de commande" |
| програма | programme | "Le nom du programme" |
| командний рядок | ligne de commande | "Lire la ligne de commande" |

---
id: c06_ex02_ft_rev_params
module: c06
phase: phase2
title: "ft_rev_params"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c06_ex01_ft_print_params"]
tags: ["c", "argv"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 83
---

# ft_rev_params

## Завдання

Напиши програму, яка виводить аргументи командного рядка у зворотному порядку, по одному на рядок.

Ця вправа -- варіація попередньої, але замість виведення від першого до останнього аргументу, ти виводиш від останнього до першого. Щоб це зробити, тобі потрібно стартувати з `argc - 1` та зменшувати лічильник до `1`.

### Прототип

```c
int	main(int argc, char **argv);
```

### Вимоги

- Виведи аргументи у зворотному порядку: `argv[argc - 1]`, `argv[argc - 2]`, ..., `argv[1]`
- НЕ виводь `argv[0]` (ім'я програми)
- Якщо аргументів немає -- нічого не виводь
- Кожен аргумент з наступним `'\n'`
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файл: `ft_rev_params.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```bash
gcc -Wall -Wextra -Werror -o ft_rev_params ft_rev_params.c
./ft_rev_params hello world 42
```

### Очікуваний результат

```
42
world
hello
```

З одним аргументом:

```bash
./ft_rev_params only
```

```
only
```

## Підказки

<details>
<summary>Підказка 1</summary>

Ініціалізуй лічильник значенням `argc - 1` та зменшуй його, поки він більший за `0`:
```c
i = argc - 1;
while (i > 0)
{
	// print argv[i]
	i--;
}
```

</details>

<details>
<summary>Підказка 2</summary>

Зверни увагу: умова `i > 0`, а НЕ `i >= 0`. Це гарантує, що `argv[0]` (ім'я програми) не буде виведено. `argv[1]` -- це перший аргумент, `argv[argc - 1]` -- останній.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| зворотний | inverse / a l'envers | "Afficher a l'envers" |
| лічильник | compteur | "Decrementer le compteur" |
| зменшувати | decrementer | "Decrementer de 1" |

---
id: c04_ex00_ft_strlen
module: c04
phase: phase2
title: "ft_strlen (review)"
difficulty: 1
xp: 15
estimated_minutes: 5
prerequisites: ["c01_ex06_ft_strlen"]
tags: ["c", "strings", "review"]
norminette: true
man_pages: ["strlen"]
multi_day: false
order: 65
---

# ft_strlen (review)

## Завдання

**Вправа на повторення (review).** Перепиши функцію `ft_strlen` по пам'яті.

На Piscine `ft_strlen` -- це одна з перших функцій, яку ти напишеш на кожному екзамені. Вона повинна бути в твоїх пальцях автоматично, як рефлекс. Засікай час: ти маєш написати її за 2-3 хвилини.

**НЕ дивись на своє попереднє рішення.** Закрий все і пиши з нуля.

### Прототип

```c
int	ft_strlen(char *str);
```

### Вимоги

- Переписати по пам'яті (НЕ дивлячись на попередні рішення)
- Повертай кількість символів у рядку (без `'\0'`)
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strlen`
- Файл: `ft_strlen.c`
- Norminette: так
- 42 header: обов'язковий
- Цільовий час: 2-3 хвилини

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_strlen(char *str);

int	main(void)
{
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("42 Paris Piscine"));
	ft_putchar('\n');
	ft_putnbr(ft_strlen("a"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
5
0
16
1
```

## Підказки

<details>
<summary>Мета-підказка</summary>

Це вправа на recall, а не на вивчення. Якщо не можеш написати `ft_strlen` за 3 хвилини -- поверни увагу на C01 і потренуйся ще. На екзамені Piscine у тебе не буде часу думати над базовими функціями.

Технічних підказок немає навмисно.

</details>

## Man сторінки

- `man 3 strlen`

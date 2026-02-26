---
id: c04_ex01_ft_putstr
module: c04
phase: phase2
title: "ft_putstr (review)"
difficulty: 1
xp: 15
estimated_minutes: 5
prerequisites: ["c01_ex05_ft_putstr"]
tags: ["c", "strings", "review"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 66
---

# ft_putstr (review)

## Завдання

**Вправа на повторення (review).** Перепиши функцію `ft_putstr` по пам'яті.

`ft_putstr` -- це твій основний інструмент виводу рядків. На Piscine ти будеш використовувати її в кожному проекті, на кожному екзамені. Написання повинно бути автоматичним.

**НЕ дивись на своє попереднє рішення.** Засікай час: ціль -- 2-3 хвилини.

### Прототип

```c
void	ft_putstr(char *str);
```

### Вимоги

- Переписати по пам'яті (НЕ дивлячись на попередні рішення)
- Виводь кожен символ рядка на stdout через `ft_putchar`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`
- Файли: `ft_putstr.c` + `ft_putchar.c`
- Norminette: так
- 42 header: обов'язковий
- Цільовий час: 2-3 хвилини

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello, Piscine!");
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr("42\n");
	ft_putstr("Review OK\n");
	return (0);
}
```

### Очікуваний результат

```
Hello, Piscine!
42
Review OK
```

## Підказки

<details>
<summary>Мета-підказка</summary>

Це вправа на recall. Якщо не пам'ятаєш -- це сигнал повернутися до C01 і потренуватися. На екзамені не буде часу згадувати базові функції.

Технічних підказок немає навмисно.

</details>

## Man сторінки

- `man 2 write`

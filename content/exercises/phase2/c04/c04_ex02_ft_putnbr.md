---
id: c04_ex02_ft_putnbr
module: c04
phase: phase2
title: "ft_putnbr (review)"
difficulty: 1
xp: 15
estimated_minutes: 5
prerequisites: ["p0_d03_ft_putnbr"]
tags: ["c", "output", "review"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 67
---

# ft_putnbr (review)

## Завдання

**Вправа на повторення (review).** Перепиши функцію `ft_putnbr` по пам'яті.

`ft_putnbr` -- це одна з трьох найважливіших функцій на Piscine (разом з `ft_putchar` та `ft_putstr`). Вона повинна працювати коректно з `INT_MIN`, від'ємними числами та нулем. На екзамені ти маєш написати її за 5 хвилин.

**НЕ дивись на своє попереднє рішення.** Засікай час: ціль -- 3-5 хвилин.

### Прототип

```c
void	ft_putnbr(int nb);
```

### Вимоги

- Переписати по пам'яті (НЕ дивлячись на попередні рішення)
- Виводи кожну цифру через `ft_putchar`
- Обробляй `INT_MIN` (-2147483648) коректно
- Обробляй від'ємні числа (виводь `'-'`)
- Обробляй `0`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `itoa`
- Файли: `ft_putnbr.c` + `ft_putchar.c`
- Norminette: так
- 42 header: обов'язковий
- Цільовий час: 3-5 хвилин

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);

int	main(void)
{
	ft_putnbr(42);
	ft_putchar('\n');
	ft_putnbr(-42);
	ft_putchar('\n');
	ft_putnbr(0);
	ft_putchar('\n');
	ft_putnbr(-2147483648);
	ft_putchar('\n');
	ft_putnbr(2147483647);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
42
-42
0
-2147483648
2147483647
```

## Підказки

<details>
<summary>Мета-підказка</summary>

Це вправа на recall. Ключові моменти, які ти маєш пам'ятати:
1. `INT_MIN` не можна просто зробити додатнім
2. Рекурсія через `nb / 10` та `nb % 10`
3. Від'ємне число: виведи `'-'` та інвертуй

Якщо не пам'ятаєш обробку `INT_MIN` -- запиши це як точку для повторення.

</details>

## Man сторінки

- `man 2 write`

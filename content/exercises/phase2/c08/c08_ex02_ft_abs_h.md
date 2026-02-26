---
id: c08_ex02_ft_abs_h
module: c08
phase: phase2
title: "ft_abs.h"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c08_ex01_ft_boolean_h"]
tags: ["c", "headers", "macros"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 99
---

# ft_abs.h

## Завдання

Створи заголовний файл `ft_abs.h`, який містить макрос `ABS` для обчислення абсолютного значення числа.

**Абсолютне значення** (модуль числа) -- це число без знаку: `ABS(-5)` = `5`, `ABS(3)` = `3`, `ABS(0)` = `0`.

**ВАЖЛИВО: тернарний оператор у макросі.** Norminette забороняє тернарний оператор (`? :`) у коді функцій. Але макроси -- це НЕ код функцій, це інструкції препроцесора. Тому в макросах тернарний оператор дозволений. Це єдиний виняток, і саме так це робиться у Piscine.

### Вміст файлу

```c
#ifndef FT_ABS_H
# define FT_ABS_H

# define ABS(Value) ((Value) < 0 ? -(Value) : (Value))

#endif
```

### Вимоги

- Файл: `ft_abs.h`
- Include guard: `#ifndef FT_ABS_H` / `# define FT_ABS_H` / `#endif`
- Макрос `ABS(Value)` -- обчислює абсолютне значення
- ОБОВ'ЯЗКОВО: дужки навколо кожного використання `Value`
- Тернарний оператор: дозволений у макросах (виняток із правила Norminette)
- 42 header: обов'язковий
- Norminette: так
- Заборонено: `printf`, `scanf`, `puts`

### Тестування

```c
#include <unistd.h>
#include "ft_abs.h"

void	ft_putnbr(int nb)
{
	char	c;

	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		write(1, "-", 1);
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	c = (nb % 10) + '0';
	write(1, &c, 1);
}

int	main(void)
{
	ft_putnbr(ABS(-5));
	write(1, "\n", 1);
	ft_putnbr(ABS(3));
	write(1, "\n", 1);
	ft_putnbr(ABS(0));
	write(1, "\n", 1);
	ft_putnbr(ABS(-2147483647));
	write(1, "\n", 1);
	return (0);
}
```

```bash
gcc -Wall -Wextra -Werror -o test_abs main.c
./test_abs
```

### Очікуваний результат

```
5
3
0
2147483647
```

## Підказки

<details>
<summary>Підказка 1</summary>

Чому дужки навколо `Value` критичні? Розглянь без дужок:

```c
#define ABS(Value) Value < 0 ? -Value : Value
```

Якщо викликати `ABS(a - b)`, препроцесор підставить:
```c
a - b < 0 ? -a - b : a - b
```

Це повний хаос через пріоритет операторів! З дужками:
```c
((a - b) < 0 ? -(a - b) : (a - b))
```

Все коректно. **Золоте правило макросів: обгорни ВСЕ в дужки.**

</details>

<details>
<summary>Підказка 2</summary>

Тернарний оператор `? :` -- це скорочений `if/else`:

```c
result = (condition) ? value_if_true : value_if_false;
```

Еквівалент:
```c
if (condition)
    result = value_if_true;
else
    result = value_if_false;
```

У макросах це необхідно, бо макрос має бути одним виразом (expression), а не блоком коду (statement). `if/else` -- це statement, `? :` -- це expression.

</details>

## Man сторінки

- `man gcc` (прапорець `-E` для перегляду результату препроцесингу)
- `man abs` (стандартна функція abs для порівняння)

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| абсолютне значення | valeur absolue | "La valeur absolue de -5 est 5" |
| тернарний оператор | operateur ternaire | "L'operateur ternaire est permis dans les macros" |
| вираз | expression | "Une expression retourne une valeur" |

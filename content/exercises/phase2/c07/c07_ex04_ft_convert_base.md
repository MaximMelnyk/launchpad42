---
id: c07_ex04_ft_convert_base
module: c07
phase: phase2
title: "ft_convert_base"
difficulty: 4
xp: 60
estimated_minutes: 90
prerequisites: ["c04_ex05_ft_atoi_base", "c04_ex04_ft_putnbr_base"]
tags: ["c", "malloc", "conversion", "base"]
norminette: true
man_pages: ["malloc"]
multi_day: false
order: 89
---

# ft_convert_base

## Завдання

Напиши функцію `ft_convert_base`, яка конвертує число з однієї системи числення в іншу, повертаючи результат як malloc'd рядок.

Ця вправа поєднує знання з C04 (`ft_atoi_base` та `ft_putnbr_base`) з динамічною пам'яттю. Замість виведення результату через `write`, ти записуєш його в новий рядок.

Алгоритм:
1. Перевір валідність обох баз
2. Парси `nbr` у десяткове число, використовуючи `base_from`
3. Конвертуй десяткове число у рядок, використовуючи `base_to`
4. Поверни malloc'd рядок

### Прототип

```c
char	*ft_convert_base(char *nbr, char *base_from, char *base_to);
```

### Вимоги

- Парси рядок `nbr` як число в системі числення `base_from`
- Конвертуй його в рядок у системі числення `base_to`
- Поверни результат як новий malloc'd рядок
- Обробляй від'ємні числа (знак `-` або `+` на початку)
- Пропускай початкові пробіли та табуляції (whitespace)
- Валідація баз: довжина >= 2, без дублікатів, без `+`, `-`, пробілів
- Якщо база невалідна -- поверни `NULL`
- Якщо `malloc` повертає `NULL` -- поверни `NULL`
- Дозволені функції: `malloc`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `atoi`, `itoa`, `strtol`
- Файли: `ft_convert_base.c`, `ft_convert_base_utils.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>
#include <stdlib.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);
char	*ft_convert_base(char *nbr, char *base_from, char *base_to);

int	main(void)
{
	char	*result;

	result = ft_convert_base("42", "0123456789", "01");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_convert_base("101010", "01", "0123456789");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_convert_base("2A", "0123456789ABCDEF", "0123456789");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_convert_base("-42", "0123456789", "0123456789ABCDEF");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_convert_base("0", "0123456789", "01");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_convert_base("42", "0", "01");
	if (result == NULL)
		write(1, "NULL\n", 5);
	result = ft_convert_base("42", "0123456789", "0+1");
	if (result == NULL)
		write(1, "NULL\n", 5);
	return (0);
}
```

### Очікуваний результат

```
101010
42
42
-2A
0
NULL
NULL
```

## Підказки

<details>
<summary>Підказка 1</summary>

Розділи задачу на підфункції (Norminette вимагає це через обмеження на кількість рядків):
1. `ft_check_base` -- валідація бази (довжина >= 2, без дублікатів, без `+`/`-`/пробілів)
2. `ft_atoi_base` -- парсинг рядка у `long` за базою
3. `ft_nbr_len` -- обчислення кількості цифр для результату
4. `ft_convert_base` -- головна функція

Використай два файли: `ft_convert_base.c` та `ft_convert_base_utils.c`.

</details>

<details>
<summary>Підказка 2</summary>

Для визначення довжини результату:
```c
int	ft_nbr_len(long nbr, int base_len)
{
	int	len;

	len = 0;
	if (nbr <= 0)
		len = 1;
	while (nbr != 0)
	{
		nbr = nbr / base_len;
		len++;
	}
	return (len);
}
```

Якщо число від'ємне, додай 1 для знака `-`.

</details>

<details>
<summary>Підказка 3</summary>

Конвертація числа в рядок (від кінця до початку):
```c
// Allocate result string
result[len] = '\0';
if (n < 0)
{
	result[0] = '-';
	n = -n;
}
while (len > start)
{
	len--;
	result[len] = base_to[n % base_len];
	n = n / base_len;
}
```

Де `start` = 1, якщо число від'ємне, або 0 інакше. Використовуй `long` замість `int`, щоб коректно обробити `-2147483648`.

</details>

## Man сторінки

- `man 3 malloc`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| система числення | base / systeme de numeration | "Convertir d'une base a une autre" |
| конвертувати | convertir | "Convertir en hexadecimal" |
| валідація | validation | "Valider la base" |
| від'ємний | negatif | "Gerer les nombres negatifs" |

---
id: c04_ex04_ft_putnbr_base
module: c04
phase: phase2
title: "ft_putnbr_base"
difficulty: 4
xp: 60
estimated_minutes: 60
prerequisites: ["c04_ex03_ft_atoi"]
tags: ["c", "conversion", "base"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 69
---

# ft_putnbr_base

## Завдання

Напиши функцію `ft_putnbr_base`, яка виводить число у заданій системі числення.

Це перша по-справжньому складна вправа модуля C04. Ти маєш не тільки вивести число в довільній базі, а й валідувати саму базу. На Piscine ця вправа часто здається складною, бо поєднує логіку `ft_putnbr` з обробкою помилок.

### Прототип

```c
void	ft_putnbr_base(int nbr, char *base);
```

### Вимоги

- Виведи число `nbr` у системі числення, визначеній рядком `base`
- Кожен символ `base` -- це цифра цієї системи (наприклад, `"0123456789ABCDEF"` = шістнадцяткова)
- **Валідація бази:** нічого не виводь, якщо:
  - Довжина бази менше 2
  - У базі є дублікати символів
  - У базі є символи `+` або `-`
- Обробляй від'ємні числа (виведи `'-'` перед числом)
- Обробляй `INT_MIN` (-2147483648) коректно
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `itoa`
- Файл: `ft_putnbr_base.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr_base(int nbr, char *base);

int	main(void)
{
	ft_putnbr_base(42, "0123456789");
	ft_putchar('\n');
	ft_putnbr_base(42, "0123456789ABCDEF");
	ft_putchar('\n');
	ft_putnbr_base(255, "0123456789ABCDEF");
	ft_putchar('\n');
	ft_putnbr_base(10, "01");
	ft_putchar('\n');
	ft_putnbr_base(-42, "0123456789");
	ft_putchar('\n');
	ft_putnbr_base(0, "0123456789");
	ft_putchar('\n');
	ft_putnbr_base(-2147483648, "0123456789");
	ft_putchar('\n');
	ft_putnbr_base(42, "0");
	ft_putnbr_base(42, "01+");
	ft_putnbr_base(42, "0112");
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
42
2A
FF
1010
-42
0
-2147483648

```

## Підказки

<details>
<summary>Підказка 1</summary>

Розбий задачу на допоміжні функції (Norminette обмежує 25 рядків на функцію!):
1. `ft_check_base` -- валідація бази (повертає довжину бази або 0 при помилці)
2. `ft_putnbr_base` -- основна функція (обробка знаку + рекурсія)

Для валідації перевір: довжина >= 2, без `+`/`-`, без дублікатів.

</details>

<details>
<summary>Підказка 2</summary>

Перевірка на дублікати:
```c
i = 0;
while (base[i])
{
    j = i + 1;
    while (base[j])
    {
        if (base[i] == base[j])
            return (0);
        j++;
    }
    i++;
}
```

Це O(n^2) алгоритм, але для коротких баз він достатній.

</details>

<details>
<summary>Підказка 3</summary>

Рекурсивний вивід у базі:
```c
if (nbr >= base_len)
    ft_putnbr_base_recursive(nbr / base_len, base, base_len);
ft_putchar(base[nbr % base_len]);
```

Для від'ємних чисел: конвертуй у `long` щоб безпечно обробити `INT_MIN`:
```c
long	n;

n = nbr;
if (n < 0)
{
    ft_putchar('-');
    n = -n;
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| база | base | "Convertir en base hexadécimale" |
| двійкова | binaire | "Le système binaire" |
| шістнадцяткова | hexadécimal | "Notation hexadécimale" |
| валідація | validation | "Valider la base" |

---
id: c04_ex05_ft_atoi_base
module: c04
phase: phase2
title: "ft_atoi_base"
difficulty: 4
xp: 60
estimated_minutes: 60
prerequisites: ["c04_ex04_ft_putnbr_base"]
tags: ["c", "conversion", "base"]
norminette: true
man_pages: []
multi_day: false
order: 70
---

# ft_atoi_base

## Завдання

Напиши функцію `ft_atoi_base`, яка конвертує рядок із заданої системи числення у ціле число.

Це фінальна і найскладніша вправа модуля C04. Вона поєднує логіку `ft_atoi` (whitespace, знаки) з `ft_putnbr_base` (валідація бази, конвертація). Якщо ти впорався з двома попередніми вправами -- ця зібере все разом.

### Прототип

```c
int	ft_atoi_base(char *str, char *base);
```

### Вимоги

- Конвертуй рядок `str`, записаний у системі числення `base`, у ціле число
- **Whitespace:** пропускай початкові пробіли та табуляції (`' '`, `'\t'`, `'\n'`, `'\v'`, `'\f'`, `'\r'`)
- **Знаки:** обробляй `+` та `-` (множинні знаки, як у `ft_atoi`)
- **Валідація бази** (ідентично `ft_putnbr_base`):
  - Довжина >= 2
  - Без дублікатів
  - Без `+`, `-`, whitespace
- Повертай `0` при невалідній базі або якщо немає валідних цифр
- Зупиняйся на першому символі, якого немає в базі
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `atoi`, `strtol`
- Файл: `ft_atoi_base.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_atoi_base(char *str, char *base);

int	main(void)
{
	ft_putnbr(ft_atoi_base("2A", "0123456789ABCDEF"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("FF", "0123456789ABCDEF"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("1010", "01"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("  -2A", "0123456789ABCDEF"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("42", "0123456789"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("   --42", "0123456789"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("0", "0123456789"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("42", "0"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("42", "0112"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("abc", "0123456789"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
42
255
10
-42
42
42
0
0
0
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Розбий на допоміжні функції:
1. `ft_check_base` -- валідація бази (перевикористай з `ft_putnbr_base`)
2. `ft_get_index` -- повертає індекс символу в базі (або `-1` якщо не знайдено)
3. `ft_atoi_base` -- основна логіка: whitespace -> знаки -> парсинг цифр

</details>

<details>
<summary>Підказка 2</summary>

Функція пошуку індексу символу в базі:
```c
int	ft_get_index(char c, char *base)
{
    int	i;

    i = 0;
    while (base[i])
    {
        if (base[i] == c)
            return (i);
        i++;
    }
    return (-1);
}
```

Якщо `ft_get_index` повертає `-1` -- це кінець числа.

</details>

<details>
<summary>Підказка 3</summary>

Основна логіка парсингу:
```c
result = 0;
while (ft_get_index(*str, base) != -1)
{
    result = result * base_len + ft_get_index(*str, base);
    str++;
}
return (result * sign);
```

Зверни увагу: `base_len` -- це довжина бази (основа системи числення). Для hex це 16, для binary -- 2.

</details>

## Man сторінки

- Специфічна для 42, аналог libc `strtol` з довільною базою

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| конвертувати | convertir | "Convertir de la base N en decimal" |
| індекс | indice | "L'indice du caractere dans la base" |
| десятковий | decimal | "Resultat en decimal" |

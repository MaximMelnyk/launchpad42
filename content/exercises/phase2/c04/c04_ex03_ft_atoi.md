---
id: c04_ex03_ft_atoi
module: c04
phase: phase2
title: "ft_atoi"
difficulty: 3
xp: 40
estimated_minutes: 45
prerequisites: ["c04_ex02_ft_putnbr"]
tags: ["c", "conversion", "parsing"]
norminette: true
man_pages: ["atoi"]
multi_day: false
order: 68
---

# ft_atoi

## Завдання

Напиши функцію `ft_atoi`, яка конвертує рядок у ціле число.

Це одна з найпопулярніших екзаменаційних задач на Piscine. `ft_atoi` тестує вміння парсити рядок: пропускати пробіли, обробляти знаки, витягувати число. Поведінка повинна бути ідентичною стандартній `atoi` з libc.

**Увага:** поведінка libc `atoi` з множинними знаками специфічна. Парна кількість `-` дає додатнє число, непарна -- від'ємне. Знаки `+` не змінюють результат.

### Прототип

```c
int	ft_atoi(char *str);
```

### Вимоги

- Відтвори поведінку стандартної функції `atoi` (man 3 atoi)
- Пропускай початкові пробіли та табуляції (whitespace: `' '`, `'\t'`, `'\n'`, `'\v'`, `'\f'`, `'\r'`)
- Обробляй опціональні знаки `+` та `-` (може бути декілька)
- Парна кількість `-` = додатнє, непарна = від'ємне
- Після першого не-знакового та не-цифрового символу -- зупинись
- Повертай `0` якщо рядок не містить цифр після обробки
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `atoi`, `strtol`
- Файл: `ft_atoi.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_atoi(char *str);

int	main(void)
{
	ft_putnbr(ft_atoi("42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("   42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("  +42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("  -42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi(" --+--+123abc"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("  ---42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("-2147483648"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("0"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("   "));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("abc123"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
42
42
42
-42
123
42
-2147483648
0
0
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм складається з трьох етапів:
1. **Пропуск whitespace:** `while (*str == ' ' || *str == '\t' || ...)`
2. **Обробка знаків:** рахуй кількість `-`. Парна = додатнє, непарна = від'ємне
3. **Парсинг цифр:** `result = result * 10 + (*str - '0')`

</details>

<details>
<summary>Підказка 2</summary>

Для обробки знаків:
```c
sign = 1;
while (*str == '+' || *str == '-')
{
    if (*str == '-')
        sign = sign * (-1);
    str++;
}
```

Це автоматично обробляє множинні знаки: `---` дає `sign = -1`, `--` дає `sign = 1`.

</details>

<details>
<summary>Підказка 3</summary>

Для перевірки whitespace можна використати таку функцію (або inline):
```c
while (*str == ' ' || *str == '\t' || *str == '\n'
    || *str == '\v' || *str == '\f' || *str == '\r')
    str++;
```

Для парсингу цифр:
```c
result = 0;
while (*str >= '0' && *str <= '9')
{
    result = result * 10 + (*str - '0');
    str++;
}
return (result * sign);
```

</details>

## Man сторінки

- `man 3 atoi`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| конвертувати | convertir | "Convertir une chaine en entier" |
| парсити | analyser | "Analyser les caracteres un par un" |
| знак | signe | "Le signe du nombre" |
| пробіл | espace | "Ignorer les espaces" |

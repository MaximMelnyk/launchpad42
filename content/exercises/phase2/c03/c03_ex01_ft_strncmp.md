---
id: c03_ex01_ft_strncmp
module: c03
phase: phase2
title: "ft_strncmp"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c03_ex00_ft_strcmp"]
tags: ["c", "strings", "compare"]
norminette: true
man_pages: ["strncmp"]
multi_day: false
order: 60
---

# ft_strncmp

## Завдання

Напиши функцію `ft_strncmp`, яка порівнює не більше `n` символів двох рядків.

Це безпечніша версія `ft_strcmp` -- вона обмежує кількість символів для порівняння. На Piscine цей патерн (обмеження через `n`) зустрічається постійно: `strncpy`, `strncat`, `strncmp`.

### Прототип

```c
int	ft_strncmp(char *s1, char *s2, unsigned int n);
```

### Вимоги

- Відтвори поведінку стандартної функції `strncmp` (man 3 strncmp)
- Порівнюй не більше `n` символів
- Якщо `n == 0` -- повертай `0`
- Повертай різницю перших символів, що відрізняються
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strncmp`, `strcmp`
- Файл: `ft_strncmp.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_strncmp(char *s1, char *s2, unsigned int n);

int	main(void)
{
	ft_putnbr(ft_strncmp("abc", "abd", 3));
	ft_putchar('\n');
	ft_putnbr(ft_strncmp("abc", "abd", 2));
	ft_putchar('\n');
	ft_putnbr(ft_strncmp("abc", "abc", 3));
	ft_putchar('\n');
	ft_putnbr(ft_strncmp("abc", "abcd", 3));
	ft_putchar('\n');
	ft_putnbr(ft_strncmp("abc", "abcd", 4));
	ft_putchar('\n');
	ft_putnbr(ft_strncmp("abc", "xyz", 0));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
-1
0
0
0
-100
0
```

## Підказки

<details>
<summary>Підказка 1</summary>

Додай лічильник `i` до циклу. Умова: `i < n` І обидва символи існують І рівні. Не забудь: якщо `n == 0`, повертай `0` одразу.

</details>

<details>
<summary>Підказка 2</summary>

```c
unsigned int	i;

i = 0;
if (n == 0)
    return (0);
while (s1[i] && s1[i] == s2[i] && i < n - 1)
    i++;
return (s1[i] - s2[i]);
```

Зверни увагу: `i < n - 1`, тому що після циклу ми повертаємо `s1[i] - s2[i]` -- це вже `n`-й символ.

</details>

## Man сторінки

- `man 3 strncmp`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| обмежити | limiter | "Limiter la comparaison a n caracteres" |
| безпечний | sécurisé | "Une version sécurisée de strcmp" |

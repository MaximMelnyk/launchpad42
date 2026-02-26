---
id: gate_level2
module: gate
phase: phase2
title: "C Core Gate Exam (Level 2)"
difficulty: 3
xp: 200
estimated_minutes: 45
prerequisites: ["c05_ex07_ft_find_next_prime"]
tags: ["gate", "exam"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 96
---

# C Core Gate Exam (Level 2)

## Правила

Це Gate Exam для переходу з C05 до C06+. Він перевіряє, чи ти можеш написати ключові функції **з пам'яті**, без жодних підказок. На реальній Piscine такі функції потрібно писати на іспитах за лічені хвилини.

### Формат

- **3 функції** написані з пам'яті
- **Обмеження часу:** 45 хвилин
- **Прохідний бал:** 2 з 3 правильних
- **Спроби:** максимум 3 спроби з перервою 48 годин між ними
- **Часткове зарахування:** при 1/3 правильних отримуєш 60% XP та можеш спробувати ще раз

### Правила екзамену

- Жодного інтернету, жодних підказок, жодних нотаток
- Тільки `man` сторінки дозволені
- Компілюй з `-Wall -Wextra -Werror`
- Norminette обов'язкова
- Тільки `write()` -- жодного `printf`
- Кожна функція -- окрема папка (`ex01/`, `ex02/`, `ex03/`)

---

## Завдання 1: ft_strcmp (ex01/)

**Складність:** 2/5 | **Час:** ~10 хв

Напиши функцію `ft_strcmp`, яка порівнює два рядки.

### Прототип

```c
int	ft_strcmp(char *s1, char *s2);
```

### Вимоги

- Відтвори поведінку стандартної `strcmp` (man 3 strcmp)
- Поверни різницю перших відмінних символів (unsigned char)
- Якщо рядки ідентичні -- поверни `0`
- Файл: `ex01/ft_strcmp.c`

### Перевірка

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putnbr(int nb)
{
	if (nb == -2147483648)
	{
		write(1, "-2147483648", 11);
		return ;
	}
	if (nb < 0)
	{
		ft_putchar('-');
		nb = -nb;
	}
	if (nb >= 10)
		ft_putnbr(nb / 10);
	ft_putchar(nb % 10 + '0');
}

int	ft_strcmp(char *s1, char *s2);

int	main(void)
{
	ft_putnbr(ft_strcmp("abc", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", "abd"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abd", "abc"));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("", ""));
	ft_putchar('\n');
	ft_putnbr(ft_strcmp("abc", ""));
	ft_putchar('\n');
	return (0);
}
```

---

## Завдання 2: ft_atoi (ex02/)

**Складність:** 3/5 | **Час:** ~15 хв

Напиши функцію `ft_atoi`, яка конвертує рядок в ціле число.

### Прототип

```c
int	ft_atoi(char *str);
```

### Вимоги

- Пропусти початкові whitespace (`' '`, `'\t'`, `'\n'`, `'\v'`, `'\f'`, `'\r'`)
- Обробляй знаки `+` та `-` (множинні: парна кількість `-` = додатнє)
- Парсинг цифр до першого не-цифрового символу
- Файл: `ex02/ft_atoi.c`

### Перевірка

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_atoi(char *str);

int	main(void)
{
	ft_putnbr(ft_atoi("42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("  -42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("  ---42"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("0"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi("abc"));
	ft_putchar('\n');
	return (0);
}
```

---

## Завдання 3: ft_recursive_factorial (ex03/)

**Складність:** 2/5 | **Час:** ~10 хв

Напиши функцію `ft_recursive_factorial`, яка обчислює факторіал рекурсивно.

### Прототип

```c
int	ft_recursive_factorial(int nb);
```

### Вимоги

- `n! = n * (n-1)!`
- `0! = 1`
- `nb < 0` -- поверни `0`
- Обов'язково рекурсія (не цикл)
- Файл: `ex03/ft_recursive_factorial.c`

### Перевірка

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putnbr(int nb);
int	ft_recursive_factorial(int nb);

int	main(void)
{
	ft_putnbr(ft_recursive_factorial(5));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(0));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(10));
	ft_putchar('\n');
	ft_putnbr(ft_recursive_factorial(-3));
	ft_putchar('\n');
	return (0);
}
```

---

## Оцінювання

| Завдання | Функція | Бали |
|----------|---------|------|
| 1 | ft_strcmp | 1 |
| 2 | ft_atoi | 1 |
| 3 | ft_recursive_factorial | 1 |
| **Всього** | | **3** |

**Прохідний бал:** 2/3

### Після екзамену

- 3/3 -- Бездоганно! C06+ розблоковано + бонус 50 XP
- 2/3 -- Добре! C06+ розблоковано
- 1/3 -- Часткове зарахування (60% XP). Спробуй ще раз через 48 годин
- 0/3 -- Не зараховано. Повтори C03-C05, спробуй через 48 годин

### Розподіл часу (рекомендація)

| Завдання | Рекомендований час |
|----------|--------------------|
| ft_strcmp | 10 хв |
| ft_atoi | 15 хв |
| ft_recursive_factorial | 10 хв |
| Перевірка всього | 10 хв |
| **Всього** | **45 хв** |

## Підказки

На екзамені підказок немає. Але ось стратегічна порада:

<details>
<summary>Стратегія екзамену</summary>

1. **Починай з ft_recursive_factorial** -- найкоротша функція (5-7 рядків). Якщо знаєш рекурсію, це 3 хвилини.
2. **Потім ft_strcmp** -- теж коротка (6-8 рядків). Основна ідея: `while` + порівняння символів.
3. **ft_atoi останнім** -- найдовша, потребує акуратності з whitespace та знаками. Це 10-15 хвилин.
4. **Перевір кожну функцію перед переходом.** Краще здати 2/3 впевнено, ніж 3/3 з помилками.

</details>

<details>
<summary>Що повторити перед екзаменом</summary>

Перед цим Gate Exam рекомендую написати кожну з трьох функцій по 2-3 рази з пам'яті:

- **ft_strcmp:** ex C03 ex00
- **ft_atoi:** ex C04 ex03
- **ft_recursive_factorial:** ex C05 ex01

Якщо можеш написати кожну за 5 хвилин без помилок -- ти готовий.

</details>

## Man сторінки

- `man 2 write`
- `man 3 strcmp`
- `man 3 atoi`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| екзамен | examen | "L'examen de passage au niveau suivant" |
| з пам'яті | par coeur / de memoire | "Ecrire la fonction de memoire" |
| прохідний бал | note de passage | "La note de passage est 2 sur 3" |
| повторити | reviser | "Revise bien avant l'examen" |
| рекурсія | recursion | "La recursion c'est quand une fonction s'appelle elle-meme" |

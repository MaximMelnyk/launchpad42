---
id: gate_level3
module: gate
phase: phase2
title: "Advanced C Gate Exam (Level 3)"
difficulty: 4
xp: 200
estimated_minutes: 60
prerequisites: ["c09_ex02_ft_split_charset"]
tags: ["gate", "exam"]
norminette: true
man_pages: ["write", "malloc"]
multi_day: false
order: 107
---

# Advanced C Gate Exam (Level 3)

## Правила

Це Gate Exam для переходу з Phase 2 до Phase 3 (C10+, linked lists, BSQ). Він перевіряє, чи ти можеш написати **складніші функції з пам'яті** -- malloc, base conversion, сортування та конкатенація рядків. На реальній Piscine ці функції регулярно з'являються на іспитах Level 3-4.

### Формат

- **4 функції** написані з пам'яті
- **Обмеження часу:** 60 хвилин
- **Прохідний бал:** 3 з 4 правильних
- **Спроби:** максимум 3 спроби з перервою 48 годин між ними
- **Часткове зарахування:** при 2/4 правильних отримуєш 60% XP та можеш спробувати ще раз

### Правила екзамену

- Жодного інтернету, жодних підказок, жодних нотаток
- Тільки `man` сторінки дозволені
- Компілюй з `-Wall -Wextra -Werror`
- Norminette обов'язкова
- Тільки `write()`, `malloc`, `free` -- жодного `printf`
- Кожна функція -- окрема папка (`ex01/`, `ex02/`, `ex03/`, `ex04/`)

---

## Завдання 1: ft_split (ex01/)

**Складність:** 4/5 | **Час:** ~20 хв

Напиши функцію `ft_split`, яка розбиває рядок за **одним символом-роздільником**.

### Прототип

```c
char	**ft_split(char *str, char c);
```

### Вимоги

- Розбий `str` на масив слів, розділених символом `c`
- Повертай `NULL`-terminated масив `char **`
- Кожне слово -- окремий `malloc`'ований рядок
- Множинні роздільники підряд -- пропускай
- Порожній рядок -- повертай `[NULL]`
- Дозволено: `malloc`
- Файл: `ex01/ft_split.c`

### Перевірка

```c
#include <unistd.h>
#include <stdlib.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

char	**ft_split(char *str, char c);

int	main(void)
{
	char	**r;
	int		i;

	r = ft_split("hello world test", ' ');
	i = 0;
	while (r && r[i])
	{
		ft_putchar('[');
		ft_putstr(r[i]);
		ft_putchar(']');
		i++;
	}
	ft_putchar('\n');
	r = ft_split("***a**b***", '*');
	i = 0;
	while (r && r[i])
	{
		ft_putchar('[');
		ft_putstr(r[i]);
		ft_putchar(']');
		i++;
	}
	ft_putchar('\n');
	return (0);
}
```

Очікуваний вивід:
```
[hello][world][test]
[a][b]
```

---

## Завдання 2: ft_atoi_base (ex02/)

**Складність:** 4/5 | **Час:** ~20 хв

Напиши функцію `ft_atoi_base`, яка конвертує рядок-число з довільної бази в `int`.

### Прототип

```c
int	ft_atoi_base(char *str, char *base);
```

### Вимоги

- `base` визначає систему числення (наприклад, `"01"` для binary, `"0123456789ABCDEF"` для hex)
- Пропустити початкові whitespace та знаки `+`/`-`
- Парна кількість `-` = позитивне, непарна = негативне
- Перевір валідність `base`: довжина >= 2, без дублікатів, без `+`, `-`, whitespace
- Якщо `base` невалідна -- поверни `0`
- Файл: `ex02/ft_atoi_base.c`

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

int	ft_atoi_base(char *str, char *base);

int	main(void)
{
	ft_putnbr(ft_atoi_base("2A", "0123456789ABCDEF"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("101", "01"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("  -42", "0123456789"));
	ft_putchar('\n');
	ft_putnbr(ft_atoi_base("0", "0123456789"));
	ft_putchar('\n');
	return (0);
}
```

Очікуваний вивід:
```
42
5
-42
0
```

---

## Завдання 3: ft_sort_int_tab (ex03/)

**Складність:** 2/5 | **Час:** ~10 хв

Напиши функцію `ft_sort_int_tab`, яка сортує масив цілих чисел за зростанням.

### Прототип

```c
void	ft_sort_int_tab(int *tab, int size);
```

### Вимоги

- Сортування за зростанням (ascending)
- Bubble sort -- найпростіший алгоритм
- `size <= 0` -- нічого не робити
- Файл: `ex03/ft_sort_int_tab.c`

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

void	ft_sort_int_tab(int *tab, int size);

int	main(void)
{
	int	arr[] = {5, 3, 1, 4, 2};
	int	i;

	ft_sort_int_tab(arr, 5);
	i = 0;
	while (i < 5)
	{
		ft_putnbr(arr[i]);
		ft_putchar(' ');
		i++;
	}
	ft_putchar('\n');
	return (0);
}
```

Очікуваний вивід:
```
1 2 3 4 5
```

---

## Завдання 4: ft_strjoin (ex04/)

**Складність:** 3/5 | **Час:** ~10 хв

Напиши функцію `ft_strjoin`, яка конкатенує масив рядків у один рядок через роздільник.

### Прототип

```c
char	*ft_strjoin(int size, char **strs, char *sep);
```

### Вимоги

- Конкатенуй `size` рядків з масиву `strs`, вставляючи `sep` між ними
- Повертай malloc'ований результат
- Якщо `size == 0` -- поверни malloc'ований порожній рядок (`""`)
- `sep` може бути порожнім або багатосимвольним
- Файл: `ex04/ft_strjoin.c`

### Перевірка

```c
#include <unistd.h>
#include <stdlib.h>

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}

char	*ft_strjoin(int size, char **strs, char *sep);

int	main(void)
{
	char	*strs[] = {"Hello", "World", "42"};
	char	*r;

	r = ft_strjoin(3, strs, " ");
	ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	r = ft_strjoin(3, strs, ", ");
	ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	r = ft_strjoin(0, strs, " ");
	ft_putstr(r);
	write(1, "\n", 1);
	free(r);
	return (0);
}
```

Очікуваний вивід:
```
Hello World 42
Hello, World, 42

```

---

## Оцінювання

| Завдання | Функція | Бали |
|----------|---------|------|
| 1 | ft_split (char c) | 1 |
| 2 | ft_atoi_base | 1 |
| 3 | ft_sort_int_tab | 1 |
| 4 | ft_strjoin | 1 |
| **Всього** | | **4** |

**Прохідний бал:** 3/4

### Після екзамену

- 4/4 -- Бездоганно! Phase 3 розблоковано + бонус 50 XP
- 3/4 -- Добре! Phase 3 розблоковано
- 2/4 -- Часткове зарахування (60% XP). Спробуй ще раз через 48 годин
- 0-1/4 -- Не зараховано. Повтори C07-C09, спробуй через 48 годин

### Розподіл часу (рекомендація)

| Завдання | Рекомендований час |
|----------|--------------------|
| ft_sort_int_tab | 10 хв |
| ft_strjoin | 10 хв |
| ft_split | 20 хв |
| ft_atoi_base | 20 хв |
| **Всього** | **60 хв** |

## Підказки

На екзамені підказок немає. Але ось стратегічна порада:

<details>
<summary>Стратегія екзамену</summary>

1. **Починай з ft_sort_int_tab** -- bubble sort, найкоротша (~10 рядків). Якщо знаєш паттерн -- 5 хвилин.
2. **Потім ft_strjoin** -- прямолінійна: порахуй загальну довжину, malloc, заповни.
3. **ft_split третім** -- ти вже писав її 2 рази (C07 та C09). З пам'яті -- 15 хвилин.
4. **ft_atoi_base останнім** -- найскладніша, але якщо знаєш ft_atoi + розуміння бази -- 15-20 хвилин.
5. **Перевір кожну функцію перед переходом.** Краще здати 3/4 впевнено, ніж 4/4 з помилками.

</details>

<details>
<summary>Що повторити перед екзаменом</summary>

Напиши кожну функцію 2-3 рази з пам'яті:

- **ft_split (char c):** C07 ex05 (з одним char) -- простіша версія
- **ft_atoi_base:** C04 ex05 (якщо робив) або C04 ex03 (ft_atoi) + додай base
- **ft_sort_int_tab:** C01 ex08 (ft_sort_int_tab)
- **ft_strjoin:** C07 ex02 (ft_strjoin) або C07 ex01 + конкатенація

Якщо кожну пишеш за 10 хвилин без помилок -- ти готовий.

</details>

<details>
<summary>Bubble sort -- ключова ідея</summary>

Bubble sort -- це два вкладених `while`: зовнішній повторює проходи, внутрішній порівнює сусідні елементи.

**Алгоритм:**
1. Прапорець `sorted = 0` (масив ще не відсортований)
2. Зовнішній `while (!sorted)`: кожен прохід починається з `sorted = 1`
3. Внутрішній `while (i < size - 1)`: порівнюй `tab[i]` та `tab[i + 1]`
4. Якщо `tab[i] > tab[i + 1]` → swap (три рядки з `tmp`) + встанови `sorted = 0`
5. Якщо за весь прохід не було жодного swap → масив відсортований, виходимо

**Оптимізація:** прапорець `sorted` дозволяє вийти рано, без зайвих проходів.

Спробуй написати сам, перш ніж дивитись на C01 ex08 (`ft_sort_int_tab`).

</details>

## Man сторінки

- `man 2 write`
- `man 3 malloc`
- `man 3 free`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| екзамен | examen | "L'examen de passage au niveau avance" |
| з пам'яті | par coeur / de mémoire | "Ecrire ft_split de mémoire" |
| сортування | tri | "Un tri a bulles (bubble sort)" |
| конкатенація | concaténation | "Concatener les chaines avec un séparateur" |
| система числення | base / système de numeration | "Convertir en base hexadécimale" |
| прохідний бал | note de passage | "Il faut 3 sur 4 pour passer" |

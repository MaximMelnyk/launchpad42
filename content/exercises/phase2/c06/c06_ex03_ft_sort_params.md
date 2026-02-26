---
id: c06_ex03_ft_sort_params
module: c06
phase: phase2
title: "ft_sort_params"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c06_ex02_ft_rev_params", "c03_ex00_ft_strcmp"]
tags: ["c", "argv", "sorting"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 84
---

# ft_sort_params

## Завдання

Напиши програму, яка сортує аргументи командного рядка в ASCII порядку (зростання) та виводить їх, по одному на рядок.

Ця вправа поєднує навички з модулів C01 (сортування масиву) та C03 (порівняння рядків). Тобі потрібно відсортувати `argv` як масив рядків, використовуючи посимвольне порівняння (ASCII).

**Увага:** ти сортуєш самі вказівники в `argv`, НЕ копіюєш рядки. Це аналог `ft_sort_int_tab`, але для рядків.

### Прототип

```c
int	main(int argc, char **argv);
```

### Вимоги

- Відсортуй аргументи `argv[1]` до `argv[argc - 1]` в ASCII порядку
- Виведи відсортовані аргументи, кожен з наступним `'\n'`
- НЕ виводь `argv[0]` (ім'я програми)
- Якщо аргументів немає -- нічого не виводь
- Сортування: будь-який алгоритм (bubble sort достатньо)
- Порівняння: як `strcmp` (ASCII, посимвольно)
- Дозволені функції: `write`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strcmp`, `qsort`
- Файл: `ft_sort_params.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```bash
gcc -Wall -Wextra -Werror -o ft_sort_params ft_sort_params.c
./ft_sort_params cherry apple banana
```

### Очікуваний результат

```
apple
banana
cherry
```

Ще один приклад (числа як рядки -- ASCII порядок):

```bash
./ft_sort_params 42 100 9 200
```

```
100
200
42
9
```

**Зверни увагу:** `"100"` < `"200"` < `"42"` < `"9"` в ASCII порядку, бо порівняння йде посимвольно (`'1'` < `'2'` < `'4'` < `'9'`).

## Підказки

<details>
<summary>Підказка 1</summary>

Використай bubble sort: порівнюй сусідні елементи та міняй місцями, якщо вони не в правильному порядку. Повторюй, поки масив не буде відсортовано.

Для порівняння рядків напиши допоміжну функцію `ft_strcmp` (ти вже реалізував її у C03).

</details>

<details>
<summary>Підказка 2</summary>

Щоб поміняти місцями два вказівники на рядки, достатньо поміняти самі вказівники:
```c
tmp = argv[j];
argv[j] = argv[j + 1];
argv[j + 1] = tmp;
```

Де `tmp` має тип `char *`. Рядки залишаються на місці, змінюються тільки вказівники.

</details>

<details>
<summary>Підказка 3</summary>

Структура bubble sort для `argv`:
```c
i = 1;
while (i < argc - 1)
{
	j = 1;
	while (j < argc - 1)
	{
		if (ft_strcmp(argv[j], argv[j + 1]) > 0)
			/* swap argv[j] and argv[j + 1] */
		j++;
	}
	i++;
}
```

Після сортування -- виведи відсортовані аргументи.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| сортувати | trier | "Trier les parametres" |
| порівняння | comparaison | "Comparaison lexicographique" |
| міняти місцями | échanger / swap | "Echanger deux éléments" |
| бульбашкове сортування | tri a bulles | "Le tri a bulles est simple" |

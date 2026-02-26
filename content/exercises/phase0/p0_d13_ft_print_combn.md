---
id: p0_d13_ft_print_combn
module: p0
phase: phase0
title: "ft_print_combn"
difficulty: 5
xp: 80
estimated_minutes: 60
prerequisites: ["p0_d12_ft_print_comb2"]
tags: ["c", "while", "combinations", "recursion", "c00"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 25
---

# ft_print_combn

## Завдання

Напиши функцію `ft_print_combn`, яка приймає число `n` і виводить усі різні комбінації `n` цифр у порядку зростання.

Це вправа **C00 ex08** з Piscine — бонусна і найскладніша в модулі C00. Якщо ти її розв'яжеш, ти готовий до C01.

### Прототип

```c
void	ft_print_combn(int n);
```

### Вимоги

- `n` — кількість цифр у комбінації (від 1 до 9)
- Виводь усі комбінації `n` різних цифр (0-9) у порядку зростання
- Цифри всередині комбінації в порядку зростання
- Комбінації розділяються `, ` (кома + пробіл)
- Після останньої комбінації — нічого
- Використовуй тільки `ft_putchar`
- Тільки цикл `while` (НЕ `for`)
- Файли: `ft_print_combn.c` + `ft_putchar.c`
- Norminette: так (max 25 рядків на функцію — тому потрібні допоміжні функції)

### Приклади

```
ft_print_combn(1) → 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
ft_print_combn(2) → 01, 02, 03, ..., 89
ft_print_combn(3) → 012, 013, ..., 789  (як ft_print_comb)
ft_print_combn(9) → 012345678, 012345679, ..., 123456789
```

### Тестування

```c
void	ft_print_combn(int n);
void	ft_putchar(char c);

int	main(void)
{
	ft_print_combn(2);
	ft_putchar('\n');
	ft_print_combn(3);
	ft_putchar('\n');
	return (0);
}
```

## Підказки

<details>
<summary>Підказка 1 — підхід з масивом</summary>

Використовуй масив `int tab[10]` для зберігання поточної комбінації. Заповни початковими значеннями (0, 1, 2, ..., n-1), потім ітеративно генеруй наступну комбінацію.

```c
int	tab[10];
int	i;

i = 0;
while (i < n)
{
	tab[i] = i;
	i++;
}
```

</details>

<details>
<summary>Підказка 2 — друк та роздільник</summary>

Для друку комбінації пройди по масиву і виведи кожну цифру:
```c
void	print_tab(int *tab, int n)
{
	int	i;

	i = 0;
	while (i < n)
	{
		ft_putchar(tab[i] + '0');
		i++;
	}
}
```

Для визначення останньої комбінації: перевір, чи `tab[i] == 10 - n + i` для кожного `i`.

</details>

<details>
<summary>Підказка 3 — генерація наступної комбінації</summary>

Алгоритм "next combination":
1. Знайди найправіший елемент, який можна збільшити: `tab[i] < 10 - n + i`
2. Збільш його на 1
3. Всі елементи правіше від нього = послідовні: `tab[j] = tab[j-1] + 1`

```c
i = n - 1;
while (i >= 0 && tab[i] == 10 - n + i)
	i--;
if (i >= 0)
{
	tab[i]++;
	j = i + 1;
	while (j < n)
	{
		tab[j] = tab[j - 1] + 1;
		j++;
	}
}
```

</details>

<details>
<summary>Підказка 4 — обхід ліміту Norminette (25 рядків)</summary>

Розбий на 3 функції:
1. `print_tab(int *tab, int n)` — друк одної комбінації
2. `next_comb(int *tab, int n)` — генерація наступної комбінації (повертає 1 якщо успішно, 0 якщо це була остання)
3. `ft_print_combn(int n)` — ініціалізація + головний цикл

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| узагальнення | généralisation | "Généraliser pour n chiffres" |
| масив | tableau | "Utiliser un tableau" |
| допоміжна функція | fonction auxiliaire | "Créer une fonction auxiliaire" |

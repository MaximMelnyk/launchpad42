---
id: p0_d12_ft_print_comb2
module: p0
phase: phase0
title: "ft_print_comb2"
difficulty: 4
xp: 60
estimated_minutes: 45
prerequisites: ["p0_d11_ft_print_comb"]
tags: ["c", "while", "combinations", "c00"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 24
---

# ft_print_comb2

## Завдання

Напиши функцію `ft_print_comb2`, яка виводить усі різні комбінації двох двозначних чисел (від 00 до 99) у порядку зростання.

Це вправа **C00 ex06** з Piscine. Головна складність — форматування: числа завжди двозначні (з провідним нулем).

### Прототип

```c
void	ft_print_comb2(void);
```

### Вимоги

- Виводь усі комбінації двох **різних** чисел від 00 до 99
- Перше число менше за друге: `00 01`, а не `01 00`
- Числа завжди двозначні: `00`, `01`, ..., `09`, `10`, ..., `99`
- Два числа розділяються пробілом: `00 01`
- Комбінації розділяються `, ` (кома + пробіл)
- Після останньої комбінації (`98 99`) — нічого
- Використовуй тільки `ft_putchar`
- Тільки цикл `while` (НЕ `for`)
- Файли: `ft_print_comb2.c` + `ft_putchar.c`
- Norminette: так

### Очікуваний результат (скорочено)

```
00 01, 00 02, 00 03, ..., 00 99, 01 02, 01 03, ..., 98 99
```

Повний вивід: 4950 комбінацій.

### Тестування

```c
void	ft_print_comb2(void);

int	main(void)
{
	ft_print_comb2();
	return (0);
}
```

## Підказки

<details>
<summary>Підказка 1 — структура циклів</summary>

Два вкладених цикли: зовнішній для першого числа (0-98), внутрішній для другого (від першого+1 до 99).

```c
int	a;
int	b;

a = 0;
while (a <= 98)
{
	b = a + 1;
	while (b <= 99)
	{
		// print a and b
		b++;
	}
	a++;
}
```

</details>

<details>
<summary>Підказка 2 — форматування двозначних чисел</summary>

Щоб вивести число з двома цифрами, розбий його на десятки і одиниці:
```c
ft_putchar(a / 10 + '0');
ft_putchar(a % 10 + '0');
ft_putchar(' ');
ft_putchar(b / 10 + '0');
ft_putchar(b % 10 + '0');
```

</details>

<details>
<summary>Підказка 3 — роздільник</summary>

Кому з пробілом після кожної комбінації, крім останньої:
```c
if (a != 98 || b != 99)
{
	ft_putchar(',');
	ft_putchar(' ');
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| двозначне число | nombre à deux chiffres | "Un nombre à deux chiffres" |
| провідний нуль | zéro initial | "Afficher avec un zéro initial" |
| пара | paire | "Toutes les paires possibles" |

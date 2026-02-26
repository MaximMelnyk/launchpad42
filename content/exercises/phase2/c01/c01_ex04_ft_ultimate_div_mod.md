---
id: c01_ex04_ft_ultimate_div_mod
module: c01
phase: phase2
title: "ft_ultimate_div_mod"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["c01_ex03_ft_div_mod"]
tags: ["c", "pointers", "math"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 41
---

# ft_ultimate_div_mod

## Завдання

Напиши функцію `ft_ultimate_div_mod`, яка обчислює ділення та остачу, але з особливістю: вхідні значення передаються через ті самі вказівники, в які записуються результати.

Після виконання функції:
- `*a` має містити результат ділення `a / b`
- `*b` має містити остачу `a % b`

Зверни увагу: потрібно зберегти оригінальні значення перед обчисленням, бо інакше при зміні `*a` втратиш початкове значення для обчислення `*a % *b`.

### Прототип

```c
void	ft_ultimate_div_mod(int *a, int *b);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Зберігай оригінальні значення у тимчасових змінних перед обчисленням
- Заголовок 42 header у кожному файлі
- Файл: `ft_ultimate_div_mod.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putnbr(int nb);
void	ft_ultimate_div_mod(int *a, int *b);

int	main(void)
{
	int	x;
	int	y;

	x = 10;
	y = 3;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	x = 42;
	y = 10;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	x = 100;
	y = 7;
	ft_ultimate_div_mod(&x, &y);
	ft_putnbr(x);
	ft_putchar(' ');
	ft_putnbr(y);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
3 1
4 2
14 2
```

## Підказки

<details>
<summary>Підказка 1</summary>

Головна помилка -- це обчислити `*a = *a / *b` першим, а потім `*b = *a % *b`. Після першого рядка `*a` вже змінено! Тому `*a % *b` дасть неправильний результат.

Рішення: зберігти оригінальні значення:
```c
int	tmp_a;
int	tmp_b;

tmp_a = *a;
tmp_b = *b;
```

</details>

<details>
<summary>Підказка 2</summary>

Повна функція:
```c
void	ft_ultimate_div_mod(int *a, int *b)
{
	int	tmp_a;
	int	tmp_b;

	tmp_a = *a;
	tmp_b = *b;
	*a = tmp_a / tmp_b;
	*b = tmp_a % tmp_b;
}
```
Зберігаємо обидва значення, потім обчислюємо. 4 змінні (a, b, tmp_a, tmp_b) -- в межах Norminette ліміту 5.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| ділення | division | "Le quotient de la division" |
| остача | reste | "Le reste de la division" |
| зберегти | sauvegarder | "Sauvegarder les valeurs originales" |

---
id: p0_d05_sign_checker
module: p0
phase: phase0
title: "Sign Checker"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["p0_d05_ft_is_negative"]
tags: ["c", "conditions", "if-else", "strings"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 12
---

# Sign Checker

## Завдання

Напиши функцію `ft_sign_checker`, яка приймає ціле число та виводить його знак словом.

### Прототип

```c
void	ft_sign_checker(int n);
```

### Поведінка

- Якщо `n > 0` -- виводить `"positive\n"`
- Якщо `n < 0` -- виводить `"negative\n"`
- Якщо `n == 0` -- виводить `"zero\n"`

### Вимоги

- Використовуй `ft_putstr` для виводу рядків
- Ланцюжок `if` / `else if` / `else`
- НЕ використовуй `switch` (заборонено Norminette)
- Файли: `ft_sign_checker.c` + `ft_putchar.c` + `ft_putstr.c`
- Norminette: так

### Тестування

```c
void	ft_sign_checker(int n);

int	main(void)
{
	ft_sign_checker(42);
	ft_sign_checker(-7);
	ft_sign_checker(0);
	ft_sign_checker(2147483647);
	ft_sign_checker(-2147483648);
	return (0);
}
```

### Очікуваний результат

```
positive
negative
zero
positive
negative
```

## Підказки

<details>
<summary>Підказка 1</summary>

Ланцюжок умов:
```c
if (n > 0)
	ft_putstr("positive\n");
else if (n < 0)
	ft_putstr("negative\n");
else
	ft_putstr("zero\n");
```

</details>

<details>
<summary>Підказка 2</summary>

Порядок перевірок важливий. Якщо поставиш `n == 0` першим, інші два випадки покриються `else if` / `else`. Обидва варіанти правильні -- головне, щоб усі три випадки були оброблені.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| умова | condition | "Vérifier une condition" |
| додатний | positif | "Un nombre positif" |
| від'ємний | négatif | "Un nombre négatif" |

---
id: p0_d09_review_combo_2
module: p0
phase: phase0
title: "Review Combo 2"
difficulty: 3
xp: 40
estimated_minutes: 40
prerequisites: ["p0_d09_review_combo_1"]
tags: ["c", "review", "conditions", "loops", "format"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 21
---

# Review Combo 2

## Завдання

Напиши міні-профайлер -- програму, яка виводить розширений профіль з використанням умов, циклів та всіх твоїх функцій.

### Програма повинна виводити

```
========== PROFILE ==========
Name: Maksym
Level: 0 (Init)
Phase: 0
Days until Piscine: 124
Skills: write putchar putstr putnbr
Progress: [##########..........] 8%
Verdict: READY TO START
=============================
```

### Деталі реалізації

1. **Лінії-розділювачі** -- використай функцію, яка малює лінію з символу `'='`
2. **Level label** -- використай `if`/`else if` для визначення назви рівня:
   - 0 = "Init", 1 = "Shell", 2 = "Core", 3 = "Memory", 4 = "Exam", 5 = "Launch"
3. **Skills** -- виведи список через пробіли (hardcoded)
4. **Progress bar** -- напиши функцію, яка малює прогрес-бар:
   - `ft_print_progress(int percent)` -- виводить `[###...]` де `#` = заповнено, `.` = порожньо
   - Довжина бару: 20 символів, `percent` від 0 до 100

### Вимоги

- Усі значення захардкожені
- Використовуй ТІЛЬКИ: `ft_putchar`, `ft_putstr`, `ft_putnbr` (НЕ `printf`)
- Мінімум 3 окремі функції (крім `main` та утиліт виводу)
- Norminette: так, максимум 25 рядків на функцію, 5 змінних на функцію
- Файли: `main.c` + `ft_putchar.c` + `ft_putstr.c` + `ft_putnbr.c` + `ft_profile.c`
- Norminette: так

### Очікуваний результат

```
========== PROFILE ==========
Name: Maksym
Level: 0 (Init)
Phase: 0
Days until Piscine: 124
Skills: write putchar putstr putnbr
Progress: [##########..........] 8%
Verdict: READY TO START
=============================
```

## Підказки

<details>
<summary>Підказка 1: прогрес-бар</summary>

```c
void	ft_print_progress(int percent)
{
	int	filled;
	int	i;

	filled = percent / 5;
	ft_putchar('[');
	i = 0;
	while (i < 20)
	{
		if (i < filled)
			ft_putchar('#');
		else
			ft_putchar('.');
		i++;
	}
	ft_putchar(']');
}
```

При `percent = 8`, `filled = 8 / 5 = 1`. Тобто 1 символ `#` та 19 символів `.`.

Ой, зачекай -- `8 / 5 = 1` (ціле ділення). Для 8% бару на 20 символів потрібно: `20 * 8 / 100 = 1`. Або простіше: `percent * 20 / 100`.

</details>

<details>
<summary>Підказка 2: рівень</summary>

```c
void	ft_print_level(int level)
{
	ft_putnbr(level);
	ft_putstr(" (");
	if (level == 0)
		ft_putstr("Init");
	else if (level == 1)
		ft_putstr("Shell");
	else if (level == 2)
		ft_putstr("Core");
	else if (level == 3)
		ft_putstr("Memory");
	else if (level == 4)
		ft_putstr("Exam");
	else
		ft_putstr("Launch");
	ft_putchar(')');
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| рівень | niveau | "Ton niveau actuel" |
| прогрес | progression | "Barre de progression" |
| профіль | profil | "Afficher le profil" |

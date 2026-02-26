---
id: c_maint_02_putnbr
module: c_maintenance
phase: phase1
title: "ft_putnbr from memory"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c_maint_01_putstr"]
tags: ["c", "memory", "practice"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 28
---

# ft_putnbr from memory

## Завдання

Напиши функцію `ft_putnbr` **з пам'яті**, не дивлячись на своє рішення з Phase 0.

`ft_putnbr` -- це одна з перших функцій, яку запитають на examshell Piscine. Це класика рівня 0-1 екзамену. На реальному examshell перші 2-3 завдання вирішують за 10-15 хвилин кожне.

**Засікай час.** Мета: написати повністю робочий `ft_putnbr` за 10 хвилин або менше. Це реалістичний темп для examshell.

### Прототип

```c
void	ft_putnbr(int nb);
```

### Вимоги

- Напиши `ft_putnbr` з нуля, з пам'яті
- НЕ відкривай своє рішення з Phase 0
- **Засікай час:** мета -- 10 хвилин (максимум 15)
- Використовуй `ft_putchar` для виводу кожної цифри
- Обробляй коректно: 0, додатні, від'ємні, `INT_MIN` (-2147483648), `INT_MAX` (2147483647)
- НЕ використовуй `printf`, `scanf`, `itoa`
- Тільки цикл `while` (НЕ `for`)
- Файли: `ft_putnbr.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_putnbr(int nb);
void	ft_putchar(char c);

int	main(void)
{
	ft_putnbr(42);
	ft_putchar('\n');
	ft_putnbr(-42);
	ft_putchar('\n');
	ft_putnbr(0);
	ft_putchar('\n');
	ft_putnbr(-2147483648);
	ft_putchar('\n');
	ft_putnbr(2147483647);
	ft_putchar('\n');
	ft_putnbr(1);
	ft_putchar('\n');
	ft_putnbr(-1);
	ft_putchar('\n');
	ft_putnbr(10);
	ft_putchar('\n');
	ft_putnbr(-10);
	ft_putchar('\n');
	ft_putnbr(100);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
42
-42
0
-2147483648
2147483647
1
-1
10
-10
100
```

### Таймер

| Час | Результат |
|-----|-----------|
| < 10 хв | Відмінно -- ти готовий до examshell |
| 10-15 хв | Нормально -- потрібна ще практика |
| > 15 хв | Повтори Phase 0 ft_putnbr, спробуй завтра |

## Підказки

<details>
<summary>Мета-підказка: чому саме 10 хвилин</summary>

На examshell Piscine рівень 0 дає тобі прості завдання (ft_putchar, ft_putstr, ft_putnbr). У тебе є ~4 години на весь екзамен, але перші 2-3 завдання мають бути вирішені за 10-15 хвилин кожне, щоб залишити час на складніші.

`ft_putnbr` -- це найскладніше із "тривіальних" завдань. Якщо ти витрачаєш на нього 30 хвилин, ти не встигнеш дійти до завдань, що дають більше балів.

**Технічних підказок немає.** Все, що тобі потрібно, ти вже знаєш з Phase 0. Згадай:
- Як обробляється знак?
- Як рекурсивно розбити число на цифри?
- Що особливого в `INT_MIN`?

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| число | nombre | "Afficher un nombre entier" |
| від'ємний | negatif | "Gerer les nombres negatifs" |
| час | temps | "Tu as combien de temps?" (скільки у тебе часу?) |
| екзамен | examen | "L'examen dure quatre heures" |

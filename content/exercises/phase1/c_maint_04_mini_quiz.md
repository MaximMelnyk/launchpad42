---
id: c_maint_04_mini_quiz
module: c_maintenance
phase: phase1
title: "Mini C Quiz"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["c_maint_03_comb_timed"]
tags: ["c", "memory", "practice"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 30
---

# Mini C Quiz

## Завдання

Напиши **три функції за 30 хвилин**: `ft_putchar`, `ft_putstr`, `ft_putnbr`. Все з пам'яті, без жодних матеріалів.

Це фінальна C Maintenance вправа Phase 1. Вона імітує розминку справжнього examshell: перші 30 хвилин екзамену, коли ти маєш швидко пройти через базові функції, щоб дістатися до складніших завдань.

**Цей квіз -- це генеральна репетиція перед Gate Exam.**

### Інструкція

1. **Постав таймер на 30 хвилин**
2. Створи три файли:
   - `ft_putchar.c`
   - `ft_putstr.c`
   - `ft_putnbr.c`
3. Напиши кожну функцію з пам'яті
4. НЕ дивись у матеріали, НЕ відкривай Phase 0
5. Компілюй та тестуй після кожної функції (не жди кінця)
6. Коли таймер пропищить -- зупинись

### Прототипи

```c
void	ft_putchar(char c);
void	ft_putstr(char *str);
void	ft_putnbr(int nb);
```

### Вимоги

- Усі три функції -- з пам'яті, за 30 хвилин
- `ft_putchar`: використовує `write(1, &c, 1)`
- `ft_putstr`: використовує `ft_putchar`, обробляє `""` та `NULL`
- `ft_putnbr`: використовує `ft_putchar`, обробляє `0`, від'ємні, `INT_MIN`
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`)
- Файли: `ft_putchar.c`, `ft_putstr.c`, `ft_putnbr.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putstr(char *str);
void	ft_putnbr(int nb);

int	main(void)
{
	ft_putchar('A');
	ft_putchar('\n');
	ft_putstr("Piscine 42");
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr((void *)0);
	ft_putstr("OK\n");
	ft_putnbr(0);
	ft_putchar('\n');
	ft_putnbr(42);
	ft_putchar('\n');
	ft_putnbr(-42);
	ft_putchar('\n');
	ft_putnbr(2147483647);
	ft_putchar('\n');
	ft_putnbr(-2147483648);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
A
Piscine 42
OK
0
42
-42
2147483647
-2147483648
```

### Оцінювання

| Функція | Бали | Критерій |
|---------|------|----------|
| ft_putchar | 1 | Компілюється, виводить символ |
| ft_putstr | 1 | Рядки + порожній рядок + NULL |
| ft_putnbr | 1 | Усі числа включно з INT_MIN |
| **Всього** | **3** | Прохідний бал: 3/3 |

### Таймер

| Час | Результат |
|-----|-----------|
| < 15 хв (всі 3) | Майстер -- ти готовий до examshell |
| 15-25 хв | Добре -- темп достатній |
| 25-30 хв | На межі -- потрібно ще тренуватися |
| > 30 хв або не всі працюють | Повернись до Phase 0, повтори кожну функцію окремо |

## Підказки

<details>
<summary>Мета-підказка: порядок написання на екзамені</summary>

На examshell Piscine оптимальний порядок:

1. **ft_putchar** (2 хвилини) -- це основа для всього іншого. Пиши першою.
2. **ft_putstr** (5 хвилин) -- використовує ft_putchar. Простий while-цикл.
3. **ft_putnbr** (8-10 хвилин) -- найскладніша з трьох. Залиш на кінець.

Рекомендація: компілюй після КОЖНОЇ функції, не після всіх трьох. Так ти зразу знайдеш помилку, а не шукатимеш її в 50 рядках коду.

**Технічних підказок немає.** Ти вже писав кожну з цих функцій мінімум двічі.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| розминка | echauffement | "C'est l'echauffement avant l'exam" |
| швидкий | rapide | "Ecris le code le plus rapide possible" |
| перевірка | verification | "Fais la verification apres chaque fonction" |
| пам'ять | mémoire | "Ecrire de mémoire, sans aide" |

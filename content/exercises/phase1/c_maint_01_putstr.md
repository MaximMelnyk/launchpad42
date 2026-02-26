---
id: c_maint_01_putstr
module: c_maintenance
phase: phase1
title: "ft_putstr from memory"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["sh01_ex01_print_groups"]
tags: ["c", "memory", "practice"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 27
---

# ft_putstr from memory

## Завдання

Напиши функцію `ft_putstr` **з пам'яті**, не дивлячись на своє рішення з Phase 0.

Під час Piscine ти будеш писати цю функцію десятки разів -- на екзаменах, у проектах, для тестування. Вона повинна "жити у пальцях", як гами для музиканта. Зараз минуло 2+ тижні з Phase 0. Подивимось, чи зберіг ти навичку.

**Це вправа на згадування (recall), не на вивчення.** Якщо не можеш згадати -- це нормально, просто поверни увагу на Phase 0 і спробуй ще раз завтра.

### Прототип

```c
void	ft_putstr(char *str);
```

### Вимоги

- Напиши `ft_putstr` з нуля, з пам'яті
- НЕ відкривай своє рішення з Phase 0
- Використовуй `ft_putchar` для виводу кожного символу
- Використовуй тільки цикл `while` (НЕ `for`)
- НЕ використовуй `printf`, `scanf`, `puts` -- тільки `write()`
- Обробляй порожній рядок `""` коректно (нічого не виводить)
- Обробляй `NULL` -- функція не повинна крашитися
- Файли: `ft_putstr.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_putstr(char *str);
void	ft_putchar(char c);

int	main(void)
{
	ft_putstr("Hello, Piscine!");
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr("42 Paris");
	ft_putchar('\n');
	ft_putstr("Memory test OK");
	ft_putchar('\n');
	ft_putstr((void *)0);
	ft_putstr("After NULL\n");
	return (0);
}
```

### Очікуваний результат

```
Hello, Piscine!
42 Paris
Memory test OK
After NULL
```

### Критерії оцінки

| Тест | Опис |
|------|------|
| Компіляція | `-Wall -Wextra -Werror` без помилок |
| Базовий вивід | Рядки виводяться коректно |
| Порожній рядок | `""` -- нічого не виводить |
| NULL | Не крашиться при `NULL` |
| Norminette | Код відповідає нормі |
| Заборонені функції | Жодного `printf`/`scanf`/`puts`/`for` |

## Підказки

<details>
<summary>Мета-підказка: про що ця вправа</summary>

Ця вправа перевіряє не знання, а **м'язову пам'ять**. На справжньому екзамені Piscine у тебе не буде доступу до попередніх рішень. Ти маєш вміти написати `ft_putstr` за 3-5 хвилин, не замислюючись.

Якщо сьогодні не вийшло з першої спроби -- запиши собі: "повторити ft_putstr завтра вранці".

**Технічних підказок немає.** Це вправа на recall.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| пам'ять | memoire | "Ecrire de memoire" (написати з пам'яті) |
| повторення | repetition | "La repetition est la cle de l'apprentissage" |
| рядок | chaine de caracteres | "Afficher une chaine" |

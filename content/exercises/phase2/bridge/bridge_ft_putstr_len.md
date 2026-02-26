---
id: bridge_ft_putstr_len
module: bridge
phase: phase2
title: "ft_putstr + ft_strlen"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["bridge_ft_strlen"]
tags: ["c", "strings", "review"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 36
---

# ft_putstr + ft_strlen

## Завдання

Закріпи роботу з рядками: комбінуй `ft_putstr` та `ft_strlen`. Напиши програму, яка для кожного рядка виводить його текст, потім двокрапку з пробілом, потім його довжину.

### Прототип

```c
void	ft_putchar(char c);
void	ft_putstr(char *str);
int	ft_strlen(char *str);
void	ft_putnbr(int nb);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`)
- Заголовок 42 header у кожному файлі
- Файли: `main.c`, `ft_putchar.c`, `ft_putstr.c`, `ft_strlen.c`, `ft_putnbr.c`
- Norminette: так

### Тестування

```c
void	ft_putchar(char c);
void	ft_putstr(char *str);
int	ft_strlen(char *str);
void	ft_putnbr(int nb);

int	main(void)
{
	ft_putstr("Hello");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("Hello"));
	ft_putchar('\n');
	ft_putstr("");
	ft_putstr(": ");
	ft_putnbr(ft_strlen(""));
	ft_putchar('\n');
	ft_putstr("42");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("42"));
	ft_putchar('\n');
	ft_putstr("Piscine is coming");
	ft_putstr(": ");
	ft_putnbr(ft_strlen("Piscine is coming"));
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hello: 5
: 0
42: 2
Piscine is coming: 17
```

## Підказки

<details>
<summary>Підказка 1</summary>

Це вправа на інтеграцію. Ти вже маєш `ft_putstr` (з Phase 0) і `ft_strlen` (попередня вправа). Тепер комбінуй їх в одній програмі. Переконайся, що кожна функція в окремому `.c` файлі.

</details>

<details>
<summary>Підказка 2</summary>

Зверни увагу на порожній рядок `""`. `ft_putstr("")` не повинна нічого виводити, а `ft_strlen("")` повинна повернути 0. Другий рядок у виводі починається з `: 0` -- тому що `ft_putstr("")` нічого не виводить, а потім одразу йде `": "`.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| об'єднати | combiner | "Combiner deux fonctions" |
| вивести | afficher | "Afficher la longueur de la chaine" |
| файл | fichier | "Un fichier source par fonction" |

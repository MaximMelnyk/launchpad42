---
id: p0_d02_ft_putstr
module: p0
phase: phase0
title: "ft_putstr"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["p0_d02_ft_putchar"]
tags: ["c", "strings", "while", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 5
---

# ft_putstr

## Завдання

Напиши функцію `ft_putstr`, яка виводить рядок (string) на стандартний вивід.

Рядок у C -- це масив символів, що закінчується нульовим символом `'\0'`. Твоя функція повинна проходити по кожному символу рядка та виводити його за допомогою `ft_putchar`.

### Прототип

```c
void	ft_putstr(char *str);
```

### Вимоги

- Використовуй `ft_putchar` для виводу кожного символу
- Використовуй цикл `while` для проходження по рядку
- НЕ використовуй `for` (заборонено Norminette)
- Зупиняйся, коли зустрінеш `'\0'` (кінець рядка)
- Файли: `ft_putstr.c` + `ft_putchar.c`
- Norminette: так

### Тестування

```c
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello, Piscine!");
	ft_putstr("\n");
	ft_putstr("42 Paris");
	ft_putstr("\n");
	return (0);
}
```

### Очікуваний результат

```
Hello, Piscine!
42 Paris
```

## Підказки

<details>
<summary>Підказка 1</summary>

Рядок у C -- це масив символів. `str[0]` -- перший символ, `str[1]` -- другий, і так далі. Коли `str[i] == '\0'`, рядок закінчився.

</details>

<details>
<summary>Підказка 2</summary>

Використай лічильник `i`:
```c
int	i;

i = 0;
while (str[i] != '\0')
{
	ft_putchar(str[i]);
	i++;
}
```

</details>

<details>
<summary>Підказка 3</summary>

Можна обійтися без лічильника, використовуючи вказівник:
```c
while (*str)
{
	ft_putchar(*str);
	str++;
}
```

Обидва варіанти правильні, але на 42 частіше використовують варіант з лічильником на початку навчання.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| рядок | chaîne de caractères | "Afficher une chaîne" |
| цикл | boucle | "Utiliser une boucle while" |

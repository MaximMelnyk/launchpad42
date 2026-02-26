---
id: c01_ex05_ft_putstr
module: c01
phase: phase2
title: "ft_putstr"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["bridge_ft_strlen"]
tags: ["c", "pointers", "strings"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 42
---

# ft_putstr

## Завдання

Це офіційна версія `ft_putstr` з модуля C01 Piscine. На відміну від Phase 0 версії, ця повинна бути написана саме так, як вимагає Moulinette (автоматичний грейдер 42).

Напиши функцію `ft_putstr`, яка виводить рядок на стандартний вивід.

### Прототип

```c
void	ft_putstr(char *str);
```

### Вимоги

- Використовуй ТІЛЬКИ функцію `write` (або дозволені ft_* функції)
- НЕ використовуй `printf`, `scanf`, `puts`
- Тільки цикл `while` (НЕ `for`)
- Ітерація через вказівник: `while (*str)` або через індекс: `while (str[i])`
- Заголовок 42 header у кожному файлі
- Файл: `ft_putstr.c`
- Norminette: так

### Тестування

```c
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Hello World!");
	ft_putstr("\n");
	ft_putstr("");
	ft_putstr("42\n");
	ft_putstr("Piscine C01\n");
	return (0);
}
```

### Очікуваний результат

```
Hello World!
42
Piscine C01
```

## Підказки

<details>
<summary>Підказка 1</summary>

Є два основних способи пройти по рядку:

**Через індекс:**
```c
int	i;

i = 0;
while (str[i] != '\0')
{
	write(1, &str[i], 1);
	i++;
}
```

**Через вказівник:**
```c
while (*str)
{
	write(1, str, 1);
	str++;
}
```
Обидва варіанти коректні. Pointer version -- елегантніший, index version -- зрозуміліший.

</details>

<details>
<summary>Підказка 2</summary>

Можна також використати `ft_strlen` і один виклик `write`:
```c
void	ft_putstr(char *str)
{
	write(1, str, ft_strlen(str));
}
```
Але це потребує окрему функцію `ft_strlen`. Для Moulinette цей варіант теж працює, якщо `ft_strlen` є у тому ж проекті.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| рядок | chaine de caracteres | "Afficher une chaine" |
| вказівник | pointeur | "Iterer avec un pointeur" |
| стандартний вивід | sortie standard | "Ecrire sur la sortie standard" |

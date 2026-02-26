---
id: c03_ex05_ft_strlcat
module: c03
phase: phase2
title: "ft_strlcat"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c03_ex03_ft_strncat", "c02_ex10_ft_strlcpy"]
tags: ["c", "strings", "safe"]
norminette: true
man_pages: ["strlcat"]
multi_day: false
order: 64
---

# ft_strlcat

## Завдання

Напиши функцію `ft_strlcat`, яка виконує безпечну конкатенацію рядків у стилі BSD.

Це найскладніша вправа модуля C03. `strlcat` -- це BSD-функція, яка гарантує NUL-термінацію та повертає загальну довжину рядка, який вона намагалася створити. Ця функція часто з'являється на екзаменах Piscine.

**Ключова відмінність від `strncat`:** параметр `size` означає повний розмір буфера `dest` (включно з NUL), а НЕ кількість символів для копіювання.

### Прототип

```c
unsigned int	ft_strlcat(char *dest, char *src, unsigned int size);
```

### Вимоги

- Відтвори поведінку BSD-функції `strlcat` (man strlcat)
- Додай `src` до `dest`, але не більше ніж `size - strlen(dest) - 1` символів
- ЗАВЖДИ додавай NUL-термінатор (якщо `size > strlen(dest)`)
- Повертай `strlen(dest) + strlen(src)` (загальну довжину бажаного результату)
- Якщо `size <= strlen(dest)` -- повертай `size + strlen(src)` (буфер вже переповнений)
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strlcat`, `strcat`, `strncat`, `strlen`
- Файл: `ft_strlcat.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);
void	ft_putnbr(int nb);
unsigned int	ft_strlcat(char *dest, char *src, unsigned int size);

int	main(void)
{
	char	buf1[20];
	char	buf2[20];
	char	buf3[10];
	unsigned int	ret;

	buf1[0] = 'H';
	buf1[1] = 'i';
	buf1[2] = '\0';
	ret = ft_strlcat(buf1, " World", 20);
	ft_putstr(buf1);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	buf2[0] = 'A';
	buf2[1] = 'B';
	buf2[2] = '\0';
	ret = ft_strlcat(buf2, "CDEF", 4);
	ft_putstr(buf2);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	buf3[0] = '1';
	buf3[1] = '2';
	buf3[2] = '3';
	buf3[3] = '\0';
	ret = ft_strlcat(buf3, "456789", 2);
	ft_putstr(buf3);
	ft_putchar(' ');
	ft_putnbr(ret);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hi World 8
ABC 6
123 8
```

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм:
1. Знайди довжину `dest` (назвемо `dest_len`)
2. Знайди довжину `src` (назвемо `src_len`)
3. Якщо `size <= dest_len` -- повертай `size + src_len`
4. Копіюй символи з `src` в `dest + dest_len`, але не більше `size - dest_len - 1`
5. Додай `'\0'`
6. Повертай `dest_len + src_len`

</details>

<details>
<summary>Підказка 2</summary>

Тобі потрібна допоміжна функція для обчислення довжини рядка (або використай inline-цикл). Не забудь: `size <= dest_len` -- особливий випадок, де ти НЕ модифікуєш `dest`.

```c
dest_len = 0;
while (dest[dest_len] && dest_len < size)
    dest_len++;
if (dest_len == size)
    return (size + src_len);
```

Цей патерн гарантує, що ми не читаємо за межами `size`.

</details>

<details>
<summary>Підказка 3</summary>

Повний алгоритм копіювання:
```c
i = 0;
while (src[i] && (dest_len + i) < (size - 1))
{
    dest[dest_len + i] = src[i];
    i++;
}
dest[dest_len + i] = '\0';
```

Фінальне повернення: `return (dest_len + src_len);` де `src_len` -- повна довжина `src`, не кількість скопійованих символів.

</details>

## Man сторінки

- `man strlcat` (або `man 3 strlcat` на BSD/macOS)

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| безпечний | securise | "Concatenation securisee" |
| буфер | tampon | "Taille du tampon" |
| переповнення | debordement | "Eviter le debordement de tampon" |

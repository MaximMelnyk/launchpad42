---
id: c03_ex02_ft_strcat
module: c03
phase: phase2
title: "ft_strcat"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["c02_ex00_ft_strcpy"]
tags: ["c", "strings", "concat"]
norminette: true
man_pages: ["strcat"]
multi_day: false
order: 61
---

# ft_strcat

## Завдання

Напиши функцію `ft_strcat`, яка додає рядок `src` в кінець рядка `dest`.

Конкатенація (з'єднання) рядків -- фундаментальна операція. Буфер `dest` повинен бути достатньо великим, щоб вмістити обидва рядки + NUL-термінатор. Функція повертає вказівник на `dest`.

### Прототип

```c
char	*ft_strcat(char *dest, char *src);
```

### Вимоги

- Відтвори поведінку стандартної функції `strcat` (man 3 strcat)
- Додай `src` в кінець `dest`, починаючи з NUL-термінатора `dest`
- Завжди додавай `'\0'` в кінці результату
- Повертай вказівник на `dest`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strcat`, `strncat`
- Файл: `ft_strcat.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);
char	*ft_strcat(char *dest, char *src);

int	main(void)
{
	char	buf1[50];
	char	buf2[50];
	char	buf3[50];

	buf1[0] = 'H';
	buf1[1] = 'e';
	buf1[2] = 'l';
	buf1[3] = 'l';
	buf1[4] = 'o';
	buf1[5] = '\0';
	ft_strcat(buf1, " World");
	ft_putstr(buf1);
	ft_putchar('\n');
	buf2[0] = '\0';
	ft_strcat(buf2, "42");
	ft_putstr(buf2);
	ft_putchar('\n');
	buf3[0] = 'A';
	buf3[1] = 'B';
	buf3[2] = '\0';
	ft_strcat(buf3, "");
	ft_putstr(buf3);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hello World
42
AB
```

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм складається з двох кроків:
1. Знайди кінець `dest` (де стоїть `'\0'`)
2. Копіюй символи з `src` починаючи з цієї позиції

</details>

<details>
<summary>Підказка 2</summary>

```c
char	*ft_strcat(char *dest, char *src)
{
    int	i;
    int	j;

    i = 0;
    while (dest[i])
        i++;
    j = 0;
    while (src[j])
    {
        dest[i + j] = src[j];
        j++;
    }
    dest[i + j] = '\0';
    return (dest);
}
```

</details>

## Man сторінки

- `man 3 strcat`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| з'єднати | concatener | "Concatener deux chaines" |
| буфер | tampon | "Le tampon doit etre assez grand" |

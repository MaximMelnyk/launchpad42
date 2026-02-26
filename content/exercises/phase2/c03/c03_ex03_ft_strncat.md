---
id: c03_ex03_ft_strncat
module: c03
phase: phase2
title: "ft_strncat"
difficulty: 2
xp: 25
estimated_minutes: 20
prerequisites: ["c03_ex02_ft_strcat"]
tags: ["c", "strings", "concat"]
norminette: true
man_pages: ["strncat"]
multi_day: false
order: 62
---

# ft_strncat

## Завдання

Напиши функцію `ft_strncat`, яка додає не більше `nb` символів з `src` в кінець `dest`, а потім додає NUL-термінатор.

Це безпечніша версія `ft_strcat`. На Piscine розуміння різниці між `strcat` і `strncat` -- це обов'язкове знання.

### Прототип

```c
char	*ft_strncat(char *dest, char *src, unsigned int nb);
```

### Вимоги

- Відтвори поведінку стандартної функції `strncat` (man 3 strncat)
- Додай не більше `nb` символів з `src` в кінець `dest`
- ЗАВЖДИ додавай `'\0'` після скопійованих символів
- Якщо `src` коротший за `nb` -- копіюй лише до кінця `src`
- Повертай вказівник на `dest`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strcat`, `strncat`
- Файл: `ft_strncat.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);
char	*ft_strncat(char *dest, char *src, unsigned int nb);

int	main(void)
{
	char	buf1[50];
	char	buf2[50];
	char	buf3[50];

	buf1[0] = 'H';
	buf1[1] = 'i';
	buf1[2] = '\0';
	ft_strncat(buf1, " World!", 4);
	ft_putstr(buf1);
	ft_putchar('\n');
	buf2[0] = '\0';
	ft_strncat(buf2, "Hello", 10);
	ft_putstr(buf2);
	ft_putchar('\n');
	buf3[0] = 'A';
	buf3[1] = '\0';
	ft_strncat(buf3, "BCDEF", 0);
	ft_putstr(buf3);
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
Hi Wor
Hello
A
```

## Підказки

<details>
<summary>Підказка 1</summary>

Алгоритм такий самий, як у `ft_strcat`, але з додатковою умовою: копіюй символи з `src` поки `j < nb` І `src[j] != '\0'`.

</details>

<details>
<summary>Підказка 2</summary>

```c
j = 0;
while (src[j] && j < nb)
{
    dest[i + j] = src[j];
    j++;
}
dest[i + j] = '\0';
```

Зверни увагу: NUL-термінатор додається ЗАВЖДИ, навіть якщо `nb == 0` (у цьому випадку він просто перезаписує існуючий `'\0'` в `dest`).

</details>

## Man сторінки

- `man 3 strncat`

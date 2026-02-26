---
id: c07_ex03_ft_strjoin
module: c07
phase: phase2
title: "ft_strjoin"
difficulty: 4
xp: 60
estimated_minutes: 60
prerequisites: ["c07_ex00_ft_strdup", "c01_ex06_ft_strlen"]
tags: ["c", "malloc", "strings"]
norminette: true
man_pages: ["malloc"]
multi_day: false
order: 88
---

# ft_strjoin

## Завдання

Напиши функцію `ft_strjoin`, яка об'єднує масив рядків в один рядок, вставляючи роздільник між ними.

Це одна з найскладніших вправ модуля C07. Тобі потрібно:
1. Обчислити загальну довжину результату (всі рядки + роздільники)
2. Виділити рівно стільки пам'яті
3. Скопіювати рядки один за одним, вставляючи роздільник між ними

**Увага:** роздільник вставляється тільки МІЖ рядками, а НЕ після останнього.

### Прототип

```c
char	*ft_strjoin(int size, char **strs, char *sep);
```

### Вимоги

- Об'єднай `size` рядків з масиву `strs`, вставляючи `sep` між ними
- Якщо `size == 0` -- поверни порожній рядок (malloc'd `""`)
- Роздільник НЕ додається після останнього рядка
- Якщо `malloc` повертає `NULL` -- поверни `NULL`
- Дозволені функції: `malloc`
- Цикли: тільки `while` (НЕ `for`)
- Заборонено: `printf`, `scanf`, `puts`, `strcat`, `strjoin`
- Файл: `ft_strjoin.c`
- Norminette: так
- 42 header: обов'язковий

### Тестування

```c
#include <unistd.h>
#include <stdlib.h>

void	ft_putchar(char c);
void	ft_putstr(char *str);
char	*ft_strjoin(int size, char **strs, char *sep);

int	main(void)
{
	char	*strs3[3];
	char	*strs1[1];
	char	*result;

	strs3[0] = "Hello";
	strs3[1] = "World";
	strs3[2] = "42";
	result = ft_strjoin(3, strs3, "-");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_strjoin(3, strs3, ", ");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	strs1[0] = "Alone";
	result = ft_strjoin(1, strs1, "-");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_strjoin(0, strs3, "-");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	result = ft_strjoin(3, strs3, "");
	ft_putstr(result);
	ft_putchar('\n');
	free(result);
	return (0);
}
```

### Очікуваний результат

```
Hello-World-42
Hello, World, 42
Alone

HelloWorld42
```

## Підказки

<details>
<summary>Підказка 1</summary>

Спочатку обчисли загальну довжину:
- Сума довжин усіх рядків
- Плюс `(size - 1)` разів довжина роздільника (роздільник між рядками, а не після)

Не забудь: якщо `size == 0`, загальна довжина = 0.

</details>

<details>
<summary>Підказка 2</summary>

Для Norminette виділи обчислення загальної довжини в окрему функцію (наприклад, `ft_total_len`). Це допоможе вкластися в обмеження 25 рядків на функцію та 5 змінних.

</details>

<details>
<summary>Підказка 3</summary>

Алгоритм копіювання:
```c
k = 0;
i = 0;
while (i < size)
{
	j = 0;
	while (strs[i][j])
		result[k++] = strs[i][j++];
	if (i < size - 1)
	{
		j = 0;
		while (sep[j])
			result[k++] = sep[j++];
	}
	i++;
}
result[k] = '\0';
```

**Увага:** 5 змінних (`i`, `j`, `k`, `result`, `size`) -- Norminette ліміт! Якщо потрібно більше -- виділяй підфункції.

</details>

## Man сторінки

- `man 3 malloc`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| об'єднати | joindre / concaténer | "Joindre les chaines avec un séparateur" |
| роздільник | séparateur | "Inserer le séparateur entre les chaines" |
| виділити | allouer | "Allouer assez de mémoire" |
| порожній рядок | chaine vide | "Retourner une chaine vide" |

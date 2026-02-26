---
id: c02_ex11_ft_putstr_non_printable
module: c02
phase: phase2
title: "ft_putstr_non_printable"
difficulty: 3
xp: 40
estimated_minutes: 30
prerequisites: ["c01_ex05_ft_putstr"]
tags: ["c", "strings", "hex"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 57
---

# ft_putstr_non_printable

## Завдання

Напиши функцію `ft_putstr_non_printable`, яка виводить рядок на стандартний вивід, замінюючи всі недруковані символи на їхнє шістнадцяткове (hex) представлення у форматі `\xHH`.

**Правила:**

- Друковані символи (ASCII 32-126) виводяться як є
- Недруковані символи замінюються на `\x` + двозначний hex-код (малі літери)
- Наприклад: символ з кодом 0 (null) виводиться як `\x00`, табуляція (код 9) як `\x09`, символ з кодом 127 як `\x7f`

### Прототип

```c
void	ft_putstr_non_printable(char *str);
```

### Вимоги

- Дозволені функції: `write`
- Друковані символи (32-126): вивести як є
- Недруковані символи: вивести `\xHH` (hex, малі літери)
- НЕ використовуй `for` (заборонено Norminette)
- Файли: `ft_putstr_non_printable.c`
- Norminette: так
- 42 Header: обов'язковий

### Тестування

```c
#include <unistd.h>

void	ft_putstr_non_printable(char *str);

int	main(void)
{
	ft_putstr_non_printable("Coucou\ntu vas bien ?");
	write(1, "\n", 1);
	ft_putstr_non_printable("Hello\t\tWorld");
	write(1, "\n", 1);
	ft_putstr_non_printable("");
	write(1, "\n", 1);
	ft_putstr_non_printable("ABC");
	write(1, "\n", 1);
	return (0);
}
```

### Очікуваний результат

```
Coucou\x0atu vas bien ?
Hello\x09\x09World

ABC
```

## Підказки

<details>
<summary>Підказка 1</summary>

Щоб перетворити число в шістнадцяткову цифру, використай рядок-таблицю: `"0123456789abcdef"`. Якщо символ має код `c`, його старша hex-цифра = `c / 16`, а молодша = `c % 16`.

</details>

<details>
<summary>Підказка 2</summary>

Напиши допоміжну функцію для виводу hex:

```c
void	ft_print_hex(char c)
{
	char	*hex;

	hex = "0123456789abcdef";
	write(1, "\\x", 2);
	write(1, &hex[(unsigned char)c / 16], 1);
	write(1, &hex[(unsigned char)c % 16], 1);
}
```

Зверни увагу на `(unsigned char)c` -- це важливо, щоб символи з кодами > 127 працювали правильно!

</details>

<details>
<summary>Підказка 3</summary>

Основний цикл:

```c
int	i;

i = 0;
while (str[i] != '\0')
{
	if (str[i] >= 32 && str[i] <= 126)
		write(1, &str[i], 1);
	else
		ft_print_hex(str[i]);
	i++;
}
```

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| шістнадцятковий | hexadécimal | "Afficher en hexadécimal" |
| недрукований | non imprimable | "Caractère non imprimable" |

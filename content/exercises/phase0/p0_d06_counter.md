---
id: p0_d06_counter
module: p0
phase: phase0
title: "Counter"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: ["p0_d05_range_check"]
tags: ["c", "while", "loops", "basics"]
norminette: true
man_pages: ["write"]
multi_day: false
order: 14
---

# Counter

## Завдання

Напиши програму, яка виводить цифри від 0 до 9 за допомогою циклу `while`.

Це твоє перше серйозне знайомство з циклами. Цикл `while` -- єдиний дозволений тип циклу на 42 (цикл `for` заборонений Norminette).

### Вимоги

- Використовуй цикл `while`
- НЕ використовуй цикл `for` (заборонено Norminette)
- Виводь символи `'0'` до `'9'` за допомогою `ft_putchar`
- В кінці виведи `'\n'`
- Файли: `main.c` + `ft_putchar.c`
- Norminette: так

### Очікуваний результат

```
0123456789
```

## Підказки

<details>
<summary>Підказка 1</summary>

Структура циклу `while`:
```c
while (умова)
{
	// тіло циклу
}
```

Цикл виконується, поки умова істинна. Не забудь змінювати змінну-лічильник, інакше цикл буде нескінченним!

</details>

<details>
<summary>Підказка 2</summary>

Можна працювати з символами напряму:
```c
char	c;

c = '0';
while (c <= '9')
{
	ft_putchar(c);
	c++;
}
ft_putchar('\n');
```

Символ `'0'` має ASCII код 48, `'9'` -- 57. Оператор `++` збільшує значення на 1.

</details>

## Man сторінки

- `man 2 write`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| цикл | boucle | "Une boucle while" |
| лічильник | compteur | "Incrémenter le compteur" |

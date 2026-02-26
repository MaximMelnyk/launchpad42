---
id: gate_level1
module: gate
phase: phase1
title: "Shell & Git Gate Exam"
difficulty: 3
xp: 200
estimated_minutes: 60
prerequisites: ["c_maint_04_mini_quiz"]
tags: ["exam", "shell", "git", "c", "makefile"]
norminette: true
man_pages: ["write", "chmod", "ls", "git", "make"]
multi_day: false
order: 31
---

# Shell & Git Gate Exam

## Правила

Це екзамен на перехід з Phase 1 до Phase 2. Він перевіряє всі навички, які ти набув за 20 днів: Shell, Git, Makefile та базовий C.

### Формат

- **5 завдань** різного типу (Shell, Git, Makefile, C)
- **Обмеження часу:** 60 хвилин
- **Прохідний бал:** 3 з 5 правильних
- **Спроби:** максимум 3 спроби з перервою 48 годин між ними
- **Часткове зарахування:** при 2/5 правильних отримуєш 60% XP та можеш спробувати ще раз

### Правила екзамену

- Жодного інтернету, жодних підказок, жодних нотаток
- Тільки `man` сторінки дозволені
- Для C-коду: компілюй з `-Wall -Wextra -Werror`
- Norminette обов'язкова для C-коду
- Працюй тільки з `write()` -- жодного `printf`
- Кожне завдання -- окрема папка (`ex01/` - `ex05/`)

---

## Завдання 1: File Permissions (Shell)

**Складність:** 1/5 | **Час:** ~5 хв

Створи файл з назвою `ready` у директорії `ex01/`, який має наступні дозвіли (permissions):

```
-rwxr-x--x
```

Що означає:
- Власник (owner): read + write + execute
- Група (group): read + execute
- Інші (others): execute

### Файл

`ex01/ready`

### Перевірка

```bash
ls -l ex01/ready
```

Очікуваний вивід (дозволи):
```
-rwxr-x--x
```

Вміст файлу не має значення (може бути порожній).

---

## Завдання 2: ls one-liner (Shell)

**Складність:** 2/5 | **Час:** ~10 хв

Створи файл `ex02/midLS.sh`, який містить одну команду `ls`. Ця команда повинна вивести вміст поточної директорії у наступному форматі:

- Показати приховані файли (крім `.` та `..`)
- Один файл на рядок
- Відсортувати за часом модифікації (найновіший першим)
- Додати символ типу файлу (trailing indicator: `/` для директорій, `*` для виконуваних)

### Файл

`ex02/midLS.sh`

### Вимоги

- Файл повинен містити ТІЛЬКИ одну команду `ls` з потрібними прапорцями
- Без шебанга (`#!/bin/bash`), без echo, без інших команд
- Команда повинна працювати при виконанні: `bash ex02/midLS.sh`

### Підказка для перевірки

```bash
cd ex02 && bash midLS.sh
```

---

## Завдання 3: Git workflow (Git)

**Складність:** 2/5 | **Час:** ~15 хв

Працюй у директорії `ex03/`. Виконай наступну послідовність дій:

1. Ініціалізуй git-репозиторій: `git init`
2. Створи файл `hello.c` з функцією `ft_putchar` (будь-яка робоча версія)
3. Зроби перший коміт з повідомленням: `"Initial commit: add ft_putchar"`
4. Створи файл `Makefile` з правилом `all` яке компілює `hello.c` в `hello`
5. Зроби другий коміт: `"Add Makefile"`
6. Створи бранч `feature` і переключись на нього
7. Додай файл `ft_putstr.c` з робочою функцією `ft_putstr`
8. Зроби третій коміт: `"Add ft_putstr"`

### Перевірка

```bash
cd ex03
git log --oneline        # 3 commits
git branch               # main/master + feature
git log feature --oneline # 3 commits (feature ahead)
```

### Очікуваний результат

- 3 коміти в історії (на бранчі `feature`)
- 2 коміти на `main`/`master`
- Бранч `feature` існує
- Файли: `hello.c`, `Makefile`, `ft_putstr.c`

---

## Завдання 4: Makefile

**Складність:** 3/5 | **Час:** ~15 хв

Створи `Makefile` у директорії `ex04/`, який компілює програму з файлів `ft_putstr.c` та `ft_putchar.c`.

### Вимоги до Makefile

- `NAME = putstr_prog`
- Правило `all`: компілює та створює виконуваний файл `$(NAME)`
- Правило `clean`: видаляє об'єктні файли (`.o`)
- Правило `fclean`: видаляє об'єктні файли та виконуваний файл
- Правило `re`: виконує `fclean` потім `all`
- Компілятор: `cc`
- Прапорці: `-Wall -Wextra -Werror`
- Використовуй змінні: `CC`, `CFLAGS`, `NAME`, `SRCS`, `OBJS`

### Файли

Створи у `ex04/`:
- `Makefile`
- `ft_putchar.c` (робоча версія)
- `ft_putstr.c` (робоча версія)
- `main.c` (тестовий main)

### main.c

```c
void	ft_putstr(char *str);

int	main(void)
{
	ft_putstr("Makefile works!\n");
	return (0);
}
```

### Перевірка

```bash
cd ex04
make        # creates putstr_prog
./putstr_prog   # outputs "Makefile works!"
make clean  # removes .o files
make fclean # removes .o and putstr_prog
make re     # full rebuild
```

---

## Завдання 5: ft_print_alphabet from memory (C)

**Складність:** 2/5 | **Час:** ~10 хв

Напиши функцію `ft_print_alphabet` з пам'яті у директорії `ex05/`.

### Прототип

```c
void	ft_print_alphabet(void);
```

### Файли

- `ex05/ft_print_alphabet.c`
- `ex05/ft_putchar.c`

### Вимоги

- Виводить `abcdefghijklmnopqrstuvwxyz`
- Тільки `ft_putchar` для виводу
- Тільки `while` (НЕ `for`)
- НЕ додавай `\n` в кінці
- Norminette: так

### Тестування

```c
void	ft_print_alphabet(void);
void	ft_putchar(char c);

int	main(void)
{
	ft_print_alphabet();
	ft_putchar('\n');
	return (0);
}
```

### Очікуваний результат

```
abcdefghijklmnopqrstuvwxyz
```

---

## Оцінювання

| Завдання | Тип | Бали |
|----------|-----|------|
| File Permissions | Shell | 1 |
| ls one-liner | Shell | 1 |
| Git workflow | Git | 1 |
| Makefile | Makefile | 1 |
| ft_print_alphabet | C | 1 |
| **Всього** | | **5** |

**Прохідний бал:** 3/5

### Після екзамену

- 5/5 -- Бездоганно! Phase 2 розблоковано + бонус 50 XP
- 4/5 -- Добре! Phase 2 розблоковано
- 3/5 -- Достатньо. Phase 2 розблоковано
- 2/5 -- Часткове зарахування (60% XP). Спробуй ще раз через 48 годин
- 1/5 або менше -- Не зараховано. Повтори матеріал Phase 1, спробуй через 48 годин

### Розподіл часу (рекомендація)

| Завдання | Рекомендований час |
|----------|--------------------|
| File Permissions | 5 хв |
| ls one-liner | 10 хв |
| Git workflow | 15 хв |
| Makefile | 15 хв |
| ft_print_alphabet | 10 хв |
| Перевірка всього | 5 хв |
| **Всього** | **60 хв** |

## Підказки

На екзамені підказок немає. Але ось стратегічна порада:

<details>
<summary>Стратегія екзамену</summary>

1. **Починай з найлегшого:** File Permissions (2 хвилини) та ft_print_alphabet (5 хвилин). Це 2 бали за 7 хвилин.
2. **Потім ls one-liner:** це один рядок, але потрібно згадати прапорці.
3. **Makefile:** якщо знаєш структуру -- це 10 хвилин. Якщо ні -- краще пропусти та зосередься на Git.
4. **Git workflow:** багато кроків, але кожен простий. Не поспішай, перевіряй після кожного коміту.
5. **Не витрачай більше 15 хвилин на одне завдання.** Якщо застряг -- перейди далі.

</details>

## Man сторінки

- `man 2 write`
- `man chmod`
- `man ls`
- `man git`
- `man git-init`
- `man git-commit`
- `man git-branch`
- `man make`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| екзамен | examen | "L'examen dure une heure" |
| дозволи | permissions / droits | "Changer les permissions du fichier" |
| бранч | branche | "Creer une nouvelle branche" |
| компіляція | compilation | "La compilation a reussi" |
| прохідний бал | note de passage | "La note de passage est 3 sur 5" |

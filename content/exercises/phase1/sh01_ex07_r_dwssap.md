---
id: sh01_ex07_r_dwssap
module: shell01
phase: phase1
title: "r_dwssap"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["sh01_ex06_skip"]
tags: ["shell", "scripting", "sed", "awk", "rev", "sort", "pipe", "passwd"]
norminette: false
man_pages: ["cat", "sed", "awk", "rev", "sort", "paste"]
multi_day: false
order: 16
---

# r_dwssap

## Завдання

Напиши командний рядок, який обробляє файл `/etc/passwd` за складним алгоритмом. Назва вправи -- "r_dwssap" -- це "passwd_r" задом наперед (натяк на те, що ми "реверсуємо" passwd).

Це одна з найскладніших вправ Shell01. Вона вимагає побудови довгого pipeline з багатьох команд. Кожна команда виконує один крок трансформації.

### Файли для здачі

- Директорія: `ex07/`
- Файл: `r_dwssap.sh`

### Алгоритм (крок за кроком)

1. Прочитай `/etc/passwd`
2. Видали рядки-коментарі (починаються з `#`)
3. Візьми кожний другий рядок, починаючи з другого (рядки 2, 4, 6, ...)
4. Візьми тільки перше поле (login) -- все до першого `:`
5. Реверсуй кожний login посимвольно (наприклад `root` -> `toor`)
6. Відсортуй у зворотному алфавітному порядку
7. Візьми тільки рядки з `$FT_LINE1` по `$FT_LINE2` включно
8. Об'єднай через `, ` (кома-пробіл)
9. Додай крапку `.` в кінці
10. Без завершального `\n`

### Вимоги

- Скрипт має починатися з `#!/bin/sh`
- Змінні оточення `FT_LINE1` та `FT_LINE2` задають діапазон рядків
- Вивід: одний рядок, логіни через `, `, крапка в кінці, без `\n`

### Приклад

```bash
$ export FT_LINE1=1
$ export FT_LINE2=3
$ bash r_dwssap.sh
yxorp, ydobon, www.
```

(Результат залежить від вмісту `/etc/passwd` на твоїй системі)

### Очікуваний формат виводу

```
reversed_login1, reversed_login2, reversed_login3.
```

Логіни розділені `, ` (кома + пробіл). Крапка `.` в кінці. Без `\n`.

## Підказки

<details>
<summary>Підказка 1</summary>

Будуй pipeline поступово, додаючи по одній команді:

```bash
# Крок 1-2: прочитай і видали коментарі
cat /etc/passwd | sed '/^#/d'

# Крок 3: кожний другий рядок, починаючи з другого
... | awk 'NR % 2 == 0'

# Крок 4: перше поле (login)
... | awk -F ":" '{print $1}'

# Крок 5: реверс кожного рядка
... | rev

# Крок 6: зворотне сортування
... | sort -r
```

Тестуй кожний крок окремо!

</details>

<details>
<summary>Підказка 2</summary>

Для кроків 7-10 (фільтрація діапазону та форматування):

```bash
# Крок 7: вибрати рядки від FT_LINE1 до FT_LINE2
... | sed -n "${FT_LINE1},${FT_LINE2}p"

# Крок 8-9: об'єднати через ", " і додати крапку
... | paste -sd ',' | sed 's/,/, /g' | sed 's/$/./'

# Крок 10: видалити завершальний \n
... | tr -d '\n'
```

Або замість `paste` + `sed`:

```bash
... | awk '{print}' ORS=', ' | sed 's/, $/\./' | tr -d '\n'
```

</details>

<details>
<summary>Підказка 3 (повна структура)</summary>

Повний pipeline має вигляд:

```bash
cat /etc/passwd | sed '/^#/d' | awk 'NR%2==0' | awk -F ":" '{print$1}' | rev | sort -r | sed -n "${FT_LINE1},${FT_LINE2}p" | awk '{print}' ORS=', ' | sed 's/, $/\./' | tr -d '\n'
```

Це ~10 команд у pipeline. Кожна виконує рівно одну трансформацію.

</details>

## Man сторінки

- `man cat`
- `man sed`
- `man awk`
- `man rev`
- `man sort`
- `man paste`
- `man tr`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| пароль | mot de passe / passwd | "/etc/passwd contient les utilisateurs" |
| зворотний порядок | ordre inverse | "Trier en ordre inverse avec sort -r" |
| реверсувати | inverser | "Inverser chaque login avec rev" |
| діапазон | plage / intervalle | "Les lignes de FT_LINE1 a FT_LINE2" |
| конвеєр (pipeline) | pipeline / enchainement | "Un long pipeline de commandes" |

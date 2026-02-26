---
id: sh01_ex03_count_files
module: shell01
phase: phase1
title: "count_files"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh01_ex02_find_sh"]
tags: ["shell", "scripting", "find", "wc", "count"]
norminette: false
man_pages: ["find", "wc", "tr"]
multi_day: false
order: 13
---

# count_files

## Завдання

Напиши командний рядок, який рахує загальну кількість звичайних файлів та директорій рекурсивно в поточній директорії.

Простіше кажучи: порахуй скільки всього "елементів" (`find` знайде) у поточній папці та всіх підпапках.

### Файли для здачі

- Директорія: `ex03/`
- Файл: `count_files.sh`

### Вимоги

- Скрипт має починатися з `#!/bin/sh`
- Рахувати рекурсивно від поточної директорії (`.`)
- Вивести тільки число (без пробілів, без тексту)
- Включає саму поточну директорію (`.`) у підрахунок

### Приклад

```bash
$ mkdir -p test_dir/sub
$ touch test_dir/a.txt test_dir/sub/b.txt
$ cd test_dir
$ bash ../count_files.sh
4
```

Пояснення: `.` (поточна), `sub` (директорія), `a.txt` (файл), `sub/b.txt` (файл) = 4 елементи.

### Очікуваний формат виводу

```
42
```

Тільки число, без зайвих пробілів чи тексту.

## Підказки

<details>
<summary>Підказка 1</summary>

Команда `find .` виводить список усіх файлів і директорій рекурсивно. Кожен елемент на окремому рядку.

Команда `wc -l` рахує кількість рядків. Але `wc -l` часто додає пробіли перед числом -- їх потрібно видалити.

</details>

<details>
<summary>Підказка 2</summary>

```bash
find . | wc -l | tr -d ' '
```

`tr -d ' '` видаляє всі пробіли. Це гарантує чистий числовий вивід без зайвих символів.

</details>

## Man сторінки

- `man find`
- `man wc`
- `man tr`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| порахувати | compter | "Compter le nombre de fichiers" |
| директорія / папка | dossier / repertoire | "Combien de fichiers dans ce repertoire ?" |
| рекурсивно | recursivement | "Lister recursivement tous les fichiers" |
| рядок | ligne | "Compter les lignes avec wc -l" |

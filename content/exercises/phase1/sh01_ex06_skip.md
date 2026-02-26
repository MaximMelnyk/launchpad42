---
id: sh01_ex06_skip
module: shell01
phase: phase1
title: "skip"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh01_ex04_mac"]
tags: ["shell", "scripting", "awk", "sed", "pipe", "stdin"]
norminette: false
man_pages: ["awk", "sed"]
multi_day: false
order: 15
---

# skip

## Завдання

Напиши командний рядок, який виводить кожний другий рядок зі стандартного вводу, починаючи з першого рядка. Тобто: рядки 1, 3, 5, 7...

На Piscine цю вправу використовують з `ls -l`, але принцип працює з будь-яким вхідним потоком.

### Файли для здачі

- Директорія: `ex06/`
- Файл: `skip.sh`

### Вимоги

- Скрипт має починатися з `#!/bin/sh`
- Читає вхідні дані зі stdin (через pipe)
- Виводить непарні рядки (1-й, 3-й, 5-й, ...)
- Парні рядки (2-й, 4-й, 6-й, ...) пропускаються

### Приклад

```bash
$ echo -e "alpha\nbeta\ngamma\ndelta\nepsilon" | bash skip.sh
alpha
gamma
epsilon
```

```bash
$ ls -l | bash skip.sh
total 42
-rw-r--r-- 1 user group  100 Feb 26 file2.txt
drwxr-xr-x 2 user group 4096 Feb 26 scripts
```

(Рядки `total 42`, третій і п'ятий рядки виводу `ls -l`)

### Очікуваний формат виводу

Непарні рядки вхідного потоку, кожний на окремому рядку.

## Підказки

<details>
<summary>Підказка 1</summary>

В `awk` змінна `NR` -- це номер поточного рядка (Number of Record). Оператор `%` -- це остача від ділення.

```bash
awk 'NR % 2 == 1'
```

Це виведе тільки рядки з непарним номером (1, 3, 5, ...).

</details>

<details>
<summary>Підказка 2</summary>

Альтернатива з `sed`:

```bash
sed -n '1~2p'
```

Це означає: починаючи з рядка 1, виводити кожний другий рядок. Але цей синтаксис GNU-специфічний.

Інший варіант з `sed`:

```bash
sed 'n;d'
```

Це виводить поточний рядок (`n` -- перейти до наступного і вивести), а потім видаляє наступний (`d`).

</details>

## Man сторінки

- `man awk`
- `man sed`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| рядок | ligne | "Afficher une ligne sur deux" |
| пропустити | sauter / skip | "Sauter les lignes paires" |
| парний / непарний | pair / impair | "Les lignes impaires (1, 3, 5...)" |
| стандартний ввід | entree standard / stdin | "Lire depuis l'entree standard" |

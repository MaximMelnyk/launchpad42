---
id: sh01_ex02_find_sh
module: shell01
phase: phase1
title: "find_sh"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh01_ex01_print_groups"]
tags: ["shell", "scripting", "find", "sed", "basename"]
norminette: false
man_pages: ["find", "sed", "basename"]
multi_day: false
order: 12
---

# find_sh

## Завдання

Напиши командний рядок, який рекурсивно знаходить усі файли з розширенням `.sh` у поточній директорії та виводить їхні імена без шляху та без розширення `.sh`.

Ця вправа тренує пошук файлів (`find`) та обробку тексту (`sed`). Обидва інструменти ти будеш використовувати щодня під час Piscine.

### Файли для здачі

- Директорія: `ex02/`
- Файл: `find_sh.sh`

### Вимоги

- Скрипт має починатися з `#!/bin/sh`
- Шукати рекурсивно від поточної директорії (`.`)
- Шукати тільки файли (`-type f`), не директорії
- Виводити тільки ім'я файлу без шляху та без `.sh`
- Кожне ім'я на окремому рядку

### Приклад

Якщо структура файлів така:

```
./test.sh
./scripts/deploy.sh
./lib/utils.sh
./README.md
```

То вивід буде:

```
test
deploy
utils
```

### Очікуваний формат виводу

```
filename1
filename2
filename3
```

По одному імені на рядок, без `.sh`, без шляху.

## Підказки

<details>
<summary>Підказка 1</summary>

Команда `find . -type f -name "*.sh"` знайде всі `.sh` файли рекурсивно. Вона виведе повний шлях, наприклад `./scripts/deploy.sh`.

Тобі потрібно видалити шлях і розширення. Для цього можна використати `sed` з регулярним виразом.

</details>

<details>
<summary>Підказка 2</summary>

Регулярний вираз для `sed`: видалити все до останнього `/` та `.sh` в кінці:

```bash
find . -type f -name "*.sh" | sed 's:.*/::'  | sed 's:\.sh$::'
```

Або одним `sed`:

```bash
find . -type f -name "*.sh" | sed 's:.*/\(.*\)\.sh$:\1:'
```

Тут `:` використовується як роздільник замість `/`, щоб не конфліктувати зі слешами у шляхах.

</details>

## Man сторінки

- `man find`
- `man sed`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| знайти | trouver / chercher | "Trouver tous les fichiers .sh" |
| розширення файлу | extension de fichier | "L'extension .sh indique un script shell" |
| рекурсивно | récursivement | "Chercher récursivement dans les sous-dossiers" |
| регулярний вираз | expression reguliere / regex | "Utiliser une regex avec sed" |

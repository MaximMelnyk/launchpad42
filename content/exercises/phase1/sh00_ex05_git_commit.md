---
id: sh00_ex05_git_commit
module: shell00
phase: phase1
title: "GiT commit"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["sh00_ex04_midls"]
tags: ["shell", "git", "log", "script"]
norminette: false
man_pages: ["git-log"]
multi_day: false
order: 6
---

# GiT commit

## Завдання

Напиши скрипт `git_commit.sh`, який виводить хеші останніх 5 комітів Git-репозиторію (тільки перші 8 символів кожного хешу).

На Piscine ти здаватимеш проєкти через Git. Розуміння Git log, комітів і хешів -- обов'язкове. Ця вправа навчить тебе парсити вивід `git log`.

### Прототип скрипта

```bash
#!/bin/bash
# Your command here
```

### Вимоги

- Скрипт `git_commit.sh`
- Виводить рівно 5 рядків (або менше, якщо комітів менше 5)
- Кожен рядок -- перші 8 символів хешу коміту
- Порядок: від найновішого до найстарішого
- Жодних зайвих символів (пробілів, лапок тощо)
- Здай у директорії `ex05/`

### Очікуваний результат

```bash
$ bash git_commit.sh
a1b2c3d4
e5f6a7b8
c9d0e1f2
a3b4c5d6
e7f8a9b0
```

(Хеші будуть різні для кожного репозиторію.)

### Теорія: Git commit hash

Кожен коміт у Git має унікальний SHA-1 хеш з 40 шістнадцяткових символів. Перші 8 символів зазвичай достатні для ідентифікації коміту в межах одного проєкту.

```
commit a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0
       ^^^^^^^^
       ці 8 символів
```

## Підказки

<details>
<summary>Підказка 1: git log з форматуванням</summary>

Команда `git log` має опцію `--format` (або `--pretty=format:`) для кастомного виводу:

```bash
git log --format='%H'     # Повний хеш
git log --format='%h'     # Скорочений хеш (7 символів)
```

Але потрібно рівно 8 символів...

</details>

<details>
<summary>Підказка 2: Обмеження кількості та формат</summary>

```bash
# Показати тільки N останніх комітів
git log -5

# Формат: тільки хеш, вирізаний до 8 символів
git log --format='%H' -5 | cut -c1-8
```

</details>

<details>
<summary>Підказка 3: Повне рішення (структура)</summary>

Скрипт складається з одного рядка (не рахуючи shebang):

```bash
#!/bin/bash
git log --format='%H' -5 | cut -c1-8
```

Або без `cut`:
```bash
#!/bin/bash
git log --pretty=format:'%.8H' -5
```

Але `%.8H` -- не стандартний формат у всіх версіях Git. Безпечніше через `cut`.

</details>

## Man сторінки

- `man git-log`
- `man cut`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| коміт | commit | "Faire un commit" |
| хеш | hash / empreinte | "Le hash du commit" |
| журнал | journal / log | "Consulter le log Git" |
| репозиторій | depot / repository | "Cloner un depot Git" |

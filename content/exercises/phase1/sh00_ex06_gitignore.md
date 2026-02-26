---
id: sh00_ex06_gitignore
module: shell00
phase: phase1
title: "gitignore"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh00_ex05_git_commit"]
tags: ["shell", "git", "gitignore", "patterns"]
norminette: false
man_pages: ["gitignore"]
multi_day: false
order: 7
---

# gitignore

## Завдання

Створи файл `.gitignore` для C-проєкту, який ігноруватиме непотрібні файли.

На Piscine ти будеш здавати тільки вихідний код (`.c` та `.h` файли). Все інше -- об'єктні файли, бекапи, тимчасові файли -- не повинно потрапити в репозиторій. `.gitignore` автоматично виключає такі файли з Git.

### Вимоги

Файл `.gitignore` має ігнорувати:

| Паттерн | Що ігнорує |
|---------|-----------|
| `*.o` | Об'єктні файли (результат компіляції) |
| `*.a` | Статичні бібліотеки |
| `*~` | Backup-файли (Vim, Emacs) |
| `#*#` | Autosave-файли (Emacs) |
| `*.swp` | Swap-файли (Vim) |
| `.DS_Store` | macOS metadata (на 42 зустрічаються iMac) |
| `a.out` | Дефолтний бінарник gcc |

### Формат файлу

```
# Object files
*.o

# Static libraries
*.a

# Backup files
*~
#*#

# Vim swap files
*.swp

# macOS
.DS_Store

# Default binary
a.out
```

### Перевірка

```bash
# Переконайся, що gitignore працює
git init test_repo && cd test_repo
cp ../.gitignore .
touch file.c file.o file.a backup~ test.swp a.out
git status
# file.c має бути в untracked
# file.o, file.a, backup~, test.swp, a.out -- не повинні з'явитися
```

## Підказки

<details>
<summary>Підказка 1: Синтаксис .gitignore</summary>

- Кожен рядок -- один паттерн
- `*` -- будь-які символи (wildcard)
- `#` на початку рядка -- коментар
- Порожні рядки ігноруються
- `!` на початку -- виняток (НЕ ігнорувати)

Приклад: ігнорувати всі `.o`, але не `important.o`:
```
*.o
!important.o
```

</details>

<details>
<summary>Підказка 2: Як перевірити, що .gitignore працює</summary>

```bash
# Перевірити, чи файл ігнорується
git check-ignore -v file.o
# Якщо ігнорується, покаже правило

# Перевірити всі ігноровані файли
git status --ignored
```

</details>

## Man сторінки

- `man gitignore`
- `man git-check-ignore`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| ігнорувати | ignorer | "Ignorer les fichiers objets" |
| паттерн | motif / pattern | "Les motifs du gitignore" |
| об'єктний файл | fichier objet | "Les fichiers objets (.o)" |
| бібліотека | bibliotheque | "Les bibliotheques statiques (.a)" |

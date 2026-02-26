---
id: sh00_ex08_clean
module: shell00
phase: phase1
title: "clean"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["sh00_ex07_diff"]
tags: ["shell", "find", "cleanup", "patterns"]
norminette: false
man_pages: ["find"]
multi_day: false
order: 9
---

# clean

## Завдання

Напиши команду (у файлі `clean`), яка рекурсивно знаходить і видаляє тимчасові файли у поточній директорії та всіх піддиректоріях.

На Piscine після довгого дня кодингу твоя робоча директорія буде засмічена тимчасовими файлами: бекапи Vim/Emacs, об'єктні файли. Перед `git add` потрібно очистити -- і ця команда стане твоїм другом.

### Паттерни для видалення

| Паттерн | Що це | Джерело |
|---------|-------|---------|
| `*~` | Backup-файли | Vim, Emacs |
| `#*#` | Autosave-файли | Emacs |
| `*.o` | Об'єктні файли | gcc |

### Вимоги

- Файл `clean` містить **одну команду** (один рядок, не рахуючи shebang)
- Команда рекурсивно знаходить файли за паттернами `*~`, `#*#`, `*.o` в поточній директорії
- Знайдені файли видаляються
- Команда використовує `find`
- Здай у директорії `ex08/`

### Перевірка

```bash
# Створити тестові файли
mkdir -p testdir/subdir
touch testdir/file.o testdir/backup~ testdir/subdir/\#save\# testdir/keep.c

# Запустити clean
bash clean

# Перевірити
ls testdir/
# Має залишитися тільки keep.c
ls testdir/subdir/
# Порожня
```

## Підказки

<details>
<summary>Підказка 1: Основи find</summary>

```bash
# Знайти файли за паттерном
find . -name "*.o"

# Знайти і видалити
find . -name "*.o" -delete

# Знайти кілька паттернів (OR)
find . -name "*.o" -o -name "*~"
```

Увага: `-o` (OR) у `find` має нижчий пріоритет ніж `-delete`. Потрібні дужки або `-exec`.

</details>

<details>
<summary>Підказка 2: Правильне групування</summary>

Проблема: `find . -name "*.o" -o -name "*~" -delete` видалить тільки `*~`, а не `*.o`.

Рішення -- використай дужки (escaped):

```bash
find . \( -name "*~" -o -name "#*#" -o -name "*.o" \) -delete
```

Або тип файлу для безпеки:

```bash
find . -type f \( -name "*~" -o -name "#*#" -o -name "*.o" \) -delete
```

`-type f` шукає тільки файли (не директорії).

</details>

<details>
<summary>Підказка 3: Альтернатива з -exec</summary>

Замість `-delete` можна використати `-exec rm`:

```bash
find . -type f \( -name "*~" -o -name "#*#" -o -name "*.o" \) -exec rm {} \;
```

Де `{}` -- підставляє знайдений файл, `\;` -- завершує exec.

`-delete` простіше, але `-exec` гнучкіше (можна додати `-v` для verbose: `rm -v`).

</details>

## Man сторінки

- `man find`
- `man rm`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| знайти | trouver / chercher | "Chercher les fichiers temporaires" |
| видалити | supprimer | "Supprimer les fichiers objets" |
| тимчасовий | temporaire | "Les fichiers temporaires" |
| рекурсивно | récursivement | "Chercher récursivement dans les sous-repertoires" |

---
id: sh00_ex07_diff
module: shell00
phase: phase1
title: "diff"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["sh00_ex06_gitignore"]
tags: ["shell", "diff", "patch", "files"]
norminette: false
man_pages: ["diff", "patch"]
multi_day: false
order: 8
---

# diff

## Завдання

Навчись працювати з `diff` та `patch` -- інструментами для порівняння файлів і створення патчів.

На Piscine та в реальній розробці `diff` використовується постійно: для перегляду змін у коді, створення патчів, code review. `git diff` -- це обгортка навколо того ж `diff`.

### Частина 1: Створення патчу

Маючи два файли (`file1` та `file2`), створи файл-патч `sw.diff` у форматі unified diff:

**file1:**
```
This is the original file.
It has some content.
Line three here.
```

**file2:**
```
This is the modified file.
It has some content.
Line three has been changed.
And a new line was added.
```

### Вимоги

- Створи `sw.diff` -- unified diff між `file1` та `file2`
- Формат: unified (`diff -u`)
- Перевір: `patch file1 sw.diff` має перетворити `file1` у `file2`
- Здай файл `sw.diff` у директорії `ex07/`

### Очікуваний результат

```bash
$ cat sw.diff
--- file1	2025-06-01 23:42:00.000000000 +0200
+++ file2	2025-06-01 23:42:00.000000000 +0200
@@ -1,3 +1,4 @@
-This is the original file.
+This is the modified file.
 It has some content.
-Line three here.
+Line three has been changed.
+And a new line was added.
```

### Перевірка

```bash
# Створити патч
diff -u file1 file2 > sw.diff

# Застосувати патч
cp file1 file1_backup
patch file1 sw.diff

# Перевірити, що file1 тепер ідентичний file2
diff file1 file2
# (порожній вивід = файли однакові)
```

## Підказки

<details>
<summary>Підказка 1: Формати diff</summary>

`diff` має кілька форматів виводу:

```bash
diff file1 file2        # Normal format (compact)
diff -u file1 file2     # Unified format (readable, used in Git)
diff -c file1 file2     # Context format (older style)
```

Unified format (`-u`) -- найпоширеніший у сучасній розробці і Git. Рядки з `-` -- видалені, з `+` -- додані.

</details>

<details>
<summary>Підказка 2: Як працює patch</summary>

```bash
# Створення патчу
diff -u original modified > changes.diff

# Застосування патчу (змінює original)
patch original changes.diff

# Скасування патчу (reverse)
patch -R original changes.diff
```

`patch` читає інструкції з `.diff` файлу і застосовує зміни до вказаного файлу.

</details>

<details>
<summary>Підказка 3: Створення тестових файлів</summary>

```bash
cat > file1 << 'EOF'
This is the original file.
It has some content.
Line three here.
EOF

cat > file2 << 'EOF'
This is the modified file.
It has some content.
Line three has been changed.
And a new line was added.
EOF

diff -u file1 file2 > sw.diff
```

</details>

## Man сторінки

- `man diff`
- `man patch`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| різниця | difference | "Afficher les differences entre deux fichiers" |
| патч | patch / correctif | "Appliquer un patch" |
| рядок | ligne | "La ligne a ete modifiee" |
| порівняти | comparer | "Comparer deux fichiers" |

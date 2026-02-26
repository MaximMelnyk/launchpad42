---
id: sh00_ex09_magic
module: shell00
phase: phase1
title: "Magic file"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["sh00_ex08_clean"]
tags: ["shell", "file", "magic", "detection"]
norminette: false
man_pages: ["file", "magic"]
multi_day: false
order: 10
---

# Magic file

## Завдання

Створи magic-файл `magic_file`, який дозволить команді `file` розпізнавати файл певного типу.

Команда `file` визначає тип файлу не за розширенням, а за вмістом (magic bytes). Magic-файли описують правила для розпізнавання: на якому зсуві шукати, що шукати, і як називати тип.

Це одна з найскладніших вправ Shell00 -- на Piscine багато студентів пропускають її. Але ти підготуєшся.

### Вимоги

Створи файл `magic_file` з правилом, яке визначає файли з рядком `42` на початку (offset 0) як `42 file`:

```
0  string  42  42 file
```

### Як це працює

```bash
$ echo "42 is the answer" > test_file
$ file -m magic_file test_file
test_file: 42 file
```

### Формат magic-файлу

```
offset  type    value   description
```

| Поле | Значення |
|------|----------|
| offset | Зсув у байтах від початку файлу (0 = самий початок) |
| type | Тип даних: `string`, `long`, `short`, `byte` |
| value | Значення для пошуку |
| description | Опис типу файлу (вивід `file`) |

### Приклади реальних magic rules

```
# PDF files
0  string  %PDF  PDF document

# PNG images
0  string  \x89PNG  PNG image data

# ELF binaries
0  string  \x7fELF  ELF
```

## Підказки

<details>
<summary>Підказка 1: Мінімальний magic-файл</summary>

Створи файл `magic_file` з одним рядком:

```bash
echo '0  string  42  42 file' > magic_file
```

Це означає: "Якщо на зсуві 0 (початок файлу) є рядок `42`, то тип файлу -- `42 file`."

</details>

<details>
<summary>Підказка 2: Тестування</summary>

```bash
# Створити тестовий файл, що починається з "42"
echo "42 is the answer" > test42

# Перевірити з нашим magic-файлом
file -m magic_file test42
# Очікувано: test42: 42 file

# Перевірити з файлом, що НЕ починається з "42"
echo "Hello world" > test_other
file -m magic_file test_other
# Очікувано: test_other: data (або інший тип)
```

</details>

<details>
<summary>Підказка 3: Поширені помилки</summary>

1. **Табуляція vs пробіли**: Деякі версії `file` вимагають табуляцію між полями. Якщо пробіли не працюють, спробуй `\t`:

```bash
printf '0\tstring\t42\t42 file\n' > magic_file
```

2. **Компіляція**: Деякі системи вимагають "скомпілювати" magic-файл:
```bash
file -C -m magic_file
```

Це створить `magic_file.mgc`. Але зазвичай `file -m magic_file` працює і без компіляції.

</details>

## Man сторінки

- `man file`
- `man 5 magic`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| тип файлу | type de fichier | "Determiner le type de fichier" |
| магічне число | nombre magique | "Les nombres magiques identifient le format" |
| зсув | decalage / offset | "A l'offset 0 du fichier" |
| визначити | determiner / identifier | "Identifier le type de fichier" |

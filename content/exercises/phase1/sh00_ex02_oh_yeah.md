---
id: sh00_ex02_oh_yeah
module: shell00
phase: phase1
title: "Oh yeah, mooore"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh00_ex01_testshell00"]
tags: ["shell", "permissions", "chmod", "touch", "tar"]
norminette: false
man_pages: ["chmod", "touch", "ls", "tar"]
multi_day: false
order: 3
---

# Oh yeah, mooore

## Завдання

Створи набір файлів з точними правами, розмірами та датами модифікації. Потім запакуй їх у tar-архів.

Ця вправа -- продовження попередньої, але тепер файлів декілька. На Piscine ти зустрінеш подібне завдання: створити файли з конкретними атрибутами і здати їх разом.

### Файли для створення

```
-r--r-xr-x 1 XX XX   40 Jun  1 23:42 testShell00
-rwx--xr-- 1 XX XX    20 Jun  1 23:42 testShell01
-rwx--x--- 1 XX XX   100 Jun  1 23:42 testShell02
```

Де `XX` -- твій username і група (автоматично).

### Характеристики

| Файл | Права | Octal | Розмір | Дата |
|------|-------|-------|--------|------|
| testShell00 | `-r--r-xr-x` | 0455 | 40 | 2025-06-01 23:42 |
| testShell01 | `-rwx--xr--` | 0714 | 20 | 2025-06-01 23:42 |
| testShell02 | `-rwx--x---` | 0710 | 100 | 2025-06-01 23:42 |

### Вимоги

- Створи всі 3 файли з точними атрибутами
- Запакуй їх командою: `tar -cf exo2.tar testShell00 testShell01 testShell02`
- Здай файл `exo2.tar` у директорії `ex02/`

### Перевірка

```bash
$ tar -tf exo2.tar
testShell00
testShell01
testShell02
$ tar -xf exo2.tar && ls -l testShell0*
-r--r-xr-x 1 user group  40 Jun  1 23:42 testShell00
-rwx--xr-- 1 user group  20 Jun  1 23:42 testShell01
-rwx--x--- 1 user group 100 Jun  1 23:42 testShell02
```

## Підказки

<details>
<summary>Підказка 1: Декодування прав доступу</summary>

Переведення текстових прав в octal:

```
testShell01: -rwx--xr--
  owner: rwx = 4+2+1 = 7
  group: --x = 0+0+1 = 1
  others: r-- = 4+0+0 = 4
  Octal: 0714

testShell02: -rwx--x---
  owner: rwx = 4+2+1 = 7
  group: --x = 0+0+1 = 1
  others: --- = 0+0+0 = 0
  Octal: 0710
```

</details>

<details>
<summary>Підказка 2: Створення всіх файлів</summary>

```bash
# testShell00 (40 bytes, 0455)
dd if=/dev/zero bs=1 count=40 > testShell00 2>/dev/null
chmod 455 testShell00
touch -t 202506012342 testShell00

# testShell01 (20 bytes, 0714)
dd if=/dev/zero bs=1 count=20 > testShell01 2>/dev/null
chmod 714 testShell01
touch -t 202506012342 testShell01

# testShell02 (100 bytes, 0710)
dd if=/dev/zero bs=1 count=100 > testShell02 2>/dev/null
chmod 710 testShell02
touch -t 202506012342 testShell02

# Pack
tar -cf exo2.tar testShell00 testShell01 testShell02
```

</details>

<details>
<summary>Підказка 3: tar зберігає права доступу</summary>

Команда `tar` за замовчуванням зберігає права доступу і timestamps файлів. Тому важливо спочатку правильно налаштувати всі атрибути, а потім пакувати.

Щоб перевірити вміст архіву з деталями: `tar -tvf exo2.tar`

</details>

## Man сторінки

- `man chmod`
- `man touch`
- `man tar`
- `man dd`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| архів | archive | "Creer une archive tar" |
| розпакувати | extraire | "Extraire les fichiers de l'archive" |
| байт | octet | "Le fichier fait 40 octets" |
| права | droits / permissions | "Verifier les droits du fichier" |

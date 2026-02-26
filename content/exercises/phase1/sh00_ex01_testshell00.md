---
id: sh00_ex01_testshell00
module: shell00
phase: phase1
title: "testShell00"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh00_ex00_z"]
tags: ["shell", "permissions", "chmod", "touch"]
norminette: false
man_pages: ["chmod", "touch", "ls", "stat"]
multi_day: false
order: 2
---

# testShell00

## Завдання

Створи файл `testShell00` з наступними характеристиками:

1. **Права доступу:** `-r--r-xr-x` (0455)
2. **Розмір:** рівно 40 байт
3. **Дата модифікації:** `2025-06-01 23:42`

Ця вправа навчить тебе працювати з правами файлів (permissions), що є критично важливим для Piscine. На 42 ти будеш здавати проєкти через Git, і неправильні права -- часта помилка новачків.

### Вимоги

- Ім'я файлу: `testShell00`
- Права: `-r--r-xr-x` (owner: read, group: read+execute, others: read+execute)
- Розмір: 40 байт
- Дата модифікації: `2025-06-01 23:42`
- Здай у директорії `ex01/`

### Перевірка

```bash
$ ls -l testShell00
-r--r-xr-x 1 user group 40 Jun  1 23:42 testShell00
```

### Теорія: права доступу в Unix

Права складаються з 3 груп по 3 біти:
```
 owner  group  others
 r w x  r w x  r w x
 4 2 1  4 2 1  4 2 1
```

Для `-r--r-xr-x`:
- Owner: `r--` = 4+0+0 = 4
- Group: `r-x` = 4+0+1 = 5
- Others: `r-x` = 4+0+1 = 5
- Разом: `0455`

## Підказки

<details>
<summary>Підказка 1: Як створити файл потрібного розміру</summary>

Щоб створити файл з рівно 40 байтами:

```bash
# Спосіб 1: python (генерує рядок потрібної довжини)
python3 -c "print('A' * 39)" > testShell00

# Спосіб 2: dd
dd if=/dev/zero bs=1 count=40 > testShell00 2>/dev/null

# Спосіб 3: printf з точною кількістю символів
printf '%0.s.' $(seq 1 39) > testShell00 && printf '\n' >> testShell00
```

Перевір: `wc -c testShell00` має показати `40`.

</details>

<details>
<summary>Підказка 2: Як встановити права та дату</summary>

```bash
# Встановити права
chmod 455 testShell00

# Встановити дату модифікації
touch -t 202506012342 testShell00
```

Формат для `touch -t`: `YYYYMMDDhhmm` (рік-місяць-день-година-хвилина).

</details>

<details>
<summary>Підказка 3: Перевірка всіх параметрів</summary>

```bash
# Перевірити права
stat -c "%a" testShell00
# Очікувано: 455

# Перевірити розмір
stat -c "%s" testShell00
# Очікувано: 40

# Перевірити дату
stat -c "%y" testShell00
# Має містити 2025-06-01 23:42
```

</details>

## Man сторінки

- `man chmod`
- `man touch`
- `man stat`
- `man ls`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| права доступу | droits d'acces / permissions | "Modifier les permissions du fichier" |
| власник | proprietaire | "Le proprietaire du fichier" |
| дата модифікації | date de modification | "Changer la date de modification" |
| розмір | taille | "La taille du fichier est de 40 octets" |

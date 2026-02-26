---
id: sh01_ex01_print_groups
module: shell01
phase: phase1
title: "print_groups"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh00_ex09_magic"]
tags: ["shell", "scripting", "groups", "id", "tr"]
norminette: false
man_pages: ["id", "tr"]
multi_day: false
order: 11
---

# print_groups

## Завдання

Напиши скрипт, який виводить групи користувача, вказаного в змінній оточення `FT_USER`. Групи мають бути розділені комами, без завершального переведення рядка.

Це перша вправа модуля Shell01 у Piscine. Вона вчить тебе працювати зі змінними оточення та комбінувати команди через pipe (`|`). На реальній Piscine ця вправа перевіряється автоматично -- формат виводу має бути ідеальним.

### Файли для здачі

- Директорія: `ex01/`
- Файл: `print_groups.sh`

### Вимоги

- Скрипт має починатися з `#!/bin/sh`
- Використай команду `id -Gn` для отримання груп
- Ім'я користувача береться зі змінної оточення `$FT_USER`
- Групи розділені комами (`,`) без пробілів
- Без завершального переведення рядка (`\n`)
- Якщо `FT_USER` не задано -- `id` виведе групи поточного користувача

### Приклад

```bash
$ export FT_USER="root"
$ bash print_groups.sh
root,wheel,daemon
$ export FT_USER=$USER
$ bash print_groups.sh
efmua,sudo,docker
```

Зверни увагу: у прикладі немає порожнього рядка після виводу. Це тому, що скрипт не додає `\n` в кінці.

### Очікуваний формат виводу

```
group1,group2,group3
```

Без пробілів навколо ком. Без `\n` в кінці.

## Підказки

<details>
<summary>Підказка 1</summary>

Команда `id -Gn` виводить імена груп користувача, розділені пробілами. Наприклад:

```bash
$ id -Gn root
root wheel daemon
```

Тобі потрібно замінити пробіли на коми. Для цього є команда `tr` (translate characters).

</details>

<details>
<summary>Підказка 2</summary>

Для видалення завершального `\n` використай `tr -d '\n'`:

```bash
id -Gn $FT_USER | tr ' ' ',' | tr -d '\n'
```

Pipe (`|`) передає вивід однієї команди на вхід наступної.

</details>

## Man сторінки

- `man id`
- `man tr`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| група | groupe | "Les groupes de l'utilisateur" |
| користувач | utilisateur | "Quel est l'utilisateur courant ?" |
| змінна оточення | variable d'environnement | "Exporter une variable d'environnement" |
| канал (pipe) | tube / pipe | "On utilise un pipe pour chainer les commandes" |

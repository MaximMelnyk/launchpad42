---
id: exam_l2_inter
module: exam
phase: phase4
title: "inter"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: []
tags: ["exam", "strings", "sets"]
norminette: true
man_pages: []
multi_day: false
order: 239
level: 2
time_limit_minutes: 25
---

# inter

## Assignment

Напиши програму, яка приймає два рядки як аргументи та виводить символи, що присутні в ОБОХ рядках, без дублікатів.

Символи виводяться у порядку їх появи в першому рядку (`argv[1]`).

Після результату виведи перехід на новий рядок.

Якщо кількість аргументів не дорівнює 2, програма виводить тільки перехід на новий рядок.

### Expected files

- `inter.c`

### Allowed functions

- `write`

### Example

```
$> ./inter "padinton" "pansen"
pan
$> ./inter "los an" "las ans"
ls an
$> ./inter "aaa" "a"
a
$> ./inter

$>
```

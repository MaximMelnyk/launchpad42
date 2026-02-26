---
id: exam_l2_wdmatch
module: exam
phase: phase4
title: "wdmatch"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: []
tags: ["exam", "strings", "matching"]
norminette: true
man_pages: []
multi_day: false
order: 245
level: 2
time_limit_minutes: 25
---

# wdmatch

## Assignment

Напиши програму, яка приймає два рядки як аргументи та перевіряє, чи всі символи першого рядка (`argv[1]`) присутні у другому рядку (`argv[2]`) у тому самому порядку.

Якщо так -- виведи перший рядок, за яким слідує перехід на новий рядок.

Якщо ні, або кількість аргументів не дорівнює 2 -- виведи тільки перехід на новий рядок.

### Expected files

- `wdmatch.c`

### Allowed functions

- `write`

### Example

```
$> ./wdmatch "faya" "fgvfrber ymberEde dings ansen"
faya
$> ./wdmatch "faya" "fgvfrber ymberEdeDings ansen"

$> ./wdmatch "quarante deux" "qua l eta i nsma nte deux"
quarante deux
$> ./wdmatch "abc" "def"

$> ./wdmatch

$>
```

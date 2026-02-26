---
id: exam_l2_union
module: exam
phase: phase4
title: "union"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: []
tags: ["exam", "strings", "sets"]
norminette: true
man_pages: []
multi_day: false
order: 247
level: 2
time_limit_minutes: 25
---

# union

## Assignment

Напиши програму, яка приймає два рядки як аргументи та виводить символи, що присутні хоча б в одному з рядків, без дублікатів.

Символи виводяться у порядку їх першої появи: спочатку з першого рядка (`argv[1]`), потім з другого (`argv[2]`).

Після результату виведи перехід на новий рядок.

Якщо кількість аргументів не дорівнює 2, програма виводить тільки перехід на новий рядок.

### Expected files

- `union.c`

### Allowed functions

- `write`

### Example

```
$> ./union "zpadinton" "pansen"
zpadintons
$> ./union "aaa" "a"
a
$> ./union "abc" "def"
abcdef
$> ./union

$>
```

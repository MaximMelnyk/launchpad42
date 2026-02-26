---
id: exam_l0_aff_first_param
module: exam
phase: phase4
title: "aff_first_param"
difficulty: 1
xp: 15
estimated_minutes: 5
prerequisites: []
tags: ["exam", "argv", "basics"]
norminette: true
man_pages: []
multi_day: false
order: 201
level: 0
time_limit_minutes: 5
---

# aff_first_param

## Assignment

Напиши програму, яка виводить перший аргумент командного рядка (`argv[1]`), за яким слідує перехід на новий рядок.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `aff_first_param.c`

### Allowed functions

- `write`

### Example

```
$> ./aff_first_param "Hello World"
Hello World
$> ./aff_first_param Piscine42 Bonus
Piscine42
$> ./aff_first_param

$>
```

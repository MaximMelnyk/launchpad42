---
id: exam_l0_aff_last_param
module: exam
phase: phase4
title: "aff_last_param"
difficulty: 1
xp: 15
estimated_minutes: 5
prerequisites: []
tags: ["exam", "argv", "basics"]
norminette: true
man_pages: []
multi_day: false
order: 202
level: 0
time_limit_minutes: 5
---

# aff_last_param

## Assignment

Напиши програму, яка виводить останній аргумент командного рядка (`argv[argc - 1]`), за яким слідує перехід на новий рядок.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `aff_last_param.c`

### Allowed functions

- `write`

### Example

```
$> ./aff_last_param "Hello World"
Hello World
$> ./aff_last_param First Second Third
Third
$> ./aff_last_param

$>
```

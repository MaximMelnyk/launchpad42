---
id: exam_l1_ulstr
module: exam
phase: phase4
title: "ulstr"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: []
tags: ["exam", "strings", "case"]
norminette: true
man_pages: []
multi_day: false
order: 221
level: 1
time_limit_minutes: 10
---

# ulstr

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та інвертує регістр кожної літери: великі стають малими, малі -- великими. Символи, що не є літерами, залишаються без змін.

Після рядка виводиться перехід на новий рядок.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `ulstr.c`

### Allowed functions

- `write`

### Example

```
$> ./ulstr "Hello World"
hELLO wORLD
$> ./ulstr "L'eSPrit 42"
l'EspRIT 42
$> ./ulstr

$>
```

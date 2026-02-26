---
id: exam_l3_tab_mult
module: exam
phase: phase4
title: "tab_mult"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "math", "formatting"]
norminette: true
man_pages: []
multi_day: false
order: 263
level: 3
time_limit_minutes: 30
---

# tab_mult

## Assignment

Напиши програму, яка приймає число як аргумент `argv[1]` і виводить таблицю множення цього числа від 1 до 9.

Кожен рядок має формат: `M x N = R`, де M -- множник (1..9), N -- введене число, R -- результат.

Кожен рядок завершується newline.

Якщо аргументів немає, програма виводить тільки newline.

### Expected files

- `tab_mult.c`

### Allowed functions

- `write`
- `atoi`

### Example

```
$> ./tab_mult "3"
1 x 3 = 3
2 x 3 = 6
3 x 3 = 9
4 x 3 = 12
5 x 3 = 15
6 x 3 = 18
7 x 3 = 21
8 x 3 = 24
9 x 3 = 27
$> ./tab_mult
$>
```

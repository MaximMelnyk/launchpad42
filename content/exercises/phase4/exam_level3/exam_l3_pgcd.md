---
id: exam_l3_pgcd
module: exam
phase: phase4
title: "pgcd"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "math"]
norminette: true
man_pages: []
multi_day: false
order: 259
level: 3
time_limit_minutes: 30
---

# pgcd

## Assignment

Напиши програму, яка приймає два додатних цілих числа як аргументи `argv[1]` і `argv[2]`, обчислює їхній найбільший спільний дільник (PGCD / GCD) за алгоритмом Евкліда і виводить результат, за яким слідує newline.

Якщо кількість аргументів не дорівнює 2 або аргументи не є валідними додатними числами, програма виводить тільки newline.

### Expected files

- `pgcd.c`

### Allowed functions

- `write`
- `atoi`

### Example

```
$> ./pgcd "42" "10"
2
$> ./pgcd "14" "77"
7
$> ./pgcd "100" "75"
25
$> ./pgcd "17" "3"
1
$> ./pgcd
$>
```

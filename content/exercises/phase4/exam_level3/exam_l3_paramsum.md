---
id: exam_l3_paramsum
module: exam
phase: phase4
title: "paramsum"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "argv"]
norminette: true
man_pages: []
multi_day: false
order: 258
level: 3
time_limit_minutes: 30
---

# paramsum

## Assignment

Напиши програму, яка виводить кількість аргументів командного рядка (без урахування імені програми), за якою слідує newline.

Якщо аргументів немає, програма виводить `0` та newline.

### Expected files

- `paramsum.c`

### Allowed functions

- `write`

### Example

```
$> ./paramsum hello world
2
$> ./paramsum "hello world" foo bar
3
$> ./paramsum
0
$> ./paramsum a b c d e f g h i j
10
$>
```

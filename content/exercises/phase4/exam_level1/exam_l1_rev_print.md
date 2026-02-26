---
id: exam_l1_rev_print
module: exam
phase: phase4
title: "rev_print"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: []
tags: ["exam", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 217
level: 1
time_limit_minutes: 10
---

# rev_print

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та виводить його у зворотному порядку, за яким слідує перехід на новий рядок.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `rev_print.c`

### Allowed functions

- `write`

### Example

```
$> ./rev_print "Hello World"
dlroW olleH
$> ./rev_print "42 Paris"
siraP 24
$> ./rev_print ""

$> ./rev_print

$>
```

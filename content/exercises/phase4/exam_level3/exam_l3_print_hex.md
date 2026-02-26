---
id: exam_l3_print_hex
module: exam
phase: phase4
title: "print_hex"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "conversion", "hex"]
norminette: true
man_pages: []
multi_day: false
order: 260
level: 3
time_limit_minutes: 30
---

# print_hex

## Assignment

Напиши програму, яка приймає додатне ціле число як аргумент `argv[1]` і виводить його у шістнадцятковому форматі (lowercase), за яким слідує newline.

Якщо аргументів немає або аргумент не є валідним, програма виводить тільки newline.

### Expected files

- `print_hex.c`

### Allowed functions

- `write`
- `atoi`

### Example

```
$> ./print_hex "42"
2a
$> ./print_hex "0"
0
$> ./print_hex "255"
ff
$> ./print_hex "4294967295"
ffffffff
$> ./print_hex
$>
```

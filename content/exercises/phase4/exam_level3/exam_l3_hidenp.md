---
id: exam_l3_hidenp
module: exam
phase: phase4
title: "hidenp"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "strings", "matching"]
norminette: true
man_pages: []
multi_day: false
order: 256
level: 3
time_limit_minutes: 30
---

# hidenp

## Assignment

Напиши програму, яка приймає два рядки і перевіряє, чи можна знайти перший рядок "прихованим" (hidden) у другому.

Рядок "прихований" в іншому, якщо кожен його символ можна знайти у другому рядку, в тому ж порядку (але не обов'язково підряд).

Якщо перший рядок прихований у другому, виведи `1`, інакше -- `0`. Результат завершується newline.

Порожній рядок прихований в будь-якому рядку.

Якщо кількість аргументів не дорівнює 2, програма виводить тільки newline.

### Expected files

- `hidenp.c`

### Allowed functions

- `write`

### Example

```
$> ./hidenp "abc" "azbycx"
1
$> ./hidenp "abc" "cab"
0
$> ./hidenp "fgex" "face your fear, gin"
1
$> ./hidenp "" "anything"
1
$> ./hidenp "abc" ""
0
$> ./hidenp
$>
```

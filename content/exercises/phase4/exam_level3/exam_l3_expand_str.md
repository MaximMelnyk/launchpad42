---
id: exam_l3_expand_str
module: exam
phase: phase4
title: "expand_str"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "strings", "formatting"]
norminette: true
man_pages: []
multi_day: false
order: 252
level: 3
time_limit_minutes: 30
---

# expand_str

## Assignment

Напиши програму, яка приймає один рядок `argv[1]` і виводить його, замінюючи кожну послідовність пробілів та табуляцій рівно трьома пробілами. Початкові та кінцеві пробіли/табуляції видаляються.

Результат виводиться з newline в кінці.

Якщо аргументів немає або кількість аргументів не дорівнює 1, програма виводить тільки newline.

### Expected files

- `expand_str.c`

### Allowed functions

- `write`

### Example

```
$> ./expand_str "hello   world" | cat -e
hello   world$
$> ./expand_str "  hello   world   !" | cat -e
hello   world   !$
$> ./expand_str "a  b	c" | cat -e
a   b   c$
$> ./expand_str | cat -e
$
$>
```

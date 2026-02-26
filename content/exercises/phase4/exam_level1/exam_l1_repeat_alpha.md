---
id: exam_l1_repeat_alpha
module: exam
phase: phase4
title: "repeat_alpha"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: []
tags: ["exam", "strings", "char"]
norminette: true
man_pages: []
multi_day: false
order: 216
level: 1
time_limit_minutes: 15
---

# repeat_alpha

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та виводить його з наступною модифікацією:

- Кожна літера повторюється стільки разів, яка її позиція в алфавіті (`a`=1, `b`=2, ..., `z`=26). Те саме для великих літер (`A`=1, `B`=2, ..., `Z`=26).
- Символи, що не є літерами, виводяться один раз без змін.

Після рядка виводиться перехід на новий рядок.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `repeat_alpha.c`

### Allowed functions

- `write`

### Example

```
$> ./repeat_alpha "abc"
abbccc
$> ./repeat_alpha "a!b"
a!bb
$> ./repeat_alpha "Z"
ZZZZZZZZZZZZZZZZZZZZZZZZZZ
$> ./repeat_alpha

$>
```

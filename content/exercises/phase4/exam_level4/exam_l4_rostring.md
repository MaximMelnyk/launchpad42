---
id: exam_l4_rostring
module: exam
phase: phase4
title: "rostring"
difficulty: 5
xp: 80
estimated_minutes: 45
prerequisites: []
tags: ["exam", "strings", "manipulation"]
norminette: true
man_pages: []
multi_day: false
order: 277
level: 4
time_limit_minutes: 45
---

# rostring

## Assignment

Напиши програму, яка приймає рядок як аргумент та перемiщує перше слово в кiнець. Слова роздiленi пробiлами та/або табуляцiями. Зайвi пробiли мiж словами скорочуються до одного.

Результат виводиться на stdout з переходом на новий рядок.

Якщо аргументiв немає або рядок порожнiй -- вивести лише новий рядок.

### Expected files

- `rostring.c`

### Allowed functions

- `write`

### Example

```
$> ./rostring "abc   def    ghi"
def ghi abc
$> ./rostring "hello"
hello
$> ./rostring "   hello   world   42   "
world 42 hello
$> ./rostring ""
$> ./rostring
$>
```

---
id: exam_l1_rotone
module: exam
phase: phase4
title: "rotone"
difficulty: 2
xp: 25
estimated_minutes: 10
prerequisites: []
tags: ["exam", "strings", "cipher"]
norminette: true
man_pages: []
multi_day: false
order: 219
level: 1
time_limit_minutes: 10
---

# rotone

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та виводить його зі зсувом кожної літери на 1 позицію вперед в алфавіті, за яким слідує перехід на новий рядок.

- `'a'` стає `'b'`, `'z'` стає `'a'`
- `'A'` стає `'B'`, `'Z'` стає `'A'`
- Символи, що не є літерами, залишаються без змін.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `rotone.c`

### Allowed functions

- `write`

### Example

```
$> ./rotone "abc"
bcd
$> ./rotone "zZ"
aA
$> ./rotone "Hello, World!"
Ifmmp, Xpsme!
$> ./rotone

$>
```

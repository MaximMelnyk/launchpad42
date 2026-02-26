---
id: exam_l2_alpha_mirror
module: exam
phase: phase4
title: "alpha_mirror"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "strings", "char"]
norminette: true
man_pages: []
multi_day: false
order: 230
level: 2
time_limit_minutes: 20
---

# alpha_mirror

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та виводить його, замінюючи кожну літеру на її "дзеркальну" в алфавіті:

- `'a'` <-> `'z'`, `'b'` <-> `'y'`, `'c'` <-> `'x'`, ...
- `'A'` <-> `'Z'`, `'B'` <-> `'Y'`, `'C'` <-> `'X'`, ...

Символи, які не є літерами, залишаються без змін.

Після результату виведи перехід на новий рядок (`'\n'`).

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `alpha_mirror.c`

### Allowed functions

- `write`

### Example

```
$> ./alpha_mirror "abc"
zyx
$> ./alpha_mirror "My Music"
Nb Nfhrx
$> ./alpha_mirror "AkjhZ 5. "
ZpqsA 5.
$> ./alpha_mirror

$>
```

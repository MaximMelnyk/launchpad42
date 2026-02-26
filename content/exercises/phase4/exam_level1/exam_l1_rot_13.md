---
id: exam_l1_rot_13
module: exam
phase: phase4
title: "rot_13"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: []
tags: ["exam", "strings", "cipher"]
norminette: true
man_pages: []
multi_day: false
order: 218
level: 1
time_limit_minutes: 15
---

# rot_13

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та виводить його з ROT13 шифруванням, за яким слідує перехід на новий рядок.

ROT13 замінює кожну літеру на літеру, що стоїть на 13 позицій далі в алфавіті. `'a'` стає `'n'`, `'z'` стає `'m'`, тощо. Символи, що не є літерами, залишаються без змін.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `rot_13.c`

### Allowed functions

- `write`

### Example

```
$> ./rot_13 "abc"
nop
$> ./rot_13 "Hello, World!"
Uryyb, Jbeyq!
$> ./rot_13 "Uryyb, Jbeyq!"
Hello, World!
$> ./rot_13

$>
```

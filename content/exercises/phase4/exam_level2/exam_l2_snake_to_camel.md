---
id: exam_l2_snake_to_camel
module: exam
phase: phase4
title: "snake_to_camel"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "strings", "conversion"]
norminette: true
man_pages: []
multi_day: false
order: 248
level: 2
time_limit_minutes: 20
---

# snake_to_camel

## Assignment

Напиши програму, яка приймає рядок у форматі snake_case як аргумент (`argv[1]`) та виводить його у форматі lowerCamelCase, за яким слідує перехід на новий рядок.

Кожен символ `'_'`, за яким слідує літера, замінюється на відповідну велику літеру (сам `'_'` видаляється).

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `snake_to_camel.c`

### Allowed functions

- `write`

### Example

```
$> ./snake_to_camel "hello_world"
helloWorld
$> ./snake_to_camel "get_next_line"
getNextLine
$> ./snake_to_camel "alreadycamel"
alreadycamel
$> ./snake_to_camel

$>
```

---
id: exam_l2_camel_to_snake
module: exam
phase: phase4
title: "camel_to_snake"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "strings", "conversion"]
norminette: true
man_pages: []
multi_day: false
order: 231
level: 2
time_limit_minutes: 20
---

# camel_to_snake

## Assignment

Напиши програму, яка приймає рядок у форматі camelCase як аргумент (`argv[1]`) та виводить його у форматі snake_case, за яким слідує перехід на новий рядок.

Кожна велика літера замінюється на `'_'` + відповідну малу літеру.

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `camel_to_snake.c`

### Allowed functions

- `write`

### Example

```
$> ./camel_to_snake "helloWorld"
hello_world
$> ./camel_to_snake "CamelCase"
_camel_case
$> ./camel_to_snake "getString"
get_string
$> ./camel_to_snake "already_snake"
already_snake
$> ./camel_to_snake

$>
```

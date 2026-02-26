---
id: exam_l3_rstr_capitalizer
module: exam
phase: phase4
title: "rstr_capitalizer"
difficulty: 4
xp: 60
estimated_minutes: 35
prerequisites: []
tags: ["exam", "strings", "case"]
norminette: true
man_pages: []
multi_day: false
order: 261
level: 3
time_limit_minutes: 35
---

# rstr_capitalizer

## Assignment

Напиши програму, яка для кожного аргументу `argv[i]` (починаючи з argv[1]) виводить рядок з такими змінами:
- Остання літера кожного слова переводиться у верхній регістр (uppercase)
- Всі інші літери -- у нижній регістр (lowercase)

Слова розділяються пробілами або табуляціями. Пробіли та табуляції виводяться без змін.

Кожен аргумент виводиться на окремому рядку (з newline в кінці).

Якщо аргументів немає, програма виводить тільки newline.

### Expected files

- `rstr_capitalizer.c`

### Allowed functions

- `write`

### Example

```
$> ./rstr_capitalizer "hello world"
hellO worlD
$> ./rstr_capitalizer "HELLO WORLD"
hellO worlD
$> ./rstr_capitalizer "hello" "world"
hellO
worlD
$> ./rstr_capitalizer "a  b"
A  B
$> ./rstr_capitalizer
$>
```

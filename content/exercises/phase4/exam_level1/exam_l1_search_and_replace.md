---
id: exam_l1_search_and_replace
module: exam
phase: phase4
title: "search_and_replace"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: []
tags: ["exam", "strings", "replace"]
norminette: true
man_pages: []
multi_day: false
order: 220
level: 1
time_limit_minutes: 15
---

# search_and_replace

## Assignment

Напиши програму, яка приймає 3 аргументи:

- `argv[1]`: рядок
- `argv[2]`: символ для пошуку (один символ)
- `argv[3]`: символ заміни (один символ)

Програма замінює кожне входження символу `argv[2]` на `argv[3]` у рядку `argv[1]` та виводить результат, за яким слідує перехід на новий рядок.

Якщо кількість аргументів не дорівнює 3, або `argv[2]`/`argv[3]` не є одним символом, програма виводить тільки перехід на новий рядок.

### Expected files

- `search_and_replace.c`

### Allowed functions

- `write`

### Example

```
$> ./search_and_replace "Hallo World" a e
Hello World
$> ./search_and_replace "abcabc" a z
zbczbc
$> ./search_and_replace "hello" x y
hello
$> ./search_and_replace "too many" a b c

$> ./search_and_replace

$>
```

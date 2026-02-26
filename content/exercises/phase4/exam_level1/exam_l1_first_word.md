---
id: exam_l1_first_word
module: exam
phase: phase4
title: "first_word"
difficulty: 2
xp: 25
estimated_minutes: 15
prerequisites: []
tags: ["exam", "strings", "parsing"]
norminette: true
man_pages: []
multi_day: false
order: 210
level: 1
time_limit_minutes: 15
---

# first_word

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та виводить його перше слово, за яким слідує перехід на новий рядок.

"Слово" (word) -- це послідовність символів, розділених пробілами (`' '`) та табуляціями (`'\t'`).

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `first_word.c`

### Allowed functions

- `write`

### Example

```
$> ./first_word "  hello world  "
hello
$> ./first_word "piscine42"
piscine42
$> ./first_word "	  	 easy   stuff  "
easy
$> ./first_word

$>
```

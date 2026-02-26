---
id: exam_l2_last_word
module: exam
phase: phase4
title: "last_word"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "strings", "parsing"]
norminette: true
man_pages: []
multi_day: false
order: 240
level: 2
time_limit_minutes: 20
---

# last_word

## Assignment

Напиши програму, яка приймає рядок як аргумент (`argv[1]`) та виводить його останнє слово, за яким слідує перехід на новий рядок.

"Слово" (word) -- це послідовність символів, розділених пробілами (`' '`) та табуляціями (`'\t'`).

Якщо аргументів немає, програма виводить тільки перехід на новий рядок.

### Expected files

- `last_word.c`

### Allowed functions

- `write`

### Example

```
$> ./last_word "hello world"
world
$> ./last_word "  piscine   42  "
42
$> ./last_word "single"
single
$> ./last_word "	  end	"
end
$> ./last_word

$>
```

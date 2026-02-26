---
id: exam_l3_epur_str
module: exam
phase: phase4
title: "epur_str"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "strings", "cleanup"]
norminette: true
man_pages: []
multi_day: false
order: 251
level: 3
time_limit_minutes: 30
---

# epur_str

## Assignment

Напиши програму, яка приймає один рядок `argv[1]` і виводить його, замінюючи кожну послідовність пробілів та табуляцій одним пробілом. Початкові та кінцеві пробіли/табуляції видаляються.

Результат виводиться з newline в кінці.

Якщо аргументів немає або кількість аргументів не дорівнює 1, програма виводить тільки newline.

### Expected files

- `epur_str.c`

### Allowed functions

- `write`

### Example

```
$> ./epur_str "  hello   world  " | cat -e
hello world$
$> ./epur_str "hello" | cat -e
hello$
$> ./epur_str "  	 hello  	  world	 " | cat -e
hello world$
$> ./epur_str "" | cat -e
$
$> ./epur_str | cat -e
$
$>
```

---
id: exam_l2_do_op
module: exam
phase: phase4
title: "do_op"
difficulty: 3
xp: 40
estimated_minutes: 25
prerequisites: []
tags: ["exam", "math", "argv"]
norminette: true
man_pages: []
multi_day: false
order: 232
level: 2
time_limit_minutes: 25
---

# do_op

## Assignment

Напиши програму-калькулятор, яка приймає три аргументи: `argv[1]` (число), `argv[2]` (оператор), `argv[3]` (число).

Підтримувані оператори: `+`, `-`, `*`, `/`, `%`.

Виведи результат операції, за яким слідує перехід на новий рядок.

При діленні на 0 (`/` або `%`) нічого не виводиться (тільки newline).

Якщо кількість аргументів не дорівнює 3, програма виводить тільки перехід на новий рядок.

### Expected files

- `do_op.c`

### Allowed functions

- `write`
- `atoi`

### Example

```
$> ./do_op "42" "+" "21"
63
$> ./do_op "42" "-" "21"
21
$> ./do_op "42" "*" "2"
84
$> ./do_op "42" "/" "5"
8
$> ./do_op "42" "%" "5"
2
$> ./do_op "42" "/" "0"

$> ./do_op

$>
```

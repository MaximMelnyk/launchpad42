---
id: exam_l2_print_bits
module: exam
phase: phase4
title: "print_bits"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "bits"]
norminette: true
man_pages: []
multi_day: false
order: 243
level: 2
time_limit_minutes: 20
---

# print_bits

## Assignment

Напиши функцію `print_bits`, яка виводить двійкове представлення байта (unsigned char).

Виводяться 8 бітів, починаючи зі старшого (MSB first). Використовуй символи `'0'` та `'1'`.

### Прототип

```c
void	print_bits(unsigned char octet);
```

### Expected files

- `print_bits.c`

### Allowed functions

- `write`

### Example

```c
print_bits(2);    /* writes "00000010" */
print_bits(0);    /* writes "00000000" */
print_bits(255);  /* writes "11111111" */
print_bits(65);   /* writes "01000001" (ASCII 'A') */
```

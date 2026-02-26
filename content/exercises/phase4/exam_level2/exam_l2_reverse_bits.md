---
id: exam_l2_reverse_bits
module: exam
phase: phase4
title: "reverse_bits"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "bits"]
norminette: true
man_pages: []
multi_day: false
order: 244
level: 2
time_limit_minutes: 20
---

# reverse_bits

## Assignment

Напиши функцію `reverse_bits`, яка повертає байт з бітами у зворотному порядку.

Біт 0 стає бітом 7, біт 1 стає бітом 6, і т.д.

### Прототип

```c
unsigned char	reverse_bits(unsigned char octet);
```

### Expected files

- `reverse_bits.c`

### Allowed functions

- None

### Example

```c
reverse_bits(0b01000001);  /* returns 0b10000010 (65 -> 130) */
reverse_bits(0b11111111);  /* returns 0b11111111 (255 -> 255) */
reverse_bits(0b00000000);  /* returns 0b00000000 (0 -> 0) */
reverse_bits(0b00000001);  /* returns 0b10000000 (1 -> 128) */
```

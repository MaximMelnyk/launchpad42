---
id: exam_l2_swap_bits
module: exam
phase: phase4
title: "swap_bits"
difficulty: 3
xp: 40
estimated_minutes: 20
prerequisites: []
tags: ["exam", "bits"]
norminette: true
man_pages: []
multi_day: false
order: 246
level: 2
time_limit_minutes: 20
---

# swap_bits

## Assignment

Напиши функцію `swap_bits`, яка міняє місцями старшу та молодшу тетради (nibbles) байта.

Старші 4 біти (bits 4-7) стають молодшими, а молодші 4 біти (bits 0-3) стають старшими.

### Прототип

```c
unsigned char	swap_bits(unsigned char octet);
```

### Expected files

- `swap_bits.c`

### Allowed functions

- None

### Example

```c
swap_bits(0b01000001);  // returns 0b00010100 (65 -> 20)
swap_bits(0b00000000);  // returns 0b00000000 (0 -> 0)
swap_bits(0b11111111);  // returns 0b11111111 (255 -> 255)
swap_bits(0b11110000);  // returns 0b00001111 (240 -> 15)
```

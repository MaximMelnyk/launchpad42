---
id: exam_l4_ft_split
module: exam
phase: phase4
title: "ft_split"
difficulty: 5
xp: 80
estimated_minutes: 60
prerequisites: []
tags: ["exam", "malloc", "strings"]
norminette: true
man_pages: []
multi_day: false
order: 275
level: 4
time_limit_minutes: 60
---

# ft_split

## Assignment

Напиши функцiю `ft_split`, яка розбиває рядок на масив слiв. Роздiлювачi -- пробiли (`' '`) та табуляцiї (`'\t'`).

Повертає NULL-terminated масив рядкiв, кожен з яких видiлений через `malloc`. При помилцi malloc -- повертає `NULL`.

### Прототип

```c
char  **ft_split(char *str);
```

- Послiдовнi пробiли/табуляцiї мiж словами iгноруються
- Початковi та кiнцевi пробiли iгноруються
- Якщо `str` -- NULL або порожнiй рядок, повернути масив з одним елементом NULL
- Кожне слово копiюється в окрему malloc'd область пам'ятi

### Expected files

- `ft_split.c`

### Allowed functions

- `malloc`

### Example

```c
char **result = ft_split("  hello  world\t42  ");
// result[0] = "hello"
// result[1] = "world"
// result[2] = "42"
// result[3] = NULL
```

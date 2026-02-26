---
id: exam_l4_ft_list_foreach
module: exam
phase: phase4
title: "ft_list_foreach"
difficulty: 5
xp: 80
estimated_minutes: 45
prerequisites: []
tags: ["exam", "linked_list", "function_pointer"]
norminette: true
man_pages: []
multi_day: false
order: 273
level: 4
time_limit_minutes: 45
---

# ft_list_foreach

## Assignment

Напиши функцiю `ft_list_foreach`, яка застосовує функцiю `f` до поля `data` кожного елемента зв'язаного списку.

Структура `t_list`:

```c
typedef struct    s_list
{
    struct s_list *next;
    void          *data;
}                 t_list;
```

### Прототип

```c
void  ft_list_foreach(t_list *begin_list, void (*f)(void *));
```

Функцiя обходить список вiд `begin_list` до кiнця та викликає `f` на `data` кожного вузла.

### Expected files

- `ft_list_foreach.c`

### Allowed functions

- None

### Example

```c
// Якщо f = функцiя що друкує рядок, а список мiстить "A" -> "B" -> "C"
// ft_list_foreach(list, print_str) виведе: ABC
```

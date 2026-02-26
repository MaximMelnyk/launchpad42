---
id: exam_l4_sort_list
module: exam
phase: phase4
title: "sort_list"
difficulty: 5
xp: 80
estimated_minutes: 60
prerequisites: []
tags: ["exam", "linked_list", "sorting"]
norminette: true
man_pages: []
multi_day: false
order: 276
level: 4
time_limit_minutes: 60
---

# sort_list

## Assignment

Напиши функцiю `sort_list`, яка сортує зв'язаний список за допомогою функцiї порiвняння `cmp`.

Функцiя `cmp` приймає два числа та повертає ненульове значення, якщо вони у правильному порядку, або 0, якщо потрiбно помiняти мiсцями.

Структура `t_list` для цього завдання:

```c
typedef struct    s_list
{
    struct s_list *next;
    int           data;
}                 t_list;
```

### Прототип

```c
t_list  *sort_list(t_list *lst, int (*cmp)(int, int));
```

Повертає вказiвник на початок вiдсортованого списку. Дозволяється мiняти мiсцями data або переставляти вузли.

### Expected files

- `sort_list.c`

### Allowed functions

- None

### Example

```c
int ascending(int a, int b)
{
    return (a <= b);
}

/* Список: 5 -> 3 -> 1 -> 4 -> 2 */
/* sort_list(list, ascending) -> 1 -> 2 -> 3 -> 4 -> 5 */
```

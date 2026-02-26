---
id: exam_l4_ft_list_remove_if
module: exam
phase: phase4
title: "ft_list_remove_if"
difficulty: 5
xp: 80
estimated_minutes: 90
prerequisites: []
tags: ["exam", "linked_list", "function_pointer"]
norminette: true
man_pages: []
multi_day: false
order: 274
level: 4
time_limit_minutes: 90
---

# ft_list_remove_if

## Assignment

Напиши функцiю `ft_list_remove_if`, яка видаляє зi зв'язаного списку всi елементи, для яких `cmp(elem->data, data_ref)` повертає 0.

Для кожного видаленого елемента потрiбно звiльнити його `data` за допомогою `free_fct`, а потiм сам елемент -- за допомогою `free`.

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
void  ft_list_remove_if(t_list **begin_list, void *data_ref,
                         int (*cmp)(), void (*free_fct)(void *));
```

Параметри:
- `begin_list` -- вказiвник на вказiвник на початок списку (може змiнитися, якщо видаляється head)
- `data_ref` -- еталонне значення для порiвняння
- `cmp` -- функцiя порiвняння (повертає 0 якщо елементи рiвнi, як `strcmp`)
- `free_fct` -- функцiя для звiльнення `data` (наприклад, `free`)

### Expected files

- `ft_list_remove_if.c`

### Allowed functions

- `free`

### Example

```c
// Список: "rm" -> "keep" -> "rm" -> "also_keep"
// cmp = strcmp, data_ref = "rm", free_fct = free
// Пiсля виклику: "keep" -> "also_keep"
```

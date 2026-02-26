---
id: exam_l3_ft_list_size
module: exam
phase: phase4
title: "ft_list_size"
difficulty: 4
xp: 60
estimated_minutes: 30
prerequisites: []
tags: ["exam", "linked_list"]
norminette: true
man_pages: []
multi_day: false
order: 254
level: 3
time_limit_minutes: 30
---

# ft_list_size

## Assignment

Напиши функцію `ft_list_size`, яка повертає кількість елементів у зв'язаному списку (linked list).

Використай наступний typedef (включи його у свій файл):

```c
typedef struct s_list
{
	struct s_list	*next;
	void		*data;
}	t_list;
```

### Prototype

```c
int	ft_list_size(t_list *begin_list);
```

### Expected files

- `ft_list_size.c`

### Allowed functions

- None

### Example

```c
/* List: [A] -> [B] -> [C] -> NULL */
ft_list_size(list);  /* returns 3 */

/* Empty list: NULL */
ft_list_size(NULL);  /* returns 0 */
```

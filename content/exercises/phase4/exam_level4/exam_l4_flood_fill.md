---
id: exam_l4_flood_fill
module: exam
phase: phase4
title: "flood_fill"
difficulty: 5
xp: 80
estimated_minutes: 60
prerequisites: []
tags: ["exam", "recursion", "2d_array"]
norminette: true
man_pages: []
multi_day: false
order: 270
level: 4
time_limit_minutes: 60
---

# flood_fill

## Assignment

Напиши функцiю `flood_fill`, яка заповнює зв'язану область у двовимiрному масивi символiв.

Функцiя починає з позицiї `begin` та замiнює всi з'єднанi символи (такi ж як у стартовiй позицiї) на символ `'F'`. З'єднання визначається за 4 напрямками (вгору, вниз, влiво, вправо).

Структура `t_point` та прототип функцiї визначенi у header-файлi `flood_fill.h`:

```c
typedef struct  s_point
{
    int           x;
    int           y;
}               t_point;

void  flood_fill(char **tab, t_point size, t_point begin);
```

Параметри:
- `tab` -- двовимiрний масив символiв (grid)
- `size` -- розмiр grid (size.x = кiлькiсть стовпцiв, size.y = кiлькiсть рядкiв)
- `begin` -- стартова позицiя (begin.x = стовпець, begin.y = рядок)

### Expected files

- `flood_fill.c`
- `flood_fill.h`

### Allowed functions

- None

### Example

```
Grid before:
11111
10001
10101
10001
11111

begin = {3, 1}, size = {5, 5}

Grid after:
11111
1FFF1
1F1F1
1FFF1
11111
```

Символ `'0'` у позицiї (3,1) та всi з'єднанi `'0'` замiнюються на `'F'`.

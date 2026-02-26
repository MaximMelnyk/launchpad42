---
id: exam_sim_02
module: exam_sim
phase: phase2
title: "Exam Simulation 2 (4h)"
difficulty: 3
xp: 200
estimated_minutes: 240
prerequisites: ["gate_level2"]
tags: ["exam", "simulation"]
norminette: false
man_pages: []
multi_day: false
order: 106
---

# Exam Simulation 2 (4h)

## Завдання

Це твоя **друга симуляція іспиту Piscine**. На відміну від першої (Levels 0-2), тут додається **Level 3** -- функції з malloc та складнішою логікою. Порівняй свій результат з першою симуляцією, щоб побачити прогрес.

**Мета:** дістатись до Level 3. Якщо на першій симуляції ти дійшов до Level 1-2, то зараз мета -- впевнено пройти Level 2 та спробувати Level 3. На реальній Piscine другий іспит (3-й тиждень) очікує рівень 2-3.

## Підготовка (перед стартом)

### Налаштування середовища

1. **Закрий все зайве:** браузер, месенджери, музику, YouTube
2. **Відключи інтернет** (Wi-Fi off або Flight Mode на роутері)
3. **Тільки дозволені інструменти:**
   - Термінал (bash)
   - Текстовий редактор: **Vim** або **Emacs** (НЕ VS Code!)
   - Компілятор: `gcc -Wall -Wextra -Werror`
   - Man сторінки: `man 2 write`, `man 3 malloc` тощо
4. **Встанови таймер:** рівно 4 години (240 хвилин)
5. **Створи робочу директорію:**

```bash
mkdir -p ~/exam_sim_02
cd ~/exam_sim_02
```

### Правила

- Жодного інтернету, жодних нотаток, жодних шпаргалок
- Тільки `man` сторінки дозволені для довідки
- Кожне завдання -- окрема директорія (`ex00/`, `ex01/`, тощо)
- Компілюй з `-Wall -Wextra -Werror`
- Norminette обов'язкова
- Тільки `write()` та `malloc`/`free` -- жодного `printf`

## Завдання іспиту

### Рівень 0 (Level 0) -- вибери одне

| # | Завдання | Опис | Очікуваний час |
|---|----------|------|----------------|
| A | ft_putchar | Вивести один символ | 2 хв |
| B | ft_print_numbers | Вивести "0123456789" | 3 хв |
| C | first_word | Вивести перше слово рядка (argv) | 5 хв |

Якщо правильно -- переходиш на Level 1. Якщо ні -- ще одне завдання Level 0.

### Рівень 1 (Level 1) -- вибери одне

| # | Завдання | Опис | Очікуваний час |
|---|----------|------|----------------|
| A | ft_strlen | Довжина рядка | 5 хв |
| B | ft_strcpy | Копіювання рядка | 5 хв |
| C | repeat_alpha | 'a'->1x, 'b'->2x, 'c'->3x... | 10 хв |
| D | rot_13 | ROT13 шифрування (argv) | 10 хв |
| E | rev_print | Вивести рядок задом-наперед | 5 хв |
| F | search_and_replace | Замінити символ c1 на c2 (argv) | 10 хв |

### Рівень 2 (Level 2) -- вибери одне

| # | Завдання | Опис | Очікуваний час |
|---|----------|------|----------------|
| A | ft_atoi | Рядок в число | 15 хв |
| B | ft_strcmp | Порівняння двох рядків | 10 хв |
| C | ft_strdup | Дублікат рядка (malloc) | 10 хв |
| D | ft_strrev | Розвернути рядок in-place | 10 хв |
| E | ft_print_hex | Число в hex | 15 хв |
| F | inter | Символи, спільні для двох рядків (argv) | 15 хв |

### Рівень 3 (Level 3) -- вибери одне

| # | Завдання | Опис | Очікуваний час |
|---|----------|------|----------------|
| A | ft_atoi_base | Конвертація числа з будь-якої бази | 25 хв |
| B | ft_list_size | Довжина linked list (int) | 15 хв |
| C | ft_range | malloc масив від min до max | 15 хв |
| D | ft_rrange | malloc масив від max до min | 15 хв |
| E | add_prime_sum | Сума простих чисел до n (argv) | 20 хв |
| F | ft_sort_int_tab | Сортування масиву int (bubble sort) | 15 хв |

**Level 3 деталі:**

**ft_atoi_base:**
```c
int	ft_atoi_base(char *str, char *base);
/* "1A" base "0123456789ABCDEF" -> 26 */
```

**ft_range:**
```c
int	*ft_range(int min, int max);
/* ft_range(1, 5) -> [1, 2, 3, 4, 5] (malloc'd) */
/* if min >= max, return NULL */
```

**ft_sort_int_tab:**
```c
void	ft_sort_int_tab(int *tab, int size);
/* Bubble sort, ascending order */
```

## Процедура виконання

### Крок 1: Обери та виконай Level 0

```bash
mkdir -p ex00
cd ex00
vim ft_putchar.c    # або інше завдання
gcc -Wall -Wextra -Werror -o test ft_putchar.c main.c
./test
```

### Крок 2: Самоперевірка

Після кожного рівня перевір вручну:
- Компілюється без помилок?
- Вивід відповідає очікуваному?
- Norminette пройдена?

### Крок 3: Перехід на наступний рівень

Якщо впевнений у відповіді -- переходь на наступний рівень. Якщо помилка -- спробуй інше завдання того ж рівня.

### Крок 4: Запис результатів

Після закінчення часу (або після завершення всіх рівнів) створи файл з результатами:

```bash
cat > ~/exam_sim_02/results.txt << 'EOF'
Exam Simulation 2 Results
Date: YYYY-MM-DD
Duration: XXX minutes (of 240)

Level 0: PASS/FAIL - [task name] - [minutes spent]
Level 1: PASS/FAIL - [task name] - [minutes spent]
Level 2: PASS/FAIL - [task name] - [minutes spent]
Level 3: PASS/FAIL - [task name] - [minutes spent]

Total level reached: X
Comparison with Sim 1: [better/same/worse] - [details]
Notes: [what was hardest, what to review]
EOF
```

## Оцінювання

| Результат | Оцінка | Коментар |
|-----------|--------|----------|
| Level 0 | 20% | Ти знаєш основи |
| Level 1 | 40% | Базовий рівень |
| Level 2 | 60% | Солідний результат |
| Level 3 | 80% | Відмінно! Вище середнього для 2-го іспиту |
| Level 3 + час залишився | 100% | Чудово! Готовий до фінального іспиту |

**Порівняння з Sim 1:** запиши в `results.txt`, на скільки рівнів ти покращився. Будь-яке покращення -- це прогрес!

**На реальній Piscine:** на 2-му іспиті (3-й тиждень) більшість студентів досягають Level 1-3. Level 3 -- це вже above average.

## Після іспиту

1. **Запиши результати** у `results.txt`
2. **Порівняй з Sim 1:** чи покращився результат?
3. **Визнач слабкі місця:** яке завдання було найскладнішим?
4. **Фокус на Level 3:** якщо не дійшов -- повтори ft_atoi_base, ft_range, ft_sort_int_tab
5. **Vim comfort:** чи став Vim зручнішим порівняно з Sim 1?

## Підказки

<details>
<summary>Підказка: стратегія іспиту (Level 0-2)</summary>

Levels 0-2 повинні бути **автоматичними** на цьому етапі:

1. **Level 0** -- максимум 3 хвилини. Якщо витрачаєш більше -- повтори C00.
2. **Level 1** -- ft_strlen або ft_strcpy найшвидші (5 хв). rot_13 -- найповільніший.
3. **Level 2** -- ft_strcmp зазвичай найшвидший. ft_strdup -- найкоротший (malloc + copy).

Бюджет часу для Levels 0-2: максимум 45 хвилин. Це залишає 3+ години для Level 3.

</details>

<details>
<summary>Підказка: стратегія Level 3</summary>

Level 3 функції ранжовані за складністю:

1. **ft_sort_int_tab** (найлегша) -- bubble sort, 10 рядків. Якщо знаєш паттерн -- 10 хвилин.
2. **ft_range** (легка) -- malloc + while loop. Не забудь обробити `min >= max`.
3. **ft_rrange** -- те саме що ft_range, тільки від max до min.
4. **add_prime_sum** -- комбінація ft_atoi + ft_is_prime в циклі.
5. **ft_list_size** -- якщо знаєш linked lists. Простий while loop по `->next`.
6. **ft_atoi_base** (найскладніша) -- потребує перевірки валідності бази + конвертації.

Обирай те, що знаєш найкраще. На реальному іспиті система обирає за тебе.

</details>

<details>
<summary>Підказка: Vim швидкий набір</summary>

До цього моменту ти повинен знати ці Vim команди напам'ять:

```
i          -- insert mode
Esc        -- normal mode
:wq        -- save + quit
:q!        -- quit without save
dd         -- delete line
yy / p     -- copy / paste line
u          -- undo
/text      -- search
:set nu    -- line numbers
ciw        -- change inner word (super useful!)
o          -- new line below + insert
O          -- new line above + insert
>>         -- indent line
<<         -- unindent line
gg         -- go to top
G          -- go to bottom
```

</details>

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| іспит | examen | "Le deuxieme examen de la Piscine" |
| покращення | amelioration / progression | "Comparer ta progression avec l'examen 1" |
| рівень | niveau | "J'ai atteint le niveau 3 cette fois" |
| пам'ять | memoire | "malloc alloue de la memoire dynamique" |
| сортування | tri | "Trier un tableau d'entiers" |
| зв'язаний список | liste chainee | "Compter les elements d'une liste chainee" |

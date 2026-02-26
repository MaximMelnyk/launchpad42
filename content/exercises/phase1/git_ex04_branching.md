---
id: git_ex04_branching
module: git
phase: phase1
title: "Branching"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["git_ex03_log_diff"]
tags: ["git", "version-control", "branching", "merge", "HEAD"]
norminette: false
man_pages: ["git", "git-branch", "git-checkout", "git-merge", "git-switch"]
multi_day: false
order: 21
---

# Branching

## Завдання

Навчися створювати гілки (branches), перемикатися між ними та зливати (merge) зміни. Розуміння гілок -- це ключ до ефективної роботи з Git.

### Що потрібно зробити

**Частина 1: Створи репозиторій з початковим кодом**

```bash
mkdir ~/git_branches && cd ~/git_branches
git init
```

1. Створи `ft_swap.c`:

```c
#include <unistd.h>

void	ft_swap(int *a, int *b)
{
	int	tmp;

	tmp = *a;
	*a = *b;
	*b = tmp;
}
```

```bash
git add ft_swap.c
git commit -m "Add ft_swap"
```

**Частина 2: Працюй з гілками**

2. Створи нову гілку `feature/ft_div_mod`:

```bash
git branch feature/ft_div_mod
```

3. Перемкнися на неї:

```bash
git checkout feature/ft_div_mod
```

(або одна команда: `git checkout -b feature/ft_div_mod`)

4. На цій гілці створи `ft_div_mod.c`:

```c
void	ft_div_mod(int a, int b, int *div, int *mod)
{
	*div = a / b;
	*mod = a % b;
}
```

```bash
git add ft_div_mod.c
git commit -m "Add ft_div_mod"
```

5. Повернися на `master`:

```bash
git checkout master
```

6. Перевір: `ft_div_mod.c` зникла! Вона існує тільки на гілці `feature/ft_div_mod`.

```bash
ls    # тільки ft_swap.c
```

7. Створи ще одну гілку `feature/ft_putchar` від `master`:

```bash
git checkout -b feature/ft_putchar
```

8. Додай `ft_putchar.c`:

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}
```

```bash
git add ft_putchar.c
git commit -m "Add ft_putchar"
```

**Частина 3: Merge**

9. Повернися на `master` та злий обидві гілки:

```bash
git checkout master
git merge feature/ft_div_mod
git merge feature/ft_putchar
```

10. Перевір результат:

```bash
git log --oneline --graph --all
ls    # ft_swap.c ft_div_mod.c ft_putchar.c
```

### Вимоги

- Репозиторій `~/git_branches/` має існувати
- Гілки `feature/ft_div_mod` та `feature/ft_putchar` створені
- Обидві гілки злиті (merged) у `master`
- На `master` присутні всі 3 файли: `ft_swap.c`, `ft_div_mod.c`, `ft_putchar.c`
- `git log --oneline --graph --all` показує коректну структуру гілок

### Очікуваний результат

```bash
$ git log --oneline --graph --all
*   eee5555 Merge branch 'feature/ft_putchar'
|\
| * ddd4444 Add ft_putchar
|/
*   ccc3333 Merge branch 'feature/ft_div_mod'
|\
| * bbb2222 Add ft_div_mod
|/
* aaa1111 Add ft_swap
```

## Контекст Piscine

На Piscine ти зазвичай НЕ використовуєш гілки -- весь код пушиться на `master`. Але розуміння гілок важливе для:

- Rush-проєктів (командна робота, кожен працює на своїй гілці)
- Реального робочого процесу після Piscine (у 42 та в індустрії)
- Розуміння `HEAD`, що допомагає при debug

**HEAD** -- це вказівник на поточну гілку/коміт. Коли ти робиш `git checkout feature/x`, HEAD переміщується на `feature/x`. Думай про HEAD як про "ти тут" на карті.

## Підказки

<details>
<summary>Підказка 1</summary>

Основні команди для гілок:

```bash
git branch                # показати всі гілки (* = поточна)
git branch <name>         # створити нову гілку
git checkout <name>       # перемкнутися на гілку
git checkout -b <name>    # створити + перемкнутися
git merge <name>          # злити гілку в поточну
git branch -d <name>      # видалити гілку (після merge)
```

Також можна використовувати новіші команди:

```bash
git switch <name>         # перемкнутися (замість checkout)
git switch -c <name>      # створити + перемкнутися
```

</details>

<details>
<summary>Підказка 2</summary>

Якщо `git merge` створює "merge commit" -- це нормально. Це коміт, який об'єднує дві лінії розробки. У `git log --graph` він виглядає як точка, де дві лінії зливаються.

Якщо merge відбувається як "fast-forward" (гілки не розходилися) -- Git просто переміщує вказівник. Merge commit не створюється.

</details>

## Man сторінки

- `man git-branch`
- `man git-checkout`
- `man git-switch`
- `man git-merge`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| гілка | branche | "Cree une nouvelle branche" |
| злити | fusionner / merger | "Fusionne la branche dans master" |
| перемкнутися | changer de branche | "Change de branche" |
| голова | HEAD | "HEAD pointe sur master" |
| основна гілка | branche principale | "Reviens sur la branche principale" |

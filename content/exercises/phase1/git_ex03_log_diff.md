---
id: git_ex03_log_diff
module: git
phase: phase1
title: "Log & Diff"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["git_ex02_clone_push"]
tags: ["git", "version-control", "log", "diff", "history"]
norminette: false
man_pages: ["git", "git-log", "git-diff", "git-show"]
multi_day: false
order: 20
---

# Log & Diff

## Завдання

Навчися читати історію комітів та бачити зміни між версіями файлів. Ці навички критично важливі для debug та peer review.

### Що потрібно зробити

**Частина 1: Підготуй репозиторій з кількома комітами**

1. Створи новий репозиторій та зроби серію комітів:

```bash
mkdir ~/git_log_practice && cd ~/git_log_practice
git init
```

2. Коміт 1 -- створи `ft_strlen.c`:

```c
#include <unistd.h>

int	ft_strlen(char *str)
{
	int	i;

	i = 0;
	while (str[i])
		i++;
	return (i);
}
```

```bash
git add ft_strlen.c
git commit -m "Add ft_strlen"
```

3. Коміт 2 -- зміни `ft_strlen.c` (зроби параметр `const`):

```c
#include <unistd.h>

int	ft_strlen(const char *str)
{
	int	i;

	i = 0;
	while (str[i])
		i++;
	return (i);
}
```

```bash
git add ft_strlen.c
git commit -m "Make ft_strlen parameter const"
```

4. Коміт 3 -- додай `ft_putstr.c`:

```c
#include <unistd.h>

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		write(1, &str[i], 1);
		i++;
	}
}
```

```bash
git add ft_putstr.c
git commit -m "Add ft_putstr"
```

**Частина 2: Досліди Git-історію**

5. Переглянь лог в різних форматах:

```bash
git log                    # повний формат
git log --oneline          # компактний (1 рядок = 1 коміт)
git log --oneline --graph  # з графом гілок
git log --stat             # зі статистикою файлів
```

6. Переглянь конкретний коміт:

```bash
git show HEAD              # останній коміт
git show HEAD~1            # попередній коміт
```

7. Переглянь різницю між комітами:

```bash
git diff HEAD~2 HEAD~1     # diff між 1-м і 2-м комітом
git diff HEAD~1 HEAD       # diff між 2-м і 3-м комітом
```

**Частина 3: Створи файл-звіт**

8. Створи файл `git_log_report.txt` з виводом `git log --oneline`:

```bash
git log --oneline > git_log_report.txt
```

### Вимоги

- Репозиторій `~/git_log_practice/` має містити 3 коміти
- Коміти мають правильні повідомлення: `"Add ft_strlen"`, `"Make ft_strlen parameter const"`, `"Add ft_putstr"`
- Файл `git_log_report.txt` містить 3 рядки (oneline log)
- Ти знаєш різницю між `git log`, `git show`, `git diff`

### Очікуваний результат

```bash
$ git log --oneline
ccc3333 Add ft_putstr
bbb2222 Make ft_strlen parameter const
aaa1111 Add ft_strlen
$ git diff HEAD~2 HEAD~1
diff --git a/ft_strlen.c b/ft_strlen.c
-int	ft_strlen(char *str)
+int	ft_strlen(const char *str)
```

## Підказки

<details>
<summary>Підказка 1</summary>

**HEAD** -- це вказівник на поточний коміт (зазвичай останній коміт поточної гілки).

- `HEAD` = останній коміт
- `HEAD~1` = на 1 коміт назад
- `HEAD~2` = на 2 коміти назад
- `HEAD~N` = на N комітів назад

Це як відлік від "зараз" у минуле.

</details>

<details>
<summary>Підказка 2</summary>

Різниця між командами:

| Команда | Що показує |
|---------|-----------|
| `git log` | Список всіх комітів (хеш, автор, дата, повідомлення) |
| `git show <commit>` | Деталі одного коміту (повідомлення + diff) |
| `git diff A B` | Різницю між двома станами (комітами, файлами) |
| `git diff` | Незакомічені зміни (working tree vs staging) |
| `git diff --staged` | Зміни у staging area (vs останній коміт) |

</details>

## Man сторінки

- `man git-log`
- `man git-diff`
- `man git-show`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| журнал / лог | journal / historique | "Regarde l'historique des commits" |
| різниця | difference / diff | "Fais un diff entre les deux versions" |
| коміт | commit | "Montre-moi le dernier commit" |
| зміни | modifications | "Quelles sont les modifications ?" |

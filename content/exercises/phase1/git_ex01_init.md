---
id: git_ex01_init
module: git
phase: phase1
title: "Init & First Commit"
difficulty: 1
xp: 15
estimated_minutes: 20
prerequisites: ["sh01_ex08_add_chelou"]
tags: ["git", "version-control", "basics"]
norminette: false
man_pages: ["git", "git-init", "git-add", "git-commit", "git-status"]
multi_day: false
order: 18
---

# Init & First Commit

## Завдання

Навчися створювати Git-репозиторій з нуля, додавати файли під контроль версій та робити перший коміт.

Git -- це основний інструмент здачі робіт у Piscine 42. Кожний проєкт, кожна вправа здається через `git push` у Vogsphere (сервер Git у 42). Якщо ти не вмієш git -- ти не зможеш здати жодної вправи.

### Що потрібно зробити

1. Створи директорію `my_first_repo/`
2. Ініціалізуй у ній Git-репозиторій (`git init`)
3. Створи файл `hello.c` з наступним вмістом:

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

int	main(void)
{
	ft_putchar('H');
	ft_putchar('i');
	ft_putchar('\n');
	return (0);
}
```

4. Перевір статус репозиторію (`git status`)
5. Додай файл до staging area (`git add hello.c`)
6. Зроби коміт з повідомленням `"Initial commit"` (`git commit -m "Initial commit"`)
7. Перевір, що коміт створено (`git log`)

### Вимоги

- Директорія `my_first_repo/` має бути Git-репозиторієм (містити `.git/`)
- Файл `hello.c` має бути закомічений (tracked, not modified)
- В історії має бути рівно 1 коміт з повідомленням `"Initial commit"`
- `git status` повинен показувати `nothing to commit, working tree clean`

### Очікуваний результат

```bash
$ cd my_first_repo/
$ git log --oneline
abc1234 Initial commit
$ git status
On branch master
nothing to commit, working tree clean
```

## Контекст Piscine

У Piscine 42 ти не створюєш репозиторії з `git init`. Замість цього ти робиш `git clone` з Vogsphere. Але розуміння `git init` важливе для роботи з особистими проєктами та для глибшого розуміння того, як працює Git.

**Vogsphere** -- це Git-сервер 42. Кожний проєкт має свій репозиторій на Vogsphere. Ти клонуєш його, працюєш локально, пушиш назад для здачі.

## Підказки

<details>
<summary>Підказка 1</summary>

Ось повна послідовність команд:

```bash
mkdir my_first_repo
cd my_first_repo
git init
```

Після `git init` ти побачиш повідомлення `Initialized empty Git repository in ...`. Це означає, що директорія `.git/` створена -- Git тепер відстежує цю папку.

</details>

<details>
<summary>Підказка 2</summary>

`git status` -- це твій найкращий друг. Використовуй його ЗАВЖДИ перед `git add` та `git commit`, щоб бачити стан файлів:

- **Untracked files** -- Git бачить файл, але не відстежує його
- **Changes to be committed** -- файл у staging area, готовий до коміту
- **nothing to commit** -- все чисто, все закомічено

```bash
git add hello.c      # додати до staging area
git status           # перевірити (має бути "Changes to be committed")
git commit -m "Initial commit"
git status           # перевірити (має бути "nothing to commit")
```

</details>

<details>
<summary>Підказка 3</summary>

Якщо Git просить налаштувати ім'я та email:

```bash
git config user.name "Your Name"
git config user.email "your@email.com"
```

Без `--global` ці налаштування діють тільки для цього репозиторію.

</details>

## Man сторінки

- `man git`
- `man git-init`
- `man git-add`
- `man git-commit`
- `man git-status`
- `man git-log`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| репозиторій | depot (repository) | "Cree un depot Git" |
| коміт | commit | "Fais ton premier commit" |
| додати | ajouter | "Ajoute le fichier au depot" |
| статус | statut / etat | "Verifie l'etat du depot" |
| версія | version | "Le controle de version" |

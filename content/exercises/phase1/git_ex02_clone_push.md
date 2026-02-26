---
id: git_ex02_clone_push
module: git
phase: phase1
title: "Clone & Push"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["git_ex01_init"]
tags: ["git", "version-control", "remote", "clone", "push"]
norminette: false
man_pages: ["git", "git-clone", "git-push", "git-remote"]
multi_day: false
order: 19
---

# Clone & Push

## Завдання

Навчися клонувати віддалений репозиторій, вносити зміни та пушити їх назад. Це ТОЧНИЙ workflow, який ти будеш використовувати щодня на Piscine.

### Що потрібно зробити

**Частина 1: Створи "віддалений" репозиторій (імітація Vogsphere)**

Оскільки у тебе немає доступу до Vogsphere, ми імітуємо його за допомогою bare-репозиторію:

```bash
mkdir -p /tmp/vogsphere
git init --bare /tmp/vogsphere/c00.git
```

**Частина 2: Клонуй та працюй**

1. Клонуй репозиторій: `git clone /tmp/vogsphere/c00.git ~/c00_work`
2. Зайди в клонований репозиторій: `cd ~/c00_work`
3. Перевір remotes: `git remote -v`
4. Створи директорію `ex00/` та файл `ex00/ft_putchar.c`:

```c
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}
```

5. Додай файл та зроби коміт:

```bash
git add ex00/ft_putchar.c
git commit -m "Add ex00: ft_putchar"
```

6. Запуш зміни: `git push origin master`

**Частина 3: Перевір результат**

7. Клонуй ще раз в іншу директорію, щоб переконатися, що push працює:

```bash
git clone /tmp/vogsphere/c00.git /tmp/c00_verify
ls /tmp/c00_verify/ex00/
```

### Вимоги

- Bare-репозиторій `/tmp/vogsphere/c00.git` містить коміт
- Робочий клон `~/c00_work` має remote `origin` що вказує на bare-репозиторій
- Файл `ex00/ft_putchar.c` існує та закомічений
- `git push` успішно відправив зміни до remote
- Повторний `git clone` показує, що файли присутні

### Очікуваний результат

```bash
$ cd ~/c00_work
$ git remote -v
origin	/tmp/vogsphere/c00.git (fetch)
origin	/tmp/vogsphere/c00.git (push)
$ git log --oneline
abc1234 Add ex00: ft_putchar
$ git status
On branch master
nothing to commit, working tree clean
```

## Контекст Piscine

На Piscine 42, Vogsphere -- це сервер, де зберігаються всі твої проєкти. Workflow:

1. Зайди на intra.42.fr, обери проєкт
2. `git clone vogsphere@vogsphere.42paris.fr:intra/2026/.../login-c00`
3. Працюй локально (write code, test, repeat)
4. `git add .` + `git commit -m "Done"` + `git push`
5. Moulinette (автоматичний грейдер) перевірить твій код

**ВАЖЛИВО:** Moulinette перевіряє ТІЛЬКИ те, що ти запушив. Якщо забудеш push -- 0 балів.

## Підказки

<details>
<summary>Підказка 1</summary>

**Bare repository** -- це репозиторій без робочої директорії (working tree). Він використовується як "сервер" для зберігання Git-історії. Vogsphere -- це фактично набір bare-репозиторіїв.

```bash
git init --bare   # створює bare repo (для серверів)
git init          # створює звичайний repo (для роботи)
```

</details>

<details>
<summary>Підказка 2</summary>

`git remote -v` показує всі remotes (віддалені сервери):

- **origin** -- це ім'я remote за замовчуванням після `git clone`
- `fetch` -- звідки Git завантажує зміни
- `push` -- куди Git відправляє зміни

Коли ти робиш `git push origin master`, ти кажеш: "Відправ гілку `master` на remote з ім'ям `origin`".

</details>

<details>
<summary>Підказка 3</summary>

Якщо `git push` видає помилку `error: src refspec master does not match any`, це означає, що ти ще не зробив жодного коміту. Спочатку зроби `git commit`, потім `git push`.

Якщо гілка називається `main` замість `master`:

```bash
git branch    # перевір назву гілки
git push origin main
```

</details>

## Man сторінки

- `man git-clone`
- `man git-push`
- `man git-remote`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| клонувати | cloner | "Clone le depot Vogsphere" |
| пушити | pousser / push | "T'as push ton projet ?" |
| віддалений | distant / remote | "Le depot distant" |
| гілка | branche | "La branche master" |
| origin | origin | "L'origin c'est Vogsphere" |

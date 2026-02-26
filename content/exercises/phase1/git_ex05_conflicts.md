---
id: git_ex05_conflicts
module: git
phase: phase1
title: "Conflict Resolution"
difficulty: 3
xp: 40
estimated_minutes: 35
prerequisites: ["git_ex04_branching"]
tags: ["git", "version-control", "merge", "conflict", "resolution"]
norminette: false
man_pages: ["git", "git-merge", "git-diff", "git-status"]
multi_day: false
order: 22
---

# Conflict Resolution

## Завдання

Навчися створювати merge-конфлікти навмисно та вирішувати їх вручну. Конфлікти в Git -- це не помилка, це нормальна ситуація, яку потрібно вміти розв'язувати.

### Що потрібно зробити

**Частина 1: Створи ситуацію конфлікту**

```bash
mkdir ~/git_conflict && cd ~/git_conflict
git init
```

1. Створи початковий файл `ft_abs.c`:

```c
int	ft_abs(int n)
{
	if (n < 0)
		return (-n);
	return (n);
}
```

```bash
git add ft_abs.c
git commit -m "Add ft_abs - basic version"
```

2. Створи гілку `refactor` та зміни реалізацію:

```bash
git checkout -b refactor
```

Зміни `ft_abs.c` на гілці `refactor`:

```c
int	ft_abs(int nb)
{
	if (nb < 0)
		nb = -nb;
	return (nb);
}
```

```bash
git add ft_abs.c
git commit -m "Refactor ft_abs: rename param, simplify"
```

3. Повернися на `master` та зроби ІНШІ зміни до ТОГО Ж файлу:

```bash
git checkout master
```

Зміни `ft_abs.c` на `master`:

```c
int	ft_abs(int value)
{
	if (value < 0)
		return (value * -1);
	return (value);
}
```

```bash
git add ft_abs.c
git commit -m "Improve ft_abs: better param name, multiply by -1"
```

**Частина 2: Спровокуй конфлікт**

4. Спробуй злити `refactor` в `master`:

```bash
git merge refactor
```

Git скаже: `CONFLICT (content): Merge conflict in ft_abs.c`. Це означає, що Git не може автоматично вирішити, яка версія правильна.

**Частина 3: Вирішити конфлікт**

5. Відкрий `ft_abs.c` -- ти побачиш маркери конфлікту:

```
<<<<<<< HEAD
int	ft_abs(int value)
{
	if (value < 0)
		return (value * -1);
	return (value);
=======
int	ft_abs(int nb)
{
	if (nb < 0)
		nb = -nb;
	return (nb);
>>>>>>> refactor
}
```

6. Вирішити конфлікт вручну -- обери найкращу версію або комбінуй:

```c
int	ft_abs(int nb)
{
	if (nb < 0)
		return (-nb);
	return (nb);
}
```

7. Збережи файл, додай та закоміть:

```bash
git add ft_abs.c
git commit -m "Resolve merge conflict in ft_abs"
```

### Вимоги

- Репозиторій `~/git_conflict/` має існувати
- Гілка `refactor` створена та злита
- Конфлікт вирішено (файл НЕ містить маркерів `<<<<<<<`, `=======`, `>>>>>>>`)
- Фінальна версія `ft_abs.c` компілюється без помилок
- В історії є merge commit з повідомленням про вирішення конфлікту

### Очікуваний результат

```bash
$ git log --oneline --graph
*   fff6666 Resolve merge conflict in ft_abs
|\
| * ddd4444 Refactor ft_abs: rename param, simplify
* | eee5555 Improve ft_abs: better param name, multiply by -1
|/
* aaa1111 Add ft_abs - basic version
$ grep -c "<<<<<<" ft_abs.c
0
```

## Контекст Piscine

Конфлікти виникають у Rush-проєктах, коли двоє студентів редагують один файл. Типовий сценарій:

1. Студент A пушить свою версію `main.c`
2. Студент B пушить свою версію `main.c`
3. `git push` відхиляє push студента B
4. Студент B робить `git pull` --> КОНФЛІКТ
5. Студент B вирішує конфлікт, комітить, пушить

Якщо ти не вмієш вирішувати конфлікти -- Rush-проєкти стануть кошмаром.

## Підказки

<details>
<summary>Підказка 1</summary>

Маркери конфлікту мають просту структуру:

```
<<<<<<< HEAD
(твоя поточна версія на master)
=======
(версія з гілки, яку ти зливаєш)
>>>>>>> refactor
```

Щоб вирішити конфлікт:
1. Видали ВСІ маркери (`<<<<<<<`, `=======`, `>>>>>>>`)
2. Залиш правильний код (або комбінуй обидві версії)
3. `git add` + `git commit`

</details>

<details>
<summary>Підказка 2</summary>

Корисні команди під час конфлікту:

```bash
git status              # показує файли з конфліктами
git diff                # показує маркери конфлікту
git merge --abort       # скасувати merge та повернутися до стану до merge
```

`git merge --abort` -- це твій "план Б". Якщо заплутався -- скасуй merge та спробуй знову.

</details>

## Man сторінки

- `man git-merge` (секція "HOW CONFLICTS ARE PRESENTED")
- `man git-diff`
- `man git-status`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| конфлікт | conflit | "Y'a un conflit dans le fichier" |
| вирішити | resoudre | "Resous le conflit manuellement" |
| злити | fusionner | "Fusionne la branche" |
| скасувати | annuler | "Annule le merge" |
| вручну | manuellement | "Edite le fichier manuellement" |

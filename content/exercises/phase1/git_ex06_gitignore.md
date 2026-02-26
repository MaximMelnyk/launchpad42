---
id: git_ex06_gitignore
module: git
phase: phase1
title: ".gitignore Mastery"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["git_ex05_conflicts"]
tags: ["git", "version-control", "gitignore", "patterns"]
norminette: false
man_pages: ["git", "gitignore"]
multi_day: false
order: 23
---

# .gitignore Mastery

## Завдання

Навчися правильно налаштовувати `.gitignore`, щоб Git ігнорував непотрібні файли: об'єктні файли (`.o`), виконувані файли, тимчасові файли. Це критично для Piscine -- Moulinette ПЕРЕВІРЯЄ наявність `.gitignore`.

### Що потрібно зробити

**Частина 1: Створи проєкт з типовими файлами**

```bash
mkdir ~/git_ignore_practice && cd ~/git_ignore_practice
git init
```

1. Створи C-файли та імітуй компіляцію:

```bash
# Source files
cat > ft_putchar.c << 'EOF'
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}
EOF

cat > main.c << 'EOF'
void	ft_putchar(char c);

int	main(void)
{
	ft_putchar('A');
	ft_putchar('\n');
	return (0);
}
EOF

# Compile (creates .o and executable)
gcc -Wall -Wextra -Werror -c ft_putchar.c -o ft_putchar.o
gcc -Wall -Wextra -Werror -c main.c -o main.o
gcc ft_putchar.o main.o -o a.out

# Create typical junk files
touch .DS_Store
touch ft_putchar.c~
touch main.c~
touch libft.a
```

2. Перевір `git status` -- Git бачить ВСЕ:

```bash
git status
```

**Частина 2: Створи .gitignore**

3. Створи файл `.gitignore` з правильними патернами:

```
# Object files
*.o

# Executables
a.out

# Static libraries
*.a

# Editor backup files
*~

# macOS
.DS_Store

# Vim swap files
*.swp
*.swo
```

4. Перевір `git status` -- тепер Git бачить тільки `.c`, `.gitignore`:

```bash
git status
```

5. Закоміть:

```bash
git add .gitignore ft_putchar.c main.c
git commit -m "Add source files and .gitignore"
```

**Частина 3: Патерни-виключення (negation)**

6. Додай складніший випадок -- ігнорувати все, крім певних файлів:

```
# Ignore all in build/ directory
build/

# But keep the README
!build/README.md
```

Для цього:

```bash
mkdir build
touch build/program build/temp.log
echo "Build instructions" > build/README.md
```

7. Оновлена `.gitignore`:

```
# Object files
*.o

# Executables
a.out

# Static libraries
*.a

# Editor backup files
*~

# macOS
.DS_Store

# Vim swap files
*.swp
*.swo

# Build directory (keep README)
build/*
!build/README.md
```

```bash
git add .gitignore build/README.md
git commit -m "Update gitignore: add build/ with README exception"
```

### Вимоги

- Файл `.gitignore` існує та закомічений
- `*.o` файли ігноруються (не з'являються в `git status`)
- `a.out` ігнорується
- `*.a` ігнорується
- `*~` файли ігноруються
- `.DS_Store` ігнорується
- `*.swp` / `*.swo` ігноруються
- Патерн negation (`!`) працює для `build/README.md`
- Тільки `.c` файли та `.gitignore` закомічені

### Очікуваний результат

```bash
$ git status
On branch master
nothing to commit, working tree clean
$ git ls-files
.gitignore
build/README.md
ft_putchar.c
main.c
```

## Контекст Piscine

На Piscine у кожному модулі потрібен правильний `.gitignore`. Типові помилки студентів:

- Пушать `.o` файли -- Moulinette може не перекомпілити
- Пушать `a.out` -- зайві файли у репозиторії
- Пушать `.DS_Store` (macOS) або `*.swp` (Vim) -- засмічують репозиторій
- Не пушать `.gitignore` -- Moulinette може перевіряти його наявність

У Shell00 вправа ex06 (sh00_ex06) -- це саме створення `.gitignore`. Ця вправа -- глибше занурення.

## Підказки

<details>
<summary>Підказка 1</summary>

Основні патерни `.gitignore`:

| Патерн | Що ігнорує |
|--------|-----------|
| `*.o` | Всі файли з розширенням `.o` |
| `a.out` | Конкретний файл `a.out` |
| `build/` | Вся директорія `build/` |
| `*~` | Всі файли що закінчуються на `~` (бекапи) |
| `!important.o` | НЕ ігнорувати `important.o` (виключення) |
| `*.swp` | Vim swap файли |

</details>

<details>
<summary>Підказка 2</summary>

Якщо файл вже закомічений, `.gitignore` НЕ буде його ігнорувати. Потрібно спочатку видалити його з Git:

```bash
git rm --cached file.o    # видалити з Git, але залишити на диску
git commit -m "Remove tracked .o file"
```

Тому ЗАВЖДИ створюй `.gitignore` ПЕРЕД першим `git add`.

</details>

<details>
<summary>Підказка 3</summary>

Перевірити, чи Git ігнорує конкретний файл:

```bash
git check-ignore -v ft_putchar.o
# Вивід: .gitignore:2:*.o	ft_putchar.o
```

Це показує: файл ігнорується правилом `*.o` з рядка 2 файлу `.gitignore`.

</details>

## Man сторінки

- `man gitignore`
- `man git-check-ignore`
- `man git-ls-files`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| ігнорувати | ignorer | "Le .gitignore ignore les fichiers .o" |
| патерн | motif / pattern | "Ajoute un motif pour les backups" |
| виключення | exception | "Fais une exception pour le README" |
| відслідковувати | suivre / tracker | "Git ne suit pas les fichiers ignores" |

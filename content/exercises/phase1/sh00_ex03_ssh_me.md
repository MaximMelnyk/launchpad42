---
id: sh00_ex03_ssh_me
module: shell00
phase: phase1
title: "SSH me!"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh00_ex02_oh_yeah"]
tags: ["shell", "ssh", "keys", "security"]
norminette: false
man_pages: ["ssh-keygen", "ssh"]
multi_day: false
order: 4
---

# SSH me!

## Завдання

Згенеруй пару SSH-ключів і здай публічний ключ.

SSH (Secure Shell) -- це протокол для безпечного підключення до віддалених серверів. На Piscine ти будеш використовувати SSH-ключі для автентифікації на Git-сервері vogsphere. Без правильно налаштованого SSH-ключа ти не зможеш здати жодний проєкт.

### Вимоги

- Згенеруй пару RSA-ключів за допомогою `ssh-keygen`
- Тип ключа: RSA
- Здай файл `id_rsa.pub` (публічний ключ) у директорії `ex03/`
- **НІКОЛИ** не здавай `id_rsa` (приватний ключ)

### Що таке SSH-ключі

SSH-ключі працюють як замок і ключ:
- **Публічний ключ** (`id_rsa.pub`) -- це замок. Його можна давати всім.
- **Приватний ключ** (`id_rsa`) -- це ключ. Його **НІКОЛИ** не показуй нікому.

```
[Твій комп'ютер] ---id_rsa---> [Шифрування] ----> [Сервер: перевіряє id_rsa.pub]
     (приватний)                                         (публічний)
```

### Перевірка

```bash
$ cat id_rsa.pub
ssh-rsa AAAAB3NzaC1yc... user@hostname
```

Публічний ключ повинен починатися з `ssh-rsa` (або `ssh-ed25519` якщо обрав інший тип).

## Підказки

<details>
<summary>Підказка 1: Генерація ключа</summary>

```bash
ssh-keygen -t rsa
```

Тебе запитають:
1. **Шлях**: натисни Enter для дефолтного (`~/.ssh/id_rsa`)
2. **Passphrase**: натисни Enter (без паролю) або введи пароль для безпеки
3. **Підтвердження**: Enter

Після цього файли будуть у `~/.ssh/`:
- `~/.ssh/id_rsa` -- приватний ключ
- `~/.ssh/id_rsa.pub` -- публічний ключ

</details>

<details>
<summary>Підказка 2: Копіювання для здачі</summary>

```bash
cp ~/.ssh/id_rsa.pub .
```

Перевір, що копіюєш саме `.pub` файл, а не приватний ключ.

</details>

<details>
<summary>Підказка 3: Перевірка формату</summary>

```bash
# Перевірити тип ключа
ssh-keygen -l -f id_rsa.pub

# Має вивести щось на кшталт:
# 3072 SHA256:... user@hostname (RSA)
```

Якщо у тебе вже є SSH-ключ, генерувати новий необов'язково -- можна скопіювати існуючий `id_rsa.pub`.

</details>

## Man сторінки

- `man ssh-keygen`
- `man ssh`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| ключ | cle | "Generer une paire de cles SSH" |
| безпека | securite | "La securite de ton compte" |
| публічний | public / publique | "La cle publique" |
| приватний | prive / privee | "Ne partage jamais ta cle privee!" |

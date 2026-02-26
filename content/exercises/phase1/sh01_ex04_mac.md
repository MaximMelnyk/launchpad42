---
id: sh01_ex04_mac
module: shell01
phase: phase1
title: "MAC"
difficulty: 2
xp: 25
estimated_minutes: 25
prerequisites: ["sh01_ex03_count_files"]
tags: ["shell", "scripting", "network", "ifconfig", "ip", "awk", "grep"]
norminette: false
man_pages: ["ifconfig", "ip", "awk", "grep"]
multi_day: false
order: 14
---

# MAC

## Завдання

Напиши командний рядок, який виводить MAC-адреси всіх мережевих інтерфейсів.

MAC-адреса (Media Access Control) -- це унікальний ідентифікатор мережевого адаптера. Ця вправа вчить тебе парсити вивід системних команд за допомогою `awk` або `grep`.

### Файли для здачі

- Директорія: `ex04/`
- Файл: `MAC.sh`

### Вимоги

- Скрипт має починатися з `#!/bin/sh`
- Виводити тільки MAC-адреси (по одній на рядок)
- Формат MAC-адреси: `XX:XX:XX:XX:XX:XX` (або `xx:xx:xx:xx:xx:xx`)
- Працює на Linux (WSL2)

### Приклад

```bash
$ bash MAC.sh
00:15:5d:a1:b2:c3
02:42:ac:11:00:02
```

### Очікуваний формат виводу

```
mac_address_1
mac_address_2
```

По одній адресі на рядок.

### Примітка для WSL2

На реальній Piscine використовується Linux і команда `ifconfig`. У WSL2 Ubuntu `ifconfig` може бути не встановлений. Є два варіанти:

```bash
# Варіант 1: ifconfig (може потребувати: sudo apt install net-tools)
ifconfig | grep -oE '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}'

# Варіант 2: ip link (доступний у будь-якому Linux)
ip link | grep -oE '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}'
```

Для Piscine готуй рішення з `ifconfig`. Для тренування на WSL2 можеш використовувати `ip link`.

## Підказки

<details>
<summary>Підказка 1</summary>

Команда `ifconfig` (або `ifconfig -a`) виводить інформацію про всі мережеві інтерфейси. Рядки з MAC-адресою містять слово `ether`:

```
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.20.0.1  netmask 255.255.240.0  broadcast 172.20.15.255
        ether 00:15:5d:a1:b2:c3  txqueuelen 1000  (Ethernet)
```

Використай `awk` або `grep` щоб витягти тільки адресу.

</details>

<details>
<summary>Підказка 2</summary>

З `awk`:

```bash
ifconfig -a | awk '/ether/{print $2}'
```

Це знаходить рядки, що містять `ether`, і виводить друге поле (саму MAC-адресу).

Або з `grep`:

```bash
ifconfig -a | grep ether | awk '{print $2}'
```

</details>

## Man сторінки

- `man ifconfig`
- `man ip`
- `man awk`
- `man grep`

## Французькі терміни

| Термін | Французькою | Приклад |
|--------|------------|---------|
| мережевий інтерфейс | interface reseau | "Lister les interfaces reseau" |
| адреса | adresse | "L'adresse MAC de l'interface" |
| фільтрувати | filtrer | "Filtrer la sortie avec grep ou awk" |
| поле | champ | "Le deuxieme champ contient l'adresse MAC" |

<div align="center">

# 🚀 42 LaunchPad

**A gamified self-study platform for 42 School Piscine preparation**

[![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178C6?logo=typescript&logoColor=white)](https://typescriptlang.org)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Cloud Run](https://img.shields.io/badge/Cloud%20Run-Serverless-4285F4?logo=googlecloud&logoColor=white)](https://cloud.google.com/run)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[Live Demo](https://launchpad42-prod.web.app) · [Report Bug](https://github.com/MaximMelnyk/launchpad42/issues) · [Request Feature](https://github.com/MaximMelnyk/launchpad42/issues)

</div>

---

## About

42 LaunchPad is a personal training platform built to prepare for the [42 School](https://42.fr) Piscine — an intensive 26-day C programming bootcamp. The platform provides a structured 125-day curriculum with gamification, spaced repetition, and real-time progress monitoring.

### The Problem

The 42 Piscine has no prerequisites, no teachers, and no textbooks. Students face Shell scripting, C programming (C00–C13), and timed exams — all in a Linux terminal with only `vim`, `gcc`, and `man` pages. Without preparation, the failure rate is significant.

### The Solution

42 LaunchPad creates a structured, gamified path from zero to Piscine-ready:

- **191 exercises** mapped to the real Piscine curriculum (Shell00/01, C00–C13)
- **191 automated test scripts** with hash-based verification
- **Exam simulations** matching the real format (3×4h + 1×8h)
- **Gamification** (XP, levels, streaks, achievements) to maintain motivation over 4+ months
- **Telegram bot** for parent monitoring — pull-based, non-intrusive
- **Spaced repetition** for C functions and French tech vocabulary

<div align="center">
<br>

| Dashboard | Exercise View |
|:---------:|:------------:|
| XP tracking, daily sessions, weekly progress | Markdown exercises with hints & test scripts |

</div>

## Features

### 📚 Curriculum (125 days, 5 phases)

| Phase | Days | Content | Exercises |
|-------|------|---------|-----------|
| **Phase 0** | 1–13 | Reactivation: `write()`, loops, basics | 25 |
| **Phase 1** | 11–30 | Shell & Tools: Shell00/01, Git, Makefile | 31 |
| **Phase 2** | 31–70 | C Core: C00–C09, Rush00/01 | 76 |
| **Phase 3** | 71–105 | Advanced: C10–C13, BSQ, Rush02 | — |
| **Phase 4** | 106–118 | Exam Training: timed simulations | 59 |
| **Phase 5** | 119–125 | Hardening & Confidence | — |

### 🎮 Gamification System

- **6 levels**: Init → Shell → Core → Memory → Exam → Launch → Ready
- **XP system**: 15–80 XP per exercise + bonuses (first attempt, no hints, streak)
- **Streak tracking**: daily completion with shield protection (1 per 7 days, max 3)
- **8 achievements**: Speed Demon, Night Owl, Marathon Runner, and more
- **Gate exams**: level-up challenges with cooldown and partial credit

### 🤖 Telegram Bot (`@LaunchPad42Bot`)

**Student commands:**
- `/today` — today's exercises and progress
- `/progress` — overall stats
- `/drill` — random function practice
- `/hint` — contextual help
- `/mood` — daily check-in

**Parent commands (pull-based monitoring):**
- `/today` — did they study today? (yes/no only)
- `/week` — weekly summary with exercises, XP, streak
- `/streak` — current streak info
- `/level` — current level and phase

Weekly auto-report every Sunday at 19:00 with Saturday preview for the student.

### 🔒 Norminette-Compliant Exercises

All C exercises follow [42's Norminette v3](https://github.com/42School/norminette) rules:
- No `for`, `switch`, `do-while`, `goto`, ternary operators
- Only `while` loops, `/* */` comments
- Max 25 lines per function, 4 arguments max
- All output via `write()` — no `printf`/`scanf`

## Architecture

```
Student → Firebase Hosting (React SPA + PWA)
                  ↓ REST API
            Cloud Run (Python/FastAPI)
                  ↓
            Firestore (flattened schema)
                  ↓
Parent → Telegram Bot (webhook on Cloud Run)
                  ↓
          Cloud Scheduler → Weekly reports
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | React 18, Vite, TypeScript (strict), TanStack Query, PWA |
| **Backend** | Python 3.12, FastAPI, Pydantic v2, structlog |
| **Database** | Cloud Firestore (flattened, no subcollections) |
| **Auth** | Firebase Auth (Google provider) |
| **Bot** | python-telegram-bot, webhook mode |
| **Hosting** | Firebase Hosting (SPA), Cloud Run (API, min 0 / max 1) |
| **CRON** | Cloud Scheduler (weekly reports) |
| **Content** | Markdown + YAML frontmatter, Bash test scripts |

## Getting Started

### Prerequisites

- Python 3.12+
- Node.js 18+
- Google Cloud SDK (`gcloud`)
- Firebase CLI (`firebase-tools`)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/MaximMelnyk/launchpad42.git
   cd launchpad42
   ```

2. **Backend setup**
   ```bash
   cd backend
   pip install -e ".[dev]"
   cp .env.example .env  # Configure Firebase credentials
   ```

3. **Frontend setup**
   ```bash
   cd frontend
   npm install
   ```

4. **Run locally**
   ```bash
   # Backend
   cd backend && uvicorn app.main:app --reload --port 8000

   # Frontend (separate terminal)
   cd frontend && npm run dev
   ```

5. **Seed content to Firestore**
   ```bash
   gcloud auth application-default login
   python scripts/seed.py --phase phase0 --collection exercises
   ```

### Running Tests

```bash
cd backend
pytest tests/ -v  # 173 tests
```

## Content Format

Exercises use Markdown with YAML frontmatter:

```yaml
---
id: c00_ex00_ft_putchar
module: c00
phase: phase2
title: "ft_putchar"
difficulty: 1
xp: 20
estimated_minutes: 15
prerequisites: []
tags: ["c", "write", "basics"]
norminette: true
---
# ft_putchar
## Task
Write a function that displays a single character...

## Hints
<details><summary>Hint 1</summary>Use write(1, &c, 1)</details>
```

Each exercise has a companion test script (`content/tests/test_*.sh`) that validates the solution with hash verification.

## Roadmap

- [x] Platform foundation (auth, API, database)
- [x] Gamification engine (XP, levels, streaks, achievements)
- [x] Telegram bot with parent monitoring
- [x] Phase 0–2 content (132 exercises)
- [x] Exam Bank — Phase 4 (59 exercises)
- [x] Production deployment (Cloud Run + Firebase Hosting)
- [ ] Phase 3 content (C10–C13, BSQ)
- [ ] Phase 5 content (hardening)
- [ ] PWA offline mode for exercises
- [ ] AI tutor integration (Socratic method)
- [ ] Examshell simulator (terminal-based)

## Cost

The entire platform runs on Google Cloud free tier:

| Service | Free Tier | Our Usage |
|---------|-----------|-----------|
| Cloud Run | 2M requests/month | ~1K/month |
| Firestore | 50K reads/day | ~100/day |
| Firebase Hosting | 10 GB/month | ~50 MB |
| Firebase Auth | 50K MAU | 1 user |
| Cloud Scheduler | 3 free jobs | 1 job |

**Total: $0/month**

## Contributing

This is a personal project built for a specific student, but the exercise content and platform architecture may be useful for others preparing for 42 Piscine. Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

## Acknowledgments

- [42 School](https://42.fr) — for the peer-to-peer education model
- [42 Norminette](https://github.com/42School/norminette) — C coding standard
- [Claude Code](https://claude.ai/claude-code) — AI-assisted development

---

<div align="center">

**Built with ❤️ for 42 Paris Piscine preparation**

If this project helps you prepare for 42, please consider giving it a ⭐

</div>

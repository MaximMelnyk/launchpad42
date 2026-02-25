/* Shared type definitions mirroring backend Pydantic models (camelCase). */

// --- User ---

export interface UserProfile {
  uid: string;
  displayName: string;
  email: string;
  level: number;
  xp: number;
  phase: string;
  currentDay: number;
  streakDays: number;
  shields: number;
  weeklyCompletedDays: string[];
  pauseMode: boolean;
  pauseStartedAt: string | null;
  telegramChatId: number | null;
  moodToday: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface UserProfileUpdate {
  displayName?: string | null;
  moodToday?: string | null;
  pauseMode?: boolean | null;
}

// --- Exercise ---

export type ExerciseStatus =
  | "locked"
  | "available"
  | "in_progress"
  | "completed"
  | "skipped";

export interface Exercise {
  id: string;
  module: string;
  phase: string;
  title: string;
  difficulty: number;
  xp: number;
  estimatedMinutes: number;
  prerequisites: string[];
  tags: string[];
  norminette: boolean;
  manPages: string[];
  multiDay: boolean;
  contentMd: string;
  order: number;
}

export interface ExerciseProgress {
  uid: string;
  exerciseId: string;
  status: ExerciseStatus;
  attempts: number;
  hintsUsed: number;
  xpEarned: number;
  hashCode: string | null;
  firstAttemptPass: boolean;
  startedAt: string | null;
  completedAt: string | null;
  updatedAt: string;
}

export interface ExerciseSubmission {
  hashCode: string;
  hintsUsed?: number;
}

// --- Session ---

export interface Session {
  uid: string;
  date: string;
  moodStart: string | null;
  moodEnd: string | null;
  exercisesCompleted: string[];
  xpEarned: number;
  drillCompleted: boolean;
  reviewCompleted: boolean;
  vocabCompleted: boolean;
  durationMinutes: number;
  startedAt: string | null;
  finishedAt: string | null;
  createdAt: string;
}

export interface SessionStart {
  mood: string;
}

export interface SessionEnd {
  mood: string;
  durationMinutes?: number;
}

// --- Gamification ---

export const LEVEL_NAMES: Record<number, string> = {
  0: "Init",
  1: "Shell",
  2: "Core",
  3: "Memory",
  4: "Exam",
  5: "Launch",
  6: "Ready",
};

export const LEVEL_XP_THRESHOLDS: Record<number, number> = {
  0: 0,
  1: 200,
  2: 600,
  3: 1400,
  4: 2600,
  5: 4000,
  6: 5500,
};

export type AchievementId =
  | "first_blood"
  | "week_warrior"
  | "streak_master"
  | "norminette_clean"
  | "exam_survivor"
  | "memory_master"
  | "speed_demon"
  | "launch_ready";

export interface Achievement {
  uid: string;
  achievementId: AchievementId;
  unlocked: boolean;
  unlockedAt: string | null;
  progress: number;
  target: number;
}

export const ACHIEVEMENT_NAMES_UK: Record<AchievementId, string> = {
  first_blood: "\u041F\u0435\u0440\u0448\u0438\u0439 \u043A\u0440\u043E\u043A",
  week_warrior:
    "\u0422\u0438\u0436\u043D\u0435\u0432\u0438\u0439 \u0432\u043E\u0457\u043D",
  streak_master:
    "\u041C\u0430\u0439\u0441\u0442\u0435\u0440 \u0441\u0435\u0440\u0456\u0439",
  norminette_clean:
    "\u0427\u0438\u0441\u0442\u0438\u0439 \u043A\u043E\u0434",
  exam_survivor:
    "\u0412\u0438\u0436\u0438\u0432 \u043D\u0430 \u0435\u043A\u0437\u0430\u043C\u0435\u043D\u0456",
  memory_master:
    "\u0412\u043E\u043B\u043E\u0434\u0430\u0440 \u043F\u0430\u043C'\u044F\u0442\u0456",
  speed_demon:
    "\u0411\u043B\u0438\u0441\u043A\u0430\u0432\u043A\u0430",
  launch_ready:
    "\u0413\u043E\u0442\u043E\u0432\u0438\u0439 \u0434\u043E \u0441\u0442\u0430\u0440\u0442\u0443",
};

export interface DrillPool {
  uid: string;
  functionQueue: string[];
  lastDrilled: Record<string, string>;
  updatedAt: string;
}

export interface ReviewCard {
  id: string;
  category: string;
  front: string;
  back: string;
  phase: string;
  intervalDays: number;
  easeFactor: number;
  nextReview: string | null;
  reviewCount: number;
  correctCount: number;
}

export interface Vocab {
  id: string;
  termFr: string;
  termUk: string;
  termEn: string;
  context: string;
  phase: string;
  intervalDays: number;
  nextReview: string | null;
  reviewCount: number;
  correctCount: number;
}

// --- Exam ---

export type ExamType = "gate" | "final";
export type ExamStatus = "in_progress" | "passed" | "failed" | "partial";

export interface Exam {
  uid: string;
  examId: string;
  examType: ExamType;
  level: number;
  exercises: string[];
  completedExercises: string[];
  score: number;
  status: ExamStatus;
  timeLimitMinutes: number;
  startedAt: string | null;
  finishedAt: string | null;
  attemptNumber: number;
}

// --- Telegram ---

export type TelegramRole = "student" | "mother";

export interface TelegramLink {
  chatId: number;
  role: TelegramRole;
  displayName: string;
  linkedAt: string;
}

// --- Tutor ---

export interface TutorRequest {
  message: string;
  exerciseId?: string | null;
  code?: string | null;
}

export interface TutorResponse {
  reply: string;
  tokensUsed?: number | null;
}

// --- API Response wrappers ---

export interface ApiResponse<T> {
  data: T;
  message?: string;
}

export interface DashboardData {
  user: UserProfile;
  todaySession: Session | null;
  todayExercises: Exercise[];
  recentAchievements: Achievement[];
  streakInfo: {
    current: number;
    shields: number;
    weeklyProgress: number;
  };
}

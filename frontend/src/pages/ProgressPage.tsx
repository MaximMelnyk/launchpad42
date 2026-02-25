/**
 * Progress page — detailed stats, achievements, exercise grid by phase.
 */

import { useQuery } from '@tanstack/react-query';
import { useUser } from '@/hooks/useUser';
import { getAchievements } from '@/services/gamificationService';
import { LEVEL_NAMES, LEVEL_XP_THRESHOLDS } from '@/types';
import type { Achievement } from '@/types';
import Layout from '@/components/Layout';
import XpBar from '@/components/XpBar';
import LevelBadge from '@/components/LevelBadge';
import AchievementBadge from '@/components/AchievementBadge';
import styles from './ProgressPage.module.css';

const PHASES = [
  { id: 'phase0', name: 'Фаза 0: Реактивація', days: '1-13' },
  { id: 'phase1', name: 'Фаза 1: Shell & Tools', days: '11-30' },
  { id: 'phase2', name: 'Фаза 2: C Core', days: '31-70' },
  { id: 'phase3', name: 'Фаза 3: Memory + Advanced', days: '71-105' },
  { id: 'phase4', name: 'Фаза 4: Exam Training', days: '106-118' },
  { id: 'phase5', name: 'Фаза 5: Hardening', days: '119-125' },
];

export default function ProgressPage(): JSX.Element {
  const { data: user, isLoading: userLoading } = useUser();
  const { data: achievements, isLoading: achievementsLoading } = useQuery<Achievement[]>({
    queryKey: ['achievements'],
    queryFn: getAchievements,
  });

  if (userLoading) {
    return (
      <Layout>
        <div className="loading-screen">Завантаження...</div>
      </Layout>
    );
  }

  if (!user) {
    return (
      <Layout>
        <div className={styles.error}>Не вдалося завантажити профіль</div>
      </Layout>
    );
  }

  const currentThreshold = LEVEL_XP_THRESHOLDS[user.level] ?? 0;
  const nextThreshold = LEVEL_XP_THRESHOLDS[user.level + 1] ?? currentThreshold;
  const xpInLevel = user.xp - currentThreshold;
  const xpNeeded = nextThreshold - currentThreshold;

  const unlockedAchievements = (achievements ?? []).filter((a) => a.unlocked);
  const lockedAchievements = (achievements ?? []).filter((a) => !a.unlocked);

  return (
    <Layout>
      <div className={styles.page}>
        <h1 className={styles.heading}>Прогрес</h1>

        {/* Stats overview */}
        <div className={styles.statsGrid}>
          <div className={styles.statCard}>
            <span className={styles.statLabel}>Рівень</span>
            <div className={styles.statValue}>
              <LevelBadge level={user.level} size="md" />
            </div>
          </div>
          <div className={styles.statCard}>
            <span className={styles.statLabel}>Загальний XP</span>
            <span className={styles.statNumber}>{user.xp}</span>
          </div>
          <div className={styles.statCard}>
            <span className={styles.statLabel}>Серія днів</span>
            <span className={styles.statNumber}>{user.streakDays}</span>
          </div>
          <div className={styles.statCard}>
            <span className={styles.statLabel}>Щити</span>
            <span className={styles.statNumber}>{user.shields}/3</span>
          </div>
          <div className={styles.statCard}>
            <span className={styles.statLabel}>День</span>
            <span className={styles.statNumber}>{user.currentDay}</span>
          </div>
          <div className={styles.statCard}>
            <span className={styles.statLabel}>Досягнення</span>
            <span className={styles.statNumber}>
              {unlockedAchievements.length}/{(achievements ?? []).length}
            </span>
          </div>
        </div>

        {/* XP to next level */}
        <div className={styles.xpSection}>
          <XpBar current={xpInLevel} max={xpNeeded} level={user.level} />
        </div>

        {/* Level progression timeline */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Рівні</h2>
          <div className={styles.timeline}>
            {Object.entries(LEVEL_NAMES).map(([lvl, name]) => {
              const levelNum = parseInt(lvl, 10);
              const isCurrent = levelNum === user.level;
              const isPast = levelNum < user.level;
              return (
                <div
                  key={lvl}
                  className={`${styles.timelineItem} ${isCurrent ? styles.timelineCurrent : ''} ${isPast ? styles.timelinePast : ''}`}
                >
                  <LevelBadge level={levelNum} size="sm" />
                  <span className={styles.timelineName}>{name}</span>
                  {isCurrent && (
                    <span className={styles.currentLabel}>Зараз</span>
                  )}
                </div>
              );
            })}
          </div>
        </section>

        {/* Phase progress */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Фази навчання</h2>
          <div className={styles.phaseList}>
            {PHASES.map((p) => {
              const isCurrent = user.phase === p.id;
              const phaseNum = parseInt(p.id.replace('phase', ''), 10);
              const userPhaseNum = parseInt(user.phase.replace('phase', '') || '0', 10);
              const isPast = phaseNum < userPhaseNum;
              return (
                <div
                  key={p.id}
                  className={`${styles.phaseItem} ${isCurrent ? styles.phaseCurrent : ''} ${isPast ? styles.phasePast : ''}`}
                >
                  <span className={styles.phaseIndicator}>
                    {isPast ? '\u2705' : isCurrent ? '\u25B6\uFE0F' : '\u2B1C'}
                  </span>
                  <div className={styles.phaseInfo}>
                    <span className={styles.phaseName}>{p.name}</span>
                    <span className={styles.phaseDays}>Дні {p.days}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        {/* Weekly completion */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Тижневі завершення</h2>
          <div className={styles.weeklyGrid}>
            {['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'].map((day, i) => {
              const dateStr = user.weeklyCompletedDays[i];
              const isComplete = !!dateStr;
              return (
                <div
                  key={day}
                  className={`${styles.weekDay} ${isComplete ? styles.weekDayComplete : ''}`}
                >
                  <span className={styles.weekDayLabel}>{day}</span>
                  <span className={styles.weekDayIcon}>
                    {isComplete ? '\u2705' : '\u2B1C'}
                  </span>
                </div>
              );
            })}
          </div>
        </section>

        {/* Achievements */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Досягнення</h2>
          {achievementsLoading && (
            <p className={styles.loading}>Завантаження досягнень...</p>
          )}

          {unlockedAchievements.length > 0 && (
            <div className={styles.achievementGroup}>
              <h3 className={styles.groupTitle}>Розблоковано</h3>
              <div className={styles.achievementGrid}>
                {unlockedAchievements.map((a) => (
                  <AchievementBadge key={a.achievementId} achievement={a} />
                ))}
              </div>
            </div>
          )}

          {lockedAchievements.length > 0 && (
            <div className={styles.achievementGroup}>
              <h3 className={styles.groupTitle}>Заблоковано</h3>
              <div className={styles.achievementGrid}>
                {lockedAchievements.map((a) => (
                  <AchievementBadge key={a.achievementId} achievement={a} />
                ))}
              </div>
            </div>
          )}
        </section>
      </div>
    </Layout>
  );
}

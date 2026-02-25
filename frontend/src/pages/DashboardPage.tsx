/**
 * Dashboard page — main hub with XP, streak, today's exercises, achievements.
 */

import { useNavigate } from 'react-router-dom';
import { useUser } from '@/hooks/useUser';
import { useTodayExercises } from '@/hooks/useExercises';
import { useCurrentSession } from '@/hooks/useSession';
import { useQuery } from '@tanstack/react-query';
import { getAchievements } from '@/services/gamificationService';
import { LEVEL_XP_THRESHOLDS } from '@/types';
import type { Achievement } from '@/types';
import Layout from '@/components/Layout';
import XpBar from '@/components/XpBar';
import LevelBadge from '@/components/LevelBadge';
import StreakCounter from '@/components/StreakCounter';
import ExerciseCard from '@/components/ExerciseCard';
import AchievementBadge from '@/components/AchievementBadge';
import styles from './DashboardPage.module.css';

export default function DashboardPage(): JSX.Element {
  const navigate = useNavigate();
  const { data: user, isLoading: userLoading } = useUser();
  const { data: todayData, isLoading: exercisesLoading } = useTodayExercises();
  const exercises = todayData?.exercises;
  const { data: session } = useCurrentSession();
  const { data: achievements } = useQuery<Achievement[]>({
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

  const recentAchievements = (achievements ?? [])
    .filter((a) => a.unlocked)
    .slice(0, 3);

  return (
    <Layout>
      <div className={styles.page}>
        {/* Phase indicator */}
        <div className={styles.phaseBar}>
          <span className={styles.phaseText}>
            Фаза {user.phase}, день {user.currentDay}
          </span>
          {!user.pauseMode && (
            <span className={styles.phaseReady}>
              Готовий до наступного дня завтра
            </span>
          )}
          {user.pauseMode && (
            <span className={styles.phasePause}>Пауза активна</span>
          )}
        </div>

        {/* Stats row */}
        <div className={styles.statsRow}>
          <div className={styles.levelSection}>
            <LevelBadge level={user.level} size="lg" />
          </div>
          <div className={styles.xpSection}>
            <XpBar current={xpInLevel} max={xpNeeded} level={user.level} />
          </div>
          <div className={styles.streakSection}>
            <StreakCounter
              streak={user.streakDays}
              shields={user.shields}
              weeklyProgress={user.weeklyCompletedDays.length}
            />
          </div>
        </div>

        {/* Quick actions */}
        <div className={styles.actions}>
          {!session && (
            <button
              className="btn btn-primary"
              onClick={() => navigate('/session')}
              type="button"
            >
              Почати сесію
            </button>
          )}
          {session && !session.finishedAt && (
            <button
              className="btn btn-primary"
              onClick={() => navigate('/session')}
              type="button"
            >
              Продовжити сесію
            </button>
          )}
          <button
            className="btn btn-secondary"
            onClick={() => navigate('/progress')}
            type="button"
          >
            Детальний прогрес
          </button>
          <button
            className="btn btn-secondary"
            onClick={() => navigate('/exam')}
            type="button"
          >
            Екзамен
          </button>
        </div>

        {/* Today's exercises */}
        <section className={styles.section}>
          <h2 className={styles.sectionTitle}>Сьогоднішні вправи</h2>
          {exercisesLoading && (
            <p className={styles.loading}>Завантаження вправ...</p>
          )}
          {!exercisesLoading && exercises && exercises.length === 0 && (
            <p className={styles.empty}>На сьогодні вправ немає. Розпочніть сесію!</p>
          )}
          {exercises && exercises.length > 0 && (
            <div className={styles.exerciseGrid}>
              {exercises.map((ex) => (
                <ExerciseCard
                  key={ex.id}
                  exercise={ex}
                  status="available"
                  onClick={() => navigate(`/exercise/${ex.id}`)}
                />
              ))}
            </div>
          )}
        </section>

        {/* Recent achievements */}
        {recentAchievements.length > 0 && (
          <section className={styles.section}>
            <h2 className={styles.sectionTitle}>Останні досягнення</h2>
            <div className={styles.achievementGrid}>
              {recentAchievements.map((a) => (
                <AchievementBadge key={a.achievementId} achievement={a} />
              ))}
            </div>
          </section>
        )}
      </div>
    </Layout>
  );
}

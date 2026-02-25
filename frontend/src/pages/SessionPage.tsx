/**
 * Session page — daily session flow: mood check-in, exercises, wrap-up.
 */

import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCurrentSession, useStartSession, useEndSession } from '@/hooks/useSession';
import { useTodayExercises } from '@/hooks/useExercises';
import Layout from '@/components/Layout';
import MoodSelector from '@/components/MoodSelector';
import Timer from '@/components/Timer';
import ExerciseCard from '@/components/ExerciseCard';
import styles from './SessionPage.module.css';

type UiPhase = 'start' | 'active' | 'ending' | 'summary';

export default function SessionPage(): JSX.Element {
  const navigate = useNavigate();
  const { data: session, isLoading: sessionLoading } = useCurrentSession();
  const { data: todayData, isLoading: exercisesLoading } = useTodayExercises();
  const exercises = todayData?.exercises;
  const startMutation = useStartSession();
  const endMutation = useEndSession();

  const [startMood, setStartMood] = useState<string>('');
  const [endMood, setEndMood] = useState<string>('');
  const [uiPhase, setUiPhase] = useState<UiPhase>('start');

  // Sync UI phase with server state on load
  useEffect(() => {
    if (sessionLoading) return;
    if (session && !session.finishedAt) {
      setUiPhase('active');
    } else if (session && session.finishedAt) {
      setUiPhase('summary');
    } else {
      setUiPhase('start');
    }
  }, [session, sessionLoading]);

  const handleStartSession = (): void => {
    if (!startMood) return;
    startMutation.mutate(startMood, {
      onSuccess: () => {
        setUiPhase('active');
      },
    });
  };

  const handleEndSession = (): void => {
    if (!endMood) return;
    endMutation.mutate(
      { mood: endMood },
      {
        onSuccess: () => {
          setUiPhase('summary');
        },
      }
    );
  };

  if (sessionLoading) {
    return (
      <Layout>
        <div className="loading-screen">Завантаження сесії...</div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className={styles.page}>
        {/* Phase: Mood Start */}
        {uiPhase === 'start' && (
          <div className={styles.moodPhase}>
            <h1 className={styles.heading}>Нова сесія</h1>
            <p className={styles.subtitle}>
              Перш ніж почати, як ти себе почуваєш?
            </p>
            <MoodSelector onSelect={setStartMood} selected={startMood} />

            {startMutation.isError && (
              <div className={styles.error}>
                {startMutation.error.message}
              </div>
            )}

            <button
              className="btn btn-primary"
              onClick={handleStartSession}
              disabled={!startMood || startMutation.isPending}
              type="button"
            >
              {startMutation.isPending ? 'Старт...' : 'Почати сесію'}
            </button>
          </div>
        )}

        {/* Phase: Active session */}
        {uiPhase === 'active' && session && (
          <div className={styles.activePhase}>
            <div className={styles.sessionHeader}>
              <h1 className={styles.heading}>Активна сесія</h1>
              {session.startedAt && (
                <Timer startedAt={session.startedAt} limitMinutes={120} />
              )}
            </div>

            {/* Session checklist */}
            <div className={styles.checklist}>
              <div className={`${styles.checkItem} ${session.vocabCompleted ? styles.done : ''}`}>
                <span className={styles.checkIcon}>
                  {session.vocabCompleted ? '\u2705' : '\u2B1C'}
                </span>
                <span>Vocab Drill (5 хв)</span>
              </div>
              <div className={`${styles.checkItem} ${session.drillCompleted ? styles.done : ''}`}>
                <span className={styles.checkIcon}>
                  {session.drillCompleted ? '\u2705' : '\u2B1C'}
                </span>
                <span>Function Drill (5 хв)</span>
              </div>
              <div className={`${styles.checkItem} ${session.reviewCompleted ? styles.done : ''}`}>
                <span className={styles.checkIcon}>
                  {session.reviewCompleted ? '\u2705' : '\u2B1C'}
                </span>
                <span>Review (9 хв)</span>
              </div>
            </div>

            {/* Exercises */}
            <section className={styles.exerciseSection}>
              <h2 className={styles.sectionTitle}>Вправи</h2>
              {exercisesLoading && (
                <p className={styles.loading}>Завантаження вправ...</p>
              )}
              {!exercisesLoading && exercises && exercises.length > 0 ? (
                <div className={styles.exerciseList}>
                  {exercises.map((ex) => {
                    const isCompleted = session.exercisesCompleted.includes(ex.id);
                    return (
                      <ExerciseCard
                        key={ex.id}
                        exercise={ex}
                        status={isCompleted ? 'completed' : 'available'}
                        onClick={() => navigate(`/exercise/${ex.id}`)}
                      />
                    );
                  })}
                </div>
              ) : (
                !exercisesLoading && (
                  <p className={styles.empty}>Немає вправ на сьогодні</p>
                )
              )}
            </section>

            {/* Session stats */}
            <div className={styles.sessionStats}>
              <span className={styles.statItem}>
                XP за сесію: <strong>{session.xpEarned}</strong>
              </span>
              <span className={styles.statItem}>
                Завершено вправ: <strong>{session.exercisesCompleted.length}</strong>
              </span>
            </div>

            {/* End session — transitions to ending UI phase */}
            <button
              className="btn btn-secondary"
              onClick={() => setUiPhase('ending')}
              type="button"
            >
              Завершити сесію
            </button>
          </div>
        )}

        {/* Phase: Mood End */}
        {uiPhase === 'ending' && (
          <div className={styles.moodPhase}>
            <h1 className={styles.heading}>Завершення сесії</h1>
            <p className={styles.subtitle}>
              Як ти почуваєшся після сесії?
            </p>
            <MoodSelector onSelect={setEndMood} selected={endMood} />

            {endMutation.isError && (
              <div className={styles.error}>
                {endMutation.error.message}
              </div>
            )}

            <div className={styles.endActions}>
              <button
                className="btn btn-secondary"
                onClick={() => setUiPhase('active')}
                type="button"
              >
                Назад
              </button>
              <button
                className="btn btn-primary"
                onClick={handleEndSession}
                disabled={!endMood || endMutation.isPending}
                type="button"
              >
                {endMutation.isPending ? 'Завершення...' : 'Завершити'}
              </button>
            </div>
          </div>
        )}

        {/* Phase: Summary */}
        {uiPhase === 'summary' && session && (
          <div className={styles.summary}>
            <h1 className={styles.heading}>Сесію завершено!</h1>

            <div className={styles.summaryCard}>
              <div className={styles.summaryItem}>
                <span className={styles.summaryLabel}>XP зароблено</span>
                <span className={styles.summaryValue}>{session.xpEarned}</span>
              </div>
              <div className={styles.summaryItem}>
                <span className={styles.summaryLabel}>Вправ завершено</span>
                <span className={styles.summaryValue}>
                  {session.exercisesCompleted.length}
                </span>
              </div>
              <div className={styles.summaryItem}>
                <span className={styles.summaryLabel}>Тривалість</span>
                <span className={styles.summaryValue}>
                  {session.durationMinutes} хв
                </span>
              </div>
            </div>

            <button
              className="btn btn-primary"
              onClick={() => navigate('/')}
              type="button"
            >
              На панель
            </button>
          </div>
        )}
      </div>
    </Layout>
  );
}

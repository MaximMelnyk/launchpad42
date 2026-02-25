/**
 * Exercise page — view exercise content, hints, and submit solution hash.
 */

import { useParams, useNavigate } from 'react-router-dom';
import { useExercise } from '@/hooks/useExercises';
import Layout from '@/components/Layout';
import MarkdownViewer from '@/components/MarkdownViewer';
import HashSubmitForm from '@/components/HashSubmitForm';
import styles from './ExercisePage.module.css';

export default function ExercisePage(): JSX.Element {
  const { exerciseId } = useParams<{ exerciseId: string }>();
  const navigate = useNavigate();

  const {
    data: detail,
    isLoading: exerciseLoading,
    error: exerciseError,
  } = useExercise(exerciseId ?? '');

  const exercise = detail?.exercise;
  const progress = detail?.progress ?? null;

  if (!exerciseId) {
    return (
      <Layout>
        <div className={styles.error}>ID вправи не вказано</div>
      </Layout>
    );
  }

  if (exerciseLoading) {
    return (
      <Layout>
        <div className="loading-screen">Завантаження вправи...</div>
      </Layout>
    );
  }

  if (exerciseError || !exercise) {
    return (
      <Layout>
        <div className={styles.error}>
          {exerciseError instanceof Error
            ? exerciseError.message
            : 'Не вдалося завантажити вправу'}
        </div>
      </Layout>
    );
  }

  const isCompleted = progress?.status === 'completed';

  return (
    <Layout>
      <div className={styles.page}>
        {/* Back navigation */}
        <button
          className={styles.backBtn}
          onClick={() => navigate(-1)}
          type="button"
        >
          {'\u2190'} Назад
        </button>

        {/* Exercise header */}
        <div className={styles.header}>
          <div className={styles.headerInfo}>
            <span className={styles.module}>{exercise.module.toUpperCase()}</span>
            <h1 className={styles.title}>{exercise.title}</h1>
          </div>
          <div className={styles.headerMeta}>
            <span className={styles.xp}>+{exercise.xp} XP</span>
            <span className={styles.time}>~{exercise.estimatedMinutes} хв</span>
            {exercise.norminette && (
              <span className={styles.norminette} title="Norminette required">
                Norminette
              </span>
            )}
          </div>
        </div>

        {/* Completion badge */}
        {isCompleted && (
          <div className={styles.completedBadge}>
            {'\u2705'} Вправу завершено! XP: {progress?.xpEarned ?? 0}
          </div>
        )}

        {/* Man pages */}
        {exercise.manPages.length > 0 && (
          <div className={styles.manPages}>
            <span className={styles.manLabel}>Man pages:</span>
            {exercise.manPages.map((mp) => (
              <code key={mp} className={styles.manItem}>
                man {mp}
              </code>
            ))}
          </div>
        )}

        {/* Exercise content */}
        <div className={styles.content}>
          <MarkdownViewer content={exercise.contentMd} />
        </div>

        {/* Prerequisites */}
        {exercise.prerequisites.length > 0 && (
          <div className={styles.prerequisites}>
            <h3 className={styles.prereqTitle}>Передумови</h3>
            <ul className={styles.prereqList}>
              {exercise.prerequisites.map((prereq) => (
                <li key={prereq}>{prereq}</li>
              ))}
            </ul>
          </div>
        )}

        {/* Submit form */}
        {!isCompleted && (
          <div className={styles.submitSection}>
            <HashSubmitForm exerciseId={exerciseId} />
          </div>
        )}

        {/* Progress info */}
        {progress && (
          <div className={styles.progressInfo}>
            <span>Спроб: {progress.attempts}</span>
            <span>Підказок: {progress.hintsUsed}</span>
            {progress.completedAt && (
              <span>
                Завершено:{' '}
                {new Date(progress.completedAt).toLocaleString('uk-UA')}
              </span>
            )}
          </div>
        )}
      </div>
    </Layout>
  );
}

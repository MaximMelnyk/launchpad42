/**
 * Exercise card — preview tile for exercise lists.
 */

import type { Exercise, ExerciseStatus } from '@/types';
import styles from './ExerciseCard.module.css';

interface ExerciseCardProps {
  exercise: Exercise;
  status?: ExerciseStatus;
  onClick?: () => void;
}

const STATUS_LABELS: Record<ExerciseStatus, string> = {
  locked: 'Заблоковано',
  available: 'Доступно',
  in_progress: 'В процесі',
  completed: 'Завершено',
  skipped: 'Пропущено',
};

function renderDifficulty(level: number): string {
  return '\u2605'.repeat(level) + '\u2606'.repeat(Math.max(0, 5 - level));
}

export default function ExerciseCard({
  exercise,
  status = 'available',
  onClick,
}: ExerciseCardProps): JSX.Element {
  const isClickable = status !== 'locked';

  return (
    <button
      className={`${styles.card} ${styles[status]}`}
      onClick={isClickable ? onClick : undefined}
      disabled={!isClickable}
      type="button"
    >
      <div className={styles.header}>
        <span className={styles.module}>{exercise.module.toUpperCase()}</span>
        <span className={styles.statusBadge}>
          {STATUS_LABELS[status]}
        </span>
      </div>

      <h3 className={styles.title}>{exercise.title}</h3>

      <div className={styles.meta}>
        <span className={styles.difficulty} title={`Складність: ${exercise.difficulty}/5`}>
          {renderDifficulty(exercise.difficulty)}
        </span>
        <span className={styles.xp}>+{exercise.xp} XP</span>
        <span className={styles.time}>~{exercise.estimatedMinutes} хв</span>
      </div>

      {exercise.tags.length > 0 && (
        <div className={styles.tags}>
          {exercise.tags.slice(0, 3).map((tag) => (
            <span key={tag} className={styles.tag}>
              {tag}
            </span>
          ))}
        </div>
      )}
    </button>
  );
}

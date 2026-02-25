/**
 * Streak counter — weekly progress (primary) and daily streak (secondary).
 */

import styles from './StreakCounter.module.css';

interface StreakCounterProps {
  streak: number;
  shields: number;
  weeklyProgress: number;
}

export default function StreakCounter({
  streak,
  shields,
  weeklyProgress,
}: StreakCounterProps): JSX.Element {
  const maxShields = 3;
  const weekDays = 7;

  return (
    <div className={styles.wrapper}>
      {/* Weekly progress - primary metric */}
      <div className={styles.weekly}>
        <span className={styles.weeklyLabel}>Тижневий прогрес</span>
        <div className={styles.weeklyDots}>
          {Array.from({ length: weekDays }, (_, i) => (
            <div
              key={i}
              className={`${styles.dot} ${i < weeklyProgress ? styles.dotFilled : ''}`}
            />
          ))}
        </div>
        <span className={styles.weeklyCount}>
          {weeklyProgress}/{weekDays}
        </span>
      </div>

      {/* Daily streak - secondary */}
      <div className={styles.streak}>
        <span className={styles.flame}>
          {streak > 0 ? '\uD83D\uDD25' : '\u26AA'}
        </span>
        <span className={styles.streakCount}>{streak}</span>
        <span className={styles.streakLabel}>
          {streak === 1 ? 'день' : 'днів'}
        </span>
      </div>

      {/* Shields */}
      <div className={styles.shields}>
        {Array.from({ length: maxShields }, (_, i) => (
          <span
            key={i}
            className={`${styles.shield} ${i < shields ? styles.shieldActive : ''}`}
            title={i < shields ? 'Щит активний' : 'Щит не активний'}
          >
            {'\uD83D\uDEE1\uFE0F'}
          </span>
        ))}
      </div>
    </div>
  );
}

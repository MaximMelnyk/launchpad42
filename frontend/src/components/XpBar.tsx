/**
 * XP progress bar — shows current XP relative to next level threshold.
 */

import styles from './XpBar.module.css';

interface XpBarProps {
  current: number;
  max: number;
  level: number;
}

export default function XpBar({ current, max, level }: XpBarProps): JSX.Element {
  const percentage = max > 0 ? Math.min((current / max) * 100, 100) : 0;

  return (
    <div className={styles.wrapper}>
      <div className={styles.label}>
        <span className={styles.xpText}>XP</span>
        <span className={styles.xpValues}>
          {current} / {max}
        </span>
        <span className={styles.levelText}>Рівень {level}</span>
      </div>
      <div className={styles.track}>
        <div
          className={styles.fill}
          style={{ width: `${percentage}%` }}
          role="progressbar"
          aria-valuenow={current}
          aria-valuemin={0}
          aria-valuemax={max}
        />
      </div>
    </div>
  );
}

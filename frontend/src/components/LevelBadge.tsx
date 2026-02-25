/**
 * Level badge — circular indicator with level number and name.
 */

import { LEVEL_NAMES } from '@/types';
import styles from './LevelBadge.module.css';

interface LevelBadgeProps {
  level: number;
  size?: 'sm' | 'md' | 'lg';
}

export default function LevelBadge({
  level,
  size = 'md',
}: LevelBadgeProps): JSX.Element {
  const levelName = LEVEL_NAMES[level] ?? 'Unknown';

  return (
    <div className={`${styles.badge} ${styles[size]}`} title={levelName}>
      <span
        className={styles.circle}
        style={{
          borderColor: `var(--color-level-${level})`,
          color: `var(--color-level-${level})`,
        }}
      >
        {level}
      </span>
      {size !== 'sm' && (
        <span className={styles.name}>{levelName}</span>
      )}
    </div>
  );
}

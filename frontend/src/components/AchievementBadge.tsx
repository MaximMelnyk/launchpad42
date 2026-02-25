/**
 * Achievement badge — shows achievement status with Ukrainian name.
 */

import type { Achievement } from '@/types';
import { ACHIEVEMENT_NAMES_UK } from '@/types';
import styles from './AchievementBadge.module.css';

interface AchievementBadgeProps {
  achievement: Achievement;
}

export default function AchievementBadge({
  achievement,
}: AchievementBadgeProps): JSX.Element {
  const name = ACHIEVEMENT_NAMES_UK[achievement.achievementId] ?? achievement.achievementId;
  const progressPercent =
    achievement.target > 0
      ? Math.min((achievement.progress / achievement.target) * 100, 100)
      : 0;

  return (
    <div
      className={`${styles.badge} ${achievement.unlocked ? styles.unlocked : styles.locked}`}
    >
      <div className={styles.icon}>
        {achievement.unlocked ? '\uD83C\uDFC6' : '\uD83D\uDD12'}
      </div>
      <div className={styles.info}>
        <span className={styles.name}>{name}</span>
        {!achievement.unlocked && achievement.target > 0 && (
          <div className={styles.progressWrapper}>
            <div className={styles.progressTrack}>
              <div
                className={styles.progressFill}
                style={{ width: `${progressPercent}%` }}
              />
            </div>
            <span className={styles.progressText}>
              {achievement.progress}/{achievement.target}
            </span>
          </div>
        )}
        {achievement.unlocked && achievement.unlockedAt && (
          <span className={styles.date}>
            {new Date(achievement.unlockedAt).toLocaleDateString('uk-UA')}
          </span>
        )}
      </div>
    </div>
  );
}

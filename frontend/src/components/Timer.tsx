/**
 * Timer component — countdown or elapsed time display.
 */

import { useState, useEffect, useCallback } from 'react';
import styles from './Timer.module.css';

interface TimerProps {
  startedAt: string;
  limitMinutes?: number;
  onExpire?: () => void;
}

function formatTime(totalSeconds: number): string {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  if (hours > 0) {
    return `${hours}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
}

export default function Timer({
  startedAt,
  limitMinutes,
  onExpire,
}: TimerProps): JSX.Element {
  const [now, setNow] = useState<number>(Date.now());

  useEffect(() => {
    const interval = setInterval(() => {
      setNow(Date.now());
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const startMs = new Date(startedAt).getTime();
  const elapsedSeconds = Math.max(0, Math.floor((now - startMs) / 1000));

  const handleExpire = useCallback(() => {
    if (onExpire) onExpire();
  }, [onExpire]);

  // Countdown mode
  if (limitMinutes !== undefined) {
    const limitSeconds = limitMinutes * 60;
    const remainingSeconds = Math.max(0, limitSeconds - elapsedSeconds);
    const percentage = limitSeconds > 0 ? (remainingSeconds / limitSeconds) * 100 : 0;
    const isWarning = percentage < 10;
    const isExpired = remainingSeconds <= 0;

    // Fire onExpire when timer reaches 0
    useEffect(() => {
      if (isExpired) {
        handleExpire();
      }
    }, [isExpired, handleExpire]);

    return (
      <div
        className={`${styles.timer} ${isWarning ? styles.warning : ''} ${isExpired ? styles.expired : ''}`}
      >
        <span className={styles.icon}>{'\u23F1\uFE0F'}</span>
        <span className={styles.time}>{formatTime(remainingSeconds)}</span>
        {isExpired && <span className={styles.expiredText}>Час вичерпано!</span>}
      </div>
    );
  }

  // Elapsed mode (no limit)
  return (
    <div className={styles.timer}>
      <span className={styles.icon}>{'\u23F1\uFE0F'}</span>
      <span className={styles.time}>{formatTime(elapsedSeconds)}</span>
    </div>
  );
}

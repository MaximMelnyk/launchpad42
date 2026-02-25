/**
 * Hash submit form — input for exercise solution hash code.
 */

import { useState } from 'react';
import { useSubmitExercise } from '@/hooks/useExercises';
import type { SubmitExerciseResponse } from '@/services/exerciseService';
import styles from './HashSubmitForm.module.css';

interface HashSubmitFormProps {
  exerciseId: string;
  onSuccess?: (result: SubmitExerciseResponse) => void;
}

const HASH_REGEX = /^[a-fA-F0-9]{8}$/;

export default function HashSubmitForm({
  exerciseId,
  onSuccess,
}: HashSubmitFormProps): JSX.Element {
  const [hashCode, setHashCode] = useState('');
  const [hintsUsed, setHintsUsed] = useState(0);
  const [showSuccess, setShowSuccess] = useState(false);
  const [xpEarned, setXpEarned] = useState(0);

  const submitMutation = useSubmitExercise();

  const isValidHash = HASH_REGEX.test(hashCode);

  const handleSubmit = (e: React.FormEvent): void => {
    e.preventDefault();
    if (!isValidHash) return;

    submitMutation.mutate(
      { id: exerciseId, data: { hashCode: hashCode.toLowerCase(), hintsUsed } },
      {
        onSuccess: (result) => {
          setXpEarned(result.xpEarned);
          setShowSuccess(true);
          setHashCode('');
          setHintsUsed(0);
          if (onSuccess) onSuccess(result);
        },
      }
    );
  };

  if (showSuccess) {
    return (
      <div className={styles.success}>
        <span className={styles.successIcon}>{'\u2705'}</span>
        <span className={styles.successText}>Вправу завершено!</span>
        <span className={styles.xpGain}>+{xpEarned} XP</span>
        <button
          type="button"
          className={styles.resetBtn}
          onClick={() => setShowSuccess(false)}
        >
          Здати ще раз
        </button>
      </div>
    );
  }

  return (
    <form className={styles.form} onSubmit={handleSubmit}>
      <h3 className={styles.title}>Здати розв'язок</h3>

      <div className={styles.field}>
        <label className={styles.label} htmlFor="hashCode">
          Хеш-код (8 символів, hex)
        </label>
        <input
          id="hashCode"
          type="text"
          className={styles.input}
          value={hashCode}
          onChange={(e) => setHashCode(e.target.value.trim())}
          placeholder="a1b2c3d4"
          maxLength={8}
          pattern="[a-fA-F0-9]{8}"
          required
        />
        {hashCode.length > 0 && !isValidHash && (
          <span className={styles.error}>
            Має бути рівно 8 шістнадцяткових символів (0-9, a-f)
          </span>
        )}
      </div>

      <div className={styles.field}>
        <label className={styles.label} htmlFor="hintsUsed">
          Використано підказок
        </label>
        <input
          id="hintsUsed"
          type="number"
          className={styles.input}
          value={hintsUsed}
          onChange={(e) => setHintsUsed(Math.max(0, parseInt(e.target.value, 10) || 0))}
          min={0}
          max={10}
        />
      </div>

      {submitMutation.isError && (
        <div className={styles.errorMessage}>
          {submitMutation.error.message}
        </div>
      )}

      <button
        type="submit"
        className={`btn btn-primary ${styles.submitBtn}`}
        disabled={!isValidHash || submitMutation.isPending}
      >
        {submitMutation.isPending ? 'Перевірка...' : 'Здати'}
      </button>
    </form>
  );
}

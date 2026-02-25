/**
 * Mood selector — 5-point mood scale for session check-in.
 */

import styles from './MoodSelector.module.css';

interface MoodSelectorProps {
  onSelect: (mood: string) => void;
  selected?: string;
}

interface MoodOption {
  value: string;
  emoji: string;
  label: string;
}

const MOODS: MoodOption[] = [
  { value: 'great', emoji: '\uD83D\uDE0E', label: 'Чудово' },
  { value: 'good', emoji: '\uD83D\uDE0A', label: 'Добре' },
  { value: 'okay', emoji: '\uD83D\uDE10', label: 'Нормально' },
  { value: 'tired', emoji: '\uD83D\uDE34', label: 'Втомлений' },
  { value: 'struggling', emoji: '\uD83D\uDE16', label: 'Складно' },
];

export default function MoodSelector({
  onSelect,
  selected,
}: MoodSelectorProps): JSX.Element {
  return (
    <div className={styles.wrapper}>
      <h3 className={styles.title}>Як ти себе почуваєш?</h3>
      <div className={styles.options}>
        {MOODS.map((mood) => (
          <button
            key={mood.value}
            type="button"
            className={`${styles.option} ${
              selected === mood.value ? styles.optionSelected : ''
            }`}
            onClick={() => onSelect(mood.value)}
          >
            <span className={styles.emoji}>{mood.emoji}</span>
            <span className={styles.label}>{mood.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

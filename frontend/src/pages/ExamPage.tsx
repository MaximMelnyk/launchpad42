/**
 * Exam page — gate and final exam simulations.
 */

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useUser } from '@/hooks/useUser';
import { startExam, getExam, submitExamExercise } from '@/services/examService';
import { LEVEL_NAMES } from '@/types';
import type { Exam, ExamType } from '@/types';
import Layout from '@/components/Layout';
import Timer from '@/components/Timer';
import styles from './ExamPage.module.css';

export default function ExamPage(): JSX.Element {
  const { data: user } = useUser();
  const queryClient = useQueryClient();

  const [activeExamId, setActiveExamId] = useState<string | null>(null);
  const [submitHash, setSubmitHash] = useState('');
  const [selectedExercise, setSelectedExercise] = useState('');

  // Fetch active exam data
  const { data: exam, isLoading: examLoading } = useQuery<Exam>({
    queryKey: ['exam', activeExamId],
    queryFn: () => getExam(activeExamId!),
    enabled: !!activeExamId,
    refetchInterval: 30000,
  });

  // Start exam mutation
  const startMutation = useMutation<Exam, Error, { examType: ExamType; level: number }>({
    mutationFn: ({ examType, level }) => startExam(examType, level),
    onSuccess: (data) => {
      setActiveExamId(data.examId);
    },
  });

  // Submit exercise mutation
  const submitMutation = useMutation({
    mutationFn: ({ examId, exerciseId, hashCode }: {
      examId: string;
      exerciseId: string;
      hashCode: string;
    }) => submitExamExercise(examId, { exerciseId, hashCode }),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ['exam', activeExamId] });
      setSubmitHash('');
      setSelectedExercise('');
    },
  });

  const handleStartExam = (examType: ExamType): void => {
    if (!user) return;
    startMutation.mutate({ examType, level: user.level });
  };

  const handleSubmitExercise = (): void => {
    if (!activeExamId || !selectedExercise || !submitHash) return;
    submitMutation.mutate({
      examId: activeExamId,
      exerciseId: selectedExercise,
      hashCode: submitHash.toLowerCase(),
    });
  };

  const handleExamExpire = (): void => {
    // Timer expired — refetch exam to get updated status
    if (activeExamId) {
      void queryClient.invalidateQueries({ queryKey: ['exam', activeExamId] });
    }
  };

  // Active exam view
  if (exam && exam.status === 'in_progress') {
    const availableExercises = exam.exercises.filter(
      (id) => !exam.completedExercises.includes(id)
    );

    return (
      <Layout>
        <div className={styles.page}>
          <div className={styles.examHeader}>
            <h1 className={styles.heading}>
              {exam.examType === 'gate' ? 'Gate Exam' : 'Final Exam'}{' '}
              — Рівень {exam.level} ({LEVEL_NAMES[exam.level] ?? ''})
            </h1>
            {exam.startedAt && (
              <Timer
                startedAt={exam.startedAt}
                limitMinutes={exam.timeLimitMinutes}
                onExpire={handleExamExpire}
              />
            )}
          </div>

          <div className={styles.examNotice}>
            Увага: під час справжнього екзамену Piscine доступу до інтернету немає.
            Тренуйтеся розв'язувати задачі без пошуку.
          </div>

          {/* Score */}
          <div className={styles.scoreBar}>
            <span>Бали: {exam.score}</span>
            <span>
              Завершено: {exam.completedExercises.length}/{exam.exercises.length}
            </span>
            <span>Спроба #{exam.attemptNumber}</span>
          </div>

          {/* Exercise list */}
          <div className={styles.exerciseList}>
            <h2 className={styles.sectionTitle}>Вправи</h2>
            {exam.exercises.map((exId, index) => {
              const isComplete = exam.completedExercises.includes(exId);
              return (
                <div
                  key={exId}
                  className={`${styles.examExercise} ${isComplete ? styles.exerciseComplete : ''} ${selectedExercise === exId ? styles.exerciseSelected : ''}`}
                  onClick={() => !isComplete && setSelectedExercise(exId)}
                  role="button"
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' && !isComplete) setSelectedExercise(exId);
                  }}
                >
                  <span className={styles.exerciseIndex}>{index + 1}</span>
                  <span className={styles.exerciseId}>{exId}</span>
                  <span className={styles.exerciseStatus}>
                    {isComplete ? '\u2705' : '\u2B1C'}
                  </span>
                </div>
              );
            })}
          </div>

          {/* Submit hash for selected exercise */}
          {selectedExercise && availableExercises.includes(selectedExercise) && (
            <div className={styles.submitSection}>
              <h3 className={styles.submitTitle}>
                Здати: {selectedExercise}
              </h3>
              <div className={styles.submitRow}>
                <input
                  type="text"
                  className={styles.hashInput}
                  value={submitHash}
                  onChange={(e) => setSubmitHash(e.target.value.trim())}
                  placeholder="a1b2c3d4"
                  maxLength={8}
                />
                <button
                  className="btn btn-primary"
                  onClick={handleSubmitExercise}
                  disabled={submitHash.length !== 8 || submitMutation.isPending}
                  type="button"
                >
                  {submitMutation.isPending ? 'Перевірка...' : 'Здати'}
                </button>
              </div>
              {submitMutation.isError && (
                <span className={styles.submitError}>
                  {submitMutation.error.message}
                </span>
              )}
            </div>
          )}
        </div>
      </Layout>
    );
  }

  // Exam results view
  if (exam && exam.status !== 'in_progress') {
    const isPassed = exam.status === 'passed';
    const isPartial = exam.status === 'partial';

    return (
      <Layout>
        <div className={styles.page}>
          <div className={styles.results}>
            <h1 className={styles.heading}>Результати екзамену</h1>
            <div className={`${styles.resultBadge} ${isPassed ? styles.passed : isPartial ? styles.partial : styles.failed}`}>
              {isPassed && 'Складено!'}
              {isPartial && 'Часткове зарахування'}
              {exam.status === 'failed' && 'Не складено'}
            </div>
            <div className={styles.resultDetails}>
              <div className={styles.resultItem}>
                <span className={styles.resultLabel}>Бали</span>
                <span className={styles.resultValue}>{exam.score}%</span>
              </div>
              <div className={styles.resultItem}>
                <span className={styles.resultLabel}>Завершено</span>
                <span className={styles.resultValue}>
                  {exam.completedExercises.length}/{exam.exercises.length}
                </span>
              </div>
            </div>
            <button
              className="btn btn-primary"
              onClick={() => setActiveExamId(null)}
              type="button"
            >
              Назад до екзаменів
            </button>
          </div>
        </div>
      </Layout>
    );
  }

  // Exam selection view
  return (
    <Layout>
      <div className={styles.page}>
        <h1 className={styles.heading}>Екзамени</h1>
        <p className={styles.description}>
          Gate-екзамени відкривають наступний рівень.
          Фінальний екзамен симулює реальний Piscine (8 годин).
        </p>

        {examLoading && <p className={styles.loading}>Завантаження...</p>}

        {startMutation.isError && (
          <div className={styles.errorBox}>
            {startMutation.error.message}
          </div>
        )}

        <div className={styles.examOptions}>
          <div className={styles.examOption}>
            <h2 className={styles.optionTitle}>Gate Exam</h2>
            <p className={styles.optionDesc}>
              Рівень {user?.level ?? 0} ({LEVEL_NAMES[user?.level ?? 0]})
              {' \u2192 '}
              Рівень {(user?.level ?? 0) + 1} ({LEVEL_NAMES[(user?.level ?? 0) + 1] ?? 'Max'})
            </p>
            <p className={styles.optionMeta}>
              4 години &middot; 48 год кулдаун при провалі &middot; 3 спроби / 14 днів
            </p>
            <button
              className="btn btn-primary"
              onClick={() => handleStartExam('gate')}
              disabled={startMutation.isPending}
              type="button"
            >
              Почати Gate Exam
            </button>
          </div>

          <div className={styles.examOption}>
            <h2 className={styles.optionTitle}>Final Exam</h2>
            <p className={styles.optionDesc}>
              Повна симуляція екзамену Piscine 42
            </p>
            <p className={styles.optionMeta}>
              8 годин &middot; Прогресивна складність &middot; Без інтернету
            </p>
            <button
              className="btn btn-secondary"
              onClick={() => handleStartExam('final')}
              disabled={startMutation.isPending}
              type="button"
            >
              Почати Final Exam
            </button>
          </div>
        </div>
      </div>
    </Layout>
  );
}

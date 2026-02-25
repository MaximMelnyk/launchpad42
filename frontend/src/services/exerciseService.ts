/**
 * Exercise service — fetch exercises and submit solutions.
 */

import { api } from '@/services/apiClient';
import type { Exercise, ExerciseProgress, ExerciseSubmission } from '@/types';

export function getTodayExercises(): Promise<Exercise[]> {
  return api.get<Exercise[]>('/curriculum/today');
}

export function getExercise(id: string): Promise<Exercise> {
  return api.get<Exercise>(`/curriculum/exercises/${id}`);
}

export function submitExercise(
  id: string,
  data: ExerciseSubmission
): Promise<ExerciseProgress> {
  return api.post<ExerciseProgress>(`/exercise/${id}/submit`, data);
}

export function getExerciseProgress(id: string): Promise<ExerciseProgress> {
  return api.get<ExerciseProgress>(`/exercise/${id}/progress`);
}

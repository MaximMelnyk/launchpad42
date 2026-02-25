/**
 * Exercise service — fetch exercises and submit solutions.
 */

import { api } from '@/services/apiClient';
import type { Exercise, ExerciseProgress, ExerciseSubmission, ReviewCard, DrillPool } from '@/types';

/** Response shape from GET /curriculum/today */
export interface TodayResponse {
  exercises: Exercise[];
  reviewCards: ReviewCard[];
  drill: DrillPool | null;
  currentDay: number;
}

/** Response shape from GET /curriculum/exercises/{id} */
export interface ExerciseDetailResponse {
  exercise: Exercise;
  progress: ExerciseProgress | null;
}

/** Response shape from POST /curriculum/exercises/{id}/submit */
export interface SubmitExerciseResponse {
  xpEarned: number;
  bonuses: string[];
  levelUp: boolean;
  achievementsUnlocked: string[];
  alreadyCompleted?: boolean;
}

export function getTodayExercises(): Promise<TodayResponse> {
  return api.get<TodayResponse>('/curriculum/today');
}

export function getExercise(id: string): Promise<ExerciseDetailResponse> {
  return api.get<ExerciseDetailResponse>(`/curriculum/exercises/${id}`);
}

export function submitExercise(
  id: string,
  data: ExerciseSubmission
): Promise<SubmitExerciseResponse> {
  return api.post<SubmitExerciseResponse>(`/curriculum/exercises/${id}/submit`, data);
}

/**
 * Exercise hooks — React Query wrappers for exercise service.
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getTodayExercises,
  getExercise,
  submitExercise,
  getExerciseProgress,
} from '@/services/exerciseService';
import type { Exercise, ExerciseProgress, ExerciseSubmission } from '@/types';

export function useTodayExercises() {
  return useQuery<Exercise[]>({
    queryKey: ['exercises', 'today'],
    queryFn: getTodayExercises,
  });
}

export function useExercise(id: string) {
  return useQuery<Exercise>({
    queryKey: ['exercise', id],
    queryFn: () => getExercise(id),
    enabled: !!id,
  });
}

export function useExerciseProgress(id: string) {
  return useQuery<ExerciseProgress>({
    queryKey: ['exerciseProgress', id],
    queryFn: () => getExerciseProgress(id),
    enabled: !!id,
  });
}

export function useSubmitExercise() {
  const qc = useQueryClient();
  return useMutation<
    ExerciseProgress,
    Error,
    { id: string; data: ExerciseSubmission }
  >({
    mutationFn: ({ id, data }) => submitExercise(id, data),
    onSuccess: (_result, variables) => {
      void qc.invalidateQueries({ queryKey: ['exerciseProgress', variables.id] });
      void qc.invalidateQueries({ queryKey: ['exercises', 'today'] });
      void qc.invalidateQueries({ queryKey: ['user'] });
    },
  });
}

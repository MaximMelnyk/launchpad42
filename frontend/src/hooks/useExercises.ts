/**
 * Exercise hooks — React Query wrappers for exercise service.
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getTodayExercises,
  getExercise,
  submitExercise,
} from '@/services/exerciseService';
import type {
  TodayResponse,
  ExerciseDetailResponse,
  SubmitExerciseResponse,
} from '@/services/exerciseService';
import type { ExerciseSubmission } from '@/types';

export function useTodayExercises() {
  return useQuery<TodayResponse>({
    queryKey: ['exercises', 'today'],
    queryFn: getTodayExercises,
  });
}

export function useExercise(id: string) {
  return useQuery<ExerciseDetailResponse>({
    queryKey: ['exercise', id],
    queryFn: () => getExercise(id),
    enabled: !!id,
  });
}

export function useSubmitExercise() {
  const qc = useQueryClient();
  return useMutation<
    SubmitExerciseResponse,
    Error,
    { id: string; data: ExerciseSubmission }
  >({
    mutationFn: ({ id, data }) => submitExercise(id, data),
    onSuccess: (_result, variables) => {
      void qc.invalidateQueries({ queryKey: ['exercise', variables.id] });
      void qc.invalidateQueries({ queryKey: ['exercises', 'today'] });
      void qc.invalidateQueries({ queryKey: ['user'] });
      void qc.invalidateQueries({ queryKey: ['gamification'] });
      void qc.invalidateQueries({ queryKey: ['achievements'] });
    },
  });
}

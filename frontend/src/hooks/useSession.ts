/**
 * Session hooks — React Query wrappers for session service.
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getCurrentSession,
  startSession,
  endSession,
} from '@/services/sessionService';
import type { Session } from '@/types';

export function useCurrentSession() {
  return useQuery<Session | null>({
    queryKey: ['session', 'current'],
    queryFn: getCurrentSession,
  });
}

export function useStartSession() {
  const qc = useQueryClient();
  return useMutation<Session, Error, string>({
    mutationFn: (mood: string) => startSession(mood),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['session', 'current'] });
      void qc.invalidateQueries({ queryKey: ['user'] });
    },
  });
}

export function useEndSession() {
  const qc = useQueryClient();
  return useMutation<
    Session,
    Error,
    { mood: string; durationMinutes?: number }
  >({
    mutationFn: ({ mood, durationMinutes }) => endSession(mood, durationMinutes),
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['session', 'current'] });
      void qc.invalidateQueries({ queryKey: ['user'] });
      void qc.invalidateQueries({ queryKey: ['gamification'] });
    },
  });
}

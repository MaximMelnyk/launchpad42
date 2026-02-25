/**
 * Session service — start, end, and query daily sessions.
 */

import { api } from '@/services/apiClient';
import type { Session } from '@/types';

export function startSession(mood: string): Promise<Session> {
  return api.post<Session>('/session/start', { mood });
}

export function endSession(mood: string, durationMinutes?: number): Promise<Session> {
  return api.post<Session>('/session/end', { mood, durationMinutes });
}

export function getCurrentSession(): Promise<Session | null> {
  return api.get<Session | null>('/session/current');
}

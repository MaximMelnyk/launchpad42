/**
 * Tutor service — AI tutor chat for exercise help.
 */

import { api } from '@/services/apiClient';
import type { TutorRequest, TutorResponse } from '@/types';

export function askTutor(data: TutorRequest): Promise<TutorResponse> {
  return api.post<TutorResponse>('/tutor/ask', data);
}

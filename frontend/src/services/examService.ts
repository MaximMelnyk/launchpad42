/**
 * Exam service — gate and final exam management.
 */

import { api } from '@/services/apiClient';
import type { Exam, ExamType, ExamSubmitResponse } from '@/types';

export function startExam(examType: ExamType, level: number): Promise<Exam> {
  return api.post<Exam>('/exam/start', { examType, level });
}

export function submitExamExercise(
  examId: string,
  data: { exerciseId: string; hashCode: string }
): Promise<ExamSubmitResponse> {
  return api.post<ExamSubmitResponse>(`/exam/${examId}/submit`, data);
}

export function getExam(examId: string): Promise<Exam> {
  return api.get<Exam>(`/exam/${examId}`);
}

export function checkCooldown(examType: string): Promise<{ canStart: boolean; reason: string | null; nextAvailable: string | null }> {
  return api.get(`/exam/cooldown/${examType}`);
}

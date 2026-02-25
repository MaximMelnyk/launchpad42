/**
 * Exam service — gate and final exam management.
 */

import { api } from '@/services/apiClient';
import type { Exam, ExamType } from '@/types';

export function startExam(examType: ExamType, level: number): Promise<Exam> {
  return api.post<Exam>('/exam/start', { examType, level });
}

export function submitExamExercise(
  examId: string,
  data: { exerciseId: string; hashCode: string }
): Promise<Exam> {
  return api.post<Exam>(`/exam/${examId}/submit`, data);
}

export function getExam(examId: string): Promise<Exam> {
  return api.get<Exam>(`/exam/${examId}`);
}

/**
 * Gamification service — XP, achievements, drills, reviews.
 */

import { api } from '@/services/apiClient';
import type { GamificationProfile, Achievement } from '@/types';

export interface DrillVerifyRequest {
  functionName: string;
  timeSeconds: number;
}

export interface DrillVerifyResponse {
  correct: boolean;
  xpEarned: number;
  alreadyDrilled?: boolean;
  error?: string;
}

export interface ReviewSubmitRequest {
  cardId: string;
  correct: boolean;
}

export interface ReviewSubmitResponse {
  nextReview: string;
  intervalDays: number;
  xpEarned: number;
  alreadyReviewed?: boolean;
}

export function getGamificationProfile(): Promise<GamificationProfile> {
  return api.get<GamificationProfile>('/gamification/profile');
}

export function getAchievements(): Promise<Achievement[]> {
  return api.get<Achievement[]>('/gamification/achievements');
}

export function verifyDrill(data: DrillVerifyRequest): Promise<DrillVerifyResponse> {
  return api.post<DrillVerifyResponse>('/gamification/drill/verify', data);
}

export function submitReview(data: ReviewSubmitRequest): Promise<ReviewSubmitResponse> {
  return api.post<ReviewSubmitResponse>('/gamification/review', data);
}

export function updateStreak(): Promise<{ streakDays: number; shields: number; weeklyProgress: string }> {
  return api.post('/gamification/streak');
}

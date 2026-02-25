/**
 * Gamification service — XP, achievements, drills, reviews.
 */

import { api } from '@/services/apiClient';
import type { UserProfile, Achievement } from '@/types';

export interface DrillVerifyRequest {
  functionName: string;
  timeSeconds: number;
}

export interface DrillVerifyResponse {
  correct: boolean;
  xpEarned: number;
}

export interface ReviewSubmitRequest {
  cardId: string;
  correct: boolean;
}

export interface ReviewSubmitResponse {
  nextReview: string;
  xpEarned: number;
}

export function getGamificationProfile(): Promise<UserProfile> {
  return api.get<UserProfile>('/gamification/profile');
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

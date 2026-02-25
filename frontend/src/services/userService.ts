/**
 * User profile service — CRUD operations for user data.
 */

import { api } from '@/services/apiClient';
import type { UserProfile, UserProfileUpdate } from '@/types';

export function getProfile(): Promise<UserProfile> {
  return api.get<UserProfile>('/auth/profile');
}

export function updateProfile(data: UserProfileUpdate): Promise<UserProfile> {
  return api.put<UserProfile>('/auth/profile', data);
}

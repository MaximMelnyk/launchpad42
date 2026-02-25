/**
 * User profile hooks — React Query wrappers for user service.
 */

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getProfile, updateProfile } from '@/services/userService';
import type { UserProfile, UserProfileUpdate } from '@/types';

export function useUser() {
  return useQuery<UserProfile>({
    queryKey: ['user'],
    queryFn: getProfile,
    staleTime: 5 * 60 * 1000,
  });
}

export function useUpdateUser() {
  const qc = useQueryClient();
  return useMutation<UserProfile, Error, UserProfileUpdate>({
    mutationFn: updateProfile,
    onSuccess: () => {
      void qc.invalidateQueries({ queryKey: ['user'] });
    },
  });
}

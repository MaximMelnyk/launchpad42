/**
 * HTTP client — adds Firebase ID token to all requests.
 * All API communication goes through this module.
 */

import { firebaseAuth } from '@/hooks/useAuth';

const BASE_URL = import.meta.env.VITE_API_URL || '/api';

async function getIdToken(): Promise<string> {
  const user = firebaseAuth.currentUser;
  if (!user) throw new Error('Not authenticated');
  return user.getIdToken();
}

async function request<T>(method: string, path: string, body?: unknown): Promise<T> {
  const token = await getIdToken();
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (res.status === 401) {
    window.location.href = '/login';
    throw new Error('Unauthorized');
  }

  if (res.status === 403) {
    const err = await res.json().catch(() => ({ detail: 'Forbidden' }));
    if (err.detail === 'wrong_account') {
      // Sign out from wrong account and redirect with error
      try {
        const { firebaseAuth } = await import('@/hooks/useAuth');
        await firebaseAuth.signOut();
      } catch { /* redirect even if sign-out fails */ }
      window.location.href = '/login?error=wrong_account';
      throw new Error('wrong_account');
    }
    throw new Error(err.detail || `HTTP 403`);
  }

  if (!res.ok) {
    const err = await res.json().catch(() => ({ detail: 'Unknown error' }));
    throw new Error(err.detail || `HTTP ${res.status}`);
  }

  return res.json() as Promise<T>;
}

export const api = {
  get: <T>(path: string): Promise<T> => request<T>('GET', path),
  post: <T>(path: string, body?: unknown): Promise<T> => request<T>('POST', path, body),
  put: <T>(path: string, body?: unknown): Promise<T> => request<T>('PUT', path, body),
};

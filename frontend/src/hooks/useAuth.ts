/**
 * Firebase Auth hook — manages user authentication state.
 * Provides sign-in, sign-out, and ID token retrieval.
 */

import { useState, useEffect } from 'react';
import { initializeApp, getApps, getApp } from 'firebase/app';
import {
  getAuth,
  onAuthStateChanged,
  signInWithPopup,
  signOut as firebaseSignOut,
  GoogleAuthProvider,
  User,
} from 'firebase/auth';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

const app = getApps().length === 0 ? initializeApp(firebaseConfig) : getApp();
export const firebaseAuth = getAuth(app);

const googleProvider = new GoogleAuthProvider();

/** Get Firebase ID token for the current user. */
export async function getIdToken(): Promise<string> {
  const user = firebaseAuth.currentUser;
  if (!user) throw new Error('Not authenticated');
  return user.getIdToken();
}

/** Sign in with Google popup. */
export async function signInWithGoogle(): Promise<User> {
  const result = await signInWithPopup(firebaseAuth, googleProvider);
  return result.user;
}

/** Sign out from Firebase. */
export async function signOut(): Promise<void> {
  await firebaseSignOut(firebaseAuth);
}

export interface UseAuthReturn {
  user: User | null;
  loading: boolean;
  signIn: () => Promise<User>;
  signOut: () => Promise<void>;
}

export function useAuth(): UseAuthReturn {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(firebaseAuth, (firebaseUser) => {
      setUser(firebaseUser);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  return {
    user,
    loading,
    signIn: signInWithGoogle,
    signOut,
  };
}

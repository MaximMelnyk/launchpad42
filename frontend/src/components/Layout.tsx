/**
 * Layout component — header with navigation, user info, and main content area.
 */

import { NavLink, useNavigate } from 'react-router-dom';
import { useUser } from '@/hooks/useUser';
import { useAuth } from '@/hooks/useAuth';
import LevelBadge from '@/components/LevelBadge';
import styles from './Layout.module.css';

interface LayoutProps {
  children: React.ReactNode;
}

export default function Layout({ children }: LayoutProps): JSX.Element {
  const { data: user } = useUser();
  const { signOut } = useAuth();
  const navigate = useNavigate();

  const handleSignOut = async (): Promise<void> => {
    await signOut();
    navigate('/login');
  };

  return (
    <div className={styles.layout} data-level={user?.level ?? 0}>
      <header className={styles.header}>
        <div className={styles.headerInner}>
          <NavLink to="/" className={styles.logo}>
            <span className={styles.logoNumber}>42</span>
            <span className={styles.logoText}>LaunchPad</span>
          </NavLink>

          <nav className={styles.nav}>
            <NavLink
              to="/"
              end
              className={({ isActive }) =>
                `${styles.navLink} ${isActive ? styles.navLinkActive : ''}`
              }
            >
              Панель
            </NavLink>
            <NavLink
              to="/session"
              className={({ isActive }) =>
                `${styles.navLink} ${isActive ? styles.navLinkActive : ''}`
              }
            >
              Сесія
            </NavLink>
            <NavLink
              to="/progress"
              className={({ isActive }) =>
                `${styles.navLink} ${isActive ? styles.navLinkActive : ''}`
              }
            >
              Прогрес
            </NavLink>
            <NavLink
              to="/tutor"
              className={({ isActive }) =>
                `${styles.navLink} ${isActive ? styles.navLinkActive : ''}`
              }
            >
              Тьютор
            </NavLink>
          </nav>

          <div className={styles.userSection}>
            {user && <LevelBadge level={user.level} size="sm" />}
            <button
              className={styles.signOutBtn}
              onClick={handleSignOut}
              title="Вийти"
            >
              Вийти
            </button>
          </div>
        </div>
      </header>

      <main className={styles.main}>
        <div className={styles.container}>{children}</div>
      </main>
    </div>
  );
}

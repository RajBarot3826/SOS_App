import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useState, createContext, useContext } from 'react';
import { DASHBOARD_USERS } from './services/mockData';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import AlertsPage from './pages/AlertsPage';
import AnalyticsPage from './pages/AnalyticsPage';
import VolunteersPage from './pages/VolunteersPage';
import QRManagementPage from './pages/QRManagementPage';
import Layout from './components/Layout';

// Auth Context
export const AuthContext = createContext(null);

export function useAuth() {
  return useContext(AuthContext);
}

function ProtectedRoute({ children, roles }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" />;
  if (roles && !roles.includes(user.role)) return <Navigate to="/" />;
  return children;
}

export default function App() {
  const [user, setUser] = useState(() => {
    const saved = localStorage.getItem('safereach_user');
    return saved ? JSON.parse(saved) : null;
  });

  const login = (email, password) => {
    const found = DASHBOARD_USERS.find(u => u.email === email && u.password === password);
    if (found) {
      const userData = { email: found.email, name: found.name, role: found.role };
      setUser(userData);
      localStorage.setItem('safereach_user', JSON.stringify(userData));
      return true;
    }
    return false;
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('safereach_user');
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={user ? <Navigate to="/" /> : <LoginPage />} />
          <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
            <Route index element={<DashboardPage />} />
            <Route path="alerts" element={<AlertsPage />} />
            <Route path="analytics" element={<ProtectedRoute roles={['admin', 'coordinator']}><AnalyticsPage /></ProtectedRoute>} />
            <Route path="volunteers" element={<ProtectedRoute roles={['admin', 'coordinator']}><VolunteersPage /></ProtectedRoute>} />
            <Route path="qr-codes" element={<ProtectedRoute roles={['admin']}><QRManagementPage /></ProtectedRoute>} />
          </Route>
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </BrowserRouter>
    </AuthContext.Provider>
  );
}

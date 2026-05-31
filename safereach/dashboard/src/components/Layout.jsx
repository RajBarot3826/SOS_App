import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../App';
import { LayoutDashboard, AlertTriangle, BarChart3, Users, QrCode, LogOut, Shield } from 'lucide-react';

export default function Layout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const navItems = [
    { to: '/', icon: LayoutDashboard, label: 'Dashboard', roles: ['admin', 'coordinator', 'security', 'caregiver'] },
    { to: '/alerts', icon: AlertTriangle, label: 'Alerts', roles: ['admin', 'coordinator', 'security', 'caregiver'] },
    { to: '/analytics', icon: BarChart3, label: 'Analytics', roles: ['admin', 'coordinator'] },
    { to: '/volunteers', icon: Users, label: 'Volunteers', roles: ['admin', 'coordinator'] },
    { to: '/qr-codes', icon: QrCode, label: 'QR Codes', roles: ['admin'] },
  ];

  const filteredNav = navItems.filter(item => item.roles.includes(user?.role));

  const handleLogout = () => { logout(); navigate('/login'); };

  return (
    <div className="app-layout">
      <aside className="sidebar">
        <div className="sidebar-header">
          <div className="sidebar-logo"><Shield size={22} /></div>
          <span className="sidebar-title">SafeReach</span>
        </div>
        <nav className="sidebar-nav">
          {filteredNav.map(item => (
            <NavLink key={item.to} to={item.to} end={item.to === '/'} className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}>
              <item.icon size={20} />
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div style={{ padding: '16px', borderTop: '1px solid var(--border)' }}>
          <div style={{ fontSize: 13, color: 'var(--text-secondary)', marginBottom: 4 }}>{user?.name}</div>
          <div style={{ fontSize: 11, color: 'var(--text-muted)', marginBottom: 12, textTransform: 'uppercase' }}>{user?.role}</div>
          <button className="btn btn-outline" style={{ width: '100%', justifyContent: 'center' }} onClick={handleLogout}>
            <LogOut size={16} /> Logout
          </button>
        </div>
      </aside>
      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
}

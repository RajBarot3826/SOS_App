import { useMemo } from 'react';
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { BarChart3, TrendingUp, Clock, PieChart as PieIcon } from 'lucide-react';
import { generateAlertsByHour, generateAlertsByDay, generateAlertTypes, generateResponseTimes, MOCK_INCIDENTS, MOCK_USERS } from '../services/mockData';

export default function AnalyticsPage() {
  const hourlyData = useMemo(() => generateAlertsByHour(), []);
  const dailyData = useMemo(() => generateAlertsByDay(), []);
  const typeData = useMemo(() => generateAlertTypes(), []);
  const responseData = useMemo(() => generateResponseTimes(), []);

  const accessibilityBreakdown = useMemo(() => {
    const counts = {};
    MOCK_USERS.forEach(u => u.accessibility.forEach(a => { counts[a] = (counts[a] || 0) + 1; }));
    return Object.entries(counts).map(([name, value]) => ({ name, value }));
  }, []);

  const activationMethods = useMemo(() => {
    const counts = {};
    MOCK_INCIDENTS.forEach(i => { counts[i.activationMethod] = (counts[i.activationMethod] || 0) + 1; });
    return Object.entries(counts).map(([name, value]) => ({ name, value }));
  }, []);

  const COLORS = ['#EF4444', '#F97316', '#EAB308', '#4A90D9', '#22C55E', '#94A3B8', '#8B5CF6', '#EC4899'];

  return (
    <>
      <header className="header">
        <h1 className="header-title">Analytics</h1>
      </header>
      <div className="page-content">
        {/* KPI Row */}
        <div className="stats-grid fade-in">
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(74, 144, 217, 0.15)' }}><BarChart3 size={22} color="var(--primary)" /></div>
            <div className="stat-value">{MOCK_INCIDENTS.length}</div>
            <div className="stat-label">Total Incidents</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(34, 197, 94, 0.15)' }}><TrendingUp size={22} color="var(--safe-green)" /></div>
            <div className="stat-value">92<span style={{ fontSize: 14, color: 'var(--text-muted)' }}>%</span></div>
            <div className="stat-label">Resolution Rate</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(234, 179, 8, 0.15)' }}><Clock size={22} color="var(--warning-yellow)" /></div>
            <div className="stat-value">4.2<span style={{ fontSize: 14, color: 'var(--text-muted)' }}>min</span></div>
            <div className="stat-label">Avg Response</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(139, 92, 246, 0.15)' }}><PieIcon size={22} color="#8B5CF6" /></div>
            <div className="stat-value">{MOCK_USERS.length}</div>
            <div className="stat-label">Registered Users</div>
          </div>
        </div>

        {/* Charts Row 1 */}
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: 20, marginBottom: 20 }}>
          <div className="chart-container fade-in">
            <div className="chart-title">Alerts by Hour of Day</div>
            <ResponsiveContainer width="100%" height={260}>
              <AreaChart data={hourlyData}>
                <defs>
                  <linearGradient id="colorAlerts" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#4A90D9" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#4A90D9" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey="hour" stroke="#64748B" fontSize={11} interval={3} />
                <YAxis stroke="#64748B" fontSize={11} />
                <Tooltip contentStyle={{ background: '#1E293B', border: '1px solid #334155', borderRadius: 8, fontSize: 12 }} />
                <Area type="monotone" dataKey="count" stroke="#4A90D9" fill="url(#colorAlerts)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>

          <div className="chart-container fade-in">
            <div className="chart-title">Alert Types</div>
            <ResponsiveContainer width="100%" height={260}>
              <PieChart>
                <Pie data={typeData} dataKey="count" nameKey="type" cx="50%" cy="50%" innerRadius={50} outerRadius={90} paddingAngle={4}>
                  {typeData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
                </Pie>
                <Tooltip contentStyle={{ background: '#1E293B', border: '1px solid #334155', borderRadius: 8, fontSize: 12 }} />
                <Legend iconType="circle" wrapperStyle={{ fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Charts Row 2 */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 20 }}>
          <div className="chart-container fade-in">
            <div className="chart-title">Alerts by Day</div>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={dailyData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey="day" stroke="#64748B" fontSize={12} />
                <YAxis stroke="#64748B" fontSize={11} />
                <Tooltip contentStyle={{ background: '#1E293B', border: '1px solid #334155', borderRadius: 8, fontSize: 12 }} />
                <Bar dataKey="count" fill="#60A5FA" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="chart-container fade-in">
            <div className="chart-title">Avg Response Time (monthly)</div>
            <ResponsiveContainer width="100%" height={220}>
              <LineChart data={responseData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey="month" stroke="#64748B" fontSize={12} />
                <YAxis stroke="#64748B" fontSize={11} unit=" min" />
                <Tooltip contentStyle={{ background: '#1E293B', border: '1px solid #334155', borderRadius: 8, fontSize: 12 }} />
                <Line type="monotone" dataKey="avgTime" stroke="#22C55E" strokeWidth={2} dot={{ fill: '#22C55E', r: 4 }} />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="chart-container fade-in">
            <div className="chart-title">User Accessibility Profile</div>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={accessibilityBreakdown} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis type="number" stroke="#64748B" fontSize={11} />
                <YAxis type="category" dataKey="name" stroke="#64748B" fontSize={11} width={80} />
                <Tooltip contentStyle={{ background: '#1E293B', border: '1px solid #334155', borderRadius: 8, fontSize: 12 }} />
                <Bar dataKey="value" fill="#8B5CF6" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </>
  );
}

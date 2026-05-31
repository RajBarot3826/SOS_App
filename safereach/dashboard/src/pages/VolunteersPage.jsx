import { useState } from 'react';
import { Users, MapPin, Clock, Shield, Search } from 'lucide-react';
import { MOCK_VOLUNTEERS } from '../services/mockData';

export default function VolunteersPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const filtered = MOCK_VOLUNTEERS.filter(v => {
    const matchesSearch = v.name.toLowerCase().includes(searchQuery.toLowerCase()) || v.department.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || v.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const statusCounts = { all: MOCK_VOLUNTEERS.length, available: MOCK_VOLUNTEERS.filter(v => v.status === 'available').length, busy: MOCK_VOLUNTEERS.filter(v => v.status === 'busy').length, 'off-duty': MOCK_VOLUNTEERS.filter(v => v.status === 'off-duty').length };

  return (
    <>
      <header className="header">
        <h1 className="header-title">Volunteer Management</h1>
        <div className="header-actions">
          <span style={{ fontSize: 13, color: 'var(--safe-green)', fontWeight: 600 }}>{statusCounts.available} Available</span>
        </div>
      </header>
      <div className="page-content">
        {/* Search & Filters */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 20, alignItems: 'center' }}>
          <div style={{ position: 'relative', flex: 1, maxWidth: 320 }}>
            <Search size={16} style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
            <input className="input" placeholder="Search volunteers..." value={searchQuery} onChange={e => setSearchQuery(e.target.value)} style={{ paddingLeft: 36 }} />
          </div>
          {['all', 'available', 'busy', 'off-duty'].map(f => (
            <button key={f} className={`btn btn-sm ${statusFilter === f ? 'btn-primary' : 'btn-outline'}`} onClick={() => setStatusFilter(f)}>
              {f === 'all' ? 'All' : f === 'off-duty' ? 'Off Duty' : f.charAt(0).toUpperCase() + f.slice(1)} ({statusCounts[f]})
            </button>
          ))}
        </div>

        {/* Volunteer Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 16 }}>
          {filtered.map(v => (
            <div key={v.id} className="volunteer-card fade-in">
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
                <div style={{ width: 44, height: 44, borderRadius: 12, background: 'rgba(74, 144, 217, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, color: 'var(--primary)', fontSize: 16 }}>
                  {v.name.split(' ').map(n => n[0]).join('')}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 700, fontSize: 15 }}>{v.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>{v.studentId} · {v.department}</div>
                </div>
                <div className="volunteer-status">
                  <div className={`status-dot ${v.status === 'available' ? 'status-available' : v.status === 'busy' ? 'status-busy' : 'status-offline'}`} />
                  <span style={{ color: v.status === 'available' ? 'var(--safe-green)' : v.status === 'busy' ? 'var(--warning-orange)' : 'var(--text-muted)' }}>
                    {v.status === 'off-duty' ? 'Off Duty' : v.status.charAt(0).toUpperCase() + v.status.slice(1)}
                  </span>
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, fontSize: 13 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--text-secondary)' }}>
                  <MapPin size={14} /> {v.zone}
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--text-secondary)' }}>
                  <Shield size={14} /> {v.responseCount} responses
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--text-secondary)' }}>
                  <Clock size={14} /> Avg: {v.avgResponseTime}
                </div>
              </div>

              <div style={{ display: 'flex', gap: 8, marginTop: 12, paddingTop: 12, borderTop: '1px solid var(--border)' }}>
                <button className="btn btn-sm btn-outline" style={{ flex: 1 }}>View Profile</button>
                {v.status === 'available' && <button className="btn btn-sm btn-primary" style={{ flex: 1 }}>Assign Alert</button>}
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}

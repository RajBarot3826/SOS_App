import { useState } from 'react';
import { QrCode, MapPin, Building, Download, Search, Plus, Copy, Check } from 'lucide-react';
import { MOCK_QR_LOCATIONS } from '../services/mockData';

export default function QRManagementPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [copiedId, setCopiedId] = useState(null);

  const filtered = MOCK_QR_LOCATIONS.filter(loc =>
    loc.name.toLowerCase().includes(searchQuery.toLowerCase()) || loc.building.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const buildingGroups = filtered.reduce((acc, loc) => {
    if (!acc[loc.building]) acc[loc.building] = [];
    acc[loc.building].push(loc);
    return acc;
  }, {});

  const handleCopyQR = (id) => {
    navigator.clipboard.writeText(`safereach://location/${id}`);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  return (
    <>
      <header className="header">
        <h1 className="header-title">QR Code Management</h1>
        <div className="header-actions">
          <button className="btn btn-primary btn-sm"><Plus size={14} /> Add Location</button>
        </div>
      </header>
      <div className="page-content">
        {/* Summary Stats */}
        <div className="stats-grid fade-in" style={{ marginBottom: 20 }}>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(74, 144, 217, 0.15)' }}><QrCode size={22} color="var(--primary)" /></div>
            <div className="stat-value">{MOCK_QR_LOCATIONS.length}</div>
            <div className="stat-label">Total QR Codes</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(96, 165, 250, 0.15)' }}><Building size={22} color="var(--accent)" /></div>
            <div className="stat-value">{Object.keys(buildingGroups).length}</div>
            <div className="stat-label">Buildings Covered</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(34, 197, 94, 0.15)' }}><MapPin size={22} color="var(--safe-green)" /></div>
            <div className="stat-value">{MOCK_QR_LOCATIONS.length}</div>
            <div className="stat-label">Active Locations</div>
          </div>
        </div>

        {/* Search */}
        <div style={{ position: 'relative', maxWidth: 400, marginBottom: 20 }}>
          <Search size={16} style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
          <input className="input" placeholder="Search locations..." value={searchQuery} onChange={e => setSearchQuery(e.target.value)} style={{ paddingLeft: 36 }} />
        </div>

        {/* Location Groups */}
        {Object.entries(buildingGroups).map(([building, locations]) => (
          <div key={building} style={{ marginBottom: 24 }}>
            <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-secondary)', marginBottom: 10, display: 'flex', alignItems: 'center', gap: 8, textTransform: 'uppercase', letterSpacing: 0.5 }}>
              <Building size={14} /> {building} ({locations.length})
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 12 }}>
              {locations.map(loc => (
                <div key={loc.id} className="card fade-in" style={{ padding: 16 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
                    <div style={{ width: 40, height: 40, borderRadius: 10, background: 'rgba(74, 144, 217, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                      <QrCode size={20} color="var(--primary)" />
                    </div>
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 700, fontSize: 14 }}>{loc.name}</div>
                      <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>Floor {loc.floor} · Room {loc.room}</div>
                    </div>
                  </div>

                  <div style={{ fontSize: 11, color: 'var(--text-muted)', marginBottom: 10, display: 'flex', alignItems: 'center', gap: 4 }}>
                    <MapPin size={12} /> {loc.lat.toFixed(4)}, {loc.lng.toFixed(4)}
                  </div>

                  <div style={{ display: 'flex', gap: 6 }}>
                    <button className="btn btn-sm btn-outline" style={{ flex: 1, fontSize: 11 }} onClick={() => handleCopyQR(loc.id)}>
                      {copiedId === loc.id ? <><Check size={12} /> Copied!</> : <><Copy size={12} /> Copy Link</>}
                    </button>
                    <button className="btn btn-sm btn-primary" style={{ flex: 1, fontSize: 11 }}>
                      <Download size={12} /> Download QR
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </>
  );
}

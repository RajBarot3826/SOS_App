import { useState, useMemo } from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import { AlertTriangle, Clock, CheckCircle, Users, MapPin, Activity } from 'lucide-react';
import { MOCK_INCIDENTS, MOCK_VOLUNTEERS } from '../services/mockData';
import 'leaflet/dist/leaflet.css';

// Fix leaflet default icon
import L from 'leaflet';
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png',
  iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
});

const sosIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41],
});

const resolvedIcon = new L.Icon({
  iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
  shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
  iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41],
});

export default function DashboardPage() {
  const activeAlerts = MOCK_INCIDENTS.filter(i => i.status === 'active' || i.status === 'acknowledged');
  const resolvedToday = MOCK_INCIDENTS.filter(i => i.status === 'resolved');
  const availableVolunteers = MOCK_VOLUNTEERS.filter(v => v.status === 'available');

  const avgResponseTime = useMemo(() => {
    const times = [4.2, 3.8, 5.1, 3.2, 4.5];
    return (times.reduce((a, b) => a + b, 0) / times.length).toFixed(1);
  }, []);

  return (
    <>
      <header className="header">
        <h1 className="header-title">Dashboard</h1>
        <div className="header-actions">
          {activeAlerts.length > 0 && (
            <span className="header-badge">{activeAlerts.length} Active</span>
          )}
          <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>
            {new Date().toLocaleDateString('en-IN', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
          </span>
        </div>
      </header>

      <div className="page-content">
        {/* Stats Grid */}
        <div className="stats-grid fade-in">
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(239, 68, 68, 0.15)' }}>
              <AlertTriangle size={22} color="var(--sos-red)" />
            </div>
            <div className="stat-value" style={{ color: 'var(--sos-red)' }}>{activeAlerts.length}</div>
            <div className="stat-label">Active Alerts</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(34, 197, 94, 0.15)' }}>
              <CheckCircle size={22} color="var(--safe-green)" />
            </div>
            <div className="stat-value" style={{ color: 'var(--safe-green)' }}>{resolvedToday.length}</div>
            <div className="stat-label">Resolved Today</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(74, 144, 217, 0.15)' }}>
              <Clock size={22} color="var(--primary)" />
            </div>
            <div className="stat-value">{avgResponseTime}<span style={{ fontSize: 14, color: 'var(--text-muted)' }}>min</span></div>
            <div className="stat-label">Avg Response Time</div>
          </div>
          <div className="stat-card">
            <div className="stat-icon" style={{ background: 'rgba(96, 165, 250, 0.15)' }}>
              <Users size={22} color="var(--accent)" />
            </div>
            <div className="stat-value">{availableVolunteers.length}</div>
            <div className="stat-label">Available Volunteers</div>
          </div>
        </div>

        {/* Main Grid: Map + Alerts */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 380px', gap: 20 }}>
          {/* Live Map */}
          <div className="card fade-in" style={{ padding: 0, overflow: 'hidden' }}>
            <div style={{ padding: '16px 20px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: 8 }}>
              <MapPin size={18} color="var(--primary)" />
              <span style={{ fontWeight: 700, fontSize: 15 }}>Live Campus Map</span>
              <span className="header-badge" style={{ marginLeft: 'auto' }}>{activeAlerts.length} Active</span>
            </div>
            <div className="map-container" style={{ height: 440 }}>
              <MapContainer center={[23.025, 72.587]} zoom={16} style={{ height: '100%', width: '100%' }} scrollWheelZoom={true}>
                <TileLayer
                  url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                  attribution='&copy; <a href="https://carto.com/">CARTO</a>'
                />
                {MOCK_INCIDENTS.map(inc => (
                  <Marker key={inc.id} position={[inc.location.lat, inc.location.lng]}
                    icon={inc.status === 'active' || inc.status === 'acknowledged' ? sosIcon : resolvedIcon}>
                    <Popup>
                      <div style={{ fontFamily: 'Inter', minWidth: 180 }}>
                        <strong style={{ fontSize: 14 }}>{inc.userName}</strong><br />
                        <span style={{ fontSize: 12, color: '#666' }}>{inc.type} · {inc.status}</span><br />
                        <span style={{ fontSize: 11, color: '#999' }}>{inc.emergencyMessage?.substring(0, 60)}...</span>
                      </div>
                    </Popup>
                  </Marker>
                ))}
              </MapContainer>
            </div>
          </div>

          {/* Recent Alerts Feed */}
          <div className="card fade-in">
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 16 }}>
              <Activity size={18} color="var(--sos-red)" />
              <span style={{ fontWeight: 700, fontSize: 15 }}>Recent Alerts</span>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {MOCK_INCIDENTS.slice(0, 5).map(inc => {
                const statusClass = inc.status === 'active' ? 'badge-active' : inc.status === 'acknowledged' ? 'badge-acknowledged' : inc.status === 'resolved' ? 'badge-resolved' : 'badge-cancelled';
                return (
                  <div key={inc.id} className={`alert-card ${inc.status === 'active' ? 'active' : ''}`}>
                    <div className="alert-header">
                      <span className="alert-name">{inc.userName}</span>
                      <span className={`badge ${statusClass}`}>{inc.status}</span>
                    </div>
                    <div className="alert-message">{inc.emergencyMessage?.substring(0, 80)}...</div>
                    <div className="alert-meta">
                      <span>📍 {inc.location.name || 'Unknown'}</span>
                      <span>🕐 {inc.createdAt.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                    {inc.accessibility?.length > 0 && inc.accessibility[0] !== 'none' && (
                      <div style={{ marginTop: 6, display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                        {inc.accessibility.map(a => (
                          <span key={a} style={{ padding: '2px 8px', background: 'rgba(234, 179, 8, 0.15)', color: 'var(--warning-yellow)', borderRadius: 8, fontSize: 10, fontWeight: 600 }}>{a}</span>
                        ))}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

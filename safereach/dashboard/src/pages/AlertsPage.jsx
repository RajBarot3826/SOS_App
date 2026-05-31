import { useState } from 'react';
import { AlertTriangle, MapPin, Clock, User, Shield, Phone, Accessibility, CheckCircle } from 'lucide-react';
import { MOCK_INCIDENTS } from '../services/mockData';

export default function AlertsPage() {
  const [filter, setFilter] = useState('all');
  const [selectedIncident, setSelectedIncident] = useState(null);

  const filtered = filter === 'all' ? MOCK_INCIDENTS : MOCK_INCIDENTS.filter(i => i.status === filter);

  const statusCounts = {
    all: MOCK_INCIDENTS.length,
    active: MOCK_INCIDENTS.filter(i => i.status === 'active').length,
    acknowledged: MOCK_INCIDENTS.filter(i => i.status === 'acknowledged').length,
    resolved: MOCK_INCIDENTS.filter(i => i.status === 'resolved').length,
    falseAlert: MOCK_INCIDENTS.filter(i => i.status === 'falseAlert').length,
  };

  return (
    <>
      <header className="header">
        <h1 className="header-title">Alerts Management</h1>
        {statusCounts.active > 0 && <span className="header-badge">{statusCounts.active} Active</span>}
      </header>

      <div className="page-content">
        {/* Filter Tabs */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
          {['all', 'active', 'acknowledged', 'resolved', 'falseAlert'].map(f => (
            <button key={f} className={`btn btn-sm ${filter === f ? 'btn-primary' : 'btn-outline'}`} onClick={() => setFilter(f)}>
              {f === 'all' ? 'All' : f === 'falseAlert' ? 'False Alert' : f.charAt(0).toUpperCase() + f.slice(1)} ({statusCounts[f]})
            </button>
          ))}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: selectedIncident ? '1fr 420px' : '1fr', gap: 20 }}>
          {/* Alerts List */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {filtered.map(inc => {
              const statusClass = { active: 'badge-active', acknowledged: 'badge-acknowledged', resolved: 'badge-resolved', cancelled: 'badge-cancelled', falseAlert: 'badge-cancelled' }[inc.status] || 'badge-cancelled';
              const isSelected = selectedIncident?.id === inc.id;
              return (
                <div key={inc.id} className={`alert-card ${inc.status === 'active' ? 'active' : ''}`}
                  onClick={() => setSelectedIncident(inc)}
                  style={{ borderColor: isSelected ? 'var(--primary)' : undefined, background: isSelected ? 'var(--bg-elevated)' : undefined }}>
                  <div className="alert-header">
                    <span className="alert-name">{inc.userName}</span>
                    <span className={`badge ${statusClass}`}>{inc.status}</span>
                  </div>
                  <div className="alert-message">{inc.emergencyMessage}</div>
                  <div className="alert-meta">
                    <span><MapPin size={12} /> {inc.location.name || 'Unknown'}</span>
                    <span><Clock size={12} /> {inc.createdAt.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' })}</span>
                    <span style={{ textTransform: 'uppercase', fontSize: 10, fontWeight: 700 }}>{inc.activationMethod}</span>
                  </div>
                  {inc.accessibility?.length > 0 && inc.accessibility[0] !== 'none' && (
                    <div style={{ marginTop: 6, display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                      {inc.accessibility.map(a => (
                        <span key={a} style={{ padding: '2px 8px', background: 'rgba(234, 179, 8, 0.15)', color: 'var(--warning-yellow)', borderRadius: 8, fontSize: 10, fontWeight: 600 }}>
                          <Accessibility size={10} style={{ verticalAlign: 'middle', marginRight: 3 }} />{a}
                        </span>
                      ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {/* Detail Panel */}
          {selectedIncident && (
            <div className="card slide-in" style={{ position: 'sticky', top: 88, maxHeight: 'calc(100vh - 112px)', overflowY: 'auto' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
                <h3 style={{ fontSize: 16, fontWeight: 700 }}>Alert Detail</h3>
                <button className="btn btn-sm btn-outline" onClick={() => setSelectedIncident(null)}>✕</button>
              </div>

              {/* User Info */}
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
                <div style={{ width: 48, height: 48, borderRadius: 12, background: 'rgba(74, 144, 217, 0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <User size={24} color="var(--primary)" />
                </div>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 16 }}>{selectedIncident.userName}</div>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>{selectedIncident.type.toUpperCase()} · {selectedIncident.activationMethod}</div>
                </div>
              </div>

              {/* Accessibility Needs */}
              {selectedIncident.accessibility?.length > 0 && selectedIncident.accessibility[0] !== 'none' && (
                <div style={{ padding: 12, background: 'rgba(234, 179, 8, 0.08)', border: '1px solid rgba(234, 179, 8, 0.2)', borderRadius: 12, marginBottom: 16 }}>
                  <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--warning-yellow)', marginBottom: 6, display: 'flex', alignItems: 'center', gap: 4 }}><Shield size={12} /> ACCESSIBILITY NEEDS</div>
                  <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
                    {selectedIncident.accessibility.map(a => <span key={a} className="badge" style={{ background: 'rgba(234, 179, 8, 0.15)', color: 'var(--warning-yellow)' }}>{a}</span>)}
                  </div>
                </div>
              )}

              {/* Emergency Message */}
              <div style={{ padding: 12, background: 'var(--bg-elevated)', borderRadius: 12, marginBottom: 16 }}>
                <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--text-muted)', marginBottom: 4 }}>MESSAGE</div>
                <div style={{ fontSize: 14 }}>{selectedIncident.emergencyMessage}</div>
              </div>

              {/* Location */}
              <div style={{ padding: 12, background: 'var(--bg-elevated)', borderRadius: 12, marginBottom: 16 }}>
                <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--text-muted)', marginBottom: 4 }}>LOCATION</div>
                <div style={{ fontSize: 14 }}>{selectedIncident.location.name || 'Unknown Area'}</div>
                <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>{selectedIncident.location.lat.toFixed(6)}, {selectedIncident.location.lng.toFixed(6)}</div>
                <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>Accuracy: {selectedIncident.location.accuracy} ({selectedIncident.location.accuracyMeters || '—'}m)</div>
              </div>

              {/* Contact Alerts */}
              {selectedIncident.contactAlerts?.length > 0 && (
                <div style={{ marginBottom: 16 }}>
                  <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-secondary)', marginBottom: 8 }}>CONTACT ALERTS</div>
                  {selectedIncident.contactAlerts.map((c, i) => (
                    <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '8px 12px', background: 'var(--bg-elevated)', borderRadius: 10, marginBottom: 4 }}>
                      <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--primary)' }}>P{c.priority + 1}</span>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 13, fontWeight: 600 }}>{c.name}</div>
                        <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>{c.phone}</div>
                      </div>
                      <div style={{ fontSize: 11, fontWeight: 600, color: c.onTheWay ? 'var(--safe-green)' : c.acknowledged ? 'var(--primary)' : c.delivered ? 'var(--warning-orange)' : 'var(--text-muted)' }}>
                        {c.onTheWay ? '🏃 On Way' : c.acknowledged ? '✓ Ack' : c.delivered ? '📨 Sent' : '...'}
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {/* Timeline */}
              <div>
                <div style={{ fontSize: 12, fontWeight: 700, color: 'var(--text-secondary)', marginBottom: 8 }}>TIMELINE</div>
                {selectedIncident.timeline?.map((e, i) => (
                  <div key={i} className="timeline-item">
                    <div className="timeline-dot" />
                    <div className="timeline-content">
                      <div className="timeline-event">{e.event}</div>
                      {e.actor && <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>By {e.actor}</div>}
                      {e.details && <div style={{ fontSize: 11, color: 'var(--text-muted)' }}>{e.details}</div>}
                      <div className="timeline-time">{e.time.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit', second: '2-digit' })}</div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Actions */}
              {(selectedIncident.status === 'active' || selectedIncident.status === 'acknowledged') && (
                <div style={{ display: 'flex', gap: 8, marginTop: 16, paddingTop: 16, borderTop: '1px solid var(--border)' }}>
                  <button className="btn btn-success btn-sm" style={{ flex: 1 }}><CheckCircle size={14} /> Resolve</button>
                  <button className="btn btn-outline btn-sm" style={{ flex: 1 }}>False Alert</button>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </>
  );
}

import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../App';
import { Shield, Eye, EyeOff } from 'lucide-react';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = (e) => {
    e.preventDefault();
    setError('');
    if (login(email, password)) {
      navigate('/');
    } else {
      setError('Invalid email or password');
    }
  };

  return (
    <div className="login-page">
      <div className="login-card fade-in">
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: 24 }}>
          <div style={{ width: 64, height: 64, borderRadius: 16, background: 'linear-gradient(135deg, var(--primary), var(--accent))', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 20px rgba(74, 144, 217, 0.4)' }}>
            <Shield size={32} color="white" />
          </div>
        </div>
        <h1>SafeReach Admin</h1>
        <p>Sign in to the institutional dashboard</p>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Email</label>
            <input className="input" type="email" placeholder="admin@safereach.edu" value={email} onChange={e => setEmail(e.target.value)} required />
          </div>
          <div className="form-group">
            <label>Password</label>
            <div style={{ position: 'relative' }}>
              <input className="input" type={showPassword ? 'text' : 'password'} placeholder="Enter password" value={password} onChange={e => setPassword(e.target.value)} required style={{ paddingRight: 44 }} />
              <button type="button" onClick={() => setShowPassword(!showPassword)} style={{ position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          {error && <div style={{ color: 'var(--sos-red)', fontSize: 13, marginBottom: 12, textAlign: 'center' }}>{error}</div>}

          <button className="btn btn-primary" type="submit" style={{ width: '100%', justifyContent: 'center', marginTop: 8, padding: '12px 20px', fontSize: 15 }}>
            Sign In
          </button>
        </form>

        <div style={{ marginTop: 24, padding: 16, background: 'var(--bg-elevated)', borderRadius: 12, fontSize: 12, color: 'var(--text-muted)' }}>
          <div style={{ fontWeight: 600, marginBottom: 8, color: 'var(--text-secondary)' }}>Demo Credentials:</div>
          <div>Admin: admin@safereach.edu / admin123</div>
          <div>Coordinator: coord@safereach.edu / coord123</div>
          <div>Security: security@safereach.edu / sec123</div>
        </div>
      </div>
    </div>
  );
}

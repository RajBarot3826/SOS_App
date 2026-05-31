// SafeReach Dashboard — Comprehensive Mock Data
export const MOCK_USERS = [
  { id: 'u1', name: 'Arjun Patel', age: 21, role: 'user', accessibility: ['physical'], photo: null, phone: '+91 9876543210' },
  { id: 'u2', name: 'Priya Sharma', age: 19, role: 'user', accessibility: ['visual'], photo: null, phone: '+91 9876543211' },
  { id: 'u3', name: 'Ramesh Gupta', age: 72, role: 'user', accessibility: ['elderly', 'lowvision'], photo: null, phone: '+91 9876543212' },
  { id: 'u4', name: 'Aisha Khan', age: 20, role: 'user', accessibility: ['hearing'], photo: null, phone: '+91 9876543213' },
  { id: 'u5', name: 'Vikram Singh', age: 25, role: 'user', accessibility: ['temporary'], photo: null, phone: '+91 9876543214' },
  { id: 'u6', name: 'Neha Reddy', age: 22, role: 'user', accessibility: ['none'], photo: null, phone: '+91 9876543215' },
  { id: 'u7', name: 'Suresh Iyer', age: 68, role: 'user', accessibility: ['cognitive', 'elderly'], photo: null, phone: '+91 9876543216' },
  { id: 'u8', name: 'Fatima Begum', age: 23, role: 'user', accessibility: ['speech'], photo: null, phone: '+91 9876543217' },
];

export const MOCK_VOLUNTEERS = [
  { id: 'v1', name: 'Rahul Desai', department: 'Computer Science', studentId: 'CS2024001', status: 'available', zone: 'Block A', responseCount: 12, avgResponseTime: '4.2 min' },
  { id: 'v2', name: 'Sneha Mehta', department: 'Mechanical Eng.', studentId: 'ME2024015', status: 'busy', zone: 'Block B', responseCount: 8, avgResponseTime: '3.8 min' },
  { id: 'v3', name: 'Amit Joshi', department: 'Electronics', studentId: 'EC2024007', status: 'available', zone: 'Hostel Area', responseCount: 15, avgResponseTime: '5.1 min' },
  { id: 'v4', name: 'Kavita Nair', department: 'Civil Eng.', studentId: 'CE2024022', status: 'off-duty', zone: 'Library', responseCount: 6, avgResponseTime: '4.5 min' },
  { id: 'v5', name: 'Deepak Kumar', department: 'IT', studentId: 'IT2024010', status: 'available', zone: 'Canteen Area', responseCount: 20, avgResponseTime: '3.2 min' },
  { id: 'v6', name: 'Ritu Saxena', department: 'Pharmacy', studentId: 'PH2024003', status: 'available', zone: 'Block C', responseCount: 9, avgResponseTime: '4.8 min' },
];

const now = new Date();
const ago = (mins) => new Date(now.getTime() - mins * 60000);

export const MOCK_INCIDENTS = [
  {
    id: 'inc1', userId: 'u1', userName: 'Arjun Patel', status: 'active', type: 'medical',
    activationMethod: 'oneTap', emergencyMessage: 'I need immediate medical help. Please call an ambulance.',
    location: { lat: 23.0258, lng: 72.5873, accuracy: 'liveGPS', accuracyMeters: 5, name: 'Block A - Room 201' },
    accessibility: ['physical'], createdAt: ago(8), isSilent: false,
    contactAlerts: [
      { name: 'Dr. Patel', phone: '+91 9999000001', priority: 0, delivered: true, acknowledged: false, onTheWay: false },
      { name: 'Meera Patel', phone: '+91 9999000002', priority: 1, delivered: true, acknowledged: false, onTheWay: false },
    ],
    timeline: [
      { event: 'SOS Alert Created', time: ago(8), actor: 'Arjun Patel', details: 'Triggered via one-tap' },
      { event: 'Alert Sent', time: ago(8), details: 'Sent to 2 contacts' },
      { event: 'Alert Delivered', time: ago(7), details: 'Delivered to Dr. Patel' },
    ],
  },
  {
    id: 'inc2', userId: 'u2', userName: 'Priya Sharma', status: 'acknowledged', type: 'safety',
    activationMethod: 'voice', emergencyMessage: 'I am in an unsafe situation near the parking lot.',
    location: { lat: 23.0245, lng: 72.5860, accuracy: 'liveGPS', accuracyMeters: 8, name: 'Parking Lot B' },
    accessibility: ['visual'], createdAt: ago(15), isSilent: false,
    contactAlerts: [
      { name: 'Amit Sharma', phone: '+91 9999000003', priority: 0, delivered: true, acknowledged: true, onTheWay: true, eta: '3 min' },
    ],
    timeline: [
      { event: 'SOS Alert Created', time: ago(15), actor: 'Priya Sharma', details: 'Triggered via voice command' },
      { event: 'Alert Sent', time: ago(15), details: 'Sent to 1 contact' },
      { event: 'Alert Acknowledged', time: ago(12), actor: 'Amit Sharma' },
      { event: 'Help On The Way', time: ago(10), actor: 'Amit Sharma', details: 'ETA: 3 min' },
    ],
  },
  {
    id: 'inc3', userId: 'u3', userName: 'Ramesh Gupta', status: 'resolved', type: 'fallDetected',
    activationMethod: 'autoDetect', emergencyMessage: 'Fall detected. User did not respond to check.',
    location: { lat: 23.0230, lng: 72.5850, accuracy: 'liveGPS', accuracyMeters: 3, name: 'Garden Area' },
    accessibility: ['elderly', 'lowvision'], createdAt: ago(120), resolvedAt: ago(90), isSilent: false,
    contactAlerts: [
      { name: 'Sunil Gupta', phone: '+91 9999000004', priority: 0, delivered: true, acknowledged: true, onTheWay: true },
    ],
    timeline: [
      { event: 'Fall Detected', time: ago(120), details: 'AI confidence: 85%' },
      { event: 'Are you okay? prompt shown', time: ago(120) },
      { event: 'No response — SOS triggered', time: ago(119.75) },
      { event: 'Alert Acknowledged', time: ago(117), actor: 'Sunil Gupta' },
      { event: 'Help On The Way', time: ago(115), actor: 'Sunil Gupta' },
      { event: 'Incident Resolved', time: ago(90), actor: 'Sunil Gupta' },
    ],
  },
  {
    id: 'inc4', userId: 'u6', userName: 'Neha Reddy', status: 'resolved', type: 'navigation',
    activationMethod: 'shake', emergencyMessage: 'I am lost and need navigation assistance.',
    location: { lat: 23.0270, lng: 72.5890, accuracy: 'approximate', name: null },
    accessibility: ['none'], createdAt: ago(360), resolvedAt: ago(330), isSilent: false,
    contactAlerts: [{ name: 'Rohit Reddy', phone: '+91 9999000005', priority: 0, delivered: true, acknowledged: true, onTheWay: false }],
    timeline: [
      { event: 'SOS Alert Created', time: ago(360), actor: 'Neha Reddy', details: 'Triggered via shake' },
      { event: 'Alert Acknowledged', time: ago(355), actor: 'Rohit Reddy' },
      { event: 'Incident Resolved', time: ago(330), actor: 'Neha Reddy' },
    ],
  },
  {
    id: 'inc5', userId: 'u4', userName: 'Aisha Khan', status: 'falseAlert', type: 'safety',
    activationMethod: 'shake', emergencyMessage: 'I am in an unsafe or threatening situation.',
    location: { lat: 23.0255, lng: 72.5870, accuracy: 'liveGPS', accuracyMeters: 4, name: 'Library' },
    accessibility: ['hearing'], createdAt: ago(480), resolvedAt: ago(479), isSilent: false,
    contactAlerts: [],
    timeline: [
      { event: 'SOS Alert Created', time: ago(480), actor: 'Aisha Khan', details: 'Triggered via shake' },
      { event: 'Marked as False Alert', time: ago(479), actor: 'Aisha Khan', details: 'Accidental shake trigger' },
    ],
  },
];

export const MOCK_QR_LOCATIONS = [
  { id: 'qr1', name: 'Main Gate', building: 'Entrance', floor: 'G', room: '-', lat: 23.0220, lng: 72.5840 },
  { id: 'qr2', name: 'Block A - Room 101', building: 'Block A', floor: '1', room: '101', lat: 23.0258, lng: 72.5873 },
  { id: 'qr3', name: 'Block A - Room 201', building: 'Block A', floor: '2', room: '201', lat: 23.0258, lng: 72.5874 },
  { id: 'qr4', name: 'Library - Ground Floor', building: 'Library', floor: 'G', room: '-', lat: 23.0255, lng: 72.5870 },
  { id: 'qr5', name: 'Canteen', building: 'Canteen Block', floor: 'G', room: '-', lat: 23.0265, lng: 72.5880 },
  { id: 'qr6', name: 'Hostel A - Room 15', building: 'Hostel A', floor: '1', room: '15', lat: 23.0240, lng: 72.5855 },
  { id: 'qr7', name: 'Computer Lab', building: 'Block B', floor: '2', room: '205', lat: 23.0250, lng: 72.5865 },
  { id: 'qr8', name: 'Parking Lot B', building: 'Parking', floor: 'G', room: '-', lat: 23.0245, lng: 72.5860 },
  { id: 'qr9', name: 'Auditorium', building: 'Main Building', floor: 'G', room: '-', lat: 23.0235, lng: 72.5845 },
  { id: 'qr10', name: 'Sports Complex', building: 'Sports', floor: 'G', room: '-', lat: 23.0275, lng: 72.5895 },
  { id: 'qr11', name: 'Admin Office', building: 'Admin Block', floor: '1', room: '102', lat: 23.0228, lng: 72.5842 },
  { id: 'qr12', name: 'Medical Room', building: 'Admin Block', floor: 'G', room: '005', lat: 23.0227, lng: 72.5841 },
];

// Analytics data generators
export const generateAlertsByHour = () => {
  return Array.from({ length: 24 }, (_, i) => ({
    hour: `${i.toString().padStart(2, '0')}:00`,
    count: Math.floor(Math.random() * 8) + (i >= 18 || i <= 6 ? 3 : 0),
  }));
};

export const generateAlertsByDay = () => {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days.map(d => ({ day: d, count: Math.floor(Math.random() * 15) + 2 }));
};

export const generateAlertTypes = () => [
  { type: 'Medical', count: 18, color: '#EF4444' },
  { type: 'Safety', count: 12, color: '#F97316' },
  { type: 'Fall Detected', count: 8, color: '#EAB308' },
  { type: 'Navigation', count: 5, color: '#4A90D9' },
  { type: 'Mobility', count: 4, color: '#22C55E' },
  { type: 'Other', count: 3, color: '#94A3B8' },
];

export const generateResponseTimes = () => {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  return months.map(m => ({ month: m, avgTime: (Math.random() * 4 + 2).toFixed(1) }));
};

export const DASHBOARD_USERS = [
  { email: 'admin@safereach.edu', password: 'admin123', name: 'Admin User', role: 'admin' },
  { email: 'coord@safereach.edu', password: 'coord123', name: 'Coordinator', role: 'coordinator' },
  { email: 'security@safereach.edu', password: 'sec123', name: 'Security Staff', role: 'security' },
  { email: 'caregiver@safereach.edu', password: 'care123', name: 'Caregiver', role: 'caregiver' },
];

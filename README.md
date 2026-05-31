<div align="center">
  <img src="https://img.icons8.com/color/120/000000/shield.png" alt="SafeReach Logo">
  <h1>SafeReach</h1>
  <p><strong>Inclusive AI-Enabled SOS & Assistive Safety Platform</strong></p>

  <p>
    <a href="#features">Features</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#mobile-app">Mobile App</a> •
    <a href="#dashboard">Dashboard</a> •
    <a href="#getting-started">Getting Started</a>
  </p>

  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white" />
  <img src="https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB" />
  <img src="https://img.shields.io/badge/Vite-B73BFE?style=for-the-badge&logo=vite&logoColor=FFD62E" />
</div>

<br />

## 🌟 Overview

**SafeReach** is a comprehensive, AI-powered emergency assistance platform designed to ensure personal safety for everyone. It bridges the gap between individuals in distress and emergency responders through a dual-platform approach: a robust mobile application for users and an intuitive web dashboard for responders and administrators.

Whether it's an automatic fall detection trigger, an emergency voice command, or a quick SOS button press, SafeReach guarantees that help is always just a moment away.

---

## ✨ Key Features

### Mobile Application
* **Intelligent SOS Triggers:** Support for multiple trigger methods, including Voice Activation, Fall Detection, Shake Detection, and a physical/on-screen SOS button.
* **Real-time Location Tracking:** Continuous live-tracking using `google_maps_flutter` and `geolocator`.
* **Accessibility First:** Integrated voice commands (`speech_to_text`), Text-to-Speech (`flutter_tts`), and tailored accessibility profiles.
* **Background Monitoring:** Runs efficiently in the background ensuring safety triggers are always active (`flutter_background_service`).
* **Emergency Contacts:** Automatic SMS alerts and notifications to designated contacts (`telephony`, `firebase_messaging`).

### Responder Dashboard
* **Real-time Monitoring:** Web-based portal built with React and Vite for monitoring active incidents.
* **Interactive Maps:** Live visualization of distress signals.
* **Incident Timeline:** Detailed logs of actions taken during an emergency.
* **Instant Communication:** Seamlessly connect with the affected user or other responders.

---

## 🏗️ Architecture

SafeReach uses a modern, scalable tech stack:

* **Mobile App:** Flutter & Dart (State management handled via `riverpod`).
* **Web Dashboard:** React, Vite, and Node.js environment.
* **Backend & Database:** Firebase Auth, Cloud Firestore for real-time syncing, and Firebase Cloud Messaging for push notifications.
* **Local Storage:** Hive & Shared Preferences for offline data retention and fast caching.

---

## 📱 Mobile App (`/safereach/mobile`)

The mobile application is the core of the user experience. 

### Prerequisites
* Flutter SDK (`>=3.10.0`)
* Android Studio / Xcode

### Setup
1. Navigate to the mobile directory:
   ```bash
   cd safereach/mobile
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 💻 Responder Dashboard (`/safereach/dashboard`)

The responder dashboard provides operators and emergency contacts with a bird's-eye view of all active incidents.

### Prerequisites
* Node.js (`v16` or higher)
* npm or yarn

### Setup
1. Navigate to the dashboard directory:
   ```bash
   cd safereach/dashboard
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   npm run dev
   ```

---

## 🔐 Security & Privacy

We take user privacy seriously. All sensitive data is secured using encryption standards (`encrypt`), and fine-grained permission handling (`permission_handler`) ensures that location and sensor data are only accessed when strictly necessary and approved by the user.

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

<div align="center">
  <p>Built with ❤️ for a safer world.</p>
</div>
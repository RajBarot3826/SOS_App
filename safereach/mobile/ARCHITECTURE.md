# SafeReach System Architecture & Documentation

This document outlines the technical architecture, data flow, and emergency workflows of the SafeReach application, fulfilling the deliverables for system documentation.

## 1. System Architecture

SafeReach is built as a highly responsive, cross-platform mobile application using **Flutter** and **Dart**. The architecture follows a reactive state-management pattern utilizing **Riverpod** to ensure that critical UI components update instantly in response to sensor data or emergency state changes.

### Core Modules
- **UI Layer (Presentation)**: Built with Material 3, fully responsive, and highly accessible. Features adaptive layouts (Pictogram mode, High Contrast mode) that react to the user's `AccessibilityProfile`.
- **State Management (Riverpod)**: Acts as the central nervous system. The `SOSNotifier` manages the state machine (Idle -> Countdown -> Active -> Resolved), ensuring all UI components instantly reflect the current emergency phase.
- **Service Layer**: Contains isolated background workers for specific hardware/API tasks:
  - `ShakeDetectionService`: Monitors accelerometer data.
  - `FallDetectionService`: Analyzes sudden gravity shifts.
  - `VoiceRecognitionService`: Listens for custom wake words.
  - `LocationService`: Interfaces with device GPS for real-time tracking.
  - `SmsService`: Handles direct background cellular communication.
- **Data Persistence**: Utilizes **Hive** (a fast, lightweight NoSQL local database) to persist user profiles, emergency contacts, accessibility settings, and incident history offline.

---

## 2. Data Flow

SafeReach is designed to function even in low-connectivity environments. 

1. **Initialization**: On startup, the `ProfileProvider` hydrates user data and settings from Hive.
2. **Sensor Processing**: Background services (e.g., Accelerometer) stream raw data to their respective service classes. The service classes process this data (e.g., calculating G-force for falls) and, upon crossing a threshold, trigger a callback to the `SOSNotifier`.
3. **Emergency Trigger**: Once `SOSNotifier` receives a trigger, it transitions the app state. It requests the `LocationService` for immediate coordinates.
4. **Data Dispatch**: The `SOSNotifier` packages the user's details, accessibility needs, and GPS coordinates into an `Incident` model. It passes this payload to the `SmsService` which directly interfaces with the Android telephony API to dispatch SMS messages to the configured `EmergencyContact` list.
5. **Logging**: The `Incident` and its ongoing timeline (messages sent, acknowledgments received) are continuously serialized and written back to the Hive local database for post-incident review.

---

## 3. Emergency Flow

The emergency workflow is designed to be frictionless and automated:

### Phase 1: Activation
The user triggers an alert via one of several accessible methods:
- **One-Tap / Long Press**: Central SOS button on the home screen.
- **Hardware Sensor**: Rapidly shaking the device.
- **Automated**: Fall detection triggered by sudden impact.
- **Voice**: Speaking a custom wake-word (e.g., "Help me").

### Phase 2: Countdown (Optional)
A configurable countdown (e.g., 5 seconds) begins, featuring visual pulsing, heavy haptic feedback, and text-to-speech warnings. This allows the user to cancel accidental triggers. 

### Phase 3: Active Dispatch
If not canceled:
1. The app acquires the most accurate GPS location.
2. A high-priority SMS is sent sequentially to all emergency contacts in the background. The SMS includes a Google Maps link and the user's specific accessibility needs (e.g., "User is Deaf").
3. The UI transitions to the Active Dashboard, showing a live elapsed timer.

### Phase 4: Escalation & Resolution
- **Escalation**: If no contact acknowledges the alert within the configurable timeframe, the system can auto-escalate the alert.
- **Resolution**: The user or responder can mark the situation as "Safe," which halts location streaming, logs the resolution timestamp, and returns the app to the idle state.

---

## 4. Limitations & Future Scope

While the current prototype is fully functional as a standalone mobile application, there are limitations planned for future resolution:

1. **Cloud Backend**: Currently, the app relies entirely on local Hive storage and SMS for decentralized communication. A true cloud backend (e.g., Firebase or AWS) is needed to sync data across devices and provide a real-time web dashboard for institutional responders (e.g., Campus Security).
2. **iOS Background SMS Restrictions**: The direct background SMS feature relies on Android telephony permissions. Due to Apple's strict sandboxing, iOS devices must use the system share sheet or SMS intent fallback, requiring one manual user tap to send the message.
3. **Battery Consumption**: Continuous background monitoring for voice (wake-word) and high-frequency accelerometer polling for fall detection consumes significant battery. Future updates will implement AI-based adaptive sampling to pause sensors when the user is stationary.
4. **Offline Maps**: While the app functions offline by sending SMS, the responders require internet access to load the Google Maps link. Integrating offline map packaging for extreme remote areas is a future goal.

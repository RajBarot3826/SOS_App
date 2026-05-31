/// SafeReach App-wide Constants
library;

import 'package:flutter/material.dart';

// ── App Info ──────────────────────────────────────────────
class AppConstants {
  AppConstants._();

  static const String appName = 'SafeReach';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Safety, One Tap Away';

  // ── SOS Configuration ─────────────────────────────────
  static const int defaultCountdownSeconds = 5;
  static const int minCountdownSeconds = 0;
  static const int maxCountdownSeconds = 10;
  static const int locationUpdateIntervalMs = 10000; // 10 seconds
  static const int locationCacheIntervalMs = 300000; // 5 minutes
  static const int falseAlertWeeklyLimit = 3;
  static const int cancelPinWindowSeconds = 60;

  // ── Escalation Timings (minutes) ──────────────────────
  static const int escalationT1Minutes = 3;
  static const int escalationT2Minutes = 6;
  static const int escalationT3Minutes = 10;
  static const int escalationT4Minutes = 15;

  // ── Shake Detection ───────────────────────────────────
  static const double shakeSensitivityLow = 25.0;
  static const double shakeSensitivityMedium = 15.0;
  static const double shakeSensitivityHigh = 10.0;
  static const int shakeCountThreshold = 3;
  static const int shakeTimeWindowMs = 2000;

  // ── Fall Detection ────────────────────────────────────
  static const double fallAccelerationThreshold = 30.0;
  static const double inactivityThreshold = 2.0;
  static const int fallInactivityDurationMs = 3000;
  static const int fallConfirmationTimeoutSeconds = 15;
  static const double fallConfidenceThreshold = 70.0;

  // ── Touch Targets ─────────────────────────────────────
  static const double minTouchTarget = 48.0;
  static const double sosTouchTarget = 120.0;
  static const double largeTouchTarget = 64.0;

  // ── Accessibility ─────────────────────────────────────
  static const double minContrastRatio = 4.5;
  static const double largeTextContrastRatio = 3.0;

  // ── Default Voice Commands ────────────────────────────
  static const List<String> defaultVoiceCommands = [
    'help me',
    'मदद करो',       // Hindi
    'મદદ કરો',       // Gujarati
    'emergency',
    'bachao',
  ];

  // ── Predefined Emergency Messages ─────────────────────
  static const List<Map<String, String>> predefinedMessages = [
    {
      'en': 'I need immediate medical help. Please call an ambulance.',
      'hi': 'मुझे तुरंत चिकित्सा सहायता चाहिए। कृपया एम्बुलेंस बुलाएं।',
      'gu': 'મને તાત્કાલિક તબીબી મદદની જરૂર છે. કૃપા કરીને એમ્બ્યુલન્સ બોલાવો.',
    },
    {
      'en': 'I am unable to move. Please come to my location.',
      'hi': 'मैं हिल नहीं पा रहा/रही हूँ। कृपया मेरे स्थान पर आएं।',
      'gu': 'હું હલવામાં અસમર્થ છું. કૃપા કરીને મારા સ્થાન પર આવો.',
    },
    {
      'en': 'I am in an unsafe or threatening situation.',
      'hi': 'मैं एक असुरक्षित या खतरनाक स्थिति में हूँ।',
      'gu': 'હું અસુરક્ષિત અથવા ધમકીભરી પરિસ્થિતિમાં છું.',
    },
    {
      'en': 'I am lost and need navigation assistance.',
      'hi': 'मैं खो गया/गई हूँ और मुझे नेविगेशन सहायता चाहिए।',
      'gu': 'હું ખોવાઈ ગયો/ગઈ છું અને મને નેવિગેશન સહાયની જરૂર છે.',
    },
    {
      'en': 'I need wheelchair or mobility assistance.',
      'hi': 'मुझे व्हीलचेयर या गतिशीलता सहायता चाहिए।',
      'gu': 'મને વ્હીલચેર અથવા ગતિશીલતા સહાયની જરૂર છે.',
    },
    {
      'en': 'I cannot speak right now. Please check my location on the map.',
      'hi': 'मैं अभी बोल नहीं सकता/सकती। कृपया मानचित्र पर मेरा स्थान देखें।',
      'gu': 'હું અત્યારે બોલી શકતો/શકતી નથી. કૃપા કરીને નકશા પર મારું સ્થાન તપાસો.',
    },
    {
      'en': 'I am having a health emergency during an exam or event.',
      'hi': 'परीक्षा या कार्यक्रम के दौरान मुझे स्वास्थ्य आपातकाल हो रहा है।',
      'gu': 'પરીક્ષા અથવા ઇવેન્ટ દરમિયાન મને આરોગ્ય કટોકટી થઈ રહી છે.',
    },
  ];

  // ── Supported Languages ───────────────────────────────
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
  ];

  // ── Accessibility Profiles ────────────────────────────
  static const List<Map<String, dynamic>> accessibilityOptions = [
    {'id': 'physical', 'label': 'Physical Disability', 'icon': Icons.accessible, 'labelHi': 'शारीरिक अक्षमता', 'labelGu': 'શારીરિક અક્ષમતા'},
    {'id': 'visual', 'label': 'Visual Impairment', 'icon': Icons.visibility_off, 'labelHi': 'दृष्टि बाधित', 'labelGu': 'દૃષ્ટિ ક્ષતિ'},
    {'id': 'lowvision', 'label': 'Low Vision', 'icon': Icons.remove_red_eye, 'labelHi': 'कम दृष्टि', 'labelGu': 'ઓછી દૃષ્ટિ'},
    {'id': 'hearing', 'label': 'Hearing Impairment', 'icon': Icons.hearing_disabled, 'labelHi': 'श्रवण बाधित', 'labelGu': 'શ્રવણ ક્ષતિ'},
    {'id': 'speech', 'label': 'Speech Impairment', 'icon': Icons.record_voice_over, 'labelHi': 'वाक् बाधित', 'labelGu': 'વાણી ક્ષતિ'},
    {'id': 'cognitive', 'label': 'Cognitive Disability', 'icon': Icons.psychology, 'labelHi': 'संज्ञानात्मक अक्षमता', 'labelGu': 'જ્ઞાનાત્મક અક્ષમતા'},
    {'id': 'neurological', 'label': 'Neurological Condition', 'icon': Icons.psychology_alt, 'labelHi': 'न्यूरोलॉजिकल', 'labelGu': 'ન્યુરોલોજિકલ'},
    {'id': 'elderly', 'label': 'Elderly', 'icon': Icons.elderly, 'labelHi': 'बुजुर्ग', 'labelGu': 'વૃદ્ધ'},
    {'id': 'temporary', 'label': 'Temporary Injury', 'icon': Icons.personal_injury, 'labelHi': 'अस्थायी चोट', 'labelGu': 'અસ્થાયી ઈજા'},
    {'id': 'none', 'label': 'No Specific Need', 'icon': Icons.check_circle, 'labelHi': 'कोई विशेष आवश्यकता नहीं', 'labelGu': 'કોઈ ચોક્કસ જરૂરિયાત નથી'},
  ];

  // ── SOS Methods ───────────────────────────────────────
  static const List<Map<String, dynamic>> sosMethods = [
    {'id': 'one_tap', 'label': 'One-Tap SOS Button', 'icon': Icons.touch_app, 'description': 'Large button on home screen'},
    {'id': 'shake', 'label': 'Shake to SOS', 'icon': Icons.vibration, 'description': '3 rapid shakes'},
    {'id': 'voice', 'label': 'Voice Command', 'icon': Icons.mic, 'description': 'Say "Help me"'},
    {'id': 'long_press', 'label': 'Long Press', 'icon': Icons.touch_app_outlined, 'description': 'Hold volume buttons 3s'},
    {'id': 'gesture', 'label': 'Gesture SOS', 'icon': Icons.gesture, 'description': 'Draw circle or Z on screen'},
    {'id': 'power_button', 'label': 'Power Button', 'icon': Icons.power_settings_new, 'description': 'Press 5 times rapidly'},
    {'id': 'widget', 'label': 'Widget/Lock Screen', 'icon': Icons.widgets, 'description': 'Home screen shortcut'},
    {'id': 'wearable', 'label': 'Wearable Device', 'icon': Icons.watch, 'description': 'Smartwatch button'},
    {'id': 'silent', 'label': 'Silent SOS', 'icon': Icons.volume_off, 'description': 'No audio/visual confirmation'},
    {'id': 'auto_detect', 'label': 'Auto-Detection', 'icon': Icons.auto_awesome, 'description': 'AI detects emergencies'},
  ];

  // ── Relationships ─────────────────────────────────────
  static const List<String> relationships = [
    'Parent',
    'Spouse',
    'Sibling',
    'Child',
    'Friend',
    'Caregiver',
    'Doctor',
    'Colleague',
    'Neighbor',
    'Other',
  ];

  // ── Blood Groups ──────────────────────────────────────
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown',
  ];
}

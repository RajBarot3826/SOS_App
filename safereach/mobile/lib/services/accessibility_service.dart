/// Accessibility Service — Full UI adaptation engine based on user's accessibility profile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/providers/profile_provider.dart';

class AccessibilityAdaptations {
  final double fontScale;
  final double minTouchTarget;
  final bool useHighContrast;
  final bool useVoiceGuidance;
  final bool useVibrationOnly;
  final bool useVisualFlash;
  final bool usePictogramMode;
  final bool useSimplifiedUI;
  final bool useOneHandedMode;
  final String handPreference; // left, right, center
  final bool enableScreenReader;
  final bool largeButtons;

  const AccessibilityAdaptations({
    this.fontScale = 1.0,
    this.minTouchTarget = 48.0,
    this.useHighContrast = false,
    this.useVoiceGuidance = false,
    this.useVibrationOnly = false,
    this.useVisualFlash = false,
    this.usePictogramMode = false,
    this.useSimplifiedUI = false,
    this.useOneHandedMode = false,
    this.handPreference = 'center',
    this.enableScreenReader = false,
    this.largeButtons = false,
  });
}

class AccessibilityService {
  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;

  /// Compute adaptations from an accessibility profile
  AccessibilityAdaptations computeAdaptations(AccessibilityProfile profile) {
    double fontScale = profile.fontScale;
    double minTouch = 48.0;
    bool highContrast = profile.highContrastEnabled;
    bool voiceGuidance = profile.voiceGuidanceEnabled;
    bool vibrationOnly = false;
    bool visualFlash = false;
    bool pictogram = profile.pictogramModeEnabled;
    bool simplified = profile.simplifiedUIEnabled;
    bool oneHanded = false;
    bool largeButtons = false;

    for (final type in profile.disabilityTypes) {
      switch (type) {
        case DisabilityType.physical:
          minTouch = 64.0;
          largeButtons = true;
          oneHanded = true;
          simplified = true;
        case DisabilityType.visual:
          voiceGuidance = true;
          highContrast = true;
          fontScale = fontScale.clamp(1.4, 2.0);
        case DisabilityType.lowVision:
          highContrast = true;
          fontScale = fontScale.clamp(1.3, 2.0);
          largeButtons = true;
        case DisabilityType.hearing:
          vibrationOnly = true;
          visualFlash = true;
        case DisabilityType.speech:
          // No voice input, emphasize text/pictogram
          pictogram = true;
        case DisabilityType.cognitive:
          simplified = true;
          pictogram = true;
          fontScale = fontScale.clamp(1.2, 1.5);
          minTouch = 56.0;
        case DisabilityType.neurological:
          simplified = true;
          minTouch = 56.0;
        case DisabilityType.elderly:
          fontScale = fontScale.clamp(1.3, 1.8);
          largeButtons = true;
          simplified = true;
          voiceGuidance = true;
          minTouch = 56.0;
        case DisabilityType.temporary:
          oneHanded = true;
          largeButtons = true;
        case DisabilityType.none:
          break;
      }
    }

    return AccessibilityAdaptations(
      fontScale: fontScale,
      minTouchTarget: minTouch,
      useHighContrast: highContrast,
      useVoiceGuidance: voiceGuidance,
      useVibrationOnly: vibrationOnly,
      useVisualFlash: visualFlash,
      usePictogramMode: pictogram,
      useSimplifiedUI: simplified,
      useOneHandedMode: oneHanded,
      handPreference: profile.handPreference.name,
      enableScreenReader: voiceGuidance,
      largeButtons: largeButtons,
    );
  }

  /// Speak text using TTS for voice guidance
  Future<void> speak(String text, {String locale = 'en-US'}) async {
    if (!_ttsInitialized) {
      await _tts.setLanguage(locale);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ttsInitialized = true;
    }
    await _tts.speak(text);
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  /// Announce screen change for voice guidance
  Future<void> announceScreen(String screenName) async {
    await speak('Screen: $screenName');
  }

  /// Announce action result
  Future<void> announceAction(String action) async {
    await speak(action);
  }

  /// Get appropriate text style with accessibility scaling
  TextStyle adaptTextStyle(TextStyle base, double fontScale) {
    return base.copyWith(
      fontSize: (base.fontSize ?? 14) * fontScale,
      height: fontScale > 1.3 ? 1.4 : null, // Increase line height for large text
    );
  }

  /// Get minimum touch target size
  double getMinTouchTarget(AccessibilityAdaptations adaptations) {
    return adaptations.minTouchTarget;
  }

  /// Get SOS button size based on adaptations
  double getSOSButtonSize(AccessibilityAdaptations adaptations) {
    if (adaptations.largeButtons) return 140.0;
    return 120.0;
  }

  void dispose() {
    _tts.stop();
  }
}

// Riverpod providers
final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  final service = AccessibilityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final accessibilityAdaptationsProvider = Provider<AccessibilityAdaptations>((ref) {
  final profile = ref.watch(profileProvider);
  final service = ref.read(accessibilityServiceProvider);
  if (profile == null) return const AccessibilityAdaptations();
  return service.computeAdaptations(profile.accessibilityProfile);
});

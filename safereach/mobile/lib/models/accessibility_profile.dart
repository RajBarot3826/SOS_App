/// Accessibility Profile Model
/// Defines user's accessibility needs and drives UI adaptations
library;

import 'package:flutter/material.dart';

enum DisabilityType {
  physical,
  visual,
  lowVision,
  hearing,
  speech,
  cognitive,
  neurological,
  elderly,
  temporary,
  none,
}

enum FeedbackMode {
  sound,
  vibration,
  visualFlash,
  all,
}

enum SOSActivationMethod {
  oneTap,
  longPress,
  voice,
  shake,
  gesture,
  powerButton,
  widget,
  wearable,
  silent,
  autoDetect,
}

enum ShakeSensitivity {
  low,
  medium,
  high,
}

enum HandPreference {
  left,
  right,
  center,
}

class AccessibilityProfile {
  final List<DisabilityType> disabilityTypes;
  final List<SOSActivationMethod> enabledSOSMethods;
  final FeedbackMode feedbackMode;
  final ShakeSensitivity shakeSensitivity;
  final HandPreference handPreference;
  final int countdownSeconds;
  final bool voiceGuidanceEnabled;
  final bool highContrastEnabled;
  final bool pictogramModeEnabled;
  final bool silentModeEnabled;
  final bool simplifiedUIEnabled;
  final double fontScale;
  final String customVoiceCommand;
  final String preferredLanguage;

  const AccessibilityProfile({
    this.disabilityTypes = const [DisabilityType.none],
    this.enabledSOSMethods = const [SOSActivationMethod.oneTap, SOSActivationMethod.shake, SOSActivationMethod.voice],
    this.feedbackMode = FeedbackMode.all,
    this.shakeSensitivity = ShakeSensitivity.medium,
    this.handPreference = HandPreference.center,
    this.countdownSeconds = 5,
    this.voiceGuidanceEnabled = false,
    this.highContrastEnabled = false,
    this.pictogramModeEnabled = false,
    this.silentModeEnabled = false,
    this.simplifiedUIEnabled = false,
    this.fontScale = 1.0,
    this.customVoiceCommand = 'help me',
    this.preferredLanguage = 'en',
  });

  /// Auto-generate UI adaptations based on disability types
  AccessibilityProfile autoAdapt() {
    var voiceGuidance = voiceGuidanceEnabled;
    var highContrast = highContrastEnabled;
    var pictogramMode = pictogramModeEnabled;
    var simplified = simplifiedUIEnabled;
    var scale = fontScale;
    var feedback = feedbackMode;
    var hand = handPreference;

    for (final type in disabilityTypes) {
      switch (type) {
        case DisabilityType.visual:
          voiceGuidance = true;
          highContrast = true;
          scale = scale < 1.3 ? 1.3 : scale;
          break;
        case DisabilityType.lowVision:
          highContrast = true;
          scale = scale < 1.2 ? 1.2 : scale;
          break;
        case DisabilityType.hearing:
          feedback = FeedbackMode.vibration;
          break;
        case DisabilityType.cognitive:
          pictogramMode = true;
          simplified = true;
          scale = scale < 1.1 ? 1.1 : scale;
          break;
        case DisabilityType.elderly:
          scale = scale < 1.15 ? 1.15 : scale;
          simplified = true;
          voiceGuidance = true;
          break;
        case DisabilityType.physical:
        case DisabilityType.temporary:
          scale = scale < 1.1 ? 1.1 : scale;
          break;
        case DisabilityType.speech:
          // No special UI adaptation, but voice SOS is disabled
          break;
        case DisabilityType.neurological:
          simplified = true;
          break;
        case DisabilityType.none:
          break;
      }
    }

    return AccessibilityProfile(
      disabilityTypes: disabilityTypes,
      enabledSOSMethods: enabledSOSMethods,
      feedbackMode: feedback,
      shakeSensitivity: shakeSensitivity,
      handPreference: hand,
      countdownSeconds: countdownSeconds,
      voiceGuidanceEnabled: voiceGuidance,
      highContrastEnabled: highContrast,
      pictogramModeEnabled: pictogramMode,
      silentModeEnabled: silentModeEnabled,
      simplifiedUIEnabled: simplified,
      fontScale: scale,
      customVoiceCommand: customVoiceCommand,
      preferredLanguage: preferredLanguage,
    );
  }

  /// Get minimum touch target based on profile
  double get minTouchTarget {
    if (disabilityTypes.contains(DisabilityType.physical) ||
        disabilityTypes.contains(DisabilityType.temporary) ||
        disabilityTypes.contains(DisabilityType.elderly)) {
      return 64.0;
    }
    return 48.0;
  }

  /// Get SOS button size based on profile
  double get sosButtonSize {
    if (disabilityTypes.contains(DisabilityType.physical) ||
        disabilityTypes.contains(DisabilityType.lowVision) ||
        disabilityTypes.contains(DisabilityType.visual)) {
      return 140.0;
    }
    return 120.0;
  }

  /// Check if a specific disability type is selected
  bool hasDisability(DisabilityType type) => disabilityTypes.contains(type);

  /// Check if voice SOS should be enabled
  bool get isVoiceSOSEnabled =>
      enabledSOSMethods.contains(SOSActivationMethod.voice) &&
      !disabilityTypes.contains(DisabilityType.speech);

  /// Check if shake SOS should be enabled
  bool get isShakeSOSEnabled =>
      enabledSOSMethods.contains(SOSActivationMethod.shake);

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'disabilityTypes': disabilityTypes.map((e) => e.name).toList(),
        'enabledSOSMethods': enabledSOSMethods.map((e) => e.name).toList(),
        'feedbackMode': feedbackMode.name,
        'shakeSensitivity': shakeSensitivity.name,
        'handPreference': handPreference.name,
        'countdownSeconds': countdownSeconds,
        'voiceGuidanceEnabled': voiceGuidanceEnabled,
        'highContrastEnabled': highContrastEnabled,
        'pictogramModeEnabled': pictogramModeEnabled,
        'silentModeEnabled': silentModeEnabled,
        'simplifiedUIEnabled': simplifiedUIEnabled,
        'fontScale': fontScale,
        'customVoiceCommand': customVoiceCommand,
        'preferredLanguage': preferredLanguage,
      };

  /// Create from JSON map
  factory AccessibilityProfile.fromJson(Map<String, dynamic> json) {
    return AccessibilityProfile(
      disabilityTypes: (json['disabilityTypes'] as List<dynamic>?)
              ?.map((e) => DisabilityType.values.firstWhere(
                    (v) => v.name == e,
                    orElse: () => DisabilityType.none,
                  ))
              .toList() ??
          [DisabilityType.none],
      enabledSOSMethods: (json['enabledSOSMethods'] as List<dynamic>?)
              ?.map((e) => SOSActivationMethod.values.firstWhere(
                    (v) => v.name == e,
                    orElse: () => SOSActivationMethod.oneTap,
                  ))
              .toList() ??
          [SOSActivationMethod.oneTap, SOSActivationMethod.shake, SOSActivationMethod.voice],
      feedbackMode: FeedbackMode.values.firstWhere(
        (v) => v.name == json['feedbackMode'],
        orElse: () => FeedbackMode.all,
      ),
      shakeSensitivity: ShakeSensitivity.values.firstWhere(
        (v) => v.name == json['shakeSensitivity'],
        orElse: () => ShakeSensitivity.medium,
      ),
      handPreference: HandPreference.values.firstWhere(
        (v) => v.name == json['handPreference'],
        orElse: () => HandPreference.center,
      ),
      countdownSeconds: json['countdownSeconds'] ?? 5,
      voiceGuidanceEnabled: json['voiceGuidanceEnabled'] ?? false,
      highContrastEnabled: json['highContrastEnabled'] ?? false,
      pictogramModeEnabled: json['pictogramModeEnabled'] ?? false,
      silentModeEnabled: json['silentModeEnabled'] ?? false,
      simplifiedUIEnabled: json['simplifiedUIEnabled'] ?? false,
      fontScale: (json['fontScale'] ?? 1.0).toDouble(),
      customVoiceCommand: json['customVoiceCommand'] ?? 'help me',
      preferredLanguage: json['preferredLanguage'] ?? 'en',
    );
  }

  AccessibilityProfile copyWith({
    List<DisabilityType>? disabilityTypes,
    List<SOSActivationMethod>? enabledSOSMethods,
    FeedbackMode? feedbackMode,
    ShakeSensitivity? shakeSensitivity,
    HandPreference? handPreference,
    int? countdownSeconds,
    bool? voiceGuidanceEnabled,
    bool? highContrastEnabled,
    bool? pictogramModeEnabled,
    bool? silentModeEnabled,
    bool? simplifiedUIEnabled,
    double? fontScale,
    String? customVoiceCommand,
    String? preferredLanguage,
  }) {
    return AccessibilityProfile(
      disabilityTypes: disabilityTypes ?? this.disabilityTypes,
      enabledSOSMethods: enabledSOSMethods ?? this.enabledSOSMethods,
      feedbackMode: feedbackMode ?? this.feedbackMode,
      shakeSensitivity: shakeSensitivity ?? this.shakeSensitivity,
      handPreference: handPreference ?? this.handPreference,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      voiceGuidanceEnabled: voiceGuidanceEnabled ?? this.voiceGuidanceEnabled,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      pictogramModeEnabled: pictogramModeEnabled ?? this.pictogramModeEnabled,
      silentModeEnabled: silentModeEnabled ?? this.silentModeEnabled,
      simplifiedUIEnabled: simplifiedUIEnabled ?? this.simplifiedUIEnabled,
      fontScale: fontScale ?? this.fontScale,
      customVoiceCommand: customVoiceCommand ?? this.customVoiceCommand,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}

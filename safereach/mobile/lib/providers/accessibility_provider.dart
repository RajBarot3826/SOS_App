/// Accessibility Provider — Drives UI adaptations based on user profile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/config/theme.dart';

/// Provides the current accessibility profile, auto-adapted
final accessibilityProfileProvider = Provider<AccessibilityProfile>((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) return const AccessibilityProfile();
  return profile.accessibilityProfile;
});

/// Provides the correct theme based on accessibility settings
final appThemeProvider = Provider<ThemeData>((ref) {
  final accessibility = ref.watch(accessibilityProfileProvider);
  if (accessibility.highContrastEnabled) {
    return SafeReachTheme.highContrastTheme(fontScale: accessibility.fontScale);
  }
  return SafeReachTheme.lightTheme(fontScale: accessibility.fontScale);
});

/// Provides the dark theme
final appDarkThemeProvider = Provider<ThemeData>((ref) {
  final accessibility = ref.watch(accessibilityProfileProvider);
  if (accessibility.highContrastEnabled) {
    return SafeReachTheme.highContrastTheme(fontScale: accessibility.fontScale);
  }
  return SafeReachTheme.darkTheme(fontScale: accessibility.fontScale);
});

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final accessibility = ref.watch(accessibilityProfileProvider);
  if (accessibility.highContrastEnabled) return ThemeMode.dark;
  return ThemeMode.system;
});

/// Whether voice guidance is active
final voiceGuidanceActiveProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityProfileProvider).voiceGuidanceEnabled;
});

/// Whether simplified UI mode is active
final simplifiedUIProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityProfileProvider).simplifiedUIEnabled;
});

/// Whether pictogram mode is active
final pictogramModeProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityProfileProvider).pictogramModeEnabled;
});

/// Current font scale
final fontScaleProvider = Provider<double>((ref) {
  return ref.watch(accessibilityProfileProvider).fontScale;
});

/// Minimum touch target size
final minTouchTargetProvider = Provider<double>((ref) {
  return ref.watch(accessibilityProfileProvider).minTouchTarget;
});

/// SOS button size
final sosButtonSizeProvider = Provider<double>((ref) {
  return ref.watch(accessibilityProfileProvider).sosButtonSize;
});

/// Current feedback mode
final feedbackModeProvider = Provider<FeedbackMode>((ref) {
  return ref.watch(accessibilityProfileProvider).feedbackMode;
});

/// Hand preference for SOS button position
final handPreferenceProvider = Provider<HandPreference>((ref) {
  return ref.watch(accessibilityProfileProvider).handPreference;
});

/// Locale provider based on user preferred language
final localeProvider = Provider<Locale>((ref) {
  final profile = ref.watch(profileProvider);
  final lang = profile?.preferredLanguage ?? 'en';
  return Locale(lang);
});

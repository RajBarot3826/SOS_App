/// Accessibility Utilities
library;

import 'package:flutter/material.dart';
import 'package:safereach/models/accessibility_profile.dart';

class AccessibilityUtils {
  AccessibilityUtils._();

  static bool meetsContrastRatio(Color fg, Color bg, {double minRatio = 4.5}) {
    final fgLum = fg.computeLuminance();
    final bgLum = bg.computeLuminance();
    final lighter = fgLum > bgLum ? fgLum : bgLum;
    final darker = fgLum > bgLum ? bgLum : fgLum;
    return (lighter + 0.05) / (darker + 0.05) >= minRatio;
  }

  static double getFontScale(List<DisabilityType> types) {
    if (types.contains(DisabilityType.visual)) return 1.5;
    if (types.contains(DisabilityType.lowVision)) return 1.4;
    if (types.contains(DisabilityType.elderly)) return 1.3;
    if (types.contains(DisabilityType.cognitive)) return 1.2;
    return 1.0;
  }

  static double getMinTouchTarget(List<DisabilityType> types) {
    if (types.contains(DisabilityType.physical)) return 64.0;
    if (types.contains(DisabilityType.elderly)) return 56.0;
    if (types.contains(DisabilityType.cognitive)) return 56.0;
    return 48.0;
  }

  static String getDisabilityLabel(DisabilityType type) {
    switch (type) {
      case DisabilityType.physical: return 'Physical Disability';
      case DisabilityType.visual: return 'Visual Impairment';
      case DisabilityType.lowVision: return 'Low Vision';
      case DisabilityType.hearing: return 'Hearing Impairment';
      case DisabilityType.speech: return 'Speech Impairment';
      case DisabilityType.cognitive: return 'Cognitive Disability';
      case DisabilityType.neurological: return 'Neurological Condition';
      case DisabilityType.elderly: return 'Elderly';
      case DisabilityType.temporary: return 'Temporary Injury';
      case DisabilityType.none: return 'No Specific Need';
    }
  }

  static IconData getDisabilityIcon(DisabilityType type) {
    switch (type) {
      case DisabilityType.physical: return Icons.accessible;
      case DisabilityType.visual: return Icons.visibility_off;
      case DisabilityType.lowVision: return Icons.remove_red_eye;
      case DisabilityType.hearing: return Icons.hearing_disabled;
      case DisabilityType.speech: return Icons.record_voice_over;
      case DisabilityType.cognitive: return Icons.psychology;
      case DisabilityType.neurological: return Icons.psychology_alt;
      case DisabilityType.elderly: return Icons.elderly;
      case DisabilityType.temporary: return Icons.personal_injury;
      case DisabilityType.none: return Icons.check_circle;
    }
  }
}

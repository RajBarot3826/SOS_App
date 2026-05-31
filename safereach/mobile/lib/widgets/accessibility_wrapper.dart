/// Accessibility Wrapper — Applies accessibility adaptations to child widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/services/accessibility_service.dart';

class AccessibilityWrapper extends ConsumerWidget {
  final Widget child;
  final String? semanticLabel;
  final bool enforceMinTouchTarget;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.semanticLabel,
    this.enforceMinTouchTarget = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adaptations = ref.watch(accessibilityAdaptationsProvider);

    Widget result = child;

    // Apply font scaling via MediaQuery override
    if (adaptations.fontScale != 1.0) {
      result = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(adaptations.fontScale),
        ),
        child: result,
      );
    }

    // Enforce minimum touch target
    if (enforceMinTouchTarget) {
      result = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: adaptations.minTouchTarget,
          minHeight: adaptations.minTouchTarget,
        ),
        child: result,
      );
    }

    // Add semantic label
    if (semanticLabel != null) {
      result = Semantics(
        label: semanticLabel,
        child: result,
      );
    }

    return result;
  }
}

/// Widget that announces screen name for voice guidance users
class VoiceGuidanceAnnouncer extends ConsumerStatefulWidget {
  final String screenName;
  final Widget child;

  const VoiceGuidanceAnnouncer({
    super.key,
    required this.screenName,
    required this.child,
  });

  @override
  ConsumerState<VoiceGuidanceAnnouncer> createState() => _VoiceGuidanceAnnouncerState();
}

class _VoiceGuidanceAnnouncerState extends ConsumerState<VoiceGuidanceAnnouncer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adaptations = ref.read(accessibilityAdaptationsProvider);
      if (adaptations.useVoiceGuidance) {
        ref.read(accessibilityServiceProvider).announceScreen(widget.screenName);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// High Contrast Wrapper — Applies high-contrast overrides
class HighContrastWrapper extends ConsumerWidget {
  final Widget child;

  const HighContrastWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adaptations = ref.watch(accessibilityAdaptationsProvider);

    if (!adaptations.useHighContrast) return child;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF111111),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        dividerColor: Colors.white24,
      ),
      child: child,
    );
  }
}

/// Voice Guidance Widget — Speaks text and action results
class VoiceGuidanceWidget extends ConsumerWidget {
  final String text;
  final Widget child;
  final bool speakOnBuild;

  const VoiceGuidanceWidget({
    super.key,
    required this.text,
    required this.child,
    this.speakOnBuild = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adaptations = ref.watch(accessibilityAdaptationsProvider);

    if (speakOnBuild && adaptations.useVoiceGuidance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(accessibilityServiceProvider).speak(text);
      });
    }

    return Semantics(
      label: text,
      child: child,
    );
  }
}

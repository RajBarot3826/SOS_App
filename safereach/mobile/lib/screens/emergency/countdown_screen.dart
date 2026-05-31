/// Countdown Screen — Full-screen SOS countdown with haptic feedback, TTS, and circular progress
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/models/incident.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/providers/sos_provider.dart';
import 'package:safereach/providers/profile_provider.dart';
import 'package:safereach/providers/accessibility_provider.dart';
import 'package:safereach/services/accessibility_service.dart';

class CountdownScreen extends ConsumerStatefulWidget {
  const CountdownScreen({super.key});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _ringController;
  int _lastCountdown = -1;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _onCountdownChanged(int countdown) {
    if (countdown == _lastCountdown) return;
    _lastCountdown = countdown;

    // Haptic feedback on each tick
    HapticFeedback.heavyImpact();
    Vibration.vibrate(duration: 200);

    // TTS announcement if voice guidance is enabled
    final voiceGuidance = ref.read(voiceGuidanceActiveProvider);
    if (voiceGuidance) {
      final accessibilityService = ref.read(accessibilityServiceProvider);
      if (countdown <= 3 && countdown > 0) {
        accessibilityService.speak('$countdown');
      } else if (countdown == 0) {
        accessibilityService.speak('Sending SOS alert now');
      }
    }

    // Animate ring
    _ringController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final sosStatus = ref.watch(sosProvider);
    final screenSize = MediaQuery.of(context).size;

    // Auto-navigate when state changes
    if (sosStatus.state == SOSState.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.activeEmergency));
      return const SizedBox.shrink();
    }
    if (sosStatus.state == SOSState.idle || sosStatus.state == SOSState.cancelled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.home));
      return const SizedBox.shrink();
    }

    // Trigger haptic/TTS on countdown change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onCountdownChanged(sosStatus.countdownRemaining);
    });

    final maxCountdown = ref.read(profileProvider)?.accessibilityProfile.countdownSeconds ?? 5;
    final progress = maxCountdown > 0
        ? sosStatus.countdownRemaining / maxCountdown
        : 0.0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDC2626),
                Color(0xFFB91C1C),
                Color(0xFF7F1D1D),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Alert icon with pulse
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.6 + (_pulseAnimation.value * 0.4),
                      child: child,
                    );
                  },
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 52),
                ),
                const SizedBox(height: 16),

                // Title
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: const Text(
                    'SENDING SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Alert will be sent in',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // Countdown ring
                Expanded(
                  child: Center(
                    child: Semantics(
                      liveRegion: true,
                      label: '${sosStatus.countdownRemaining} seconds remaining',
                      child: SizedBox(
                        width: screenSize.width * 0.55,
                        height: screenSize.width * 0.55,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: screenSize.width * 0.55,
                                  height: screenSize.width * 0.55,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withValues(alpha: 0.3 * _pulseAnimation.value),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // Progress ring background
                            SizedBox(
                              width: screenSize.width * 0.5,
                              height: screenSize.width * 0.5,
                              child: CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 6,
                                strokeCap: StrokeCap.round,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                            ),

                            // Progress ring foreground (animated)
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.0, end: progress),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return SizedBox(
                                  width: screenSize.width * 0.5,
                                  height: screenSize.width * 0.5,
                                  child: CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 6,
                                    strokeCap: StrokeCap.round,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              },
                            ),

                            // Inner circle with number
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 1.3, end: 1.0),
                              duration: const Duration(milliseconds: 300),
                              key: ValueKey(sosStatus.countdownRemaining),
                              builder: (context, scale, child) {
                                return Transform.scale(scale: scale, child: child);
                              },
                              child: Container(
                                width: screenSize.width * 0.38,
                                height: screenSize.width * 0.38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${sosStatus.countdownRemaining}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenSize.width * 0.18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Trigger method badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTriggerIcon(sosStatus.triggerMethod),
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Triggered via ${_getTriggerLabel(sosStatus.triggerMethod)}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // CANCEL button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Semantics(
                    label: 'Cancel SOS alert',
                    button: true,
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(sosProvider.notifier).cancelCountdown();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: Colors.black26,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close_rounded, size: 26),
                            SizedBox(width: 10),
                            Text(
                              'CANCEL',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Tap CANCEL to stop the alert',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTriggerIcon(SOSActivationMethod? method) {
    switch (method) {
      case SOSActivationMethod.shake:
        return Icons.vibration;
      case SOSActivationMethod.voice:
        return Icons.mic;
      case SOSActivationMethod.longPress:
        return Icons.touch_app;
      case SOSActivationMethod.autoDetect:
        return Icons.auto_awesome;
      default:
        return Icons.touch_app;
    }
  }

  String _getTriggerLabel(SOSActivationMethod? method) {
    switch (method) {
      case SOSActivationMethod.shake:
        return 'Shake';
      case SOSActivationMethod.voice:
        return 'Voice Command';
      case SOSActivationMethod.longPress:
        return 'Long Press';
      case SOSActivationMethod.autoDetect:
        return 'Auto Detection';
      case SOSActivationMethod.oneTap:
        return 'Button Tap';
      default:
        return 'Tap';
    }
  }
}

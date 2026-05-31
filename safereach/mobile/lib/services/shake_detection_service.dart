/// Shake Detection Service — Accelerometer-based SOS trigger
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:safereach/config/constants.dart';

enum ShakeSensitivity { low, medium, high }

class ShakeDetectionService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final List<DateTime> _shakeTimestamps = [];
  Timer? _resetTimer;
  bool _isEnabled = false;
  ShakeSensitivity _sensitivity = ShakeSensitivity.medium;
  void Function()? _onShakeDetected;

  bool get isEnabled => _isEnabled;
  ShakeSensitivity get sensitivity => _sensitivity;

  double get _threshold {
    switch (_sensitivity) {
      case ShakeSensitivity.low:
        return AppConstants.shakeSensitivityLow;
      case ShakeSensitivity.medium:
        return AppConstants.shakeSensitivityMedium;
      case ShakeSensitivity.high:
        return AppConstants.shakeSensitivityHigh;
    }
  }

  /// Start listening for shake events
  void start({
    required void Function() onShakeDetected,
    ShakeSensitivity sensitivity = ShakeSensitivity.medium,
  }) {
    _onShakeDetected = onShakeDetected;
    _sensitivity = sensitivity;
    _isEnabled = true;
    _shakeTimestamps.clear();

    _subscription?.cancel();
    _subscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50),
    ).listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (!_isEnabled) return;

    // Calculate total acceleration magnitude (excluding gravity ~9.8)
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Subtract gravity approximation to get pure user acceleration
    final userAcceleration = (magnitude - 9.8).abs();

    if (userAcceleration > _threshold) {
      final now = DateTime.now();

      // Remove old timestamps outside the time window
      _shakeTimestamps.removeWhere(
        (t) => now.difference(t).inMilliseconds > AppConstants.shakeTimeWindowMs,
      );

      _shakeTimestamps.add(now);

      // Check if we have enough shakes within the time window
      if (_shakeTimestamps.length >= AppConstants.shakeCountThreshold) {
        _shakeTimestamps.clear();
        _triggerShake();
      }
    }
  }

  void _triggerShake() {
    // Debounce: pause detection for 3 seconds after trigger
    _isEnabled = false;
    _onShakeDetected?.call();

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 3), () {
      _isEnabled = true;
    });
  }

  /// Update sensitivity
  void setSensitivity(ShakeSensitivity s) {
    _sensitivity = s;
  }

  /// Stop listening
  void stop() {
    _isEnabled = false;
    _subscription?.cancel();
    _subscription = null;
    _resetTimer?.cancel();
    _shakeTimestamps.clear();
  }

  void dispose() {
    stop();
  }
}

// Riverpod provider
final shakeDetectionServiceProvider = Provider<ShakeDetectionService>((ref) {
  final service = ShakeDetectionService();
  ref.onDispose(() => service.dispose());
  return service;
});

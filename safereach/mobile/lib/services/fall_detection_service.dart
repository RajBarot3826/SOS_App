/// Fall Detection Service — Rule-based fall detection using accelerometer patterns
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/config/constants.dart';
import 'package:safereach/services/sensor_service.dart';

enum FallDetectionState {
  monitoring,
  possibleFall,
  waitingConfirmation,
  confirmed,
  dismissed,
}

class FallEvent {
  final DateTime timestamp;
  final double peakAcceleration;
  final double confidencePercent;
  final FallDetectionState state;

  const FallEvent({
    required this.timestamp,
    required this.peakAcceleration,
    required this.confidencePercent,
    required this.state,
  });
}

class FallDetectionService {
  final SensorService _sensorService;
  StreamSubscription<SensorData>? _subscription;
  Timer? _inactivityCheckTimer;
  Timer? _confirmationTimer;

  FallDetectionState _state = FallDetectionState.monitoring;
  double _peakAcceleration = 0;
  DateTime? _fallDetectedTime;
  bool _isEnabled = false;

  void Function(FallEvent)? _onFallDetected;
  void Function()? _onFallConfirmed;

  FallDetectionState get state => _state;
  bool get isEnabled => _isEnabled;

  FallDetectionService(this._sensorService);

  /// Start monitoring for falls
  void start({
    required void Function(FallEvent) onFallDetected,
    required void Function() onFallConfirmed,
  }) {
    _onFallDetected = onFallDetected;
    _onFallConfirmed = onFallConfirmed;
    _isEnabled = true;
    _state = FallDetectionState.monitoring;

    if (!_sensorService.isActive) _sensorService.start();

    _subscription = _sensorService.sensorStream.listen(_analyzeSensorData);
  }

  void _analyzeSensorData(SensorData data) {
    if (!_isEnabled || _state != FallDetectionState.monitoring) return;

    final userAccel = (data.accelerationMagnitude - 9.8).abs();

    // Phase 1: Detect sudden acceleration spike (possible fall impact)
    if (userAccel > AppConstants.fallAccelerationThreshold) {
      _peakAcceleration = data.accelerationMagnitude;
      _fallDetectedTime = DateTime.now();
      _state = FallDetectionState.possibleFall;

      // Phase 2: Check for inactivity after spike (person not moving = on the ground)
      _inactivityCheckTimer?.cancel();
      _inactivityCheckTimer = Timer(
        Duration(milliseconds: AppConstants.fallInactivityDurationMs),
        () => _checkInactivity(),
      );
    }
  }

  void _checkInactivity() {
    if (!_isEnabled || _state != FallDetectionState.possibleFall) return;

    final inactivity = _sensorService.inactivityDuration;

    // If user has been still for 3+ seconds after the impact
    if (inactivity.inMilliseconds >= AppConstants.fallInactivityDurationMs) {
      final confidence = _calculateConfidence(
        _peakAcceleration,
        inactivity.inSeconds.toDouble(),
      );

      if (confidence >= AppConstants.fallConfidenceThreshold) {
        _state = FallDetectionState.waitingConfirmation;

        final event = FallEvent(
          timestamp: _fallDetectedTime ?? DateTime.now(),
          peakAcceleration: _peakAcceleration,
          confidencePercent: confidence,
          state: _state,
        );
        _onFallDetected?.call(event);

        // Start confirmation timeout (15 seconds)
        _confirmationTimer?.cancel();
        _confirmationTimer = Timer(
          Duration(seconds: AppConstants.fallConfirmationTimeoutSeconds),
          () => _confirmFall(),
        );
      } else {
        // Low confidence → back to monitoring
        _state = FallDetectionState.monitoring;
      }
    } else {
      // User started moving again → not a fall
      _state = FallDetectionState.monitoring;
    }
  }

  /// Calculate fall confidence score (0-100%)
  double _calculateConfidence(double peakAccel, double inactivitySec) {
    // Base score from acceleration magnitude
    double accelScore = ((peakAccel - AppConstants.fallAccelerationThreshold) /
            AppConstants.fallAccelerationThreshold *
            50)
        .clamp(0, 50);

    // Bonus from inactivity duration
    double inactivityScore = (inactivitySec / 5.0 * 50).clamp(0, 50);

    return (accelScore + inactivityScore).clamp(0, 100);
  }

  void _confirmFall() {
    if (_state != FallDetectionState.waitingConfirmation) return;
    _state = FallDetectionState.confirmed;
    _onFallConfirmed?.call();

    // Reset after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _state = FallDetectionState.monitoring;
    });
  }

  /// User responds "I'm okay" → dismiss the fall alert
  void dismissFall() {
    _confirmationTimer?.cancel();
    _state = FallDetectionState.dismissed;

    // Return to monitoring after 2 seconds
    Timer(const Duration(seconds: 2), () {
      _state = FallDetectionState.monitoring;
    });
  }

  /// Stop fall detection
  void stop() {
    _isEnabled = false;
    _subscription?.cancel();
    _inactivityCheckTimer?.cancel();
    _confirmationTimer?.cancel();
    _state = FallDetectionState.monitoring;
  }

  void dispose() {
    stop();
  }
}

// Riverpod provider
final fallDetectionServiceProvider = Provider<FallDetectionService>((ref) {
  final sensorService = ref.watch(sensorServiceProvider);
  final service = FallDetectionService(sensorService);
  ref.onDispose(() => service.dispose());
  return service;
});

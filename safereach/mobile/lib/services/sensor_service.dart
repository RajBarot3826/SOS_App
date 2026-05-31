/// Sensor Service — Central accelerometer/gyroscope management
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorData {
  final double accelerationMagnitude;
  final double gyroMagnitude;
  final DateTime timestamp;
  final bool isStationary;

  const SensorData({
    required this.accelerationMagnitude,
    required this.gyroMagnitude,
    required this.timestamp,
    required this.isStationary,
  });
}

class SensorState {
  final bool isActive;
  final SensorData? latestData;
  final double avgAcceleration;
  final Duration inactivityDuration;

  const SensorState({
    this.isActive = false,
    this.latestData,
    this.avgAcceleration = 0,
    this.inactivityDuration = Duration.zero,
  });

  SensorState copyWith({
    bool? isActive,
    SensorData? latestData,
    double? avgAcceleration,
    Duration? inactivityDuration,
  }) =>
      SensorState(
        isActive: isActive ?? this.isActive,
        latestData: latestData ?? this.latestData,
        avgAcceleration: avgAcceleration ?? this.avgAcceleration,
        inactivityDuration: inactivityDuration ?? this.inactivityDuration,
      );
}

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  Timer? _inactivityTimer;

  final _controller = StreamController<SensorData>.broadcast();
  Stream<SensorData> get sensorStream => _controller.stream;

  double _lastAccelMag = 9.8;
  double _lastGyroMag = 0;
  DateTime? _lastMovementTime;
  final List<double> _recentAccelValues = [];
  static const int _windowSize = 20;

  bool _isActive = false;
  bool get isActive => _isActive;

  /// Start sensor monitoring
  void start() {
    if (_isActive) return;
    _isActive = true;
    _lastMovementTime = DateTime.now();

    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _lastAccelMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      _recentAccelValues.add(_lastAccelMag);
      if (_recentAccelValues.length > _windowSize) _recentAccelValues.removeAt(0);

      final userAccel = (_lastAccelMag - 9.8).abs();
      if (userAccel > 2.0) _lastMovementTime = DateTime.now();

      _emitData();
    });

    _gyroSub = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _lastGyroMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    });

    // Track inactivity every second
    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (_) => _emitData());
  }

  void _emitData() {
    if (!_isActive) return;

    final now = DateTime.now();
    final inactivity = _lastMovementTime != null ? now.difference(_lastMovementTime!) : Duration.zero;
    final avgAccel = _recentAccelValues.isEmpty ? 9.8 : _recentAccelValues.reduce((a, b) => a + b) / _recentAccelValues.length;

    _controller.add(SensorData(
      accelerationMagnitude: _lastAccelMag,
      gyroMagnitude: _lastGyroMag,
      timestamp: now,
      isStationary: inactivity.inSeconds > 3,
    ));
  }

  /// Get current average acceleration
  double get averageAcceleration {
    if (_recentAccelValues.isEmpty) return 9.8;
    return _recentAccelValues.reduce((a, b) => a + b) / _recentAccelValues.length;
  }

  /// Get inactivity duration
  Duration get inactivityDuration {
    if (_lastMovementTime == null) return Duration.zero;
    return DateTime.now().difference(_lastMovementTime!);
  }

  /// Stop sensor monitoring
  void stop() {
    _isActive = false;
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _inactivityTimer?.cancel();
    _recentAccelValues.clear();
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

// Riverpod providers
final sensorServiceProvider = Provider<SensorService>((ref) {
  final service = SensorService();
  ref.onDispose(() => service.dispose());
  return service;
});

final sensorDataProvider = StreamProvider<SensorData>((ref) {
  final service = ref.watch(sensorServiceProvider);
  if (!service.isActive) service.start();
  return service.sensorStream;
});

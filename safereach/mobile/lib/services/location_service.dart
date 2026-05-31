/// Location Service — Multi-fallback location with accuracy tracking
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:safereach/models/incident.dart';

enum LocationStrategy { gps, lastKnown, network, manual, qrCode }

class LocationResult {
  final double latitude;
  final double longitude;
  final LocationAccuracy accuracy;
  final double? accuracyMeters;
  final LocationStrategy strategy;
  final DateTime timestamp;
  final String? locationName;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.accuracyMeters,
    required this.strategy,
    required this.timestamp,
    this.locationName,
  });

  IncidentLocation toIncidentLocation() => IncidentLocation(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        accuracyMeters: accuracyMeters,
        timestamp: timestamp,
        locationName: locationName,
      );
}

class LocationService {
  StreamSubscription<geo.Position>? _positionStream;
  geo.Position? _lastKnownPosition;
  Timer? _cacheTimer;
  final List<LocationResult> _history = [];

  List<LocationResult> get history => List.unmodifiable(_history);

  /// Initialize and start caching location every 5 minutes
  Future<void> initialize() async {
    await _checkPermissions();
    _startCaching();
  }

  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) return false;
    }
    if (permission == geo.LocationPermission.deniedForever) return false;
    return true;
  }

  /// Get best available location using fallback chain:
  /// GPS → Last Known → Network → Default
  Future<LocationResult> getBestLocation() async {
    // Strategy 1: Live GPS (high accuracy)
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final result = LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: LocationAccuracy.liveGPS,
        accuracyMeters: position.accuracy,
        strategy: LocationStrategy.gps,
        timestamp: DateTime.now(),
      );
      _lastKnownPosition = position;
      _history.add(result);
      return result;
    } catch (_) {}

    // Strategy 2: Last known GPS (cached)
    if (_lastKnownPosition != null) {
      final result = LocationResult(
        latitude: _lastKnownPosition!.latitude,
        longitude: _lastKnownPosition!.longitude,
        accuracy: LocationAccuracy.lastKnown,
        accuracyMeters: _lastKnownPosition!.accuracy,
        strategy: LocationStrategy.lastKnown,
        timestamp: DateTime.now(),
      );
      _history.add(result);
      return result;
    }

    // Strategy 3: Platform last known
    try {
      final position = await geo.Geolocator.getLastKnownPosition();
      if (position != null) {
        _lastKnownPosition = position;
        final result = LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: LocationAccuracy.lastKnown,
          accuracyMeters: position.accuracy,
          strategy: LocationStrategy.lastKnown,
          timestamp: DateTime.now(),
        );
        _history.add(result);
        return result;
      }
    } catch (_) {}

    // Strategy 4: Low accuracy / network
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      final result = LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: LocationAccuracy.approximate,
        accuracyMeters: position.accuracy,
        strategy: LocationStrategy.network,
        timestamp: DateTime.now(),
      );
      _history.add(result);
      return result;
    } catch (_) {}

    // Strategy 5: Default (Ahmedabad center)
    final result = LocationResult(
      latitude: 23.0225,
      longitude: 72.5714,
      accuracy: LocationAccuracy.manual,
      strategy: LocationStrategy.manual,
      timestamp: DateTime.now(),
      locationName: 'Default location',
    );
    _history.add(result);
    return result;
  }

  /// Set location from QR code scan
  LocationResult setFromQR({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    final result = LocationResult(
      latitude: latitude,
      longitude: longitude,
      accuracy: LocationAccuracy.qrCode,
      strategy: LocationStrategy.qrCode,
      timestamp: DateTime.now(),
      locationName: locationName,
    );
    _history.add(result);
    return result;
  }

  /// Start streaming location updates during emergency
  Stream<LocationResult> startEmergencyStream() {
    final controller = StreamController<LocationResult>();

    _positionStream = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (position) {
        _lastKnownPosition = position;
        final result = LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: LocationAccuracy.liveGPS,
          accuracyMeters: position.accuracy,
          strategy: LocationStrategy.gps,
          timestamp: DateTime.now(),
        );
        _history.add(result);
        controller.add(result);
      },
      onError: (e) => controller.addError(e),
    );

    return controller.stream;
  }

  /// Stop streaming
  void stopEmergencyStream() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  /// Cache location every 5 minutes for fallback
  void _startCaching() {
    _cacheTimer?.cancel();
    _cacheTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      try {
        final position = await geo.Geolocator.getCurrentPosition(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
        _lastKnownPosition = position;
      } catch (_) {}
    });
  }

  /// Calculate distance between two points in meters
  double distanceBetween(double lat1, double lng1, double lat2, double lng2) {
    return geo.Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  void dispose() {
    _positionStream?.cancel();
    _cacheTimer?.cancel();
  }
}

// Riverpod provider
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final currentLocationProvider = FutureProvider<LocationResult>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getBestLocation();
});

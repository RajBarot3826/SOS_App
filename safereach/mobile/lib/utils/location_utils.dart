/// Location Utilities
library;

import 'dart:math';

class LocationUtils {
  LocationUtils._();

  static String formatCoordinates(double lat, double lng, {int decimals = 6}) {
    return '${lat.toStringAsFixed(decimals)}, ${lng.toStringAsFixed(decimals)}';
  }

  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.toInt()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  static String getGoogleMapsUrl(double lat, double lng) {
    return 'https://maps.google.com/?q=$lat,$lng';
  }

  static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  static String estimateETA(double distanceMeters, {double speedKmh = 30.0}) {
    final hours = distanceMeters / (speedKmh * 1000);
    final minutes = (hours * 60).ceil();
    if (minutes < 1) return '<1 min';
    if (minutes < 60) return '$minutes min';
    return '${(minutes / 60).floor()}h ${minutes % 60}m';
  }
}

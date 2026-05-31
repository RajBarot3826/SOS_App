/// QR Scanner Service — Campus QR code scanning for instant location identification
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QRLocationData {
  final String locationId;
  final String building;
  final String floor;
  final String room;
  final double latitude;
  final double longitude;
  final String? name;

  const QRLocationData({
    required this.locationId,
    required this.building,
    required this.floor,
    required this.room,
    required this.latitude,
    required this.longitude,
    this.name,
  });

  /// Parse QR code content
  /// Expected format: JSON string or safereach://location/{id}
  /// JSON: {"id":"qr1","building":"Block A","floor":"2","room":"201","lat":23.0258,"lng":72.5873,"name":"Block A - Room 201"}
  factory QRLocationData.fromQRCode(String rawData) {
    // Try JSON format first
    try {
      final json = jsonDecode(rawData) as Map<String, dynamic>;
      return QRLocationData(
        locationId: json['id'] as String? ?? '',
        building: json['building'] as String? ?? 'Unknown',
        floor: json['floor'] as String? ?? 'G',
        room: json['room'] as String? ?? '-',
        latitude: (json['lat'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['lng'] as num?)?.toDouble() ?? 0.0,
        name: json['name'] as String?,
      );
    } catch (_) {}

    // Try safereach://location/{id} format
    if (rawData.startsWith('safereach://location/')) {
      final id = rawData.replaceFirst('safereach://location/', '');
      return QRLocationData.fromLocationId(id);
    }

    throw FormatException('Invalid QR code format: $rawData');
  }

  /// Lookup from known campus locations
  factory QRLocationData.fromLocationId(String id) {
    final locations = _campusLocations;
    final loc = locations.firstWhere(
      (l) => l['id'] == id,
      orElse: () => throw Exception('Unknown location ID: $id'),
    );
    return QRLocationData(
      locationId: loc['id'] as String,
      building: loc['building'] as String,
      floor: loc['floor'] as String,
      room: loc['room'] as String,
      latitude: loc['lat'] as double,
      longitude: loc['lng'] as double,
      name: loc['name'] as String?,
    );
  }

  String get displayName => name ?? '$building - Floor $floor, Room $room';

  /// Generate QR code content for a location
  String toQRContent() => jsonEncode({
        'id': locationId,
        'building': building,
        'floor': floor,
        'room': room,
        'lat': latitude,
        'lng': longitude,
        'name': name,
      });

  // Pre-populated campus locations (synced with dashboard mock data)
  static final List<Map<String, dynamic>> _campusLocations = [
    {'id': 'qr1', 'name': 'Main Gate', 'building': 'Entrance', 'floor': 'G', 'room': '-', 'lat': 23.0220, 'lng': 72.5840},
    {'id': 'qr2', 'name': 'Block A - Room 101', 'building': 'Block A', 'floor': '1', 'room': '101', 'lat': 23.0258, 'lng': 72.5873},
    {'id': 'qr3', 'name': 'Block A - Room 201', 'building': 'Block A', 'floor': '2', 'room': '201', 'lat': 23.0258, 'lng': 72.5874},
    {'id': 'qr4', 'name': 'Library - Ground Floor', 'building': 'Library', 'floor': 'G', 'room': '-', 'lat': 23.0255, 'lng': 72.5870},
    {'id': 'qr5', 'name': 'Canteen', 'building': 'Canteen Block', 'floor': 'G', 'room': '-', 'lat': 23.0265, 'lng': 72.5880},
    {'id': 'qr6', 'name': 'Hostel A - Room 15', 'building': 'Hostel A', 'floor': '1', 'room': '15', 'lat': 23.0240, 'lng': 72.5855},
    {'id': 'qr7', 'name': 'Computer Lab', 'building': 'Block B', 'floor': '2', 'room': '205', 'lat': 23.0250, 'lng': 72.5865},
    {'id': 'qr8', 'name': 'Parking Lot B', 'building': 'Parking', 'floor': 'G', 'room': '-', 'lat': 23.0245, 'lng': 72.5860},
    {'id': 'qr9', 'name': 'Auditorium', 'building': 'Main Building', 'floor': 'G', 'room': '-', 'lat': 23.0235, 'lng': 72.5845},
    {'id': 'qr10', 'name': 'Sports Complex', 'building': 'Sports', 'floor': 'G', 'room': '-', 'lat': 23.0275, 'lng': 72.5895},
    {'id': 'qr11', 'name': 'Admin Office', 'building': 'Admin Block', 'floor': '1', 'room': '102', 'lat': 23.0228, 'lng': 72.5842},
    {'id': 'qr12', 'name': 'Medical Room', 'building': 'Admin Block', 'floor': 'G', 'room': '005', 'lat': 23.0227, 'lng': 72.5841},
  ];
}

class QRScannerService {
  QRLocationData? _lastScannedLocation;

  QRLocationData? get lastScannedLocation => _lastScannedLocation;

  /// Process a scanned QR code and return parsed location data
  QRLocationData? processQRCode(String rawData) {
    try {
      final location = QRLocationData.fromQRCode(rawData);
      _lastScannedLocation = location;
      return location;
    } catch (e) {
      return null;
    }
  }

  /// Get all known campus locations (for manual selection fallback)
  List<QRLocationData> getAllCampusLocations() {
    return QRLocationData._campusLocations
        .map((loc) => QRLocationData(
              locationId: loc['id'] as String,
              building: loc['building'] as String,
              floor: loc['floor'] as String,
              room: loc['room'] as String,
              latitude: loc['lat'] as double,
              longitude: loc['lng'] as double,
              name: loc['name'] as String?,
            ))
        .toList();
  }
}

// Riverpod provider
final qrScannerServiceProvider = Provider<QRScannerService>((ref) => QRScannerService());

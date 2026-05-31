/// Incident Model — Full lifecycle state machine for SOS alerts
library;

import 'package:safereach/models/accessibility_profile.dart';

enum IncidentStatus {
  created,
  sent,
  delivered,
  acknowledged,
  responderAssigned,
  helpOnTheWay,
  resolved,
  cancelled,
  falseAlert,
}

enum IncidentType {
  medical,
  safety,
  mobility,
  navigation,
  health,
  custom,
  fallDetected,
  inactivityDetected,
  panicDetected,
}

enum LocationAccuracy {
  liveGPS,
  approximate,
  lastKnown,
  manuallySelected,
  qrCode,
  manual,
}

class IncidentLocation {
  final double latitude;
  final double longitude;
  final LocationAccuracy accuracy;
  final double? accuracyMeters;
  final String? locationName;
  final DateTime timestamp;

  const IncidentLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.accuracyMeters,
    this.locationName,
    required this.timestamp,
  });

  String get badge {
    switch (accuracy) {
      case LocationAccuracy.liveGPS:
        return '🟢 LIVE GPS${accuracyMeters != null ? " (${accuracyMeters!.round()}m)" : ""}';
      case LocationAccuracy.approximate:
        return '🟡 APPROXIMATE (Wi-Fi/Cell)';
      case LocationAccuracy.lastKnown:
        final elapsed = DateTime.now().difference(timestamp);
        return '🟠 LAST KNOWN (${_formatDuration(elapsed)} ago)';
      case LocationAccuracy.manuallySelected:
        return '🔵 MANUALLY SELECTED${locationName != null ? " ($locationName)" : ""}';
      case LocationAccuracy.qrCode:
        return '🔵 QR LOCATION${locationName != null ? " ($locationName)" : ""}';
      case LocationAccuracy.manual:
        return '⚪ MANUAL${locationName != null ? " ($locationName)" : ""}';
    }
  }

  String get googleMapsUrl =>
      'https://maps.google.com/?q=$latitude,$longitude';

  String get coordinateString => '$latitude,$longitude';

  static String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}s';
    if (d.inHours < 1) return '${d.inMinutes}min';
    return '${d.inHours}h ${d.inMinutes % 60}min';
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy.name,
        'accuracyMeters': accuracyMeters,
        'locationName': locationName,
        'timestamp': timestamp.toIso8601String(),
      };

  factory IncidentLocation.fromJson(Map<String, dynamic> json) {
    return IncidentLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      accuracy: LocationAccuracy.values.firstWhere(
        (v) => v.name == json['accuracy'],
        orElse: () => LocationAccuracy.lastKnown,
      ),
      accuracyMeters: json['accuracyMeters']?.toDouble(),
      locationName: json['locationName'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class TimelineEntry {
  final String event;
  final DateTime timestamp;
  final String? actorName;
  final String? details;

  const TimelineEntry({
    required this.event,
    required this.timestamp,
    this.actorName,
    this.details,
  });

  Map<String, dynamic> toJson() => {
        'event': event,
        'timestamp': timestamp.toIso8601String(),
        'actorName': actorName,
        'details': details,
      };

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      event: json['event'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      actorName: json['actorName'],
      details: json['details'],
    );
  }
}

class ContactAlert {
  final String contactId;
  final String contactName;
  final String contactPhone;
  final int priority;
  final bool isDelivered;
  final bool isAcknowledged;
  final bool isOnTheWay;
  final DateTime? deliveredAt;
  final DateTime? acknowledgedAt;
  final DateTime? onTheWayAt;
  final String? estimatedETA;

  const ContactAlert({
    required this.contactId,
    required this.contactName,
    required this.contactPhone,
    required this.priority,
    this.isDelivered = false,
    this.isAcknowledged = false,
    this.isOnTheWay = false,
    this.deliveredAt,
    this.acknowledgedAt,
    this.onTheWayAt,
    this.estimatedETA,
  });

  Map<String, dynamic> toJson() => {
        'contactId': contactId,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'priority': priority,
        'isDelivered': isDelivered,
        'isAcknowledged': isAcknowledged,
        'isOnTheWay': isOnTheWay,
        'deliveredAt': deliveredAt?.toIso8601String(),
        'acknowledgedAt': acknowledgedAt?.toIso8601String(),
        'onTheWayAt': onTheWayAt?.toIso8601String(),
        'estimatedETA': estimatedETA,
      };

  factory ContactAlert.fromJson(Map<String, dynamic> json) {
    return ContactAlert(
      contactId: json['contactId'] ?? '',
      contactName: json['contactName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      priority: json['priority'] ?? 0,
      isDelivered: json['isDelivered'] ?? false,
      isAcknowledged: json['isAcknowledged'] ?? false,
      isOnTheWay: json['isOnTheWay'] ?? false,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      acknowledgedAt: json['acknowledgedAt'] != null ? DateTime.parse(json['acknowledgedAt']) : null,
      onTheWayAt: json['onTheWayAt'] != null ? DateTime.parse(json['onTheWayAt']) : null,
      estimatedETA: json['estimatedETA'],
    );
  }

  ContactAlert copyWith({
    bool? isDelivered,
    bool? isAcknowledged,
    bool? isOnTheWay,
    DateTime? deliveredAt,
    DateTime? acknowledgedAt,
    DateTime? onTheWayAt,
    String? estimatedETA,
  }) {
    return ContactAlert(
      contactId: contactId,
      contactName: contactName,
      contactPhone: contactPhone,
      priority: priority,
      isDelivered: isDelivered ?? this.isDelivered,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isOnTheWay: isOnTheWay ?? this.isOnTheWay,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      onTheWayAt: onTheWayAt ?? this.onTheWayAt,
      estimatedETA: estimatedETA ?? this.estimatedETA,
    );
  }
}

class Incident {
  final String id;
  final String userId;
  final String userName;
  final IncidentStatus status;
  final IncidentType type;
  final SOSActivationMethod activationMethod;
  final IncidentLocation location;
  final List<IncidentLocation> locationHistory;
  final String emergencyMessage;
  final List<ContactAlert> contactAlerts;
  final List<TimelineEntry> timeline;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? cancelledAt;
  final String? resolvedBy;
  final String? cancelReason;
  final double? aiConfidenceScore;
  final bool isSilent;
  final List<String> userDisabilities;

  const Incident({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.type,
    required this.activationMethod,
    required this.location,
    this.locationHistory = const [],
    required this.emergencyMessage,
    this.contactAlerts = const [],
    this.timeline = const [],
    required this.createdAt,
    this.resolvedAt,
    this.cancelledAt,
    this.resolvedBy,
    this.cancelReason,
    this.aiConfidenceScore,
    this.isSilent = false,
    this.userDisabilities = const [],
  });

  bool get isActive =>
      status != IncidentStatus.resolved &&
      status != IncidentStatus.cancelled &&
      status != IncidentStatus.falseAlert;

  Duration get elapsed => DateTime.now().difference(createdAt);

  bool get needsEscalation {
    if (!isActive) return false;
    final hasAcknowledgment = contactAlerts.any((c) => c.isAcknowledged);
    return !hasAcknowledgment;
  }

  int get currentEscalationLevel {
    final minutes = elapsed.inMinutes;
    if (minutes >= 15) return 4;
    if (minutes >= 10) return 3;
    if (minutes >= 6) return 2;
    if (minutes >= 3) return 1;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'status': status.name,
        'type': type.name,
        'activationMethod': activationMethod.name,
        'location': location.toJson(),
        'locationHistory': locationHistory.map((l) => l.toJson()).toList(),
        'emergencyMessage': emergencyMessage,
        'contactAlerts': contactAlerts.map((c) => c.toJson()).toList(),
        'timeline': timeline.map((t) => t.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
        'cancelledAt': cancelledAt?.toIso8601String(),
        'resolvedBy': resolvedBy,
        'cancelReason': cancelReason,
        'aiConfidenceScore': aiConfidenceScore,
        'isSilent': isSilent,
        'userDisabilities': userDisabilities,
      };

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      status: IncidentStatus.values.firstWhere(
        (v) => v.name == json['status'],
        orElse: () => IncidentStatus.created,
      ),
      type: IncidentType.values.firstWhere(
        (v) => v.name == json['type'],
        orElse: () => IncidentType.custom,
      ),
      activationMethod: SOSActivationMethod.values.firstWhere(
        (v) => v.name == json['activationMethod'],
        orElse: () => SOSActivationMethod.oneTap,
      ),
      location: IncidentLocation.fromJson(json['location'] ?? {}),
      locationHistory: (json['locationHistory'] as List<dynamic>?)
              ?.map((l) => IncidentLocation.fromJson(l))
              .toList() ??
          [],
      emergencyMessage: json['emergencyMessage'] ?? '',
      contactAlerts: (json['contactAlerts'] as List<dynamic>?)
              ?.map((c) => ContactAlert.fromJson(c))
              .toList() ??
          [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((t) => TimelineEntry.fromJson(t))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      resolvedBy: json['resolvedBy'],
      cancelReason: json['cancelReason'],
      aiConfidenceScore: json['aiConfidenceScore']?.toDouble(),
      isSilent: json['isSilent'] ?? false,
      userDisabilities: (json['userDisabilities'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Incident copyWith({
    IncidentStatus? status,
    IncidentLocation? location,
    List<IncidentLocation>? locationHistory,
    List<ContactAlert>? contactAlerts,
    List<TimelineEntry>? timeline,
    DateTime? resolvedAt,
    DateTime? cancelledAt,
    String? resolvedBy,
    String? cancelReason,
    double? aiConfidenceScore,
  }) {
    return Incident(
      id: id,
      userId: userId,
      userName: userName,
      status: status ?? this.status,
      type: type,
      activationMethod: activationMethod,
      location: location ?? this.location,
      locationHistory: locationHistory ?? this.locationHistory,
      emergencyMessage: emergencyMessage,
      contactAlerts: contactAlerts ?? this.contactAlerts,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      cancelReason: cancelReason ?? this.cancelReason,
      aiConfidenceScore: aiConfidenceScore ?? this.aiConfidenceScore,
      isSilent: isSilent,
      userDisabilities: userDisabilities,
    );
  }
}

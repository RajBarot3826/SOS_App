/// Emergency Contact Model
library;

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String countryCode;
  final String relationship;
  final int priority;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? photoUrl;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.countryCode = '+91',
    required this.relationship,
    required this.priority,
    this.isAcknowledged = false,
    this.acknowledgedAt,
    this.photoUrl,
  });

  String get fullPhoneNumber => '$countryCode$phone';

  String get displayPhone => '$countryCode $phone';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'countryCode': countryCode,
        'relationship': relationship,
        'priority': priority,
        'isAcknowledged': isAcknowledged,
        'acknowledgedAt': acknowledgedAt?.toIso8601String(),
        'photoUrl': photoUrl,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      countryCode: json['countryCode'] ?? '+91',
      relationship: json['relationship'] ?? 'Other',
      priority: json['priority'] ?? 0,
      isAcknowledged: json['isAcknowledged'] ?? false,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.parse(json['acknowledgedAt'])
          : null,
      photoUrl: json['photoUrl'],
    );
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? countryCode,
    String? relationship,
    int? priority,
    bool? isAcknowledged,
    DateTime? acknowledgedAt,
    String? photoUrl,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      relationship: relationship ?? this.relationship,
      priority: priority ?? this.priority,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

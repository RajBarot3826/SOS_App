/// User Profile Model — Complete user data with all SafeReach fields
library;

import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/models/emergency_contact.dart';
import 'package:safereach/models/safe_location.dart';

enum UserRole {
  user,
  responder,
  volunteer,
  admin,
}

class MedicalInfo {
  final String? bloodGroup;
  final String? allergies;
  final String? medicalConditions;
  final String? doctorName;
  final String? doctorPhone;
  final bool hasConsented;

  const MedicalInfo({
    this.bloodGroup,
    this.allergies,
    this.medicalConditions,
    this.doctorName,
    this.doctorPhone,
    this.hasConsented = false,
  });

  Map<String, dynamic> toJson() => {
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'medicalConditions': medicalConditions,
        'doctorName': doctorName,
        'doctorPhone': doctorPhone,
        'hasConsented': hasConsented,
      };

  factory MedicalInfo.fromJson(Map<String, dynamic> json) {
    return MedicalInfo(
      bloodGroup: json['bloodGroup'],
      allergies: json['allergies'],
      medicalConditions: json['medicalConditions'],
      doctorName: json['doctorName'],
      doctorPhone: json['doctorPhone'],
      hasConsented: json['hasConsented'] ?? false,
    );
  }

  MedicalInfo copyWith({
    String? bloodGroup,
    String? allergies,
    String? medicalConditions,
    String? doctorName,
    String? doctorPhone,
    bool? hasConsented,
  }) {
    return MedicalInfo(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      hasConsented: hasConsented ?? this.hasConsented,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String? photoUrl;
  final int? age;
  final UserRole role;
  final String preferredLanguage;
  final AccessibilityProfile accessibilityProfile;
  final List<EmergencyContact> emergencyContacts;
  final MedicalInfo medicalInfo;
  final List<SafeLocation> safeLocations;
  final List<String> customEmergencyMessages;
  final bool isOnboardingComplete;
  final bool hasSetupPin;
  final String? pin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Volunteer-specific fields
  final String? studentId;
  final String? department;
  final String? volunteerStatus; // available, busy, off-duty
  final String? assignedZone;

  const UserProfile({
    required this.id,
    required this.name,
    this.photoUrl,
    this.age,
    this.role = UserRole.user,
    this.preferredLanguage = 'en',
    this.accessibilityProfile = const AccessibilityProfile(),
    this.emergencyContacts = const [],
    this.medicalInfo = const MedicalInfo(),
    this.safeLocations = const [],
    this.customEmergencyMessages = const [],
    this.isOnboardingComplete = false,
    this.hasSetupPin = false,
    this.pin,
    required this.createdAt,
    required this.updatedAt,
    this.studentId,
    this.department,
    this.volunteerStatus,
    this.assignedZone,
  });

  bool get hasMinimumContacts => emergencyContacts.length >= 2;

  List<EmergencyContact> get sortedContacts {
    final sorted = List<EmergencyContact>.from(emergencyContacts);
    sorted.sort((a, b) => a.priority.compareTo(b.priority));
    return sorted;
  }

  EmergencyContact? get primaryContact =>
      sortedContacts.isNotEmpty ? sortedContacts.first : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'age': age,
        'role': role.name,
        'preferredLanguage': preferredLanguage,
        'accessibilityProfile': accessibilityProfile.toJson(),
        'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
        'medicalInfo': medicalInfo.toJson(),
        'safeLocations': safeLocations.map((l) => l.toJson()).toList(),
        'customEmergencyMessages': customEmergencyMessages,
        'isOnboardingComplete': isOnboardingComplete,
        'hasSetupPin': hasSetupPin,
        'pin': pin,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'studentId': studentId,
        'department': department,
        'volunteerStatus': volunteerStatus,
        'assignedZone': assignedZone,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
      age: json['age'],
      role: UserRole.values.firstWhere(
        (v) => v.name == json['role'],
        orElse: () => UserRole.user,
      ),
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      accessibilityProfile: json['accessibilityProfile'] != null
          ? AccessibilityProfile.fromJson(json['accessibilityProfile'])
          : const AccessibilityProfile(),
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
              ?.map((c) => EmergencyContact.fromJson(c))
              .toList() ??
          [],
      medicalInfo: json['medicalInfo'] != null
          ? MedicalInfo.fromJson(json['medicalInfo'])
          : const MedicalInfo(),
      safeLocations: (json['safeLocations'] as List<dynamic>?)
              ?.map((l) => SafeLocation.fromJson(l))
              .toList() ??
          [],
      customEmergencyMessages:
          (json['customEmergencyMessages'] as List<dynamic>?)?.cast<String>() ?? [],
      isOnboardingComplete: json['isOnboardingComplete'] ?? false,
      hasSetupPin: json['hasSetupPin'] ?? false,
      pin: json['pin'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      studentId: json['studentId'],
      department: json['department'],
      volunteerStatus: json['volunteerStatus'],
      assignedZone: json['assignedZone'],
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? photoUrl,
    int? age,
    UserRole? role,
    String? preferredLanguage,
    AccessibilityProfile? accessibilityProfile,
    List<EmergencyContact>? emergencyContacts,
    MedicalInfo? medicalInfo,
    List<SafeLocation>? safeLocations,
    List<String>? customEmergencyMessages,
    bool? isOnboardingComplete,
    bool? hasSetupPin,
    String? pin,
    DateTime? updatedAt,
    String? studentId,
    String? department,
    String? volunteerStatus,
    String? assignedZone,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      role: role ?? this.role,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      accessibilityProfile: accessibilityProfile ?? this.accessibilityProfile,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      safeLocations: safeLocations ?? this.safeLocations,
      customEmergencyMessages: customEmergencyMessages ?? this.customEmergencyMessages,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      hasSetupPin: hasSetupPin ?? this.hasSetupPin,
      pin: pin ?? this.pin,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      volunteerStatus: volunteerStatus ?? this.volunteerStatus,
      assignedZone: assignedZone ?? this.assignedZone,
    );
  }
}

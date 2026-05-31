/// Profile Provider — Manages user profile state
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safereach/models/user_profile.dart';
import 'package:safereach/models/emergency_contact.dart';
import 'package:safereach/models/safe_location.dart';
import 'package:safereach/models/accessibility_profile.dart';
import 'package:safereach/services/storage_service.dart';
import 'package:uuid/uuid.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProfileNotifier(storage);
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final StorageService _storage;
  static const _uuid = Uuid();

  ProfileNotifier(this._storage) : super(null) {
    _loadProfile();
  }

  void _loadProfile() {
    state = _storage.getProfile();
  }

  Future<void> createProfile({
    required String name,
    required UserRole role,
    String? photoUrl,
    int? age,
    String preferredLanguage = 'en',
  }) async {
    final profile = UserProfile(
      id: _uuid.v4(),
      name: name,
      photoUrl: photoUrl,
      age: age,
      role: role,
      preferredLanguage: preferredLanguage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = profile;
    await _storage.saveProfile(profile);
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile.copyWith(updatedAt: DateTime.now());
    await _storage.saveProfile(state!);
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    await updateProfile(state!.copyWith(name: name));
  }

  Future<void> updateAge(int age) async {
    if (state == null) return;
    await updateProfile(state!.copyWith(age: age));
  }

  Future<void> updateLanguage(String language) async {
    if (state == null) return;
    await updateProfile(state!.copyWith(preferredLanguage: language));
  }

  Future<void> updateAccessibilityProfile(
      AccessibilityProfile accessibilityProfile) async {
    if (state == null) return;
    final adapted = accessibilityProfile.autoAdapt();
    await updateProfile(state!.copyWith(accessibilityProfile: adapted));
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    if (state == null) return;
    final contacts = List<EmergencyContact>.from(state!.emergencyContacts)
      ..add(contact);
    await updateProfile(state!.copyWith(emergencyContacts: contacts));
  }

  Future<void> removeEmergencyContact(String contactId) async {
    if (state == null) return;
    final contacts = state!.emergencyContacts
        .where((c) => c.id != contactId)
        .toList();
    await updateProfile(state!.copyWith(emergencyContacts: contacts));
  }

  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    if (state == null) return;
    final contacts = state!.emergencyContacts
        .map((c) => c.id == contact.id ? contact : c)
        .toList();
    await updateProfile(state!.copyWith(emergencyContacts: contacts));
  }

  Future<void> reorderContacts(List<EmergencyContact> contacts) async {
    if (state == null) return;
    final reordered = contacts
        .asMap()
        .entries
        .map((e) => e.value.copyWith(priority: e.key))
        .toList();
    await updateProfile(state!.copyWith(emergencyContacts: reordered));
  }

  Future<void> updateMedicalInfo(MedicalInfo medicalInfo) async {
    if (state == null) return;
    await updateProfile(state!.copyWith(medicalInfo: medicalInfo));
  }

  Future<void> addSafeLocation(SafeLocation location) async {
    if (state == null) return;
    final locations = List<SafeLocation>.from(state!.safeLocations)
      ..add(location);
    await updateProfile(state!.copyWith(safeLocations: locations));
  }

  Future<void> removeSafeLocation(String locationId) async {
    if (state == null) return;
    final locations =
        state!.safeLocations.where((l) => l.id != locationId).toList();
    await updateProfile(state!.copyWith(safeLocations: locations));
  }

  Future<void> addCustomMessage(String message) async {
    if (state == null) return;
    if (state!.customEmergencyMessages.length >= 10) return;
    final messages = List<String>.from(state!.customEmergencyMessages)
      ..add(message);
    await updateProfile(state!.copyWith(customEmergencyMessages: messages));
  }

  Future<void> removeCustomMessage(int index) async {
    if (state == null) return;
    final messages = List<String>.from(state!.customEmergencyMessages)
      ..removeAt(index);
    await updateProfile(state!.copyWith(customEmergencyMessages: messages));
  }

  Future<void> completeOnboarding() async {
    if (state == null) return;
    await updateProfile(state!.copyWith(isOnboardingComplete: true));
    await _storage.setOnboardingComplete(true);
  }

  Future<void> setupPin(String pin) async {
    if (state == null) return;
    await updateProfile(state!.copyWith(hasSetupPin: true, pin: pin));
  }

  Future<void> deleteAllData() async {
    state = null;
    await _storage.deleteAllData();
  }
}

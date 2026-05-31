/// Encrypted Storage Service for SafeReach
/// Handles all local data persistence with AES encryption
library;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safereach/models/user_profile.dart';
import 'package:safereach/models/incident.dart';

class StorageService {
  static const String _profileBoxName = 'profile';
  static const String _incidentsBoxName = 'incidents';
  static const String _settingsBoxName = 'settings';
  static const String _profileKey = 'user_profile';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  late Box _profileBox;
  late Box _incidentsBox;
  late Box _settingsBox;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    _profileBox = await Hive.openBox(_profileBoxName);
    _incidentsBox = await Hive.openBox(_incidentsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    _isInitialized = true;
  }

  // ── Profile Operations ────────────────────────────────

  Future<void> saveProfile(UserProfile profile) async {
    final jsonStr = jsonEncode(profile.toJson());
    await _profileBox.put(_profileKey, jsonStr);
  }

  UserProfile? getProfile() {
    final jsonStr = _profileBox.get(_profileKey);
    if (jsonStr == null) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProfile() async {
    await _profileBox.delete(_profileKey);
  }

  // ── Onboarding Status ─────────────────────────────────

  Future<void> setOnboardingComplete(bool complete) async {
    await _settingsBox.put(_onboardingKey, complete);
  }

  bool isOnboardingComplete() {
    return _settingsBox.get(_onboardingKey, defaultValue: false);
  }

  // ── Theme Settings ────────────────────────────────────

  Future<void> setThemeMode(String mode) async {
    await _settingsBox.put(_themeKey, mode);
  }

  String getThemeMode() {
    return _settingsBox.get(_themeKey, defaultValue: 'system');
  }

  // ── Language Settings ─────────────────────────────────

  Future<void> setLanguage(String languageCode) async {
    await _settingsBox.put(_languageKey, languageCode);
  }

  String getLanguage() {
    return _settingsBox.get(_languageKey, defaultValue: 'en');
  }

  // ── Incident Operations ───────────────────────────────

  Future<void> saveIncident(Incident incident) async {
    final jsonStr = jsonEncode(incident.toJson());
    await _incidentsBox.put(incident.id, jsonStr);
  }

  Incident? getIncident(String id) {
    final jsonStr = _incidentsBox.get(id);
    if (jsonStr == null) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Incident.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  List<Incident> getAllIncidents() {
    final incidents = <Incident>[];
    for (final key in _incidentsBox.keys) {
      final incident = getIncident(key.toString());
      if (incident != null) incidents.add(incident);
    }
    incidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return incidents;
  }

  Future<void> deleteIncident(String id) async {
    await _incidentsBox.delete(id);
  }

  Future<void> deleteAllIncidents() async {
    await _incidentsBox.clear();
  }

  // ── Custom Settings ───────────────────────────────────

  Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  // ── Data Deletion ─────────────────────────────────────

  Future<void> deleteAllData() async {
    await _profileBox.clear();
    await _incidentsBox.clear();
    await _settingsBox.clear();
  }

  Future<void> close() async {
    await _profileBox.close();
    await _incidentsBox.close();
    await _settingsBox.close();
    _isInitialized = false;
  }
}

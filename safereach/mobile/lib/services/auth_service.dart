/// Auth Service — PIN + biometric authentication
library;


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

enum AuthState { unauthenticated, authenticated, locked }

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  String? _storedPinHash;
  bool _biometricEnabled = false;
  AuthState _state = AuthState.unauthenticated;

  AuthState get state => _state;
  bool get biometricEnabled => _biometricEnabled;
  bool get hasPinSet => _storedPinHash != null;

  /// Initialize auth service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _storedPinHash = prefs.getString('safereach_pin_hash');
    _biometricEnabled = prefs.getBool('safereach_biometric') ?? false;
  }

  /// Set up PIN
  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('safereach_pin_hash', hash);
    _storedPinHash = hash;
  }

  /// Verify PIN
  bool verifyPin(String pin) {
    if (_storedPinHash == null) return false;
    final hash = _hashPin(pin);
    final valid = hash == _storedPinHash;
    if (valid) _state = AuthState.authenticated;
    return valid;
  }

  /// Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Enable/disable biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('safereach_biometric', enabled);
    _biometricEnabled = enabled;
  }

  /// Authenticate with biometric
  Future<bool> authenticateWithBiometric({String reason = 'Authenticate to access SafeReach'}) async {
    try {
      final success = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (success) _state = AuthState.authenticated;
      return success;
    } catch (_) {
      return false;
    }
  }

  /// Verify identity for cancelling SOS (PIN or biometric)
  Future<bool> verifyIdentityForCancel() async {
    if (_biometricEnabled) {
      return authenticateWithBiometric(
        reason: 'Verify your identity to cancel the SOS alert',
      );
    }
    // PIN verification handled via UI
    return false;
  }

  /// Lock the app
  void lock() {
    _state = AuthState.locked;
  }

  /// Logout
  void logout() {
    _state = AuthState.unauthenticated;
  }

  /// Delete all auth data
  Future<void> deleteAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('safereach_pin_hash');
    await prefs.remove('safereach_biometric');
    _storedPinHash = null;
    _biometricEnabled = false;
    _state = AuthState.unauthenticated;
  }

  /// Simple hash function for PIN (use bcrypt in production)
  String _hashPin(String pin) {
    final key = encrypt.Key.fromUtf8('SafeReachPINKey!'); // 16 bytes
    final iv = encrypt.IV.fromUtf8('SafeReachPINIV!!'); // 16 bytes
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(pin, iv: iv).base64;
  }
}

// Riverpod providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateProvider<AuthState>((ref) => AuthState.unauthenticated);

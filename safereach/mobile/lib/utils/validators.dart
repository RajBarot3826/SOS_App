/// Input Validators
library;

class Validators {
  Validators._();

  static String? requiredField(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length < 10) return 'Phone number must be at least 10 digits';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'PIN is required';
    if (value.length < 4 || value.length > 6) return 'PIN must be 4-6 digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'PIN must contain only digits';
    return null;
  }

  static String? latitude(String? value) {
    if (value == null || value.isEmpty) return 'Latitude is required';
    final lat = double.tryParse(value);
    if (lat == null || lat < -90 || lat > 90) return 'Invalid latitude (-90 to 90)';
    return null;
  }

  static String? longitude(String? value) {
    if (value == null || value.isEmpty) return 'Longitude is required';
    final lng = double.tryParse(value);
    if (lng == null || lng < -180 || lng > 180) return 'Invalid longitude (-180 to 180)';
    return null;
  }
}

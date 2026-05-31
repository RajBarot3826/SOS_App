import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Create or update user profile upon login
  Future<void> syncUserProfile() async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'demo_uid_12345';
    final phone = user?.phoneNumber ?? '+919409630896';

    // Get FCM Token
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    await _firestore.collection('users').doc(phone).set({
      'phoneNumber': phone,
      'uid': uid,
      'fcmToken': fcmToken,
      'lastActive': FieldValue.serverTimestamp(),
      'isAppUser': true,
    }, SetOptions(merge: true));
  }

  // Check if a contact phone number is registered in the app
  Future<bool> isContactAppUser(String phoneNumber) async {
    try {
      // Clean phone number (remove spaces, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
      
      final doc = await _firestore.collection('users').doc(cleanNumber).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Start SOS Session and Stream Location
  Future<void> startActiveSOS({
    required String incidentId,
    required double lat,
    required double lng,
    required int batteryLevel,
    required String userName,
    required String emergencyType,
    required String emergencyMessage,
    List<String> disabilities = const [],
    Map<String, dynamic> medicalInfo = const {},
  }) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'demo_uid_12345';
    final phone = user?.phoneNumber ?? '+919409630896';

    await _firestore.collection('incidents').doc(incidentId).set({
      'userId': uid,
      'phoneNumber': phone,
      'userName': userName,
      'emergencyType': emergencyType,
      'emergencyMessage': emergencyMessage,
      'disabilities': disabilities,
      'medicalInfo': medicalInfo,
      'startTime': FieldValue.serverTimestamp(),
      'isActive': true,
      'startLocation': GeoPoint(lat, lng),
      'currentLocation': GeoPoint(lat, lng),
      'batteryLevel': batteryLevel,
    });
  }

  // Update Location During SOS
  Future<void> updateSOSLocation(String incidentId, double lat, double lng, int batteryLevel) async {
    await _firestore.collection('incidents').doc(incidentId).update({
      'currentLocation': GeoPoint(lat, lng),
      'batteryLevel': batteryLevel,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // End SOS Session
  Future<void> endActiveSOS(String incidentId) async {
    await _firestore.collection('incidents').doc(incidentId).update({
      'isActive': false,
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  // Stream active incident for a contact to track
  Stream<DocumentSnapshot> streamIncident(String incidentId) {
    return _firestore.collection('incidents').doc(incidentId).snapshots();
  }

  // Stream all active incidents (For Responder Mode 2-Device Demo)
  Stream<QuerySnapshot> streamAllActiveIncidents() {
    return _firestore
        .collection('incidents')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

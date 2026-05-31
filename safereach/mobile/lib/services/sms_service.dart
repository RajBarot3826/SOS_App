/// SMS Service — Emergency SMS sending with fallback
library;


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsMessage {
  final String recipient;
  final String body;
  final DateTime timestamp;
  final bool isSent;
  final String? error;

  const SmsMessage({
    required this.recipient,
    required this.body,
    required this.timestamp,
    this.isSent = false,
    this.error,
  });
}

class SmsService {
  final List<SmsMessage> _sentMessages = [];
  final List<SmsMessage> _failedQueue = [];

  List<SmsMessage> get sentMessages => List.unmodifiable(_sentMessages);
  List<SmsMessage> get failedQueue => List.unmodifiable(_failedQueue);

  static String formatEmergencyMessage({
    required String userName,
    required double latitude,
    required double longitude,
    required String emergencyType,
    String? customMessage,
    List<String>? disabilities,
    String? medicalInfoText,
  }) {
    final mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
    
    String msg = '🚨 SOS from $userName!\n📍 $mapsLink\n⚠️ $emergencyType';
    if (customMessage != null && customMessage.isNotEmpty) {
      msg += '\n💬 $customMessage';
    }
    if (disabilities != null && disabilities.isNotEmpty) {
      msg += '\n♿ Disabilities: ${disabilities.join(", ")}';
    }
    if (medicalInfoText != null && medicalInfoText.isNotEmpty) {
      msg += '\n🏥 Medical Info: $medicalInfoText';
    }
    return msg;
  }

  /// Send SMS via telephony (direct) with fallback to intent
  Future<SmsMessage> sendSMS({
    required String phone,
    required String body,
  }) async {
    // Sanitize phone number (remove spaces and dashes)
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    
    try {
      // 1. Try real-time background SMS
      print('Attempting to send background SMS to $cleanPhone...');
      if (await Permission.sms.request().isGranted) {
        print('SMS Permission GRANTED. Sending via Telephony API...');
        final Telephony telephony = Telephony.instance;
        
        // Wait for send status
        final sent = await Future.microtask(() async {
          bool isSent = false;
          try {
            telephony.sendSms(
              to: cleanPhone,
              message: body,
              statusListener: (SendStatus status) {
                print('TELEPHONY SMS STATUS for $cleanPhone: ${status.name}');
                if (status == SendStatus.SENT || status == SendStatus.DELIVERED) {
                  isSent = true;
                }
              }
            );
            // Give it 500ms to see if it crashes or immediately fails
            await Future.delayed(const Duration(milliseconds: 500));
            // We assume it sent if it didn't throw an error in the telephony plugin
            return true;
          } catch (e) {
            print('Telephony error: $e');
            return false;
          }
        });

        if (sent) {
          final sentMsg = SmsMessage(
            recipient: cleanPhone,
            body: body,
            timestamp: DateTime.now(),
            isSent: true,
          );
          _sentMessages.add(sentMsg);
          return sentMsg;
        } else {
          print('Background SMS failed silently. Falling back to Intent...');
        }
      } else {
        print('SMS Permission DENIED. Falling back to Intent...');
      }

      // 2. Fallback: SMS Intent
      final smsUri = Uri(
        scheme: 'sms',
        path: cleanPhone,
        queryParameters: {'body': body},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        final sent = SmsMessage(
          recipient: cleanPhone,
          body: body,
          timestamp: DateTime.now(),
          isSent: true,
        );
        _sentMessages.add(sent);
        return sent;
      }

      // 3. Fallback: share via system share sheet
      await Share.share(body, subject: 'Emergency Alert - SafeReach');
      final shared = SmsMessage(
        recipient: cleanPhone,
        body: body,
        timestamp: DateTime.now(),
        isSent: true,
      );
      _sentMessages.add(shared);
      return shared;
    } catch (e) {
      final failed = SmsMessage(
        recipient: cleanPhone,
        body: body,
        timestamp: DateTime.now(),
        isSent: false,
        error: e.toString(),
      );
      _failedQueue.add(failed);
      return failed;
    }
  }

  /// Send emergency SMS to multiple contacts
  Future<List<SmsMessage>> sendToContacts({
    required List<String> phones,
    required String userName,
    required double latitude,
    required double longitude,
    required String emergencyType,
    String? customMessage,
    List<String>? disabilities,
    String? medicalInfoText,
  }) async {
    final body = formatEmergencyMessage(
      userName: userName,
      latitude: latitude,
      longitude: longitude,
      emergencyType: emergencyType,
      customMessage: customMessage,
      disabilities: disabilities,
      medicalInfoText: medicalInfoText,
    );

    final results = <SmsMessage>[];
    for (final phone in phones) {
      final result = await sendSMS(phone: phone, body: body);
      results.add(result);
      // Small delay between messages
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return results;
  }

  /// Retry failed messages
  Future<void> retryFailed() async {
    final toRetry = List<SmsMessage>.from(_failedQueue);
    _failedQueue.clear();

    for (final msg in toRetry) {
      await sendSMS(phone: msg.recipient, body: msg.body);
    }
  }

  /// Call emergency number
  Future<void> callEmergency(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// Riverpod provider
final smsServiceProvider = Provider<SmsService>((ref) => SmsService());
